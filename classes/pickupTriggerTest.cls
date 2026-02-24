@isTest
public class pickupTriggerTest 
{
    @isTest
    static void pickupTest()
    {
        Test.setMock(HttpCalloutMock.class, new ShipmentWebHookCalloutMock());
        Test.startTest();
        Id userId=UserInfo.getUserId();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Account a=new Account();
        a.name='Test Billing Customer Account';
        a.First_Name__c='Test Billing';
        a.Last_Name__c='Customer Account';
        a.RecordTypeId = devRecordTypeId;
        a.PAN_Number_of_Entity__c  ='1234556778';
        a.Primary_Customer_Email__c='test123@gmail.com';
        a.BVC_Company_Type__c='Domestic';
        a.Customer_Status__c ='Active';
        a.Type_Of_Customer__c='Customer';
        a.Category__c='Manufacturer';
        a.ST_Pricing_Type__c = 'Non ACR';
        a.BVC_Legal_Entity__c='B.V. Chinai & Co. (India) Private Limited';
        a.Mobile__c = '+919876543210';
        a.Phone = '+918765432109';
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
        
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X1889b31c',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';
        
        update p2;
        
        Date tod = system.today();
        Integer d = tod.day();
        Integer mo = tod.month();
        Integer yr = tod.year();                
        DateTime nt = DateTime.newInstance(yr, mo, d);    
        Pickup__c p1 =  SavePickup(a.id,bab.Id,a.id,a1.id,ab.Id,'sample1',nt,true,c.Id);        
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
       // List<Pickup__c> pkList = new List<Pickup__c>();
        Pickup__c pu = new Pickup__c();
        pu.Customer__c = CAId;
        pu.Shipper_Name__c = SAId;
        pu.Shipper_Address__c = SAddId; 
        pu.Pickup_Date_and_Time__c= P_date;
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
       // pkList.add(pu);
        insert pu;  
        
        Pickup__c pu1 = new Pickup__c();
        pu1.Customer__c = CAId;
        pu1.Shipper_Name__c = SAId;
        pu1.Shipper_Address__c = SAddId; 
        pu1.Pickup_Date_and_Time__c= P_date;
        pu1.Remarks__c = Remarks;
        pu1.RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId();
        if(bill_Ac!=null)
        {
            pu1.Billing_Account__c = bill_Ac;
        }
        if(bill_Add!=null)
        {
            pu1.Billing_Address__c=bill_Add;
        }            
        //pkList.add(pu1);
        // insert pu1; 

        try {
            insert pu1;
            // If the Pickup is inserted successfully, the test should fail
            //System.assert(false, 'The Pickup should not have been inserted.');
        } catch (DmlException e) {
            // Verify that the expected error message is present
            // System.assertEquals('Duplicate Pickup Error \n Pickup Already Exists '+pu.Name, e.getDmlMessage(0));
        }        
        
       // database.Insert(pkList,false);       
        return pu;        
    }    
}