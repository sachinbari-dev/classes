@isTest(SeeAllData=true)
public class VaultShipmentHelperTest {
@isTest
    public static void VaultShipmentTest() 
    {
       Test.startTest();               
       user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];
       user u1 = [SELECT Id, Username, ProfileId FROM User where ProfileId ='00e5g000000HGU6AAO' LIMIT 1];
              
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
        
        
      /*   blng__LegalEntity__c le = new blng__LegalEntity__c();
           le.Name = 'BVC';
           le.blng__City__c = 'pune';
           le.blng__Country__c = 'India';
           
         insert le;*/ //commented for uninstallation of CPQ
                 
        Hub__c newHub = new Hub__c();
          newHub.Name = 'Mumbai';
          newHub.Branch__c = 'Mumbai';
      //    newHub.Billing_Entity_Name__c = le.Id;
          insert newHub;
         
        Hub__c newHub1 = new Hub__c();
          newHub1.Name = 'Delhi';
          newHub1.Branch__c = 'Delhi';
    //      newHub1.Billing_Entity_Name__c = le.Id;
          insert newHub1;
                
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        
        
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
        TestAdd.Is_Primary__c=true;
       
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
       
     //   insert TestAdd2;
         
        
                 
        
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
         
         Account Acc1 = New Account();
            Acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            Acc1.Name = 'TATA COMPANY LIMITED - Billing EQUPNB123M';
            Acc1.BVC_Company_Type__c = 'Domestic';        
            Acc1.KYC_Indicator_for_Domestic_Flag__c = true;
            Acc1.Customer_Status__c = 'Active';
            Acc1.Category__c = 'Manufacturer';
            Acc1.Type_Of_Customer__c = 'Both';
            Acc1.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
            Acc1.Primary_Customer_Email__c = 'abc@sdcnd.com';
            Acc1.Phone = '8775563644';
            Acc1.First_Name__c = 'billing first';               
            Acc1.Last_Name__c = 'billing lst';
      //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
            Acc1.Name_As_Per_PAN_Manual_Input__c = 'new customer';
            Acc1.PAN_Number_of_Entity__c = 'EQUPNB123M';      
            Insert Acc1;          
        VaultShipment.getCustomerChilds(Acc.id); 
        
        Map<String, Object> data = new Map<String, Object>{
            'customerId' => Acc.id,
                'IsExhibition' => true,
                'Hub' => newHub.Id,
                'ShippingAccount' => shippingAcc.id,
                'ProductValue' => '22',
                'isHub' => false,
                'ProductDescription' => 'Machinery',
                'AuthorisedPersonIDDetails' => 'Imran',
                'AuthorisedPersonName' => 'Imran',
                'NetWeight' =>'12',
                'GrossWeight' =>'12',
                'NumberROfPackages' => '2'
                };
                    
        String jsonString = JSON.serialize(data);          
        VaultShipment.saveVShipment(jsonString);
        Vault_Shipmet__c VS = [select Id from Vault_Shipmet__c limit 1];
        ApexPages.currentPage().getParameters().put('id', VS.Id);
        GenerateVSBagLabel GL = new GenerateVSBagLabel();
       

        Test.stopTest();
    }
@isTest
    public static void VaultShipmentTest1() 
    {
         Vault_Shipmet__c vs = new Vault_Shipmet__c(
       
        Secure_Bags__c = 'BAG001' // Ensure this is not null
    );
    insert vs;
        Test.startTest(); 
       
        
        ApexPages.currentPage().getParameters().put('id', VS.Id);
        GenerateVSBagLabel GL = new GenerateVSBagLabel();
        VaultShipmentPrintLabelPdfController VSPL = new VaultShipmentPrintLabelPdfController();
       //  GenerateVSBagLabel.GetCoverage1();
        //  GenerateVSBagLabel.GetCoverage2();
        Test.stopTest();
        
    }
@isTest
    public static void VaultShipmentTest2() 
    {
        Vault_Shipmet__c vs = new Vault_Shipmet__c(
            
            Secure_Bags__c = 'AnotherBag'
        );
        insert vs;

        // Create RecordType for Secure_Packaging__c
        Id secureBagRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Secure_Packaging__c' AND Name = 'Secure Bag' LIMIT 1].Id;

        // Insert a Secure_Packaging__c record
        Secure_Packaging__c sp = new Secure_Packaging__c(
            Name = 'TestSP',
            Vault_Shipmet__c = vs.Id,
            Status__c = 'Available',
            RecordTypeId = secureBagRTId
        );
        insert sp;
        Test.startTest(); 
       
		TMS_AddSecureBagOnValutShipment.shipmentRecordGet(VS.Id);
        List<Secure_Packaging__c> securePackagingList = [ SELECT Id, Name, Vault_Shipmet__c, Shipment__c, Status__c, RecordType.Name  
        FROM Secure_Packaging__c  WHERE  RecordType.Name = 'Secure Bag' and Status__c='Available' limit 1];
        System.debug('251 securePackagingList :'+securePackagingList);
        TMS_AddSecureBagOnValutShipment.createSecureBagRecords(securePackagingList[0].Name,VS.Id);
        Test.stopTest();
    }    
}