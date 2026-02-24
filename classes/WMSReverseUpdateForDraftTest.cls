@isTest
public class WMSReverseUpdateForDraftTest {

     @isTest
    public static void testmethod1(){
           Set<id>  salesId = new Set<id>();
        List<id >  salesOrderId = new List<id>();
        
        Sales_order__c s = new Sales_order__c();
        s.Amount__c = 35;
        s.Quantity__c = 4;
        
        insert s;
        
         Sales_order__c s1 = new Sales_order__c();
        s1.Amount__c = 35;
        s1.Quantity__c = 4;
        s1.Sales_Order_Status__c = 'Dispatched';
        s1.Is_Dispatched__c = false;
        
        insert s1;
        
        salesId.add(s.id);
        salesOrderId.add(s.id);
        
        product_Master__c pm = new product_master__c();
         pm.Name = 'Test product';
         pm.Stock_Quantity__c = 50;
          pm.Total_Reserved_Stock__c = 6;
         pm.Available_Stock__c = 44;
         pm.Stock_Price__c = 5000;
        
        insert pm;
        
        WMS_Products__c wp = new WMS_Products__c();
          wp.Product_Master__c = pm.id;
          wp.Sales_Order__c = s.id;
          wp.Quantity__c = 25;
          wp.Price__c = 200;
        
        insert wp;
        
        test.startTest();
           WMSReverseUpdateForDraft.updateProductMaster(salesOrderId);
        test.stopTest();
    }
    
}