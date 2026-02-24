@IsTest
public class TmsUpdateSecureBagTriggerTest {
    @IsTest
    public static void test1() {
        Hub__c hub1 = new Hub__c();
        hub1 = BVCL_TestDataFactory.CreateHub('name', true, 'MUMBAI');
        
        Hub__c hub2 = new Hub__c();
        hub2 = BVCL_TestDataFactory.CreateHub('name1', true, 'DELHI');
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Flight_Schedule__c testFlightSchedule = new Flight_Schedule__c();
        insert testFlightSchedule;
        
        Secure_Bag__c testSecureBag = new Secure_Bag__c();
        testSecureBag.Shipment__c = Ship1.Id;
        testSecureBag.Current_Scan_Hub__c = hub1.Id;
        testSecureBag.Current_Origin_City__c = 'Delhi';
        testSecureBag.Finalised_Linehaul_Number__c = null;
        testSecureBag.Flight_Schedule__c = null;
        testSecureBag.Linehaul_Type__c = null;
        testSecureBag.Next_Destination__c = null;
        testSecureBag.Flight_Date_Time__c = null;
        testSecureBag.Finalized_Time__c = null;
        
        insert testSecureBag;
        
        Secure_Bag__c testSecureBagToUpdate = [SELECT Id, Current_Scan_Hub__c FROM Secure_Bag__c LIMIT 1];
        testSecureBagToUpdate.Current_Scan_Hub__c = hub2.Id;
        
        Test.startTest();
        update testSecureBagToUpdate;
        Test.stopTest();
        
        
    }
    
   
}