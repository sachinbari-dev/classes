trigger FixedBillingDailyTrigger on Fixed_Billing_Daily__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('for checking Inside after insert of FixedBillingDailyTrigger');
        /*Set<Id> fbdIds = new Set<Id>();
        for(Fixed_Billing_Daily__c fbd : Trigger.new){
            fbdIds.add(fbd.Id);
        }
        System.debug('for checking fbdIds.size() === '+fbdIds.size());
        
        List<Shipment__c> shipmentList = [SELECT Id, Customer__c, Shipping_Note_Number__c, Shipment_Date__c, Product_Code__c, 
                        Fixed_Billing_Daily__c, Fixed_Billing_Daily__r.Date__c, Fixed_Billing_Daily__r.No_of_Shipments__c,
                        Fixed_Billing_Daily__r.Daily_Revenue__c, Fixed_Billing_Daily__r.Per_Shipment_Revenue__c
                        FROM Shipment__c WHERE Fixed_Billing_Daily__c IN :fbdIds];
        System.debug('for checking shipmentList.size() === '+shipmentList.size());
        
        if(!shipmentList.isEmpty()){
            System.debug('for checking calling FixedBillingOrderQueueable');
            System.enqueueJob(new FixedBillingOrderQueueable(fbdIds));
        }*/
    }
}