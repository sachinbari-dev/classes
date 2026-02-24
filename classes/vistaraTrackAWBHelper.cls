public class vistaraTrackAWBHelper {

    public static string generateToken(){
        String token = '';
        String Endpoint = '';
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
        
       List<Airline_API__mdt> vistaraAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Vistara_Token_Generation' LIMIT 1];
        if(!vistaraAirline.isEmpty()){
            Endpoint = vistaraAirline[0].Endpoint__c;
            ClientUID = vistaraAirline[0].ClientUID__c;
            Client_Key = vistaraAirline[0].Client_Key__c;
            AppID =  vistaraAirline[0].AppID__c;
            Device_ID = vistaraAirline[0].Device_ID__c; 
        }
        
        // send http post reuqest to the endpoint fetched  by metadata nd stored in endpoint variable, and send body in the request.  
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        
     // get response of the request and store in response variable    
        HttpResponse response = http.send(request);
        
         if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
         }else{
             system.debug(response.getBody());
            //deserialize response   
                  
            vistaraWrapperclClass responseWrapper = vistaraWrapperclClass.parse(response.getBody());
            system.debug(responseWrapper);
            String d = '';
             
              if(String.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d; 
            }
             
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);

            vistaraWrapperTokenClass1 responseWrap = new vistaraWrapperTokenClass1();
            
            if(String.isNotBlank(result)){
                responseWrap = vistaraWrapperTokenClass1.parse(result);
            }  
              system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
         // assign token number value in token variable mentioned above, take TokenNumber  from IndigoWrapperTokenClass class.
                    token =  responseWrap.Table[0].TokenNumber ;
                }
                
            }else{
                token ='';
            }
         }
        
        return token;
    }
    
      public static List<Linehaul_Tracking__c> trackAWB(List<Linehaul__c> awblist, string token,Map<String,String> awbStatusMap){
          
           List<Linehaul_Tracking__c> insertLinehaulTrack	= new List<Linehaul_Tracking__c>();
        String status = '';
        
        String sessionID = '';
        List<Linehaul__c> updateIndigoLinehaulList = new List<Linehaul__c>();
        
    // check token is not null or empty in linehaul tracking record    
        if(token != null && token != ''){
    // create variables to store values of custom metadata
            String endpointtrack = '';
            String sessiontID = '';
            String loginName = '';
            String awbPrefix = '';
    // get Airline_API__mdt metadata whose developer name is Indigo_Track_AWB 
            List<Airline_API__mdt> vistaraAirlineTrack = [SELECT  Endpoint__c,Session_Id__c,LoginName__c,AWB_Prefix__c FROM Airline_API__mdt
                                                         WHERE DeveloperName = 'Vistara_Get_Tracking_Info' LIMIT 1];
            if(vistaraAirlineTrack[0].Endpoint__c != null && vistaraAirlineTrack[0].Endpoint__c != ''){
     // assigned metadata values in variables 
                endpointtrack = vistaraAirlineTrack[0].Endpoint__c;
                sessiontID = vistaraAirlineTrack[0].Session_Id__c;
                loginName = vistaraAirlineTrack[0].LoginName__c;
                awbPrefix  = vistaraAirlineTrack[0].AWB_Prefix__c;
            }
            
            for(Linehaul__c awbrecord : awblist){
                
                string awbNumber = awbrecord.AWB_Number__c;
                
                 Http  httpt = new Http();
                 HttpRequest requestTrack = new HttpRequest();
                
                 requestTrack.setEndpoint(endpointtrack);
                 requestTrack.setMethod('POST');
                 requestTrack.setHeader('Content-type','application/Json');
                 requestTrack.setBody ('{"loginName":"'+ loginName +'","sessionId":"'+ sessiontID +'", "awbPrefix":"'+ awbPrefix +'","awbNumber":"'+ awbNumber +'","station":"","TokenNumber":"'+ token +'"}');
                 
                 system.debug('{"loginName":"'+ loginName +'","sessionId":"'+ sessiontID +'", "awbPrefix":"'+ awbPrefix +'","awbNumber":"'+ awbNumber +'","station":"","TokenNumber":"'+ token +'"}');
                
                 Http http = new Http();
                 HttpResponse responseTrack = http.send(requestTrack);
                 
                if(responseTrack.getStatusCode() != 200){
                    status = responseTrack.getStatus();
                    system.debug('The status code returned was not expected: ' + responseTrack.getStatusCode() + ' ' + responseTrack.getStatus());
                }else{
                    VistaraTrackAwbWrapperClass1 responseWrapper = VistaraTrackAwbWrapperClass1.parse(responseTrack.getBody());
                    
                    system.debug('responseWrapper@@@@@'+ responseWrapper);
                    string d = '';
                    
                    if(String.isNotBlank(responseWrapper.d)){
                        d = responseWrapper.d;
                    }
                    
                    string result = d.subStringBetween('RESULT_START:',':RESULT_END');
                    system.debug('Result@@@@'+ result);
                    
                     VistaraTrackAwbWrapperClass2 responseWrap1 =  VistaraTrackAwbWrapperClass2.parse(result);
                    if(responseWrap1.Table4.isEmpty()){
                        for(VistaraTrackAwbWrapperClass2.Table7 getAWBstatus : responseWrap1.Table7){
                            for(VistaraTrackAwbWrapperClass2.Table2 getsattus : responseWrap1.Table2 ){
                                
                                    Linehaul_Tracking__c lineTrackrecord = new Linehaul_Tracking__c();
                                    lineTrackrecord.Linehaul_Name__c = awbRecord.Id;
                                    lineTrackrecord.AWB_Number__c = awbRecord.AWB_Number__c;
                                    lineTrackrecord.Linehaul_Type__c = '';    
                                    lineTrackrecord.Airline__c  = 'Vistara';
                                    lineTrackrecord.Status__c = getsattus.Milestone;
                                    lineTrackrecord.Milestone__c = getsattus.Milestone;
                                    lineTrackrecord.Pieces__c = getsattus.Pieces;
                                    lineTrackrecord.Pieces_Weight__c = getsattus.PiecesWeight;
                                    lineTrackrecord.UOM__c = getsattus.UOM;
                                    lineTrackrecord.Flight_Number__c = getsattus.FlightNo;
                                    lineTrackrecord.Flight_Date_Track__c = getsattus.FlightDate;
                                    lineTrackrecord.Station__c = getsattus.Station;
                                    lineTrackRecord.Origin__c = getsattus.Origin;
                                    lineTrackRecord.Destination__c = getsattus.Destination;
                                    lineTrackRecord.Order_By__c = getsattus.OrderBy;
                                    lineTrackRecord.Updated_On__c = getsattus.UpdatedOn;
                                    lineTrackrecord.Last_Activity__c = getAWBstatus.LastActivity;
                                    lineTrackrecord.Description__c = getAWBstatus.Description;
                                    insertLinehaulTrack.add(lineTrackrecord);
                                 
                           
                        } 
                            }
       // create linehaul tracking record from linehaul record 
        
                    }
                    
                }
            }
      }
          return insertLinehaulTrack;
   }
    
      public static List<Linehaul_Tracking__c> updateTrackAWB(List<Linehaul_Tracking__c> awblist, string token,Map<String,String> awbStatusMap){
          
           List<Linehaul_Tracking__c> updateLinehaulTrack	= new List<Linehaul_Tracking__c>();
        String status = '';
        
        String sessionID = '';
        List<Linehaul__c> updateIndigoLinehaulList = new List<Linehaul__c>();
        
    // check token is not null or empty in linehaul tracking record    
        if(token != null && token != ''){
    // create variables to store values of custom metadata
            String endpointtrack = '';
            String sessiontID = '';
            String loginName = '';
            String awbPrefix = '';
    // get Airline_API__mdt metadata whose developer name is Indigo_Track_AWB 
            List<Airline_API__mdt> vistaraAirlineTrack = [SELECT  Endpoint__c,Session_Id__c,LoginName__c,AWB_Prefix__c FROM Airline_API__mdt
                                                         WHERE DeveloperName = 'Vistara_Get_Tracking_Info' LIMIT 1];
            if(vistaraAirlineTrack[0].Endpoint__c != null && vistaraAirlineTrack[0].Endpoint__c != ''){
     // assigned metadata values in variables 
                endpointtrack = vistaraAirlineTrack[0].Endpoint__c;
                sessiontID = vistaraAirlineTrack[0].Session_Id__c;
                loginName = vistaraAirlineTrack[0].LoginName__c;
                awbPrefix  = vistaraAirlineTrack[0].AWB_Prefix__c;
            }
            
            for(Linehaul_Tracking__c awbrecord : awblist){
                
                string awbNumber = awbrecord.AWB_Number__c;
                
                 Http  httpt = new Http();
                 HttpRequest requestTrack = new HttpRequest();
                
                 requestTrack.setEndpoint(endpointtrack);
                 requestTrack.setMethod('POST');
                 requestTrack.setHeader('Content-type','application/Json');
                 requestTrack.setBody ('{"loginName":"'+ loginName +'","sessionId":"'+ sessiontID +'", "awbPrefix":"'+ awbPrefix +'","awbNumber":"'+ awbNumber +'","station":"","TokenNumber":"'+ token +'"}');
                 
                 system.debug('{"loginName":"'+ loginName +'","sessionId":"'+ sessiontID +'", "awbPrefix":"'+ awbPrefix +'","awbNumber":"'+ awbNumber +'","station":"","TokenNumber":"'+ token +'"}');
                
                 Http http = new Http();
                 HttpResponse responseTrack = http.send(requestTrack);
                 
                if(responseTrack.getStatusCode() != 200){
                    status = responseTrack.getStatus();
                    system.debug('The status code returned was not expected: ' + responseTrack.getStatusCode() + ' ' + responseTrack.getStatus());
                }else{
                    VistaraTrackAwbWrapperClass1 responseWrapper = VistaraTrackAwbWrapperClass1.parse(responseTrack.getBody());
                    
                    system.debug('responseWrapper@@@@@'+ responseWrapper);
                    string d = '';
                    
                    if(String.isNotBlank(responseWrapper.d)){
                        d = responseWrapper.d;
                    }
                    
                    string result = d.subStringBetween('RESULT_START:',':RESULT_END');
                    system.debug('Result@@@@'+ result);
                    
                     VistaraTrackAwbWrapperClass2 responseWrap1 =  VistaraTrackAwbWrapperClass2.parse(result);
                    if(responseWrap1.Table4.isEmpty()){
                        for(VistaraTrackAwbWrapperClass2.Table7 getAWBstatus : responseWrap1.Table7){
                            for(VistaraTrackAwbWrapperClass2.Table2 getsattus : responseWrap1.Table2 ){
 
                                awbrecord.AWB_Number__c = awbRecord.AWB_Number__c;
                                awbrecord.Linehaul_Type__c = 'Air';
                                awbrecord.Airline__c  = 'Vistara';
                                awbrecord.Status__c = getsattus.Milestone; 
                                awbrecord.Milestone__c = getsattus.Milestone;
                                awbrecord.Pieces__c = getsattus.Pieces;
                                awbrecord.Pieces_Weight__c = getsattus.PiecesWeight;
                                awbrecord.UOM__c = getsattus.UOM;
                                awbrecord.Flight_Number__c = getsattus.FlightNo;
                                awbrecord.Flight_Date_Track__c = getsattus.FlightDate;
                                awbrecord.Station__c = getsattus.Station;
                                awbrecord.Origin__c = getsattus.Origin;
                                awbrecord.Destination__c = getsattus.Destination;
                                awbrecord.Order_By__c = getsattus.OrderBy;
                                awbrecord.Updated_On__c = getsattus.UpdatedOn;
                                awbrecord.Last_Activity__c = getAWBstatus.LastActivity;
                                awbrecord.Description__c = getAWBstatus.Description;
                                updateLinehaulTrack.add(awbrecord);
                        } 
                            }
       
        
                    }
                    
                }
            }
      }
          return updateLinehaulTrack;
   }
}