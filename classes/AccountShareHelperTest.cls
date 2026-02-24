@IsTest
public class AccountShareHelperTest {
    @IsTest
    static void testShareBVCContracts() {
        
        User primaryOwner = createTestUser('primaryowner@test.com');
        User secondaryOwner = createTestUser('secondaryowner@test.com');
        
       
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = primaryOwner.Id,
            Sales_Secondary_Owner__c = secondaryOwner.Id
        );
        insert testAccount;

      
        List<BVC_Contract__c> contracts = new List<BVC_Contract__c>();
        for (Integer i = 1; i <= 2; i++) {
            contracts.add(new BVC_Contract__c(
             
                Customer_Name__c = testAccount.Id,
                Status__c = 'Activated'
            ));
        }
        insert contracts;

        
        Test.startTest();
        AccountShareHelper.shareBVCContracts(new List<Id>{testAccount.Id});
        Test.stopTest();

     
        List<BVC_Contract__Share> shares = [
            SELECT ParentId, UserOrGroupId, AccessLevel, RowCause 
            FROM BVC_Contract__Share 
            WHERE ParentId IN :contracts
        ];

     
        for (BVC_Contract__Share share : shares) {
          
        }
    }
   
    private static User createTestUser(String email) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = email,
            Username = email,
            Alias = 'tuser',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        return user;
    }
}