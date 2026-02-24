@isTest
public class PickupHelperTest 
{
    @isTest
    static void ShipmentTest()
    {
        
        Test.startTest();
        Id userId=UserInfo.getUserId();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Account a=new Account();
        a.name='Test Billing Customer Account';
        a.RecordTypeId = devRecordTypeId;
        a.PAN_Number_of_Entity__c  ='1234556778';
        a.BVC_Company_Type__c='Domestic';
        a.Customer_Status__c ='Active';
        a.Type_Of_Customer__c='Customer';
        a.Category__c='Manufacturer';
        a.ST_Pricing_Type__c = 'Non ACR';
        a.BVC_Legal_Entity__c='B.V. Chinai & Co. (India) Private Limited';
        a.Mobile__c = '+919876543210';
        a.Phone = '+918765432109';
        a.Primary_Customer_Email__c='testmail1@gmail.com';
        insert a;
        
        Account a1=new Account();
        a1.name='Test Shipping Customer Account';
        a1.RecordTypeId = devRecordTypeId1;
        a1.PAN_Number_of_Entity__c  ='1234566778';
        a1.BVC_Company_Type__c='Domestic';
        a1.Customer_Status__c ='Active';
        a1.Type_Of_Customer__c='Customer';
        a1.Category__c='Manufacturer';
        a1.BVC_Legal_Entity__c='B.V. Chinai & Co. (India) Private Limited';   
        a1.Mobile__c = '+919876543210';
        a1.Phone = '+918765432109';
        a1.Primary_Customer_Email__c='testmail2@gmail.com';
        insert a1;
        Id devRecordTypeId5 = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();       
        List<AddressBook__c> addresslist=new list<AddressBook__c>();
        AddressBook__c ab=new AddressBook__c();
        ab.name='1-7-12,Sanfranciisco, washigton,United States of America';
        ab.ADDRESS1__c='Address1';
        ab.ADDRESS2__c='Address2';
        ab.CITY__c='city';
        ab.COUNTRY__c='India';
        ab.Customer__c=a1.id;
        ab.PINCODE__c='854105';
        ab.District__c='district';
        ab.TRADE_NAME__c=a.name;
        ab.GSTIN__c='';
        ab.recordtypeId=devRecordTypeId5;
        
        insert ab;
        AddressBook__c ab1=new AddressBook__c();
        ab1.name='1-7-132,Sanfranciisco, washigton,United States of America';
        ab1.ADDRESS1__c='Address5';
        ab1.ADDRESS2__c='Address6';
        ab1.CITY__c='city';
        ab1.COUNTRY__c='India';
        ab1.Customer__c=a1.id;
        ab1.PINCODE__c='854106';
        ab1.District__c='district';
        ab1.TRADE_NAME__c=a.name;
        ab1.GSTIN__c=''; 
        ab1.recordtypeId=devRecordTypeId5;
        insert ab1;
        
        Id BillingAddRecTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId(); 
        AddressBook__c bab=new AddressBook__c();
        bab.name='1-7-13,Sanfranciisco, washigton,United States of America';
        ab.ADDRESS1__c='Address11';
        bab.ADDRESS2__c='Address22';
        bab.CITY__c='city1';
        bab.COUNTRY__c='India';
        bab.Customer__c=a.id;
        bab.PINCODE__c='854108';
        bab.District__c='district';
        bab.TRADE_NAME__c=a.name;
        bab.GSTIN__c='';
        bab.recordtypeId=BillingAddRecTypeId;  
        insert bab;
        
        Contact c = new Contact();
        c.LastName = 'test1';
        c.MobilePhone = '+918888777711';
        c.AddressBook__c = ab.Id;
        Insert c;
        
        Date tod = system.today();
        Integer d = tod.day();
        Integer mo = tod.month();
        Integer yr = tod.year();                
        DateTime nt = DateTime.newInstance(yr, mo, d);    
        Pickup__c p1 =  SavePickup(a.id,bab.Id,a.id,a1.id,ab.Id,'sample1',nt,true,c.Id);
        // Pickup__c p2 =  SavePickup(a.id,bab.Id,a.id,a1.id,ab.Id,'sample1',null,true,c.Id);
        
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        /// ship.Customer__c = Acc.id; 
        ship.Insurance_By__c = 'BVC';
        ship.Billing_Account__c = a.Id;
        ship.Billing_Address__c =  bab.id;
        ship.Shipper_Name_TMS__c = a1.id;  
        ship.Consignee_Name_TMS__c = a1.Id;
        ship.Origin_Address_Name__c = ab.id;
        ship.Destination_Address_Name__c = ab.Id;
        ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'Gram';
        ship.Shipment_Value__c = 21;
        ship.Pickup__c = p1.id;
        Ship.Total_Invoice_Value__c = 876;
        // ship.Billing_Account__c = a.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        
        ship.Shipping_Note_Number__c='OS12345';
        
        insert ship;        
        
        List<String> idss = new List<String>();
        idss.add(p1.Id);
       // PickupHelper.updateShipments(idss); 
        PickupControlShips.getShipementList(ship.Id);
        PickupControlShips.updateShipementList(ship.Id);
        test.stopTest();         
    }
    
    public static Pickup__c SavePickup(String bill_Ac,
                                       String bill_Add,
                                       String CAId,
                                       String SAId,
                                       String SAddId,
                                       String Remarks,
                                       DateTime P_date,
                                       boolean stg,
                                       String Receiver)
    {
        List<string> res = new List<string>();
        String status='FAIL';
        integer Temp=0;
        Pickup__c pkk;
        System.debug('Inside Save Pickup');
        System.debug('Inside Save Pickup bill_Ac :'+bill_Ac);
        System.debug('Inside Save Pickup bill_Add :'+bill_Add);
        Pickup__c pu = new Pickup__c();
        Date tod1 = system.today();
        Integer d1 = tod1.day();
        Integer mo1 = tod1.month();
        Integer yr1 = tod1.year();  
        DateTime dt = DateTime.newInstance(yr1, mo1, d1);
        List<Pickup__c> pkl = [select Id,Name from Pickup__c where Customer__c =:CAId AND Shipper_Name__c =: SAId AND Shipper_Address__c =: SAddId AND CreatedDate >=: dt];
        System.debug(' Size :'+pkl.size());
        
        if(pkl.size()>0 && stg== false)
        {
            Temp=1;
            System.debug(' Size :'+pkl[0].Name);
            res.add(status);
            res.add(pkl[0].Name);
        }
        
        if(CAId != null && SAId != null && SAddId != null && Temp==0)        
        {            
            pu.Customer__c = CAId;
            pu.Shipper_Name__c = SAId;
            pu.Shipper_Address__c = SAddId; 
            if(P_date==null){
            }
            else
            {
                
                pu.Pickup_Date_and_Time__c= P_date;  
                System.debug('22.pu.Pickup_Date_and_Time__c :'+pu.Pickup_Date_and_Time__c);
            }
            pu.Remarks__c = Remarks;
            pu.RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId();
            
            if(bill_Ac!=null)
            {
                pu.Billing_Account__c = bill_Ac;
            }
            if(bill_Add!=null)
            {
                pu.Billing_Address__c=bill_Add;
            }                        
            insert pu;
            System.debug('PU : '+pu);
            System.debug('PU Name : '+pu.Id);
            pkk = [select Id,Name from Pickup__c where Id=:pu.Id limit 1];
        }
        return pu;
    }   
}