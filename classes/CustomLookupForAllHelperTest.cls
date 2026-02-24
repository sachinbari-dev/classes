@isTest(SeeAllData=true)
public class CustomLookupForAllHelperTest
{
    @isTest
    static void testGetCustomLookupWithValidInputs() 
    {
        List<String> searchList = new List<String>(); 
        searchList.add('Gunman');
        searchList.add('Security Guard');       
        CustomLookupForAllHelper.getCustomLookup('Account','Name','as', '',searchList, 'Vault_Shipmet__c', '', '','Shipping_Account__c');
        Account ac = [select id from Account limit 1];
        CustomLookupForAllHelper.getCustomLookup('AddressBook__c','Name','as', '',searchList, 'Vault_Shipmet__c', 'Customer__c', ac.Id,'Stall_Details_Shipping_Address__c');										 

    }
}