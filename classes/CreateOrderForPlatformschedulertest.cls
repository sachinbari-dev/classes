@isTest
public class CreateOrderForPlatformschedulertest {

     @isTest
    static void acrShipmentTestMethod(){
        
        
        Test.startTest();

        String cronExp = '0 0 0 1 1 ? 2050'; 
        // Runs at a fake future time (doesn't matter in test)

        System.schedule(
            'Test CreateOrderForPlatform',
            cronExp,
            new CreateOrderForPlatform()
        );
        CreateOrderForPlatform.dummyMethod();

        Test.stopTest();  // Forces execute() to run
        
        
    
    }}