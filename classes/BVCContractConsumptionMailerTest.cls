@isTest
public class BVCContractConsumptionMailerTest {
    @isTest
    static void testSendEmailWithMockedFinanceContact() {
        // Create secondary user
        User secondaryOwner = new User(
            Alias = 'ssowner',
            Email = 'secowner@example.com',
            FirstName = 'Finance',
            LastName = 'Contact1',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sec.owner.test@example.com'
        );
        insert secondaryOwner;

        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Update with secondary owner
        acc.Sales_Secondary_Owner__c = secondaryOwner.Id;
      //  update acc;

        // Create Contact with Email
        Contact financeContact = new Contact(
            FirstName = 'Finance',
            LastName = 'Contact',
            Email = 'finance@example.com'
        );
        insert financeContact;

        // Cannot insert AccountContactRole in Apex – we just reference it in production logic

        // Create BVC Contract
        BVC_Contract__c contract = new BVC_Contract__c(
         //   Name = 'Test Contract',
         //   of_Contract_Consumption__c = 130,/
            Customer_Name__c = acc.Id,
            BVC_Service__c ='ExhibiSHIP'
        );
        insert contract;

        Test.startTest();
        BVCContractConsumptionMailer.sendContractConsumptionEmail(new List<Id>{contract.Id});
        BVCContractConsumptionExhibitionMailer.sendContractConsumptionEmail(new List<Id>{contract.Id});
        BVCContractConsumption80Mailer.sendContractConsumptionEmail(new List<Id>{contract.Id});

        Test.stopTest();

       // System.assertEquals(1, Limits.getEmailInvocations());
    }
}