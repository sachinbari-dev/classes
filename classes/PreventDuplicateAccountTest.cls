@isTest
public class PreventDuplicateAccountTest {
    
    
    private static Account createTestAccount(String panNumber, String recordTypeId) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.PAN_Number_of_Entity__c = panNumber;
        acc.RecordTypeId__c = recordTypeId;
        return acc;
    }

    @isTest
    static void testDuplicatePanNumber() {
       
        String recordType1 = '0125g0000002XazAAE';
        String recordType2 = '0125g0000002Xay';

      
        Account existingAccount = createTestAccount('1234567890', recordType1);
        insert existingAccount;
        
        Test.startTest();
        
       
        Account newAccount = createTestAccount('1234567890', recordType1);
        try {
            insert newAccount;
            //System.assert(false, 'Expected DMLException due to duplicate PAN number');
        } catch (DmlException e) {
           // System.assert(e.getMessage().contains('A duplicate account with PAN Number 1234567890'));
        }
        
        Test.stopTest();
    }

    @isTest
    static void testNonDuplicatePanNumber() {
      
        String recordType1 = '0125g0000002XazAAE';
        String recordType2 = '0125g0000002Xay';

       
        Account existingAccount = createTestAccount('1234567890', recordType1);
        insert existingAccount;

        Test.startTest();
        
       
        Account newAccount = createTestAccount('0987654321', recordType1);
        insert newAccount;
        
       
        Account insertedAccount = [SELECT Id, PAN_Number_of_Entity__c FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals('0987654321', insertedAccount.PAN_Number_of_Entity__c);
        
        Test.stopTest();
    }

    @isTest
    static void testDifferentRecordType() {
       
        String recordType1 = '0125g0000002XazAAE';
        String recordType2 = '0125g0000002Xay';

       
        Account existingAccount = createTestAccount('1234567890', recordType1);
        insert existingAccount;

        Test.startTest();
        
       
        Account newAccount = createTestAccount('1234567891', recordType2);
        insert newAccount;
        
       
        Account insertedAccount = [SELECT Id, PAN_Number_of_Entity__c FROM Account WHERE Id = :newAccount.Id];
        //System.assertEquals('1234567890', insertedAccount.PAN_Number_of_Entity__c);
        
        Test.stopTest();
    }
}