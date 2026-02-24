@isTest
public class UpdateShipmentFieldsBatchTest {

    @isTest
    static void testBatch() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account',Phone ='919881297454',Last_Name__c = 'Test Contact');
        insert testAccount;

        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id,email = 'test@gmail.com');
        insert testContact;

        Contract testContract = new Contract(AccountId = testAccount.Id, Status = 'Draft',ContractTerm = 12 ,StartDate= Date.today());
        insert testContract;
        
        testAccount.Active_Contract__c = testContract.Id;
        update testAccount;

        Shipment__c testShipment = new Shipment__c(
            Shipping_Note_Number__c = 'SN123',
            Shipment_Date__c = Date.today(),
            Shipment_Value__c = 500,
            Freight_Charges__c = 50,
            Weight_Charges__c = 30,
            Total_Charge__c = 123,
            Bill_To_Account__c = testAccount.Id
        );
        insert testShipment;

        ST_ACR_Consumption__c testConsumption = new ST_ACR_Consumption__c(
            Freight_Charges__c = 60,
            Weight_Charges__c = 40,
            Total_Charge__c = 150,
            Shipment__c = testShipment.id,
            Bill_To_Account__c = testAccount.Id,
            Customer_Account__c = testAccount.Id,
            Contract__c = testContract.Id
        );
        insert testConsumption;
        
        
        

        
        // Start the batch
        Test.startTest();
        UpdateShipmentFieldsBatch batch = new UpdateShipmentFieldsBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that the Shipment__c fields were updated
        Shipment__c updatedShipment = [SELECT Freight_Charges__c, Weight_Charges__c, Total_Charge__c FROM Shipment__c WHERE Id = :testShipment.Id];
        System.assertEquals(testConsumption.Freight_Charges__c, updatedShipment.Freight_Charges__c);
        System.assertEquals(testConsumption.Weight_Charges__c, updatedShipment.Weight_Charges__c);
        System.assertEquals(testConsumption.Total_Charge__c, updatedShipment.Total_Charge__c);
    }
}