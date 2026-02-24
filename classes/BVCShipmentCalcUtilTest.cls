@isTest
public class BVCShipmentCalcUtilTest {
    
    @isTest
    static void testMethod1(){
       /* Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',false);
        testAccount.Customer_Category__c = 'Non ACR Contracted';
        testAccount.Customer_Category_Static__c = 'Non-ACR';
        Insert testAccount;
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',False);
        ShipperAcc.Customer_Category__c = 'Non ACR Contracted';
        ShipperAcc.Customer_Category_Static__c = 'Non-ACR';
        Insert ShipperAcc;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Ship1.Bill_To_Account__c = testAccount.id;
        Ship1.Origin_Hub__c = DelhiHub.Id;
        update Ship1;
        
        list<BVCShipmentCalcUtil.ShipmentDetail> wrapList = new list<BVCShipmentCalcUtil.ShipmentDetail>();
        BVCShipmentCalcUtil.ShipmentDetail wrap = new BVCShipmentCalcUtil.ShipmentDetail();
        wrap.CommunityUniqueId = 'test';
        wrap.freightOnInvoice=0;
        wrap.perShipment = 0;
        wrap.prodName ='test';
        wrap.errors = 'test';
        wrap.exhibitionContractedPriceId = 'test';
        wrapList.add(wrap);
        
        list<Account> listAcc = new list<Account>();
        listAcc.add(testAccount);
        
        
        map<id,Account> mapAccount = new map<id,Account>();
        mapAccount.put(listAcc[0].Id,listAcc[0]);*/
         list<BVCShipmentCalcUtil.ShipmentDetail> wrapList = new list<BVCShipmentCalcUtil.ShipmentDetail>();
        test.startTest();
        List < BVCShipmentCalcUtil.ShipmentDetail > shipWrapList = BVCShipmentCalcUtil.shipmentCalculationUtility(wrapList);
        BVCShipmentCalcUtil.fgMethod();
        BVCShipmentCalcUtil.fMethod();
        test.stopTest();

    }

}