@RestResource(urlMapping='/updateFleetxJob/*')
global with sharing class FleetXJobUpdate {
@HttpPut
    global static String updateJob() {
        String statusMessage;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
         String jobId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		System.debug('8 jobId:'+jobId);
        // Parse the JSON request body
        String requestBody = req.requestBody.toString();
        System.debug('requestBody :'+requestBody);
        if(requestBody!=null && requestBody!='')
        {
            
            jobWrapper jw = (jobWrapper) JSON.deserialize(requestBody, jobWrapper.class);
            System.debug('JobName :'+jw.JobName);
            System.debug('Job Status :'+jw.Status);
            try
            {
                FleetXJob__c fjob = [select Id,Name,Job_Status__c from FleetXJob__c where Name=:jw.JobName limit 1];
                System.debug('fjob :'+fjob);
                if(fjob!=null && jw.Status!=null)
                {
                    fjob.Job_Status__c=jw.Status;
                    update fJob;
                    res.statusCode = 201; 
            		statusMessage ='Ok';
                }
                else
                {
                   res.statusCode = 300; 
            		statusMessage ='Job Not Found or status was not null'; 
                }
                
            }
            catch(Exception e)
            {
                res.statusCode = 300; 
            	statusMessage ='Job Not Found'; 
            }
        }
        else
        {
            res.statusCode = 300; 
            statusMessage ='ok, but need payload to update';
        }
            
        return statusMessage;
    }
    /*
    @HttpGet
    global static String testGet()
    {
        return 'sample test';
    }
    @HttpPost
    global static String testPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        System.debug('requestBody :'+requestBody);
        res.statusCode = 201;
        return 'sample test Post';
    }   
    */
public class jobWrapper
{
    public String JobName;
    public String Status;
}    
}