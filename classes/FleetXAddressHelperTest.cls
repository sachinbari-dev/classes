@isTest
public class FleetXAddressHelperTest 
{
@isTest
    public static void test1()
    {
        // List<FleetX_AddressBook__c> fxaList = new List<FleetX_AddressBook__c>();
       
        List<String> ids = new List<String>();
        for(integer x=1;x<=5;x++)
        {
            FleetX_AddressBook__c sfa = new FleetX_AddressBook__c();
            sfa.Address_Name__c='test Address name'+x;
            sfa.Address_Details__c='112-addtest'+x;
            sfa.Address_Code__c='11234'+x;
            insert sfa;
            ids.add(sfa.Id);
        }
        Test.startTest();
        //FleetXAddressHelper.saveFleetxAddress('Sample Route1','',ids);
        Test.stopTest();
    }
    
}