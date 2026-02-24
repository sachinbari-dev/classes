global class EmployeeDataBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    public List<FleetX_People__c> DarwinScheduleList = new List<FleetX_People__c>();   
    
     global Database.QueryLocator Start(Database.BatchableContext bc){
     
       String Query='Select Employee_Code__c,People_email__c,People_lastName__c From FleetX_People__c Limit 1';
        return Database.getQueryLocator(Query);
     }
    
           global void execute(Database.BatchableContext bc,List<FleetX_People__c> Dc){        
    
         
         List<FleetX_People__c> insertPeople = new List<FleetX_People__c>();
        
      
        
         string Keset = '';         
         string Dataset = '';
         String endpoint = '';
        
       
        
        
        List<Darwin_Metadata__mdt> Darwingetpeople = [Select Endpoint__c,datasetKey__c,api_key__c FROM Darwin_Metadata__mdt
                                                       Where DeveloperName = 'DarwinAPIDeatils' LIMIT 1];
        
        if(!Darwingetpeople.isEmpty()){
            Dataset = Darwingetpeople[0].datasetKey__c;
            Keset = Darwingetpeople[0].api_key__c;
            endpoint = Darwingetpeople[0].Endpoint__c;
        }
          
                 DarwinScheduleList.addAll(EmployeeDataScheduleBatchHelper.getDarwinpeople(Keset,Dataset,endpoint));
                
            
            
            if(!DarwinScheduleList.isEmpty() && DarwinScheduleList.size() > 0){
                for(FleetX_People__c getPeople:DarwinScheduleList ){
                    if(getPeople != null){
                        insertPeople.add(getPeople);
                    }
                    
                }     
                
              
              //  Database.insert(insertFlight);
               if (!insertPeople.isEmpty()) {
                        try {
                            List<Database.SaveResult> insertResults = Database.insert(insertPeople, false);
                            
                            for (Database.SaveResult result : insertResults) {
                                if (!result.isSuccess()) {
                                    for (Database.Error error : result.getErrors()) {
                                        System.debug('Error inserting record: ' + error.getMessage());
                                        System.debug('Fields that caused the error: ' + error.getFields());
                                    //    System.debug('Record that caused the error: ' + insertFlight[result.getIndex()]);
                                    }
                                }
                            }
                            
                            system.debug('List of Flight in Batch for Insertion------ ' + DarwinScheduleList.size());
                        } catch (Exception ex) {
                            // Log the exception and additional information for troubleshooting
                            system.debug('Error inserting records: ' + ex.getMessage());
                        } 
                    }
                system.debug('List of Flight in Batch for Insertion------ '+DarwinScheduleList.size());
            }
            
             
        }
       global void finish(Database.BatchableContext bc){
       } 
     }