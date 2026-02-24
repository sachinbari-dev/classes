trigger vehicleTrigger on Transport__c(after update) 
{
  if(trigger.isUpdate && trigger.isAfter)
    {
       SmartTrackingVehicleDeallocation.deallocation(trigger.new,trigger.oldMap);       
    }  
}