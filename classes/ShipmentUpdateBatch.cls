/*
Created By 		: Imran
Created Date	: 21-12-2023
Version 1.0		: If Pickup Status Completed with Non OS Shipments without SB then Creating New Pickup and assign
*/
public class ShipmentUpdateBatch implements Database.Batchable<sObject>, Database.Stateful  
{
    List<Pickup__c> pickupList = new List<Pickup__c>();
    String newPickupId;
    String oldPickupId;
    public decimal test=0;
    public ShipmentUpdateBatch(List<ID> ids)
    {
        oldPickupId = ids[0];
        Pickup__c pk1 = [select Id,Shipment__c,Billing_Account__c,Billing_Address__c,
                         Customer__c,Shipper_Address__c,Shipper_Name__c 
                         from Pickup__c where Id=:ids[0] limit 1]; 
        
        Pickup__c pk = new Pickup__c();
        pk.Billing_Account__c=pk1.Billing_Account__c;
        pk.Billing_Address__c= pk1.Billing_Address__c;
        pk.Customer__c=pk1.Customer__c;
        pk.Pickup_Date__c= System.today();
        pk.Shipper_Address__c=pk1.Shipper_Address__c;
        pk.Shipper_Name__c=pk1.Shipper_Name__c;      
        pickupList.add(pk);                    
        Database.SaveResult[] srList = Database.insert(pickupList);                    
        for (Database.SaveResult sr : srList)
        {
            newPickupId = sr.getId();
            System.debug('New PickupId :'+newPickupId);
        }        
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'select Id,Pickup__c,Shipping_Note_Number__c,Number_of_Secure_Bags__c from Shipment__c where Pickup__c = \'' + oldPickupId + '\'';  // \'' + shipIds+ '\'
        System.debug('<===  queryString ====> :'+queryString);
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext BC, List<Shipment__c> ships){
        
        List<Shipment__c> ship_All_List = new List<shipment__c>();           
        for(Shipment__c s: ships)        
        {
            if(s.Shipping_Note_Number__c.startswith('OS') && s.Number_of_Secure_Bags__c==0)
            {
                s.Pickup__c = newPickupId;
                ship_All_List.add(s);                
            }
            
        }
        // update ship_All_List; 
        Database.SaveResult[] srList = database.update(ship_All_List);
        if(srList[0].isSuccess()){test=1;System.debug('<== test :'+test);}
    }
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('test :'+test);
        System.debug('newPickupId :'+newPickupId);        
        System.debug('oldPickupId :'+oldPickupId);
        if(test==1){
            Pickup__c newPickup = [select Id,Shipment__c from Pickup__c where Id=:newPickupId limit 1];
            Shipment__c newShip = [select Id from Shipment__c where Pickup__c=:newPickupId limit 1];
            System.debug('newPickup :'+newPickup);        
            System.debug('newPickup ShipId :'+newShip.Id);
            
            newPickup.Shipment__c = newShip.Id;
            // update newPickup; 
            Database.update(newPickup);            
        }
        
    }    
}