@isTest
public class CreateSalesOrderControllerTest {

      @TestSetup
    public static void testsetup(){
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Dummy file content')
        );
        insert cv;
        
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
        
        
           Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi ';
        newHub.Branch__c = 'delhi';
        insert newHub;
        
        
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
        
                      
       Sales_order__c s = new Sales_order__c();
            s.Amount__c = 35;
            s.Quantity__c = 4;
            s.Vendor__c = shippingAcc.id;
            s.Shipping_Partner__c = shippingAcc.id;
            s.Vendor_Address__c = TestAdd.id;
          //  s.Hub__c = newHub.id; 
            
            insert s;
    }
    
    @isTest
    public static void testmethod1(){
        
        ContentVersion cv =[SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        
        Sales_order__c po = [select id from Sales_order__c LIMIT 1];
        
         Id fileId = cv.ContentDocumentId;
        
        List<CreateSalesOrderController.InvoiceWrapper> wrappers = new List<CreateSalesOrderController.InvoiceWrapper>();
        
         CreateSalesOrderController.InvoiceWrapper w = new CreateSalesOrderController.InvoiceWrapper();
          
          w.invoiceNo = 'INV1224';
          w.invoiceDate = Date.today();
          w.amount = 5435;
          w.docType = 'Invoice';
          w.fileId = fileId;
        
         wrappers.add(w);
        
          String jsonPayload = JSON.serialize(wrappers);
        
         Test.startTest();

             CreateSalesOrderController.createCustomerDocuments(po.Id,jsonPayload);
            CreateSalesOrderController.attachKycFile(po.id, fileId);
        Test.stopTest();
    }
}