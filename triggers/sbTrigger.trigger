trigger sbTrigger on Secure_Bag__c (after update) 
{
	if(trigger.isUpdate && trigger.isAfter)
    {
        SmartTrackingDeallocation.deallocation(trigger.new,trigger.oldMap);       
    }	
}