@isTest
public class BVC_EYControllerTest {

      @isTest
    static void manualInvoiceTaxTest1(){
        test.startTest();
        
         Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
        
       
        
        
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
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Ac.Name;
        TestAdd.Customer__c = Ac.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
     
       
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
        bq.BVC_Price_Slab__c= 'New Package 1 : 1L';
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
        
        
        
       
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
       // inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented due to billing removal
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.Status__c = 'Draft';
        inv.BVC_Invoice_Run__c = invRun.id;
       
        
        insert inv;
        
         invRun =[select id from BVC_Invoice_Run__c where id =:invRun.id ];
        invRun.BVCInvoice__c = inv.id;
        update invRun;
       
        
        BVCInvoiceLineitem__c invLine = new BVCInvoiceLineitem__c ();
        invLine.BVCInvoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.Subtotal__c = 3500;
        invLine.Name = 'BVCLN-00223';
        insert invLine;
        
       
       
        
        try{
             BVC_EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(inv.Id),'Inv');
            
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    
  @isTest
    static void manualInvoiceTaxTest2(){
        test.startTest();
        
         Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
        
       
        
        
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
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Ac.Name;
        TestAdd.Customer__c = Ac.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
     
       
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
        bq.BVC_Price_Slab__c= 'New Package 1 : 1L';
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
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
     //   inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented due to billing removal
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.BVC_CB_Is_CB_Invoice__c = false;
        inv.BVC_Invoice_Run__c = invRun.id;
        inv.Status__c = 'Draft';
        
        insert inv;
        
         invRun =[select id from BVC_Invoice_Run__c where id =:invRun.id ];
        invRun.BVCInvoice__c = inv.id;
        update invRun;
       
        
        BVCInvoiceLineitem__c invLine = new BVCInvoiceLineitem__c ();
        invLine.BVCInvoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.Subtotal__c = 3500;
        invLine.Name = 'BVCLN-00223';
        insert invLine;
        
      
       
        
        try{
             BVC_EyManualTaxCalculationClass.invoiceEyIntegration(String.valueOf(invRun.Id),'invRun');
            
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
    
     @isTest
    static void manualInvoiceTaxTest3(){
        test.startTest();
        
         Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
        
       
        
        
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
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Ac.Name;
        TestAdd.Customer__c = Ac.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
     
       
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
        bq.BVC_Price_Slab__c= 'New Package 1 : 1L';
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
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
     //   inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented due to billing removal
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.BVC_CB_Is_CB_Invoice__c = false;
        inv.BVC_Invoice_Run__c = invRun.id;
        inv.Status__c = 'Draft';
        inv.BVC_CB_Is_CB_Invoice__c = false;
        inv.Total_BVC_Valuation_Charges__c =null;
        inv.Total_Docket_Charges__c =null;
        inv.Total_Fuel_Charges__c =null;
        inv.Total_Holiday_Charges__c =null;
        inv.Total_Universe_Cost_Charge__c =null;
        inv.Total_Vaulting_Charges__c =null;
        inv.Total_Weight_Charges__c =null;
     
        insert inv;
        
         invRun =[select id from BVC_Invoice_Run__c where id =:invRun.id ];
        invRun.BVCInvoice__c = inv.id;
        update invRun;
       
        
        BVCInvoiceLineitem__c invLine = new BVCInvoiceLineitem__c ();
        invLine.BVCInvoice__c  = inv.Id;
        invLine.Freight_Charges__c = 1000;
        invLine.Offline_Charge__c = 1000;
        invLine.Liability_Charges__c = 1000;
        invLine.BVC_Valuation_Charges__c = 100;
        invLine.Docket_Charges__c = 100;
        invLine.Fuel_Charges__c = 100;
        invLine.Holiday_Charges__c = 100;
        invLine.Weight_Charges__c = 100;
        invLine.Subtotal__c = 3500;
        invLine.Name = 'BVCLN-00223';
        insert invLine;
        
      
       
        
        try{
            
            BVC_EyManualTaxCalculationClass.f1Method();
        }catch(Exception e){
            System.debug('Exception message----@@@  '+e.getMessage());
        }
        test.stopTest();
    }
}