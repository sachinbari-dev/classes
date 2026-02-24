@isTest
public class BVC_CPQ_EYControllerTest {

    @isTest
    static void testmethd1(){
      Test.setMock(HttpCalloutMock.class,new MockHttpTokenGenerator());
        
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
        //bq.Type__c = 'Quote';
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
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
      //  inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c; commented for billing ref.
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
        invLine.Subtotal__c = 3500;
        invLine.Name = 'BVCLN-00223';
        insert invLine;
        
        
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
        
          BVC_CPQ_EYController.bearerTokenGenerator(invoices);
          List<BVCInvoice__c> updatedInvoices = BVC_CPQ_EYController.updateInvoiceFields(responseMap, new List<BVCInvoice__c>{inv});
        
           Integration_Log__c lg = BVC_CPQ_EYController.createIntegrationLog(inv.id,errorMessage,requestJson,responseJson,statusCode);
         BVC_CPQ_EYController.wrapperTestCoverage(jsonTest);

    //    BVC_CPQ_EYController.ChargeHeadCreator(invResponseMap, invoiceIds);
     //   BVC_CPQ_EYController.createCBEYLineItems(inv, i);
     //   BVC_CPQ_EYController.LineItemCreator(invResponseMap, invoiceIds);
     //   BVC_CPQ_EYController.updateInvoiceFields(responseMap, invoices);
       

    }
    
    @IsTest
    public static void testEYIntegration() {
       
        Test.setMock(HttpCalloutMock.class, new BVC_CPQ_EYControllerMock());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/BVCGSTEngine');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        
       
        EY_ResponseJSONParser parser = (EY_ResponseJSONParser) JSON.deserialize(res.getBody(), EY_ResponseJSONParser.class);
        
      
              
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
        //bq.Type__c = 'Quote';
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
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
      //  inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c;commented for billing ref.
        inv.BVC_Entity__c = branch.BVC_Entity__c;
        inv.BVC_Branch__c = branch.Id;
        inv.Invoice_Date__c = system.today();
        inv.Account__c = ac.id;
        inv.Status__c = 'Draft';
        inv.BVC_Invoice_Run__c = invRun.id;
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.BVCOrder__c = bo.id;
        inv.Destination_Address__c = TestAdd1.id;
        inv.BVC_CB_Is_CB_Invoice__c = true;
         inv.Total_Universe_Cost_Charge__c = 324;
        inv.Total_BVC_Valuation_Charges__c = 45;
        inv.Total_Fuel_Surcharge__c = 4654;
        inv.Total_Vaulting_Charges__c = 43534;
       inv.Total_Weight_Charges__c = 546;
        inv.Total_Holiday_Charges__c =643;
        inv.Total_Logistics_Charges__c =634;
        insert inv;
        
        invoices.add(inv); 
               
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
        invLine.Subtotal__c = 3500;
        invLine.Name = 'BVCLN-00223';
        invLine.product_code__c = 'FREIGHT CHARGES';
        insert invLine;
        
         BVCInvoiceLineitem__c invLine1 = new BVCInvoiceLineitem__c ();
        invLine1.BVCInvoice__c  = inv.Id;
        invLine1.Freight_Charges__c = 1000;
        invLine1.Offline_Charge__c = 1000;
        invLine1.Liability_Charges__c = 1000;
        invLine1.BVC_Valuation_Charges__c = 100;
        invLine1.Docket_Charges__c = 100;
        invLine1.Fuel_Charges__c = 100;
        invLine1.Holiday_Charges__c = 100;
        invLine1.Weight_Charges__c = 100;
        invLine1.Subtotal__c = 3500;
        invLine1.Name = 'BVCLN-00224';
        invLine.product_code__c = 'VAULTING CHARGES';
        insert invLine1;
        
         BVCInvoiceLineitem__c invLine2 = new BVCInvoiceLineitem__c ();
        invLine2.BVCInvoice__c  = inv.Id;
        invLine2.Freight_Charges__c = 1000;
        invLine2.Offline_Charge__c = 1000;
        invLine2.Liability_Charges__c = 1000;
        invLine2.BVC_Valuation_Charges__c = 100;
        invLine2.Docket_Charges__c = 100;
        invLine2.Fuel_Charges__c = 100;
        invLine2.Holiday_Charges__c = 100;
        invLine2.Weight_Charges__c = 100;
        invLine2.Subtotal__c = 3500;
        invLine2.Name = 'BVCLN-00225';
        invLine.product_code__c = 'UNIVERSE COST CHARGE';
        insert invLine2;
        
        new List<BVCInvoiceLineitem__c> {invLine, invLine1, invLine2};
            
      
        
        
        List<BVCInvoice__c> invoicesToUpdate = new List<BVCInvoice__c>(); 
          invoicesToUpdate.add(inv);
       
        Map<Id, EY_ResponseJSONParser> responseMap = new Map<Id, EY_ResponseJSONParser>();
        responseMap.put(invoicesToUpdate[0].Id, parser);

         EY_ResponseJSONParser.lineItems lineItemData1 = new EY_ResponseJSONParser.lineItems();
         
         lineItemData1.materialDescription = 'FREIGHT CHARGES';
          lineItemData1.itemNumber = '1';
            lineItemData1.tax = 0;
            lineItemData1.totalItemValue = 295000;
            lineItemData1.natureOfService = 'FREIGHT CHARGES';
            lineItemData1.sacApplicable = '996531';
            lineItemData1.taxApplicablePercentage = 0.18;
            lineItemData1.taxCategory = 'IGST';
            lineItemData1.taxCalculated = 45000;
            lineItemData1.taxCalculatedINR = 45000;
            lineItemData1.igstPercentage = 0.18;
            lineItemData1.cgstPercentage = 0;
            lineItemData1.sgstPercentage = 0;
            lineItemData1.igst = 45000;
            lineItemData1.cgst = 0;
            lineItemData1.sgst = 0;
            lineItemData1.igsT_INR = 45000;
            lineItemData1.cgsT_INR = 0;
            lineItemData1.sgsT_INR = 0;
        
        
         EY_ResponseJSONParser.lineItems lineItemData2 = new EY_ResponseJSONParser.lineItems();
            lineItemData2.materialDescription = 'VAULTING CHARGES'; 
             lineItemData2.itemNumber = '1';
            lineItemData2.tax = 0;
            lineItemData2.totalItemValue = 295000;
            lineItemData2.natureOfService = 'VAULTING CHARGES';
            lineItemData2.sacApplicable = '996531';
            lineItemData2.taxApplicablePercentage = 0.18;
            lineItemData2.taxCategory = 'IGST';
            lineItemData2.taxCalculated = 45000;
            lineItemData2.taxCalculatedINR = 45000;
            lineItemData2.igstPercentage = 0.18;
            lineItemData2.cgstPercentage = 0;
            lineItemData2.sgstPercentage = 0;
            lineItemData2.igst = 45000;
            lineItemData2.cgst = 0;
            lineItemData2.sgst = 0;
            lineItemData2.igsT_INR = 45000;
            lineItemData2.cgsT_INR = 0;
            lineItemData2.sgsT_INR = 0;
        
        EY_ResponseJSONParser.lineItems lineItemData3 = new EY_ResponseJSONParser.lineItems();
             lineItemData3.materialDescription = 'UNIVERSE COST CHARGE';
             lineItemData3.itemNumber = '1';
            lineItemData3.tax = 0;
            lineItemData3.totalItemValue = 295000;
            lineItemData3.natureOfService = 'UNIVERSE COST CHARGE';
            lineItemData3.sacApplicable = '996531';
            lineItemData3.taxApplicablePercentage = 0.18;
            lineItemData3.taxCategory = 'IGST';
            lineItemData3.taxCalculated = 45000;
            lineItemData3.taxCalculatedINR = 45000;
            lineItemData3.igstPercentage = 0.18;
            lineItemData3.cgstPercentage = 0;
            lineItemData3.sgstPercentage = 0;
            lineItemData3.igst = 45000;
            lineItemData3.cgst = 0;
            lineItemData3.sgst = 0;
            lineItemData3.igsT_INR = 45000;
            lineItemData3.cgsT_INR = 0;
            lineItemData3.sgsT_INR = 0;
        
         BVC_Charge_Head_Tax__c chTax = new BVC_Charge_Head_Tax__c();
               
               chTax.Name = 'CH-001';
               chTax.BVCInvoice__c = inv.id;
               chTax.CGST_Amount__c =768;
               chTax.IGST__c=4364;
               chTax.CGST_Rate__c = 12;
               chTax.IGST__c = 324;
               chTax.IGST_Amount__c = 312;
               chTax.SGST__c = 453;
               chTax.SGST_Amount__c = 56;
               chTax.Total_Amount__c = 4656;
            
               chTax.Tax_Amount__c = 657;
               chTax.Tax_Percent__c = 32;
               chTax.Taxable_Value__c =432;
              
        insert chTax;
        
         BVC_Charge_Head_Tax__c chTax1 = new BVC_Charge_Head_Tax__c();
               
               chTax1.Name = 'CH-002';
               chTax1.BVCInvoice__c = inv.id;
               chTax1.CGST_Amount__c =768;
               chTax1.IGST__c=4364;
               chTax1.CGST_Rate__c = 12;
               chTax1.IGST__c = 324;
               chTax1.IGST_Amount__c = 312;
               chTax1.SGST__c = 453;
               chTax1.SGST_Amount__c = 56;
               chTax1.Total_Amount__c = 4656;
              
               chTax1.Tax_Amount__c = 657;
               chTax1.Tax_Percent__c = 32;
               chTax1.Taxable_Value__c =432;
              
        insert chTax1;
        
         BVC_Charge_Head_Tax__c chTax2 = new BVC_Charge_Head_Tax__c();
               
               chTax2.Name = 'CH-003';
               chTax2.BVCInvoice__c = inv.id;
               chTax2.CGST_Amount__c =768;
               chTax2.IGST__c=4364;
               chTax2.CGST_Rate__c = 12;
               chTax2.IGST__c = 324;
               chTax2.IGST_Amount__c = 312;
               chTax2.SGST__c = 453;
               chTax2.SGST_Amount__c = 56;
               chTax2.Total_Amount__c = 4656;
              
               chTax2.Tax_Amount__c = 657;
               chTax2.Tax_Percent__c = 32;
               chTax2.Taxable_Value__c =432;
              
        insert chTax2;
        
        new List<BVC_Charge_Head_Tax__c> {chTax, chTax1, chTax2};
            
            
             List<EY_RequestJSONParser.lineItems> lineItemsList = new List<EY_RequestJSONParser.lineItems>();
        Integer i = 0;
        
        if (inv.Total_Freight_Charges__c != null && inv.Total_Freight_Charges__c > 0) {
            EY_RequestJSONParser.lineItems item1 = new EY_RequestJSONParser.lineItems();
            EY_Master_Data__mdt mc1 = EY_Master_Data__mdt.getInstance('Freight_Charges');
            item1.uom = 'OTH-OTHERS';
            i++;
            item1.itemNumber = String.valueOf(i);
            item1.itemQuantity = 1;
            item1.unitPrice = inv.Total_Freight_Charges__c;
            item1.itemNetValue = inv.Total_Freight_Charges__c;
            item1.materialChargeCode = mc1.Charge_Code__c;
            lineItemsList.add(item1);
        }
       
        if (inv.Total_Fuel_Surcharge__c != null && inv.Total_Fuel_Surcharge__c > 0) {
            EY_RequestJSONParser.lineItems item1 = new EY_RequestJSONParser.lineItems();
            EY_Master_Data__mdt mc1 = EY_Master_Data__mdt.getInstance('Fuel_Surcharge');
            item1.uom = 'OTH-OTHERS';
            i++;
            item1.itemNumber = String.valueOf(i);
            item1.itemQuantity = 1;
            item1.unitPrice = inv.Total_Fuel_Surcharge__c;
            item1.itemNetValue = inv.Total_Fuel_Surcharge__c;
            item1.materialChargeCode = mc1.Charge_Code__c;
            lineItemsList.add(item1);
        }

        EY_RequestJSONParser.lineItems firstItem = lineItemsList[0];
        
         Map<Id, List<EY_ResponseJSONParser.lineItems>> invResponseMap = new Map<Id, List<EY_ResponseJSONParser.lineItems>>();
        invResponseMap.put(inv.Id, new List<EY_ResponseJSONParser.lineItems> {lineItemData1, lineItemData2, lineItemData3});
        
         EY_ResponseJSONParser jsonTest = new EY_ResponseJSONParser();
        
        string errorMessage = 'error code 400';
        string requestJson = 'request';
        string responseJson = 'resposne';
        string statusCode = '400';
       
        List<Id> invoiceIds = new List<Id> { inv.Id };
        List<BVCInvoiceLineitem__c> lineItemsToUpdate = BVC_CPQ_EYController.LineItemCreator(invResponseMap, invoiceIds);
        List<BVC_Charge_Head_Tax__c> createcrgHead = BVC_CPQ_EYController.ChargeHeadCreator(invResponseMap, invoiceIds);
        Integration_Log__c lg = BVC_CPQ_EYController.createIntegrationLog(inv.id,errorMessage,requestJson,responseJson,statusCode);
         BVC_CPQ_EYController.wrapperTestCoverage(jsonTest);
            
        List<BVCInvoice__c> updatedInvoices = BVC_CPQ_EYController.updateInvoiceFields(responseMap, invoicesToUpdate);
           BVC_CPQ_EYController.Method2(); 
        System.assertEquals('Success', updatedInvoices[0].EY_Tax_Calculation_Status__c);
    }
    
       @isTest
    static void testmethd2(){
        Test.setMock(HttpCalloutMock.class,new MockHttpTokenGenerator());
        Test.setMock(HttpCalloutMock.class,new BVC_CPQ_EYControllerMock());
        
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
        //bq.Type__c = 'Quote';
        bq.Ordered__c = true;
        
        insert bq;
        
        BVCOrder__c bo = new BVCOrder__c();
         bo.BVCQuote__c = bq.id;
         bo.Status__c = 'Activated';
         bo.BVC_LegalEntity__c = legEntity.Id;
         bo.BVC_Entity__c = en.Id;
         bo.BVC_Branch__c =  branch.Id;
         bo.Account__c = Ac.id;
         bo.Billing_Address__c = TestAdd.id;
          insert bo;
        
         BVC_Invoice_Run__c  invRun = new BVC_Invoice_Run__c();
            invRun.Customer__c = ac.id;
            
          insert invRun;
        
         List<BVCInvoice__C> invoices = new List<BVCInvoice__C>();
        
        BVCInvoice__C inv = new BVCInvoice__C();
        inv.Invoice_Type__c = 'Tax Invoice';
        inv.Destination_Address__c = TestAdd.Id;
        inv.Billing_Address__c = TestAdd.Id;
      //  inv.BVC_LegalEntity__c = branch.ST_BVC_Billing_Entity__c;commented for billing ref.
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
        
        invoices.add(inv); 
        blng_accName = inv.Account__r.name;
        spng_accName = inv.Account__r.name;
        
        Map<String,String> mapResponseCharge = new Map<String,String>{ 'VAULTING CHARGES' => 'Vaulting Charges','FUEL SURCHARGE' => 'Fuel Surcharge','FREIGHT CHARGES' => 'Freight Charge', 'LIABILITY CHARGES'=> 'Liability Charge', 'OFFLINE CHARGES'   => 'Offline Charge','BVC VALUATION CHARGES'   => 'BVC Valuation Charge','DOCKET CHARGES' => 'Docket Charge', 'FUEL CHARGES' => 'Fuel Charge','HOLIDAY CHARGES' => 'Holiday Charge', 'WEIGHT CHARGES' => 'Weight Charge', 'COMMISSION' => 'COMMISSION', 'LOGISTICS CHARGES' => 'LOGISTICS CHARGES', 'SECURE LOGISTICS CHARGES' => 'SECURE LOGISTICS CHARGES',' UNIVERSE COST CHARGES' => ' UNIVERSE COST CHARGE'};
        Integer count = 0;
        
        
        
        List<id>  recId = new List<id>{inv.id};
        
         invRun =[select id from BVC_Invoice_Run__c where id =:invRun.id ];
        invRun.BVCInvoice__c = inv.id;
        update invRun;
       
        
        
        Product2 p = new Product2();
        p.Name ='Valship Metro To Metro (20-25)';
        p.ProductCode = 'VAL-MM-25';
        
        insert p;
        
        
        
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
        invline.Product__c = p.id;
        invLine.Product_Name__c ='Valship Metro To Metro (20-25)';
        insert invLine;
        
        integer i = 0;
         Map<Id,AddressBook__c> invAddressMap = new Map<Id,AddressBook__c>([SELECT Id,ADDRESS1__c,ADDRESS2__c,STATE__c,PINCODE__c,
                                                                          COUNTRY__c,CITY__c,GST_Registered_Status__c,Dealer_Type__c 
                                                                          FROM AddressBook__c 
                                                                          WHERE Id = :Testadd.Id]);
        
        
         
             
           
          BVC_CPQ_EYController.bearerTokenGenerator(invoices);
          BVC_CPQ_EYController.authurl(inv, invAddressMap);
          BVC_CPQ_EYController.createCBEYLineItems(inv, i);
    

    }
}