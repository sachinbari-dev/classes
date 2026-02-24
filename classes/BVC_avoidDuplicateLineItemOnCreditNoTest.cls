@isTest
public class BVC_avoidDuplicateLineItemOnCreditNoTest {

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
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 10000;  
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = new BVCCreditNote__c();
        creditNote.Account__c = BillingAcc.Id;
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        insert creditNote;
        
        BVCCredit_Note_Line__c creditNoteLine1 = new BVCCredit_Note_Line__c(
            BVCCreditNote__c = creditNote.Id,
            Charge_Head_Type__c = 'Fuel Surcharge',
            Subtotal__c = 5.00
        );
        
        BVCCredit_Note_Line__c creditNoteLine2 = new BVCCredit_Note_Line__c(
            BVCCreditNote__c = creditNote.Id,
            Charge_Head_Type__c = 'Universe Cost Charge',
            Subtotal__c = 20.00,
            Line_Number__c = '1'
        );
        
          BVCCredit_Note_Line__c creditNoteLine3 = new BVCCredit_Note_Line__c(
            BVCCreditNote__c = creditNote.Id,
            Charge_Head_Type__c = 'Universe Cost Charge',
            Subtotal__c = 20.00
            
        );
        List<BVCCredit_Note_Line__c>  CnList =  new List<BVCCredit_Note_Line__c>{creditNoteLine1, creditNoteLine2,creditNoteLine3};
        
        insert CnList;
            
     
            Test.startTest();
         BVC_avoidDuplicateLineItemOnCreditnote.avoidDuplicateLineItem(CnList);
         
            Test.stopTest();
    }
    @isTest
     public static void testMethod2(){
         
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
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 10000;  
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = new BVCCreditNote__c();
        creditNote.Account__c = BillingAcc.Id;
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        insert creditNote;
        
        BVCCredit_Note_Line__c creditNoteLine1 = new BVCCredit_Note_Line__c(
            BVCCreditNote__c = creditNote.Id,
            Charge_Head_Type__c = 'Fuel Surcharge',
            Subtotal__c = 5.00
        );
        
        BVCCredit_Note_Line__c creditNoteLine2 = new BVCCredit_Note_Line__c(
            BVCCreditNote__c = creditNote.Id,
            Charge_Head_Type__c = 'Universe Cost Charge',
            Subtotal__c = 20.00,
            Line_Number__c = '1'
        );
        
          BVCCredit_Note_Line__c creditNoteLine3 = new BVCCredit_Note_Line__c(
            BVCCreditNote__c = creditNote.Id,
            Charge_Head_Type__c = 'Universe Cost Charge',
            Subtotal__c = 20.00
            
        );
        List<BVCCredit_Note_Line__c>  CnList =  new List<BVCCredit_Note_Line__c>{creditNoteLine1, creditNoteLine2,creditNoteLine3};
        
        insert CnList;
            
        List<BVCCredit_Note_Line__c> cnLists = [select id,name,line_number__c from BVCCredit_Note_Line__c where id=:creditNoteLine3.id];
        cnLists[0].Subtotal__c  =19;
        update cnLists;
         try{
          Test.startTest();
             BVC_avoidDuplicateLineItemOnCreditnote.avoidDuplicateLineNumber(CnList);
            Test.stopTest();
         }catch(Exception e){
             system.debug('error message' + e);
         }

     }
}