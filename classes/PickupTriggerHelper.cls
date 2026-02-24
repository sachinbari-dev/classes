public class PickupTriggerHelper 
{
    public static void handlePickupCompleted(List<Pickup__c> pickupList, Map<Id,Pickup__c> oldMap) {
        String PickupName='';
    try {
        Set<Id> pkIdList = new Set<Id>();		
        for (Pickup__c pk : pickupList) {
            Pickup__c oldPk = oldMap.get(pk.Id);
            if (oldPk.Pickup_Status__c != pk.Pickup_Status__c && pk.Pickup_Status__c == 'Completed') { pkIdList.add(pk.Id); PickupName +=pk.Name;}
        }
        if(pkIdList.size()>0)
        { PickupTriggerHelperBatch batchExe = new PickupTriggerHelperBatch(pkIdList); Database.executeBatch(batchExe); }			 
    } catch (Exception e) { insert new Apex_Error_Log__c( Class_Name__c = 'PickupTriggerHelper - '+PickupName, Error__c = e.getMessage() ); }
}

}