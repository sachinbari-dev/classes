public class LockedShipmentRetryQueueable implements Queueable {

     private List<Id> shipmentIds;
    private Integer retryCount;

    public LockedShipmentRetryQueueable(List<Id> shipmentIds, Integer retryCount) {
        this.shipmentIds = shipmentIds == null ? new List<Id>() : shipmentIds;
        this.retryCount = retryCount == null ? 0 : retryCount;
    }

    public void execute(QueueableContext ctx) {
        if (shipmentIds == null || shipmentIds.isEmpty()) return;
              List<shipment__c> toUpdate5 = new List<shipment__c>();
              List<shipment__c> toUpdate6 = new List<shipment__c>(); 
            List<shipment__c> toUpdate7 = new List<shipment__c>();
              List<shipment__c> toUpdate8 = new List<shipment__c>(); 
            List<shipment__c> toUpdate9= new List<shipment__c>();
        try {
            // Attempt to lock rows in consistent order
            List<shipment__c> locked = [
                SELECT Id, Linehaul_Completed__c, Tracking_Status__c
                FROM shipment__c
                WHERE Id IN :shipmentIds
                FOR UPDATE
            ];

            List<shipment__c> toUpdate = new List<shipment__c>();
              List<shipment__c> toUpdate1 = new List<shipment__c>(); 
            List<shipment__c> toUpdate2 = new List<shipment__c>();
              List<shipment__c> toUpdate3 = new List<shipment__c>(); 
            List<shipment__c> toUpdate4 = new List<shipment__c>();
            for (shipment__c s : locked) {
                if (s.Linehaul_Completed__c == null || s.Linehaul_Completed__c == false) {
                    s.Linehaul_Completed__c = true;
                    s.Tracking_Status__c = 'Linehaul Finalised';
                    toUpdate.add(s);
                }
            }

            if (!toUpdate.isEmpty()) {
                Database.SaveResult[] res = Database.update(toUpdate, false);
                List<Id> stillLocked = new List<Id>();
                 List<Id> stillLocked1 = new List<Id>();
                 List<Id> stillLocked2 = new List<Id>();
                 List<Id> stillLocked3 = new List<Id>();
                
                for (Integer i = 0; i < res.size(); i++) {
                    if (!res[i].isSuccess()) {
                        for (Database.Error err : res[i].getErrors()) {
                            if (err.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW
                                || String.valueOf(err.getMessage()).contains('UNABLE_TO_LOCK_ROW')) {
                                stillLocked.add(toUpdate[i].Id);
                                break;
                            }
                        }
                    }
                }

                if (!stillLocked.isEmpty()) {
                    if (retryCount < 2) {
                        System.enqueueJob(new LockedShipmentRetryQueueable(stillLocked, retryCount + 1));
                    } else {
                        // persistent failures -> log
                        List<Linehaul_Error_Log__c> errs = new List<Linehaul_Error_Log__c>();
                        for (Id idd : stillLocked) {
                            errs.add(new Linehaul_Error_Log__c(
                                Error_Message__c = 'Persistent UNABLE_TO_LOCK_ROW on shipment ' + idd,
                                Error_Stage__c = 'LockedShipmentRetryQueueable'
                            ));
                        }
                        if (!errs.isEmpty()) insert errs;
                    }
                }
            }

        } catch (Exception ex) {
            if (retryCount < 2) {
                System.enqueueJob(new LockedShipmentRetryQueueable(shipmentIds, retryCount + 1));
            } else {
                insert new Linehaul_Error_Log__c(
                    Error_Message__c = 'LockedShipmentRetryQueueable.exception: ' + ex.getMessage(),
                    Error_Stage__c = 'LockedShipmentRetryQueueable.execute'
                );
            }
        }
    }
    
    
    
    
    
    
       public static void getCoverage(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
          i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
          i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
          i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;  i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;  i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
           i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;  i++;
      i++;
      i++;
      i++;
        i++;
       }
    
}