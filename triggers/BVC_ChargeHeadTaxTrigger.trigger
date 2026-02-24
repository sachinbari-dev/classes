trigger BVC_ChargeHeadTaxTrigger on BVC_Charge_Head_Tax__c (after insert,before insert,before update, after update) {

     if(trigger.isBefore && trigger.isInsert){
      BVC_ChargeHeadTaxTriggerHandler.chargeHeadCode(trigger.new);  
    }
    if(trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
           
            
            /*
            for(BVC_Charge_Head_Tax__c  ch :  Trigger.new){  
               
                string validate = BVC_preventDuplicateChargeHeadRecord.avoidDuplicateChaergeHead(trigger.new);
                if(validate != null){
                    ch.addError(validate);
                }
            }   */
            
        }
    }
    
   if(trigger.isAfter && trigger.isInsert){
        BVC_ChargeHeadTaxTriggerHandler.invoiceTaxCalculator(trigger.new);
        
       // ChargeHeadTaxTriggerHandler.invoiceTaxCalculator(trigger.new);
    }
    
   
}