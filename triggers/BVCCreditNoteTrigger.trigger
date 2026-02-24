trigger BVCCreditNoteTrigger on BVCCreditNote__c (before insert, before update, after insert, after update) {
    
    // GST Based serial Number calculation
    if(Trigger.isBefore && Trigger.isInsert ){
        BVCCreditNoteTriggerHandler.updateEmailRecepients(trigger.new);
        BVCCreditNoteTriggerHandler.ValidateCreditAmountInsert(trigger.new);
        BVCCreditNoteTriggerHandler.updateRecordType(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate ){
        Boolean callSeriesUpdate = false;
        Set<Id> bvcCreditNotApprovedIds = new Set<Id>();
        BVCCreditNoteTriggerHandler.ValidateCreditAmount(trigger.new,trigger.oldMap);
        BVCCreditNoteTriggerHandler.amountsInWordConversion(trigger.new,trigger.oldMap); 
        /*
        //Old code for credit note serial number generation.
        for(BVCCreditNote__c bvCreditNote : trigger.new){
            if(bvCreditNote.Approval_Status__c == 'Approved'){
                bvcCreditNotApprovedIds.add(bvCreditNote.Id);
            }
        }
        if(bvcCreditNotApprovedIds.size()>0){
            BVCCreditNoteTriggerHandler.gstSerialNumberUpdate(trigger.new);                
        }
        */
        
        
        // Added by Rafi Khan - from here credit note serial numbers has been generated for CB credit note as like existing flow.
        for(BVCCreditNote__c bvCreditNote : trigger.new){
            System.debug('for checking Inside loop');
            System.debug('for checking bvCreditNote.BVC_CB_Is_CB_CreditNote_c__c '+bvCreditNote.BVC_CB_Is_CB_CreditNote_c__c);
            
            if (bvCreditNote.BVC_CB_Is_CB_CreditNote_c__c == true && bvCreditNote.Approval_Status__c == 'Approved'
                && (bvCreditNote.CreditNote_Serial_No__c == null || String.isBlank(bvCreditNote.CreditNote_Serial_No__c))) {
                    callSeriesUpdate = true;
                    break;
                }
            
        }
        
        if (callSeriesUpdate) {
            BVCCreditNoteTriggerHandler.gstSerialNumberUpdate(Trigger.new);
            UtilClass.recursionCheck = true;
        }
		
		
        
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        //Added by Rafi Khan to generate series for non-CB credit notes without custom setting works only on insert
        Map<Id, BVCCreditNote__c> oldMap = Trigger.oldMap;
        Map<Id, BVCCreditNote__c> cnMap = new Map<Id, BVCCreditNote__c>(
            [SELECT Id, BVC_CB_Is_CB_CreditNote_c__c,CreditNote_Serial_No__c, Credit_Note_Type__c, BVC_LegalEntity__c, BVC_Legal_Entities__c,
             BVC_LegalEntity__r.GSTIN_State_Code__c, BVC_LegalEntity__r.Billing_Serial_Number__c, 
             BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c, Approval_Status__c, createdDate
             FROM BVCCreditNote__c
             WHERE Id IN :Trigger.newMap.keySet()]);
        
        System.debug('for checking credit note values == '+cnMap.values());
        
        List<BVCCreditNote__c> listToProcess = new List<BVCCreditNote__c>();
        for (BVCCreditNote__c cn : cnMap.values()) {
            System.debug('for checking inside loop');
            BVCCreditNote__c oldCn = oldMap != null ? oldMap.get(cn.Id) : null;
            System.debug('for checking inside loop UtilClass.recursionCheck =='+UtilClass.recursionCheck);
            System.debug('for checking inside loop cn.BVC_CB_Is_CB_CreditNote_c__c = '+cn.BVC_CB_Is_CB_CreditNote_c__c );
            System.debug('for checking inside loop cn.BVC_LegalEntity__c = '+cn.BVC_LegalEntity__c);
            System.debug('for checking inside loop cn.CreditNote_Serial_No__c = '+cn.CreditNote_Serial_No__c);
            System.debug('for checking inside loop cn.Approval_Status__c ='+cn.Approval_Status__c);
            System.debug('for checking inside loop oldCn.Approval_Status__c ='+oldCn.Approval_Status__c);
            if (cn.BVC_CB_Is_CB_CreditNote_c__c == false && (cn.BVC_LegalEntity__c != null)
                && (cn.CreditNote_Serial_No__c == null || String.isBlank(cn.CreditNote_Serial_No__c)) && cn.Approval_Status__c == 'Approved' 
                && (oldCn.Approval_Status__c != 'Approved')
               ) {
                   listToProcess.add(cn);
               }
        }
        if (listToProcess.size() > 0) {
            BVCCreditNoteTriggerHandler.gstSerialNumberUpdate(listToProcess);
        }
        //UtilClass.recursionCheck = true;
        
        //upto here
        
        
        BVCCreditNoteTriggerHandler.callEYTaxCal(trigger.new,trigger.oldMap);
        BVCCreditNoteTriggerHandler.generateDocument(trigger.new,trigger.oldMap);
        
    }

}