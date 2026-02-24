trigger hubTrigger on Hub__c (after update) 
{
	if(trigger.isUpdate && trigger.isAfter)
    {
       SmartTrackingHubDeallocation.deallocation(trigger.new,trigger.oldMap);       
    }	
}