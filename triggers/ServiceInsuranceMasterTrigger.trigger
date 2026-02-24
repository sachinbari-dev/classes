trigger ServiceInsuranceMasterTrigger on Service_Insurance_Master__c (before insert,before update) 
{
	if(trigger.isUpdate && trigger.isBefore)
    {
        List<Service_Insurance_Master__c> updatedList = new List<Service_Insurance_Master__c>();
        for(Service_Insurance_Master__c sim : trigger.new)
        {
           Service_Insurance_Master__c oldRec = trigger.oldMap.get(sim.Id);
            if(sim.End_Date__c!=oldRec.End_Date__c || sim.Start_Date__c!=oldRec.Start_Date__c)
            {
               if(!updatedList.contains(sim)) 
               {
                   updatedList.add(sim);
               }
            }
        }
        if(updatedList.size()>0)
        {
            ServiceInsuranceMasterTriggerHelper.AfterUpdate(trigger.OldMap,updatedList);
        }
    }
}