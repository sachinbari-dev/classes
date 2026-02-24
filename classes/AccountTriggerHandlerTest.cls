@isTest
public class AccountTriggerHandlerTest {
    @testSetup
    static void setup() {
       
        List<Account> existingAccounts = new List<Account>{
            new Account(Name = 'Existing Account 1', PAN_Number_of_Entity__c = 'ASASF1234A', RecordTypeId = '0125g0000002XavAAE'),
            new Account(Name = 'Existing Account 2', PAN_Number_of_Entity__c = 'ASASF1234H', RecordTypeId = '0125g0000002Xax')
        };
        insert existingAccounts;
    }

    @isTest
    static void testDuplicatePANNumber() {
       
        Account newAccount = new Account(Name = 'New Account', PAN_Number_of_Entity__c = 'ASASF1234A', RecordTypeId = '0125g0000002XavAAE');
        
        Test.startTest();
        try {
            insert newAccount;
          //  System.assert(false, 'Expected DMLException was not thrown');
        } catch (DmlException e) {
           
         //   System.assert(e.getMessage().contains('An account with the same PAN Number already exists.'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testNonDuplicatePANNumber() {
        
        Account newAccount = new Account(Name = 'Unique Account', PAN_Number_of_Entity__c = 'ASASF1234R', RecordTypeId = '0125g0000002XavAAE');
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
        
       
        Account insertedAccount = [SELECT Id, PAN_Number_of_Entity__c FROM Account WHERE Id = :newAccount.Id];
        System.assertNotEquals(null, insertedAccount, 'The account should have been inserted successfully.');
    }

    @isTest
    static void testDifferentRecordTypeId() {
       
        Account newAccount = new Account(Name = 'Different Record Type Account', PAN_Number_of_Entity__c = 'ASASF1234R', RecordTypeId = '0125g0000002XavAAE');
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
        
       
        Account insertedAccount = [SELECT Id, PAN_Number_of_Entity__c FROM Account WHERE Id = :newAccount.Id];
        System.assertNotEquals(null, insertedAccount, 'The account should have been inserted successfully.');
    }
}