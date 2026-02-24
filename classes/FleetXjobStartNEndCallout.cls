public class FleetXjobStartNEndCallout {
    public static void makeCalloutHelper(List<String> jobIdList)
    {        
        List<FleetXJob__c> jobsList = [select Id,Name,End_KM__c,Start_KM__c,Vehicle_Number__r.Name,Vehicle_Number__c
                                       from FleetXJob__c where Id IN : jobIdList];
        try
        {
            FleetXjobStartNEndCalloutBatch batchJob = new FleetXjobStartNEndCalloutBatch(jobsList);
            Database.executeBatch(batchJob,50);  
        }catch(Exception e)
        { Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'FleetXjobStartNEndCallout',Error__c=e.getMessage()); insert AEL; }
        
    }
}