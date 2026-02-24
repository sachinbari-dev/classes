@isTest
private class BVCMassApprovalRejectionControllerTest {
    
    @testSetup
    static void setup() {
        // Setting up a test Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.PAN_Number_of_Entity__c = 'djzst12345';
        acc.Name_As_Per_PAN_Manual_Input__c = 'Test PAN Number';
        insert acc;
        
        
        BVCCreditNote__c creditNote = new BVCCreditNote__c();
        creditNote.Account__c = acc.Id;
        creditNote.Credit_Note_Date__c = Date.today();
        creditNote.Internal_Comments__c = 'No Comments';
        creditNote.Remark__c = 'No Remark';
        creditNote.Reason_for_Credit_Note__c = 'ACR Billing';
        creditNote.Status__c = 'Draft';
        creditNote.Approval_reason__c='ACR Invoice Cancellation';
        
        insert creditNote;
    }
    
    @isTest
    private static void testMethod1() {
       
        Test.startTest();
        
       
        BVCMassApprovalRejectionController.Method2();
        
       
        BVCCreditNote__c creditNote = [SELECT Id, Account__r.Name, Credit_Note_Date__c, Internal_Comments__c, Remark__c, Reason_for_Credit_Note__c 
                                       FROM BVCCreditNote__c 
                                       WHERE Reason_for_Credit_Note__c = 'ACR Billing' LIMIT 1];
        
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(creditNote.Id);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setSkipEntryCriteria(true);
      //  Approval.ProcessResult result = Approval.process(req1);
        
       
       // List<ProcessInstance> p = [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :creditNote.Id];
       // List<ProcessInstanceWorkItem> pw = [SELECT Id, ProcessInstanceId, OriginalActorId FROM ProcessInstanceWorkItem WHERE ProcessInstanceId = :p[0].Id];
       // List<ProcessInstanceStep> ps = [SELECT Id, ProcessInstanceId, OriginalActorId, StepStatus FROM ProcessInstanceStep WHERE ProcessInstanceId = :p[0].Id];
        
        //System.debug('Process Instances: ' + p);
        //System.debug('Process Work Items: ' + pw);
       // System.debug('Process Steps: ' + ps);
        
        
        //List<String> lstWorkItemIds = new List<String>();
       // lstWorkItemIds.add(pw[0].Id);
        
       
       // List<BVCMassApprovalRejectionController.SubmittedRecordsWrapper> submittedRecords = BVCMassApprovalRejectionController.getSubmittedRecords();
       // System.assertNotEquals(0, submittedRecords.size(), 'Submitted records should not be empty');
        
       
        //String approvalMessage = BVCMassApprovalRejectionController.processRecords(lstWorkItemIds, 'Approve');
       // System.assertEquals('All records are Approved successfully', approvalMessage, 'Approval message should match');
        
        Test.stopTest();
    }
}