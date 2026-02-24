trigger ShipmentSLAMappingTrigger on Shipment__c (after insert) 
{
    if(trigger.isInsert && trigger.isAfter)
    {
        List<Shipment__c> shipList = new List<Shipment__c>(); 
        for(Shipment__c sh:trigger.new)
        {
            if(sh.Origin_Address_City__c!=null &&sh.Origin_Address_City__c!='' && 
               sh.Destination_Address_City__c!=null && sh.Destination_Address_City__c!='')
            {
                shipList.add(sh);
            }
        }
        if(shipList.size()>0)
        {
            ShipmentSlAMapping.getShipmentSla(shipList);
        }
    }
}