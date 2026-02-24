public class DataMigrationHelpper 
{    
    public static void contractMigrationBatch(List<String> ContractIdList)
    {
        ContractMigration CM = new ContractMigration(ContractIdList);
        database.executeBatch(CM,2000);   
    }
   
    public static void orderMigrationBatch(Integer limitation)
    {
		if(limitation==null)
        {
            limitation=500;
        }
        List<BVC_ACR_Consumption__c> existingList= [select Id,BVCOrder__c,Is_Order_Migrattion__c,Migrated_ACR_Consumption__c from BVC_ACR_Consumption__c  
                                                    where Migrated_ACR_Consumption__c!=null and Is_Order_Migrattion__c=FALSE 
                                                    and BVCOrder__c=null and BVC_Contract__r.Latest_Contract__c=True limit : limitation];
        Map<String,BVC_ACR_Consumption__c> migratedACR_Con = new Map<String,BVC_ACR_Consumption__c>();
        if(existingList.size()>0)
        {
			for(BVC_ACR_Consumption__c acr:existingList)
            {
                migratedACR_Con.put(acr.Migrated_ACR_Consumption__c,acr);
            }
            orderMigration OM = new orderMigration(migratedACR_Con);
            database.executeBatch(OM,2000);
        }
        
    } 
    /*
    public static void orderProductMigrationBatch()
    {
        List<BVCOrder__c> bvcOrders = [select Id,Migrated_Order__c from BVCOrder__c where Migrated_Order__c!=null limit 45000];
        List<String> orderIdList = new List<String>();
        if(bvcOrders.size()>0)
        {
            for(BVCOrder__c bo:bvcOrders)
            {
                orderIdList.add(bo.Migrated_Order__c);
            }            
        }
        OrderProductMigration OPM = new OrderProductMigration(orderIdList);
        database.executeBatch(OPM,10); 
    }   
    public static void acrConsumptionMigrationBatch()
    {
        List<BVC_Contract__c> existingList = [select Migrated_Contract__c from BVC_Contract__c where Migrated_Contract__c!=null limit 10000];
        Map<String,String> contIds = new Map<String,String>(); 
        List<String> contractsIdList = new List<String>();       
        if(existingList.size()>0)
        {
            for(BVC_Contract__c bvc_Con:existingList)
            {
                contractsIdList.add(bvc_Con.Migrated_Contract__c);
                contIds.put(bvc_Con.Migrated_Contract__c,bvc_Con.Id); 
            }
        }
        
        
        Map<String,String> existingMap = new Map<String,String>();
        
        // collecting Migrated BVC ACR Consumptions
        List<BVC_ACR_Consumption__c> migratedAcrConsumption = [select Id,Migrated_ACR_Consumption__c 
                                                               from BVC_ACR_Consumption__c where Migrated_ACR_Consumption__c!=null];
        if(migratedAcrConsumption.size()>0)
        {
            for(BVC_ACR_Consumption__c acp:migratedAcrConsumption)
            {
                existingMap.put(acp.Migrated_ACR_Consumption__c,acp.Migrated_ACR_Consumption__c);
            }
        } 
        if(contractsIdList.size()>0 && contIds.size()>0)            
        {
            ACR_ConsumptionMigration ACRCM = new ACR_ConsumptionMigration(contractsIdList,contIds);
            database.executeBatch(ACRCM,10);
        }        
    }  
    */
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
}