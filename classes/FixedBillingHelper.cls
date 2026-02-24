public class FixedBillingHelper {
    //**********************************************************************************************************************************************************
    //This class gets called from a flow- Fixed Billing Invoice Scheduler
    //
    ////**********************************************************************************************************************************************************
    
    @InvocableMethod
   public static void getOrderids(list<String> invoicerunid){
        system.debug('Calling get records of invoice scheduler_____');
       
        list<BVC_Invoice_Run__c> runrecord=[select id,Customer__c,BVCInvoice__c,To__c,From__c,Lock_this_Invoice_Run__c,Total_Invoice_Lines__c from BVC_Invoice_Run__c 
                                            where id=:invoicerunid AND Lock_this_Invoice_Run__c=false];
       
        list<BVCOrder__c> ordersList=[select Id,Product_Code__c,BVC_LegalEntity__c,Billing_Account__c,schedulerKey__c,Billing_Address__c,
                                      (Select Id from BVC_Order_Products__r)
                                      from BVCOrder__c where 
                                      Account__c=:runrecord[0].Customer__c AND 
                                      Shipment_Date__c>=:runrecord[0].From__c AND 
                                      Shipment_Date__c<=:runrecord[0].To__c
                                      AND Billing_status__c='Pending' AND 
                                      fixed_billing_order__c=true AND
                                      BVC_LegalEntity__c!=null AND
                                      BVC_Invoice_Run__c=:runrecord[0].id
                                     ];
        
        system.debug('Order List======'+ordersList);
        Map<Id,BVCOrder__c> nonacrBVCOrderMap=new Map<Id,BVCOrder__c>();
        if(ordersList.size()>0){
        for(BVCOrder__c OP:ordersList){
            nonacrBVCOrderMap.put(OP.id,OP);
            
        }}
        System.debug(nonacrBVCOrderMap.size());
 
		FixedBillingInvoiceBatch bcn = new FixedBillingInvoiceBatch(nonacrBVCOrderMap,runrecord) ; 
        ID batchprocessid = Database.executeBatch(bcn,200);
        }
}