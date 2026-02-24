@isTest
public class CreatePurchaseOrderControllerTest {

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
        
    }
    
    @isTest
    public static void testmethod1(){
        
        ContentVersion cv =[SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        
        Purchase_Order__c po = [select id from Purchase_Order__c LIMIT 1];
        
         Id fileId = cv.ContentDocumentId;
        
        List<CreatePurchaseOrderController.InvoiceWrapper> wrappers = new List<CreatePurchaseOrderController.InvoiceWrapper>();
        
         CreatePurchaseOrderController.InvoiceWrapper w = new CreatePurchaseOrderController.InvoiceWrapper();
          
          w.invoiceNo = 'INV1224';
          w.invoiceDate = Date.today();
          w.amount = 5435;
          w.docType = 'Invoice';
          w.fileId = fileId;
        
         wrappers.add(w);
        
          String jsonPayload = JSON.serialize(wrappers);
        
         Test.startTest();

             CreatePurchaseOrderController.createCustomerDocuments(po.Id,jsonPayload);
            CreatePurchaseOrderController.attachKycFile(po.id, fileId);
        Test.stopTest();
    }
}