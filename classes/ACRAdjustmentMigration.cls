global class ACRAdjustmentMigration implements Database.Batchable<sObject>,Database.Stateful
{
    Map<String,String> contIdMap = new Map<String,String>();
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        List<BVC_Contract__c> existingList = [select Migrated_Contract__c from BVC_Contract__c where Migrated_Contract__c!=null limit 40000];
        List<String> contractsIdList = new List<String>();
        if(existingList.size()>0)
        {
            for(BVC_Contract__c bvc_Con:existingList)
            {
                contractsIdList.add(bvc_Con.Migrated_Contract__c);
                contIdMap.put(bvc_Con.Migrated_Contract__c,bvc_Con.Id); 
            }
        }
        String query='select Id,Account__c,Name,Adjustment_Amount__c,Adjustment_Date__c,';
        query+='Adjustment_Remark__c,Adjustment_Type__c,Contract__c';
        query+=' from ACR_Adjustment__c where Contract__c IN :contractsIdList and Is_Migrated__c=FALSE';
        System.debug('31 query :'+query);

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<ACR_Adjustment__c> ACR_AdjustmentList)
    {
        System.debug('22 ACR_AdjustmentList.size() :'+ACR_AdjustmentList.size());        
        if(ACR_AdjustmentList.size()>0)
        {
			List<BVC_ACR_Adjustment__c> existingList =[select Id,Migrated_ACR_Adjustment__c 
                                                       from BVC_ACR_Adjustment__c where Migrated_ACR_Adjustment__c!=null]; 
            Map<String,String> migratedMap = new Map<String,String>();
            if(existingList.size()>0)
            {
                for(BVC_ACR_Adjustment__c bvc_Acr_adj:existingList)
                {
                    migratedMap.put(bvc_Acr_adj.Migrated_ACR_Adjustment__c,bvc_Acr_adj.Id);
                }
            }

            
            List<BVC_ACR_Adjustment__c> listToCreate = new List<BVC_ACR_Adjustment__c>();
            List<ACR_Adjustment__c> adjToUpdate = new List<ACR_Adjustment__c>();
            for(ACR_Adjustment__c adj:ACR_AdjustmentList)
            {
                BVC_ACR_Adjustment__c bvcAdjRecord = new BVC_ACR_Adjustment__c();
                String bvcContractId=null;
                String migratedId = null;
                migratedId = migratedMap.get(adj.Id);
                bvcContractId = contIdMap.get(adj.Contract__c);
                if(migratedId==null)
                {
                    bvcAdjRecord.Account__c =adj.Account__c;
                    bvcAdjRecord.Adjustment_Amount__c =adj.Adjustment_Amount__c;
                    bvcAdjRecord.Adjustment_Date__c =adj.Adjustment_Date__c;
                    bvcAdjRecord.Adjustment_Remark__c =adj.Adjustment_Remark__c;
                    bvcAdjRecord.Adjustment_Type__c =adj.Adjustment_Type__c;
                    bvcAdjRecord.BVC_Contract__c =bvcContractId; 
                    bvcAdjRecord.Migrated_ACR_Adjustment__c = adj.Id;
                    listToCreate.add(bvcAdjRecord);
                    adj.Is_Migrated__c = true;
                    adjToUpdate.add(adj);
                }

            }
            if(listToCreate.size()>0)
            {
                List<Database.UpsertResult> upsertResults = Database.upsert(listToCreate, false);
                ACRAdjustmentMigration.MigratedLogGeneration(upsertResults,listToCreate,'ACR Adjustment','BVC ACR Adjustment');
                List<Database.UpsertResult> upsertResults1 = Database.upsert(adjToUpdate, false);
            }            
        }
    }   
    global void finish(Database.BatchableContext bc)
    {
        
    }
    public static void MigratedLogGeneration(List<Database.UpsertResult> upsertResults,List<BVC_ACR_Adjustment__c> bvcACRAdjList,
                                             String FromObject,String ToObject)
    {
        List<Data_Migration_Log__c> dmList = new List<Data_Migration_Log__c>();
        List<String> recIdsList = new List<String>();
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
                MigrationLogPassed.Processed_recordId__c = bvcACRAdjList[i].Migrated_ACR_Adjustment__c;
                recIdsList.add(MigrationLogPassed.Processed_recordId__c);
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
                    MigrationLogFailed.Error__c='Error on record Id: ' + bvcACRAdjList[i].Migrated_ACR_Adjustment__c + ' - ' + error.getMessage();
                    MigrationLogFailed.Processed_recordId__c=bvcACRAdjList[i].Migrated_ACR_Adjustment__c;
                } 
                recIdsList.add(MigrationLogFailed.Processed_recordId__c);
                dmList.add(MigrationLogFailed);
            }
        }
        if(recIdsList.size()>0)
        {
            List<Data_Migration_Log__c> DeleteLogList = [select Id from Data_Migration_Log__c where Processed_recordId__c IN : recIdsList];
            delete DeleteLogList;
            insert dmList;
        }
    }    
}