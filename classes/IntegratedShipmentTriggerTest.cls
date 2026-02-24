@isTest
public class IntegratedShipmentTriggerTest {
    public static String CRON_EXP = '0 0 0 24 7 ? 2022';   
    
    @isTest
    public static void integratedShipmentTriggerTestMethod(){                
        test.startTest();
        ShipmentsTriggerHelper newHelper = new ShipmentsTriggerHelper(); 
        Map<Id,Shipment__c> newShipmentMap = new Map<Id,Shipment__c>();
        Map<Id,Shipment__c> oldShipmentMap = new Map<Id,Shipment__c>();
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> UpdateShipmentlist = new List<shipment__c>();
        
        user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];
        
      
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
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        
        Account Ac = New Account();
        Ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Ac.Name = 'TITANS COMPANY LIMITED - Billing EQUPNB123U';
        Ac.BVC_Company_Type__c = 'Domestic';        
        Ac.KYC_Indicator_for_Domestic_Flag__c = true;
        Ac.Customer_Status__c = 'Active';
        Ac.Category__c = 'Manufacturer';
        Ac.Type_Of_Customer__c = 'Both';
        Ac.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Ac.Primary_Customer_Email__c = 'abc@sdcn.com';
        Ac.Phone = '94746367837';
        Ac.BillingState = 'MH';
        Ac.BillingPostalCode = '431122';
        Ac.ParentId = Acc.id;
        Ac.First_Name__c = 'billing firstname';               
        Ac.Last_Name__c = 'billing lst name';
        //     Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Ac.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Ac.PAN_Number_of_Entity__c = 'EQUPNB123R';      
        Insert Ac;
        
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
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        con.MobilePhone = '+919876567876';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi ';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi ', newHub.Name);
        
        
        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
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
        pin.Zone__c = z.Id;
        insert pin;
        
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
        
        Acc = [select id,Name from Account where ID =: Acc.id];
        
        Acc.Primary_Address__c = TestAdd.id;
        Acc.Billing_Address__c = TestAdd.id;
        Acc.Is_Finance_Contact_Present__c=true; 
        Acc.KYC_Status__c='API Verified';
        update Acc;
        
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
        
        shippingAcc = [select id,name from Account where id =: shippingAcc.id];
        shippingAcc.Primary_Address__c = TestAdd1.Id;
        shippingAcc.Billing_Address__c = TestAdd1.Id;
        
        update shippingAcc;
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        newexhibition.ST_Active__c=true;
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.Pickup_Assigned_To__c=UserInfo.getUserId();
        //   TestPick.Name = 'TestPickup';
        Insert TestPick; 
        
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = newhub.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
        
        Acc = [SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:Acc.id];
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'BVC';
        ship.Billing_Account__c = Ac.Id;
        ship.Billing_Address__c =  Acc.Primary_Address__r.id;
        ship.Shipper_Name_TMS__c = shippingAcc.id;  
        ship.Consignee_Name_TMS__c = shippingAcc.Id;
        ship.Origin_Address_Name__c = testAdd1.id;
        ship.Destination_Address_Name__c = TestAdd1.Id;
        ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = TestPick.id;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
       // Ship.Billing_Entity_Name__c = Acc.Name; //commented for uninstallation of CPQ
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = u.id;                                                
        ship.Origin_Hub__c= newHub.Id;  
        ship.Status__c = 'billed';   
        Ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        ship.Shipment_Value__c = 155327;
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Consignee_Name__c = 'abcxyz';
        //  ship.Shipment_Lot__c = newLot.id;
        ship.Gross_Weight__c = 12.2;
        ship.Shipment_Stage__c = 'BVC weighment done';
        Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        ship.Delivery_Route_Number__c = newpickup.Id;
        ship.Customer_Product_Category__c = 'ValSHIP';
        ship.Origin_Type__c = 'Online';
        ship.Destination_Type__c = 'Online';
        ship.Product_Description__c = 'Product_Category__c';
        ship.BVC_Product_Name__c = 'valSHIP within city';
        ship.BVC_Product_Name__c = 'valSHIP Surface C2C';
        ship.BVC_Product_Name__c = 'valSHIP Express C2C';
        ship.IsExhibition__c = true;
        ship.Status__c = 'pending billing';
        ship.Exhibition__c = newexhibition.id;
        ship.Exhibition_Movement_Type__c= 'Inward';
        ship.Exhibition_Name__c = 'newExhibition';          
        ship.Shipment_Created_Through__c = 'Mobile App';                     
        ship.Product_Code__c = '';  
        ship.Shipment_Created_Through__c = '';
        ship.Actual_Delivery_Date_and_Time__c = Datetime.newInstance(2025,9,5,10,0,0);  
        ship.Destination_Hub__c = newhub.id;
        insert ship;
        //newShipmentlist.add(ship);
        oldShipmentMap.put(ship.id,ship);   
        
        Secure_Bag__c secObj = new Secure_Bag__c();
        
        secObj.Shipment__c = Ship.Id;
        //Name = 'SB-145869';
        secObj.Current_Origin_City__c = 'Mumbai';                                            
        secObj.Is_Misrouted__c = false;                                                      
        secObj.Is_Count_Mismatch__c = false;                                                 
        //POD__c = false,                                                        
        secObj.Current_Scan_Loction__c = 'Delivered';                                        
        secObj.Last_Scan_Location__c = 'Out for Delivery';
        
        
        insert secObj;
        
        Pickup_Delivery_Route__c  newpickups = new Pickup_Delivery_Route__c();
        newpickups.Delivery_Route_Number__c = 'RTNO-47';
        newpickups.Hub__c = newhub.id;
        //      newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickups;
        
        
        ship.Billing_Account__c = Ac.id;
        ship.Billing_Address__c = Ac.Primary_Address__r.id;                      
        ship.Invoice_Calculated_Amount__c = 434;
        //   ships.Tracking_Status__c = 'out for pickup';
        ship.Gross_Weight__c = 3.4;
        ship.Net_Weight__c = 1.2;
        ship.Shipment_Value__c = 3232;          
        ship.Delivery_Route_Assigned_To__c = u.id;
        ship.Status__c = 'ACR Consumed';
        ship.Customer_Invoice_Number__c = '34343';
        //      ships.OwnerId = u.id;        
        ship.Shipment_Created_Through__c = 'Service'; 
        ship.Delivery_Route_Number__c =newpickups.Id ;
        //   ship.Customer_Product_Category__c = 'bath';
        //   ship.Verified_for_Billling__c = 'NO';
        //    ship.Verified_for_Billing__c  = True;
        //    ship.Ready_for_Billing__c = true;
        //    ship.Rebilling_Reason__c = 'Wrong Weight';
        ship.Shipment_Created_Through__c = 'Mobile App';
        ship.Delivery_Route_Assigned_To__c =u.id;  
        update ship;
        
        
        ship.Total_Invoice_Value__c = 435654;
        ship.No_Of_Attempts__c = 1;
        //     ship.Delivery_Route_Assigned_To__c = u1.id;
        ship.Tracking_Status__c = 'Delivered';
        update ship;
        
        test.stoptest();
        
    }
    @isTest
    public static void integratedShipmentTriggerTestMethod3(){
        
        
        test.startTest();
        
        //      user u1 = [SELECT Id, Username, ProfileId FROM User where ProfileId ='00e5g000000HGU6AAO' LIMIT 1];   
        
        
        ShipmentsTriggerHelper newHelper = new ShipmentsTriggerHelper(); 
        Map<Id,Shipment__c> newShipmentMap = new Map<Id,Shipment__c>();
        Map<Id,Shipment__c> oldShipmentMap = new Map<Id,Shipment__c>();
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> UpdateShipmentlist = new List<shipment__c>();
        
        user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];
        
     
        
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
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        
        Account Ac = New Account();
        Ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Ac.Name = 'TITANS COMPANY LIMITED - Billing EQUPNB123U';
        Ac.BVC_Company_Type__c = 'Domestic';        
        Ac.KYC_Indicator_for_Domestic_Flag__c = true;
        Ac.Customer_Status__c = 'Active';
        Ac.Category__c = 'Manufacturer';
        Ac.Type_Of_Customer__c = 'Both';
        Ac.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Ac.Primary_Customer_Email__c = 'abc@sdcn.com';
        Ac.Phone = '94746367837';
        Ac.BillingState = 'MH';
        Ac.BillingPostalCode = '431122';
        Ac.ParentId = Acc.id;
        Ac.First_Name__c = 'billing firstname';               
        Ac.Last_Name__c = 'billing lst name';
        //     Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Ac.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Ac.PAN_Number_of_Entity__c = 'EQUPNB123R';    
        Ac.ST_Pricing_Type__c = 'Non ACR';
        Ac.Customer_Category__c = 'Non Contracted';
        
        
        Insert Ac;
        
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
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        con.MobilePhone = '+919876567876';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        
        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
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
        pin.Zone__c = z.Id;
        insert pin;
        
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
        
        Acc = [select id,Name from Account where ID =: Acc.id];
        
        Acc.Primary_Address__c = TestAdd.id;
        Acc.Billing_Address__c = TestAdd.id;
        Acc.Is_Finance_Contact_Present__c=true; 
        Acc.KYC_Status__c='API Verified';
        update Acc;
        
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
        
        shippingAcc = [select id,name from Account where id =: shippingAcc.id];
        shippingAcc.Primary_Address__c = TestAdd1.Id;
        shippingAcc.Billing_Address__c = TestAdd1.Id;
        
        update shippingAcc;
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        newexhibition.ST_Active__c=true;
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.Pickup_Assigned_To__c = UserInfo.getUserId();
        //   TestPick.Name = 'TestPickup';
        Insert TestPick; 
        
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = newhub.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
        
        Acc = [SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:Acc.id];
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'BVC';
        ship.Billing_Account__c = Ac.Id;
        ship.Billing_Address__c =  Acc.Primary_Address__r.id;
        ship.Shipper_Name_TMS__c = shippingAcc.id;  
        ship.Consignee_Name_TMS__c = shippingAcc.Id;
        ship.Origin_Address_Name__c = testAdd1.id;
        ship.Destination_Address_Name__c = TestAdd1.Id;
        ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = TestPick.id;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
      //  Ship.Billing_Entity_Name__c = Acc.Name;//commented for uninstallation of CPQ
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = u.id;                                                
        ship.Origin_Hub__c= newHub.Id;  
        ship.Status__c = 'billed';   
        Ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        ship.Shipment_Value__c = 155327;
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Consignee_Name__c = 'abcxyz';
        //  ship.Shipment_Lot__c = newLot.id;
        ship.Gross_Weight__c = 12.2;
        ship.Shipment_Stage__c = 'BVC weighment done';
        Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        ship.Delivery_Route_Number__c = newpickup.Id;
        ship.Customer_Product_Category__c = 'GoldSHIP';
        ship.Origin_Type__c = 'Online';
        ship.Destination_Type__c = 'Online';
        ship.Product_Description__c = 'Product_Category__c';
        ship.BVC_Product_Name__c = 'GoldSHIP within city';
        ship.BVC_Product_Name__c = 'GoldSHIP Surface C2C';
        ship.BVC_Product_Name__c = 'GoldSHIP Express C2C';
        ship.IsExhibition__c = true;
        ship.Status__c = 'pending billing';
        ship.Exhibition__c = newexhibition.id;
        ship.Exhibition_Movement_Type__c= 'Inward';
        ship.Exhibition_Name__c = 'newExhibition';          
        ship.Shipment_Created_Through__c = 'Mobile App';                     
        ship.Product_Code__c = '';  
        ship.Shipment_Created_Through__c = '';
        
        insert ship;
        //newShipmentlist.add(ship);
        oldShipmentMap.put(ship.id,ship);   
        
        Secure_Bag__c secObj = new Secure_Bag__c();
        
        secObj.Shipment__c = Ship.Id;
        //Name = 'SB-145869';
        secObj.Current_Origin_City__c = 'Mumbai';                                            
        secObj.Is_Misrouted__c = false;                                                      
        secObj.Is_Count_Mismatch__c = false;                                                 
        //POD__c = false,                                                        
        secObj.Current_Scan_Loction__c = 'Delivered';                                        
        secObj.Last_Scan_Location__c = 'Out for Delivery';
        
        insert secObj;
        
        Pickup_Delivery_Route__c  newpickups = new Pickup_Delivery_Route__c();
        newpickups.Delivery_Route_Number__c = 'RTNO-47';
        newpickups.Hub__c = newhub.id;
        //      newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickups;
        
        
        ship.Billing_Account__c = Ac.id;
        ship.Billing_Address__c = Ac.Primary_Address__r.id;                      
        ship.Invoice_Calculated_Amount__c = 434;
        //   ships.Tracking_Status__c = 'out for pickup';
        ship.Gross_Weight__c = 3.4;
        ship.Net_Weight__c = 1.2;
        ship.Shipment_Value__c = 3232;          
        ship.Delivery_Route_Assigned_To__c = u.id;
        ship.Status__c = 'ACR Consumed';
        ship.Customer_Invoice_Number__c = '34343';
        //      ships.OwnerId = u.id;        
        ship.Shipment_Created_Through__c = 'Service'; 
        ship.Delivery_Route_Number__c =newpickups.Id ;
        //   ship.Customer_Product_Category__c = 'bath';
        //   ship.Verified_for_Billling__c = 'NO';
        //    ship.Verified_for_Billing__c  = True;
        //    ship.Ready_for_Billing__c = true;
        //    ship.Rebilling_Reason__c = 'Wrong Weight';
        ship.Shipment_Created_Through__c = 'Mobile App';
        ship.Delivery_Route_Assigned_To__c =u.id;  
        update ship;
        
        
        ship.Total_Invoice_Value__c = 435654;
        ship.No_Of_Attempts__c = 1;
        //     ship.Delivery_Route_Assigned_To__c = u1.id;
        ship.Tracking_Status__c = 'Delivered';
        update ship;                        
        test.stoptest();
        
    }
    @isTest
    private static void testMethod3(){
        Id currentUserId = UserInfo.getUserId();
        User u =[SELECT Id, LastName, FirstName, Name, ProfileId FROM User where id=:currentUserId];
        
        Account acc1ACR = BVCL_TestDataFactory.createCustomer('BVCLBill Customer', 'Billing', true);
        Account shipperAcc = BVCL_TestDataFactory.createCustomer('BVCL Shipp Customer', 'Shipping', true);
        
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Test Hub', true, 'MUMBAI');
        Active_Pincode__c testPin = BVCL_TestDataFactory.CreatePincode('400001', testHub.Id, 'Mumbai', 'Mumbai City', true);
        AddressBook__c testAddrBilling = BVCL_TestDataFactory.CreateAddress('Billing', acc1ACR.Id, 'Test Line 1', testPin.Id, 'Mumbai', true);
        AddressBook__c testAddrShipping = BVCL_TestDataFactory.CreateAddress('Shipping', shipperAcc.Id, 'Test Line 1', testPin.Id, 'Mumbai', true);
        
        acc1ACR.Primary_Address__c = testAddrBilling.Id;
        update acc1ACR;
         RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Shipment__c'
            AND Name = 'Shipment Form'
            LIMIT 1
        ];
        Shipment__c ship = new Shipment__c(
            Customer_Product_Category__c='ValSHIP',
            Customer__c = acc1ACR.id,
            Shipper_Name_TMS__c = shipperAcc.Id,
            Origin_Address_Name__c= testAddrShipping.Id,
            Consignee_Name_TMS__c = shipperAcc.Id,
            Destination_Address_Name__c = testAddrShipping.Id,
            Product_Description__c = 'Gold Jewellery',
            Net_Weight__c = 11,
            Net_Weight_UOM_TMS__c = 'Gram',
            Gross_Weight__c = 12,
            Gross_Weight_UOM_TMS__c = 'Gram',
            Shipment_Value__c = 123456,
            RecordTypeId = rt.Id
        ); 
        insert ship;
        
        
        shipment__c s =[select id,name from shipment__c LIMIT 1];
        s.Tracking_Status__c = 'Destination Hub'; 
        s.Delivery_Route_Assigned_To__c = u.id;
        
        update s;
    }
    
    public static void integratedShipmentTriggerTestMethod1(){
        
        try{
            
            
            
            //      user u1 = [SELECT Id, Username, ProfileId FROM User where ProfileId ='00e5g000000HGU6AAO' LIMIT 1];   
            
            ShipmentsTriggerHelper newHelper = new ShipmentsTriggerHelper(); 
            Map<Id,Shipment__c> newShipmentMap = new Map<Id,Shipment__c>();
            Map<Id,Shipment__c> oldShipmentMap = new Map<Id,Shipment__c>();
            List<shipment__c> newShipmentlist = new List<shipment__c>();
            List<shipment__c> UpdateShipmentlist = new List<shipment__c>();
            
            user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];
            
        
            
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
            system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
            system.assertEquals('Active', Acc.Customer_Status__c);
            system.assertEquals('billing firstname', Acc.First_Name__c);
            
            
            Account Ac = New Account();
            Ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            Ac.Name = 'TITANS COMPANY LIMITED - Billing EQUPNB123U';
            Ac.BVC_Company_Type__c = 'Domestic';        
            Ac.KYC_Indicator_for_Domestic_Flag__c = true;
            Ac.Customer_Status__c = 'Active';
            Ac.Category__c = 'Manufacturer';
            Ac.Type_Of_Customer__c = 'Both';
            Ac.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
            Ac.Primary_Customer_Email__c = 'abc@sdcn.com';
            Ac.Phone = '94746367837';
            Ac.BillingState = 'MH';
            Ac.BillingPostalCode = '431122';
            Ac.ParentId = Acc.id;
            Ac.First_Name__c = 'billing firstname';               
            Ac.Last_Name__c = 'billing lst name';
            //     Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
            Ac.Name_As_Per_PAN_Manual_Input__c = 'new cust';
            Ac.PAN_Number_of_Entity__c = 'EQUPNB123R';      
            Insert Ac;
            
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
            
            Contact Con = New Contact();
            Con.LastName = 'TestContact';
            Con.AccountId = Acc.Id;
            Con.Email = 'abc123@paoj.com';
            con.MobilePhone = '+919876567876';
            Con.BVC_Finance_Contact__c = TRUE;
            Insert Con;
            
            Hub__c newHub = new Hub__c();
            newHub.Name = 'delhi Acr';
            newHub.Branch__c = 'delhi';
            insert newHub;
            system.assertEquals('delhi Acr', newHub.Name);
            
            
            Zone__c z =  new Zone__c();         
            z.Name= 'North';
            insert z;
            system.assertEquals('North', z.Name);
            
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
            pin.Zone__c = z.Id;
            insert pin;
            
            
            AddressBook__c TestAdd = New AddressBook__c();
            TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            TestAdd.Name = 'testaddress';
            TestAdd.GSTIN__c = '';
            TestAdd.TRADE_NAME__c = Acc.Name;
            TestAdd.Customer__c = Acc.id;
            TestAdd.Source__c = 'Manual';
            TestAdd.Your_Address_Identifier__c = 'billing';
            TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
            TestAdd.ADDRESS1__c = 'ABC Street';
            TestAdd.CITY__c = 'Test City';
            TestAdd.STATE__c = 'Test State';
            TestAdd.COUNTRY__c = 'Test Country';
            TestAdd.Active_Pincode__c = pin.Id ;
            
            Insert TestAdd;
            
            Acc = [select id,Name from Account where ID =: Acc.id];
            
            Acc.Primary_Address__c = TestAdd.id;
            Acc.Billing_Address__c = TestAdd.id;
            Acc.Is_Finance_Contact_Present__c=true; 
            Acc.KYC_Status__c='API Verified';
            update Acc;
            
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
            
            shippingAcc = [select id,name from Account where id =: shippingAcc.id];
            shippingAcc.Primary_Address__c = TestAdd1.Id;
            shippingAcc.Billing_Address__c = TestAdd1.Id;
            
            update shippingAcc;
            
            ST_Exhibition__c newexhibition = new ST_Exhibition__c();
            newexhibition.Name = 'New OFC opening';
            newexhibition.COA_Exhibition_Code__c = 'OFC-21';
            insert newexhibition ;
            
            Shipment_Lot__c newLot =  new Shipment_Lot__c();
            newLot.name = 'New Shipment Lot';
            insert newLot;                               
            
            Pickup__c TestPick = New Pickup__c();
            TestPick.Pickup_Date__c = System.Today();
            TestPick.Customer__c = Acc.Id;        
            TestPick.Origin_Address_Name__c = TestAdd.Id;
            TestPick.Destination_Address_Name__c = TestAdd.Id;
            //   TestPick.Name = 'TestPickup';
            Insert TestPick; 
            
            Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
            newpickup.Delivery_Route_Number__c = 'RTNO-45';
            newpickup.Hub__c = newhub.id;
            //        newpickup.Delivery_Route_Assigned_To__c = u.id;
            insert newpickup;
            
            Acc = [SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:Acc.id];
            
            Shipment__c ship = new Shipment__c();          
            ship.Invoice_Calculated_Amount__c = 29000;
            Ship.Total_Charge__c = 3456;
            ship.Customer__c = Acc.id; 
            ship.Insurance_By__c = 'BVC';
            ship.Billing_Account__c = Ac.Id;
            ship.Billing_Address__c =  Acc.Primary_Address__r.id;
            ship.Shipper_Name_TMS__c = shippingAcc.id;  
            ship.Consignee_Name_TMS__c = shippingAcc.Id;
            ship.Origin_Address_Name__c = testAdd1.id;
            ship.Destination_Address_Name__c = TestAdd1.Id;
            ship.Net_Weight__c = 12;
            ship.Net_Weight_UOM_TMS__c = 'Gram';
            ship.Shipment_Value__c = 21;
            ship.Pickup__c = TestPick.id;
            Ship.Total_Invoice_Value__c = 876;
            ship.Billing_Account__c = acc.Id;
            Ship.Bill_To_GSTIN__c = 'ABCD123L';
            Ship.Bill_To_Party_Address__c = 'Test Address';
            Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
          //  Ship.Billing_Entity_Name__c = Acc.Name;//commented for uninstallation of CPQ
            ship.AddressBook__c = TestAdd.Id;
            ship.Delivery_Route_Assigned_To__c = u.id;                                                
            ship.Origin_Hub__c= newHub.Id;  
            ship.Status__c = 'billed';   
            Ship.Shipper__c = 'abcxyz';
            ship.Tracking_Status__c = 'Delivered';          
            ship.Shipment_Value__c = 155327;
            Ship.Origin_Pincode__c = '444603';
            Ship.Destination_Pincode__c = '110001';
            Ship.Consignee_Name__c = 'abcxyz';
            //  ship.Shipment_Lot__c = newLot.id;
            ship.Gross_Weight__c = 12.2;
            ship.Shipment_Stage__c = 'BVC weighment done';
            Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
            ship.Delivery_Route_Number__c = newpickup.Id;
            ship.Customer_Product_Category__c = 'ValSHIP';
            ship.Origin_Type__c = 'Online';
            ship.Destination_Type__c = 'Online';
            ship.Product_Description__c = 'Product_Category__c';
            ship.BVC_Product_Name__c = 'valSHIP within city';
            ship.BVC_Product_Name__c = 'valSHIP Surface C2C';
            ship.BVC_Product_Name__c = 'valSHIP Express C2C';
            ship.IsExhibition__c = true;
            ship.Status__c = 'pending billing';
            ship.Exhibition__c = newexhibition.id;
            ship.Exhibition_Movement_Type__c= 'Inward';
            ship.Exhibition_Name__c = 'newExhibition';          
            ship.Shipment_Created_Through__c = 'Mobile App';                     
            ship.Product_Code__c = '';  
            ship.Shipment_Created_Through__c = '';
            
            
            insert ship;
            //newShipmentlist.add(ship);
            oldShipmentMap.put(ship.id,ship);   
            
            Secure_Bag__c secObj = new Secure_Bag__c();
            
            secObj.Shipment__c = Ship.Id;
            //Name = 'SB-145869';
            secObj.Current_Origin_City__c = 'Mumbai';                                            
            secObj.Is_Misrouted__c = false;                                                      
            secObj.Is_Count_Mismatch__c = false;                                                 
            //POD__c = false,                                                        
            secObj.Current_Scan_Loction__c = 'Delivered';                                        
            secObj.Last_Scan_Location__c = 'Out for Delivery';
            
            
            insert secObj;
            
            Map<Id,Account>mapOfIdVsAccount=new Map<Id,Account>([SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:Acc.id]);
            system.debug('map of accountupdate+++'+ mapOfIdVsAccount.values());
            
            Pickup_Delivery_Route__c  newpickups = new Pickup_Delivery_Route__c();
            newpickups.Delivery_Route_Number__c = 'RTNO-47';
            newpickups.Hub__c = newhub.id;
            //      newpickup.Delivery_Route_Assigned_To__c = u.id;
            insert newpickups;
            
            
            ship.Billing_Account__c = Ac.id;
            ship.Billing_Address__c = Ac.Primary_Address__r.id;                      
            ship.Invoice_Calculated_Amount__c = 434;
            //   ships.Tracking_Status__c = 'out for pickup';
            ship.Gross_Weight__c = 3.4;
            ship.Net_Weight__c = 1.2;
            ship.Shipment_Value__c = 3232;          
            ship.Delivery_Route_Assigned_To__c = u.id;
            ship.Status__c = 'ACR Consumed';
            ship.Customer_Invoice_Number__c = '34343';
            //      ships.OwnerId = u.id;        
            ship.Shipment_Created_Through__c = 'Service'; 
            ship.Delivery_Route_Number__c =newpickups.Id ;
            ship.Customer_Product_Category__c = 'bath';
            ship.Verified_for_Billling__c = 'NO';
            ship.Verified_for_Billing__c  = True;
            //    ship.Ready_for_Billing__c = true;
            //    ship.Rebilling_Reason__c = 'Wrong Weight';
            ship.Shipment_Created_Through__c = 'Mobile App';
            update ship;
            
            
            ship.Total_Invoice_Value__c = 435654;
            ship.No_Of_Attempts__c = 1;
            //     ship.Delivery_Route_Assigned_To__c = u1.id;
            ship.Tracking_Status__c = 'Delivered';
            update ship;
            // billing account update
            
            List<Shipment__c> newShipment2 = new List<Shipment__c>();   
            Shipment__c ship2 = new Shipment__c();          
            ship2.Invoice_Calculated_Amount__c = 29000;
            ship2.Total_Charge__c = 3456;
            ship2.Customer__c = Acc.id; 
            ship2.Insurance_By__c = 'BVC';
            ship2.Billing_Account__c = Ac.Id;
            ship2.Billing_Address__c =  Acc.Primary_Address__r.id;
            ship2.Shipper_Name_TMS__c = shippingAcc.id;  
            ship2.Consignee_Name_TMS__c = shippingAcc.Id;
            ship2.Origin_Address_Name__c = testAdd1.id;
            ship2.Destination_Address_Name__c = TestAdd1.Id;
            ship2.Net_Weight__c = 12;
            ship2.Net_Weight_UOM_TMS__c = 'Gram';
            ship2.Shipment_Value__c = 21;
            ship2.Pickup__c = TestPick.id;
            ship2.Total_Invoice_Value__c = 876;
            ship2.Billing_Account__c = acc.Id;
            ship2.Bill_To_GSTIN__c = 'ABCD123L';
            ship2.Bill_To_Party_Address__c = 'Test Address';
            ship2.Bill_To_Party_PAN__c = 'ABCD1234M';
        //    Ship.Billing_Entity_Name__c = Acc.Name;//commented for uninstallation of CPQ
            ship.AddressBook__c = TestAdd.Id;
            ship2.Delivery_Route_Assigned_To__c = u.id;                                                
            ship2.Origin_Hub__c= newHub.Id;  
            ship2.Status__c = 'billed';   
            ship2.Shipper__c = 'abcxyz';
            ship2.Tracking_Status__c = 'Delivered';          
            ship2.Shipment_Value__c = 155327;
            ship2.Origin_Pincode__c = '444603';
            ship2.Destination_Pincode__c = '110001';
            ship2.Consignee_Name__c = 'abcxyz';
            //  ship.Shipment_Lot__c = newLot.id;
            ship2.Gross_Weight__c = 12.2;
            ship2.Shipment_Stage__c = 'BVC weighment done';
            ship2.Consignee_Email_ID__c = 'abc@sdcn.com';
            ship2.Delivery_Route_Number__c = newpickup.Id;
            ship2.Customer_Product_Category__c = 'eSHIP';
            ship2.Origin_Type__c = 'Online';
            ship2.Destination_Type__c = 'Online';
            ship2.Product_Description__c = 'Product_Category__c';
            ship2.BVC_Product_Name__c = 'valSHIP within city';
            ship2.BVC_Product_Name__c = 'valSHIP Surface C2C';
            ship2.BVC_Product_Name__c = 'valSHIP Express C2C';
            ship2.IsExhibition__c = true;
            ship2.Status__c = 'pending billing';
            ship2.Exhibition__c = newexhibition.id;
            ship2.Exhibition_Movement_Type__c= 'Inward';
            ship2.Exhibition_Name__c = 'newExhibition';          
            ship2.Shipment_Created_Through__c = 'Mobile App';                     
            ship2.Product_Code__c = '';  
            ship2.Shipment_Created_Through__c = '';
            ship2.Created_through_BVCeSHIP__c = true;
            ship2.Verified_for_Billing__c = true;
            ship2.Verified_for_Billling__c = 'NO';
            
            newShipment2.add(ship2);               
            insert newShipment2;
            
            BVCQuote__c quote = new BVCQuote__c(
                Account__c = Ac.Id,
                Contracted__c = false,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addMonths(12),
                BVC_Service__c = 'eSHIP',
                Business_Type__c='ACR'
            );
            insert quote;
            
            BVCQuote__c quoteNonACR = new BVCQuote__c(
                Account__c = Ac.Id,
                Contracted__c = false,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addMonths(12),
                BVC_Service__c = 'eSHIP',
                Business_Type__c='Non ACR'
            );
            insert quoteNonACR;
            BVC_Contract__c bvcContracteSHIPNonACR = new BVC_Contract__c(
                Customer_Name__c = Ac.Id,
                Contract_Start_Date__c = Date.today(),
                Contract_End_Date__c = Date.today().addMonths(12),
                //Contracted_ACR_Package__c = 'Standard',
                Contract_Amount__c = 10000,
                Business_Type__c = 'Non ACR',
                Contract_Term_months__c = 12,
                Quote__c = quoteNonACR.Id,
                bvc_service__c='eSHIP',
                Is_Legacy_Contract__c=false,
                Slab_Criteria__c='Invoice Value INR',
                BVC_Branch__c=newHub.id
                //    BVC_Billing_Entity__c=legalEnty.id,
                //     BVC_Entity__c=entity.id
            );
            insert bvcContracteSHIPNonACR;
            
            eSHIP_Standard_Pricing__c standardPricing = new eSHIP_Standard_Pricing__c();
            standardPricing.RecordTypeId = Schema.SObjectType.eSHIP_Standard_Pricing__c.getRecordTypeInfosByName().get('Legacy eSHIP Pricing').getRecordTypeId();
            standardPricing.Rate_INR__c = 100;
            standardPricing.Liability_Charges__c = 50;
            standardPricing.COD_Charges_percentage_of_product__c = 10;
            standardPricing.Fuel_Surcharge__c = 5;
            standardPricing.UOM_Percentage__c = 1.5;
            standardPricing.Weight_Charges__c = 200;
            standardPricing.Per_Shipment_Freight_Charge__c = true;
            standardPricing.No_Of_Free_Atttemps__c = 2;
            standardPricing.Gross_Weight_Unit_for_Additional_Weight__c = 5;
            standardPricing.Additional_Charge__c = 20;
            standardPricing.COD_Charges_per_shipment__c = 30;
            
            system.debug('RecordTypeId@@@@'+standardPricing.RecordTypeId );
            insert standardPricing;
            system.debug('standardPricing@@@'+standardPricing);
            
            test.startTest();
          //  ShipmentTriggerBVCHelper.createOrderNew( newShipment2); //commented for uninstallation of CPQ
            test.stopTest();
        }catch(exception e){
            system.debug('error'+e);
        }
    }
    
    @isTest
    public static void  insertRecordBATHTest(){
        //Test.setMock(HttpCalloutMock.class, new ShipmentWebHookCalloutMock());
        try{
            
        
            String Uid = UserInfo.getUserId();
            Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
            insert hub;
            User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
            List<Hub__c> BVCbranchBatheShip = [select id,/*Billing_Entity_Name__c,*/Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];//commented for uninstallation of CPQ
            Account acc= new Account();
            acc.Name='Test';
            acc.Email__c = 'test@gmail.com';
            acc.First_Name__c = 'TestB';
            acc.Last_Name__c='Test';
            acc.Phone = '8765676545';
            acc.RecordTypeId='0125g0000002XavAAE';
            Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
            acc.PAN_Number_of_Entity__c='546gtyhu78';
            insert acc;
            Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
            insert entity;
          
            Hub__c newHub = new Hub__c();
            newHub.Name='MUMBAI-BDB';
            newHub.Branch__c='AGRA';
          //  newHub.Billing_Entity_Name__c=leObj.id; //commented for uninstallation of CPQ
            insert newHub;
            
            Zone__c newZone = new Zone__c();
            newZone.Name='data Zone';
            insert newZone;
            Active_Pincode__c newActivePinCode = new Active_Pincode__c();
            newActivePinCode.Pincodes__c='43785';
            newActivePinCode.City__c='Agra';
            newActivePinCode.Country__c='India';
            newActivePinCode.State__c='Delhi';
            newActivePinCode.Hub__c=newHub.ID;
            newActivePinCode.Zone__c=newZone.Id;
            insert newActivePinCode;
            
            AddressBook__c BillingAdd = new AddressBook__c();
            BillingAdd.RecordTypeId='0125g0000002Xb0AAE';
            BillingAdd.Customer__c=acc.Id;
            BillingAdd.Your_Address_Identifier__c='shivaji Ward';
            BillingAdd.ADDRESS1__c='shivaji ward Ghatanji';
            BillingAdd.TRADE_NAME__c='TEST';
            BillingAdd.Active_Pincode__c=newActivePinCode.Id;
            insert BillingAdd;
            acc.Billing_Address__c=BillingAdd.Id;
            acc.Primary_Address__c=BillingAdd.Id;
            acc.Is_Finance_Contact_Present__c=true;
            acc.KYC_Status__c='API Verified';
            acc.Name_As_Per_PAN_Manual_Input__c='TESTKYC';
            //acc.Name_As_Per_PAN__pc='TESTKYC';
            acc.KARZAA_Name_As_Per_PAN__c='TESTKYC';
            acc.Trade_Name__c='TESTKYC';
            update acc;
         
            List<Shipment__c> ListShipment = new List<Shipment__c>();
            Shipment__c Shipment = new Shipment__c();
            Shipment.Customer__c=acc.ID;
            shipment.Is_Uploaded__c=false;
            shipment.Customer_Product_Category__c='BATH';
            Shipment.Product_Category__c='Studded Jewellery';
            Shipment.Total_Invoice_Value__c=90;
            Shipment.Origin_Destination_Pairing__c='Within City';
            Shipment.Visit_Outcome__c='Successful';
            shipment.Net_Weight__c=490;
            shipment.Gross_Weight__c=560;
            shipment.Shipment_Type__c='Intercity';
            shipment.Net_Weight_UOM__c='Gram';
            shipment.Gross_Weight_UOM__c='Gram';
            ListShipment.add(Shipment);
         /*   qT.Shipment__c=shipment.Id;
            update qT;*/ //commented for uninstallation of CPQ
            
            Test.startTest();
            insert ListShipment;
            Shipment.Gross_Weight__c=900;
            update ListShipment;
            shipment.Quick_Calculate_Shipment__c = true;
            update ListShipment;
            Shipment.Verified_for_Billing__c=true;
            update ListShipment;
            Shipment.Ready_for_Rebilling__c=true;
            Shipment.Rebilling_Reason__c='Wrong Customer';
            Shipment.Remark__c='TEST';
            update ListShipment;
            Test.stopTest();       
        }catch(exception e){
            system.debug('error:'+ e);
        }
        
    }
    @isTest
    public static void  insertRecordeSHIPTest(){
        try{
            
       
            String Uid = UserInfo.getUserId();
            Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
            insert hub;
            User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
            List<Hub__c> BVCbranchBatheShip = [select id,/*Billing_Entity_Name__c,*/Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];//commented for uninstallation of CPQ
            
            Account acc= new Account();
            Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            Acc.Name = 'Test';
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
            insert acc;
            
            Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
            insert entity;
         
            Hub__c newHub = new Hub__c();
            newHub.Name='MUMBAI-BDB';
            newHub.Branch__c='AGRA';
          //  newHub.Billing_Entity_Name__c=leObj.id;//commented for uninstallation of CPQ
            insert newHub;
            
            Zone__c newZone = new Zone__c();
            newZone.Name='data Zone';
            insert newZone;
            Active_Pincode__c newActivePinCode = new Active_Pincode__c();
            newActivePinCode.Pincodes__c='43785';
            newActivePinCode.City__c='Agra';
            newActivePinCode.Country__c='India';
            newActivePinCode.State__c='Delhi';
            newActivePinCode.Hub__c=newHub.ID;
            newActivePinCode.Zone__c=newZone.Id;
            insert newActivePinCode;
            
            AddressBook__c BillingAdd = new AddressBook__c();
            BillingAdd.RecordTypeId='0125g0000002Xb0AAE';
            BillingAdd.Customer__c=acc.Id;
            BillingAdd.Your_Address_Identifier__c='shivaji Ward';
            BillingAdd.ADDRESS1__c='shivaji ward Ghatanji';
            BillingAdd.TRADE_NAME__c='TEST';
            BillingAdd.Active_Pincode__c=newActivePinCode.Id;
            insert BillingAdd;
            acc.Billing_Address__c=BillingAdd.Id;
            acc.Primary_Address__c=BillingAdd.Id;
            acc.Is_Finance_Contact_Present__c=true;
            acc.KYC_Status__c='API Verified';
            acc.Name_As_Per_PAN_Manual_Input__c='TESTKYC';
            //acc.Name_As_Per_PAN__pc='TESTKYC';
            acc.KARZAA_Name_As_Per_PAN__c='TESTKYC';
            acc.Trade_Name__c='TESTKYC';
            update acc;
        
            
            
            
            List<Shipment__c> ListShipment = new List<Shipment__c>();
            Shipment__c Shipment = new Shipment__c();
            Shipment.Customer__c=acc.ID;
            shipment.Is_Uploaded__c=false;
            shipment.Customer_Product_Category__c='eSHIP';
            Shipment.Product_Category__c='Studded Jewellery';
            Shipment.Total_Invoice_Value__c=90;
            Shipment.Origin_Destination_Pairing__c='Within City';
            Shipment.Visit_Outcome__c='Successful';
            shipment.Net_Weight__c=490;
            shipment.Gross_Weight__c=560;
            shipment.Shipment_Type__c='Intercity';
            shipment.Net_Weight_UOM__c='Gram';
            shipment.Gross_Weight_UOM__c='Gram';
            ListShipment.add(Shipment);
        /*    qT.Shipment__c=shipment.Id;
           // update qT;*/ //commented for uninstallation of CPQ
            
            
            
            
            Test.startTest();
            insert ListShipment;
            Shipment.Gross_Weight__c=900;
            update ListShipment;
            shipment.Quick_Calculate_Shipment__c = true;
            update ListShipment;
            //  Shipment.Verified_for_Billing__c=true;
            //     shipment.Verified_for_Billling__c ='NO';
            update ListShipment;
            //Shipment.Ready_for_Rebilling__c=true;
            //Shipment.Rebilling_Reason__c='Wrong Customer';
            //Shipment.Remark__c='TEST';
            //update ListShipment;
            
            
            Test.stopTest();  
            
        }catch (Exception e){
            system.debug('error:'+e);
        }
        
    }
    
  
    
    @isTest
    static void nonACRnonContractedShipmentTestMethod(){
        test.startTest();
        //sam
       
        Account acc1ACR = BVCL_TestDataFactory.createCustomer('BVCLBill Customer', 'Billing', true);
        Account shipperAcc = BVCL_TestDataFactory.createCustomer('BVCL Shipp Customer', 'Shipping', true);
        
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Test Hub', true, 'MUMBAI');
        Active_Pincode__c testPin = BVCL_TestDataFactory.CreatePincode('400001', testHub.Id, 'Mumbai', 'Mumbai City', true);
        AddressBook__c testAddrBilling = BVCL_TestDataFactory.CreateAddress('Billing', acc1ACR.Id, 'Test Line 1', testPin.Id, 'Mumbai', true);
        AddressBook__c testAddrShipping = BVCL_TestDataFactory.CreateAddress('Shipping', shipperAcc.Id, 'Test Line 1', testPin.Id, 'Mumbai', true);
        
        acc1ACR.Primary_Address__c = testAddrBilling.Id;
        update acc1ACR;
        
        
        
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Shipment__c'
            AND Name = 'Shipment Form'
            LIMIT 1
        ];
        Shipment__c ship = new Shipment__c(
            Customer_Product_Category__c='ValSHIP',
            Customer__c = acc1ACR.id,
            Shipper_Name_TMS__c = shipperAcc.Id,
            Origin_Address_Name__c= testAddrShipping.Id,
            Consignee_Name_TMS__c = shipperAcc.Id,
            Destination_Address_Name__c = testAddrShipping.Id,
            Product_Description__c = 'Gold Jewellery',
            Net_Weight__c = 11,
            Net_Weight_UOM_TMS__c = 'Gram',
            Gross_Weight__c = 12,
            Gross_Weight_UOM_TMS__c = 'Gram',
            Shipment_Value__c = 123456,
            RecordTypeId = rt.Id
        ); 
        insert ship;
        
        
        
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1ACR.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exemptlist.add(exempt);
        insert exemptlist;
        
        Shipment__c ship1 = [SELECT Id,Bill_To_Account__c,Shipment_Date__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,/*Bill_To_Account__r.Active_contract__c,*/
                            Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                            Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.BVC_LegalEntity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                            Origin_Type__c,Destination_Type__c,platform_User__c FROM Shipment__c where Id = :ship.Id];
        system.debug('Shipment Non ACR Non Contracted::Test::Class::'+ship.Bill_To_Account__r.Billing_Frequency__c);
        ship.Status__c = 'Pending Billing';
        
        update ship;
        
        
        ship.Liability_Cover_By_BVC__c = 'Yes';
        ship.Next_Billing_Date__c = system.today().adddays(3);
        ship.Status__c = 'Verified for Billing';
        ship.Product_Code__c = 'GOLD-EX-C2C';
        ship.Origin_Type__c = 'Offline';
        ship.Destination_Type__c = 'Offline';
        
        try{
            update ship;  
        } catch(exception ex){
            system.debug('Non Acr Non Contract Shipment Failed:'+ex.getMessage());
        }  
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = schemaMap.get('Shipment__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            
            fieldNames.add(fieldName);
            
        }        
        string query = 'SELECT '+String.join(fieldNames , ' , ')+' FROM Shipment__c WHERE Id = \''+String.valueOf(ship.Id)+'\'';
        List<Shipment__c> ships = Database.query(query);
        Set<Id> ids = new Set<Id>{ship.Id};
            List<Shipment__c> shipments = new List<Shipment__c>();
        shipments.addAll(ships);
        
        ShipmentOrderCreationBatch cb = new ShipmentOrderCreationBatch(ids);
        cb.execute(null,shipments);
        //Database.executeBatch(new );
        
        test.stopTest();
    }  
    @isTest
    static void TestMethod1(){
        list<BVCShipmentCalcUtil.ShipmentDetail> wrapList = new list<BVCShipmentCalcUtil.ShipmentDetail>();
        BVCShipmentCalcUtil.ShipmentDetail wrap = new BVCShipmentCalcUtil.ShipmentDetail();
        wrap.CommunityUniqueId = 'test';
        wrap.freightOnInvoice=0;
        wrap.perShipment = 0;
        wrap.prodName ='test';
        wrap.errors = 'test';
        wrap.exhibitionContractedPriceId = 'test';
        wrapList.add(wrap);
        
        Account acc1ACR = BVCL_TestDataFactory.createCustomer('BVCLBill Customer', 'Billing', true);
        Account shipperAcc = BVCL_TestDataFactory.createCustomer('BVCL Shipp Customer', 'Shipping', true);
        
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Test Hub', true, 'MUMBAI');
        Active_Pincode__c testPin = BVCL_TestDataFactory.CreatePincode('400001', testHub.Id, 'Mumbai', 'Mumbai City', true);
        AddressBook__c testAddrBilling = BVCL_TestDataFactory.CreateAddress('Billing', acc1ACR.Id, 'Test Line 1', testPin.Id, 'Mumbai', true);
        AddressBook__c testAddrShipping = BVCL_TestDataFactory.CreateAddress('Shipping', shipperAcc.Id, 'Test Line 1', testPin.Id, 'Mumbai', true);
        
        acc1ACR.Primary_Address__c = testAddrBilling.Id;
        update acc1ACR;
        
        
        
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Shipment__c'
            AND Name = 'Shipment Form'
            LIMIT 1
        ];
        Shipment__c ship = new Shipment__c(
            Customer_Product_Category__c='ValSHIP',
            Customer__c = acc1ACR.id,
            Shipper_Name_TMS__c = shipperAcc.Id,
            Origin_Address_Name__c= testAddrShipping.Id,
            Consignee_Name_TMS__c = shipperAcc.Id,
            Destination_Address_Name__c = testAddrShipping.Id,
            Product_Description__c = 'Gold Jewellery',
            Net_Weight__c = 11,
            Net_Weight_UOM_TMS__c = 'Gram',
            Gross_Weight__c = 12,
            Gross_Weight_UOM_TMS__c = 'Gram',
            Shipment_Value__c = 123456,
            RecordTypeId = rt.Id
        ); 
        insert ship;
        
        List<Exempted_City__c> exemptlist=new List<Exempted_City__c>();
        Exempted_City__c exempt=new Exempted_City__c();
        exempt.Customer__c=acc1ACR.Id;
        exempt.Exempted_City__c='Mumbai'; 
        exemptlist.add(exempt);
        insert exemptlist;
        
        Shipment__c ship1 = [SELECT Id,Bill_To_Account__c,Shipment_Date__c,Bill_To_Account__r.Billing_Frequency__c,BillTo_Party_Address__c,Origin_Address_Name__c,Destination_Address_Name__c,/*Bill_To_Account__r.Active_contract__c,*/
                             Bill_To_Account__r.Customer_Category__c,Bill_To_Account__r.Contract_End_Date__c,Bill_To_Account__r.Contracted_ACR_Package__c,Bill_To_Account__r.Balance_Amount__c,Shipment_Value__c,
                             Shipment_Number__c,Shipping_Note_Number__c,Origin_Hub__c,Bill_To_Account__r.Name,Origin_Hub__r.BVC_LegalEntity__c,Product_Code__c,Gross_Weight__c,Status__c,Ready_for_Billing__c,Liability_Cover_By_BVC__c,
                             Origin_Type__c,Destination_Type__c,platform_User__c FROM Shipment__c WHERE Id = :ship.Id];
        system.debug('Shipment Non ACR Non Contracted::Test::Class::'+ship.Bill_To_Account__r.Billing_Frequency__c);
        
        // ShipmentCalcUtil.shipmentCalculationNonACRContract(wrapList,mapAccount);       
    }
    
    @isTest
    static void shipmentHelperafterInsert(){
        helpMethod();
    }
    public static void helpMethod()
    {
        Map<Id,Shipment__c> newShipmentMap = new Map<Id,Shipment__c>();
        Map<Id,Shipment__c> oldShipmentMap = new Map<Id,Shipment__c>();
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> UpdateShipmentlist = new List<shipment__c>();        
        user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];              
       
        
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
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        
        Account Ac = New Account();
        Ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Ac.Name = 'TITANS COMPANY LIMITED - Billing EQUPNB123U';
        Ac.BVC_Company_Type__c = 'Domestic';        
        Ac.KYC_Indicator_for_Domestic_Flag__c = true;
        Ac.Customer_Status__c = 'Active';
        Ac.Category__c = 'Manufacturer';
        Ac.Type_Of_Customer__c = 'Both';
        Ac.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Ac.Primary_Customer_Email__c = 'abc@sdcn.com';
        Ac.Phone = '94746367837';
        Ac.BillingState = 'MH';
        Ac.BillingPostalCode = '431122';
        Ac.ParentId = Acc.id;
        Ac.First_Name__c = 'billing firstname';               
        Ac.Last_Name__c = 'billing lst name';
        //     Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Ac.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Ac.PAN_Number_of_Entity__c = 'EQUPNB123R';    
        Ac.ST_Pricing_Type__c = 'Non ACR';
        Ac.Customer_Category__c = 'Non Contracted';
        
        
        Insert Ac;
        
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
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        con.MobilePhone = '+919876567876';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        
        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
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
        pin.Zone__c = z.Id;
        insert pin;
        
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
        
        Acc = [select id,Name from Account where ID =: Acc.id];
        
        Acc.Primary_Address__c = TestAdd.id;
        Acc.Billing_Address__c = TestAdd.id;
        Acc.Is_Finance_Contact_Present__c=true; 
        Acc.KYC_Status__c='API Verified';
        update Acc;
        
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
        
        shippingAcc = [select id,name from Account where id =: shippingAcc.id];
        shippingAcc.Primary_Address__c = TestAdd1.Id;
        shippingAcc.Billing_Address__c = TestAdd1.Id;
        
        update shippingAcc;
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        newexhibition.ST_Active__c=true;
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.Pickup_Assigned_To__c = UserInfo.getUserId();
        Insert TestPick; 
        
        Pickup__c TestPick1 = New Pickup__c();
        TestPick1.Pickup_Date__c = System.Today();
        TestPick1.Customer__c = Acc.Id;        
        TestPick1.Origin_Address_Name__c = TestAdd.Id;
        TestPick1.Destination_Address_Name__c = TestAdd.Id;
        TestPick1.Pickup_Assigned_To__c = UserInfo.getUserId();
        Insert TestPick1;
        
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = newhub.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
        
        Acc = [SELECT Id,name,ParentId,Primary_Address__c,Primary_Address__r.id,(select id,name,Primary_Address__c,Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id =:Acc.id];
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'BVC';
        ship.Billing_Account__c = Ac.Id;
        ship.Billing_Address__c =  Acc.Primary_Address__r.id;
        ship.Shipper_Name_TMS__c = shippingAcc.id;  
        ship.Consignee_Name_TMS__c = shippingAcc.Id;
        ship.Origin_Address_Name__c = testAdd1.id;
        ship.Destination_Address_Name__c = TestAdd1.Id;
        ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = TestPick.id;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
      //  Ship.Billing_Entity_Name__c = Acc.Name;//commented for uninstallation of CPQ
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = u.id;                                                
        ship.Origin_Hub__c= newHub.Id;  
        ship.Status__c = 'billed';   
        Ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        ship.Shipment_Value__c = 155327;
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Consignee_Name__c = 'abcxyz';
        //  ship.Shipment_Lot__c = newLot.id;
        ship.Gross_Weight__c = 12.2;
        ship.Shipment_Stage__c = 'BVC weighment done';
        Ship.Consignee_Email_ID__c = 'abc@sdcn.com';
        ship.Delivery_Route_Number__c = newpickup.Id;
        ship.Customer_Product_Category__c = 'GoldSHIP';
        ship.Origin_Type__c = 'Online';
        ship.Destination_Type__c = 'Online';
        ship.Product_Description__c = 'Product_Category__c';
        ship.BVC_Product_Name__c = 'GoldSHIP within city';
        ship.BVC_Product_Name__c = 'GoldSHIP Surface C2C';
        ship.BVC_Product_Name__c = 'GoldSHIP Express C2C';
        ship.IsExhibition__c = true;
        ship.Status__c = 'pending billing';
        ship.Exhibition__c = newexhibition.id;
        ship.Exhibition_Movement_Type__c= 'Inward';
        ship.Exhibition_Name__c = 'newExhibition';          
        ship.Shipment_Created_Through__c = 'Mobile App';                     
        ship.Product_Code__c = '';  
        ship.Shipment_Created_Through__c = '';   
        ship.Tracking_Status__c='Created';
        insert ship;
        
        ship.Pickup__c = TestPick1.Id;
        update ship;
    }
    
}