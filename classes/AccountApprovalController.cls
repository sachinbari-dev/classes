/*Class      : AccountApprovalController
 *Author     : Sanket Pisal
 *Date       : Apr 2025
 */
public with sharing class AccountApprovalController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getPendingApprovals() {
        List<Account> accounts = [
            SELECT Id, Name, Owner_Change__r.FirstName,Owner_Change__r.LastName, Owner.Name, LastModifiedBy.Name,Customer_Owner__c
            FROM Account
            WHERE Owner_Change__c != NULL AND Approval_Stage__c ='Pending'
        ];
        System.debug('Retrieved Accounts for Approval: ' + accounts);
        return accounts;
    }

    @AuraEnabled
    public static void submitForApproval(List<Id> accountIds) {
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();

        for (Id accountId : accountIds) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(accountId);
            approvalRequests.add(req);
        }

        if (!approvalRequests.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(approvalRequests);
            for (Approval.ProcessResult result : results) {
                if (!result.isSuccess()) {
                    throw new AuraHandledException('Failed to submit for approval: ' + result.getErrors().get(0).getMessage());
                }
            }
        }
    }

    @AuraEnabled
    public static void approveAccounts(List<Id> accountIds) {
        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accountId : accountIds) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :accountId];
            for (ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Approve');
                req.setWorkitemId(workItem.Id);
                approvalRequests.add(req);
            }
        }

        if (!approvalRequests.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(approvalRequests);
            for (Approval.ProcessResult result : results) {
                if (!result.isSuccess()) {
                    throw new AuraHandledException('Failed to approve: ' + result.getErrors().get(0).getMessage());
                } else {
                    Id approvedRecordId = result.getInstanceId();
                    ProcessInstance instance = [SELECT TargetObjectId FROM ProcessInstance WHERE Id = :approvedRecordId];
                    accountsToUpdate.add(new Account(Id = instance.TargetObjectId));
                }
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    @AuraEnabled
    public static void rejectAccounts(List<Id> accountIds) {
        List<Approval.ProcessWorkitemRequest> rejectionRequests = new List<Approval.ProcessWorkitemRequest>();

        for (Id accountId : accountIds) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :accountId];
            for (ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Reject');
                req.setWorkitemId(workItem.Id);
                rejectionRequests.add(req);
            }
        }

        if (!rejectionRequests.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(rejectionRequests);
            for (Approval.ProcessResult result : results) {
                if (!result.isSuccess()) {
                    throw new AuraHandledException('Failed to reject: ' + result.getErrors().get(0).getMessage());
                }
            }
        }
    }
}