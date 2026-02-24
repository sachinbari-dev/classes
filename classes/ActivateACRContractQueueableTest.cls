@isTest
public class ActivateACRContractQueueableTest {
    @isTest
    static void acrShipmentTestMethod(){
    Map<Id, Id> testMap = new Map<Id, Id>();
        testMap.put(UserInfo.getUserId(), UserInfo.getUserId());

        Test.startTest();
        System.enqueueJob(new ActivateACRContractQueueable(testMap));
        ActivateACRContractQueueable.dummyMethod();
        Test.stopTest();
    }}