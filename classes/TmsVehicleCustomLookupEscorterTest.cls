/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 27-03-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/

@isTest
private class TmsVehicleCustomLookupEscorterTest {

    @isTest
    static void testFetchLookupData() {
        
        //FleetX_People__c ftPeople = new FleetX_People__c();
        //insert ftPeople;

        Test.startTest();
        List<sObject> result = TmsVehicleCustomLookupEscorter.fetchLookupData('TestData', 'User');
        //List<sObject> result = TmsVehicleCustomLookupEscorter.fetchLookupData('TestData', 'FleetX_People__c');

        Test.stopTest();
        
    }

}