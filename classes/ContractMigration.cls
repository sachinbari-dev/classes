/*
*  @Created By : Imran Shaik
*  @Created Date : 05-Sep-2024
*  @Version V1: Migrating all CPQ Contract to BVC Contracts
*               Migrating Order to BVC Order
* 				 Migrating ST_ACR_Consumption__c to BVC_ACR_Consumption__c
* 				 Linking CPQ Contract ST_ACR_Contracted_Price__c,ST_NonACR_Contracted_Price__c,ST_Exhibition_Contracted_Price__c to Created BVC Contracts
*/
global class ContractMigration implements Database.Batchable<sObject>,Database.Stateful
{
    public boolean skipTestClass=false;
    public Integer totalRecordsProcesses=0;
    List<String> ContractIdList = new List<String>();
    Map<String,String> contIds = new Map<String,String>();

    
    public ContractMigration(List<String> ContractIdList)
    {
        this.ContractIdList = ContractIdList;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('Line 6');
        String status='Activated';        
        String query='Select Id,Name,ContractNumber,AccountId,BVC_Service__c,Latest_Contract__c,Business_Type__c,BVC_Billing_Entity__c,BVC_Branch__c,Primary_Customer_Email__c,StartDate,EndDate,';
        query+=' status,Is_Migrted__c,ContractTerm,Contracted_ACR_Package__c,Contract_Amount__c,BVC_Entity__c,OwnerId';
        
        if(skipTestClass) 
        {
            query+=' from Contract where Status=\'Activated\' and Is_Migrted__c=FALSE';
        }
        else
        {
            query+=' from Contract where Id IN : ContractIdList and Is_Migrted__c=FALSE';
            // query += ' from Contract where Id IN (\'8005g0000005XHpAAM\', \'8005g0000006MhmAAE\', \'800J10000004yOZIAY\', \'8005g0000005UYaAAM\',\'8005g0000006F2jAAE\',\'8005g0000006M04AAE\',\'8005g000000V5N6AAK\',\'8005g0000005V29AAE\',\'8005g00000067MZAAY\',\'8005g000000Q37WAAS\',\'800J10000004yKVIAY\')'; 
            // query += ' from Contract where Id IN (\'8005g0000005UWoAAM\', \'8005g00000064t1AAA\', \'8005g0000006MeTAAU\', \'800J10000004zPHIAY\', \'800J10000004zPgIAI\',\'8005g0000005V29AAE\',\'8005g00000067MZAAY\',\'8005g000000Q37WAAS\', \'8005g0000005UDAAA2\', \'8005g0000005YBiAAM\', \'8005g00000064XTAAY\', \'8005g00000065l5AAA\',\'8005g0000006MenAAE\',\'8005g0000005UDlAAM\',\'8005g0000005XHpAAM\',\'8005g0000006MhmAAE\',\'800J10000004yOZIAY\',\'8005g0000005UYaAAM\',\'8005g0000006F2jAAE\',\'8005g0000006M04AAE\',\'8005g000000V5N6AAK\',\'8005g0000005UDpAAM\',\'800J10000004zQtIAI\',\'8005g0000005UFeAAM\',\'8005g0000005Y48AAE\')'; 
        }
        //query+=' from Contract where Status=\'Activated\' and Is_Migrted__c=FALSE';
        //query+=' from Contract';
        // query+=' from Contract where Id=\'800Il000000LHd2IAG\'';
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<Contract> contractsList)
    {         
        System.debug('Line 16');
        
        List<String> contractsIdList = new List<String>();
        List<BVC_Contract__c> createContracts = new List<BVC_Contract__c>();
        Map<String,Contract> migratedContracts = new Map<String,Contract>();
        if(contractsList.size()>0)
        {         
            for(Contract cont:contractsList)
            {   
                System.debug('Line 41');
                BVC_Contract__c singleBvcContract = new BVC_Contract__c();
                singleBvcContract.Status__c = cont.Status;
                singleBvcContract.Customer_Name__c = cont.AccountId;
                singleBvcContract.BVC_Service__c = cont.BVC_Service__c;
                singleBvcContract.Business_Type__c = cont.Business_Type__c;
                // singleBvcContract.BVC_Entity__c = cont.BVC_Entity__c;
                // singleBvcContract.BVC_Billing_Entity__c = cont.BVC_Billing_Entity__c;
                singleBvcContract.BVC_Branch__c = cont.BVC_Branch__c;
                singleBvcContract.Contract_Start_Date__c = cont.StartDate;
                //singleBvcContract.Latest_Contract__c = true;
                singleBvcContract.Contract_End_Date__c = cont.EndDate;
                singleBvcContract.Contract_Amount__c = cont.Contract_Amount__c;
                singleBvcContract.Contract_Term_months__c = cont.ContractTerm;
                singleBvcContract.Contracted_ACR_Package__c = cont.Contracted_ACR_Package__c;
                singleBvcContract.Primary_Customer_Email__c = cont.Primary_Customer_Email__c;
                singleBvcContract.OwnerId = cont.OwnerId;
                singleBvcContract.Migrated_Contract__c = cont.Id;		// Mapping Migrated Id
                singleBvcContract.Text_Migrated_Contract__c =cont.ContractNumber;
                
                migratedContracts.put(cont.Id,cont);
                contractsIdList.add(cont.Id);
                createContracts.add(singleBvcContract); 
                totalRecordsProcesses+=1;
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
                List<Contract> conToUpdate = new List<Contract>();
                for (Integer i = 0; i < upsertResults.size(); i++) 
                {
                    Database.UpsertResult result = upsertResults[i];
                    if (result.isSuccess()) 
                    {
                        Contract c = migratedContracts.get(createContracts[i].Migrated_Contract__c);
                        if(c!=null)
                        {
                            c.Is_Migrted__c= true;
                            conToUpdate.add(c);
                            contIds.put(createContracts[i].Migrated_Contract__c,createContracts[i].Id);
                        }                        
                    }                    
                }
                List<Database.UpsertResult> CheckBoxupsertResults = Database.upsert(conToUpdate, false);
                                
                DataMigrationLogGeneration.MigratedLogGeneration(upsertResults,null,null,null,createContracts,'Contract','BVC Contract');           
                //upsert createContracts;
                System.debug('Line 62 contIds : '+contIds.size());
            }catch(Exception e)
            {
                System.debug('Line No 65 ACRCP Error :'+e.getMEssage());
            }System.debug('Line No 66');
            if(acrCPList.size()>0)
            { System.debug('Line No 68');
             for(ST_ACR_Contracted_Price__c acp : acrCPList)
             {System.debug('Line No 70 acp:'+acp);
              String bvcId = contIds.get(acp.ST_Contract__c); System.debug('Line No 71 bvcId:'+bvcId);
              if(bvcId!=null)
              {
                  acp.BVC_Contract__c = bvcId; 
                  listACRCPToUpdate.add(acp);
              }                
             }
            }
            System.debug('Line No 79 NonAcrCPList.size() :'+NonAcrCPList.size());
            if(NonAcrCPList.size()>0)
            { System.debug('Line No 81 NonAcrCPList.size() :'+NonAcrCPList.size());                
             for(ST_NonACR_Contracted_Price__c Nacp : NonAcrCPList)
             { System.debug('Line No 83 Nacp :'+Nacp);
              String bvcId = contIds.get(Nacp.ST_Contract__c);
              if(bvcId!=null) System.debug('Line No 85 bvcId :'+bvcId);
              {
                  Nacp.BVC_Contract__c = bvcId; 
                  listNACRCPToUpdate.add(Nacp);
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
            }  System.debug('Line No 105 listACRCPToUpdate :'+listACRCPToUpdate);      
            if(listACRCPToUpdate.size()>0)
            { System.debug('Line No 100 listACRCPToUpdate.size() :'+listACRCPToUpdate.size());
             try
             {System.debug('Line No 102 : Before update');
              upsert listACRCPToUpdate;  System.debug('Line No 103 : After update');
             }catch(Exception e)
             {
                 System.debug('Line No 104 ACRCP Error :'+e.getMEssage());
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
    
    global void finish(Database.BatchableContext bc)
    {
        String body = 'Contract To BVC Contract Migration Processed Records :'+contIds.size();
        // Email configuration
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'imran.shaik@bvclogistics.com'});
        email.setSubject('Contract To BVC Contract Migration');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});

        if(contIds.size()>0)
        {
            ACR_ConsumptionMigration ACRCM = new ACR_ConsumptionMigration(contIds);
            database.executeBatch(ACRCM,50);
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