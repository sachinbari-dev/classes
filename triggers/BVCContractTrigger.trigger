/**********************************************************
 * Created By : Shaik Imran
 * Created Date:19-08-2024
 * Purpose: send Contract Annexure File Email
**********************************************************************/
trigger BVCContractTrigger on BVC_Contract__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        BVCContractTriggerHandler.handleContractEmails(Trigger.new, Trigger.oldMap);
    }
}