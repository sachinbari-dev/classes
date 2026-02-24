/*
 * 
 *  @Last Modified By 	: Imran Shaik
 *  @Last Modified date : 27-10-2025
 *  @Last Modified date : 04-11-2025 
 *  @Version   			: V1.1 Pickup Picked Up Status to In Progress when Shipment is Cretaed with Status = Created when Creation with Pickup
 *  @Version   			: V1.2 Update Pickup on Shipment then change Pickup PickupStatus to In Progress when Shipment Status = Created
 * 
 */
public class shipmentHelper 
{   
    public static void afterInsert(List<Shipment__c> shipList) 
    {
        List<String> pickupIdList = new List<String>();
        for(Shipment__c shipment : shipList)
        {
            if(shipment.Pickup__c!=null && shipment.Tracking_Status__c=='Created')
            {
                pickupIdList.add(shipment.Pickup__c);	
            }
        }
        if(pickupIdList.size()>0)
        {
            List<Pickup__c> pkList = [select Id,Pickup_Assigned_To__c from Pickup__c where Id IN :pickupIdList and Pickup_Assigned_To__c=null];
            Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>([select Id,Pickup_Status__c from Pickup__c where Id IN :pickupIdList ] );
            Boolean ischanged = false;
            if(pickupMap.size()>0)
            {
                for(Id pkId : pickupMap.keySet())
                {
					Pickup__c pickupRecord = pickupMap.get(pkId);
                    if(pickupRecord.Pickup_Status__c!='In Progress')
                    {
                        pickupRecord.Pickup_Status__c = 'In Progress';
                        ischanged=true;
                    }                    
                }
                try
                {
                    if(ischanged)
                    {
                        update pickupMap.values();
                    }
                }catch(Exception e){}
            }
        }        
    }

    public static void afterUpdate(List<Shipment__c> shipList, Map<Id,Shipment__c> OldMap)
    {
        List<String> pickupIdList = new List<String>();
        for(Shipment__c shipment : shipList)
        {
            Shipment__c oldShip = OldMap.get(shipment.Id);
            if(oldShip!=null && shipment.Tracking_Status__c=='Created')
            {
                if(shipment.Pickup__c!=null && oldShip.Pickup__c != shipment.Pickup__c)
                {
                    pickupIdList.add(shipment.Pickup__c);	
                }                
            }
        }
        if(pickupIdList.size()>0)
        {
            List<Pickup__c> pkList = [select Id,Pickup_Assigned_To__c from Pickup__c where Id IN :pickupIdList and Pickup_Assigned_To__c=null];
            Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>([select Id,Pickup_Status__c from Pickup__c where Id IN :pickupIdList ] );
            Boolean ischanged = false;
            if(pickupMap.size()>0)
            {
                for(Id pkId : pickupMap.keySet())
                {
					Pickup__c pickupRecord = pickupMap.get(pkId);
                    if(pickupRecord.Pickup_Status__c!='In Progress')
                    {
                        pickupRecord.Pickup_Status__c = 'In Progress';
                        ischanged=true;
                    }
                    
                }
                try
                {
                    if(ischanged)
                    {
                        update pickupMap.values();
                    }
                    
                }catch(Exception e){}
            }
        }        
    }
    
}