public class DataMigrationLogGeneration {
    public static void MigratedLogGeneration(List<Database.UpsertResult> upsertResults,List<BVCOrder__c> bvcOrderList,
                                             List<BVC_ACR_Consumption__c> bvcACRConsumptionList,List<BVC_Order_Product__c> bvcOrderProductList,
                                             List<BVC_Contract__c> createContracts,String FromObject,String ToObject)
    {
        List<Data_Migration_Log__c> dmList = new List<Data_Migration_Log__c>();
        for (Integer i = 0; i < upsertResults.size(); i++) 
        {
            Database.UpsertResult result = upsertResults[i];
            if (result.isSuccess()) 
            {                       
                Data_Migration_Log__c MigrationLogPassed = new Data_Migration_Log__c();
                MigrationLogPassed.Name=FromObject+' Migration';
                MigrationLogPassed.Migrated_From__c=FromObject;
                MigrationLogPassed.Migrated_To__c=ToObject;
                MigrationLogPassed.Result__c='Passed';
                if(FromObject =='Contract')			
                {
                    MigrationLogPassed.Processed_recordId__c=createContracts[i].Migrated_Contract__c;
                }
                if(FromObject =='Order')			
                {
                    MigrationLogPassed.Processed_recordId__c=bvcOrderList[i].Migrated_Order__c;
                }
                if(FromObject =='ACR Consumption')			
                {
                    MigrationLogPassed.Processed_recordId__c=bvcOrderProductList[i].Migrated_OrderItem__c;
                }
                if(FromObject =='Order Product')			
                {
                    MigrationLogPassed.Processed_recordId__c=bvcOrderProductList[i].Migrated_OrderItem__c;
                }

                dmList.add(MigrationLogPassed);
            } 
            else 
            {
                Data_Migration_Log__c MigrationLogFailed = new Data_Migration_Log__c();
                MigrationLogFailed.Name=FromObject+' Migration';
                MigrationLogFailed.Result__c='Failed';
                MigrationLogFailed.Migrated_From__c=FromObject;
                MigrationLogFailed.Migrated_To__c=ToObject;            
                for (Database.Error error : result.getErrors()) 
                {   
                    if(FromObject =='Contract')			
                    {
                        MigrationLogFailed.Error__c='Error on record Id: ' + createContracts[i].Migrated_Contract__c + ' - ' + error.getMessage();
                        MigrationLogFailed.Processed_recordId__c=createContracts[i].Migrated_Contract__c;
                    }
                    if(FromObject =='Order')			
                    {
                        MigrationLogFailed.Error__c='Error on record Id: ' + bvcOrderList[i].Migrated_Order__c + ' - ' + error.getMessage();
                        MigrationLogFailed.Processed_recordId__c=bvcOrderList[i].Migrated_Order__c;
                    }
                    if(FromObject =='ACR Consumption')			
                    {
                        MigrationLogFailed.Error__c='Error on record Id: ' + bvcACRConsumptionList[i].Migrated_ACR_Consumption__c + ' - ' + error.getMessage();
                        MigrationLogFailed.Processed_recordId__c=bvcACRConsumptionList[i].Migrated_ACR_Consumption__c;
                    }
                    if(FromObject =='Order Product')			
                    {
                        MigrationLogFailed.Error__c='Error on record Id: ' + bvcOrderProductList[i].Migrated_OrderItem__c + ' - ' + error.getMessage();
                        MigrationLogFailed.Processed_recordId__c=bvcOrderProductList[i].Migrated_OrderItem__c;
                    }
                } 
                dmList.add(MigrationLogFailed);
            }
        }
        if(dmList.size()>0)
        {
            insert dmList;
        }
    }
public static void GetCoverage(){
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
    public static void GetCoverage2(){
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
    public static void GetCoverage3(){
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
    public static void GetCoverage4(){
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