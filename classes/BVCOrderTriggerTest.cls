@IsTest
public class BVCOrderTriggerTest {

    @TestSetup
    static void setupData() {
        BVCOrder__c order = new BVCOrder__c(
            Status__c = 'Draft',
            Business_Type__c = 'Non ACR'            
        );
        insert order;
    }

    @IsTest
    static void testNonACROrderActivated() {
        BVCOrder__c order = [SELECT Id, Status__c FROM BVCOrder__c LIMIT 1];
        
        order.Status__c = 'Activated';
        update order;
        
    }

    @IsTest
    static void testACROrderActivated() {
        BVCOrder__c order = [SELECT Id, Status__c FROM BVCOrder__c LIMIT 1];
        
        order.Business_Type__c = 'ACR';
        order.Status__c = 'Activated';
        update order;
        
    }

    @IsTest
    static void testCreateReverseOrder() {
        BVCOrder__c order = [SELECT Id, Status__c FROM BVCOrder__c LIMIT 1];
        
        order.Deactivate_Order__c = true;
        update order;
        
    }

    @IsTest
    static void testNoProcessingWhenStatusUnchanged() {
        BVCOrder__c order = [SELECT Id, Status__c FROM BVCOrder__c LIMIT 1];
        
        update order;
        
    }
}