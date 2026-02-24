@isTest
private class ContactValidationHelperTest {

    // Utility method to create a test AddressBook record
    private static AddressBook__c createAddressBook(Boolean isRestricted) {
        Id restrictedRecordTypeId;

        if (isRestricted) {
            restrictedRecordTypeId = [
                SELECT Id FROM RecordType 
                WHERE SObjectType = 'AddressBook__c' 
                AND DeveloperName = 'Billing' 
                LIMIT 1
            ].Id;
        }
            Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '+919474636783';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc;
        // Create the record as the default (System Admin) test user
        AddressBook__c addr = new AddressBook__c(
            Name = 'Test AddressBook',
            Customer__c = Acc.id,
            RecordTypeId = isRestricted ? restrictedRecordTypeId : null
        );
        insert addr;

        return addr;
    }

    @isTest
    static void testPreventRestrictedContactCreation_OfficeExec_ShouldError() {
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Operations Office Executive' LIMIT 1];
        User restrictedUser = new User(
            Alias = 'restusr',
            Email = 'restricteduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = restrictedProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'restricteduser@test.com'
        );
        insert restrictedUser;

        AddressBook__c restrictedAddressBook = createAddressBook(true);

        System.runAs(restrictedUser) {
            Contact con = new Contact(
                LastName = 'Test Contact Office Exec',
                AddressBook__c = restrictedAddressBook.Id
            );

            Test.startTest();
            try {
                insert con;
                System.assert(false, 'Expected DMLException was not thrown');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('You are not allowed to create a Contact'),
                    'Expected validation error message not found: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testPreventRestrictedContactCreation_FieldExec_ShouldError() {
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Operations Field Executive' LIMIT 1];
        User restrictedUser = new User(
            Alias = 'fldusr',
            Email = 'fielduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'FieldExec',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = restrictedProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'fielduser@test.com'
        );
        insert restrictedUser;

        AddressBook__c restrictedAddressBook = createAddressBook(true);

        System.runAs(restrictedUser) {
            Contact con = new Contact(
                LastName = 'Test Contact Field Exec',
                AddressBook__c = restrictedAddressBook.Id
            );

            Test.startTest();
            try {
                insert con;
                System.assert(false, 'Expected DMLException was not thrown');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('You are not allowed to create a Contact'),
                    'Expected validation error message not found: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testPreventRestrictedContactCreation_NonRestricted_ShouldPass() {
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        AddressBook__c restrictedAddressBook = createAddressBook(true);

        System.runAs(currentUser) {
            Contact con = new Contact(
                LastName = 'Allowed Contact',
                AddressBook__c = restrictedAddressBook.Id
            );

            Test.startTest();
            insert con; // Should succeed
            Test.stopTest();

            System.assertNotEquals(null, con.Id, 'Contact should have been inserted successfully');
        }
    }
}