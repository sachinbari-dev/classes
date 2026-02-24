@isTest
public class CreateShipmentTrackingFromLinehaulTest {

    @isTest
    public static void TestCreateShipmentTracking(){
        
             // Create test data for Linehaul_Tracking__c records
        Linehaul_Tracking__c linehaul1 = new Linehaul_Tracking__c();
        Linehaul_Tracking__c linehaul2 = new Linehaul_Tracking__c();
            
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
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';  
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';      
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';    
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '9877287843';
        insert shippingAcc;
        
       
        
          Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', false);
            DelhiAir.Airport_Code__c = 'DEL';
            insert DelhiAir;
         system.assertEquals('DEL', DelhiAir.Airport_Code__c);        
        
         Transport__c BOMAir = BVCL_TestDataFactory.CreateAirport('Mumbai Airport', false);
            BOMAir.Airport_Code__c = 'BOM';
            insert BOMAir;
        system.assertEquals('BOM', BOMAir.Airport_Code__c);
        
         Flight_Schedule__c flight = BVCL_TestDataFactory.createFlight('Indigo', BOMAir.id, DelhiAir.id, true);
          
        system.debug('flight+++'+ flight);        
                
          Hub__c newHub = new Hub__c();
          newHub.Name = 'MUMBAI';
          newHub.Branch__c = 'MUMBAI';
          newHub.Hub_Email_ID__c = 'test@gmail.com';
          insert newHub;
        system.assertEquals('MUMBAI', newHub.Name);
       
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

        
           Shipment__c ship = new Shipment__c();          
           ship.Invoice_Calculated_Amount__c = 29000;
           Ship.Total_Charge__c = 3456;
           ship.Customer__c = Acc.id; 
           ship.Insurance_By__c = 'BVC';
           ship.Destination_Address_Name__c = TestAdd.Id;
           ship.Net_Weight__c = 12;
           ship.Net_Weight_UOM_TMS__c = 'Gram';
           ship.Shipment_Value__c = 21;          
           Ship.Total_Invoice_Value__c = 876;
           ship.Billing_Account__c = acc.Id;
           Ship.Bill_To_GSTIN__c = 'ABCD123L';
           Ship.Bill_To_Party_Address__c = 'Test Address';
           Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
           Ship.Billing_Entity_Name__c = Acc.Name;      
           ship.Status__c = 'billed';   
           Ship.Shipper__c = 'abcxyz';
           ship.Tracking_Status__c = 'Picked up';                   
           Ship.Origin_Pincode__c = '444603';
           Ship.Destination_Pincode__c = '110001';
           Ship.Consignee_Name__c = 'abcxyz';       
           ship.Gross_Weight__c = 12.2;
           ship.Shipment_Stage__c = 'BVC weighment done';
           Ship.Consignee_Email_ID__c = 'abc@sdcn.com';       
           ship.Customer_Product_Category__c = 'ValSHIP';
           ship.Origin_Type__c = 'Online';
           ship.Destination_Type__c = 'Online';
           ship.Product_Description__c = 'Product_Category__c';
           ship.BVC_Product_Name__c = 'valSHIP within city';
           ship.BVC_Product_Name__c = 'valSHIP Surface C2C';
           ship.BVC_Product_Name__c = 'valSHIP Express C2C';
           
                  
           insert ship;
         
        // Create test data for secure_bag__c records associated with linehaul1
        secure_packaging__c sp = new secure_packaging__c();
          sp.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
          sp.Name = 'EZ087HTY';
          insert sp;
        
        system.debug('sp+++'+ sp);
        system.assertEquals('EZ087HTY', sp.name);
        
        secure_packaging__c sp1 = new secure_packaging__c();
          sp1.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Seal').getRecordTypeId();
          sp1.Name = 'EZ087HTK';
          insert sp1;
        
        secure_packaging__c sp2 = new secure_packaging__c();
          sp2.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Trunk').getRecordTypeId();
          sp2.Name = 'EZ087HTN';
          insert sp2;
        
        
        secure_packaging__c sp3 = new secure_packaging__c();
          sp3.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Bag').getRecordTypeId();
          sp3.Name = 'EH76678J';
          insert sp3;
         
        Linehaul__c lineRec = new Linehaul__c();
          lineRec.AWB_Number__c = '455367';
          lineRec.Origin__c = 'Mumbai';
          LineRec.Destination__c = 'Delhi';
          lineRec.Gross_Weight__c = 90.82;
        
          insert lineRec;

       
        system.assertEquals('455367',  lineRec.AWB_Number__c);
        system.assertEquals('Mumbai', lineRec.Origin__c);
        system.assertEquals('Delhi',  LineRec.Destination__c);
        system.assertEquals(90.82, lineRec.Gross_Weight__c);
        
 
        linehaul1.Airline__c = 'indigo';
        linehaul1.AWB_Number__c = lineRec.AWB_Number__c;
        linehaul1.Origin__c = lineRec.Origin__c;
        linehaul1.Destination__c = lineRec.Destination__c;
        insert linehaul1;
        
         awb_number__c aw = new awb_number__c();
             aw.AWB_Code__c = linehaul1.AWB_Number__c;
             aw.Shipment__c = ship.Id;
             aw.Linehaul_Tracking__c = linehaul1.Id;
              insert aw;
        
          secure_bag__c  sb1 = new secure_bag__c();           
          sb1.Next_Destination__c = 'MUMBAI';  
          sb1.Shipment__c= ship.id;        
          sb1.Secure_Bag__c = sp3.id;
          sb1.Right_Seal_Id__c = sp1.Id;
          sb1.Seal_Id__c = sp.Id;
          sb1.Trunk_Id__c = sp2.Id;  
          sb1.Linehaul_Tracking__c = linehaul1.Id;
         
          
           insert sb1; 
        
        
        List<shipment__c>shipList = [select id,linehaul_completed__c ,Tracking_status__c from shipment__c where id=:ship.Id];
         List<shipment__c>  shList = new  List<shipment__c>();
        for(shipment__c sh : shipList){
                sh.linehaul_completed__c =true;
                sh.Tracking_status__c = 'Linehaul Finalised';   
                shList.add(sh);            
        }
           update shList;

        List<Shipment_Tracking__c>  stList = new List<Shipment_Tracking__c>();
          Shipment_Tracking__c  st = new Shipment_Tracking__c();
                  st.Location__c = 'In Transit'; 
                  st.Scan_Time__c = System.now();
                  st.Linehaul__c = aw.Linehaul_Tracking__c;
                  st.Shipment__c = shList[0].id;
                   stList.add(st);
                  insert stList;
          List<id> ShipmentIds = new List<id>{ship.id};
              List<id> sTid = new List<id>{st.id};
        // Call the invocable method
           
        Test.startTest();
        
        CreateShipmentTrackingFromLinehaul.createShipmentTracking(ShipmentIds);
        UpdateSecurebagsCurrentScanToLinehaul.upadateSecurebag(sTid);
        Test.stopTest();
 
    }
}