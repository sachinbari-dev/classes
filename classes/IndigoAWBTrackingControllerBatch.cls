global class IndigoAWBTrackingControllerBatch implements Database.Batchable<sobject>,Database.AllowsCallouts{

     private String token;
    private String sessionId;
    
    global Database.querylocator start(Database.BatchableContext bc){
     
        string query ='Select id,Name,AWB_Number__c,Select_Airline__c,AWB_Tracking_Status__c,CreatedDate from Linehaul__c where Select_Airline__c =\'Indigo\' AND CreatedDate = Today AND AWB_Tracking_Status__c NOT IN (\'Delivered Saved\', \'Voided\', \'Return to Shipper\')';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchableContext bc,List<Linehaul__c> lineList){
         token = TMS_LinehaulClass.getIndigoTokenIndigo();
        sessionId = TMS_LinehaulClass.getIndigoSessionIdIndigo(token);
          Map<Id, Linehaul__c> recordsToUpdateMap = new Map<Id, Linehaul__c>();
        
            for (Linehaul__c l : lineList) {
            if (l.AWB_Number__c != null) {
                IndigoAWBTrackingControllerBatchHelper.AWBTrackingWrapper wrapper =
                    IndigoAWBTrackingControllerBatchHelper.getTrackingDetails(l.AWB_Number__c, token, sessionId);
    
                if (wrapper != null && wrapper.Table1 != null) {
                    for (IndigoAWBTrackingControllerBatchHelper.Table1 t1 : wrapper.Table1) {
                        if (String.isNotBlank(t1.Milestone) && l.AWB_Tracking_Status__c != t1.Milestone) {
                            l.AWB_Tracking_Status__c = t1.Milestone;
                           
                            recordsToUpdateMap.put(l.Id, l);
                        }
                    }
                }
            }
        }
    
        if (!recordsToUpdateMap.isEmpty()) {
             update recordsToUpdateMap.values();
        } 
       
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}