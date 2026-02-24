public class PickupControlShips 
{
 @AuraEnabled
    public static List<Shipment__c> getShipementList(String recordId)
    {
        System.debug('recordId :'+recordId);
        List<Shipment__c> shipList = [ select Id,Name,Shipping_Note_Number__c,Number_of_Secure_Bags__c from Shipment__c where Pickup__c =:recordId and Number_of_Secure_Bags__c=0];       
		System.debug('shipList :'+shipList);
        return shipList;
    }
    
 @AuraEnabled
    public static String updateShipementList(String recordId)
    {
        String res;
        Shipment__c sh =[ select Id,Name,Shipping_Note_Number__c,Number_of_Secure_Bags__c,Pickup__c from Shipment__c where Id =:recordId limit 1];       
        if(sh!=null)
        {
            res=sh.Name;
            sh.Pickup__c=null;
            update sh;            
        }
            return res;
    } 
    
}