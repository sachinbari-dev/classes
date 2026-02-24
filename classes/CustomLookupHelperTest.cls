@isTest
public class CustomLookupHelperTest {

    @testSetup
    static void setup() {
        // Create test data for FleetX_People__c object
        List<FleetX_People__c> testPeople = new List<FleetX_People__c>();
        for (Integer i = 0; i < 10; i++) {
            testPeople.add(new FleetX_People__c(
                Name = 'Test Person ' + i,
                People_userType__c = 'Type' + i
            ));
        }
        insert testPeople; 

        // Create test data for other sObjects if needed
    }

    @isTest
    static void testGetCustomLookupWithValidInputs() {
        List<String> searchList = new List<String>(); 
        searchList.add('Gunman');
        searchList.add('Security Guard');
        String result = CustomLookupHelper.getCustomLookup('FleetX_People__c', 'Name', 'Test', 'People_userType__c', 'Type1','',searchList,'','');   
        List<CustomLookupHelper.ResultWrapper> resultList = (List<CustomLookupHelper.ResultWrapper>) JSON.deserialize(result, List<CustomLookupHelper.ResultWrapper>.class);
    }

    @isTest
    static void testGetCustomLookupWithNullSearchText() {
         List<String> searchList = new List<String>(); 
        searchList.add('Gunman');
        searchList.add('Security Guard');
        String result = CustomLookupHelper.getCustomLookup('FleetX_People__c', 'Name', null, 'People_userType__c', 'Type1','',searchList,'','');
        List<CustomLookupHelper.ResultWrapper> resultList = (List<CustomLookupHelper.ResultWrapper>) JSON.deserialize(result, List<CustomLookupHelper.ResultWrapper>.class);
    }

    @isTest
    static void testGetCustomLookupWithNullFilterField1() {
        List<String> searchList = new List<String>(); 
        searchList.add('Gunman');
        searchList.add('Security Guard');
        try{
            String result = CustomLookupHelper.getCustomLookup('FleetX_People__c', 'Name', 'Test', null, null,'',searchList,'','');
            List<CustomLookupHelper.ResultWrapper> resultList = (List<CustomLookupHelper.ResultWrapper>) JSON.deserialize(result, List<CustomLookupHelper.ResultWrapper>.class);           
        }catch(exception e)
        {
            
        }

    }

    @isTest
    static void testGetCustomLookupWithInvalidObjName() {
        try {
            List<String> searchList = new List<String>(); 
            searchList.add('Gunman');
            searchList.add('Security Guard');
            String result = CustomLookupHelper.getCustomLookup('InvalidObject__c', 'Name', 'Test', 'People_userType__c', 'Type1','',searchList,'','');
        } catch (Exception e) {
            System.debug('Caught exception: ' + e.getMessage());
        }
    }

    @isTest
    static void testGetCustomLookupWithEmptySearchText() {
        List<String> searchList = new List<String>(); 
        searchList.add('Gunman');
        searchList.add('Security Guard');
        String result = CustomLookupHelper.getCustomLookup('FleetX_People__c', 'Name', '', 'People_userType__c', 'Type1','',searchList,'','');
        List<CustomLookupHelper.ResultWrapper> resultList = (List<CustomLookupHelper.ResultWrapper>) JSON.deserialize(result, List<CustomLookupHelper.ResultWrapper>.class);
    }

    @isTest
    static void testGetCustomLookupWithOnlyFilterField1() {
        List<String> searchList = new List<String>(); 
        searchList.add('Gunman');
        searchList.add('Security Guard');
        String result = CustomLookupHelper.getCustomLookup('FleetX_People__c', 'Name', null, 'People_userType__c', 'Type1','',searchList,'','');
        List<CustomLookupHelper.ResultWrapper> resultList = (List<CustomLookupHelper.ResultWrapper>) JSON.deserialize(result, List<CustomLookupHelper.ResultWrapper>.class);
    }
}