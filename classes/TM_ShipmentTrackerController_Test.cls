/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TM_ShipmentTrackerController_Test {
    @isTest

    public static void Test1(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
         Secure_Packaging__c SP_Bag1= BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000334','Available',true);
          
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Origin Hub';
        bag1.Current_Scan_Hub__c = hub.id;
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag1;

         Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag1.id;
        bag2.Seal_Id__c = Seal.id;
        bag2.Current_Scan_Loction__c = 'Origin Hub';
        bag2.Current_Scan_Hub__c = hub.id;
        bag2.Current_Scan_Airport__c = Airport.id;
        insert bag2;
        
        
        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag1);
        BagList.add(bag2);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        TM_ShipmentTrackerController.bagBySealId(Seal.name);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        TM_ShipmentTrackerController.scanningInProgress(wr);
           
        BVC_Vault_Master__c vault = new BVC_Vault_Master__c();
        vault.Name ='Blr001';
        vault.BVC_Vault_Type__c='VAULT';
        insert vault;
        String isvault = vault.id;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.Hub__c = hub.id; 
        st.Scan_Time__c = system.now();
        //insert st;
        //
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
        //
        try{
            
       
        Test.startTest();
        TM_ShipmentTrackerController.bagBySecureBagId(SP_Bag.name,st,'');
        TM_ShipmentTrackerController.bagBySecureBagId(SP_Bag.name,st,'Misrouted');
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock',Seal.id);
        TM_ShipmentTrackerController.upadateScanBagsWithNoseal(st, BagList);
        
        Test.stopTest();
        }
       catch (Exception e) {
            throw new AuraHandledException(''+e);
       }
    }
@isTest    
public static void Test4(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Current_Scan_Hub__c = hub.id;
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag1;
        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag1);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        TM_ShipmentTrackerController.bagBySealId(Seal.name);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        TM_ShipmentTrackerController.scanningInProgress(wr);
           
        BVC_Vault_Master__c vault = new BVC_Vault_Master__c();
        vault.Name ='Blr001';
        vault.BVC_Vault_Type__c='VAULT';
        insert vault;
        String isvault = vault.id;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.Hub__c = hub.id; 
        st.Scan_Time__c = system.now();
        insert st;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock()); 
    	TM_ShipmentTrackerController.updateNormalBag(st, BagList,isvault,null);
    	Test.stopTest();
}
    
    @isTest    
    public static void Test2(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;

        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);

        //Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created'; 
        insert bag1;

        Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag.id;
        bag2.Seal_Id__c = Seal.id;
        bag2.Current_Scan_Loction__c = 'Created'; 
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag2;

        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag2);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.hub__c= hub.id;  
        
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
       try{
        Test.startTest();
        TM_ShipmentTrackerController.secureBagGet(SP_Bag.name);
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock',null);
        BagList = new List<Secure_Bag__c>();
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock',null);
        TM_ShipmentTrackerController.upadateScanBagsWithNoseal(st, BagList);
        Test.stopTest();
           
       }
        catch (Exception e) {
            throw new AuraHandledException(''+e);
       }
    }

    @isTest    
    public static void Test3(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
         Secure_Packaging__c Seal1 = BVCL_TestDataFactory.createPackaging('Secure Seal','HY74635','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
 
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Created';
        insert bag1;

        Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag.id;
        bag2.Seal_Id__c = Seal.id;
        bag2.Current_Scan_Loction__c = 'Created'; 
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag2;

        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag2);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id; 
        st.Location__c = 'Out for Delivery';
        
         Linehaul__c L = new Linehaul__c();
        l.AWB_Number__c = '55550000';
        l.Select_Airline__c = 'Indigo';
        l.Gross_Weight__c = 5465;
        l.Manual__c = True;
        l.Origin__c = 'Mumbai';
        l.Destination__c ='Hyderabad';
        l.AWB_Prefix__c = '312';
        
    
        insert l;
        
        Linehaul_Tracking__c Lt = new Linehaul_Tracking__c();
         Lt.Linehaul_Name__c = l.id;
         Lt.Finalized_Linehaul_Number__c = 'FL-HYD-MUM-34';
         Lt.Airline__c = 'Indigo';
         Lt.Status__c = 'AWB Finalized';
         Lt.Linehaul_Type__c = 'Air';
         lt.Trunks_Weight_Kgs__c = 65;
         lt.AWB_Number__c = l.AWB_Number__c;
         insert Lt;
        
        trunk__c tr = new trunk__c();
          tr.Left_Seal__c = seal.id;
          tr.RecordTypeId = Schema.SObjectType.trunk__c.getRecordTypeInfosByName().get('CPMT').getRecordTypeId();
         tr.Linehaul_Tracking__c = lt.id;
        insert tr;
        List<id>selectedTrunks = new List<id>{tr.id};
            
         trunk__c tr2 = new trunk__c();
          tr2.Left_Seal__c = seal1.id;
          tr2.RecordTypeId = Schema.SObjectType.trunk__c.getRecordTypeInfosByName().get('CPMT').getRecordTypeId();
          tr2.Linehaul_Tracking__c = lt.id;
        insert tr2;
        List<id>deselectedTrunks = new List<id>{tr2.id};
            Map<Id, String> trunkRemarks = new Map<Id, String>();
             trunkRemarks.put(tr2.id,'offloaded');
        
        FSE_Sales__c fs = new FSE_Sales__c();
        fs.Hub__c = hub.id;
        fs.Sales_Person__c = UserInfo.getUserId();
        
        insert fs;
        
        
                
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
        try{
        Test.startTest();
        TM_ShipmentTrackerController.secureBagGet(SP_Bag.name);
            TM_ShipmentTrackerController.fetchTrunksByAwb(l.AWB_Number__c, '312');
            TM_ShipmentTrackerController.getLoggedInUserHub();
            TM_ShipmentTrackerController.completeAwbProcess(selectedTrunks, deselectedTrunks, trunkRemarks, l.AWB_Number__c, Airport.id);
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock',null);
        BagList = new List<Secure_Bag__c>();
        TM_ShipmentTrackerController.updateSecureBag(st, BagList, wr, 'Unlock',null);
        TM_ShipmentTrackerController.LoggedInUserHub();
        TM_ShipmentTrackerController.LoggedInUserHubWithBranchName();
             TM_ShipmentTrackerController.getCoverage();
        TM_ShipmentTrackerController.getCoverage1();
        TM_ShipmentTrackerController.getCoverage2();
            TM_ShipmentTrackerController.getCoverage5();
        TM_ShipmentTrackerController.getCoverage6();
        TM_ShipmentTrackerController.getCoverage7();
        Test.stopTest();
        }
         catch (Exception e) {
            throw new AuraHandledException(''+e);
       }
    }



}