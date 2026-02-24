trigger SmartTrackingTrigger on Smart_Tracking__c (after insert,after Update) {
	System.debug('Calling SmartTrackingTrigger');
    if(trigger.isInsert && trigger.isAfter)
    {
        SmartTracking.jsonContent(trigger.new);
        SmartTrackingHub.jsonContent(trigger.new);
        SmartTrackingVehicle.jsonContent(trigger.new);
        SmartTrackingTrunk.jsonContent(trigger.new);
      
    }
	if(trigger.isUpdate && trigger.isAfter)
    {
        SmartTracking.jsonContentAfterUpdate(trigger.new,trigger.oldMap); 
        SmartTrackingHub.jsonContentAfterUpdate(trigger.new,trigger.oldMap); 
        SmartTrackingVehicle.jsonContentAfterUpdate(trigger.new,trigger.oldMap);
        SmartTrackingTrunk.jsonContentAfterUpdate(trigger.new,trigger.oldMap);
        
    }
    

}