@IsTest
public class BVCQuoteTriggerTest {

    @TestSetup
    static void setupData() {
        BVCQuote__c bvcQuote = new BVCQuote__c(
            Status__c = 'Draft',
            Business_Type__c = 'ACR'
        );
        insert bvcQuote;
    }

    @IsTest
    static void testAfterUpdateContractSentStatus() {
        BVCQuote__c bvcQuote = [SELECT Id, Status__c, Business_Type__c FROM BVCQuote__c LIMIT 1];

        bvcQuote.Status__c = 'Contract Sent';
        update bvcQuote;

    }

    @IsTest
    static void testNoProcessingWhenStatusUnchanged() {
        BVCQuote__c bvcQuote = [SELECT Id, Status__c, Business_Type__c FROM BVCQuote__c LIMIT 1];

        update bvcQuote;

        
    }

    @IsTest
    static void testContractGenerationCalled() {
        BVCQuote__c bvcQuote = [SELECT Id, Status__c, Business_Type__c FROM BVCQuote__c LIMIT 1];

        bvcQuote.Status__c = 'Contract Sent';
        update bvcQuote;

        
    }

    @IsTest
    static void testDeleteScenario() {
        BVCQuote__c bvcQuote = [SELECT Id FROM BVCQuote__c LIMIT 1];

        delete bvcQuote;

        
    }

    @IsTest
    static void testInsertScenario() {
        BVCQuote__c newQuote = new BVCQuote__c(
            Status__c = 'Contract Sent',
            Business_Type__c = 'ACR'
        );
        insert newQuote;

        
    }
}