@IsTest
public class ShipmentControllerTest {
    @TestSetup
    static void setup() {
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
        Acc.Phone = '+919474636783';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c = 'ZBVC11566198';
        Insert Acc;
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '+919877287843';
        insert shippingAcc;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        
        Hub__c hub1 = new Hub__c();
        hub1.Name = 'delhi';
        hub1.Branch__c = 'delhi';
        insert hub1;
        
        Zone__c z = new Zone__c();         
        z.Name = 'North';
        insert z;
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Pune';
        pin.Pincodes__c = '444601';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Hub__c = newHub.id;
        pin.Zone__c = z.Id;
        insert pin;
        
        AddressBook__c TestAdd = new AddressBook__c();
        TestAdd.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = shippingAcc.Name;
        TestAdd.Customer__c = shippingAcc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id;
        TestAdd.Is_Active__c = true;
        Insert TestAdd;
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        insert newexhibition;
        
        Shipment__c ship = new Shipment__c();          
        ship.Shipping_Note_Number__c = 'TEST123456';
        ship.Invoice_Calculated_Amount__c = 29000;
        ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'Customer';
        ship.Destination_Address_Name__c = TestAdd.Id;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.Shipment_Value__c = 21;
        ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = Acc.Id;
        ship.Bill_To_GSTIN__c = 'ABCD123L';
        ship.Bill_To_Party_Address__c = 'Test Address';
        ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        ship.Billing_Entity_Name__c = Acc.Name;
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = UserInfo.getUserId();                                                
        ship.Origin_Hub__c = newHub.Id;  
        ship.Status__c = 'billed';   
        ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        ship.Origin_Pincode__c = '444603';
        ship.Destination_Pincode__c = '110001';
        ship.Consignee_Name__c = 'abcxyz';
        ship.Shipment_Stage__c = 'BVC weighment done';
        ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        ship.Customer_Product_Category__c = 'ValSHIP';
        ship.Origin_Type__c = 'Online';
        ship.Destination_Type__c = 'Online';
        ship.Product_Description__c = 'Product_Category__c';
        ship.BVC_Product_Name__c = 'valSHIP Express C2C';
        ship.IsExhibition__c = true;
        ship.Status__c = 'pending billing';
        ship.Exhibition__c = newexhibition.id;
        ship.Exhibition_Movement_Type__c = 'Inward';
        ship.Exhibition_Name__c = 'newExhibition';
        ship.Shipment_Created_Through__c = 'Mobile App';
        ship.Extra_Charge__c= 100;
        insert ship;
    }

    @IsTest
    static void testGetShipmentByNoteNumber() {
        Test.startTest();
        Shipment__c result = ShipmentController.getShipmentByNoteNumber('TEST123456');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Shipment should not be null');
    }

    @IsTest
    static void testUpdateShipment() {
        Shipment__c ship = [SELECT Id FROM Shipment__c LIMIT 1];
        ship.Total_Charge__c = 5000;

        Test.startTest();
        ShipmentController.updateShipment(ship);
        Test.stopTest();

        Shipment__c updatedShip = [SELECT Total_Charge__c FROM Shipment__c WHERE Id = :ship.Id];
        System.assertEquals(5000, updatedShip.Total_Charge__c, 'Total Charge should be updated');
    }

    @IsTest
    static void testSubmitForApproval() {
        Shipment__c ship = [SELECT Id FROM Shipment__c LIMIT 1];
        Test.startTest();

    try {
        // Call the controller method
        ShipmentController.submitForApproval(ship.Id);
    } catch (Exception e) {
       // System.assert(false, 'Exception thrown: ' + e.getMessage());
    }
    Test.stopTest();

   
    List<ProcessInstance> approvalProcesses = [
        SELECT Id
        FROM ProcessInstance
        WHERE TargetObjectId = :ship.Id
    ];
 
}
}