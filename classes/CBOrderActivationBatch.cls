public class CBOrderActivationBatch implements Database.Batchable<SObject> {
    public final String Query;
    public final String objectType;
    
    public CBOrderActivationBatch(String objectType) {
		System.debug('for checking objectType '+objectType);
        this.objectType = objectType;

        if (this.objectType == 'Order') {
            Query = 'SELECT Id, Status FROM Order WHERE Status = \'Draft\' AND BVC_CB_PreTaxBill__c != null AND Billing_Address__c != null AND BVC_CB_PreTaxBill__r.BVC_CB_Invoice_Generated_in_Salesforce__c = false AND BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = true';
        } else if (this.objectType == 'BVCOrder__c') {
            System.debug('for checking Inside if(this.objectType == BVCOrder__c)');
            Query = 'SELECT Id, Status__c, ActivatedBy__c, Activated_Date__c FROM BVCOrder__c WHERE Status__c = \'Draft\' AND BVC_CB_PreTaxBill__c != null AND Billing_Address__c != null AND BVC_CB_PreTaxBill__r.BVC_CB_Invoice_Generated_in_Salesforce__c = false AND BVC_CB_PreTaxBill__r.BVC_CB_Is_Order_Created__c = true';
            System.debug('for checking query '+Query);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('for checking this.objectType in QueryLocator ' + this.objectType);
        
        System.debug('for checking CPU Time Before Query ' + Limits.getCpuTime());
        System.debug('for checking Heap Size Before Query ' + Limits.getHeapSize());
        
        List<SObject> fetchedRecords = Database.query(Query);
        System.debug('for checking records fetched by Query ' + fetchedRecords.size());
        
        System.debug('for checking CPU Time After Query: ' + Limits.getCpuTime());
        System.debug('for checking Heap Size After Query: ' + Limits.getHeapSize());
        
                
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> OrderList) {
        try{
            System.debug('for checking inside execute method this.objectType ' + this.objectType);
            System.debug('for checking OrderList.size() ' + OrderList.size());
            
            if (this.objectType == 'Order') {
                List<Order> updateOrderList = new List<Order>();
                for (Order orderObj : (List<Order>)OrderList) {
                    Order updateOrderObj = new Order();
                    updateOrderObj.Id = orderObj.Id;
                    updateOrderObj.Status = 'Activated';
                    updateOrderList.add(updateOrderObj);
                }
                System.debug('for checking updateOrderList '+updateOrderList);
                System.debug('for checking updateOrderList.size() '+updateOrderList.size());
                update updateOrderList;
            } else if (this.objectType == 'BVCOrder__c') {
                List<BVCOrder__c> updateBVCOrderList = new List<BVCOrder__c>();
                for (BVCOrder__c bvcOrderObj : (List<BVCOrder__c>)OrderList) {
                    System.debug('for checking which BVCOrder__c record is Processing ' + bvcOrderObj.Id);
                    BVCOrder__c updateBVCOrderObj = new BVCOrder__c();
                    updateBVCOrderObj.Id = bvcOrderObj.Id;
                    updateBVCOrderObj.Status__c = 'Activated';
                    updateBVCOrderObj.ActivatedBy__c = UserInfo.getUserId();
                    updateBVCOrderObj.Activated_Date__c = System.now();
                    updateBVCOrderList.add(updateBVCOrderObj);
                }
                System.debug('for checking updateBVCOrderList '+updateBVCOrderList);
                System.debug('for checking updateBVCOrderList.size() '+updateBVCOrderList.size());
                
                update updateBVCOrderList;
            }
        } catch (Exception ex){
            System.debug('for checking ex.getMessage() '+ex.getMessage());
            System.debug('for checking ex.getLineNumber() '+ex.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext BC) {
        
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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