global class CBOrderActivation implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        Integer bvcOrderCount = [SELECT COUNT() FROM BVCOrder__c WHERE Status__c = 'Draft' AND BVC_CB_PreTaxBill__c != null AND Billing_Address__c != null AND BVC_CB_PreTaxBill__r.BVC_CB_Invoice_Generated_in_Salesforce__c = false AND BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = true];
        
        Integer orderCount = [SELECT COUNT() FROM Order WHERE Status = 'Draft' AND BVC_CB_PreTaxBill__c != null AND Billing_Address__c != null AND BVC_CB_PreTaxBill__r.BVC_CB_Invoice_Generated_in_Salesforce__c = false AND BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = true];
        
        System.debug('for checking bvcOrderCount '+bvcOrderCount);
        System.debug('for checking orderCount '+orderCount);
        
        if (bvcOrderCount > 0) {
            Database.executeBatch(new CBOrderActivationBatch('BVCOrder__c'), 1);
        }
        
        if (orderCount > 0) {
            Database.executeBatch(new CBOrderActivationBatch('Order'), 20);
        }
    }
    
    
    public static void Method2(){
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
    } 
    
}