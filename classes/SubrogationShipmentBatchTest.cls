@IsTest
public class SubrogationShipmentBatchTest {

    @IsTest
    static void testMethod1() {
        Hub__c hb = new Hub__c();
        hb.Name = 'name';
        hb.Branch__c= 'Mumbai';
        insert hb;
        
        Active_Pincode__c pinCode = new Active_Pincode__C();
        pinCode.Name = '400093';
        pinCode.Pincodes__c = '400093';
        pinCode.State__c = 'Maharashtra';
        pinCode.Country__c = 'India';
        pinCode.City__c = 'Mumbai';
        insert pinCode;
        
        List<Account> accList = new List<Account>();
        Account Customer = TestUtility.createnonACRnonContractedAccount();
        Customer.Name = 'Wallet Account';
        Customer.Last_Name__c = 'xyz';
        Customer.Oracle_Account_Code__c = '3242';
        Customer.Subrogation_Start_Date__c = Date.newInstance(2025, 5, 2);
        Customer.Subrogation_End_Date__c = Date.newInstance(2026, 5, 1);
        accList.add(Customer);
        
        insert accList;
        System.debug('non acr account===='+accList[0]);
        
        Shipment__c shipment = new Shipment__c();
        shipment.Customer__c = Customer.Id;
        shipment.Subrogation_letter_available__c = false;
        insert shipment;
        
        Test.setCreatedDate(shipment.Id, DateTime.newInstance(2025, 3, 19, 0, 0, 0));
        
        Test.startTest();
        SubrogationShipmentBatch batch = new SubrogationShipmentBatch(new Set<Id>{Customer.Id});
        Database.executeBatch(batch, 50);
        Test.stopTest();
        
        Shipment__c updatedShipment = [SELECT Id, Subrogation_letter_available__c, CreatedDate FROM Shipment__c WHERE Id = :shipment.Id];
        System.debug('createddate===='+updatedShipment.CreatedDate);
        System.debug('Subrogation_letter_available__c===='+updatedShipment.Subrogation_letter_available__c);
        System.debug('Id===='+updatedShipment.Id);
        System.assertEquals(true, updatedShipment.Subrogation_letter_available__c, 'Shipment should be marked for subrogation');
    }
    @IsTest
    static void testExecuteLogicDirectly() {
        Shipment__c s = new Shipment__c(Subrogation_letter_available__c = false);
        insert s;
        
        List<SObject> scope = new List<SObject>{ s };
            
            SubrogationShipmentBatch batch = new SubrogationShipmentBatch(null);
        batch.updateShipments(scope);  // 👈 direct call to boost coverage
        
        Shipment__c updated = [SELECT Subrogation_letter_available__c FROM Shipment__c WHERE Id = :s.Id];
        System.assertEquals(true, updated.Subrogation_letter_available__c);
    }
    
    
}