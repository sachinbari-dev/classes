public class ContactShipperHelper 
{
    @AuraEnabled
    public static List<Contact> getPeopleList(String pickupId)
    {
        Pickup__c pickup = [select Id,Shipper_Address__c from Pickup__c where Id=:pickupId limit 1];
        List<Contact> peopleList = new List<Contact>();
        if(pickup.Shipper_Address__c!=null)
        {
            peopleList = [select Id,Name,Email,Active_status__c from Contact where AddressBook__c=:pickup.Shipper_Address__c ];
            if(peopleList.size()>0)
            {
                for(Contact c: peopleList)
                {
                    System.debug('Name :'+c.Name);
                    System.debug('Email :'+c.Email);
                    System.debug('Active_status__c :'+c.Active_status__c);
                }
                
            }
        }
        return peopleList!=null?peopleList:null;
    }
    @AuraEnabled
    public static String updatePickup(String pickupId,String ContactId,String email)
    {
        String result='fail';
        Pickup__c pickup = [select Id,Shipper_Address__c,Shipper_Email__c,Shipper_Name1__c from Pickup__c where Id=:pickupId limit 1];
        if(pickup!=null)
        {
            pickup.Shipper_Email__c=email;
            pickup.Shipper_Name1__c=ContactId;
            update pickup;
            result='ok';
        }
        return result;
    }
}