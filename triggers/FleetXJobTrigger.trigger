// new callout for Job when Job Creates with Start KM or updated with StartKM or updated with End KM having Vehicle Number
trigger FleetXJobTrigger on FleetXJob__c (after insert,after update) {
    if(trigger.isInsert && trigger.isAfter)
    {       
        try
        {
            FleetXJobTriggerHelper.calloutExternal(trigger.new,'POST');
        }
        catch(Exception e)
        { }
        
    }
    if(trigger.isUpdate && trigger.isAfter)
    {
        List<FleetXJob__c> updatedList = new List<FleetXJob__c>();
        List<String> jobIdList = new List<String>();  // V1.1
        for(FleetXJob__c fj:trigger.new)
        {
            FleetXJob__c oldFJ = trigger.oldMap.get(fj.Id);
            // V1.1 starts Here
            if(fj.Vehicle_Number__c!=null &&(oldFJ.Start_KM__c!=fj.Start_KM__c) || (oldFJ.End_KM__c!=fj.End_KM__c))
            {
                jobIdList.add(fj.Id);
            }
            // V1.1 ends Here
             if(fj.FleetX_Driver__c!=oldfj.FleetX_Driver__c || fj.Driver_2__c!=oldfj.Driver_2__c ||   fj.Loader_1__c!=oldfj.Loader_1__c || fj.Loader_2__c!=oldfj.Loader_2__c ||               fj.FleetX_Gunmen__c!=oldfj.FleetX_Gunmen__c || fj.Armed_Guard_2__c!=oldfj.Armed_Guard_2__c|| fj.Escorter__c!=oldfj.Escorter__c || fj.Escorter2__c!=oldfj.Escorter2__c)
             {
                 updatedList.add(fj);
             }            
        }
        System.debug('FleetXJobTrigger 27 updatedList :'+updatedList);      
		// V1.1 starts Here
		System.debug('FleetXJobTrigger 29 jobIdList :'+jobIdList);
        if(jobIdList.size()>0)
        {
       		FleetXjobStartNEndCallout.makeCalloutHelper(jobIdList);     
        }
        // V1.1 ends Here
        try
        {
            if(updatedList.size()>0)
            {
                FleetXJobTriggerHelper.calloutExternal(updatedList,'PUT');
            }            
        }
        catch(Exception e)
        { }       
    }    
}