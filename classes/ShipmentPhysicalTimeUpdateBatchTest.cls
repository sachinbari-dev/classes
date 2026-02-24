/**
 * Test class for ShipmentPhysicalTimeUpdateBatch
 */
@isTest(SeeAllData=true)
public class ShipmentPhysicalTimeUpdateBatchTest {    
    @isTest
    static void testBatchExecutionPass() {
        System.debug('193 testBatchExecutionPass :');
        Shipment__c shipmentWithPickup = [ SELECT Id, Pickup__c, Physical_Pickup_Completed_Time1__c, 
                                          Pickup__r.Physical_Pickup_Completed_Time__c
                                          FROM Shipment__c WHERE Pickup__r.Pickup_Status__c=:'Completed' and
                                          Pickup__r.Physical_Pickup_Completed_Time__c!=null limit 1];
        List<Shipment__c> shipList = new List<Shipment__c>{shipmentWithPickup};
        System.debug('193 shipList :'+shipList);
        
        List<String> pickupIdList = new List<String>{shipmentWithPickup.Pickup__c};            
        Test.startTest();
        SLACalculatorHandlerBatchHandler.callbatchHelper(pickupIdList);
        Test.stopTest();        
    }    
}