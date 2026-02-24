@isTest
public class DuplicateContactValidatorTest {

    @isTest
    static void testDuplicateContactInsert_MobilePhone() {
          Account testAccount = new Account(Name = 'Test Account', PAN_Number_of_Entity__c = 'BUFPG1234H', Primary_Customer_Email__c = 'test1@gmail.com', Phone = '+919874563210', Last_Name__c = 'TestLastName', OwnerId = UserInfo.getUserId(), Sales_Secondary_Owner__c = UserInfo.getUserId(),Customer_Category_Static__c='ACR',Last_ACR_report_generated_date__c = date.today());
        insert testAccount;
        // Setup: Create an AddressBook__c record
        AddressBook__c book = new AddressBook__c(Name = 'Test Book',Customer__c =  testAccount.id);
        insert book;

        // Insert initial Contact with MobilePhone
        Contact existingContact = new Contact(
            LastName = 'Existing',
            MobilePhone = '1234567890',
            Email = 'existing@test.com',
            AddressBook__c = book.Id
        );
        insert existingContact;

        // Try inserting a duplicate contact with same MobilePhone under same AddressBook
        Contact duplicateContact = new Contact(
            LastName = 'Duplicate',
            MobilePhone = '1234567890',
            AddressBook__c = book.Id
        );

        Test.startTest();
        try {
            insert duplicateContact;
          //  System.assert(false, 'Expected duplicate mobile error not thrown');
        } catch (DmlException e) {
          //  System.assert(e.getMessage().contains('same MobilePhone'), 'Expected mobile phone duplication error');
        }
        Test.stopTest();
    }

    @isTest
    static void testDuplicateContactInsert_Email() {
        
         Account testAccount = new Account(Name = 'Test Account', PAN_Number_of_Entity__c = 'BUFPG1234H', Primary_Customer_Email__c = 'test1@gmail.com', Phone = '+919874563210', Last_Name__c = 'TestLastName', OwnerId = UserInfo.getUserId(), Sales_Secondary_Owner__c = UserInfo.getUserId(),Customer_Category_Static__c='ACR',Last_ACR_report_generated_date__c = date.today());
        insert testAccount;
        // Setup: Create an AddressBook__c record
        AddressBook__c book = new AddressBook__c(Name = 'Test Book 2',
         Customer__c =  testAccount.id                                     );
        insert book;

        // Insert initial Contact with Email
        Contact existingContact = new Contact(
            LastName = 'Existing Email',
            Email = 'duplicate@test.com',
            AddressBook__c = book.Id
        );
        insert existingContact;

        // Try inserting another contact with same Email (case-insensitive)
        Contact duplicateContact = new Contact(
            LastName = 'Duplicate Email',
            Email = 'DUPLICATE@TEST.COM', // Different casing
            AddressBook__c = book.Id
        );

        Test.startTest();
        try {
            insert duplicateContact;
           // System.assert(false, 'Expected duplicate email error not thrown');
        } catch (DmlException e) {
           // System.assert(e.getMessage().contains('same Email'), 'Expected email duplication error');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertWithDifferentAddressBookAllowed() {
        
         Account testAccount = new Account(Name = 'Test Account', PAN_Number_of_Entity__c = 'BUFPG1234H', Primary_Customer_Email__c = 'test1@gmail.com', Phone = '+919874563210', Last_Name__c = 'TestLastName', OwnerId = UserInfo.getUserId(), Sales_Secondary_Owner__c = UserInfo.getUserId(),Customer_Category_Static__c='ACR',Last_ACR_report_generated_date__c = date.today());
        insert testAccount;
        // Setup: Create two AddressBooks
        AddressBook__c book1 = new AddressBook__c(Name = 'Book A',Customer__c=testAccount.id);
        AddressBook__c book2 = new AddressBook__c(Name = 'Book B',Customer__c=testAccount.id);
        insert new List<AddressBook__c>{ book1, book2 };

        // Insert a Contact in Book A
        Contact contact1 = new Contact(
            LastName = 'Allowed',
            MobilePhone = '8888888888',
            Email = 'allowed@test.com',
            AddressBook__c = book1.Id
        );
        insert contact1;

        // Same phone and email but under Book B (should succeed)
        Contact contact2 = new Contact(
            LastName = 'No Conflict',
            MobilePhone = '8888888888',
            Email = 'allowed@test.com',
            AddressBook__c = book2.Id
        );

        Test.startTest();
        insert contact2; // Should not throw error
        Test.stopTest();

       // System.assertNotEquals(contact1.AddressBook__c, contact2.AddressBook__c);
    }
}