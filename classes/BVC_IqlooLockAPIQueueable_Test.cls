@isTest
public class BVC_IqlooLockAPIQueueable_Test {

    @isTest
    
    public static void testMethod1(){
        
        Shipment__c s = new Shipment__c();
        s.Lock_ID__c = 'Hsd54534';
         insert s;
        
         Test.startTest();
        System.enqueueJob(new BVC_IqlooLockAPIQueueable(s.Lock_ID__c,s.id));
        Test.stopTest(); 
    }
}