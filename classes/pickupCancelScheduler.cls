global class pickupCancelScheduler implements Schedulable
{    
   global void execute(SchedulableContext sc) 
   {
      PickupCancelBatch b = new PickupCancelBatch(); 
      ID batchprocessid = Database.executeBatch(b,200);
   }
}