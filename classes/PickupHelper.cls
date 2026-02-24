/*
Created By 		: Imran
Created Date	: 21-12-2023
Version 1.0		: If Pickup Status Completed with Non OS Shipments without SB calling Batch Class to create new Pickup for that Shipments
 */
public class PickupHelper 
{
    @InvocableMethod(label='PickupHelper' description='update Shipments')
    public static void updateShipments(List<String> id) 
    {
        List<ID> ids = new List<ID>();
        ids.add(id[0]);
        System.debug('<==== PickupID ====> :'+ids[0]);
        ShipmentUpdateBatch sub = new ShipmentUpdateBatch(ids);
        Database.executeBatch(sub, 20);
    }
}