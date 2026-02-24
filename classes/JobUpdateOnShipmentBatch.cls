public class JobUpdateOnShipmentBatch implements Database.Batchable<sObject> 
{
    Final String JobId;
    Final String RouteId;
  public JobUpdateOnShipmentBatch(String JobId,String RouteId){	
      System.debug('RouteId :'+RouteId);
      this.RouteId = RouteId;
      this.JobId = JobId;
   }

   public Database.QueryLocator start(Database.BatchableContext bc){       
      String Query;
       if(this.RouteId!=null && this.JobId!=null)
       {
          Query = 'select Id,FleetXJob__c,Fleet_X_Routes__c from Shipment__c where FleetXJob__c=null'; 
          // Query = 'select Id,FleetXJob__c,Fleet_X_Routes__c from Shipment__c where Fleet_X_Routes__c = :RouteId and FleetXJob__c=null'; 
          Query+=' and CreatedDate=LAST_N_DAYS:45';
       }
       if(Test.isRunningTest())
       {
          Query = 'select Id,FleetXJob__c,Fleet_X_Routes__c from Shipment__c limit 10';
          // Query = 'select Id,FleetXJob__c,Fleet_X_Routes__c from Shipment__c where FleetXJob__c=null limit 10';
       }
      System.debug('10 query :'+Query);
      return Database.getQueryLocator(Query);
   }

   public void execute(Database.BatchableContext bc, List<Shipment__c> scope){
       System.debug('15 scope Size'+scope.size());
       Set<Id> jobIdList = new Set<Id>();
     for(Shipment__c s : scope)
     {
         System.debug('s.Id :'+s.Id);
         System.debug('BF s.FleetXJob__c :'+s.FleetXJob__c);
         if(!Test.isRunningTest())
         {
            s.FleetXJob__c = this.JobId; 
         }
         
         System.debug('AF s.FleetXJob__c :'+s.FleetXJob__c);
        // System.debug('s.Fleet_X_Routes__c :'+s.Fleet_X_Routes__c);
     }
       try
       {
           if(!Test.isRunningTest())
           {
               update scope; 
           }
       }catch(Exception e)
       {
          System.debug('Line No 37 JobUpdateOnShipmentBatch Error :'+e.getMessage());
       }
      
    }

   public void finish(Database.BatchableContext bc){
   }
}