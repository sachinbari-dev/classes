public class vistaraFlightScheduleBatchHelper {

    public static string generateToken(){
        // get Airline_API__mdt custom metadata where developer name is 'Vistara_Token_Generation'        
         List<Airline_API__mdt> VistaraAirline = [SELECT ClientUID__c,Client_Key__c,AppID__c,Device_ID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Vistara_Token_Generation'];
       
         // create variables to store the values of metadata.
        
        String Endpoint = '';
        String ClientUID = '';
        String Client_Key = '';
        String AppID = '';
        String Device_ID = '';
        String token = '';
        
         for(Airline_API__mdt vistaraData : VistaraAirline){
            Endpoint = vistaraData.Endpoint__c;
            ClientUID = vistaraData.ClientUID__c;
            Client_Key = vistaraData.Client_Key__c;
            AppID = vistaraData.AppID__c;
            Device_ID = vistaraData.Device_ID__c;
        }
        
         //send Http request to the endpoint get from metadata for token number generation.   
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        system.debug('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"ClientUID":"'+ClientUID+'", "ClientKey":"'+Client_Key+'", "AppID":"'+AppID+'", "DeviceID":"'+Device_ID+'"}');
        HttpResponse response = http.send(request);
  
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug('response body 35 '+response.getBody());
            
           vistaraTokenGenarationWrapper responseWrapper = vistaraTokenGenarationWrapper.parse(response.getBody());
            system.debug(responseWrapper);
            String d = '';
            
           if(String.isNotBlank(responseWrapper.d)){
                d = responseWrapper.d; 
               system.debug('Responsewrapper: ' + d);
            }
            
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug('result#####'+result);
            
            vistaraWrapperTokenClass responseWrap = new vistaraWrapperTokenClass();
             if(String.isNotBlank(result)){
                responseWrap = vistaraWrapperTokenClass.parse(result);
                 system.debug('@@responseWrap :'+ responseWrap);
            } 
             system.debug(responseWrap);
            if(responseWrap != null){
                if(responseWrap.Table != null){
                    token =  responseWrap.Table[0].TokenNumber ;
                    system.debug('token :@@ '+ token);
                }
                
            }else{
                token ='';
            }
        }
        
        return token;
    }
    
    public static string generateSessionId(){
       
        // get Airline_API__mdt custom metadata where  developer name is 'Vistara_Get_User_Details'
        List<Airline_API__mdt> vistaraAirline = [SELECT Username__c,Password__c,Station__c,AppID__c, Endpoint__c FROM Airline_API__mdt
                                                WHERE DeveloperName = 'Vistara_Get_User_Details'];
        
        // create variables to store values of airline custom metadata and stored.
        String Endpoint = '';        
        String Username = '';
        String Password = '';
        String Station = '';
        String AppID = '';
        String session = '';
        String token = vistaraFlightScheduleBatchHelper.generateToken();
        
        for(Airline_API__mdt VistaraData : vistaraAirline){
            Endpoint = VistaraData.Endpoint__c;
            Username = VistaraData.Username__c;
            Password = VistaraData.Password__c;
            Station = VistaraData.Station__c;
            AppID = VistaraData.AppID__c;
        }
        
      // send http post request to the endpoint     
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');       
        system.debug('{"Username":"'+Username+'", "Password":"'+Password+'", "Station":"'+Station+'", "AppID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        
        // Set the body as a JSON object
        request.setBody('{"username":"'+Username+'", "password":"'+Password+'", "station":"'+Station+'", "appID":"'+AppID+'", "TokenNumber":"'+token+'"}');
        HttpResponse response = http.send(request);
        
         if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
            
            vistaraGetSessionIdWrapper responseWrapper = vistaraGetSessionIdWrapper.parse(response.getBody());
            system.debug(responseWrapper);
            
            String d = responseWrapper.d;
            String result = d.subStringBetween('RESULT_START:',':RESULT_END');
            system.debug(result);
            
           vistaraGetSessionIdWrapper1 responseWrap = vistaraGetSessionIdWrapper1.parse(result);
            system.debug(responseWrap);
            session = responseWrap.Table[0].SessionID;
            system.debug('session ' + session);
        }
        return session;
    }
    
    public static List<Flight_Schedule__c> getVistaraFlightList(String originFlightCode,String VistaraAirlineID,String VistaraLoginName,String VistaraAirlineCode,String VistaraEndpoint){
     
        List<Flight_Schedule__c>  flightScheduleList =  new List<Flight_Schedule__c>();
        
     // store session id and token number  
        String token = vistaraFlightScheduleBatchHelper.generateToken();  
        String session = vistaraFlightScheduleBatchHelper.generateSessionId();       
        Date todayDate = system.today()+1;
        String origin = originFlightCode;
        
        Id airportId = Schema.SObjectType.Transport__c.getRecordTypeInfosByDeveloperName().get('Airport').getRecordTypeId();
        Set<String> originSet = new Set<String>();
        Set<String> destinSet = new Set<String>();        
        Map<String,String> shippingAccCodeMap = new Map<String,String>();
        Map<String,String> shippingAgentMap = new Map<String,String>();
        Map<String,String> shippingCityMap = new Map<String,String>();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(VistaraEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-type', 'application/json');
        
        system.debug('{"loginName":"'+VistaraLoginName+'", "airlineCode":"'+VistaraAirlineCode+'", "sessionId":"'+session+'", "origin":"'+origin+'", "dest":"", "fltDate":"'+todayDate+'", "currentStation":"", "flightNo":"", "TokenNumber":"'+token+'"}');
       
        request.setBody('{"loginName":"'+VistaraLoginName+'", "airlineCode":"'+VistaraAirlineCode+'", "sessionId":"'+session+'", "origin":"'+origin+'", "dest":"", "fltDate":"'+todayDate+'","currentStation":"", "flightNo":"", "TokenNumber":"'+token+'"}');
        HttpResponse response = http.send(request);
        system.debug('response@@@@'+response );
        
         if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug(response.getBody());
            
             vistaraGetFlightListWrapper responseWrap = vistaraGetFlightListWrapper.parse(response.getBody());
             system.debug(responseWrap);
            
             string d = responseWrap.d;
             string result = d.subStringBetween('RESULT_START:',':RESULT_END');
             system.debug('result@@:'+result);
            
             string error = 'Schedule Not Available for selected criteria.';
             Boolean checkError =  result.contains(error);
             system.debug('checkError'+checkError);
             if(checkError == false){
            
             vistaraGetFlightListWrapper1 getFlightResp = vistaraGetFlightListWrapper1.parse(result);
             system.debug(getFlightResp);
            
             for(vistaraGetFlightListWrapper1.Table route : getFlightResp.Table){
                       originSet.add(route.FltOrigin);
                       destinSet.add(route.FltDestination);
                    system.debug('route@@@'+ route);
                    system.debug('originSet@@:'+ originSet);
                    system.debug('destinSet@@:'+ destinSet);
                 }
            
              // get Shipper_Consignee_Indigo_AWB__mdt custom metadata  
            for(Shipper_Consignee_Indigo_AWB__mdt shipCon : [SELECT ACCOUNT_CODE__c,ACCOUNT_NAME__c,AGENT_CODE__c,Airport_Code__c,CITY__c,COUNTRY__c,PARTICIPATION_TYPE__c 
                                                             FROM Shipper_Consignee_Indigo_AWB__mdt
                                                            WHERE (Airport_Code__c IN : originSet OR Airport_Code__c IN: destinSet)
                                                            ]){
            if(shipCon.Airport_Code__c != null && shipCon.Airport_Code__c != ''){
                 shippingAccCodeMap.put(shipCon.Airport_Code__c,shipCon.ACCOUNT_CODE__c); 
                 shippingAgentMap.put(shipCon.Airport_Code__c,shipCon.AGENT_CODE__c);                           
                 shippingCityMap.put(shipCon.Airport_Code__c,shipCon.CITY__c);      
             }                                                     
            
        }
                 if(getFlightResp.table.size() > 0){
      // Create flight schedule record from response           
                for(vistaraGetFlightListWrapper1.table flight : getFlightResp.table){
                    
                    Flight_Schedule__c flightSchedule = new Flight_Schedule__c();
                    
                    flightSchedule.Flight_ID__c = flight.ScheduleID;
                    flightSchedule.Name = 'Vistara '+ flight.FltNumber +'-'+ flight.FltOrigin +'-'+flight.FltDestination+'-'+flight.DepDateTime;
                    
                    system.debug('Name of flight '+flightSchedule.Name);
                    system.debug('ID of flight '+flightSchedule.Id);
                    system.debug('Name of flight Number '+flight.FltNumber);
                    
                    flightSchedule.Flight_Number__c = flight.FltNumber;
                    flightSchedule.LegSequence__c = flight.LegSequence;
                    flightSchedule.Actual_Flight_Departure__c = flight.DepDateTime;
                    flightSchedule.Actual_Flight_Arrival__c = flight.ArrDateTime;
                    flightSchedule.Operational_Status__c = flight.STATUS;
                    flightSchedule.Scheduled_Arrival_Time__c = flight.ArrTime;
					flightSchedule.Scheduled_Departure_Time__c = flight.DeptTime;
                    if(flight.FltDate != null){
                        flightSchedule.Departure_Date__c = Date.valueOf(string.valueof(flight.FltDate));
                    }
                   
                    flightSchedule.Origin__c = flight.FltOrigin;
                    flightSchedule.Destination__c = flight.FltDestination;
                    flightSchedule.AirLine1__c = VistaraAirlineID;  
                    
                    if((!shippingAccCodeMap.isEmpty() && shippingAccCodeMap.containsKey(flight.FltOrigin)) && (!shippingAgentMap.isEmpty() && shippingAgentMap.containsKey(flight.FltOrigin)) && (!shippingCityMap.isEmpty() && shippingCityMap.containsKey(flight.FltOrigin))){
                        flightSchedule.Shipping_Account_Code__c = shippingAccCodeMap.get(flight.FltOrigin);
                        flightSchedule.Shipping_Agent_Code__c = shippingAgentMap.get(flight.FltOrigin);
                        flightSchedule.Shipping_City__c = shippingCityMap.get(flight.FltOrigin);
                    }
                    
                    if((!shippingAccCodeMap.isEmpty() && shippingAccCodeMap.containsKey(flight.FltDestination)) && (!shippingCityMap.isEmpty() && shippingCityMap.containsKey(flight.FltDestination))){
                        flightSchedule.Consignee_Account_Code__c = shippingAccCodeMap.get(flight.FltDestination);
                        flightSchedule.Consignee_City__c = shippingCityMap.get(flight.FltDestination);
                    }
                    
                    FlightScheduleList.add(flightSchedule);
                    system.debug('FlightSchedule ==== '+flightSchedule);                                         
                    system.debug('FlightScheduleList ==== '+FlightScheduleList.size());
                }
            }
       }
      }
         return FlightScheduleList;
    }
}