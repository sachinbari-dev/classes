/*  @ Helper Class for ContractMigration
 *  @Created By : Imran Shaik
 *  @Created Date : 27-Sep-2024
 *  @Version V1: Migrating all CPQ Contract to BVC Contracts
 * 				 Linking CPQ Contract ST_ACR_Contracted_Price__c,ST_NonACR_Contracted_Price__c,ST_Exhibition_Contracted_Price__c to Created BVC Contracts 
 */
global class ContractToBVCContractMigration implements Database.Batchable<sObject>,Database.Stateful
{
    
    public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
            'SELECT Id FROM Shipment__c WHERE id=null'
        );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
    /*
    global static Map<String,String> QuoteIdMap = new Map<String,String>();
	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('Line 6');
        String status='Activated';
        String query='Select Id,Name,ContractNumber,AccountId,BVC_Service__c,Latest_Contract__c,Business_Type__c,BVC_Billing_Entity__c,BVC_Branch__c,Primary_Customer_Email__c,StartDate,EndDate,';
        query+=' status,ContractTerm,Contracted_ACR_Package__c,Contract_Amount__c,BVC_Entity__c,OwnerId';
        //query+=' from Contract where Status=\'Activated\' and Is_Migrted__c=FALSE';
        //query+=' from Contract';
          //query+=' from Contract where Id=\'800Il000000LHd2IAG\' and Is_Migrted__c=FALSE';
         query += ' from Contract where Id IN (\'800Il000000LLr2IAG\', \'8000T000000AgOSQA0\', \'800Il000000LKgSIAW\', \'8005g0000006HS2AAM\', \'800Il000000LGzqIAG\',\'8005g0000006E8sAAE\',\'8005g0000006J9NAAU\',\'8005g0000006F7KAAU\',\'8005g0000006FbfAAE\',\'8005g00000067TMAAY\',\'8005g00000068hlAAA\',\'8005g0000006BWvAAM\',\'8005g0000006FTWAA2\',\'8005g0000006HSCAA2\',\'8005g0000006HSlAAM\',\'8005g0000006IbfAAE\',\'8005g0000006IsgAAE\')';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<Contract> contractsList)
    {         
        System.debug('Line 16');
         Map<String,String> contIds = new Map<String,String>();
         List<String> contractsIdList = new List<String>();
         List<BVC_Contract__c> createContracts = new List<BVC_Contract__c>();
     if(contractsList.size()>0)
     {
         // Checking for migrated Contracts
         List<String> cids = new List<String>();
         Map<String,String> existingMap = new Map<String,String>();
         for(Contract cont:contractsList)
         {
           cids.add(cont.Id)  ;
         }
         if(cids.size()>0)
         {
             // getting already Migrated BVC Contracts
            List<BVC_Contract__c> existingList = [select Id,Migrated_Contract__c from BVC_Contract__c where Migrated_Contract__c IN :cids];
             if(existingList.size()>0)
             {
                 for(BVC_Contract__c bct : existingList)
                 {
                     existingMap.put(bct.Migrated_Contract__c,bct.Id);
                 }
             }
         }
         // Checking process Stopped
         
         for(Contract cont:contractsList)
         {   
             System.debug('Line 41');
                 BVC_Contract__c singleBvcContract = new BVC_Contract__c();
                 singleBvcContract.Status__c = cont.Status;
                 singleBvcContract.Customer_Name__c = cont.AccountId;
                 singleBvcContract.BVC_Service__c = cont.BVC_Service__c;
                 singleBvcContract.Business_Type__c = cont.Business_Type__c;
                 singleBvcContract.BVC_Branch__c = cont.BVC_Branch__c;
                 singleBvcContract.Contract_Start_Date__c = cont.StartDate;
                 singleBvcContract.Contract_End_Date__c = cont.EndDate;
                 singleBvcContract.Contract_Amount__c = cont.Contract_Amount__c;
                 singleBvcContract.Contract_Term_months__c = cont.ContractTerm;
                 singleBvcContract.Contracted_ACR_Package__c = cont.Contracted_ACR_Package__c;
                 singleBvcContract.Primary_Customer_Email__c = cont.Primary_Customer_Email__c;
                 singleBvcContract.OwnerId = cont.OwnerId;
                 singleBvcContract.Migrated_Contract__c = cont.Id;		// Mapping Migrated Id
                 singleBvcContract.Text_Migrated_Contract__c =cont.ContractNumber;
                 
                 contractsIdList.add(cont.Id);
                 createContracts.add(singleBvcContract);            
                 System.debug('Line 39 singleBvcContract.Id:'+singleBvcContract.Id);                      
         }         
     }
         System.debug('Line 41 contractsIdList:'+contractsIdList.size());
        List<ST_ACR_Contracted_Price__c> acrCPList = [select Id,BVC_Contract__c,ST_Contract__c from ST_ACR_Contracted_Price__c where ST_Contract__c IN : contractsIdList];
        List<ST_NonACR_Contracted_Price__c> NonAcrCPList = [select Id,BVC_Contract__c,ST_Contract__c from ST_NonACR_Contracted_Price__c where ST_Contract__c IN : contractsIdList];
        List<ST_Exhibition_Contracted_Price__c> ExbPList = [select Id,BVC_Contract__c,ST_Contract__c from ST_Exhibition_Contracted_Price__c where ST_Contract__c IN : contractsIdList];
        
        List<ST_ACR_Contracted_Price__c> listACRCPToUpdate = new List<ST_ACR_Contracted_Price__c>();
        List<ST_NonACR_Contracted_Price__c> listNACRCPToUpdate = new List<ST_NonACR_Contracted_Price__c>();
        List<ST_Exhibition_Contracted_Price__c> listExbToUpdate = new List<ST_Exhibition_Contracted_Price__c>();
     	
        System.debug('Line 42 Found acrCPList Size : '+acrCPList.size());
        System.debug('Line 43 Found NonAcrCPList Size : '+NonAcrCPList.size());
        System.debug('Line 44 Found ExbPList Size : '+ExbPList.size()); System.debug('Line 49 createContracts size:'+createContracts.size());
        if(createContracts.size()>0)
        { 
            try
            {
                List<Database.UpsertResult> upsertResults = Database.upsert(createContracts, false);
                for(BVC_Contract__c bvc:createContracts)
                {
            		contIds.put(bvc.Migrated_Contract__c,bvc.Id);        
                }
                List<Data_Migration_Log__c> dmList = new List<Data_Migration_Log__c>();
                for (Integer i = 0; i < upsertResults.size(); i++) {
                    Database.UpsertResult result = upsertResults[i];
                    if (result.isSuccess()) 
                    {                       
                        Data_Migration_Log__c MigrationLogPassed = new Data_Migration_Log__c();
                        MigrationLogPassed.Name='Contract Migration';
                        MigrationLogPassed.Migrated_From__c='Contract';
                        MigrationLogPassed.Migrated_To__c='BVC Contract';
                        MigrationLogPassed.Result__c='Passed';
                        MigrationLogPassed.Processed_recordId__c=createContracts[i].Migrated_Contract__c;
                        dmList.add(MigrationLogPassed);
                    } 
                    else 
                    {
                        Data_Migration_Log__c MigrationLogFailed = new Data_Migration_Log__c();
                        MigrationLogFailed.Name='Contract Migration';
                        MigrationLogFailed.Result__c='Failed';
                        MigrationLogFailed.Migrated_From__c='Contract';
                        MigrationLogFailed.Migrated_To__c='BVC Contract';
                        MigrationLogFailed.Processed_recordId__c=createContracts[i].Migrated_Contract__c;
                        for (Database.Error error : result.getErrors()) {                           
                            // failedRecordDetails.add('Error on record Id: ' + createContracts[i].Migrated_Contract__c + ' - ' + error.getMessage());
                            MigrationLogFailed.Error__c='Error on record Id: ' + createContracts[i].Migrated_Contract__c + ' - ' + error.getMessage();
                        } 
                        dmList.add(MigrationLogFailed);
                    }
                }
                if(dmList.size()>0)
                {
                    insert dmList;
                }
                ContractToBVCContractMigrationHelper.generateBvcOrders(contractsIdList, contIds);
            }catch(Exception e)
            {
                System.debug('Line No 65 ACRCP Error :'+e.getMEssage());
            }
            System.debug('Line No 66');
            if(acrCPList.size()>0)
            { 
                System.debug('Line No 68');
                for(ST_ACR_Contracted_Price__c acp : acrCPList)
                {
                    System.debug('Line No 70 acp:'+acp);
                    String bvcId = contIds.get(acp.ST_Contract__c); System.debug('Line No 71 bvcId:'+bvcId);
                    if(bvcId!=null)
                    {
                        acp.BVC_Contract__c = bvcId; 
                        listACRCPToUpdate.add(acp);
                    }                
                }
                
                System.debug('Line No 105 listACRCPToUpdate :'+listACRCPToUpdate);      
                if(listACRCPToUpdate.size()>0)
                { 
                    System.debug('Line No 100 listACRCPToUpdate.size() :'+listACRCPToUpdate.size());
                    try
                    {
                        System.debug('Line No 102 : Before update');
                        upsert listACRCPToUpdate;  System.debug('Line No 103 : After update');
                    }catch(Exception e)
                    {
                        System.debug('Line No 104 ACRCP Error :'+e.getMEssage());
                    }            
                }
            }
            System.debug('Line No 79 NonAcrCPList.size() :'+NonAcrCPList.size());
            if(NonAcrCPList.size()>0)
            { 
                System.debug('Line No 81 NonAcrCPList.size() :'+NonAcrCPList.size());                
                for(ST_NonACR_Contracted_Price__c Nacp : NonAcrCPList)
                { 
                    System.debug('Line No 83 Nacp :'+Nacp);
                    String bvcId = contIds.get(Nacp.ST_Contract__c);
                    if(bvcId!=null) System.debug('Line No 85 bvcId :'+bvcId);
                    {
                        Nacp.BVC_Contract__c = bvcId; 
                        listNACRCPToUpdate.add(Nacp);
                    }                
                }
                if(listNACRCPToUpdate.size()>0)
                {
                    try
                    {
                        upsert listNACRCPToUpdate;
                    }catch(Exception e)
                    {
                        System.debug('Line No 114 NonACRCP Error :'+e.getMEssage());
                    }            
                }
            }
            
            if(ExbPList.size()>0)
            {                
                for(ST_Exhibition_Contracted_Price__c Exbcp : ExbPList)
                {
                    String bvcId = contIds.get(Exbcp.ST_Contract__c);
                    if(bvcId!=null)
                    {
                        Exbcp.BVC_Contract__c = bvcId; 
                        listExbToUpdate.add(Exbcp);
                    }                
                }
                if(listExbToUpdate.size()>0)
                {
                    try
                    {
                        upsert listExbToUpdate;
                    }catch(Exception e)
                    {
                        System.debug('Line No 124 EXB Error :'+e.getMEssage());
                    }            
                } 
            }  
        }   
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
		
    }*/
}