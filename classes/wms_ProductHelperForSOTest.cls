@isTest
public class wms_ProductHelperForSOTest {

    @isTest
    public static void testMethod1(){
        
         Sales_order__c s = new Sales_order__c();
            s.Amount__c = 35;
            s.Quantity__c = 4;
        
        insert s;
        
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
        List<WMS_Products__c> WMSProdList = new List<WMS_Products__c>{wp};
            
        test.startTest();
        wms_ProductHelperForSO.multiProductUpdateOnSO(WMSProdList);
        test.stopTest();
    }
}