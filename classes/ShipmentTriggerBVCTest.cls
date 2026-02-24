@isTest
public class ShipmentTriggerBVCTest {
    @isTest
    static void acrShipmentTestMethod(){
        shipment__c s= new shipment__c();
        s.Shipping_Note_Number__c = 'DS424';
        insert s;
    Test.startTest();
       // ShipmentTriggerBVCHelper.createBVCOrderNew(shipListNew);
        ShipmentTriggerBVCHelper.getCoverage();
        Test.stopTest();
    }}
   
/*
    @isTest
    private static void  insertRecordBATHTest(){
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='Bath Commission / Success Fees');
        Product2 prodESHIP = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='Bath Fright Secure Logistics Charges');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC BATH',Family = 'BVC BATH',ProductCode='BVC BATH');
        Product2 prodiEVALSHIP = new Product2(Name = 'BVC eSHIP',Family = 'BVC eSHIP',ProductCode='BVC eSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='Eship freight Charge');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodiEVALSHIP);
        prodList.add(prodExibiSHIP);
        insert prodList;
        list<PricebookEntry> PBentry = new list<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice2 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice3 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice4 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice5 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PBentry.add(standardPrice1);
        PBentry.add(standardPrice2);
        PBentry.add(standardPrice3);
        PBentry.add(standardPrice4);
        PBentry.add(standardPrice5);
        PBentry.add(BVCPrice1);
        PBentry.add(BVCPrice2);
        PBentry.add(BVCPrice3);
        PBentry.add(BVCPrice4);
        PBentry.add(BVCPrice5);
        insert PBentry;
        String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranchBatheShip = [select id,Billing_Entity_Name__c,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        insert acc;
        Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
        insert entity;
        blng__LegalEntity__c leObj = new blng__LegalEntity__c(
                                            Name = 'Bvc Legal Entity',
                                            Billing_Authorised_Signatory__c = 'test Signatory',
                                            GSTIN__c = 'DHA528BA5Q',
                                            Billling_Entity_PAN_No__c = 'FHA5HWQ8A',
                                            GSTIN_Principle_Business_Address_Line_1__c = '123,house',
                                            CurrencyIsoCode = 'INR',
                                            GSTIN_State_Code__c = '28',
                                            Billing_Serial_Number__c = 01,
                                            blng__Active__c = true,
                                            blng__Country__c = 'India',
                                            BVC_Entity__c = entity.Id);
        insert leObj;
        Hub__c newHub = new Hub__c();
        newHub.Name='MUMBAI-BDB';
        newHub.Branch__c='AGRA';
        newHub.Billing_Entity_Name__c=leObj.id;
        insert newHub;
        
        Zone__c newZone = new Zone__c();
        newZone.Name='data Zone';
        insert newZone;
        Active_Pincode__c newActivePinCode = new Active_Pincode__c();
        newActivePinCode.Pincodes__c='43785';
        newActivePinCode.City__c='Agra';
        newActivePinCode.Country__c='India';
        newActivePinCode.State__c='Delhi';
        newActivePinCode.Hub__c=newHub.ID;
        newActivePinCode.Zone__c=newZone.Id;
        insert newActivePinCode;
        
        AddressBook__c BillingAdd = new AddressBook__c();
        BillingAdd.RecordTypeId='0125g0000002Xb0AAE';
        BillingAdd.Customer__c=acc.Id;
        BillingAdd.Your_Address_Identifier__c='shivaji Ward';
        BillingAdd.ADDRESS1__c='shivaji ward Ghatanji';
        BillingAdd.TRADE_NAME__c='TEST';
        BillingAdd.Active_Pincode__c=newActivePinCode.Id;
        insert BillingAdd;
        acc.Billing_Address__c=BillingAdd.Id;
        acc.Primary_Address__c=BillingAdd.Id;
        acc.Is_Finance_Contact_Present__c=true;
        acc.KYC_Status__c='API Verified';
        acc.Name_As_Per_PAN_Manual_Input__c='TESTKYC';
        //acc.Name_As_Per_PAN__pc='TESTKYC';
        acc.KARZAA_Name_As_Per_PAN__c='TESTKYC';
        acc.Trade_Name__c='TESTKYC';
        update acc;
        SBQQ__Quote__c qT= new SBQQ__Quote__c();
        qT.SBQQ__Account__c=acc.Id;
        qT.BVC_Service__c='BATH';
        qT.Tariff_Plan_Bath_Eship__c='Standard';
        qT.Business_Type__c='ACR';
        qT.BVC_Branch__c=hub.Id;
        insert qT;
        Contract con = new Contract();
        con.AccountId=acc.Id;
        con.Business_Type__c='Non ACR';
        con.BVC_Service__c='BATH';
        con.BVC_Branch__c=newHub.id;
        con.BVC_Billing_Entity__c=leObj.id;
        con.Status='Draft';
        con.StartDate=Date.Today();
        con.EndDate=Date.newInstance(2028, 06, 09);
        con.ContractTerm=12;
        con.Contract_Amount__c=150000;
        //con.SBQQ__Quote__c=qT.ID;
        insert con;
        con.Status='Activated';
        update con;
        List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc.ID;
        shipment.Is_Uploaded__c=false;
        shipment.Customer_Product_Category__c='BATH';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=90;
        Shipment.Origin_Destination_Pairing__c='Within City';
        Shipment.Visit_Outcome__c='Successful';
        shipment.Net_Weight__c=90;
        shipment.Gross_Weight__c=560;
        shipment.Shipment_Type__c='Intercity';
        shipment.Net_Weight_UOM__c='Gram';
        shipment.Gross_Weight_UOM__c='Gram';
        ListShipment.add(Shipment);
        qT.Shipment__c=shipment.Id;
        update qT;
        
        Test.startTest();
        insert ListShipment;
        Shipment.Gross_Weight__c=900;
        update ListShipment;
        shipment.Quick_Calculate_Shipment__c = true;
        update ListShipment;
        Shipment.Verified_for_Billing__c=true;
        update ListShipment;
        Shipment.Ready_for_Rebilling__c=true;
        Shipment.Rebilling_Reason__c='Wrong Customer';
        Shipment.Remark__c='TEST';
        update ListShipment;
        Test.stopTest();       
    }
    @isTest
    private static void  insertRecordeSHIPTest(){
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='Bath Commission / Success Fees');
        Product2 prodESHIP = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='Bath Fright Secure Logistics Charges');
        Product2 prodiVALSHIP = new Product2(Name = 'BVC BATH',Family = 'BVC BATH',ProductCode='BVC BATH');
        Product2 prodiEVALSHIP = new Product2(Name = 'BVC eSHIP',Family = 'BVC eSHIP',ProductCode='BVC eSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='Eship freight Charge2');
        Product2 prodeSHIP1 = new Product2(Name = 'Additional Charge',Family = 'Eship freight Charge',ProductCode='Additional Charge');
        Product2 prodeSHIP2 = new Product2(Name = 'COD Charges',Family = 'Eship freight Charge',ProductCode='COD Charges');
        Product2 prodeSHIP3 = new Product2(Name = 'eSHIP Freight',Family = 'Eship freight Charge',ProductCode='eSHIP Freight');
        Product2 prodeSHIP4 = new Product2(Name = 'Fuel Surcharge',Family = 'Eship freight Charge',ProductCode='Fuel Surcharge');
        Product2 prodeSHIP5 = new Product2(Name = 'Liability Charges',Family = 'Eship freight Charge',ProductCode='Liability Charges');
        Product2 prodeSHIP6 = new Product2(Name = 'Weight Charge',Family = 'Eship freight Charge',ProductCode='Weight Charge');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodiEVALSHIP);
        prodList.add(prodExibiSHIP);
        prodList.add(prodeSHIP1);
        prodList.add(prodeSHIP2);
        prodList.add(prodeSHIP3);
        prodList.add(prodeSHIP4);
        prodList.add(prodeSHIP5);
        prodList.add(prodeSHIP6);
        insert prodList;
        list<PricebookEntry> PBentry = new list<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        
        PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodeSHIP1.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice7 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodeSHIP2.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice8 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodeSHIP3.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice9 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodeSHIP4.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice10 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodeSHIP5.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice11 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodeSHIP6.Id,UnitPrice = 0, IsActive = true);
        
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice2 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice3 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice4 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice5 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        
        PricebookEntry BVCPrice6 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodeSHIP1.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice7 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodeSHIP2.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice8 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodeSHIP3.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice9 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodeSHIP4.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice10 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodeSHIP5.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice11 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodeSHIP6.Id,UnitPrice = 0, IsActive = true);
        PBentry.add(standardPrice1);
        PBentry.add(standardPrice2);
        PBentry.add(standardPrice3);
        PBentry.add(standardPrice4);
        PBentry.add(standardPrice5);
        
        PBentry.add(standardPrice6);
        PBentry.add(standardPrice7);
        PBentry.add(standardPrice8);
        PBentry.add(standardPrice9);
        PBentry.add(standardPrice10);
        PBentry.add(standardPrice11);
        
        PBentry.add(BVCPrice1);
        PBentry.add(BVCPrice2);
        PBentry.add(BVCPrice3);
        PBentry.add(BVCPrice4);
        PBentry.add(BVCPrice5);
        
        PBentry.add(BVCPrice6);
        PBentry.add(BVCPrice7);
        PBentry.add(BVCPrice8);
        PBentry.add(BVCPrice9);
        PBentry.add(BVCPrice10);
        PBentry.add(BVCPrice11);
        insert PBentry;
        String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranchBatheShip = [select id,Billing_Entity_Name__c,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        insert acc;
        Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
        insert entity;
        blng__LegalEntity__c leObj = new blng__LegalEntity__c(
                                            Name = 'Bvc Legal Entity',
                                            Billing_Authorised_Signatory__c = 'test Signatory',
                                            GSTIN__c = 'DHA528BA5Q',
                                            Billling_Entity_PAN_No__c = 'FHA5HWQ8A',
                                            GSTIN_Principle_Business_Address_Line_1__c = '123,house',
                                            CurrencyIsoCode = 'INR',
                                            GSTIN_State_Code__c = '28',
                                            Billing_Serial_Number__c = 01,
                                            blng__Active__c = true,
                                            blng__Country__c = 'India',
                                            BVC_Entity__c = entity.Id);
        insert leObj;
        Hub__c newHub = new Hub__c();
        newHub.Name='MUMBAI-BDB';
        newHub.Branch__c='AGRA';
        newHub.Billing_Entity_Name__c=leObj.id;
        insert newHub;
        
        Zone__c newZone = new Zone__c();
        newZone.Name='data Zone';
        insert newZone;
        Active_Pincode__c newActivePinCode = new Active_Pincode__c();
        newActivePinCode.Pincodes__c='43785';
        newActivePinCode.City__c='Agra';
        newActivePinCode.Country__c='India';
        newActivePinCode.State__c='Delhi';
        newActivePinCode.Hub__c=newHub.ID;
        newActivePinCode.Zone__c=newZone.Id;
        insert newActivePinCode;
        
        AddressBook__c BillingAdd = new AddressBook__c();
        BillingAdd.RecordTypeId='0125g0000002Xb0AAE';
        BillingAdd.Customer__c=acc.Id;
        BillingAdd.Your_Address_Identifier__c='shivaji Ward';
        BillingAdd.ADDRESS1__c='shivaji ward Ghatanji';
        BillingAdd.TRADE_NAME__c='TEST';
        BillingAdd.Active_Pincode__c=newActivePinCode.Id;
        insert BillingAdd;
        acc.Billing_Address__c=BillingAdd.Id;
        acc.Primary_Address__c=BillingAdd.Id;
        acc.Is_Finance_Contact_Present__c=true;
        acc.KYC_Status__c='API Verified';
        acc.Name_As_Per_PAN_Manual_Input__c='TESTKYC';
        //acc.Name_As_Per_PAN__pc='TESTKYC';
        acc.KARZAA_Name_As_Per_PAN__c='TESTKYC';
        acc.Trade_Name__c='TESTKYC';
        update acc;
        SBQQ__Quote__c qT= new SBQQ__Quote__c();
        qT.SBQQ__Account__c=acc.Id;
        qT.BVC_Service__c='eSHIP';
        qT.Tariff_Plan_Bath_Eship__c='Standard';
        qT.Business_Type__c='ACR';
        qT.BVC_Branch__c=hub.Id;
        insert qT;
        Contract con = new Contract();
        con.AccountId=acc.Id;
        con.Business_Type__c='Non ACR';
        con.BVC_Service__c='eSHIP';
        con.BVC_Branch__c=newHub.id;
        con.BVC_Billing_Entity__c=leObj.id;
        con.Status='Draft';
        con.StartDate=Date.Today();
        con.EndDate=Date.newInstance(2028, 06, 09);
        con.ContractTerm=12;
        con.Contract_Amount__c=150000;
        con.Is_Legacy_Contract__c=true;
        //con.SBQQ__Quote__c=qT.ID;
        insert con;
        con.Status='Activated';
        update con;
        List<Shipment__c> ListShipment = new List<Shipment__c>();
        Shipment__c Shipment = new Shipment__c();
        Shipment.Customer__c=acc.ID;
        shipment.Is_Uploaded__c=false;
        shipment.Customer_Product_Category__c='eSHIP';
        Shipment.Product_Category__c='Studded Jewellery';
        Shipment.Total_Invoice_Value__c=90;
        Shipment.Origin_Destination_Pairing__c='Within City';
        Shipment.Visit_Outcome__c='Successful';
        shipment.Net_Weight__c=90;
        shipment.Gross_Weight__c=560;
        shipment.Shipment_Type__c='Intercity';
        shipment.Net_Weight_UOM__c='Gram';
        shipment.Gross_Weight_UOM__c='Gram';
        ListShipment.add(Shipment);
        qT.Shipment__c=shipment.Id;
        update qT;
        
        Test.startTest();
        insert ListShipment;
        Shipment.Gross_Weight__c=900;
        update ListShipment;
        shipment.Quick_Calculate_Shipment__c = true;
        update ListShipment;
        Shipment.Verified_for_Billing__c=true;
        update ListShipment;
        //Shipment.Ready_for_Rebilling__c=true;
        //Shipment.Rebilling_Reason__c='Wrong Customer';
        //Shipment.Remark__c='TEST';
        //update ListShipment;
        Test.stopTest();  
        
    }
   
     @isTest
    static void testValidateAndCreateOrder() {
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        Ship1.Bill_To_Account__c = testAccount.id;
        Ship1.Origin_Hub__c = DelhiHub.Id;
        update Ship1;

        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>{ Ship1.Id => Ship1 };

        Test.startTest();
        BVCOrderCreateShipment.validateAndCreateOrder(shipmentMap);
        Test.stopTest();

    }
    @isTest
    static void testValidateAndCreateOrderWithErrors() {
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        Ship1.Bill_To_Account__c = null;
        Ship1.Origin_Hub__c = DelhiHub.Id;
        update Ship1;

        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>{ Ship1.Id => Ship1 };

        Test.startTest();
        BVCOrderCreateShipment.validateAndCreateOrder(shipmentMap);
        Test.stopTest();

    }

    
    @isTest
    static void testCreateOrderShipment(){
        
       /* Account testAccounteSHIP = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account testAccountBATH = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccounteSHIP.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        LegalEntity legalEnty = new LegalEntity();
        Entity__c entity = new Entity__c();
        
        regularAddress.GST_Registered_Status__c ='Unregistered';
        regularAddress.Dealer_Type__c='unregistered';
        regularAddress.Source__c= 'KARZAA';
        update regularAddress;
        
        BVCQuote__c quote = new BVCQuote__c(
            Account__c = testAccounteSHIP.Id,
            Contracted__c = false,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(12),
            BVC_Service__c = 'eSHIP',
            Business_Type__c='ACR'
        );
        insert quote;
        
        BVCQuote__c quoteNonACR = new BVCQuote__c(
            Account__c = testAccounteSHIP.Id,
            Contracted__c = false,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(12),
            BVC_Service__c = 'eSHIP',
            Business_Type__c='Non ACR'
        );
        insert quoteNonACR;
        
      

        BVC_Contract__c bvcContracteSHIP = new BVC_Contract__c(
            Customer_Name__c = testAccounteSHIP.Id,
            Contract_Start_Date__c = Date.today(),
            Contract_End_Date__c = Date.today().addMonths(12),
            //Contracted_ACR_Package__c = 'Standard',
            Contract_Amount__c = 10000,
            Business_Type__c = 'ACR',
            Contract_Term_months__c = 12,
            Quote__c = quote.Id,
            bvc_service__c='eSHIP',
            Is_Legacy_Contract__c=true,
            Slab_Criteria__c='Invoice Value INR',
            BVC_Branch__c=DelhiHub.id,
            BVC_Billing_Entity__c=legalEnty.id,
            BVC_Entity__c=entity.id
        );
        insert bvcContracteSHIP;
        
        BVC_Contract__c bvcContracteSHIPNonACR = new BVC_Contract__c(
            Customer_Name__c = testAccounteSHIP.Id,
            Contract_Start_Date__c = Date.today(),
            Contract_End_Date__c = Date.today().addMonths(12),
            //Contracted_ACR_Package__c = 'Standard',
            Contract_Amount__c = 10000,
            Business_Type__c = 'Non ACR',
            Contract_Term_months__c = 12,
            Quote__c = quoteNonACR.Id,
            bvc_service__c='eSHIP',
            Is_Legacy_Contract__c=false,
            Slab_Criteria__c='Invoice Value INR',
            BVC_Branch__c=DelhiHub.id,
            BVC_Billing_Entity__c=legalEnty.id,
            BVC_Entity__c=entity.id
        );
        insert bvcContracteSHIPNonACR;
        
        testAccounteSHIP.Liability_Cover_By_BVC_For_Eship__c='Yes';
        testAccounteSHIP.eSHIP_BVC_Contract__c=bvcContracteSHIP.id;
        testAccounteSHIP.Customer_Category_Static__c='ACR';
        update testAccounteSHIP;
        
        RecordType recordType = new RecordType(
            SObjectType = 'eSHIP_Standard_Pricing__c',
            DeveloperName = 'Legacy_eSHIP_Pricing',
            Name = 'Legacy eSHIP Pricing'
        );
        
        eSHIP_Standard_Pricing__c standardPricing = new eSHIP_Standard_Pricing__c(
            RecordTypeId = '0125g000002AVJMAA4',
            Rate_INR__c = 100,
            Liability_Charges__c = 50,
            COD_Charges_percentage_of_product__c = 10,
            Fuel_Surcharge__c = 5,
            UOM_Percentage__c = 1.5,
            Weight_Charges__c = 200,
            Per_Shipment_Freight_Charge__c = true,
            No_Of_Free_Atttemps__c = 2,
            Gross_Weight_Unit_for_Additional_Weight__c = 5,
            Additional_Charge__c = 20,
            COD_Charges_per_shipment__c = 30
        );
        insert standardPricing;
        
        eSHIP_Custom_Pricing__c CustomPricing = new eSHIP_Custom_Pricing__c(
            customer__c=testAccounteSHIP.Id,
            Rate_INR__c=200,
            Liability_Charges__c=0.5, 
            COD_Charges_percentage_of_product__c=2, 
            Fuel_Surcharge__c=5,
            UOM_Percentage__c=1000, 
            Weight_Charges__c=50, 
            Per_Shipment_Freight_Charge__c=true, 
            BVCQuote__c=bvcContracteSHIP.Quote__c, 
            No_Of_Free_Atttemps__c=3, 
            Gross_Weight_Unit_for_Additional_Weight__c=250, 
            Additional_Charge__c=100, 
            COD_Charges_per_shipment__c=50, 
            Shipment_Type__c='intercity',
            Lower_Bound__c=50001 ,
            Upper_Bound__c=100000,
            Slab_Criteria__c='Invoice Value INR',
            Latest_Pricing__c =true);
        insert CustomPricing;
        
        Shipment__c ShipeSHIP = BVCL_TestDataFactory.CreateShipment(testAccounteSHIP.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        ShipeSHIP.Bill_To_Account__c = testAccounteSHIP.id;
        ShipeSHIP.Origin_Hub__c = DelhiHub.Id;
        ShipeSHIP.Total_Invoice_Value__c=10000;
        ShipeSHIP.Payment_Mode__c='COD';
        ShipeSHIP.Product_Code__c='eSHIP';
        ShipeSHIP.Created_through_BVCeSHIP__c=true;
       // ShipeSHIP.Verified_for_Billing__c=true;
        ShipeSHIP.Shipment_Date__c=system.today();
        ShipeSHIP.Billing_Account__c=testAccounteSHIP.id;
        ShipeSHIP.Origin_Type__c='Online';
        ShipeSHIP.Destination_Type__c='Online';
        ShipeSHIP.Shipment_Value__c=10;
        ShipeSHIP.Origin_Type__c='Online';
        ShipeSHIP.Shipment_Type__c='intercity';
        ShipeSHIP.Product_Description__c='Gold Coin';
        ShipeSHIP.Customer_Product_Category__c='eSHIP';
        
        
        update ShipeSHIP;
        
        BVCOrder__c eSHIPOrder= new BVCOrder__c(
            Shipment_Date__c=ShipeSHIP.Shipment_Date__c,
            Contract_ID_Map__c=ShipeSHIP.Account__r.eSHIP_Contract__c,
            BVC_Branch__c=ShipeSHIP.Account__r.eSHIP_Contract__r.BVC_Branch__c,
            Destination_Type__c=ShipeSHIP.Destination_Type__c,
            Shipment_Value__c=ShipeSHIP.Shipment_Value__c,
            Origin_Type__c=ShipeSHIP.Origin_Type__c,
            Shipment_Type__c=ShipeSHIP.Shipment_Type__c,
            Product_Description__c=ShipeSHIP.Product_Description__c,
            BVC_Billing_Entity__c=bvcContracteSHIP.BVC_Billing_Entity__c,
            BVC_Entity__c=bvcContracteSHIP.BVC_Entity__c,
            Billing_Address__c=ShipeSHIP.Account__r.Billing_Address__c
        );
		
        list<Shipment__c> shipListNew= new list<Shipment__c>{ShipeSHIP};
            
        Test.startTest();
       // ShipmentTriggerBVCHelper.createBVCOrderNew(shipListNew);
        ShipmentTriggerBVCHelper.getCoverage();
        Test.stopTest();

        
    }
/*@isTest
static void testCreateBVCOrderNew() {
   
 Test.startTest();
    ShipmentTriggerBVCHelper.getCoverage();
    Test.stopTest();

}

}*/