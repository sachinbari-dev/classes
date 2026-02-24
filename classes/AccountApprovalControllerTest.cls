@isTest
private class AccountApprovalControllerTest {
    @testSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Approval_Stage__c = 'Pending',
                Owner_Change__c = UserInfo.getUserId()
            ));
        }
        insert accounts;
    }

    @isTest
    static void testGetPendingApprovals() {
        Test.startTest();
        List<Account> pendingAccounts = AccountApprovalController.getPendingApprovals();
        Test.stopTest();

        System.assertNotEquals(0, pendingAccounts.size(), 'There should be pending approvals');
    }

    @isTest
    static void testSubmitForApproval() {
        List<Account> accounts = [SELECT Id FROM Account WHERE Approval_Stage__c = 'Pending'];
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        Test.startTest();
        AccountApprovalController.submitForApproval(accountIds);
        Test.stopTest();

        List<ProcessInstance> approvals = [SELECT Id FROM ProcessInstance WHERE TargetObjectId IN :accountIds];
        System.assertNotEquals(0, approvals.size(), 'Accounts should be submitted for approval');
    }

    @isTest
    static void testApproveAccounts() {
        List<Account> accounts = [SELECT Id FROM Account WHERE Approval_Stage__c = 'Pending' LIMIT 1];
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

       
        AccountApprovalController.submitForApproval(accountIds);

      
        List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :accountIds];
        System.assertNotEquals(0, workItems.size(), 'Work items should exist before approving');

        Test.startTest();
        AccountApprovalController.approveAccounts(accountIds);
        Test.stopTest();

        Account updatedAccount = [SELECT Approval_Stage__c FROM Account WHERE Id = :accountIds[0]];
        System.assertEquals('Approved', updatedAccount.Approval_Stage__c, 'Account should be approved');
    }

    @isTest
    static void testRejectAccounts() {
        List<Account> accounts = [SELECT Id FROM Account WHERE Approval_Stage__c = 'Pending' LIMIT 1];
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

      
        AccountApprovalController.submitForApproval(accountIds);

       
        List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :accountIds];
        System.assertNotEquals(0, workItems.size(), 'Work items should exist before rejecting');

        Test.startTest();
        AccountApprovalController.rejectAccounts(accountIds);
        Test.stopTest();

        Account updatedAccount = [SELECT Approval_Stage__c FROM Account WHERE Id = :accountIds[0]];
        System.assertEquals('Rejected', updatedAccount.Approval_Stage__c, 'Account should be rejected');
    }
}