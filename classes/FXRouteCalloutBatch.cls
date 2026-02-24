public class FXRouteCalloutBatch implements Database.Batchable<sObject>, Database.Stateful 
{
    public final String jsonString;  
    public FXRouteCalloutBatch(String jsonPayload)   
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
        List<String> TooLongRoutes = new List<String>();
        List<String> FR_Names = new List<String>();	// to store FleetXRoute Names                
        List<Route_List__c> routeListsToInsert = new List<Route_List__c>();          
        Map<String,Route_List__c> frMap = new Map<String,Route_List__c>();
        List<Route_List__c> routeListsExisting = [select Id,Name from Route_List__c limit 10000];
        System.debug('<== routeListsExisting :'+routeListsExisting.size());
        integer existingTotalRoutes=0,newTotalRoutes=0,ExistingTotalPoints=0,NewTotalPoints=0;
        if(routeListsExisting.size()>0)
        {
            existingTotalRoutes = routeListsExisting.size();
            for(Route_List__c fr:routeListsExisting)
            {
                frMap.put(fr.Name,fr);
            }
            // 
        }        
        System.debug('<== frMap Size :'+frMap.size());
        System.debug('<=========== Inside Execute Mehtod ========>');                            
        List<RouteList> AllRoutesList = (List<RouteList>)JSON.deserialize(jsonString, List<RouteList>.Class);        
        System.debug('Total Routes Found :'+AllRoutesList.size()); 
        
        for(RouteList singleRoute :AllRoutesList)
        {       
            System.debug('Route Name :'+singleRoute.name);
            if(singleRoute.name.length()<80)
            {
                Route_List__c oldRoute = frMap.get(singleRoute.name);
                System.debug('Old Route Name :'+oldRoute);
                if(oldRoute==null)
                {
                    System.debug('Found New Route :'+singleRoute.name);
                    Route_List__c rl = new Route_List__c();
                    rl.Name=singleRoute.name;
                    routeListsToInsert.add(rl);
                    FR_Names.add(singleRoute.name);                    
                }
                                 
            }
            else
            {
               TooLongRoutes.add(singleRoute.name); 
            }
        }
        System.debug('New Route Name Size :'+FR_Names.size());
        System.debug('New Route routeLists Size :'+routeListsToInsert.size());
        System.debug('TooLongRoutes Size :'+TooLongRoutes.size());
        if(routeListsToInsert.size()>0)
        {            
                try
                {
                    Database.insert(routeListsToInsert, false);
                   // insert routeListsToInsert; 
                }catch(Exception e)
                {
                    System.debug('FXRouteCalloutBatch ERROR MSG :'+e.getMessage());
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
        mail.setSubject('Apex FXRouteCalloutBatch ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Database.executeBatch(new FXRoutePointsCalloutBatch(jsonString),200);  // calling child Batch
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