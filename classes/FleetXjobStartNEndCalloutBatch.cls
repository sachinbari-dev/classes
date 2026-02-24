global class FleetXjobStartNEndCalloutBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public List<FleetXJob__c> jobsList = new List<FleetXJob__c>();
    global FleetXjobStartNEndCalloutBatch(List<FleetXJob__c> jobsList)
    {
        this.jobsList = jobsList;  
    }
    global Iterable<FleetXJob__c> start(Database.BatchableContext bc) 
    {
        return jobsList;
    }
    
    global void execute(Database.BatchableContext bc, List<FleetXJob__c> scope) {
        Fleet_Integration__mdt FI = [select Id,Label,endpoint_url__c,extension__c,password__c,username__c,method__c
                                     from Fleet_Integration__mdt where Label=:'JobStartEndCallout' limit 1];
        System.debug('17 FI:'+FI);
        
        if(FI!=null)
        {
            
            for (FleetXJob__c job : scope) {                
                try {
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    String EndPoint = FI.endpoint_url__c+FI.extension__c;
                    
                    String VehicleNumber = job.Vehicle_Number__r.Name;
                    String kmString = job.End_KM__c!=null?job.End_KM__c:job.Start_KM__c;
                    
                    String JsonPayload ='[{"vehicleNumber": "' + VehicleNumber + '", "odometer": "' + kmString + '"}]';
                    String acToken = FI.username__c+' '+FI.password__c;
                    System.debug('EndPoint :'+EndPoint);
                    System.debug('26 acToken :'+acToken);
                    req.setEndpoint(EndPoint);
                    req.setMethod(FI.method__c);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Authorization', 'Bearer ' +FI.password__c);
                    req.setBody(JsonPayload); 
                    System.debug('38 JsonPayload: '+JsonPayload);
                    System.debug('38 req: '+req);
                    // Send request
                    HttpResponse res = http.send(req);
					System.debug('38 res: '+res);
                    
                    if (res.getStatusCode() == 200) {
                       // System.debug('Success for Account: ' + acc.Id + ' | Response: ' + res.getBody());
                    } else {
                        Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'FleetXjobStartNEndCalloutBatch',Error__c=job.Name+' - '+res.getBody());
                        insert AEL;
                       // System.debug('Failed for Account: ' + acc.Id + ' | Status: ' + res.getStatus());
                    }
                    
                } catch (Exception e) {
                    System.debug('Error for Job: ' + job.Name + ' | ' + e.getMessage());
                    Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'FleetXjobStartNEndCalloutBatch',Error__c=job.Name+' - '+e.getMessage());
                    insert AEL;
                }
            }
            
            
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch completed.');
    }
}