global class vistaraFlightScheduleBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {

     public List<Flight_Schedule__c> FlightScheduleList = new List<Flight_Schedule__c>();   
    
     global Database.QueryLocator Start(Database.BatchableContext bc){
     
        String mtCityCode =  'SELECT Origin__c FROM City_Code__mdt'+(Test.isRunningTest()?' LIMIT 10':'');
        return Database.getQueryLocator(mtCityCode);
     }
    
    global void execute(Database.BatchableContext bc,List<City_Code__mdt> originCode){        
    
         List<Flight_Schedule__c> updateFlight = new List<Flight_Schedule__c>();
         List<Flight_Schedule__c> insertFlight = new List<Flight_Schedule__c>();
        
         system.debug('Origin codes@@:'+ originCode);
        
         string VistaraId = '';         
         string loginName = '';
         String airlineCode = '';
         String endpoint = '';
        
        //get airline record where airline name is 'Vistara'
         List<AirLine1__c> vistaraAirline = [Select id,name,Airline_Name__c from AirLine1__c where Airline_Name__c ='Vistara' Limit 1];
         
        if(!vistaraAirline.isEmpty()){
            VistaraId = vistaraAirline[0].id;
        }
        
        List<Airline_API__mdt> vistaraGetFlightList = [Select Endpoint__c,loginName__c, airLine_Code__c FROM Airline_API__mdt
                                                       WHERE DeveloperName = 'Vistara_Get_Flight_List' LIMIT 1];
        
        if(!vistaraGetFlightList.isEmpty()){
            loginName = vistaraGetFlightList[0].loginName__c;
            airlineCode = vistaraGetFlightList[0].airLine_Code__c;
            endpoint = vistaraGetFlightList[0].Endpoint__c;
        }
        
        string tokenNumber =  vistaraFlightScheduleBatchHelper.generateToken();
        
        system.debug('tokenNumber@@:'+ tokenNumber);
        
        if(tokenNumber != null && tokenNumber != ''){
             string sessionId = vistaraFlightScheduleBatchHelper.generateSessionId();
             system.debug('sessionID@@:'+ sessionId);
             system.debug('loginName@@:'+ loginName);
             system.debug('airlineCode@@:'+ airlinecode);
             system.debug('endpoint@@:'+ endpoint);
            
            if(sessionId != null && sessionId != '' && VistaraId != null && VistaraId != '' && originCode.size() > 0 && (loginName !=null && loginName !='' && airlinecode !=null && airlinecode !='' && endpoint !=null && endpoint !='')){
                for(City_Code__mdt  origincity : originCode){
                 FlightScheduleList.addAll(vistaraFlightScheduleBatchHelper.getVistaraFlightList(origincity.origin__c, VistaraId, loginName, airlinecode, endpoint));
                }
            }
            
            if(!FlightScheduleList.isEmpty() && FlightScheduleList.size() > 0){
                for(Flight_schedule__c getFlight:FlightScheduleList ){
                    if(getflight != null){
                        insertFlight.add(getFlight);
                    }else{
                        updateFlight.add(getFlight);
                    }
                    
                }     
                
                if(updateFlight.size()>0){
                    update updateFlight;
                }
              //  Database.insert(insertFlight);
               if (!insertFlight.isEmpty()) {
                        try {
                            List<Database.SaveResult> insertResults = Database.insert(insertFlight, false);
                            
                            for (Database.SaveResult result : insertResults) {
                                if (!result.isSuccess()) {
                                    for (Database.Error error : result.getErrors()) {
                                        System.debug('Error inserting record: ' + error.getMessage());
                                        System.debug('Fields that caused the error: ' + error.getFields());
                                    //    System.debug('Record that caused the error: ' + insertFlight[result.getIndex()]);
                                    }
                                }
                            }
                            
                            system.debug('List of Flight in Batch for Insertion------ ' + flightScheduleList.size());
                        } catch (Exception ex) {
                            // Log the exception and additional information for troubleshooting
                            system.debug('Error inserting records: ' + ex.getMessage());
                        } 
                    }
                system.debug('List of Flight in Batch for Insertion------ '+flightScheduleList.size());
            }
            
             
        }
       
     }
      global void finish(Database.BatchableContext bc){
        
    }
}