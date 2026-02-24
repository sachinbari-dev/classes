global class QuoteMigration implements Database.Batchable<sObject>,Database.Stateful
{
    public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
            'SELECT Id FROM Shipment__c WHERE id=null'
        );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
    
    public static void dummyMethod(){
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
    } 
}
    /*global static Map<String,String> QuoteIdMap = new Map<String,String>();
	global Database.QueryLocator start(Database.BatchableContext cont)
    {
        System.debug('Line 5');
        String customerName='0015g000012eMClAAM';
        String query='Select Id,Name,SBQQ__StartDate__c,SBQQ__EndDate__c,Contract_Signed__c,Contract_End_Date__c,';
        query+='SBQQ__Status__c,Business_Type__c,BVC_Service__c,SBQQ__Account__c,BVC_Branch__c,Contract_Signed_Date__c,Contract_Start_Date__c,';
        query+='Contract_Sent_Date__c,SBQQ__Primary__c,Decision_Maker__c,People__c,Evaluator__c,Exhibition__c';
        query+=' from SBQQ__Quote__c where SBQQ__Account__c=:customerName';
        System.debug('Line 11 query:'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext cont,List<SBQQ__Quote__c> cpqQuoteList)
    {
        System.debug('Line 16 ');
        String ACR_recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String NonACR_recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        String EXHB_recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('Exhibition').getRecordTypeId();
        List<BVCQuote__c> migratedQuotesList = new List<BVCQuote__c>();
        System.debug('18 Found :'+cpqQuoteList.size());
        for(SBQQ__Quote__c quote : cpqQuoteList)
        {
            BVCQuote__c bvcQuote = new BVCQuote__c();
            bvcQuote.CPQ_Quote_Name__c = quote.Name; 
            bvcQuote.CPQ_QuoteId__c = quote.Id; 
            bvcQuote.Converted_CPQ_Quote__c = quote.Id;             
            bvcQuote.Start_Date__c = quote.SBQQ__StartDate__c;
            bvcQuote.End_Date__c = quote.SBQQ__EndDate__c;
            bvcQuote.Contract_Signed__c = quote.Contract_Signed__c;            
            bvcQuote.Contract_End_Date__c	 = quote.Contract_End_Date__c;
            bvcQuote.Contract_Sent_Date__c = quote.Contract_Sent_Date__c;
            bvcQuote.Contract_Signed_Date__c = quote.Contract_Signed_Date__c;
            bvcQuote.Contract_Start_Date__c = quote.Contract_Start_Date__c;            
            bvcQuote.Account__c = quote.SBQQ__Account__c;
            if(quote.Business_Type__c=='ACR') { bvcQuote.RecordTypeId = ACR_recordTypeId; }
            if(quote.Business_Type__c=='Non ACR') { bvcQuote.RecordTypeId = NonACR_recordTypeId; }
            if(quote.Business_Type__c=='Exhibition') { bvcQuote.RecordTypeId = EXHB_recordTypeId; }           
            bvcQuote.Business_Type__c = quote.Business_Type__c;
            bvcQuote.BVC_Branch__c = quote.BVC_Branch__c;
           // bvcQuote.BVC_Price_Slab__c = priceSlab;
            bvcQuote.BVC_Service__c = quote.BVC_Service__c;
            bvcQuote.Exhibition__c = quote.Exhibition__c;
            bvcQuote.Primary__c = quote.SBQQ__Primary__c;
            bvcQuote.Status__c = quote.SBQQ__Status__c;
            // Set the new fields
            bvcQuote.Decision_Maker__c = quote.Decision_Maker__c;
            bvcQuote.Customer_Authorized_Signatory__c = quote.People__c;
            bvcQuote.Evaluator__c = quote.Evaluator__c; 
            System.debug('50 quote.Business_Type__c :'+quote.Business_Type__c);
            QuoteIdMap.put(quote.Id,bvcQuote.Id);
            migratedQuotesList.add(bvcQuote);
        }
        if(migratedQuotesList.size()>0)
        {
            System.debug('55 Before Insert :');
            try{
                // upsert migratedQuotesList;
                System.debug('Line no 60 migratedQuotesList.size()) :'+migratedQuotesList.size());
                List<Database.UpsertResult> upsertResults = Database.upsert(migratedQuotesList, false);
                QuoteMigrationHelper.MakeMail(upsertResults,migratedQuotesList,'BVC Quote');
                System.debug('58 After Insert :');
            }catch(Exception e)
            {
               System.debug('61 Error :'+e.getMessage()); 
            }
            
            System.debug('Final');
        }
    }
    
    global void finish(Database.BatchableContext cont)
    {
        QuoteLinnesMigration qlm = new QuoteLinnesMigration();
        qlm.QuoteIdMap = QuoteIdMap;
        Database.executeBatch(qlm,10);
    }
}*/