@isTest
private class AddressBookControllerTest {
    @testSetup
    static void setupTestData() {
        List<AddressBook__c> addressBooks = new List<AddressBook__c>();
        for (Integer i = 0; i < 3; i++) {
            addressBooks.add(new AddressBook__c(Name = 'Test AddressBook ' + i, Customer__c = '0015g000011c0KXAAY'));
        }
        insert addressBooks;
    }

    @isTest
    static void testEnforceContactLimit() {
        AddressBookControllerTest.setupTestData();

        List<AddressBook__c> addressBooks = [
            SELECT Id
            FROM AddressBook__c
            LIMIT 3
        ];

        List<Contact> contactsToInsert = new List<Contact>();
        Integer addressBookIndex = 0;
        for (Integer i = 0; i < 5; i++) {
            contactsToInsert.add(new Contact(
                FirstName = 'New',
                LastName = 'Contact ' + i,
                MobilePhone='+9189012345',
                AddressBook__c = addressBooks[addressBookIndex].Id
            ));
            addressBookIndex++;
            if (addressBookIndex >= addressBooks.size()) {
                addressBookIndex = 0;
            }
        }

        Test.startTest();
        AddressBookController.enforceContactLimit(contactsToInsert);
        Test.stopTest();

     
    }

    @isTest
    static void testEnforceContactLimitWithExistingContacts() {
        AddressBookControllerTest.setupTestData();

        List<AddressBook__c> addressBooks = [
            SELECT Id
            FROM AddressBook__c
            LIMIT 3
        ];

        List<Contact> existingContacts = new List<Contact>();
        Integer addressBookIndex = 0;  // Initialize the addressBookIndex
        for (Integer i = 0; i < 12; i++) {
            existingContacts.add(new Contact(
                FirstName = 'Existing',
                LastName = 'Contact ' + i,
                MobilePhone='+9189012345',
                Email='test1@gmail.com',
                AddressBook__c = addressBooks[addressBookIndex].Id
            ));
            addressBookIndex++;
            if (addressBookIndex >= addressBooks.size()) {
                addressBookIndex = 0;
            }
        }
        insert existingContacts;

        List<Contact> newContacts = new List<Contact>();
        newContacts.add(new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            Email='test1@gmail.com',
            MobilePhone='+9189012345',
            AddressBook__c = addressBooks[0].Id
        ));

        Test.startTest();
        AddressBookController.enforceContactLimit(newContacts);
        Test.stopTest();

        
    }
}