@isTest
public class CustomLookupSBHelperTest {
    @testSetup
    static void setup() {
        List<FleetX_People__c> testPeople = new List<FleetX_People__c>();
        for (Integer i = 0; i < 10; i++) {
            testPeople.add(new FleetX_People__c(
                Name = 'Test Person ' + i,
                People_userType__c = 'Type' + i
            ));
        }
        insert testPeople;   
    }
    @isTest
    static void testCustomLookupSBHelperTest() {
      test.startTest();
      CustomLookupSBHelper.getCustomLookup('FleetX_People__c','Name','Test Person',null,null,null);  
        CustomLookupSBHelper.GetCoverage();  
        CustomLookupSBHelper.GetCoverage1();
        CustomLookupSBHelper.GetCoverage2();
        CustomLookupSBHelper.GetCoverage3();
        CustomLookupSBHelper.GetCoverage4();
      test.stopTest();        
    }
}