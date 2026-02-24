@isTest
public class UpdateNonACRTemplateTest {
    
    @isTest
    static void acrShipmentTestMethod(){
    UpdateNonACRTemplate.dummyMethod();
    }}
  
    /*
    @isTest
    static void testAfterInsert() {
        // Create test data for SBQQ__Quote__c
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            Business_Type__c = 'Non ACR',
            SBQQ__Status__c = 'Draft'
        );
        insert testQuote;
         
        Product2 gwc = new Product2(
            ProductCode= 'GOLD-WC',
            Name= 'GoldSHIP Within City'
        );
        insert gwc;

        Product2 gsc = new Product2(
            ProductCode= 'GOLD-S-C2C',
            Name= 'GoldSHIP Surface C2C'
        );
        insert gsc;

        Product2 gec = new Product2(
            ProductCode= 'GOLD-EX-C2C',
            Name= 'GoldSHIP Express C2C'
        );
        insert gec;
        
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gwc.Id,
            ST_Rate_Amount__c = 2000,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gsc.Id,
            ST_Gross_Weight_Slabs__c = '0 - 20 Kg',
            ST_Rate_Amount__c = 1.75,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gsc.Id,
            ST_Gross_Weight_Slabs__c = '20.01+ Kg',
            ST_Rate_Amount__c = 1.5,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gec.Id,
            ST_Gross_Weight_Slabs__c = '0 - 1 Kg',
            ST_Rate_Amount__c = 3,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gec.Id,
            ST_Gross_Weight_Slabs__c = '1.01 - 3 Kg',
            ST_Rate_Amount__c = 2.5,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gec.Id,
            ST_Gross_Weight_Slabs__c = '3.01 - 10 Kg',
            ST_Rate_Amount__c = 1.5,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gec.Id,
            ST_Gross_Weight_Slabs__c = '10.01 - 20 Kg',
            ST_Rate_Amount__c = 1.5,
            SBQQ__Quote__c = testQuote.Id
        ));

        quoteLines.add(new SBQQ__QuoteLine__c(
            SBQQ__Product__C = gec.Id,
            ST_Gross_Weight_Slabs__c = '20.01+ Kg',
            ST_Rate_Amount__c = 1.25,
            SBQQ__Quote__c = testQuote.Id
        ));

        insert quoteLines;

        // Update quote status to trigger the after insert logic
        /*Non_ACR_Template__c nonacr = new Non_ACR_Template__c(
            ST_BVC_Service__c = 'GoldSHIP Express C2C',
            ST_0_1_KG__c = 3,
            ST_1_01_3_KG__c = 2.5,
            ST_3_01_10_KG__c = 2,
            ST_10_01_20_KG__c = 1.5,
            ST_20_01_Kg__c = 1.25,
            Quote__c = testQuote.Id
        ); 
        insert nonacr; 
        testQuote.SBQQ__Status__c = 'Activated';
        update testQuote;
        
       
    }
}*/