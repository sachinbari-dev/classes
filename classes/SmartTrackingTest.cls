@isTest
global class SmartTrackingTest {

    @isTest
   global  static void testCreateSmartTrackingRecord() {
        // Create a test Shipment record and related Secure Bag records
        Shipment__c shipment = new Shipment__c();
        insert shipment;

        Secure_Bag__c secureBag1 = new Secure_Bag__c(
            //Secure_Packaging_Identifier__c = 'Bag1',
            Shipment__c = shipment.Id,Current_Scan_Loction__c='Created'
        );
        Secure_Bag__c secureBag2 = new Secure_Bag__c(
            //Secure_Packaging_Identifier__c = 'Bag2',
            Shipment__c = shipment.Id,Current_Scan_Loction__c='Created'
        );
        insert new List<Secure_Bag__c>{secureBag1, secureBag2};            
        Transport__c tp = new Transport__c(Name='test name',Vehicle_Number__c='123123') ;   
        insert tp;
        Transport__c tp2 = new Transport__c(Name='test name2',Vehicle_Number__c='123123') ;   
        insert tp2;  
        Hub__c	 hub1 = new Hub__c(Name='test hub1',Branch__c='Delhi');
        insert hub1;
        Hub__c	 hub2 = new Hub__c(Name='Chennai hub',Branch__c='Chennai');
        insert hub2;       
        Test.setMock(HttpCalloutMock.class,new SmartTrackingMockCall()); 
       
        Id BCRecordTypeId = Schema.SObjectType.Smart_Tracking__c.getRecordTypeInfosByName().get('Beacons').getRecordTypeId();
        Id BT300RecordTypeId = Schema.SObjectType.Smart_Tracking__c.getRecordTypeInfosByName().get('BT300').getRecordTypeId();
        Id BT300ARecordTypeId = Schema.SObjectType.Smart_Tracking__c.getRecordTypeInfosByName().get('BT300').getRecordTypeId();
        Id RRecordTypeId = Schema.SObjectType.Smart_Tracking__c.getRecordTypeInfosByName().get('Routers').getRecordTypeId();

		Smart_Tracking__c smtBeacon = new Smart_Tracking__c();
        Smart_Tracking__c smtBt300 = new Smart_Tracking__c();
        Smart_Tracking__c smtBt300SP = new Smart_Tracking__c();
        Smart_Tracking__c smtRouter = new Smart_Tracking__c();
        smtBeacon.Name ='Beacon';
        smtBeacon.Device_ID__c='Beacon123';
        smtBeacon.RecordTypeId=BCRecordTypeId;
        smtBeacon.Imei__c	='123456';
        smtBeacon.SB_Allocation__c=secureBag1.Id;
        smtBeacon.Is_allocated__c = true;
        insert smtBeacon;
        Smart_Tracking__c stup = [select Id,Name,RecordTypeId,SB_Allocation__c from Smart_Tracking__c where Id=:smtBeacon.Id limit 1];
        stup.SB_Allocation__c =secureBag2.Id;
        update stup;

        smtBt300.Name ='BT300';
        smtBt300.Device_ID__c='BT123';
        smtBt300.RecordTypeId=BT300RecordTypeId;
        smtBt300.Imei__c	='123477';
        smtBt300.V_Allocation__c=tp.Id;
        smtBt300.Is_allocated__c = true;
        insert smtBt300;
        Smart_Tracking__c stupBT = [select Id,Name,RecordTypeId,V_Allocation__c from Smart_Tracking__c where Id=:smtBt300.Id limit 1];
        stupBT.V_Allocation__c =tp2.Id;
        update stupBT;

        smtRouter.Name ='Router1';
        smtRouter.Device_ID__c='RT123';
        smtRouter.RecordTypeId=RRecordTypeId;
        smtRouter.Imei__c	='123488';
        smtRouter.H_Allocation__c=hub1.Id;
        smtRouter.Is_allocated__c = true;
        insert smtRouter;
        Smart_Tracking__c stupRT = [select Id,Name,RecordTypeId,H_Allocation__c from Smart_Tracking__c where Id=:smtRouter.Id limit 1];
        stupRT.H_Allocation__c =hub2.Id;
        update stupRT;        
		Secure_Packaging__c spk = new Secure_Packaging__c(Name='sp Name');
        insert spk;
		Secure_Packaging__c spk1 = new Secure_Packaging__c(Name='sp Name2');
        insert spk1;       

        smtBt300SP.Name ='SPBT300';
        smtBt300SP.Device_ID__c='BTSP123';
        smtBt300SP.RecordTypeId=BT300ARecordTypeId;
        smtBt300SP.Imei__c	='123499';
        smtBt300SP.TAllocation__c=spk.Id;
        smtBt300SP.Is_allocated__c = true;
        insert smtBt300SP;
        Smart_Tracking__c stupBTSP = [select Id,Name,RecordTypeId,TAllocation__c from Smart_Tracking__c where Id=:smtBeacon.Id limit 1];
        stupBTSP.TAllocation__c =spk1.Id;
        update stupBTSP;  
       // updating SecureBag
        Secure_Bag__c sbu = [select Id,Current_Scan_Loction__c,UUID__c from Secure_Bag__c where Id=:secureBag2.Id limit 1];
        sbu.Current_Scan_Loction__c='Delivered';
        sbu.UUID__c='123234';
        update sbu;
       
       // Update Hub
        Hub__c hhub = [select Id,Deallocated__c,UUID__c from Hub__c where Id=:hub2.Id limit 1];
        hhub.Deallocated__c=true;
        hhub.UUID__c='123212';
        update hhub;
       
       // update Transport
       Transport__c tsp = [select Id,Deallocated__c,UUID__c from Transport__c where Id=:tp2.Id limit 1];
       tsp.Deallocated__c=true;
       tsp.UUID__c='223311';
       update tsp;
       
       // update Secure Packaging
       Secure_Packaging__c scp = [select Id,Deallocated__c,UUID__c from Secure_Packaging__c where Id=:spk1.Id limit 1 ];
	   scp.Deallocated__c=true;
       scp.UUID__c='453456';
       update scp;
    }
}