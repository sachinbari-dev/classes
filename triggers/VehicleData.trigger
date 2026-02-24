trigger VehicleData on Vehicle_Data__c (before update,before insert) 
{
	if(trigger.isUpdate && trigger.isBefore)
    {
        for(Vehicle_Data__c vd : trigger.new)
        {
            if(vd.End_KM__c==null || vd.End_KM__c=='')
            {
                vd.End_KM__c='0';
            }
            if(vd.Start_KM__c==null || vd.Start_KM__c=='')
            {
                vd.Start_KM__c='0';
            }  
           Integer startKms = Integer.valueOf(vd.Start_KM__c);  
           Integer endKms = Integer.valueOf(vd.End_KM__c)>0?Integer.valueOf(vd.End_KM__c):0;   
            if(vd.Mode__c=='End' && endKms < startKms)
            {
              vd.addError('Start KM Must be Less Than End KM');
            }
            if(vd.Mode__c=='Start')
            {
                vd.End_KM__c='0';
            }            
        }
    }

    if(trigger.isInsert && trigger.isBefore)
    {
        for(Vehicle_Data__c vd : trigger.new)
        {
            if(vd.End_KM__c==null || vd.End_KM__c=='')
            {
                vd.End_KM__c='0';
            }
            if(vd.Start_KM__c==null || vd.Start_KM__c=='')
            {
                vd.Start_KM__c='0';
            }
            if((vd.End_KM__c==null || vd.End_KM__c=='') && vd.Mode__c=='Start')
            {
                vd.End_KM__c='0';
            }
            if((vd.End_KM__c==null || vd.End_KM__c=='') && vd.Mode__c!='Start')
            {
                vd.addError('Start KM Must be Greater Than End KM');
            }            
        }
    }
    
}