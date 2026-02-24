public class FixedBillingDailyTriggerHelper {
    
    public static void FixedBillingShipmentsUpdates(Id fbdId){
        
        List<Shipment__c> shipmentList = [SELECT Id, Fixed_Billing_Daily__c FROM Shipment__c
                                          WHERE Fixed_Billing_Daily__c = :fbdId];
        
        List<Shipment__c> shipListToUpdate = new List<Shipment__c>();
        
        if (!shipmentList.isEmpty()) {
            for (Shipment__c s : shipmentList){
                s.Fixed_Billing_Daily__c = fbdId;
                shipListToUpdate.add(s);
            }
        }
        
        if(!shipListToUpdate.isEmpty()){
            update shipListToUpdate;
        }
        
        
    }

}