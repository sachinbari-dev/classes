public class fleetxRouteHelper 
{
    /*
    @AuraEnabled
	public static List<FleetX_AddressBook__c> getAddresses(String sText)
    {
        String st='%'+sText+'%';
        System.debug('Text :'+st);
        List<FleetX_AddressBook__c> faList = [select Id,Name from FleetX_AddressBook__c where Name Like :st limit 5000];
        System.debug('Address Size :'+faList.size());
        if(faList.size()>0)
        {
            return faList;
        }
        else
        {
           return null; 
        }        
    }
    @AuraEnabled
	public static List<FleetX_AddressBook__c> getAllAddresses()
    {
        List<FleetX_AddressBook__c> faList = [select Id,Name from FleetX_AddressBook__c limit 5000];
        return faList;
    }
    */
    @AuraEnabled
	public static String saveFleetxAddress(String Name,String Addresses,List<String> idlist)
    {
        System.debug('Name :'+Name+' Addresses :'+Addresses);
        System.debug('idlist :'+idlist);
        FleetX_Routes__c fr = new FleetX_Routes__c();
        fr.routename__c =Name;
        //fr.FleetX_Address_Route__c = Addresses;
         fr.FleetX_Address_Route1__c = Addresses;
        insert fr;
        List<FleetX_AddressBook__c> faList = [select Id,Name,Address_Code__c,Address_Details__c from FleetX_AddressBook__c where Id IN :idlist];
		integer x=0;
        List<FleetXPoints__c> fjp = new List<FleetXPoints__c>();
        if(faList.size()>0)
        {
            for(FleetX_AddressBook__c fa : faList)
            {
                x=x+1;
                FleetXPoints__c single_fjp = new FleetXPoints__c();
                single_fjp.FleetX_Route__c=fr.Id;
                single_fjp.FleetX_AddressBook__c=fa.Id;
                single_fjp.address__c='Point - '+x+' : '+fa.Address_Details__c; 
                single_fjp.Address_Code__c = fa.Address_Code__c;
                fjp.add(single_fjp);
                System.debug('Id :'+fa.Id+' Name :'+fa.Name);
            }  
            insert fjp;
        }
		return fr.routename__c;
    }    
}