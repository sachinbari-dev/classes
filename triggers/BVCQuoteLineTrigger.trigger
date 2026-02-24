/* created by :imran
 * created date : 09-08-2024
 * version 1.0: calculating discounts 
 * last modified date : 09-08-2024
 * last Modified by : imran
 * version 1.0 :  
 */

trigger BVCQuoteLineTrigger on BVCQuoteLineItem__c (before insert, before update,after update) {
    
    if(trigger.isBefore && trigger.isInsert){
        BVCQuoteLineTriggerHandler.UpdateQuoteLineChargeFields(trigger.new);
        BVCQuoteLineTriggerHandler.quoteLineMaxDiscount(trigger.new,null);
    }

    if(trigger.isBefore && trigger.isUpdate) 
    {
        System.debug('Line no 10 BVCQuoteLineItem__c');
            BVCQuoteLineTriggerHandler.quoteLineMaxDiscount(trigger.new,trigger.oldMap);       
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        BVCQuoteLineTriggerHandler.updateBVCQuoteLineFields(trigger.new,trigger.oldMap);
    }
}