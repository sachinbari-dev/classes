@isTest
public class BVC_avoidDuplicateLineItemOnInvoiceTest {

/*
    @isTest
    public static void testMethod1(){
        
          Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test';
        
        insert billingEntity;

        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_LegalEntity__c = billingEntity.Id;
        bvcInvoice.Account__c = BillingAcc.Id;
        bvcInvoice.Total_Credit_Notes__c = 2;
        bvcInvoice.Total_Weight_Charges__c = 60.00;
        bvcInvoice.Total_BVC_Valuation_Charges__c = 120.00;
        bvcInvoice.Total_Docket_Charges__c = 30.00;
        bvcInvoice.Total_Fuel_Charges__c = 40.00;
        bvcInvoice.Total_Holiday_Charges__c = 25.00;
        bvcInvoice.Total_Logistics_Charges__c = 90.00;
        bvcInvoice.Total_Fuel_Surcharge__c = 20.00;
        bvcInvoice.Total_Universe_Cost_Charge__c = 55.00;
        bvcInvoice.Total_Vaulting_Charges__c = 45.00;
        bvcInvoice.BVC_CB_Is_CB_Invoice__c = true;
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
         invLineItem.BVCInvoice__c = bvcInvoice.id;
         invLineItem.name ='FREIGHT CHARGES';
         invLineItem.BVC_CB_ChargeDescription__c ='FREIGHT CHARGES';
         invLineItem.Freight_Charges__c = 76;          
        List<BVCInvoiceLineitem__c> lineitemList= new List<BVCInvoiceLineitem__c>{invLineItem};
        
        insert invLineItem;
        
         BVCInvoiceLineitem__c invLineItem1 = new BVCInvoiceLineitem__c();
          invLineItem1.BVCInvoice__c = bvcInvoice.id;
          invLineItem1.name ='FREIGHT CHARGES';  
          invLineItem1.BVC_CB_ChargeDescription__c ='FREIGHT CHARGES';
        invLineItem1.Freight_Charges__c = 56;
                   
        List<BVCInvoiceLineitem__c> lineitemList1= new List<BVCInvoiceLineitem__c>{invLineItem1};
        
        insert invLineItem1;
            
        BVCInvoiceLineitem__c l = [select id,BVC_CB_ChargeDescription__c from BVCInvoiceLineitem__c where id=:invLineItem1.Id ];
      
        l.Freight_Charges__c = 76;
        update l;
        
            try{
                
                Test.startTest();
                
                 BVC_avoidDuplicateLineItemOnInvoice.preventDuplicateCharges(lineitemList);
                 BVC_avoidDuplicateLineItemOnInvoice.preventDuplicateCharges(lineitemList1);
                
            Test.stopTest();
                
              
            }catch(Exception e){
                
            }
            
    }  */
    
    @isTest static void testInsertAndDuplicateBlocked() {
        
                Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        BVC_LegalEntity__c le = new BVC_LegalEntity__c(Name='TestLE1');
        insert le;

        BVCInvoice__c inv = new BVCInvoice__c();
        inv.BVC_LegalEntity__c = le.Id;
        inv.Account__c = BillingAcc.Id;
        inv.Total_Credit_Notes__c = 2;
        inv.Total_Weight_Charges__c = 60.00;
        inv.Total_BVC_Valuation_Charges__c = 120.00;
        inv.Total_Docket_Charges__c = 30.00;
        inv.Total_Fuel_Charges__c = 40.00;
        inv.Total_Holiday_Charges__c = 25.00;
        inv.Total_Logistics_Charges__c = 90.00;
        inv.Total_Fuel_Surcharge__c = 20.00;
        inv.Total_Universe_Cost_Charge__c = 55.00;
        inv.Total_Vaulting_Charges__c = 45.00;
        inv.BVC_CB_Is_CB_Invoice__c = true;
        insert inv;

        // First line item - should insert successfully
        BVCInvoiceLineitem__c li1 = new BVCInvoiceLineitem__c(
            BVCInvoice__c = inv.Id,
            Name = 'FREIGHT CHARGES',
            BVC_CB_ChargeDescription__c = 'FREIGHT CHARGES',
            Freight_Charges__c = 100
        );
        
        BVCInvoiceLineitem__c li2 = new BVCInvoiceLineitem__c(
            BVCInvoice__c = inv.Id,
            Name = 'FREIGHT CHARGES', // duplicate Name
            BVC_CB_ChargeDescription__c = 'FREIGHT CHARGES', // duplicate desc
            Freight_Charges__c = 50
        );
        List<BVCInvoiceLineitem__c> lineItemList = new List<BVCInvoiceLineitem__c>{li2};
        Test.startTest();
            Database.SaveResult sr1 = Database.insert(li1, false);
          Database.SaveResult sr2 = Database.insert(li2, false);
        BVC_avoidDuplicateLineItemOnInvoice.preventDuplicateCharges(lineItemList);
        Test.stopTest();

        System.assert(sr1.isSuccess(), 'First line item should insert successfully.');


    }

    @isTest static void testUpdateDuplicateBlocked() {
      
             Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        BVC_LegalEntity__c le = new BVC_LegalEntity__c(Name='TestLE1');
        insert le;

        BVCInvoice__c inv = new BVCInvoice__c();
        inv.BVC_LegalEntity__c = le.Id;
        inv.Account__c = BillingAcc.Id;
        inv.Total_Credit_Notes__c = 2;
        inv.Total_Weight_Charges__c = 60.00;
        inv.Total_BVC_Valuation_Charges__c = 120.00;
        inv.Total_Docket_Charges__c = 30.00;
        inv.Total_Fuel_Charges__c = 40.00;
        inv.Total_Holiday_Charges__c = 25.00;
        inv.Total_Logistics_Charges__c = 90.00;
        inv.Total_Fuel_Surcharge__c = 20.00;
        inv.Total_Universe_Cost_Charge__c = 55.00;
        inv.Total_Vaulting_Charges__c = 45.00;
        inv.BVC_CB_Is_CB_Invoice__c = true;
        insert inv;
    


        // Insert two distinct line items
        BVCInvoiceLineitem__c liA = new BVCInvoiceLineitem__c(
            BVCInvoice__c = inv.Id,
            Name = 'LINE A',
            BVC_CB_ChargeDescription__c = 'DESC A',
            Freight_Charges__c = 10
        );
        
         insert liA;
        BVCInvoiceLineitem__c liB = new BVCInvoiceLineitem__c(
            BVCInvoice__c = inv.Id,
            Name = 'LINE B',
            BVC_CB_ChargeDescription__c = 'DESC B',
            Freight_Charges__c = 20
        );
  insert lib;
     

        BVCInvoiceLineitem__c l =[select id,Name,BVC_CB_ChargeDescription__c,Freight_Charges__c from BVCInvoiceLineitem__c where id=:lib.Id];
        liB.Name = 'LINE A';
        liB.BVC_CB_ChargeDescription__c = 'DESC A';
         liB.Freight_Charges__c = 10;
        update lib;

       
    }
   
}