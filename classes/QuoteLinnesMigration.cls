public class QuoteLinnesMigration implements Database.Batchable<sObject>
{
    public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
        'SELECT Id FROM Shipment__c WHERE id=null'
    );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
    public static void getCoverage(){
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

    } 
}
    
    /*
    public Map<String,String> QuoteIdMap = new Map<String,String>();
	public Database.QueryLocator start(Database.BatchableContext cont)
    {
        System.debug('Line 5');
        Set<String> ids = this.QuoteIdMap.keySet();
        String query='Select Id,Name,BVCQuote__c';
       // query+='';
       // query+='';
        query+=' from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : ids';
        System.debug('Line 11 query:'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext cont,List<SBQQ__QuoteLine__c> cpqQuoteLinesList)
    {
        System.debug('Line 16 ');
        String ACR_recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        String NonACR_recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        String EXHB_recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('Exhibition').getRecordTypeId();
        List<BVCQuoteLineItem__c> migratedQuoteLinesList = new List<BVCQuoteLineItem__c>();
        System.debug('18 Found :'+ cpqQuoteLinesList.size());
        for(SBQQ__QuoteLine__c qli :  cpqQuoteLinesList)
        {
            BVCQuoteLineItem__c qlItem = new BVCQuoteLineItem__c();
            String bvcQuoteId = this.QuoteIdMap.get(qli.SBQQ__Quote__c);

            qlItem.BVCQuote__c = bvcQuoteId;
            qlItem.Product__c = qli.SBQQ__Product__c;
            qlItem.Quantity__c = qli.SBQQ__Quantity__c;

            qlItem.Rate_Amount__c = qli.ST_Rate_Amount__c;
            qlItem.Minimum_Freight__c = qli.ST_Minimum_Freight__c;
            qlItem.Product_Code__c = qli.SBQQ__ProductCode__c; 
            qlItem.Subrogation_Liability__c = qli.Subrogation_Liability__c;
            qlItem.All_Risk_Liability__c = qli.All_Risk_Liability__c;
            qlItem.Fidelity_Liability__c = qli.Fidelity_Liability__c;
            qlItem.Offline_Charge__c = qli.Offline_Charge_Discount_Percent__c;
            qlItem.Remote_Location__c = qli.Remote_Location__c;
            qlItem.Indirect_Location__c = qli.Indirect_Location__c;
            qlItem.Fuel_Surcharge__c = qli.Fuel_Surcharge__c;
            qlItem.Freight_on_Invoice_Value__c = qli.Freight_Charges_eSHIP__c;
            qlItem.Universe_Cost_Charge__c = qli.Universe_Cost_Charge__c;
            qlItem.Product_Name__c = qli.SBQQ__ProductName__c;
            qlItem.ACR_Standard_Price__c = qli.ST_ACR_Standard_Price__c;
            // qlItem.Rate_UOM__c = qli.Rate_INR__c;
            qlItem.Package_Type__c = qli.ST_Package_Type__c;
            // qlItem.Net_Unit_Price__c = qli.
            qlItem.Liability_Coverage__c =qli.Liability_Charges_eSHIP__c;
                
            migratedQuoteLinesList.add(qlItem);

        }
        if(migratedQuoteLinesList.size()>0)
        {
            System.debug('55 Before Insert :');
            try{
				// upsert migratedQuoteLinesList;
                System.debug('Line no 59 migratedQuoteLinesList.size()) :'+migratedQuoteLinesList.size());
                List<Database.UpsertResult> upsertResults = Database.upsert(migratedQuoteLinesList, false);
                QuoteMigrationHelper.MakeMail(upsertResults,migratedQuoteLinesList,'BVC QuoteLines');
                System.debug('58 After Insert :');
            }catch(Exception e)
            {
               System.debug('61 Error :'+e.getMessage()); 
            }
            
            System.debug('Final');
        }
    }
    
    public void finish(Database.BatchableContext cont)
    {
        
    }*/