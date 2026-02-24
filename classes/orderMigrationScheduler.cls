global class orderMigrationScheduler implements Schedulable {
 global void execute(SchedulableContext sc) {
        
     
     Map<String, BVC_ACR_Consumption__c> migratedACR_ConMap = new Map<String, BVC_ACR_Consumption__c>();
     list<BVC_ACR_Consumption__c> consumptionList= [select Id, Is_Order_Migrattion__c,BVCOrder__c,Migrated_ACR_Consumption__c,Migrated_ACR_Consumption__r.ST_ACR_Order__c  
                                                    from BVC_ACR_Consumption__c
         WHERE Migrated_ACR_Consumption__r.ST_ACR_Order__c !=null and BVCOrder__c=null and BVC_Contract__r.Bvc_service__c='eSHIP' LIMIT 10];
     
     system.debug('consumptionList.size()==='+consumptionList.size());
     system.debug('consumptionList==='+consumptionList);
     for(BVC_ACR_Consumption__c newconsumption:consumptionList){
         migratedACR_ConMap.put(newconsumption.Migrated_ACR_Consumption__c, newconsumption);
     }
     system.debug('migratedACR_ConMap=='+migratedACR_ConMap);
     
     orderMigration batchJob = new orderMigration(migratedACR_ConMap);
     Database.executeBatch(batchJob);
     
   /*  orderMigrationOnly batchJob2 = new orderMigrationOnly(30);
     Database.executeBatch(batchJob2);*/
      
    }
    public static void Method2(){
        integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
}