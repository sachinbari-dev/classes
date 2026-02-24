public class ServiceInsuranceMasterTriggerHelper 
{
	public static void AfterUpdate(Map<Id,Service_Insurance_Master__c> oldMap, List<Service_Insurance_Master__c> recList)
    {
        for(Service_Insurance_Master__c sim : recList)
        {
            String InsuranceBy='BVC';
            if(sim.End_Date__c!=null && sim.Start_Date__c!=null)
            {
                
                if(sim.End_Date__c>=Date.today())
                {
                   InsuranceBy = 'Customer' ;
                }
            }
            sim.Insurance_By__c = InsuranceBy;
        }
    }
}