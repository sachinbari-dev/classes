@isTest
public class cubizonFalconAPITest {
    @isTest
    static void testUpdateSecureBagDetails_Success() {
        
        
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
        

         Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
        
        system.debug('contactId ++++'+ Con);
        system.assertEquals('TestContact',  Con.LastName);       
        system.assertEquals('abc123@paoj.com', Con.Email);
        system.assertEquals(true, Con.BVC_Finance_Contact__c);
        
       /*  blng__LegalEntity__c le = new blng__LegalEntity__c();
           le.Name = 'BVC';
           le.blng__City__c = 'pune';
           le.blng__Country__c = 'India';
           
         insert le;*/ //commented for uninstallation of CPQ
                 
        Hub__c newHub = new Hub__c();
          newHub.Name = 'Mumbai';
          newHub.Branch__c = 'Mumbai';
        //  newHub.Billing_Entity_Name__c = le.Id;
          insert newHub;
         
        Hub__c newHub1 = new Hub__c();
          newHub1.Name = 'Delhi';
          newHub1.Branch__c = 'Delhi';
        //  newHub1.Billing_Entity_Name__c = le.Id;
          insert newHub1;
        
        system.debug('hub recordID++++' + newHub);
        system.assertEquals('Mumbai', newHub.Name);
        system.assertEquals('Mumbai', newHub.Branch__c);
        
                    
        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        
        system.debug('zone record Id ++++++' + z );
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
        
        system.debug('Active pincode ID+++++ '+ pin);
        system.assertEquals('456789', pin.Name);
        system.assertEquals('Pune', pin.City__c);
        system.assertEquals('444601', pin.Pincodes__c);
        system.assertEquals('Pune', pin.City__c);
        system.assertEquals('pune', pin.District__c);
        system.assertEquals(true, pin.Online__c);
        system.assertEquals('Serviceable', pin.Pincode_Type__c);
        system.assertEquals('Online', pin.Online_Offline__c );
        system.assertEquals('India', pin.Country__c);
        system.assertEquals('Maha', pin.State__c);
        
                
        
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
       
        Account Acc2 = New Account();
        Acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc2.Name = 'Anil jwelles HKYYT5638O - Billing HKYYT5638O';
        Acc2.ParentId = Acc.id;
        Acc2.Customer_Status__c = 'Active';
        Acc2.BVC_Company_Type__c = 'Domestic';        
        Acc2.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc2.Customer_Status__c = 'Active';
        Acc2.Category__c = 'Manufacturer';
        Acc2.Type_Of_Customer__c = 'Both';
        Acc2.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc2.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc2.Phone = '94746367837';
        Acc2.First_Name__c = 'billing firstname';               
        Acc2.Last_Name__c = 'billing lst name';
  //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc2.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc2.PAN_Number_of_Entity__c = 'HKYYT5638O';    
        
        Insert Acc2;
        
         
        AddressBook__c TestAdd1 = New AddressBook__c();
        TestAdd1.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd1.Name = 'testaddress';
        TestAdd1.GSTIN__c = '';
        TestAdd1.TRADE_NAME__c = Acc2.Name;
        TestAdd1.Customer__c = Acc2.id;
        TestAdd1.Source__c = 'Manual';
        TestAdd1.Is_Primary__c = true;
        TestAdd1.Your_Address_Identifier__c = 'billing';
        TestAdd1.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd1.ADDRESS1__c = 'ABC Street';
        TestAdd1.CITY__c = 'Test City';
        TestAdd1.STATE__c = 'Test State';
        TestAdd1.COUNTRY__c = 'Test Country';
        TestAdd1.Active_Pincode__c = pin.Id ;
       
        Insert TestAdd1;
         
        AddressBook__c TestAdd2 = New AddressBook__c();
        TestAdd2.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd2.Name = 'testaddress1';
        TestAdd2.GSTIN__c = '';
        TestAdd2.TRADE_NAME__c = shippingAcc.Name;
        TestAdd2.Customer__c = shippingAcc.id;
        TestAdd2.Source__c = 'Manual';
     //   TestAdd2.Is_Primary__c = true;
        TestAdd2.Your_Address_Identifier__c = 'billing';
        TestAdd2.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd2.ADDRESS1__c = 'ABC Street';
        TestAdd2.CITY__c = 'Test City';
        TestAdd2.STATE__c = 'Test State';
        TestAdd2.COUNTRY__c = 'Test Country';
        TestAdd2.Active_Pincode__c = pin.Id ;
       
        insert testAdd2;
 
        
           Shipment__c ship = new Shipment__c();          
           ship.Invoice_Calculated_Amount__c = 29000;
           Ship.Total_Charge__c = 3456;
           ship.Customer__c = Acc.id; 
           ship.Insurance_By__c = 'BVC';
         
     //      ship.Shipper_Name_TMS__c = shippingAcc.Name;
     //      ship.Consignee_Name_TMS__c = shippingAcc.name;
    //       ship.Origin_Address_Name__c = TestAdd2.Id;
    //      ship.Destination_Address_Name__c = TestAdd2.Id;
         
           ship.Net_Weight__c = 12;
           ship.Net_Weight_UOM_TMS__c = 'gram';
           ship.Shipment_Value__c = 21;
            Ship.Total_Invoice_Value__c = 876;
           ship.Billing_Account__c = acc.Id;
           Ship.Bill_To_GSTIN__c = 'ABCD123L';
           Ship.Bill_To_Party_Address__c = 'Test Address';
           Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
           Ship.Billing_Entity_Name__c = Acc.Name;
           ship.AddressBook__c = TestAdd.Id;
                                 
           ship.Origin_Hub__c= newHub.Id;  
           ship.Destination_Hub__c = newHub1.id;
           ship.Status__c = 'billed';   
           Ship.Shipper__c = 'abcxyz';
           ship.Tracking_Status__c = 'Delivered';          
           
           Ship.Origin_Pincode__c = '444603';
           Ship.Destination_Pincode__c = '110001';
           Ship.Consignee_Name__c = 'abcxyz';
       //  ship.Shipment_Lot__c = newLot.id;
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
           ship.Product_Code__c = 'VAL-EX-C2C';
           ship.IsExhibition__c = true;
           ship.Status__c = 'pending billing';
         
           ship.Exhibition_Movement_Type__c= 'Inward';
           ship.Exhibition_Name__c = 'newExhibition';
           ship.Shipment_Created_Through__c = 'Mobile App';                     
           ship.Product_Code__c = '';     
           ship.Ready_for_Rebilling__c = false;
           ship.Verified_for_Billing__c = false;
                         
           insert ship;
        
          secure_packaging__c sp = new secure_packaging__c();
         sp.Name = 'TEST123';
         sp.Status__c = 'Consumed';
         sp.RecordTypeId =Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Bag').getRecordTypeId();
         sp.Type_of_Packaging__c = 'Secure Bag';
         sp.Shipment__c = ship.id;
        insert sp;
   
        secure_bag__c sb = new secure_bag__c();
          sb.Secure_Bag__c = sp.Id;
          sb.Shipment__c = ship.id;
        insert sb;

        
         Map<String, Object> requestList = new Map<String, Object>{
                'awb' => 'TEST123',
                'deviceid' => 'Device001',
                'additional_awb' => 'AWB123',
                'length' => '10.5',
                'breadth' => '8.2',
                'height' => '4.3',
                'weight' => '2.5',
                'Vol. Weight' => '3.0',
                'scanned_date' => '2023-12-01',
                'scanned_time' => '10:30:00',
                'Weight unit' => 'kg',
                'Dim. Unit' => 'cm',
                'images' => 'dgfdh'
            
        };
        String requestBody = JSON.serialize(requestList);
    
        system.debug('request body@@@'+requestBody );
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        req.requestURI = 'https://bvc2--bvcuat.sandbox.my.salesforce.com/services/apexrest/SecureBagWeighing/';
        RestContext.request = req;
        RestContext.response = res;

      
        String response = cubizonFalconAPI.updateSecureBagDetails();
        System.debug('API Response: ' + response);
        Test.stopTest();

      
       Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
       System.assertNotEquals(null, responseMap, 'Response map should not be null.');        
     
       
        System.assertEquals(true, responseMap.get('success'), 'The success flag should be true.');
        System.assertEquals(200, responseMap.get('status_code'), 'The status code should be 200.');
        System.assertEquals('Records and images updated successfully.', responseMap.get('message'),'The response message should indicate success.' );

        /*
        Secure_Bag__c updatedBag = [SELECT Device_Id__c, M_Length__c, M_Weight__c, Scanned_Date__c
                                    FROM Secure_Bag__c
                                    WHERE Secure_Packaging_Identifier__c = 'TEST123' LIMIT 1];
        System.assertEquals('Device001', updatedBag.Device_Id__c, 'Device ID should be updated.');
        System.assertEquals(10.5, updatedBag.M_Length__c, 'Length should be updated.');
        System.assertEquals(2.5, updatedBag.M_Weight__c, 'Weight should be updated.');  */
          
    //    List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'Secure Bag Image - TEST123%'];
  //      System.assertEquals(1, contentVersions.size(), 'One content version should be created.');
    }

}