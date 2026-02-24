trigger BVCCreditNoteLineTrigger on BVCCredit_Note_Line__c (before insert,before Update) {

     if(trigger.isBefore && trigger.isInsert){
        BVCCreditNoteLineTriggerHandler.validateChargeHeadAmount(trigger.new);
         
       for(BVCCredit_Note_Line__c  ch :  Trigger.new){ 
           
                string validate = BVC_avoidDuplicateLineItemOnCreditnote.avoidDuplicateLineItem(trigger.new);
                if(validate != null){
                    ch.addError(validate);
                }
            }
         
    }
    if(trigger.isBefore && trigger.isUpdate){
         for(BVCCredit_Note_Line__c  ch :  Trigger.new){ 
           
                string validate = BVC_avoidDuplicateLineItemOnCreditnote.avoidDuplicateLineNumber(trigger.new);
                if(validate != null){
                    ch.addError(validate);
                }
            }
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        BVCCreditNoteLineTriggerHandler.validateChargeHeadAmount(trigger.new);
    }
    
}