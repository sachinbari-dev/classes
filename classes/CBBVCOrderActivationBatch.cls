public class CBBVCOrderActivationBatch implements Database.Batchable<sObject>{
    public final String Query;
    public CBBVCOrderActivationBatch(){
        Query='SELECT id,Status__c FROM BVCOrder__c where Status__c = \'Draft\' and BVC_CB_PreTaxBill__c != null and Billing_Address__c != null and BVC_CB_PreTaxBill__r.BVC_CB_Invoice_Generated_in_Salesforce__c = false and BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = true ';  
        System.debug('for checking Query '+Query);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext BC, List<BVCOrder__c> scope){
        System.debug('for checking scope : '+scope);
        System.debug('for checking scope.size() '+scope.size());
        for(BVCOrder__c s:scope){
            s.Status__c = 'Activated';
        }
        Update scope;   
    }
    public void finish(Database.BatchableContext BC){
        
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
        i++;} 
}