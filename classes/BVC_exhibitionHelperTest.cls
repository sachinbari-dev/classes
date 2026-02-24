@isTest
public class BVC_exhibitionHelperTest {

    @TestSetup
    
    public static void testfactory(){
        
         Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '94746367837';
        Acc.BillingState = 'MH';
        Acc.BillingPostalCode = '431122';
        
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';      
        Insert Acc;
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467H';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '9877287843';
        insert shippingAcc;
        
         Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi ';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi ', newHub.Name);
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Hub__c = newHub.id;
      
        insert pin;
        
        
        AddressBook__c TestAdd1 = New AddressBook__c();
        TestAdd1.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd1.Name = 'testShippingaddress';
        TestAdd1.GSTIN__c = '';
        TestAdd1.TRADE_NAME__c = shippingAcc.Name;
        TestAdd1.Customer__c = shippingAcc.id; 
        TestAdd1.Source__c = 'Manual';
        TestAdd1.Your_Address_Identifier__c = 'billing';
        TestAdd1.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd1.ADDRESS1__c = 'ABC Street';
        TestAdd1.CITY__c = 'Test City';
        TestAdd1.STATE__c = 'Test State';
        TestAdd1.COUNTRY__c = 'Test Country';
        TestAdd1.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd1;
        
        ST_Exhibition__c E = new ST_Exhibition__c();
        E.Name = 'test Expo';
        E.ST_Active__c = true;
        
        insert E;
        
        Shipment__c s = new shipment__c();
        s.Customer__c = Acc.id;
        s.Shipper_Name_TMS__c = shippingAcc.id;
        s.Consignee_Name_TMS__c = shippingAcc.id;
        s.Origin_Address_Name__c = testAdd1.Id;
        s.Destination_Address_Name__c = TestAdd1.Id;
        s.Exhibition__c = e.id;
        s.IsExhibition__c = true;
        
        insert S;
        
        delivery__c d = new delivery__c();
        d.Shipment__c = s.id;
        
        insert d;
        
        secure_packaging__c sp = new secure_packaging__c();
        sp.Name = 'TH73433';
        sp.RecordTypeId =Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
        sp.Type_of_Packaging__c = '	Secure Seal';
        insert sp;
        
        secure_bag__c sb = new secure_bag__c();
        sb.Shipment__c = s.id;
        sb.Finalised_Linehaul_Number__c = 'Test8743';
        sb.Seal_Id__c = sp.id;
        insert sb;
    }
    
    @isTest
    public static void Testmethod1(){
        
        List<Shipment__c> sList = [select id,IsExhibition__c,Exhibition__c,Tracking_Status__c, name from shipment__c  LIMIT 1 ];
        List<secure_bag__c> sblist = [select id,name ,Is_Exhibition__c,shipment__c from secure_bag__c LIMIT 1];
        
        Map<Id, Secure_Bag__c> oldMap = new Map<Id, Secure_Bag__c>();
        oldmap.put(sblist[0].id,sbList[0]);
        
        Map<Id, Shipment__c> shipoldMap = new Map<Id, Shipment__c>();
        shipoldMap.put(sList[0].id,sList[0]);
        
        Test.startTest();
          //  BVC_exhibitionHelper.removeSealIdAndAwbNumberFromBag(sList);
            BVC_exhibitionHelper.udpateSecurebagsIsExhibition(sblist, oldMap);
          //  BVC_exhibitionHelper.updateSecureBagIsExhibitionToFalse(sList, shipoldMap);
        Test.StopTest();
        
    }
    
   @isTest
   public static void TestMethod2() {

    // STEP 1: Query original Shipment (OLD state)
    Shipment__c oldShipment = [
        SELECT Id, IsExhibition__c, Exhibition__c, Tracking_Status__c, Name
        FROM Shipment__c
        LIMIT 1
    ];

    
    Map<Id, Shipment__c> shipOldMap = new Map<Id, Shipment__c>{
        oldShipment.Id => oldShipment.clone(false, true, false, false)
    };

    // STEP 3: Modify NEW values (simulate update)
    oldShipment.IsExhibition__c = false;
    oldShipment.Exhibition__c = null;
    update oldShipment;

    // STEP 4: Query updated shipment (Trigger.new equivalent)
    List<Shipment__c> sList = [
        SELECT Id, IsExhibition__c, Exhibition__c, Tracking_Status__c, Name
        FROM Shipment__c
        WHERE Id = :oldShipment.Id
    ];

    // STEP 5: Secure Bag oldMap (if helper expects it)
    Secure_Bag__c sb = [
        SELECT Id, Name, Is_Exhibition__c, Shipment__c
        FROM Secure_Bag__c
        LIMIT 1
    ];

    Map<Id, Secure_Bag__c> sbOldMap = new Map<Id, Secure_Bag__c>{
        sb.Id => sb.clone(false, true, false, false)
    };

    Test.startTest();
      //  BVC_exhibitionHelper.removeSealIdAndAwbNumberFromBag(sList);
        BVC_exhibitionHelper.updateSecureBagIsExhibitionToFalse(sList);
    Test.stopTest();
}
    

}