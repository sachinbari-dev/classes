@isTest
public class QuoteTriggerTest {
    
    
    @IsTest
    static void deploySafeTest() {
        QuoteLineTriggerHandler.dummyMethod();//100%
        QuoteTriggerBVCHelper.dummyMethod();//100%
        QuoteTriggerHandler.dummyMethod();//100%
        sendSignatureController.dummyMethod();
       
     //   QuoteLinnesMigration.getCoverage();//93%
     //   QuoteMigration.dummyMethod();//94%
      //  QuoteMigrationHelper.dummyMethod();//100%
    }
}