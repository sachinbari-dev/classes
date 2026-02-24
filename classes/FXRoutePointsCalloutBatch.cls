public class FXRoutePointsCalloutBatch implements Database.Batchable<sObject>, Database.Stateful 
{
    public final String jsonString; 
    public FXRoutePointsCalloutBatch(String jsonPayload)   
    {       
        System.debug('<=========== Inside Constructor ========>');
        jsonString = jsonPayload;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {                  
        return Database.getQueryLocator('select Id,Name,Address_Name__c,Address_Details__c,Address_Code__c from FleetX_AddressBook__c limit 2');
    }
    
    public void execute(Database.BatchableContext BC, List<FleetX_AddressBook__c> scope)        
    {            
        List<FleetXPoints__c> fxpList = [select Id,Address_Name__c,Route_List__c from FleetXPoints__c];                 
        System.debug('<== fxpList Size :'+fxpList.size());
            Map<String,FleetXPoints__c> fpMap = new Map<String,FleetXPoints__c>();
            if(fxpList.size()>0)
            {
                for(FleetXPoints__c fp:fxpList)
                {
                    fpMap.put(fp.Address_Name__c,fp);
                }
            }
        System.debug('<== fpMap Size:'+fpMap.size());
        Map<String,Route_List__c> frMap = new Map<String,Route_List__c>();

        System.debug('<=========== Inside Execute Mehtod ========>');                            
        List<RouteList> AllRoutesList = (List<RouteList>)JSON.deserialize(jsonString, List<RouteList>.Class);        
        System.debug('Total Routes Found :'+AllRoutesList.size()); 

        if(AllRoutesList!=null)
        {
            Map<String,Route_List__c> RouteListMap = new Map<String,Route_List__c>();                                      
            List<FleetXPoints__c> frpListtoInsert = new List<FleetXPoints__c>();
            List<FleetXPoints__c> frpListtoUpdate = new List<FleetXPoints__c>();
            List<Route_List__c> ExistingRouteList = [ select id,name from Route_List__c limit 10000];

            System.debug('<== ExistingRouteList :'+ExistingRouteList.size());
			if(ExistingRouteList.size()>0)            
            {
                for(Route_List__c isl: ExistingRouteList)
                {
					RouteListMap.put(isl.Name,isl);
                }                
            }

            for(RouteList singleRoute :AllRoutesList)
            { 
                System.debug('EACH ROUTE :'+singleRoute.name);
                Route_List__c rt = RouteListMap.get(singleRoute.name);               
                System.debug('Inserted Route :'+rt);
                if(rt!=null)
                {                    
                    for(fPoints fp:singleRoute.routePoints)
                    {
                        FleetXPoints__c oldFP = fpMap.get(fp.address);
                        System.debug('OLD Point Found :'+oldFP);
                       // System.debug('61 OLD oldFP.Route_List__c :'+oldFP.Route_List__c);
                        if(oldFP==null)
                        {  
                        	System.debug('NEW ADDRESS :'+fp.address);    
                            if(rt.Id!=null){
                                System.debug('6666 OLD Point Found :'+rt.Id);
                            }
                            FleetXPoints__c fjp = new FleetXPoints__c();
                            fjp.Address_Name__c=fp.address;
                            fjp.Latitude__c=fp.latitude;
                            fjp.Longitude__c=fp.longitude;  
                            fjp.Route_List__c=rt.Id;
                            frpListtoInsert.add(fjp); 
                        }
                        if(oldFP!=null)
                        {
                            System.debug('73 OLD oldFP.Route_List__c :'+oldFP.Route_List__c);
                            if(oldFP.Route_List__c==null && rt.Id!=null)
                            {
                               	oldFP.Route_List__c=rt.Id;
                            	frpListtoUpdate.add(oldFP); 
                            }
                            
                        }
                    }                   
                }

            } 
             System.debug('Total frpListtoInsert Size :'+frpListtoInsert.size());
            if(frpListtoInsert.size()>0)
            {
                System.debug('Records Size :'+frpListtoInsert.size());
                // insert frpListtoInsert;
                try
                {
                    Database.insert(frpListtoInsert, false);
                   // insert frpListtoInsert; 
                }catch(Exception e)
                {
                    System.debug('upsert frpListtoInsert ERROR MSG :'+e.getMessage());
                }
                
            }
            if(frpListtoUpdate.size()>0)
            {
                try{
                    Database.update(frpListtoUpdate, false);
                }catch(Exception e)
                {
                    System.debug('Update frpListtoUpdate ERROR MSG :'+e.getMessage());
                }
            }
        }
             
    }    
    public void finish(Database.BatchableContext bc)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :bc.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email,'imran.shaik@bvclogistics.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Apex FXRoutePointsCalloutBatch ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public class RouteList		// FleetX_Routes__c
    {
        public String id;	//230998
        public String name;	//ATQ 1
        /*
        public String enabled;
        public String distance;	//215.897
        public String allowEdit;
        public String createdDate;	//1606145902000
        public String lastModifiedDate;	//1686889127000
        public String createdBy;	//10783
        public String lastModifiedBy;	//1090475
        public String fetchAllRoutePoints;
        public String transitTime;	//0
        public String controllingBranchAllPoints;
        public String controllingBranchFirstLast;
        public String lane;  
        */
        Public List<fPoints> routePoints;
        Public clsGroup groups;
    }
    public class fPoints			// FleetXPoints__c
    {
        Public String Id;
        Public String address;
        Public String latitude;
        Public String longitude;
        /*
        Public String distance;
        Public String addressBookId;
        Public String transitTime;
        Public String radius;
        Public boolean reversePoint;
        Public boolean wayPoint; 
		*/
    }    
    class clsGroup 					// what object to map and store?
    {
        /*
        public Integer createdDate;	//1687251030000
        public Integer lastModifiedDate;	//1687251030000
        public Integer createdBy;	//5801
        public Integer lastModifiedBy;	//5801
        public Integer id;	//1269
        public String name;	//Amritsar - Punjab
        public Integer accountId;	//771
        public boolean enabled;
		*/
    } 

}