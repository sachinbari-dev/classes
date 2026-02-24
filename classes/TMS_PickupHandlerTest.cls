@isTest(seeAllData=true)
public class TMS_PickupHandlerTest {    
    @isTest
    public static void TestupdatePickUp(){      
        Pickup__c pick = [select Id,(Select Id from Shipments__r) from Pickup__c WHERE Id IN (SELECT Pickup__c FROM Shipment__c where Tracking_Status__c='Created') limit 1];
        Map<Id,Pickup__c> oldMap = new Map<Id,Pickup__c>();
        oldMap.put(pick.Id,pick);
        List<Pickup__c> pickupList = new List<Pickup__c>();
        Pickup__c Newpick = pick;
        Newpick.Pickup_Status__c='Completed';
        pickupList.add(Newpick);
        PickupTriggerHelper.handlePickupCompleted(pickupList,oldMap);
        pickupList[0].Pickup_Status__c='Completed';
        System.debug('12 oldMap :'+oldMap);
        System.debug('12 pickupList :'+pickupList);
        try
        {
           PickupTriggerHelper1.handlePickupCompleted(pickupList,oldMap); 
        } catch(exception e){}
        
        Set<Id> pkIdList = new Set<Id>();
        pkIdList.add(pick.Id);
       //PickupTriggerHelperBatch batchExe = new PickupTriggerHelperBatch(pkIdList);
      //Database.executeBatch(batchExe, 20);
    }  
    @isTest(seeAllData=false)
    public static void TestupdatePickUp1(){ 
         Profile p = [SELECT Id FROM Profile WHERE Name='Operations Field Executive'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser@bvcl.com');
        insert u;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Pickup_Delivery_Route__c pd= new Pickup_Delivery_Route__c(Name='TestPickup',Pickup_Route_Assigned_To__c=u.Id
                                                                  ,Hub__c=DelhiHub.Id);
        insert pd;  
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',false);
        ShipperAcc.PAN_Number_of_Entity__c ='EZBBS2122M';
        insert ShipperAcc;
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('210111', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        ShipperAddress.Pickup_Route_Number__c=pd.Id;
        update ShipperAddress; 
        Pickup__c pick = BVCL_TestDataFactory.CreatePickup(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, false);
        
        pick.BVC_Origin_Hub__c = DelhiHub.id;
        pick.Pickup_Assigned_To__c = UserInfo.getUserId();
        insert pick;
        pick.Pickup_Assigned_To__c = u.id;
        update pick;       
    }
}