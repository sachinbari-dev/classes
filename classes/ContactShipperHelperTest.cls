@isTest
public class ContactShipperHelperTest 
{
    @isTest
    public static void test1()
    {
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


        
        Hub__c newHub = new Hub__c();
          newHub.Name = 'delhi Acr';
          newHub.Branch__c = 'delhi';
          insert newHub;
         
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
        TestAdd.GSTIN__c = '09AACCN7214Q1ZY';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.id;
        TestAdd.Source__c = 'KARZAA';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.PAN_Number_of_Entity__c  = 'BRVPM5868H';
        TestAdd.Active_Pincode__c = pin.Id ;
       
        Insert TestAdd;


        AddressBook__c TestAdds = New AddressBook__c();
        TestAdds.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdds.Name = 'test Shipping address';
        TestAdds.GSTIN__c = '09AACCN7214Q1ZY';
        TestAdds.TRADE_NAME__c = Acc.Name;
        TestAdds.Customer__c = Acc.id;
        TestAdds.Source__c = 'KARZAA';
        TestAdds.Your_Address_Identifier__c = 'Shipping';
        TestAdds.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdds.ADDRESS1__c = 'ABC Street1';
        TestAdds.CITY__c = 'Test City1';
        TestAdds.STATE__c = 'Test State1';
        TestAdds.COUNTRY__c = 'Test Country';
        TestAdds.PAN_Number_of_Entity__c  = 'ALOPS2041L';
        TestAdds.Active_Pincode__c = pin.Id ;
       
        Insert TestAdds;        

        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = Acc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Con.AddressBook__c=TestAdds.Id;
        Insert Con;
        
        AddressBook__c TestShipAdd = New AddressBook__c();
        TestShipAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestShipAdd.Name = 'TestShipAddress';
        TestShipAdd.GSTIN__c = '';
        TestShipAdd.TRADE_NAME__c = shippingAcc.Name;
        TestShipAdd.Customer__c = shippingAcc.id;
        TestShipAdd.Source__c = 'Manual';
        TestShipAdd.Your_Address_Identifier__c = 'billing';
        TestShipAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestShipAdd.ADDRESS1__c = 'ABC Street';
        TestShipAdd.CITY__c = 'Test City';
        TestShipAdd.STATE__c = 'Test State';
        TestShipAdd.COUNTRY__c = 'Test Country';
        TestShipAdd.Active_Pincode__c = pin.Id ;
       
        Insert TestShipAdd;
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.Pickup_Status__c='Completed';
        TestPick.Shipper_Address__c=TestAdds.Id;
        insert TestPick;
        
        test.startTest();
        ContactShipperHelper.getPeopleList(TestPick.Id);
        ContactShipperHelper.updatePickup(TestPick.Id,Con.Id,'test@gmail.com');
        test.stopTest();
    }
}