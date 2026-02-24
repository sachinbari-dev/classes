public class FleetXjobCancelCallout {
    @AuraEnabled
    public static String makeCallout(String recId)
    {
        jobCancelCallout(recId);
        FleetXJob__c job = [select Id, Job_Creation_Failed__c, Job_created_success__c, Job_Status__c, Job_Id__c from FleetXJob__c where Id = :recId limit 1];
        System.debug('7 message:'+job.Job_Status__c);
        return job.Job_Status__c;
    }
    @future(callout=true)
    public static void jobCancelCallout(String recordId)
    {
        FleetXJob__c job = [select Id, Job_Creation_Failed__c, Job_created_success__c, Job_Status__c, Job_Id__c from FleetXJob__c where Id = :recordId limit 1];
        Fleet_Integration__mdt FI = new Fleet_Integration__mdt();

        FI = [select Id, Label, endpoint_url__c, extension__c, password__c, username__c from Fleet_Integration__mdt where Label = 'Job Cancel' limit 1];
        System.debug('11 Line FI: ' + FI);

        if (job.Job_Id__c != null)
        {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String EndPoint = FI.endpoint_url__c + FI.extension__c; 
            String acToken = FI.username__c + ' ' + FI.password__c;
            System.debug('EndPoint: ' + EndPoint);
            System.debug('26 acToken: ' + acToken);
            req.setEndpoint(EndPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Authorization', 'Bearer ' + FI.password__c);
            
            // Convert Decimal jobId to String and set the request body
            String jobIdStr = String.valueOf(job.Job_Id__c);
            String requestBody = 'jobId=' + EncodingUtil.urlEncode(jobIdStr, 'UTF-8');
            req.setBody(requestBody);

            System.debug('Line No 35 JsonString req: ' + req);

            try
            {
                System.debug('Sending req: ' + req);
                HttpResponse response = http.send(req);
                System.debug('31 response.getStatusCode(): ' + response.getStatusCode());
                if (response.getStatusCode() == 200 || response.getStatusCode() == 201)
                {
                    String responseBody = response.getBody(); 
                    System.debug('responseBody: ' + responseBody + '\n response.getStatusCode(): ' + response.getStatusCode());
                    job.Job_Status__c = 'Cancelled';
                    update job;
                }
                else
                {
                    System.debug('HTTP Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                    System.debug('Response body: ' + response.getBody());
                }
            }
            catch (Exception e)
            {
                System.debug('47 Callout Exception: ' + e.getMessage());
            }
            
        }
    }      
}