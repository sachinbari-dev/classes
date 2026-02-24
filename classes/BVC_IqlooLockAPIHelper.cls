/*
 * Developer: Sangale govind
 * Created On: 28/04/2025
 * ---------------------------------------------------------------------------------------------------------------------------
 * Version : Modified By     |  Modified date  |  Modified Details
 -----------------------------------------------------------------------------------------------------------------------------
 *  1.0    : Sangale govind  | 28/04/2025      |   New class-  method added for token generation generateAccessToken
 *  1.1    : Sangale Govind  | 12/05/2025      |   method added getIqlooSinglePin and it's related Inner wrapper Classes
 *  1.2    : sangale Govind  | 13/05/2025      |   method added getIqlooMasterPIN and it's related ineer wrapper classes
 ----------------------------------------------------------------------------------------------------------------------------
 * Description:  IqlooLock API For Thomas Project
 */

public class BVC_IqlooLockAPIHelper {

    //Iqloo Token Generation Callout
    public static String generateAccessToken() {
            
            String endpointUrl;
            IqlooRequestWrapper reqWrapper;
            
            List<Iqloo_Lock__mdt> mdtList = [SELECT Id, DeveloperName, Username__c, Password__c, Endpoint__c, scope__c 
                                              FROM Iqloo_Lock__mdt WHERE DeveloperName = 'Login_credentials' LIMIT 1];
            
            if (!mdtList.isEmpty()) {
                for(Iqloo_Lock__mdt mdt : mdtList){
                    endpointUrl = mdt.Endpoint__c;
                    
                    reqWrapper = new IqlooRequestWrapper();
                    reqWrapper.username = mdt.Username__c;
                    reqWrapper.password = mdt.Password__c;
                    reqWrapper.grant_type = 'client_credentials'; 
                    reqWrapper.scope = mdt.scope__c;  
                }
            } else {
                throw new AuraHandledException('Login credentials not found in Custom Metadata');
            }
            
            String requestBody = reqWrapper.toUrlEncodedString();
           
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
           
            String authHeaderValue = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(reqWrapper.username + ':' + reqWrapper.password));
            req.setHeader('Authorization', authHeaderValue);
            
            req.setBody(requestBody);
            System.debug('requestBody: ' + requestBody);
        
            Http http = new Http();
            HttpResponse res = http.send(req);
           
            if (res.getStatusCode() == 200) {
                IqlooResponseWrapper response = (IqlooResponseWrapper) JSON.deserialize(res.getBody(), IqlooResponseWrapper.class);
                System.debug('Response: ' + response);
                
                if(!Test.isRunningTest()){
                    Shield_Lock_Audit_Log__c  s = [select id,Access_Token__c, name from Shield_Lock_Audit_Log__c where name ='SL-00001' LIMIT 1];
                  s.Access_Token__c = response.access_token;
                
                  update s;
                }
                
                
                return response.access_token;
            } else {
                
                 integration_Log__c intlg = new integration_Log__c();
                      
                      intlg.Status_Code__c =  String.valueOf(res.getStatusCode());
                      intlg.Response_JSON__c = res.getBody();
                      intlg.Error_Reason__c = 'IqlooLock Token generation API error' +  res.getBody() ;
                      intlg.Integration_Server__c = 'IqlooLock';
                        insert intlg;
                System.debug('Failed to fetch Access Token: ' + res.getBody());
               
                return 'Error fetching Access Token';
               
            }
        }
    
        public class IqlooRequestWrapper {
            public String username;
            public String password;
            public String grant_type;
            public String scope;
    
            public String toUrlEncodedString() {
                return 'grant_type=' + grant_type + '&scope=' + scope;
            }
        }
        
    
        public class IqlooResponseWrapper {
            public String access_token;
             public Integer expires_in;
            public String token_type;
           
        }
    
    //Iqloo Single PIN Callout
  
    public static string getIqlooSinglePin(string deviceId ,id recordId){
        
        
        string token ;
        if(!Test.isRunningTest()){
            Shield_Lock_Audit_Log__c  tokens = [select id,Access_Token__c, name from Shield_Lock_Audit_Log__c where name ='SL-00001' LIMIT 1];
          token = tokens.Access_Token__c;
        }
         
        
        // String token  = BVC_IqlooLockAPIHelper.generateAccessToken();
       //  deviceId = 'SP2X1889b31c';
        system.debug('Token@@@'+ token);
        Integer currentVariance;
        Integer nextVariance;
        
        List<Pickup__c> pickupList = [SELECT Id, variance__c FROM Pickup__c WHERE Id = :recordId LIMIT 1];
        if(!pickupList.isEmpty()){
            for(Pickup__c p : pickupList){
                currentVariance = p.Variance__c != null ? (Integer)p.Variance__c : 5;
                nextVariance = currentVariance > 1 ? currentVariance - 1 : 5;
            }
        }
        
        List<shipment__c>  shiList = [SELECT Id, variance__c FROM shipment__c WHERE Id = :recordId LIMIT 1];
         if(!shiList.isEmpty()){
            for(shipment__c s : shiList){
                currentVariance = s.Variance__c != null ? (Integer)s.Variance__c : 1;
                nextVariance = currentVariance < 5 ? currentVariance + 1 : 1;
            }
        }
        
         string endpointUrl = 'https://api.igloodeveloper.co/igloohome/devices/'+deviceId+'/algopin/onetime';
     
          iqlooSinglePinRequest SingleReq = new iqlooSinglePinRequest(currentVariance);
        
         string requestBody = JSON.serialize(SingleReq);
         system.debug('requestBody@@@' + requestBody);
        
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json, application/xml');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+ token);
            req.setBody(requestBody);
        
            Http http = new Http();
            HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
                iqlooSinglePinResponseWRapper response = (iqlooSinglePinResponseWRapper) JSON.deserialize(res.getBody(), iqlooSinglePinResponseWRapper.class);
                System.debug('single pin Response: ' + response);
                 updateOTP(recordId,response.pin,nextVariance);
                return response.pin;
        }else{
            
                     integration_Log__c intlg = new integration_Log__c();
                      
                      intlg.Status_Code__c =  String.valueOf(res.getStatusCode());
                      intlg.Response_JSON__c = res.getBody();
                      intlg.Error_Reason__c = 'IqlooLock Get Single PIN API error' +  res.getBody() ;
                      intlg.Integration_Server__c = 'IqlooLock';
                        insert intlg;
            
                System.debug('Failed to Get Single PIN: ' + res.getBody());
             //   throw new AuraHandledException('Error fetching Get Single');
            return 'Error fetching Get Single';
        }
    }
    
    public class iqlooSinglePinRequest{
        public integer variance;
        public string startDate ;
        public string accessName ='Escorter';
        
         public iqlooSinglePinRequest(Integer var) {
            this.variance = var;
            system.debug('variance'+ variance);
             
            Datetime now = Datetime.now(); 
            Integer hour = now.hour();
            Date currentDate = now.date();
            
            Datetime rounded = Datetime.newInstance(currentDate, Time.newInstance(hour, 0, 0, 0));
            startDate = rounded.format('yyyy-MM-dd\'T\'HH') + ':00:00+05:30';
            system.debug('startDate@@@'+ startDate);
      }
        
    }
    
    public class iqlooSinglePinResponseWRapper{
        public string pin;
        public string pinId;
    }
    
    //master PIN Callout
    
    Public static string getIqlooMasterPIN(id recordId,string deviceId){
        
        
           string token ;
        if(!Test.isRunningTest()){
            Shield_Lock_Audit_Log__c  tokens = [select id,Access_Token__c, name from Shield_Lock_Audit_Log__c where name ='SL-00001' LIMIT 1];
          token = tokens.Access_Token__c;
        }
       // string token = BVC_IqlooLockAPIHelper.generateAccessToken();
        system.debug('token@@@'+token);
     //  deviceId = 'SP2X1889b31c';
        
        string Endpointurl = 'https://api.igloodeveloper.co/igloohome/devices/'+deviceId+'/masterpin';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpointurl);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer '+token);
        
        Http http = new Http();
        httpResponse res = http.send(req);
        
        if(res.getStatusCode() == 200){
             iqlooMasterResponseWrapper response = (iqlooMasterResponseWrapper) JSON.deserialize(res.getBody(), iqlooMasterResponseWrapper.class);
              updateMasterPIN(recordId,response.pin); 
            return response.pin;
        }else{
            
                     integration_Log__c intlg = new integration_Log__c();
                      
                      intlg.Status_Code__c =  String.valueOf(res.getStatusCode());
                      intlg.Response_JSON__c = res.getBody();
                      intlg.Error_Reason__c = 'IqlooLock Get Master PIN API error' +  res.getBody() ;
                      intlg.Integration_Server__c = 'IqlooLock';
                        insert intlg;
            
                System.debug('Failed to Get Master PIN: ' + res.getBody());
            //    throw new AuraHandledException('Error fetching Get Master PIN');
              return 'Error fetching Get Master PIN';
        }
    
    }
    
    public class iqlooMasterResponseWrapper{
        public string pin;
    }
    
    @InvocableMethod
    public static void callIqlooSinglePinMethod(List<id> recordID){
        
        List<Shipment__c>  shipList =[select id,Tracking_Status__c , LOCK_ID__c,OTP__c from Shipment__c where id IN:recordID LIMIT 1];
        for(Shipment__c s : shipList){
            if(s.Tracking_Status__c =='Out for Delivery' && s.LOCK_ID__c != Null){
                 System.enqueueJob(new BVC_IqlooLockAPIQueueable( s.LOCK_ID__c,s.Id));
                
            }
        }
    }
    
    public static void updateOTP( id recordId, string Pin,integer variance){
        
          List<Pickup__c> pickupList = [select id,OTP__c,variance__c from Pickup__c where id =:recordId];
                if(!pickupList.isEmpty()){
                        Pickup__c p = new Pickup__c();
                        p.id = recordId;
                        p.OTP__c = Pin;
                        p.variance__c = variance;
                
                     update p; 
                }
        
        List<Shipment__c> shipList = [select id ,OTP__c,variance__c from Shipment__c where id=:recordId];
        
            if(!shipList.isEmpty()){
                Shipment__c s = new Shipment__c();
                s.Id = recordId;
                s.OTP__c = pin;
                s.variance__c = variance;
                update s;
            }
        }
    public static void updateMasterPIN(id recordId, string Pin){
        
         List<Pickup__c> pickupList = [select id,OTP__c,IqlooMasterPIN__c from Pickup__c where id =:recordId];
                if(!pickupList.isEmpty()){
                        Pickup__c p = new Pickup__c();
                        p.id = recordId;
                        p.IqlooMasterPIN__c = Pin;
                
                     update p; 
                }
        
        List<Shipment__c> shipList = [select id ,OTP__c,IqlooMasterPIN__c from Shipment__c where id=:recordId];
        
                if(!shipList.isEmpty()){
                    Shipment__c s = new Shipment__c();
                    s.Id = recordId;
                    s.IqlooMasterPIN__c = pin;
                    
                    update s;
                }
    } 
        
  }