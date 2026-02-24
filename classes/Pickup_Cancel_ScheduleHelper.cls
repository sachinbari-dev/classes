public class Pickup_Cancel_ScheduleHelper 
{
  @InvocableMethod(label='Pickup_Cancel_ScheduleHelper' description='Cancel Pickups without Shipments.')
  public static void getPickups(List<String> ids) 
  {
     // Database.executeBatch(new PickupCancelBatch,200);
     // ID batchprocessid = Database.executeBatch(new PickupCancelBatch);
      /*
        List<Pickup__c> pickups = [SELECT id, Name, Pickup_Status__c, Pickup_Date__c, Created_Date__c, (select Id from Shipments__r) FROM Pickup__c WHERE CreatedDate <= YESTERDAY and Pickup_Status__c='Created' and Id not In (SELECT Pickup__c FROM Shipment__c)];
      List<Pickup__c> pickups1 = [SELECT Name,Pickup_Status__c,Created_Date__c,(select Id from Shipments__r) FROM Pickup__c WHERE CreatedDate <= YESTERDAY and Pickup_Status__c='Created'];
    List<Pickup__c> upList = new List<Pickup__c>();
      System.debug('Total Found :'+pickups.size());
    for (Pickup__c pk : pickups) 
    {
        if(pk.Shipments__r.size()==0)	// checking for id the Pickup Shipments size = 0
        { 
            System.debug('pk :'+pk.Name);
            System.debug('Ship Size :'+pk.Shipments__r.size());            
            pk.Pickup_Status__c='Cancelled';
            pk.Pickup_Date__c= pk.Created_Date__c;
            upList.add(pk);						// collecting the Pickups            
        }
    }
    for (Pickup__c pk : upList) 
    {
            System.debug('pk Name:'+pk.Name);
        	System.debug('pk Pickup_Status__c :'+pk.Pickup_Status__c);
    }
      System.debug('Found without Ships :'+upList.size());
      if(upList.size()>0)
      {
          System.debug('Before Update');
           update upList;
          System.debug('After Update');
      }
      */
  }
}