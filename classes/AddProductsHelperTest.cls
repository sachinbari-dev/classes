@isTest
public class AddProductsHelperTest {
    @isTest
	public static void testFunction1()
    {
        
         Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467H';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '9877287843';
        insert shippingAcc;  
        
          Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi ';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi ', newHub.Name);
        
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
      
        insert pin;
        
           AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = shippingAcc.Name;
        TestAdd.Customer__c = shippingAcc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'Shipping';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ;
        
        Insert TestAdd;
        
        test.StartTest();
        Product_Master__c pm = [select Id,Name,Stock_Price__c from Product_Master__c limit 1];
		AddProductsHelper.getProductMasterList('abc'); 
        AddProductsHelper.ProductWrapper pw = new AddProductsHelper.ProductWrapper();
        Purchase_Order__c po = new Purchase_Order__c();
        po.PO_Status__c='Draft';
         po.Shipping_Partner__c = shippingAcc.id;
        po.Customer_Address__c = TestAdd.id;
       
        insert po;
        String JsonString = '[{"Id":"a7pIl0000008OOmIAM","Name":"Forevermark Icon Collection","Price":19000,"TotalPrice":"190000.00","SerialNumber":"A10021212", "Quantity":"10","startSL":"C10","endSL":"60","midSL":"45","apendName":"","itemNo":""}, {"Id":"a7pIl0000008OO3IAM","Name":"Gold Bar","Price":32,"TotalPrice":"480.00","SerialNumber":"X88765","Quantity":"15","startSL":"D20", "endSL":"11","midSL":"65","apendName":"","itemNo":""}]';
        AddProductsHelper.saveProducts(po.Id,JsonString);
        test.StopTest();
    }
    @testSetup
    static void setupTestData() 
    {
		List<Product_Master__c> pmList = new List<Product_Master__c>();
        for(integer i=1;i<=10;i++)
        {
            Product_Master__c pm = new Product_Master__c();
            pm.Name='Gold Bar Testing12345'+i;
            pm.Status__c='Active';
            pm.Available_Stock__c=0;
            pm.Stock_Quantity__c=10;
            pm.Stock_Price__c=10;
            pmList.add(pm);
        }
        insert pmList;
    }
}