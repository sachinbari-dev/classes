global class FleetXjobCallout implements Database.Batchable<SObject>, Database.AllowsCallouts {
        public String JsonString;
    	public String JobId;
    	public String lineNo;
    	public String Method;
    	public List<FleetXJob__c> jobsList;
    	public List<String> jobIdList = new List<String>();
    
    global void jobCallout(String JsonString,String JobId,String lineNo,String Method)
    {
        this.JsonString = JsonString;
        this.JobId = JobId;
        this.lineNo = lineNo;
        this.Method = Method;
        this.jobIdList.add(JobId);
        jobsList = [select Id,Name,End_KM__c,Start_KM__c,Vehicle_Number__r.Name,Vehicle_Number__c
                                       from FleetXJob__c where Id IN : jobIdList];
    }
    global Iterable<FleetXJob__c> start(Database.BatchableContext bc) 
    {
        return jobsList;
    }
    
    global void execute(Database.BatchableContext bc, List<FleetXJob__c> scope) 
    {
        Fleet_Integration__mdt FI = new Fleet_Integration__mdt();
        System.debug('5 Line No:'+lineNo+'Method :'+Method);
        if(Method=='POST')
        {
            FI = [select Id,Label,endpoint_url__c,extension__c,password__c,username__c
                                     from Fleet_Integration__mdt where Label=:'Job Callout' limit 1];
            System.debug('11 Line FI:'+FI);
        }
        if(Method=='PUT')
        {
            FI = [select Id,Label,endpoint_url__c,extension__c,password__c,username__c
                                     from Fleet_Integration__mdt where Label=:'Job Callout_Put' limit 1];
            System.debug('17 Line FI:'+FI);
        }          
        if(FI!=null && JsonString!=null)
        {          
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String EndPoint = FI.endpoint_url__c+FI.extension__c; //+JsonString;
            String acToken = FI.username__c+' '+FI.password__c;
            System.debug('EndPoint :'+EndPoint);
            System.debug('26 acToken :'+acToken);
            req.setEndpoint(EndPoint);
            //req.setMethod('POST');
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            // req.setHeader('Authorization',acToken);
            req.setHeader('Authorization', 'Bearer ' +FI.password__c);
            System.debug('Line No 33 : JsonString :'+JsonString);
            req.setBody(JsonString);
            System.debug('Line No 35 JsonString req:'+req);
            FleetXJob__c job = [select Id,Name,Job_Creation_Failed__c,Job_created_success__c,Job_Status__c,
                                Job_Id__c from FleetXJob__c where Id=:JobId limit 1];
            try
            {
                System.debug('Sending req :'+req);
                HttpResponse response = http.send(req);
                System.debug('63 response.getStatus():'+response.getStatus());
                System.debug('63 response.getBody():'+response.getBody());
                System.debug('63 response.getStatusCode():'+response.getStatusCode());
                if(response.getStatusCode()==200 || response.getStatusCode()==201)
                {
                    String responseBody = response.getBody(); 
                    System.debug('responseBody :'+responseBody+'\n response.getStatusCode() :'+response.getStatusCode());
                    Object obj = JSON.deserializeUntyped(responseBody);
                    Map<String, Object> resp = (Map<String, Object>)obj;
                    System.debug('Id :'+resp.get('id'));
                    System.debug('JobName :'+(String)resp.get('name'));
                    System.debug('status :'+(String)resp.get('status'));
                    Object vehicleobj = JSON.deserializeUntyped(JSON.serialize(resp.get('vehicle')));
                    Map<String, Object> Vresp = (Map<String, Object>)vehicleobj;
                    System.debug('Vehicle Id :'+(String)Vresp.get('Id'));
                    System.debug('vehicle :'+JSON.serialize(resp.get('vehicle')));
                   // job.Job_Creation_Failed__c=false;
                    job.Job_created_success__c=true;
                    job.Job_Status__c=(String)resp.get('status');
                    job.Job_Id__c=(Integer)resp.get('id');                    
                }
                else
                {
                    System.debug('HTTP Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                    if(Method=='POST')
                    {
                        job.Job_Creation_Failed__c=true;
                    }
                    if(Method!='POST')
                    {
                        job.Job_created_success__c=true;
                        job.Job_Creation_Failed__c=false;
                    }
                    Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'FleetXjobCallout-'+Method,Error__c=job.Name+' - '+response.getStatusCode()+'-'+response.getBody());
                    insert AEL;                 
                }
            }
            catch(Exception e)
            {
                System.debug('94 Callout Exception :'+e.getMessage());
                if(Method=='POST')
                {
                    job.Job_Creation_Failed__c=true;
                    job.Job_created_success__c=false; 
                }   
                if(Method!='POST')
                {
                    job.Job_Creation_Failed__c=false;
                    job.Job_created_success__c=true; 
                } 
                Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'FleetXjobCallout -'+Method,Error__c=job.Name+' - '+e.getMessage());
                insert AEL;
            }
            update job;
        }        
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch completed.');
        if(jobIdList!=null && Method=='POST')
        {
       		FleetXjobStartNEndCallout.makeCalloutHelper(jobIdList);     
        }
    }
}