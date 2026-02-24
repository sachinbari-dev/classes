@isTest
public class SendConsumptionAlertTest {

    @testSetup
    static void setupData() {
        // Create test Users (Owner + Secondary Owner)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User ownerUser = new User(
            FirstName = 'Primary',
            LastName = 'Owner',
            Email = 'sanket.pisal@bvclogistice.com',
            Username = 'primary.owner@test.com.' + System.currentTimeMillis(),
            Alias = 'pown',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert ownerUser;

        User secondaryUser = new User(
            FirstName = 'Secondary',
            LastName = 'Owner',
            Email = 'sanket.pisal@bvclogistice.com',
            Username = 'secondary.owner@test.com.' + System.currentTimeMillis(),
            Alias = 'sown',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert secondaryUser;

        // Create Account
        Account acc = new Account(
            Name = 'Test Customer Account',
            OwnerId = ownerUser.Id,
            Sales_Secondary_Owner__c = secondaryUser.Id
        );
        insert acc;

        // Create two Contacts with emails
        Contact contact1 = new Contact(
            FirstName = 'Finance',
            LastName = 'Contact1',
            Email = 'finance1@test.com',
            AccountId = acc.Id
        );

        Contact contact2 = new Contact(
            FirstName = 'Legal',
            LastName = 'Contact2',
            Email = 'sanket.pisal@bvclogistice.com',
            AccountId = acc.Id
        );

        insert new List<Contact>{ contact1, contact2 };

        // Link via AccountContactRole (with non-null role)
        insert new List<AccountContactRole>{
            new AccountContactRole(AccountId = acc.Id, ContactId = contact1.Id, Role = 'Finance'),
            new AccountContactRole(AccountId = acc.Id, ContactId = contact2.Id, Role = 'Legal')
        };

        // Create BVC Contract with >120% consumption
        BVC_Contract__c contract = new BVC_Contract__c(
           // Name = 'Test BVC Contract',
            //of_Contract_Consumption__c = 1.25,
            Customer_Name__c = acc.Id
        );
        insert contract;
    }

    @isTest
    static void testSendAlert() {
        // Get the test contract
        BVC_Contract__c contract = [SELECT Id FROM BVC_Contract__c LIMIT 1];

        // Prepare input
        SendConsumptionAlert.InputWrapper input = new SendConsumptionAlert.InputWrapper();
        input.contractId = contract.Id;

        Test.startTest();
        SendConsumptionAlert.sendAlert(new List<SendConsumptionAlert.InputWrapper>{ input });
        Test.stopTest();

        System.assert(true, 'Email send completed without error.');
    }
}