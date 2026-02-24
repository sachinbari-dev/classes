trigger ChargeHeadTaxTrigger on Charge_Head_Tax__c (after insert,before insert) {
    /*
    if(trigger.isBefore && trigger.isInsert){
     // ChargeHeadTaxTriggerHandler.chargeHeadCode(trigger.new);    
    }  /*
    /*
   if(trigger.isAfter && trigger.isInsert){
         SBQQ.TriggerControl.disable();
            try {
                 ChargeHeadTaxTriggerHandler.invoiceTaxCalculator(trigger.new);
            } finally {
            SBQQ.TriggerControl.enable();
            }
       // ChargeHeadTaxTriggerHandler.invoiceTaxCalculator(trigger.new);
    }  */
}