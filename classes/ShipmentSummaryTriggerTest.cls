@isTest
public class ShipmentSummaryTriggerTest {
    @IsTest
    static void testCreateExternalContractShipment() {
        try{
            Account acrAccount = BVCL_TestDataFactory.createCustomer('ACR Account','Billing',true);
            Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
            Hub__c testHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
            Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', testHub.id, 'Delhi', 'South', true);
            AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',nonAcrAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
            Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(acrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, false);
            Ship1.Shipping_Note_Number__c = 'testSNN';
            Insert Ship1;
            Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(nonAcrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
            List<Shipment__c> shipList = new List<Shipment__c>();
            shipList.add(Ship1);
            shipList.add(Ship2);
            
            BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
            billingEntity.Name = 'test';
            insert billingEntity;
            
            External_Contract__c extContract = new External_Contract__c();
            insert extContract;
            
            BVCInvoice__c invoice = new BVCInvoice__c(
                Account__c = acrAccount.Id,
                Status__c = 'Draft',
                EY_Tax_Calculation_Status__c = 'Pending',
                Billing_Address__c = regularAddress.Id
            );
            insert invoice;
            
            BVCInvoice__c invoice1 = new BVCInvoice__c(
                Account__c = acrAccount.Id,
                Status__c = 'Draft',
                EY_Tax_Calculation_Status__c = 'Pending',
                Billing_Address__c = regularAddress.Id
            );
            insert invoice1;
            
            External_Contract_Shipment_Summary__c summary = new External_Contract_Shipment_Summary__c(
                Customer__c = acrAccount.Id, External_Contract__c = extContract.Id,
                Start_Date__c = Date.today().toStartOfMonth(), End_Date__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1),
                BVC_LegalEntity__c = billingEntity.Id, Origin_Hub__c = testHub.Id, Product_Code__c = 'Product 1',
                BVCInvoice__c = null
                
            );
            insert summary;
            
            External_Contract_Shipment_Summary__c summary1 = new External_Contract_Shipment_Summary__c(
                Customer__c = acrAccount.Id, External_Contract__c = extContract.Id,
                Start_Date__c = Date.today().toStartOfMonth(), End_Date__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1),
                BVC_LegalEntity__c = billingEntity.Id, Origin_Hub__c = testHub.Id, Product_Code__c = 'Product 2',
                BVCInvoice__c = null
                
            );
            insert summary1;
            
            List<External_Contract_Shipment_Summary__c> summaries = new List<External_Contract_Shipment_Summary__c>();
            summaries.add(summary);
            summaries.add(summary1);
            
            Test.startTest();
            summaries[0].BVCInvoice__c = invoice1.Id;
            update summaries[0];
            
            summaries[1].BVCInvoice__c = invoice.Id;
            update summaries[1];
            Test.stopTest();
            
        }catch(Exception ex){
            System.debug('Error in testShipmentSummaryTriggerTest === '+ex.getMessage());
            System.debug('Error in testShipmentSummaryTriggerTest on line number === '+ex.getLineNumber());
        }
    }
}