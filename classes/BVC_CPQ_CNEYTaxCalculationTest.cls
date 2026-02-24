@isTest
public class BVC_CPQ_CNEYTaxCalculationTest {

    
    @isTest
    static void testmethd1(){
   /*   Test.setMock(HttpCalloutMock.class,new MockHttpTokenGenerator());
        
        API_Integration_Credential__mdt gstEngine = API_Integration_Credential__mdt.getInstance('EY_GST_Engine');
        
        if(gstEngine.Server_URL__c == 'https://qa.bvcapp.com/api/BVCGSTEngine'){
               Test.setMock(HttpCalloutMock.class,new BVC_CPQ_EYControllerMock());
        }
     
        
       String blng_accName;
       String spng_accName;
        
                 Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
         Account ac1 = new Account(Name = 'ACR1 Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HJ72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac1;
        
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
        
                AddressBook__c TestAdd2 = New AddressBook__c();
        TestAdd2.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd2.Name = ' mumbai dadar';
        TestAdd2.TRADE_NAME__c = ac1.Name;
        TestAdd2.Customer__c = ac1.id;
        TestAdd2.Source__c = 'Manual';
        TestAdd2.Your_Address_Identifier__c = 'billing';
        TestAdd2.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd2.ADDRESS1__c = 'ABC Street';
        TestAdd2.ADDRESS2__c = 'testadd';
        TestAdd2.CITY__c = 'Test City';
        TestAdd2.STATE__c = 'Test State';
        TestAdd2.COUNTRY__c = 'Test Country';
        TestAdd2.Active_Pincode__c = pin.Id ;
        TestAdd2.GST_Registered_Status__c = 'Unregistered';
        TestAdd2.Dealer_Type__c ='unregistered ';
        
        
        Insert TestAdd2;
        
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
     
       
       LegalEntity legEntity = new LegalEntity();
        legEntity.Name = 'BVC Logistcis.pvt.ltd';
        legEntity.Billing_Authorised_Signatory__c = 'testADmin';
        legEntity.Billing_Authorised_Signatory_Designation__c = 'Admin';
        legEntity.Status = 'Active';
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
         bo.BVC_Billing_Entity__c = legEntity.Id;
         bo.BVC_Entity__c = en.Id;
         bo.BVC_Branch__c =  branch.Id;
         bo.Account__c = Ac.id;
          insert bo;
        
         BVC_Invoice_Run__c  invRun = new BVC_Invoice_Run__c();
            invRun.Customer__c = ac.id;
            
          insert invRun;
        
         List<BVCInvoice__C> invoices = new List<BVCInvoice__C>();
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
        inv.Origin_Address__c = TestAdd2.id;
        inv.BVC_Billing_Entity__c = branch.ST_BVC_Billing_Entity__c;
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.Status__c = 'Draft';
        inv.BVC_Invoice_Run__c = invRun.id;
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.BVCOrder__c = bo.id;
        inv.Destination_Address__c = TestAdd1.id;
       
        
        insert inv;
        
        BVCCreditNote__c  bc= new BVCCreditNote__c();
        
        bc.Account__c= Acc.id;
        bc.Address_Book__c = TestAdd.id;
        bc.BVCInvoice__c = inv.id;
        bc.BVC_Branch__c = branch.id;
        bc.BVC_Entity__c = branch.BVC_Entity__c;
        bc.Hub__c = branch.Id;
        bc.Approval_Status__c = 'Approved';
        bc.Credit_Note_Type__c = 'Tax Credit Note';
        bc.Credit_Note_Date__c = system.today();
        bc.Status__c = 'Draft';
        insert bc;
        
        
        invoices.add(inv); 
        blng_accName = inv.Account__r.name;
        spng_accName = inv.Account__r.name;
        
        Map<String,String> mapResponseCharge = new Map<String,String>{ 'VAULTING CHARGES' => 'Vaulting Charges','FUEL SURCHARGE' => 'Fuel Surcharge','FREIGHT CHARGES' => 'Freight Charge', 'LIABILITY CHARGES'=> 'Liability Charge', 'OFFLINE CHARGES'   => 'Offline Charge','BVC VALUATION CHARGES'   => 'BVC Valuation Charge','DOCKET CHARGES' => 'Docket Charge', 'FUEL CHARGES' => 'Fuel Charge','HOLIDAY CHARGES' => 'Holiday Charge', 'WEIGHT CHARGES' => 'Weight Charge', 'COMMISSION' => 'COMMISSION', 'LOGISTICS CHARGES' => 'LOGISTICS CHARGES', 'SECURE LOGISTICS CHARGES' => 'SECURE LOGISTICS CHARGES',' UNIVERSE COST CHARGES' => ' UNIVERSE COST CHARGE'};
        Integer count = 0;
        
        
        
        List<id>  recId = new List<id>{inv.id};
        
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
        invLine.Subtotal__c = 350;
        invLine.Name = 'BVCLN-00223';
        
        insert invLine;
        
        BVCCredit_Note_Line__c  bnl1 = new BVCCredit_Note_Line__c();
        bnl1.BVCCreditNote__c = bc.id;
        bnl1.Type__c = 'Master';
        bnl1.Charge_Head_Type__c = 'Freight Charge';
       
        bnl1.Tax_Percentage_Applied__c = 18;
        bnl1.Subtotal__c = 354;
        bnl1.TaxAmount__c = 35;
        bnl1.Charge_Head_Name__c = 'FREIGHT CHARGE';
        
        insert bnl1;
        
           BVCCredit_Note_Line__c  bnl2 = new BVCCredit_Note_Line__c();
        bnl2.BVCCreditNote__c = bc.id;
        bnl2.Type__c = 'Master';
        bnl2.Charge_Head_Type__c = 'Offline Charge';
       
        bnl2.Tax_Percentage_Applied__c = 18;
        bnl2.Subtotal__c = 354;
        bnl2.TaxAmount__c = 354;
        bnl2.Charge_Head_Name__c = 'Offline Charge';
        
        insert bnl2;
           BVCCredit_Note_Line__c  bnl3 = new BVCCredit_Note_Line__c();
        bnl3.BVCCreditNote__c = bc.id;
        bnl3.Type__c = 'Master';
        bnl3.Charge_Head_Type__c = 'LIABILITY CHARGE';
      
        bnl3.Tax_Percentage_Applied__c = 18;
        bnl3.Subtotal__c = 355;
        bnl3.TaxAmount__c = 334;
        bnl3.Charge_Head_Name__c = 'LIABILITY CHARGE';
        
        insert bnl3;
        
           BVCCredit_Note_Line__c  bnl4 = new BVCCredit_Note_Line__c();
        bnl4.BVCCreditNote__c = bc.id;
        bnl4.Type__c = 'Master';
        bnl4.Charge_Head_Type__c = 'BVC VALUATION CHARGE';
      
        bnl4.Tax_Percentage_Applied__c = 18;
        bnl4.Subtotal__c = 355;
        bnl4.TaxAmount__c = 3564;
        bnl4.Charge_Head_Name__c = 'BVC VALUATION CHARGE';
        
        insert bnl4;
        
         BVCCredit_Note_Line__c  bnl5 = new BVCCredit_Note_Line__c();
        bnl5.BVCCreditNote__c = bc.id;
        bnl5.Type__c = 'Master';
        bnl5.Charge_Head_Type__c = 'Docket Charge';
       
        bnl5.Tax_Percentage_Applied__c = 18;
        bnl5.Subtotal__c = 355;
        bnl5.TaxAmount__c = 3564;
        bnl5.Charge_Head_Name__c = 'Docket Charge';
        
        insert bnl5;
        
         BVCCredit_Note_Line__c  bnl6 = new BVCCredit_Note_Line__c();
        bnl6.BVCCreditNote__c = bc.id;
        bnl6.Type__c = 'Master';
        bnl6.Charge_Head_Type__c = 'Holiday Charge';
      
        bnl6.Tax_Percentage_Applied__c = 18;
        bnl6.Subtotal__c = 355;
        bnl6.TaxAmount__c = 3564;
        bnl6.Charge_Head_Name__c = 'Holiday Chargee';
        
        insert bnl6;

                BVCCredit_Note_Line__c  bnl7 = new BVCCredit_Note_Line__c();
        bnl7.BVCCreditNote__c = bc.id;
        bnl7.Type__c = 'Master';
        bnl7.Charge_Head_Type__c = 'Universe Cost Charge';
     
        bnl7.Tax_Percentage_Applied__c = 18;
        bnl7.Subtotal__c = 355;
        bnl7.TaxAmount__c = 3564;
        bnl7.Charge_Head_Name__c = 'Universe Cost Charge';
        
        insert bnl7;     
        
          BVCCredit_Note_Line__c  bnl8 = new BVCCredit_Note_Line__c();
        bnl8.BVCCreditNote__c = bc.id;
        bnl8.Type__c = 'Master';
        bnl8.Charge_Head_Type__c = 'Fuel Surcharge';
        
        bnl8.Tax_Percentage_Applied__c = 18;
        bnl8.Subtotal__c = 355;
        bnl8.TaxAmount__c = 3564;
        bnl8.Charge_Head_Name__c = 'Fuel Surcharge';
        
        insert bnl8;   
        
         BVCCredit_Note_Line__c  bnl9 = new BVCCredit_Note_Line__c();
        bnl9.BVCCreditNote__c = bc.id;
        bnl9.Type__c = 'Master';
        bnl9.Charge_Head_Type__c = 'Vaulting Charge';
        
        bnl9.Tax_Percentage_Applied__c = 18;
        bnl9.Subtotal__c = 355;
        bnl9.TaxAmount__c = 3564;
        bnl9.Charge_Head_Name__c = 'Vaulting Charge';
        
        insert bnl9;   
        
         Map<Id,AddressBook__c> invAddressMap = new Map<Id,AddressBook__c>([SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,PINCODE__c,
                                                                          COUNTRY__c,CITY__c,GST_Registered_Status__c,Dealer_Type__c 
                                                                          FROM AddressBook__c 
                                                                          WHERE Id = :Testadd.Id]);
        
        
     
        
         Map<Id, EY_ResponseJSONParser> responseMap = new Map<Id, EY_ResponseJSONParser>();
        EY_ResponseJSONParser jsonTest = new EY_ResponseJSONParser();
        
          string errorMessage = 'error code 400';
        string requestJson = 'request';
        string responseJson = 'resposne';
        string statusCode = '400';
       // responseMap.put(inv.Id, parser1);
       
        
        id CnID = bc.id;
        
        
        PageReference pageRef = Page.BVC_creditNoteTaxPage;
        pageRef.getParameters().put('id', CnID);
        Test.setCurrentPage(pageRef);
        
        BVC_CPQ_CNEYTaxCalculation  bcn = new BVC_CPQ_CNEYTaxCalculation();
          bcn.doTaxCalculation();
          BVC_CPQ_CNEYTaxCalculation.doTaxCalculationForCN(cnId);*/
          BVC_CPQ_CNEYTaxCalculation.f1Method();
          
   
       

    }
    
}