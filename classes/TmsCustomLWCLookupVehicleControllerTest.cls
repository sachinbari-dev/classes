/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 27-03-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/

@isTest
private class TmsCustomLWCLookupVehicleControllerTest {

    @isTest
    static void testFetchLookupData() {

       	Transport__c tVehicle = new Transport__c();
        tVehicle.Vehicle_Number__c = 'TestData';
        insert tVehicle;

        Test.startTest();
        List<sObject> result = TmsCustomLWCLookupVehicleController.fetchLookupData('TestData', 'Transport__c');
        Test.stopTest();
        
        
    }

}