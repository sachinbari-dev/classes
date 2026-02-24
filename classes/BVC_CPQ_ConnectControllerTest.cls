@isTest
public class BVC_CPQ_ConnectControllerTest {

    @isTest
    static void testmethod1(){
            Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
        
         Account acc = new Account(Name = 'Cosnginee cust',
                                         PAN_Number_of_Entity__c = 'YYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId()
                                         );
        insert acc;
       
        
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
       
        
        insert pin;
        
          Entity__c  en = new Entity__c();
         en.Name = 'BVCL Maharashtra';
         en.Corporate_Office_Address_Line_1__c = 'testadd';
         en.Corporate_Office_Address_Line_2__c = 'tesdadd';
         en.Website__c = 'www.google.com';
      
        insert en;
        
        
         Hub__c branch = new Hub__c();
        branch.Name = 'Mumbai-SCP';
        branch.BVC_Entity__c = en.id;
       
        branch.Hub_Pincode__c = pin.id;
        
        insert branch;
        
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress unit no9, mumbai dadar';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Ac.Name;
        TestAdd.Customer__c = Ac.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.ADDRESS2__c = 'testadd';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        TestAdd.GST_Registered_Status__c = 'Registered';
        TestAdd.Dealer_Type__c = 'Regular ';
        TestAdd.GSTIN__c ='37GYA623HA721ZZ';
        
        Insert TestAdd;
        
         AddressBook__c TestAdd1 = New AddressBook__c();
        TestAdd1.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd1.Name = 'Desttestaddressu unit no9, mumbai dadar';
        TestAdd1.TRADE_NAME__c = Acc.Name;
        TestAdd1.Customer__c = Acc.id;
        TestAdd1.Source__c = 'Manual';
        TestAdd1.Your_Address_Identifier__c = 'billing';
        TestAdd1.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd1.ADDRESS1__c = 'ABC Street';
        TestAdd1.ADDRESS2__c = 'testadd';
        TestAdd1.CITY__c = 'Test City';
        TestAdd1.STATE__c = 'Test State';
        TestAdd1.COUNTRY__c = 'Test Country';
        TestAdd1.Active_Pincode__c = pin.Id ;
        TestAdd1.GST_Registered_Status__c = 'Registered';
        TestAdd1.Dealer_Type__c = 'Regular ';
        TestAdd1.GSTIN__c ='37YYA623HA721ZZ';
        
        Insert TestAdd1;
     
       
       BVC_LegalEntity__c legEntity = new BVC_LegalEntity__c();
        legEntity.Name = 'BVC Logistcis.pvt.ltd';
        legEntity.Billing_Authorised_Signatory__c = 'testADmin';
        legEntity.Billing_Authorised_Signatory_Designation__c = 'Admin';
        legEntity.Status__c = 'Active';
        legEntity.GSTIN_Principle_Business_Address_Line_1__c = 'testadd';
        legEntity.GSTIN_Principle_Business_Address_Line_2__c = 'testadd2';
        legEntity.GSTIN__c = '27AABCB7286R1ZV';
        legEntity.Billing_Serial_Number__c = 888;
        legEntity.Billling_Entity_PAN_No__c = 'AAICG6169P6';
        legEntity.GSTIN_TYPE__c = 'Normal';
        legEntity.LUT_Number__c = '565767gn';
        legEntity.GSTIN_State__c = 'Maharashtra';
        legEntity.BVC_Entity__c = en.id;
        insert legEntity;
               
        BVCQuote__c  bq = new BVCQuote__c();
        bq.Account__c = ac.id;
        bq.Business_Type__c = 'ACR';
        bq.Status__c = 'Quote Sent';
        //bq.BVC_Price_Slab__c= 'Package 1 : 1L';
        bq.Type__c = 'Quote';
        bq.Ordered__c = true;
        
        insert bq;
        
        BVCOrder__c bo = new BVCOrder__c();
         bo.BVCQuote__c = bq.id;
         bo.Status__c = 'Activated';
         bo.BVC_LegalEntity__c = legEntity.Id;
         bo.BVC_Entity__c = en.Id;
         bo.BVC_Branch__c =  branch.Id;
         bo.Account__c = Ac.id;
          insert bo;
        
         BVC_Invoice_Run__c  invRun = new BVC_Invoice_Run__c();
            invRun.Customer__c = ac.id;
            
          insert invRun;
        
         List<BVCInvoice__C> invoices = new List<BVCInvoice__C>();
        List<id> invIds = new List<id>();
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
      //  inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented for billing removal
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.Status__c = 'Draft';
        inv.BVC_Invoice_Run__c = invRun.id;
       
        inv.BVCOrder__c = bo.id;
        inv.Destination_Address__c = TestAdd1.id;
        inv.BVC_CB_Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Is_CB_Invoice__c= true;
       
        
        insert inv;
        
         List<id> invIds1 = new List<id>();
         BVCInvoice__C inv1 = new BVCInvoice__C();
        inv1.Invoice_Type__c = 'Bill of Supply Invoice';
        inv1.Destination_Address__c = TestAdd.Id;
        inv1.Billing_Address__c = TestAdd.Id;
      //  inv1.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented for billing removal
        inv1.BVC_Entity__c = branch.BVC_Entity__c;
        inv1.BVC_Branch__c = branch.Id;
        inv1.Invoice_Date__c = system.today();
        inv1.Account__c = ac.id;
        inv1.Status__c = 'Draft';
        inv1.BVC_Invoice_Run__c = invRun.id;
        
        inv1.BVCOrder__c = bo.id;
        inv1.Destination_Address__c = TestAdd1.id;
        inv1.BVC_CB_Invoice_Type__c = 'Bill of Supply Invoice';
        inv1.BVC_CB_Is_CB_Invoice__c= true;
       
        
        insert inv1;
       
        invIds1.add(inv1.id);
        
        
         List<id> invIds2 = new List<id>();
        
         BVCInvoice__C inv2 = new BVCInvoice__C();
        inv2.Invoice_Type__c = 'Commercial Invoice';
        inv2.Destination_Address__c = TestAdd.Id;
        inv2.Billing_Address__c = TestAdd.Id;
//   inv2.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented for billing removal
        inv2.BVC_Entity__c = branch.BVC_Entity__c;
        inv2.BVC_Branch__c = branch.Id;
        inv2.Invoice_Date__c = system.today();
        inv2.Account__c = ac.id;
        inv2.Status__c = 'Draft';
        inv2.BVC_Invoice_Run__c = invRun.id;
        inv2.BVCOrder__c = bo.id;
        inv2.Destination_Address__c = TestAdd1.id;
        inv2.BVC_CB_Invoice_Type__c = 'Commercial Invoice';
        inv2.BVC_CB_Is_CB_Invoice__c= true;
       
        
        insert inv2;
       
        invIds2.add(inv2.id);
        
        Integration_Log__c log = new Integration_Log__c();
                        log.Integration_Server__c = 'Razorpay';
                        log.Status_Code__c ='400';
                        log.Request_JSON__c = 'demo request';
                        log.Response_JSON__c = 'demo response';
                        log.Error_Reason__c = 'address missing';
                        log.BVCInvoice__c = inv.Id;
                        
        insert log;
        
        test.startTest();
        BVC_CPQ_ConnectController.authurl(invIds);
        
       
        Test.stopTest();
    }
    
    
    @isTest
    static void testmethod2(){
            Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
        
         Account acc = new Account(Name = 'Cosnginee cust',
                                         PAN_Number_of_Entity__c = 'YYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId()
                                         );
        insert acc;
       
        
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
       
        
        insert pin;
        
          Entity__c  en = new Entity__c();
         en.Name = 'BVCL Maharashtra';
         en.Corporate_Office_Address_Line_1__c = 'testadd';
         en.Corporate_Office_Address_Line_2__c = 'tesdadd';
         en.Website__c = 'www.google.com';
      
        insert en;
        
        
         Hub__c branch = new Hub__c();
        branch.Name = 'Mumbai-SCP';
        branch.BVC_Entity__c = en.id;
       
        branch.Hub_Pincode__c = pin.id;
        
        insert branch;
        
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress unit no9, mumbai dadar';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Ac.Name;
        TestAdd.Customer__c = Ac.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.ADDRESS2__c = 'testadd';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        TestAdd.GST_Registered_Status__c = 'Registered';
        TestAdd.Dealer_Type__c = 'Regular ';
        TestAdd.GSTIN__c ='37GYA623HA721ZZ';
        
        Insert TestAdd;
        
         AddressBook__c TestAdd1 = New AddressBook__c();
        TestAdd1.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd1.Name = 'Desttestaddressu unit no9, mumbai dadar';
        TestAdd1.TRADE_NAME__c = Acc.Name;
        TestAdd1.Customer__c = Acc.id;
        TestAdd1.Source__c = 'Manual';
        TestAdd1.Your_Address_Identifier__c = 'billing';
        TestAdd1.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd1.ADDRESS1__c = 'ABC Street';
        TestAdd1.ADDRESS2__c = 'testadd';
        TestAdd1.CITY__c = 'Test City';
        TestAdd1.STATE__c = 'Test State';
        TestAdd1.COUNTRY__c = 'Test Country';
        TestAdd1.Active_Pincode__c = pin.Id ;
        TestAdd1.GST_Registered_Status__c = 'Registered';
        TestAdd1.Dealer_Type__c = 'Regular ';
        TestAdd1.GSTIN__c ='37YYA623HA721ZZ';
        
        Insert TestAdd1;
     
       
       BVC_LegalEntity__c legEntity = new BVC_LegalEntity__c();
        legEntity.Name = 'BVC Logistcis.pvt.ltd';
        legEntity.Billing_Authorised_Signatory__c = 'testADmin';
        legEntity.Billing_Authorised_Signatory_Designation__c = 'Admin';
        legEntity.Status__c = 'Active';
        legEntity.GSTIN_Principle_Business_Address_Line_1__c = 'testadd';
        legEntity.GSTIN_Principle_Business_Address_Line_2__c = 'testadd2';
        legEntity.GSTIN__c = '27AABCB7286R1ZV';
        legEntity.Billing_Serial_Number__c = 888;
        legEntity.Billling_Entity_PAN_No__c = 'AAICG6169P6';
        legEntity.GSTIN_TYPE__c = 'Normal';
        legEntity.LUT_Number__c = '565767gn';
        legEntity.GSTIN_State__c = 'Maharashtra';
        legEntity.BVC_Entity__c = en.id;
        insert legEntity;
               
        BVCQuote__c  bq = new BVCQuote__c();
        bq.Account__c = ac.id;
        bq.Business_Type__c = 'ACR';
        bq.Status__c = 'Quote Sent';
        //bq.BVC_Price_Slab__c= 'Package 1 : 1L';
        bq.Type__c = 'Quote';
        bq.Ordered__c = true;
        
        insert bq;
        
        BVCOrder__c bo = new BVCOrder__c();
         bo.BVCQuote__c = bq.id;
         bo.Status__c = 'Activated';
         bo.BVC_LegalEntity__c = legEntity.Id;
         bo.BVC_Entity__c = en.Id;
         bo.BVC_Branch__c =  branch.Id;
         bo.Account__c = Ac.id;
          insert bo;
        
         BVC_Invoice_Run__c  invRun = new BVC_Invoice_Run__c();
            invRun.Customer__c = ac.id;
            
          insert invRun;
        
         List<BVCInvoice__C> invoices = new List<BVCInvoice__C>();
        List<id> invIds = new List<id>();
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
    //    inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented for billing removal
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.Status__c = 'Draft';
        inv.BVC_Invoice_Run__c = invRun.id;
       
        inv.BVCOrder__c = bo.id;
        inv.Destination_Address__c = TestAdd1.id;
        inv.BVC_CB_Invoice_Type__c = 'Tax Invoice';
        inv.BVC_CB_Is_CB_Invoice__c= true;
       
        
        insert inv;
        
         List<id> invIds1 = new List<id>();
         BVCInvoice__C inv1 = new BVCInvoice__C();
        inv1.Invoice_Type__c = 'Bill of Supply Invoice';
        inv1.Destination_Address__c = TestAdd.Id;
        inv1.Billing_Address__c = TestAdd.Id;
        //inv1.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c;  commented for billing removal
        inv1.BVC_Entity__c = branch.BVC_Entity__c;
        inv1.BVC_Branch__c = branch.Id;
        inv1.Invoice_Date__c = system.today();
        inv1.Account__c = ac.id;
        inv1.Status__c = 'Draft';
        inv1.BVC_Invoice_Run__c = invRun.id;
        
        inv1.BVCOrder__c = bo.id;
        inv1.Destination_Address__c = TestAdd1.id;
        inv1.BVC_CB_Invoice_Type__c = 'Bill of Supply Invoice';
        inv1.BVC_CB_Is_CB_Invoice__c= true;
       
        
        insert inv1;
       
        invIds1.add(inv1.id);
        
        
         List<id> invIds2 = new List<id>();
        
         BVCInvoice__C inv2 = new BVCInvoice__C();
        inv2.Invoice_Type__c = 'Commercial Invoice';
        inv2.Destination_Address__c = TestAdd.Id;
        inv2.Billing_Address__c = TestAdd.Id;
   //     inv2.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented for billing removal
        inv2.BVC_Entity__c = branch.BVC_Entity__c;
        inv2.BVC_Branch__c = branch.Id;
        inv2.Invoice_Date__c = system.today();
        inv2.Account__c = ac.id;
        inv2.Status__c = 'Draft';
        inv2.BVC_Invoice_Run__c = invRun.id;
        inv2.BVCOrder__c = bo.id;
        inv2.Destination_Address__c = TestAdd1.id;
        inv2.BVC_CB_Invoice_Type__c = 'Commercial Invoice';
        inv2.BVC_CB_Is_CB_Invoice__c= true;
       
        
        insert inv2;
       
        invIds2.add(inv2.id);
        
        test.startTest();
        
        BVC_CPQ_ConnectController.authurl(invIds1);
       
      
        Test.stopTest();
    }
    @isTest
     static void testmethod3(){
         BVC_CPQ_ConnectController.fakemethod();
         
     }
}