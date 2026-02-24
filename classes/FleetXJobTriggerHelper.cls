/*
 *  @author 			: Shaik Imran
 *  Created Date 		: May-1-2024
 *  Last Modified By 	: 06-06-2024
 *  usecase 			: after job creation job details with routes, route points
 * 						  preparing Json Payload and sending to callout Fleetx App
 * version v 1.0			: making callout
 * varsion v 1.2			: added extra payload to current payload
 * 
 */
public class FleetXJobTriggerHelper {
    public static void calloutExternal(List<FleetXJob__c> jobList,String method)
    {
        System.debug('Line 4 calloutExternal');
        List<String> fjIds = new List<String>();
        for(FleetXJob__c fjb: jobList)
        {
            fjIds.add(fjb.Id);
        }        
        List<FleetXJob__c> FJList = [select Id,Name,Vehicle_Number__c,Vehicle_Number__r.Name,FleetX_RouteName__c,FleetX_RouteName__r.Name,
                                     scheduleDeparture__c,FleetX_Gunmen__c,Escorter1__c,FleetX_Escorter__c,FleetX_Driver__c,
                                     Escorter1__r.MobilePhone,jobName__c,vehicleNumber__c,Escorter__c,
                                     Loader_1__c,Loader_1__r.People_phoneNumber__c,Start_KM__c,
                                    Escorter2__c,Escorter2__r.People_phoneNumber__c,
                                    Armed_Guard_2__c,Armed_Guard_2__r.People_phoneNumber__c,
                                    Driver_2__c,Driver_2__r.People_phoneNumber__c,
                                    Loader_2__c,Loader_2__r.People_phoneNumber__c,FleetX_Driver__r.Name,
                                     FleetX_Gunmen__r.People_phoneNumber__c,Escorter__r.People_phoneNumber__c,FleetX_Gunmen__r.People_userType__c,Escorter__r.People_userType__c,FleetX_Gunmen__r.FleetXPeopleID__c,
                                     FleetX_Escorter__r.People_phoneNumber__c,FleetX_Escorter__r.People_userType__c,FleetX_Escorter__r.FleetXPeopleID__c,Escorter__r.FleetXPeopleID__c,
                                     FleetX_Driver__r.People_phoneNumber__c,FleetX_Driver__r.People_userType__c,FleetX_Driver__r.FleetXPeopleID__c
                                     from FleetXJob__c where Id IN :fjIds];
        System.debug('33 FleetXJobTriggerHelper  FJList:'+FJList);
        Route_List__c R = new Route_List__c();
        List<FleetXPoints__c> points = new List<FleetXPoints__c>();
        String pointsJson='';       
        if(FJList[0].FleetX_RouteName__c!=null)
        {
            points = [select Id,Name,Address_Name__c,Latitude__c,Longitude__c
                      from FleetXPoints__c where Route_List__c=:FJList[0].FleetX_RouteName__c];
            R = [select Id,Name from Route_List__c where Id=:FJList[0].FleetX_RouteName__c limit 1];
            System.debug('42 FleetXJobTriggerHelper points:'+points);
            if(points.size()>0)
            {                 
                for(FleetXPoints__c p:points)
                {
                    pointsJson=pointsJson+'{';
                    String address = p.Address_Name__c.replaceAll('\\s', '');
                    pointsJson=pointsJson+'"address":"'+address+'",';  
                    pointsJson=pointsJson+'"latitude":'+p.Latitude__c+',';                   
                    pointsJson=pointsJson+'"longitude":'+p.Longitude__c+'},'; 
                }
                pointsJson = pointsJson.substring(0, pointsJson.length() - 1);
            }
        }

        String JsonString ='{';
        JsonString = JsonString +'"jobName":"'+FJList[0].jobName__c+'",';
        
        if(FJList[0].scheduleDeparture__c!=null)
        {
            DateTime utcDateTime = FJList[0].scheduleDeparture__c;
            TimeZone istTimeZone = TimeZone.getTimeZone('Asia/Kolkata');
            DateTime convertedISTDateTime = utcDateTime.addSeconds(istTimeZone.getOffset(utcDateTime) / 1000);
            System.debug('istDateTime :'+convertedISTDateTime); 
            JsonString = JsonString +'"startDateTime":"'+convertedISTDateTime+'",'; 
            
        }
        else
        {
           JsonString = JsonString +'"startDateTime":"'+FJList[0].scheduleDeparture__c+'",'; 
        }
        
        
        
        
        // JsonString = JsonString +'"vehicleNumber":"'+FJList[0].vehicleNumber__c+'",';		// Vehicle_Number__r.Name
        JsonString = JsonString +'"vehicleNumber":"'+FJList[0].Vehicle_Number__r.Name+'",';	// changed to new lookup
        
        JsonString = JsonString +'"routeName":"'+FJList[0].FleetX_RouteName__r.Name+'",'; // newly added Route Name
        if(FJList[0].Start_KM__c != null)
{
    JsonString = JsonString + '"openingOdo":' + FJList[0].Start_KM__c + ','; 
}

        // JsonString = JsonString +'"routeName":"'+FJList[0].FleetX_RouteName__r.Name+'",'; // newly added Route Name
        
        String usersJson ='';
        // adding FleetX_Escorter__c
        if(FJList[0].Escorter__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].Escorter__r.People_phoneNumber__c!=null)
            {
                String phone = FJList[0].Escorter__r.People_phoneNumber__c.remove('+91');
                usersJson = usersJson +phone;
            }
            else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"Escorter"';
          //  usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }
        // adding FleetX_Gunmen__c
        if(FJList[0].FleetX_Gunmen__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].FleetX_Gunmen__r.People_phoneNumber__c!=null)
            {
                usersJson = usersJson+FJList[0].FleetX_Gunmen__r.People_phoneNumber__c;
            }else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"Gunmen"';
           // usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }        
        // adding FleetX_Driver__c
        if(FJList[0].FleetX_Driver__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].FleetX_Driver__r.People_phoneNumber__c!=null)
            {
                usersJson = usersJson + FJList[0].FleetX_Driver__r.People_phoneNumber__c;
            }else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"'+FJList[0].FleetX_Driver__r.People_userType__c+'"';
           // usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }     
// --------------------------------------------  //
		// adding Loader
        if(FJList[0].Loader_1__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].Loader_1__r.People_phoneNumber__c!=null)
            {
                String phone = FJList[0].Loader_1__r.People_phoneNumber__c.remove('+91');
                usersJson = usersJson +phone;
            }
            else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"LOADER"';
          //  usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }
        // adding Escorter2
         if(FJList[0].Escorter2__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].Escorter2__r.People_phoneNumber__c!=null)
            {
                usersJson = usersJson + FJList[0].Escorter2__r.People_phoneNumber__c;
            }else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"Gunmen2"';
           // usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }
        // adding Gunmen2
        if(FJList[0].Armed_Guard_2__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].Armed_Guard_2__r.People_phoneNumber__c!=null)
            {
                usersJson = usersJson+FJList[0].Armed_Guard_2__r.People_phoneNumber__c;
            }else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"Escorter2"';
           // usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }        
        
         

        // adding Driver2
        if(FJList[0].Driver_2__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].Driver_2__r.People_phoneNumber__c!=null)
            {
                usersJson = usersJson+FJList[0].Driver_2__r.People_phoneNumber__c;
            }else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"DRIVER2"';
           // usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'},';    
        }        
        // adding Loader2
        if(FJList[0].Loader_2__c!=null)
        {
            usersJson = usersJson +'{"phoneNumber":';
            if(FJList[0].Loader_2__r.People_phoneNumber__c!=null)
            {
                usersJson = usersJson + FJList[0].Loader_2__r.People_phoneNumber__c;
            }else {usersJson = usersJson +0;}
            usersJson = usersJson +',"label":"LOADER2"';
           // usersJson = usersJson +',"userId":'+0;
            usersJson = usersJson +'}';    
        }         
// -------------------------------------------//  
      usersJson = usersJson.removeEnd(',');
        JsonString = JsonString +'"jobUsers": ['; 
        JsonString = JsonString + usersJson; 
        JsonString = JsonString +'],';

        // newly added on 05-06-2024 v1.2
        JsonString = JsonString +'"driverName":"'+FJList[0].FleetX_Driver__r.Name+'",'; 
        JsonString = JsonString +'"driverPhone":'+FJList[0].FleetX_Driver__r.People_phoneNumber__c+','; 
        // upto here        v1.2  
        
        /*
        JsonString = JsonString +'"points": ['; 
        JsonString = JsonString + pointsJson; 
        JsonString = JsonString +']}'; 
        
         System.debug('FINAL pointsJson :'+pointsJson);
        System.debug('FINAL JSON String :'+JsonString);
        System.debug('points Size :'+points.size());
        */
        if(points.size()>0 && FJList[0].Escorter__c!=null)
        {
            JsonString = JsonString +'"points": ['; 
            JsonString = JsonString + pointsJson; 
            JsonString = JsonString +']}'; 
            
            System.debug('194 FINAL pointsJson :'+pointsJson);
            System.debug('195 FINAL JSON String :'+JsonString);
            System.debug('196 points Size :'+points.size());            
            String JobId=FJList[0].Id;
            System.debug('198 MAKING CALLOUT method:'+method);
            // JsonString=JsonString.replaceAll('	-', '-');
            
           // FleetXjobCallout.jobCallout(JsonString,JobId,'200',method); 
            FleetXjobCallout fjc = new FleetXjobCallout();
            fjc.jobCallout(JsonString,JobId,'200',method);
            Database.executeBatch(fjc,50);
        }
        else
        {
            JsonString = JsonString +'"points": [ { "address": "", "latitude": 0, "longitude": 0 }]'; 
            JsonString = JsonString + pointsJson; 
            JsonString = JsonString +'}'; 
            
            System.debug('208 FINAL pointsJson :'+pointsJson);
            System.debug('209 FINAL JSON String :'+JsonString);
            System.debug('210 points Size :'+points.size());            
            String JobId=FJList[0].Id;
            System.debug('212 MAKING CALLOUT method:'+method);
            // JsonString=JsonString.replaceAll('	-', '-');
           // FleetXjobCallout.jobCallout(JsonString,JobId,'214',method); 
            FleetXjobCallout fjc = new FleetXjobCallout();
            fjc.jobCallout(JsonString,JobId,'200',method);
            Database.executeBatch(fjc,50);
        }
    }
    /*
    public static void jobCancelCallout(List<FleetXJob__c> jobList)
    {
        List<String> fjIds = new List<String>();
        for(FleetXJob__c fjb: jobList)
        {
            fjIds.add(fjb.Id);
        }
        List<FleetXJob__c> FJList = [select Id,Name,Job_Id__c from FleetXJob__c where Id IN :fjIds];
        if(FJList.size()>0)
        {
           for(FleetXJob__c fjpb:FJList) 
           {
               if(fjpb.Job_Id__c!=null)
               {
                  // FleetXjobCancelCallout.jobCancelCallout(String.valueOf(fjpb.Job_Id__c),fjpb.Id);
               }
           }
        }
    }
    */
}