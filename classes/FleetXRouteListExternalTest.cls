@isTest
public class FleetXRouteListExternalTest {
    @isTest
    public static void test1()
    {
        FleetX_AddressBook__c sfa = new FleetX_AddressBook__c();
        sfa.Address_Name__c='test Address name';
        sfa.Address_Details__c='112-addtest';
        sfa.Address_Code__c='11234';
        insert sfa;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();           
        FleetXRouteListExternal fre = new FleetXRouteListExternal();
        fre.getFleetXRoutes();
        FleetXRouteListExternalBatchSchedular myClass = new FleetXRouteListExternalBatchSchedular ();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);        
        Test.stopTest();
    }
}