public class JobsUpdateDaily 
{
    
    @future(callout=true)
    public static void jobUpdateCallout()
    {
        Map<String,String> jobStatusMap = new Map<String,String>();
        Datetime dt = Datetime.now();
        Long l = dt.getTime();
        system.debug(l);
        String extension='listing?size=100&from='+l+'&sort=startDate,desc';
        // listing?size=100&from=1570861614000&sort=startDate,desc
        Fleet_Integration__mdt FI = [select Id,Label,endpoint_url__c,extension__c,password__c,username__c,method__c
                                     from Fleet_Integration__mdt where Label=:'FleetXUpdate' limit 1];
        System.debug('11 Line FI:'+FI);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        String EndPoint = FI.endpoint_url__c+extension; //+JsonString;
        String acToken = FI.username__c+' '+FI.password__c;
        System.debug('EndPoint :'+EndPoint);
        req.setEndpoint(EndPoint);
        req.setMethod(FI.method__c);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' +FI.password__c);
        System.debug('Line No 21 JsonString req:'+req);
        try
        {
            System.debug('24 Sending req :'+req);
            HttpResponse response = http.send(req);
            if(response.getStatusCode()==200 || response.getStatusCode()==201)
            {
                String responseBody = response.getBody(); 
                System.debug('29 responseBody :'+responseBody+'\n response.getStatusCode() :'+response.getStatusCode());
                updateWrapper uw = (updateWrapper) JSON.deserialize(responseBody, updateWrapper.class);

                for(integer i=0;i<uw.Content.size();i++)
                {
                    jobStatusMap.put(uw.Content[i].name,uw.Content[i].status);
                }							
                System.debug('jobStatusMap.keySet() :'+jobStatusMap.keySet());
                if(jobStatusMap.size()>0)
                {
                    List<FleetXJob__c> jobListToUpdate = new List<FleetXJob__c>();
                    List<FleetXJob__c> fjobList = [select Id,Name,jobName__c,Job_Status__c from FleetXJob__c where jobName__c IN :jobStatusMap.keySet()];
                    if(fjobList.size()>0)
                    {
                        for(FleetXJob__c fj:fjobList)
                        {
                            if(jobStatusMap.containsKey(fj.jobName__c))
                            {
                                fj.Job_Status__c=jobStatusMap.get(fj.jobName__c);
                                jobListToUpdate.add(fj);
                            }
                            System.debug('------------------------------------ ');
                        }
                        
                        if(jobListToUpdate.size()>0)
                        {
                            update jobListToUpdate;
                        }
                    }
                }
            }
            else
            {
                System.debug('HTTP Error: ' + response.getStatusCode() + ' ' + response.getStatus());               
            }
        }
        catch(Exception e)
        {
            System.debug('Callout Exception :'+e.getMessage());
        }
    }
public class updateWrapper
{
    public Integer totalElements;
    public List<ContentWrap> Content;
    
} 
 public class ContentWrap
 {
     public Integer Id;
     public String name;
     public String status;
     public String startDate;    
 }

}