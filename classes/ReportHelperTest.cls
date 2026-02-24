/*Class      : ReportHelper
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : April 2024
 */


@isTest
public class ReportHelperTest {
@isTest
    public static void test1()
    {
        //test.startTest();  
        // user u= [SELECT Id,UserRole.Name,Username,isActive  FROM User WHERE UserRole.Name='EXECUTIVE' AND isActive=true LIMIT 1];
        user u= [SELECT Id,UserRole.Name,Username,isActive,International_Billing_Branch__c  
                 FROM User WHERE Profile.Name!='System Adminstrator' AND isActive=true AND International_Billing_Branch__c!=null LIMIT 1];
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> updateShipmentlist = new List<shipment__c>();

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
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '+919877287843';
        insert shippingAcc;
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Con.MobilePhone = '+919876567876';
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        
        Hub__c hub1 = new Hub__c();
        hub1.Name='delhi';
        hub1.Branch__c ='delhi';
        insert hub1;
        
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
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
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
        TestAdd.Active_Pincode__c = pin.Id ;
        TestAdd.Is_Active__c=true;
        Insert TestAdd;
        
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        newexhibition.ST_Active__c = true ;
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.BVC_Origin_Hub__c = hub1.id;
        Insert TestPick; 
		
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = hub1.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
        
        
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'Customer';
        // ship.Shipper_Name_TMS__c = shippingAcc.Name;
        // ship.Consignee_Name_TMS__c = shippingAcc.name;
        // ship.Origin_Address_Name__c = testAdd.name;
        ship.Destination_Address_Name__c = TestAdd.Id;
        //ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.CurrencyIsoCode ='';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = TestPick.id;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = Acc.Name;
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = UserInfo.getUserId();                                                
        ship.Origin_Hub__c= newHub.Id;  
        ship.Status__c = 'billed';   
        Ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Consignee_Name__c = 'abcxyz';
        //  ship.Shipment_Lot__c = newLot.id;
        //ship.Gross_Weight__c = 20;
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
        newShipmentlist.add(ship);                  
        insert newShipmentlist;
        
        
        ship.Insurance_By__c = 'Customer';
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.CurrencyIsoCode = '';
        //newShipmentlist.add(ship);
        update ship;
        
        Secure_Bag__c secObj = new Secure_Bag__c(
            Shipment__c = newShipmentlist[0].Id,                   
            Current_Origin_City__c = 'Mumbai',                                            
            Is_Misrouted__c = false,                                                      
            Is_Count_Mismatch__c = false,                                                 
            Current_Scan_Loction__c = 'Delivered',                                        
            Last_Scan_Location__c = 'Out for Delivery'
        );
        insert secObj;
        
        String bagData = 'jfgnkjfndgknjdfsgdfkgnlfdsnglndfnglnglnfldj';
        
        Integer nwc=0;
        String refNo ='';
        Integer IValue=0;
        String pickupId=newpickup.Id;
        String CustomerId=Acc.id;
        String SA_ID=shippingAcc.Id;
        String OAddressID=testAdd.Id;
        String CS_ACCID=shippingAcc.Id;
        String D_Address=TestAdd.Id;
        String BVCServices1='ValSHIP';
        String ProdcutDescription1='Dore Bar';
        String InsuranceBy1='BVC';
        String Receiver =null;
        List<Customer_Documents__c> ValList = new List<Customer_Documents__c>();
        String recName = Add_Shipment.getRecordId();
        datetime dtt = System.today();
        /*
        String AcName = Add_Shipment.createCustomer('Test',Acc.Id,'abcd','1234567890',
                                                    'www.google.com',dtt,'one','two','abc@gmail.com','1122334455');
         */
        List<Secure_Bag__c> sb = Add_Shipment.getAllSB(newShipmentlist[0].Id);
        //Customer_Documents__c cd1 = Add_Shipment.SaveInvoice(newShipmentlist[0].Id,0,0,'2000','','Gram','Invoice');
        Customer_Documents__c cd  = new Customer_Documents__c();
        cd.Shipment__c =newShipmentlist[0].Id;
        cd.Total_Net_Weight__c =50;
        cd.Invoice_Value__c =200;
        cd.Reference_number__c ='123';
        cd.Unit_Weight__c ='Gram';
        cd.CurrencyIsoCode ='';
        cd.Document_type__c ='Invoice';
        insert cd;

        Secure_Packaging__c sp = new Secure_Packaging__c();
        sp.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
        //sp.Shipment__c = Ship1.id;
        sp.Name = 'X0737246';
        sp.Status__c = 'Available';
        
        insert sp;                   
		Transport__c TP = new Transport__c(Name='Test');
        insert TP;
		FleetXJob__c fj = new FleetXJob__c(Vehicle_Number__c=TP.Id,startDateTime__c=System.now(),vehicleNumber__c='MH02ER5254',scheduleDeparture__c=System.now()); 
        insert fj;
        List<String> pickupIds = new List<String>();
        String  userId=UserInfo.getUserId();
        List<String> shipIds = new List<String>();
        List<String> LHIds = new List<String>();
        String jobId = fj.Id;
        shipIds.add(ship.Id);
        // pickupIds.add(TestPick.Id);
        // List<String> pickupIds4 = new List<String>();
        test.startTest();  
		ReportHelper.getPickups1();
        ReportHelper.getPickups(TestPick.Name);
        ReportHelper.getLinehauls('');
        ReportHelper.getShipments(ship.Shipping_Note_Number__c);
        ReportHelper.getShipments1();
        //ReportHelper.getDeliveries();     
        test.stopTest();        
    }
    
    @isTest
    public static void test2()
    {
       // test.startTest();  
        // user u= [SELECT Id,UserRole.Name,Username,isActive  FROM User WHERE UserRole.Name='EXECUTIVE' AND isActive=true LIMIT 1];
        user u= [SELECT Id,UserRole.Name,Username,isActive,International_Billing_Branch__c  
                 FROM User WHERE Profile.Name!='System Adminstrator' AND isActive=true AND International_Billing_Branch__c!=null LIMIT 1];
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> updateShipmentlist = new List<shipment__c>();

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
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '+919877287843';
        insert shippingAcc;
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Con.MobilePhone = '+919876567876';
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        
        Hub__c hub1 = new Hub__c();
        hub1.Name='delhi';
        hub1.Branch__c ='delhi';
        insert hub1;
        
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
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
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
        TestAdd.Active_Pincode__c = pin.Id ;
        TestAdd.Is_Active__c=true;
        Insert TestAdd;
        
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        newexhibition.ST_Active__c = True;
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.BVC_Origin_Hub__c = hub1.id;
        Insert TestPick; 
        
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = hub1.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
        
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'Customer';
        // ship.Shipper_Name_TMS__c = shippingAcc.Name;
        // ship.Consignee_Name_TMS__c = shippingAcc.name;
        // ship.Origin_Address_Name__c = testAdd.name;
        ship.Destination_Address_Name__c = TestAdd.Id;
        //ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.CurrencyIsoCode ='';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = TestPick.id;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = Acc.Name;
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = UserInfo.getUserId();                                                
        ship.Origin_Hub__c= newHub.Id;  
        ship.Status__c = 'billed';   
        Ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Consignee_Name__c = 'abcxyz';
        //  ship.Shipment_Lot__c = newLot.id;
        //ship.Gross_Weight__c = 20;
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
        newShipmentlist.add(ship);                  
        insert newShipmentlist;
        
        
        ship.Insurance_By__c = 'Customer';
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.CurrencyIsoCode = '';
        //newShipmentlist.add(ship);
        update ship;
        
        Secure_Bag__c secObj = new Secure_Bag__c(
            Shipment__c = newShipmentlist[0].Id,                   
            Current_Origin_City__c = 'Mumbai',                                            
            Is_Misrouted__c = false,                                                      
            Is_Count_Mismatch__c = false,                                                 
            Current_Scan_Loction__c = 'Delivered',                                        
            Last_Scan_Location__c = 'Out for Delivery'
        );
        insert secObj;
        
        String bagData = 'jfgnkjfndgknjdfsgdfkgnlfdsnglndfnglnglnfldj';
        
        Integer nwc=0;
        String refNo ='';
        Integer IValue=0;
        String pickupId=newpickup.Id;
        String CustomerId=Acc.id;
        String SA_ID=shippingAcc.Id;
        String OAddressID=testAdd.Id;
        String CS_ACCID=shippingAcc.Id;
        String D_Address=TestAdd.Id;
        String BVCServices1='ValSHIP';
        String ProdcutDescription1='Dore Bar';
        String InsuranceBy1='BVC';
        String Receiver =null;
        List<Customer_Documents__c> ValList = new List<Customer_Documents__c>();
        String recName = Add_Shipment.getRecordId();
        datetime dtt = System.today();
        /*
        String AcName = Add_Shipment.createCustomer('Test',Acc.Id,'abcd','1234567890',
                                                    'www.google.com',dtt,'one','two','abc@gmail.com','1122334455');
         */
        List<Secure_Bag__c> sb = Add_Shipment.getAllSB(newShipmentlist[0].Id);
        //Customer_Documents__c cd1 = Add_Shipment.SaveInvoice(newShipmentlist[0].Id,0,0,'2000','','Gram','Invoice');
        Customer_Documents__c cd  = new Customer_Documents__c();
        cd.Shipment__c =newShipmentlist[0].Id;
        cd.Total_Net_Weight__c =50;
        cd.Invoice_Value__c =200;
        cd.Reference_number__c ='123';
        cd.Unit_Weight__c ='Gram';
        cd.CurrencyIsoCode ='';
        cd.Document_type__c ='Invoice';
        insert cd;

        Secure_Packaging__c sp = new Secure_Packaging__c();
        sp.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
        //sp.Shipment__c = Ship1.id;
        sp.Name = 'X0737245';
        sp.Status__c = 'Available';
        
        insert sp;                   
		Transport__c TP = new Transport__c(Name='Test');
        insert TP;
		FleetXJob__c fj = new FleetXJob__c(Vehicle_Number__c=TP.Id,startDateTime__c=System.now(),vehicleNumber__c='MH02ER5254',scheduleDeparture__c=System.now()); 
        insert fj;
        Linehaul_Tracking__c lh = new Linehaul_Tracking__c();
        lh.Origin__c='BENGALURU';
        insert lh;
        
        List<String> pickupIds = new List<String>();
        String  userId=UserInfo.getUserId();
        List<String> shipIds = new List<String>();
        List<String> LHIds = new List<String>();
       // LHIds.add(lh.Id);
        String jobId = fj.Id;
       // shipIds.add(ship.Id);
        pickupIds.add(TestPick.Id);
        // List<String> pickupIds4 = new List<String>();
         test.startTest();    
		ReportHelper.getPickups1();
        ReportHelper.getPickups(TestPick.Name);
        ReportHelper.getLinehauls('');
        ReportHelper.getShipments(ship.Shipping_Note_Number__c);
        ReportHelper.getShipments1();
        //ReportHelper.getDeliveries();  
        ReportHelper.getInboundShipments(ship.Shipping_Note_Number__c);   
        test.stopTest();                
    }
@isTest
    public static void test3()
    {
      //  test.startTest();  
        // user u= [SELECT Id,UserRole.Name,Username,isActive  FROM User WHERE UserRole.Name='EXECUTIVE' AND isActive=true LIMIT 1];
        user u= [SELECT Id,UserRole.Name,Username,isActive,International_Billing_Branch__c  
                 FROM User WHERE Profile.Name!='System Adminstrator' AND isActive=true AND International_Billing_Branch__c!=null LIMIT 1];
        List<shipment__c> newShipmentlist = new List<shipment__c>();
        List<shipment__c> updateShipmentlist = new List<shipment__c>();

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
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '+919877287843';
        insert shippingAcc;
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Con.MobilePhone = '+919876567876';
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        
        Hub__c hub1 = new Hub__c();
        hub1.Name='delhi';
        hub1.Branch__c ='delhi';
        insert hub1;
        
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
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
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
        TestAdd.Active_Pincode__c = pin.Id ;
        TestAdd.Is_Active__c=true;
        Insert TestAdd;
        
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        newexhibition.ST_Active__c =true;
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.BVC_Origin_Hub__c = hub1.id;
        Insert TestPick; 
        
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = hub1.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
        
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'Customer';
        // ship.Shipper_Name_TMS__c = shippingAcc.Name;
        // ship.Consignee_Name_TMS__c = shippingAcc.name;
        // ship.Origin_Address_Name__c = testAdd.name;
        ship.Destination_Address_Name__c = TestAdd.Id;
        //ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.CurrencyIsoCode ='';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = TestPick.id;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = Acc.Name;
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = UserInfo.getUserId();                                                
        ship.Origin_Hub__c= newHub.Id;  
        ship.Status__c = 'billed';   
        Ship.Shipper__c = 'abcxyz';
        ship.Tracking_Status__c = 'Delivered';          
        
        Ship.Origin_Pincode__c = '444603';
        Ship.Destination_Pincode__c = '110001';
        Ship.Consignee_Name__c = 'abcxyz';
        //  ship.Shipment_Lot__c = newLot.id;
        //ship.Gross_Weight__c = 20;
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
        newShipmentlist.add(ship);                  
        insert newShipmentlist;
        
        
        ship.Insurance_By__c = 'Customer';
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.CurrencyIsoCode = '';
        //newShipmentlist.add(ship);
        update ship;
        
        Secure_Bag__c secObj = new Secure_Bag__c(
            Shipment__c = newShipmentlist[0].Id,                   
            Current_Origin_City__c = 'Mumbai',                                            
            Is_Misrouted__c = false,                                                      
            Is_Count_Mismatch__c = false,                                                 
            Current_Scan_Loction__c = 'Delivered',                                        
            Last_Scan_Location__c = 'Out for Delivery'
        );
        insert secObj;
        
        String bagData = 'jfgnkjfndgknjdfsgdfkgnlfdsnglndfnglnglnfldj';
        
        Integer nwc=0;
        String refNo ='';
        Integer IValue=0;
        String pickupId=newpickup.Id;
        String CustomerId=Acc.id;
        String SA_ID=shippingAcc.Id;
        String OAddressID=testAdd.Id;
        String CS_ACCID=shippingAcc.Id;
        String D_Address=TestAdd.Id;
        String BVCServices1='ValSHIP';
        String ProdcutDescription1='Dore Bar';
        String InsuranceBy1='BVC';
        String Receiver =null;
        List<Customer_Documents__c> ValList = new List<Customer_Documents__c>();
        String recName = Add_Shipment.getRecordId();
        datetime dtt = System.today();
        /*
        String AcName = Add_Shipment.createCustomer('Test',Acc.Id,'abcd','1234567890',
                                                    'www.google.com',dtt,'one','two','abc@gmail.com','1122334455');
         */
        List<Secure_Bag__c> sb = Add_Shipment.getAllSB(newShipmentlist[0].Id);
        //Customer_Documents__c cd1 = Add_Shipment.SaveInvoice(newShipmentlist[0].Id,0,0,'2000','','Gram','Invoice');
        Customer_Documents__c cd  = new Customer_Documents__c();
        cd.Shipment__c =newShipmentlist[0].Id;
        cd.Total_Net_Weight__c =50;
        cd.Invoice_Value__c =200;
        cd.Reference_number__c ='123';
        cd.Unit_Weight__c ='Gram';
        cd.CurrencyIsoCode ='';
        cd.Document_type__c ='Invoice';
        insert cd;

        Secure_Packaging__c sp = new Secure_Packaging__c();
        sp.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
        //sp.Shipment__c = Ship1.id;
        sp.Name = 'X0737245';
        sp.Status__c = 'Available';
        
        insert sp;                   
		Transport__c TP = new Transport__c(Name='Test');
        insert TP;
		FleetXJob__c fj = new FleetXJob__c(Vehicle_Number__c=TP.Id,startDateTime__c=System.now(),vehicleNumber__c='MH02ER5254',scheduleDeparture__c=System.now()); 
        insert fj;
        Linehaul_Tracking__c lh = new Linehaul_Tracking__c();
        lh.Origin__c='BENGALURU';
        insert lh;
        
        List<String> pickupIds = new List<String>();
        String  userId=UserInfo.getUserId();
        List<String> shipIds = new List<String>();
        List<String> LHIds = new List<String>();
        LHIds.add(lh.Id);
        String jobId = fj.Id;
       // shipIds.add(ship.Id);
       // pickupIds.add(TestPick.Id);
        // List<String> pickupIds4 = new List<String>();
        test.startTest();
		ReportHelper.getPickups1();
        ReportHelper.getPickups(TestPick.Name);
        ReportHelper.getLinehauls('');
        ReportHelper.getShipments(ship.Shipping_Note_Number__c);
        ReportHelper.getShipments1();
         ReportHelper.getInboundShipments(ship.Shipping_Note_Number__c);
       // ReportHelper.getDeliveries();     
        test.stopTest();                        
    }
    
     @isTest
    static void testGetDeliveries() {
     
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'test45user@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

       
        System.runAs(testUser) {
           
            Hub__c testHub = new Hub__c(
                Name = 'BENGALURU'
            
            );
            insert testHub;

          
            Shipment__c testShipment = new Shipment__c(
             
                Destination_Hub__c = testHub.Id
            );
            insert testShipment;

           
            Delivery__c testDelivery = new Delivery__c(
               
               Status__c = 'Accepted',
                Shipment__c = testShipment.Id             
            );
            insert testDelivery;

            
            List<Delivery__c> deliveries = ReportHelper.getDeliveries('');

            // Assert that the method returns the correct delivery
           // System.assertEquals(1, deliveries.size());
         // System.assertEquals(testDelivery.Id, deliveries[0].Id);
        }
    }

 @isTest
    static void testVehicleData() {
     
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'test45user@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

       
        System.runAs(testUser) {
           
            Hub__c testHub = new Hub__c(
                Name = 'BENGALURU'
            
            );
            insert testHub;

          
            Vehicle_Data__c TestVehicle = new Vehicle_Data__c(
             
                User_Hub__c = testHub.Id,
                Start_KM__c='2',
                End_KM__c='1',
                Mode__c = 'Start'
            );
            insert TestVehicle;

           
            

            
            List<Vehicle_Data__c> Vehicles = ReportHelper.getVehicleData('');

            // Assert that the method returns the correct delivery
           // System.assertEquals(1, deliveries.size());
         // System.assertEquals(testDelivery.Id, deliveries[0].Id);
        }
    }

    
    //Secure Bag
   @isTest
    static void testGetSecureBags() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; // Assuming you have a profile named 'Standard User'
        User testUser = new User(
            Alias = 'testUser',
            Email = 'testUser467@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUser467@example.com',
            City = 'Bengaluru' // Set the city for the test user
        );
        insert testUser;

        // Create a test Shipment__c record
        Shipment__c testShipment = new Shipment__c(
           
        );
        insert testShipment;

        // Create a test Secure_Bag__c record
        Secure_Bag__c testBag = new Secure_Bag__c(
           
            Current_Scan_Hub__c = 'a3m5g000000Hn5aAAC', // Set the current scan hub
            Shipment__c = testShipment.Id // Assign the test Shipment__c record
        );
        insert testBag;

        Test.startTest();
       
        List<Secure_Bag__c> result = ReportHelper.getSecureBags('');
        Test.stopTest();
        
   if (!result.isEmpty()) {
    Secure_Bag__c retrievedBag = result[0];
    
} else {
   
    System.debug('No Secure_Bag__c records found.');
}
        
      
       
    }
}