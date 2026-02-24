public class ShipmentSlAMappingHelper 
{
    @InvocableMethod(label='ShipmentSlAMappingHelper')
    public static void ShipmentSlAMapping(List<ID> ids) 
    {
        System.debug('ShipmentSlAMappingHelper :'+ids);
        List<Shipment__c> shipList = [select Id,Origin_Address_City__c, Destination_Address_City__c,Physical_Pickup_Completed_Time__c
                                      from Shipment__c where Id IN : ids];
        List<Shipment__c> shipListToSend = new List<Shipment__c>(); 
        for(Shipment__c sh:shipList) {
            if(sh.Origin_Address_City__c!=null &&sh.Origin_Address_City__c!='' && 
               sh.Destination_Address_City__c!=null && sh.Destination_Address_City__c!='' 
               && sh.Physical_Pickup_Completed_Time__c!=null){
                   shipListToSend.add(sh);
               }
        }
        System.debug('16 shipListToSend :'+shipListToSend);
        if(shipListToSend.size()>0)
        {
            ShipmentSlAMapping.getShipmentSla(shipListToSend);
        }
    }
}