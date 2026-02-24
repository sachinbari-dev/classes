@isTest
public class DefaultContactEnforcerTest {
    @isTest
    static void testEnforceDefaultContact() {
        AddressBook__c testAddressBook = new AddressBook__c(Customer__c='0015g000011c0KXAAY');
        insert testAddressBook;
        
        Contact testContact1 = new Contact(
            LastName = 'TestContact1',
            Default__c = false,
             Email='test1@gmail.com',
             MobilePhone='+918951234567',
            AddressBook__c = testAddressBook.Id
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            LastName = 'TestContact2',
            Default__c = false,
            MobilePhone='+918951234568',
             Email='test2@gmail.com',
            AddressBook__c = testAddressBook.Id
        );
        
        AddressBook__c emptyAddressBook = new AddressBook__c(Customer__c='0015g000011c0KXAAY');
        insert emptyAddressBook;
        
        Contact testContact3 = new Contact(
            LastName = 'TestContact3',
            Default__c = true,
             Email='test3@gmail.com',
            MobilePhone='+918951234560',
            AddressBook__c = emptyAddressBook.Id
        );
        insert testContact3;
        
        List<Contact> newContacts = new List<Contact>{testContact2, testContact3};
        
        Test.startTest();
        DefaultContactEnforcer.enforceDefaultContact(newContacts);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testGetExistingDefaultContacts() {
        // Create test data
        
        AddressBook__c testAddressBook = new AddressBook__c(Customer__c='0015g000011c0KXAAY');
        insert testAddressBook;
        
        Contact testContact1 = new Contact(
            LastName = 'TestContact1',
            Default__c = false,
             Email='test12@gmail.com',
             MobilePhone='+9189512345612',
            AddressBook__c = testAddressBook.Id
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            LastName = 'TestContact2',
            Default__c = true,
            Email='test23@gmail.com',
            MobilePhone='+9189512345613',
            AddressBook__c = testAddressBook.Id
        );
        insert testContact2;
        
        Set<Id> addressBookIds = new Set<Id>{testAddressBook.Id};
        
        Test.startTest();
        Map<Id, Contact> existingDefaultContacts = DefaultContactEnforcer.getExistingDefaultContacts(addressBookIds);
        Test.stopTest();
        
        
    }
}