@isTest
public class SecureBagPDFcontrollerTest {

    @isTest
    public static void testSecureBagPDF(){
        
               
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
        
        /* blng__LegalEntity__c le = new blng__LegalEntity__c();
           le.Name = 'BVC';
           le.blng__City__c = 'pune';
           le.blng__Country__c = 'India';
           
         insert le;*/ //commented for uninstallation of CPQ
                 
        Hub__c newHub = new Hub__c();
          newHub.Name = 'Mumbai';
          newHub.Branch__c = 'Mumbai';
       //   newHub.Billing_Entity_Name__c = le.Id;
          insert newHub;
         
        Hub__c newHub1 = new Hub__c();
          newHub1.Name = 'Delhi';
          newHub1.Branch__c = 'Delhi';
       //   newHub1.Billing_Entity_Name__c = le.Id;
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
         sp.Name = 'JD865483';
         sp.Shipment__c = ship.id;
         sp.Status__c = 'Consumed';
         sp.RecordTypeId =Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Secure Bag').getRecordTypeId();
         sp.Type_of_Packaging__c = 'Secure Bag';
          
        insert sp;
        
        secure_bag__c sb = new secure_bag__c();
          sb.Shipment__c = ship.id;
          sb.Secure_Bag__c = sp.Id;
          
        insert sb;
        
          ApexPages.currentPage().getParameters().put('id', ship.Id);
          ApexPages.StandardController sc = new ApexPages.StandardController(ship);
          SecureBagPDFcontroller controller = new SecureBagPDFcontroller(sc);

    }
}