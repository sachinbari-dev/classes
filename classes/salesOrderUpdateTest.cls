@isTest
public class salesOrderUpdateTest {

    
    
     @testSetup
    public static void setupTestData(){
        
          Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467H';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '9877287843';
        insert shippingAcc;  
        
        Account shippingAcc1 = new Account();
        shippingAcc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        shippingAcc1.Name = 'Test GOLD RETAIL VENTURES LLP - Shipping GMPPR6789R';
        
        shippingAcc1.PAN_Number_of_Entity__c = 'GMPPR6789R';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc1.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc1.First_Name__c = 'new customer';           
        shippingAcc1.Last_Name__c = 'customer account';
        shippingAcc1.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc1.Phone = '9877287843';
        insert shippingAcc1;    
        
                
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi ';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi ', newHub.Name);
        
         Hub__c newHub1 = new Hub__c();
        newHub1.Name = 'SILIGURI ';
        newHub1.Branch__c = 'SILIGURI';
        insert newHub1;
        system.assertEquals('SILIGURI ', newHub1.Name);
        
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Hub__c = newHub.id;
      
        insert pin;
        
           AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = shippingAcc.Name;
        TestAdd.Customer__c = shippingAcc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'Shipping';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
        
          AddressBook__c TestAdd1 = New AddressBook__c();
        TestAdd1.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd1.Name = 'testaddressTEST';
        TestAdd1.GSTIN__c = '';
        TestAdd1.TRADE_NAME__c = shippingAcc1.Name;
        TestAdd1.Customer__c = shippingAcc1.id;
        TestAdd1.Source__c = 'Manual';
        TestAdd1.Your_Address_Identifier__c = 'Shipping';
        TestAdd1.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd1.ADDRESS1__c = 'ABC Street';
        TestAdd1.CITY__c = 'Test City';
        TestAdd1.STATE__c = 'Test State';
        TestAdd1.COUNTRY__c = 'Test Country';
        TestAdd1.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd1;
        
            
         product_Master__c pm = new product_master__c();
             pm.Name = 'Gold Bar - 1 KG';
             pm.Stock_Quantity__c = 50;
             pm.Total_Reserved_Stock__c = 6;
             pm.Available_Stock__c = 44;
             pm.Stock_Price__c = 5000;
             pm.Category__c = 'Gold';
             pm.Customer__c = shippingAcc.id;
        pm.Total_Reserved_Stock__c = 3;
            
            
            insert pm;
        
        Purchase_Order__c p = new Purchase_Order__c();
       
        p.Shipping_Partner__c = shippingAcc.id;
        p.Customer_Address__c = TestAdd.id;
        p.Invoice_Amount__c = 43;
        p.Invoice_No__c = '43543';
        p.Invoice_Date__c = system.today();
        p.PO_Status__c = 'Draft';
        p.Verified_PO__c = false ;
        p.hub__c = newhub.id;
        insert p;
        
         WMS_Products__c wp = new WMS_Products__c();
          wp.Product_Master__c = pm.id;
          
          wp.Quantity__c = 25;
          wp.Price__c = 200;
            wp.Customer__c = shippingAcc.id;
            wp.Shipping_Address__c = TestAdd.Id;
            wp.Serial_Number__c ='CAP100';
            wp.Purchase_Order__c = p.Id;
            wp.Status__c = 'Available';
           // wp.Hub__c = newHub.id;
        insert wp;
        
        contentversion cv = new contentversion();
        cv.Title = 'Test File';
        cv.PathOnClient = 'TestFile.txt';
        cv.FirstPublishLocationId = p.Id;
        cv.VersionData = Blob.valueOf('Test');
        insert cv;
        
            
  
          Sales_order__c s = new Sales_order__c();
            s.Amount__c = 35;
            s.Quantity__c = 4;
            s.Vendor__c = shippingAcc1.id;
            s.Shipping_Partner__c = shippingAcc.id;
            s.Vendor_Address__c = TestAdd.id;
          //  s.Hub__c = newHub.id; 
            
            insert s;
        
    }
    
    @isTest
    public static void testMethod1(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        List<id> salesOrderId =new List<id>{s.id};
        test.startTest();
            salesOrderUpdate.udpateSalesOrder(salesOrderId); 
        test.stopTest();
    }
    
      @isTest
    public static void testMethod3(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateSalesOrderStatus(salesId);
        test.stopTest();
    }
     @isTest
    public static void testMethod4(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateProductMaster(salesId);
        test.stopTest();
    }
    @isTest
    public static void testMethod5(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateWMSProductStatus(salesId);
        test.stopTest();
    }
        @isTest
    public static void testMethod6(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
        List<Sales_Order__c> salesOrderList = new List<Sales_Order__c> {s};
        test.startTest();   
            salesOrderUpdate.updateStockOutDateAndUser(salesOrderList);
        test.stopTest();
    }
       @isTest
    public static void testMethod7(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
        
        s.Sales_Order_Status__c = 'Stock Reserved';
        update s;
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateWMSProductStatus(salesId);
        test.stopTest();
    }
    
    @isTest
    public static void testMethod8(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
         s.Sales_Order_Status__c = 'Stock Reserved';
        update s;
      
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateWMSProductStatus(salesId);
        test.stopTest();
    }
    @isTest
    public static void testMethod9(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
        
        s.Sales_Order_Status__c = 'Delivered';
        update s;
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateWMSProductStatus(salesId);
        test.stopTest();
    }
       @isTest
    public static void testMethod10(){
   
        Sales_order__c s =[select id from Sales_order__c LIMIT 1];
      
        WMS_Products__c wp = [select id from WMS_Products__c LIMIT 1];
        
        wp.Sales_Order__c = s.id;
        update wp;
        
        s.Sales_Order_Status__c = 'Returned';
        s.Returned_Reasons__c ='Delivery Failure';
        
        update s;
        set<id> salesId= new set<id>{s.id};
        test.startTest();   
            salesOrderUpdate.updateWMSProductStatus(salesId);
        test.stopTest();
    }
    
}