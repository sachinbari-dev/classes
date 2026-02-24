public class FleetXAddressHelper 
{
    @AuraEnabled
    public static FleetXJob__c saveFleetxAddress(String DAddresses,
                                           String GMAddresses,
                                           String ESAddresses,
                                           List<String> Didlist,
                                           List<String> GMidlist,
                                           List<String> ESidlist,
                                           String vehicleNumber,                                            
                                           String CurrencyIsoCode, 
                                           String integrationstatus, 
                                           DateTime startDateTime,  
                                           Date lastModifiedDate,                                           
                                           String FleetX_RoutesName, 
                                           DateTime scheduleDeparture,
                                           DateTime scheduleArrival, 
                                           String FleetXJobID)
    {
        System.debug('Didlist :'+Didlist);
        String[] address     = DAddresses.split(';');  
        
        System.debug('<============== FJOB ==================>');
        System.debug('address : '+address);
        System.debug('DAddresses : '+DAddresses);
        System.debug('GMAddresses : '+GMAddresses);
        System.debug('ESAddresses : '+ESAddresses);
        System.debug('Didlist : '+Didlist);
        System.debug('GMidlist : '+GMidlist);
        System.debug('ESidlist : '+ESidlist);
        System.debug('vehicleNumber : '+vehicleNumber);
        System.debug('CurrencyIsoCode : '+CurrencyIsoCode);
        System.debug('integrationstatus : '+integrationstatus);        
        System.debug('startDateTime : '+startDateTime);
        System.debug('lastModifiedDate : '+lastModifiedDate);
        System.debug('FleetX_RoutesName : '+FleetX_RoutesName);
        System.debug('scheduleDeparture : '+scheduleDeparture);
        System.debug('scheduleArrival : '+scheduleArrival);
        System.debug('FleetXJobID : '+FleetXJobID);  
        FleetXJob__c fjob = new FleetXJob__c(); 
        try
        {
            fjob.vehicleNumber__c = vehicleNumber;
            fjob.CurrencyIsoCode = CurrencyIsoCode;
            fjob.integrationstatus__c = integrationstatus;
            fjob.startDateTime__c = Datetime.valueOf(startDateTime);
            fjob.lastModifiedDate__c = Date.valueOf(lastModifiedDate);
            fjob.FleetX_RoutesName__c =FleetX_RoutesName;
            fjob.scheduleDeparture__c = Datetime.valueOf(scheduleDeparture);
            fjob.scheduleArrival__c = Datetime.valueOf(scheduleArrival);
            if(FleetXJobID != null)
            {
              // fjob.FleetXJobID__c = Integer.valueOf(FleetXJobID);  
            }
            
            insert fjob;
            List<People_Jobs__c > PJList = new List<People_Jobs__c>();
            if(Didlist.size()>0 && fjob.id!=null)
            {
                for(String driver:Didlist)
                {
                    People_Jobs__c p = new People_Jobs__c();
                    p.FleetX_People__c=driver;
                    p.FleetXJob__c=fjob.Id;
                    p.User_Type__c='Driver';
                    PJList.add(p);
                }            
            }
            if(GMidlist.size()>0 && fjob.id!=null)
            {
                for(String gunmen:GMidlist)
                {
                    People_Jobs__c p = new People_Jobs__c();
                    p.FleetX_People__c=gunmen;
                    p.FleetXJob__c=fjob.Id;
                    p.User_Type__c='GunMen';
                    PJList.add(p);
                }            
            }
            
            if(ESidlist.size()>0 && fjob.id!=null)
            {
                for(String escorter:ESidlist)
                {
                    People_Jobs__c p = new People_Jobs__c();
                    p.FleetX_People__c=escorter;
                    p.FleetXJob__c=fjob.Id;
                    p.User_Type__c='Escorter';
                    PJList.add(p);
                }            
            }
            if(PJList.size()>0)
            {
                insert PJList;
            }            
        }
        catch(Exception e)
        {
            system.debug('Error Message :'+e.getMessage());
        }  
        System.debug('<=== fjob.Name :'+fjob.Name);
         FleetXJob__c fbb = new  FleetXJob__c();
        if(fjob.Id!=null)
        {
           fbb = [select Id,name from FleetXJob__c where Id=:fjob.Id limit 1];
        }
        
        System.debug('<=== fjob.Name :'+fbb.Name);
        return fbb;
    }    
}