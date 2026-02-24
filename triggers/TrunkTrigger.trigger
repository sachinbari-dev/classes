trigger TrunkTrigger on Secure_Packaging__c (after update) 
{
    if(trigger.isUpdate && trigger.isAfter)
    {
       SmartTrackingTrunkDeallocation.deallocation(trigger.new,trigger.oldMap);       
    }  
}