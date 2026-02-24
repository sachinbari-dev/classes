@isTest
public class SO_AddProductsHelperTest {
    
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
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
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
        TestAdd1.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
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
        
        Purchase_Order__c p = new Purchase_Order__c();
       
        p.Shipping_Partner__c = shippingAcc.id;
        p.Customer_Address__c = TestAdd.id;
        p.Invoice_Amount__c = 43;
        p.Invoice_No__c = '43543';
        p.Invoice_Date__c = system.today();
        p.PO_Status__c = 'Draft';
        insert p;
        
         Sales_order__c s = new Sales_order__c();
            s.Amount__c = 35;
            s.Quantity__c = 4;
            s.Vendor__c = shippingAcc1.id;
            s.Shipping_Partner__c = shippingAcc.id;
            s.Vendor_Address__c = TestAdd.id;
          //  s.Hub__c = newHub.id; 
            
            insert s;
        
          Sales_order__c s1 = new Sales_order__c();
            s1.Amount__c = 35;
            s1.Quantity__c = 6;
            s1.Vendor__c = shippingAcc1.id;
            s1.Shipping_Partner__c = shippingAcc1.id;
            s1.Vendor_Address__c = TestAdd1.id;
           // s1.Hub__c = newHub1.id;
            insert s1;
        
        
         product_Master__c pm = new product_master__c();
             pm.Name = 'Gold Bar - 1 KG';
             pm.Stock_Quantity__c = 50;
             pm.Total_Reserved_Stock__c = 6;
             pm.Available_Stock__c = 44;
             pm.Stock_Price__c = 5000;
             pm.Category__c = 'Gold';
             pm.Customer__c = shippingAcc.id;
            
            
            insert pm;
        
            product_Master__c pm1 = new product_master__c();
             pm1.Name = 'Silver Bar - 1 KG';
             pm1.Stock_Quantity__c = 50;
             pm1.Total_Reserved_Stock__c = 6;
             pm1.Available_Stock__c = 44;
             pm1.Stock_Price__c = 5000;
             pm1.Category__c = 'Silver';
             pm1.Customer__c = shippingAcc1.id;
            
            
            insert pm1;
         
        string productsList = pm1.name;
        
         List<WMS_Products__c> WMSProdList = new List<WMS_Products__c>();
          
        
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
        
         WMS_Products__c wp1 = new WMS_Products__c();
          wp1.Product_Master__c = pm1.id;
          
          wp1.Quantity__c = 25;
          wp1.Price__c = 200;
            wp1.Customer__c = shippingAcc1.id;
            wp1.Shipping_Address__c = TestAdd1.Id;
            wp1.Serial_Number__c ='CAP100';
            wp1.Purchase_Order__c = p.Id;
            wp1.Status__c = 'Available';
          //  wp1.Hub__c = newHub1.id;
        insert wp1;
        
        WMSProdList.add(wp);
        list<id> WMSProd = new list<id>{wp.id};
            
              Exception_Log__c  ex = new Exception_Log__c();
                        ex.Name = 'add WMS product on SO';
                        ex.Exception_Error_Message__c = 'error';
                        ex.Error_Message__c = 'Error while adding WMS Product on SO'; 
                        ex.Apex_Method__c = 'SO_AddProductsHelper.saveProducts';
                        ex.Line_Number__c = 34;
                        ex.Sales_Order__c = s.id;
                        insert ex;
    }

    @isTest
    public static void testmethod1(){
        
        Sales_order__c s = [SELECT Id FROM Sales_order__c LIMIT 1];

        Product_Master__c pm = [SELECT Id, Name FROM Product_Master__c LIMIT 1];

      List<Id> WMSProd = new List<Id>();
        
        for (WMS_Products__c wp : [SELECT Id FROM WMS_Products__c]) {
            WMSProd.add(wp.Id);
        }
            
      
          string prodCat = 'Gold';
         Test.startTest();
            try{
                SO_AddProductsHelper.getProductMasterList(prodCat);
              SO_AddProductsHelper.saveProducts(s.id, WMSProd);
            
             SO_AddProductsHelper.validateSerial('CAP100', pm.id, s.id);
               
                
            }catch(exception e){
                
            }
          
         Test.stopTest();
    }
     @isTest
    public static void testmethod2(){
        Sales_order__c s = [SELECT Id FROM Sales_order__c LIMIT 1];
        Product_Master__c pm = [SELECT Id, Name FROM Product_Master__c LIMIT 1];
        WMS_Products__c wp = [SELECT Id,Status__c,Product_Master__c,Product_Master__r.id FROM WMS_Products__c where Product_Master__r.id=:Pm.id  LIMIT 1];
        
   
        
         Test.startTest();
            try{
                SO_AddProductsHelper.validateSerial('CAP100', pm.id, s.id);
                
                
            }catch(exception e){
                
            }
           
          Test.stopTest();
    }
    @isTest
     public static void testmethod3(){
             Account ac = [select id,name ,PAN_Number_of_Entity__c from Account where PAN_Number_of_Entity__c =:'GMUUY5467H' LIMIT 1];
           Sales_order__c s = [SELECT Id,Shipping_Partner__c,Shipping_Partner__r.id FROM Sales_order__c WHERE Shipping_Partner__r.id=:ac.id LIMIT 1];
        Product_Master__c pm = [SELECT Id, Name,Customer__c,Customer__r.id FROM Product_Master__c where Customer__r.id=:ac.id LIMIT 1];
        WMS_Products__c wp = [SELECT Id,Status__c,Product_Master__c,Product_Master__r.id FROM WMS_Products__c where Product_Master__r.id=:Pm.id  LIMIT 1];
     
         wp.Status__c = 'Reserved';
         update wp;
         
           Test.startTest();
            try{
                SO_AddProductsHelper.validateSerial('CAP100', pm.id, s.id);
                 System.assert(false, 'Exception should have been thrown');
            }catch(exception e){
                System.assertEquals('Script-thrown exception',e.getMessage());
            }
           
          Test.stopTest();
   
     }
        @isTest
     public static void testmethod4(){
         Account ac = [select id,name ,PAN_Number_of_Entity__c from Account where PAN_Number_of_Entity__c =:'GMPPR6789R' LIMIT 1];
         
          Account ac1 = [select id,name ,PAN_Number_of_Entity__c from Account where PAN_Number_of_Entity__c =:'GMUUY5467H' LIMIT 1];
         Sales_order__c s = [SELECT Id,Shipping_Partner__c,Shipping_Partner__r.id FROM Sales_order__c WHERE Shipping_Partner__r.id=:ac.id LIMIT 1];
        Product_Master__c pm = [SELECT Id, Name,Customer__c,Customer__r.id FROM Product_Master__c where Customer__r.id=:ac1.id LIMIT 1];
         
         //  Sales_order__c s = [SELECT Id,Shipping_Partner__c,Shipping_Partner__r.id FROM Sales_order__c WHERE Shipping_Partner__r.id=:ac.id LIMIT 1];
      //  Product_Master__c pm = [SELECT Id, Name,Customer__c,Customer__r.id FROM Product_Master__c where Customer__r.id=:ac.id LIMIT 1];
        WMS_Products__c wp = [SELECT Id,Status__c,Product_Master__c,Product_Master__r.id FROM WMS_Products__c where Product_Master__r.id=:Pm.id  LIMIT 1];
        
      
      
           Test.startTest();
            try{
                SO_AddProductsHelper.validateSerial('CAP100', pm.id, s.id);
                 
            }catch(exception e){
                System.assertEquals('Script-thrown exception',e.getMessage());
            }
           
          Test.stopTest();
   
     }
    
     @isTest
     public static void testmethod5(){
         Account ac = [select id,name ,PAN_Number_of_Entity__c from Account where PAN_Number_of_Entity__c =:'GMPPR6789R' LIMIT 1];
         
          Account ac1 = [select id,name ,PAN_Number_of_Entity__c from Account where PAN_Number_of_Entity__c =:'GMUUY5467H' LIMIT 1];
         Sales_order__c s = [SELECT Id,Shipping_Partner__c,Shipping_Partner__r.id FROM Sales_order__c WHERE Shipping_Partner__r.id=:ac.id LIMIT 1];
        Product_Master__c pm = [SELECT Id, Name,Customer__c,Customer__r.id FROM Product_Master__c where Customer__r.id=:ac1.id LIMIT 1];
         
         //  Sales_order__c s = [SELECT Id,Shipping_Partner__c,Shipping_Partner__r.id FROM Sales_order__c WHERE Shipping_Partner__r.id=:ac.id LIMIT 1];
      //  Product_Master__c pm = [SELECT Id, Name,Customer__c,Customer__r.id FROM Product_Master__c where Customer__r.id=:ac.id LIMIT 1];
        WMS_Products__c wp = [SELECT Id,Status__c,Product_Master__c,Product_Master__r.id FROM WMS_Products__c where Product_Master__r.id=:Pm.id  LIMIT 1];
        
      
      
           Test.startTest();
            try{
                SO_AddProductsHelper.validateSerial('CAP100', pm.id, s.id);
                 
            }catch(exception e){
                System.assertEquals('Script-thrown exception',e.getMessage());
            }
           
          Test.stopTest();
   
     }
   
    
}