/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 25-12-2023
 * @last modified by  : rafi.khan@bvclogistics.com
**/
@isTest
public class WeightTriggerTest {
    @isTest
    static void testWeightTrigger() {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer', 'Billing', false);
        BillingAcc.Customer_Category_Static__c = 'ACR';
        Insert BillingAcc;
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer', 'Shipping', true);
        Shipment__c ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        List<Weight__c>   weigtList = new List<Weight__c>();
        //System.debug('ship for testing '+ship);
        
        Weight__c weight = new Weight__c();
        weight.Number_of_Secure_Bags_Scanned__c = 3;
        weigtList.add(weight);
        insert weigtList;
        //System.debug('for checking weigtList '+weigtList[0].Id);
        
        List<Shipment__c> shipList = new List<Shipment__c>();
        ship.Weight__c = weigtList[0].Id;
        shipList.add(ship);
        update shipList;
        
        List<Weight__c>   weigtListUpdate = new List<Weight__c>();
        for(Weight__c obj :weigtList){
            Weight__c tmpObj = new Weight__c();
            tmpObj.Id= obj.Id;
            tmpObj.Number_of_Secure_Bags_Scanned__c = 0;
            weigtListUpdate.add(tmpObj);
        }
        update weigtListUpdate;
        
    }
    
}