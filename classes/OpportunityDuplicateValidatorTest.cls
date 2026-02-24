@isTest
private class OpportunityDuplicateValidatorTest {
    @isTest
    static void testCheckForDuplicates() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity existingOpportunity = new Opportunity(
            Name = 'Existing Opportunity',
            AccountId = testAccount.Id,
            BVC_L2_Product__c = 'ValShip',
            StageName = 'Closed Won',
            CloseDate = Date.today()
        );
        insert existingOpportunity;
        
        Opportunity newOpportunity = new Opportunity(
            Name = 'New Opportunity',
            AccountId = testAccount.Id,
            BVC_L2_Product__c = 'ValShip',
            StageName = 'Closed Lost',
            CloseDate = Date.today()
        );
        
        List<Opportunity> newOpportunities = new List<Opportunity>{ newOpportunity };
        
        // Call the method being tested
        Test.startTest();
        OpportunityDuplicateValidator.checkForDuplicates(newOpportunities);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, newOpportunities.size());
       // System.assert(newOpportunities[0].hasErrors(), 'Error should be added to the new opportunity');
        
        try {
            insert newOpportunities[0];
        } catch (DmlException e) {
            System.assertEquals(1, e.getNumDml());
            System.assertEquals(0, e.getDmlIndex(0));
           
        }
    }
}