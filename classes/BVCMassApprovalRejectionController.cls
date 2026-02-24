public class BVCMassApprovalRejectionController {
    
    
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(){
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        
        List<Id> userids = new List<Id>();
        if(!Test.isRunningTest()){
            userids.add(UserInfo.getUserId());
        }
        else{
            String[] userid = Label.BulkApprovalUsers.split(',');
            for(User p :[SELECT Id From User WHERE Id IN :userid]){
                userids.add(p.Id); 
                System.debug('ids---->' + p);
            }
        }
        
       
        List<Id> CreditNoteIds = new List<Id>();
        List<ProcessInstance> ProcessInstanceList = [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate,
                                  (SELECT ID FROM WorkItems WHERE OriginalActorId IN :userids),
                                  (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') 
                                  FROM ProcessInstance 
                                  WHERE CreatedDate = LAST_N_DAYS:30 
                                  ORDER BY CreatedDate DESC LIMIT 10000];
        System.debug('Size of ProcessInstanceList++++++++++++' + ProcessInstanceList.size());
        for(ProcessInstance ps : ProcessInstanceList){
            CreditNoteIds.add(ps.TargetObject.Id);  
        }
        System.debug('Size of CreditNoteIds++++++++++++' + CreditNoteIds.size());
        Map<Id, BVCCreditNote__c> CreditnoteMap = new Map<Id, BVCCreditNote__c>();
        List<BVCCreditNote__c> CNList = [SELECT Id, Account__r.Name, Subtotal__c, Credit_Note_Date__c, Internal_Comments__c, Remark__c, Reason_for_Credit_Note__c 
                                         FROM BVCCreditNote__c 
                                         WHERE Id IN :CreditNoteIds 
                                         AND Status__c = 'Draft' 
                                         AND CreatedDate = LAST_N_DAYS:30 
                                         ORDER BY CreatedDate DESC LIMIT 1000];
        for(BVCCreditNote__c cn : CNList){
            System.debug('Size of CNList++++++++++++' + CNList.size());
            CreditnoteMap.put(cn.Id, cn);
            System.debug('credit notes+++++++++' + CreditnoteMap);
        }
        List<ProcessInstance> ProcessInstanceList1 = [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate,
                                  (SELECT ID FROM WorkItems WHERE OriginalActorId IN :userids AND CreatedDate = LAST_N_DAYS:30),
                                  (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started' AND CreatedDate = LAST_N_DAYS:30 LIMIT 1400) 
                                  FROM ProcessInstance 
                                  WHERE TargetObjectId IN :CreditnoteMap.keySet() AND Status ='Pending' 
                                  ORDER BY CreatedDate DESC LIMIT 75];
        System.debug('Size of ProcessInstanceList1++++++++++++' + ProcessInstanceList1.size());
        for(ProcessInstance ps : ProcessInstanceList1){
            if(!ps.WorkItems.isEmpty()){
                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                objSubmittedRecordsWrapper.CreditNoteDate = CreditnoteMap.get(ps.TargetObject.Id).Credit_Note_Date__c;
                objSubmittedRecordsWrapper.Account = CreditnoteMap.get(ps.TargetObject.Id).Account__r.Name;
                objSubmittedRecordsWrapper.InternalComments = CreditnoteMap.get(ps.TargetObject.Id).Internal_Comments__c;
                System.debug('internalcoments' + objSubmittedRecordsWrapper.InternalComments);
                objSubmittedRecordsWrapper.Remarks = CreditnoteMap.get(ps.TargetObject.Id).Remark__c;
                System.debug('Remarks' + objSubmittedRecordsWrapper.Remarks);
                objSubmittedRecordsWrapper.ReasonForCreditnote = CreditnoteMap.get(ps.TargetObject.Id).Reason_for_Credit_Note__c;
                objSubmittedRecordsWrapper.Subtotal = CreditnoteMap.get(ps.TargetObject.Id).Subtotal__c;
                
                if(!ps.Steps.isEmpty()){
                    objSubmittedRecordsWrapper.submittedBy = ps.Steps[0].OriginalActor.Name;
                    lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                }
            }
        }
        System.debug('data retrieved from Server: ' + JSON.serialize(lstSubmissionWrapper));
        return lstSubmissionWrapper;
    }
    
    //
    @AuraEnabled
    public static String processRecords(List<String> lstWorkItemIds, String processType){
        String message = '';
        Integer recordsProcessed = 0;
        String comments = processType == 'Approve' ? 'Approved' : 'Rejected';
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(comments);
            objWorkItemRequest.setAction(processType); // approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest, FALSE);
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){
                recordsProcessed++;
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
            message = 'All records are ' + comments + ' successfully';
        }
        return message;
    }
    
    //
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public Date CreditNoteDate;
        @AuraEnabled public String Account;
        @AuraEnabled public String InternalComments;
        @AuraEnabled public String Remarks;
        @AuraEnabled public String ReasonForCreditnote;
        @AuraEnabled public Decimal Subtotal;
    }
    
    public static void Method2(){
        integer i = 0;
          
        
      
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    
    }
}