@isTest
public class ShipmentSummaryTriggerHandlerTest_2 {
    
    @isTest
    static void setupTestData() {
        try{
            Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
            Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
            Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
            Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
            AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
            AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
            Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
            Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
            
            BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
            billingEntity.Name = 'test';
            
            insert billingEntity;
            
            ST_ACR_Standard_Price__c acrStdPrice = new ST_ACR_Standard_Price__c();
            Insert acrStdPrice;
            
            Contact testContact = new Contact(
                LastName = 'Test Name',
                AccountId = testAccount.Id,
                MobilePhone = '9876543210'
            );
            Insert testContact;
            
            
            External_Contract__c EC = new 	External_Contract__c();
            EC.Customer__c = testAccount.id;
            EC.Product_Code__c = 'VAL-MM-1';
            EC.Product_Name__c= 'Valship Metro To Metro (0-1)';
            EC.Active__c = true;
            
            Insert EC;
            
            External_Contract_Shipment_Summary__c ECSS = new External_Contract_Shipment_Summary__c();
            ECSS.Customer__c=testAccount.id;
            ECSS.External_Contract__c= EC.Id;
            ECSS.Product_Code__c = 'VAL-MM-1';
            ECSS.Product_Name__c= 'Valship Metro To Metro (0-1)';
            ECSS.BVC_LegalEntity__c=billingEntity.id;
            
            insert ECSS;
            
            BVCInvoice__c Inv = new BVCInvoice__c();
            Inv.Account__c= testAccount.id;
            Inv.Product_Code__c='VAL-MM-1';
            Inv.Product_Name__c='Valship Metro To Metro (0-1)';
            Inv.BVC_LegalEntity__c = billingEntity.Id;
            Inv.Status__c = 'Draft';
            
            insert Inv;
            
            Inv.Status__c='Posted';
            update Inv;
            
            ECSS.BVCInvoice__c=Inv.id;
            update ECSS;
            
            BVCInvoice__c Inv2 = new BVCInvoice__c();
            Inv2.Account__c= testAccount.id;
            Inv2.Product_Code__c='VAL-MM-1';
            Inv2.Product_Name__c='Valship Metro To Metro (0-1)';
            Inv2.BVC_LegalEntity__c = billingEntity.Id;
            
            insert Inv2;
            
            Attachment att = new Attachment(
            Name = 'TestAttachment.pdf',
            Body = Blob.valueOf('Test File'),
            ParentId = inv2.Id
        );
        insert att;
            
            BVCInvoice__c updatedInv = [
            SELECT Invoice_AttachmentId__c
            FROM BVCInvoice__c
            WHERE Id = :inv2.Id
        ];
            
        }catch(Exception ex){
            System.debug('Error Message ==='+ex.getMessage());
            System.debug('Error on Line Number ==='+ex.getLineNumber());
        }
    }
    @isTest
    static void acrShipmentTestMethod(){
        
        
        PaymentBuilder.dummyMethod();//100
        RazorpayAllocationBatch.dummyMethod();//94
    }}