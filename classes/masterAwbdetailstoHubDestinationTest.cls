@isTest
public class masterAwbdetailstoHubDestinationTest {
 
    @isTest
    public static void testCreateMasterAwbSheet() {
        // Create test data for Linehaul_Tracking__c
         
        Test.setMock(HttpCalloutMock.class, new sendGridEmailMessageAttachmentsMock());   
        
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
  //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
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
     //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
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
     //    ship.Shipper_Name_TMS__c = shippingAcc.Name;
    //     ship.Consignee_Name_TMS__c = shippingAcc.name;
     //    ship.Origin_Address_Name__c = testAdd.name;
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
           ship.Tracking_Status__c = 'Delivered';                   
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
         
         
        Linehaul__c lineRec = new Linehaul__c();
          lineRec.AWB_Number__c = '123456';
          lineRec.Origin__c = 'Mumbai';
          LineRec.Destination__c = 'Delhi';
          lineRec.Gross_Weight__c = 90.82;
          lineRec.Manual__c = true;
          insert lineRec;
        
        Linehaul_Tracking__c linehaul = new Linehaul_Tracking__c();
            linehaul.Linehaul_Name__c =  lineRec.Id;
            linehaul.Flight_Date__c = system.today();
            linehaul.AWB_Number__c = 'AWB123';
            linehaul.Origin__c = 'Origin City';
            // Add other required fields here
        
        insert linehaul;

        // Create test data for secure_bag__c
        Secure_Bag__c secureBag = new Secure_Bag__c();
            secureBag.Finalised_Linehaul_Number__c = '123456';
            // Add other required fields here
        secureBag.Shipment__c = ship.id;
        secureBag.Linehaul_Tracking__c = linehaul.Id;
        insert secureBag;

        // Add other related records as needed

        // Prepare the list of record IDs for the invocable method
        List<List<String>> recid = new List<List<String>>();
        recid.add(new List<String>{'test@example.com', linehaul.Id});
             system.debug('recid!!!!!' + recid);
        Test.startTest();
        // Call the invocable method
       
        masterAwbdetailstoHubDestinationEmail.createMasterAwbSheet(recid);
        
      
        Test.stopTest();

        // Add assertions based on your expected behavior

        // Example assertion (you may need to adjust based on your logic)
        Linehaul_Tracking__c updatedLinehaul = [SELECT Id, Email_Status__c, Email_Error_Message__c FROM Linehaul_Tracking__c WHERE Id = :linehaul.Id];
        System.assertEquals('Sent', updatedLinehaul.Email_Status__c);
        
    }
}