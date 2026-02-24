@isTest
public class CustomLookupLwcControllerTest {
    
    @isTest
    public static void test(){
        
        Secure_Packaging__c SP_Trunk = BVCL_TestDataFactory.createPackaging('Trunk','BVCL1234','Available',true);
        
        Trunk__c testTrunk = new Trunk__c();
        testTrunk.Trunk_name__c = SP_Trunk.Id;
        insert testTrunk;
        
        Hub__c  hb = new Hub__c();
        hb.Name = 'AHMEDABAD';
        hb.Branch__c = 'AHMEDABAD';
        insert hb;
        
        String userId = UserInfo.getUserId();
        System.debug('userId '+userId);
        
        FSE_Sales__c testFSE = new FSE_Sales__c();
        testFSE.Sales_Person__c = userId;
        testFSE.Hub__c = hb.Id;
        insert testFSE;

        string EmpHub = testFSE.Hub__r.Branch__c;
        
        test.startTest();
        List<sObject> result = CustomLookupLwcController.fetchLookupData('test','Trunk__c');
        test.stopTest();
    }

}