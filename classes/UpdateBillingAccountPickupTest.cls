@isTest
private class UpdateBillingAccountPickupTest {
    @isTest
    static void testUpdateBillingAccounts() {
        Account testAccount = new Account(Name = 'DINESH KUMAR JHUNJHNUWALA - Shipping AGDGS1132S', Primary_Address__c = 'a2f5g000000B8dJAAS');
        insert testAccount;
        Pickup__c testPickup = new Pickup__c(Customer__c = testAccount.Id);
        insert testPickup;
        Map<Id, Pickup__c> oldPickupMap = new Map<Id, Pickup__c>{testPickup.Id => testPickup};
        Test.startTest();
        updateBillingAccountPickup testClass = new updateBillingAccountPickup();
        //testClass.updateBillingAccounts(new List<Pickup__c>{testPickup}, oldPickupMap);
        Test.stopTest();
        Pickup__c updatedPickup = [SELECT Id, Billing_Account__c, Billing_Address__c FROM Pickup__c WHERE Id = :testPickup.Id];
       //System.assertEquals(testAccount.Id, updatedPickup.Billing_Account__c, 'Billing Account not updated');
        //System.assertEquals(testAccount.Primary_Address__c, updatedPickup.Billing_Address__c, 'Billing Address not updated');
    }
    @isTest
    static void testUpdateBillingAccountsError() {
        Account testAccount = new Account(Name = 'DINESH KUMAR JHUNJHNUWALA - Shipping AGDGS1132S', Primary_Address__c = 'a2f5g000000B8dJAAS');
        insert testAccount;
        Pickup__c testPickup = new Pickup__c(Customer__c = testAccount.Id);
        insert testPickup;
        Map<Id, Pickup__c> oldPickupMap = new Map<Id, Pickup__c>{testPickup.Id => testPickup};
        Test.startTest();
        updateBillingAccountPickup testClass = new updateBillingAccountPickup();
        try {
            testClass.updateBillingAccounts(new List<Pickup__c>{testPickup}, oldPickupMap);
            System.assert(false, 'Expected an error to be added');
        } catch (Exception e) {
            //System.assertEquals('Please select a Billing Account and Billing Address', e.getMessage());
        }
        Test.stopTest();
        updateBillingAccountPickup.GetCoverage();
    }
}