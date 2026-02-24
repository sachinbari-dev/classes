@IsTest
public class FinanceSnapshotBatchTest {
    
    @IsTest
    static void testGstSerialNumberUpdate() {
        
        Hub__c hb = new Hub__c();
        hb.Name = 'name';
        hb.Branch__c= 'Mumbai';
        insert hb;
        
        Active_Pincode__c pinCode = new Active_Pincode__C();
        pinCode.Name = '400093';
        pinCode.Pincodes__c = '400093';
        pinCode.State__c = 'Maharashtra';
        pinCode.Country__c = 'India';
        pinCode.City__c = 'Mumbai';
        insert pinCode;
        
       List<Account> accList = new list<Account>();
        Account WalletCustomer = TestUtility.createnonACRnonContractedAccount();
        WalletCustomer.name='Wallet Account';
        WalletCustomer.Last_Name__c='xyz';
        WalletCustomer.Oracle_Account_Code__c='3242';
       // WalletCustomer.Email__c = 'test@gmail88.com';
        accList.add(WalletCustomer);
        
        Account NonACRCustomer = TestUtility.createnonACRnonContractedAccount();
        NonACRCustomer.name='nonAcr Account';
        NonACRCustomer.Last_Name__c='abc';
        NonACRCustomer.Oracle_Account_Code__c='3822';
      //  NonACRCustomer.Email__c = 'test@gmail88.com';
        accList.add(NonACRCustomer);
        
        Account ACRCustomer = TestUtility.createnonACRnonContractedAccount();
        ACRCustomer.name='Acr Account';
        ACRCustomer.Last_Name__c='pqn';
        ACRCustomer.Oracle_Account_Code__c='3222';
      //  ACRCustomer.Email__c = con1.Email;
        accList.add(ACRCustomer);
       
        insert accList;
        system.debug('non acr account===='+accList[1]);
        
        Contact con = TestUtility.createContact(accList[2]);
        con.AccountId=accList[2].id;
        con.Email='test@gmail88.com';
        insert con;
        
      //  update accList[2];
        
        List<AddressBook__c> blngAddress = TestUtility.createAddressBook(accList);
        insert blngAddress;
        
        accList[2].Billing_Address__c = blngAddress[0].Id;
        accList[2].Billing_Address__c = blngAddress[0].Id;
        accList[2].Is_Finance_Contact_Present__c = true;
        accList[2].Primary_Address__c = blngAddress[0].Id;
        accList[2].Credit_Status__c='Credit';
        accList[2].Billing_Frequency__c='Shipment';
        update accList[2];
        
        accList[1].Billing_Address__c = blngAddress[0].Id;
        accList[1].Billing_Address__c = blngAddress[0].Id;
        accList[1].Is_Finance_Contact_Present__c = true;
        accList[1].Primary_Address__c = blngAddress[0].Id;
        accList[1].Credit_Status__c='Credit';
        accList[1].Billing_Frequency__c='Shipment';
        update accList[1];
        
        
        
        LegalEntity billingEntity = new LegalEntity();
        billingEntity.Name = 'test';
        
        insert billingEntity;
        
        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_Billing_Entity__c = billingEntity.Id;
        bvcInvoice.Account__c = accList[2].Id;
        bvcInvoice.Total_Credit_Notes__c = 0;
        
        
        insert bvcInvoice;
         
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 10000;
        
        Insert invLineItem;
        
        
        BVC_Contract__c ACRContract = new BVC_Contract__c();
        ACRContract.Customer_Name__c=accList[2].Id;
        ACRContract.Business_Type__c='ACR';
        ACRContract.BVCInvoice__c=bvcInvoice.Id;
        ACRContract.Status__c='Activated';
        ACRContract.Contract_Start_Date__c = Date.newInstance(2025, 2, 28); 
        ACRContract.Contract_End_Date__c = Date.newInstance(2029, 2, 28);
        ACRContract.Contract_Amount__c=100000;
        insert ACRContract;
        accList[2].BVC_Contract__c=ACRContract.id;
        update accList[2];
        
        BVC_Contract__c oldContract = new BVC_Contract__c();
        oldContract.Customer_Name__c = accList[2].Id;
        oldContract.Business_Type__c = 'ACR';
        oldContract.Status__c = 'Expired';
        oldContract.Contract_Start_Date__c = Date.newInstance(2023, 1, 1);
        oldContract.Contract_End_Date__c = Date.newInstance(2024, 1, 1);
        oldContract.Contract_Amount__c = 50000;
        insert oldContract;
        
        BVC_ACR_Consumption__c ACRCon = new BVC_ACR_Consumption__c ();
        ACRCon.BVC_Contract__c=ACRContract.Id;
        ACRCon.Total_Charge__c=1000;
        
        BVC_Contract__c NonACRContract = new BVC_Contract__c();
        NonACRContract.Customer_Name__c=accList[1].Id;
        NonACRContract.Business_Type__c='Non ACR';
        NonACRContract.Status__c='Activated';
        NonACRContract.Contract_Start_Date__c = Date.newInstance(2025, 2, 28); 
        NonACRContract.Contract_End_Date__c = Date.newInstance(2029, 2, 28);
        insert NonACRContract;
        accList[1].BVC_Contract__c=NonACRContract.id;
        update accList[1];
        
        ST_NonACR_Contracted_Price__c conPrice = new ST_NonACR_Contracted_Price__c();
        conPrice.ST_Customer_Account__c = accList[1].Id;
        conPrice.BVC_Contract__c=NonACRContract.id;
        insert conPrice;
        
        shipment__c sh = new shipment__c();
        sh.Customer__c=accList[1].Id;
       // insert sh;
        
        bvcOrder__c ord = new BVCOrder__c();
        ord.Account__c=accList[1].id;
        ord.Shipment__c=sh.id;
        insert ord;
        
        BVC_Order_Product__c odP = new BVC_Order_Product__c();
        odP.BVCOrder__c= ord.id;
        odP.Non_ACR_Contracted_Price__c=conPrice.id;
        insert odP;
        
        BVCInvoice__c bvcInvoiceNonACR = new BVCInvoice__c();
        bvcInvoiceNonACR.BVC_Billing_Entity__c = billingEntity.Id;
        bvcInvoiceNonACR.Account__c = accList[1].Id;
        system.debug('invoice account==='+bvcInvoiceNonACR.Account__c);
        bvcInvoiceNonACR.Total_Credit_Notes__c = 0;
        bvcInvoiceNonACR.BVCOrder__c=ord.id;
        insert bvcInvoiceNonACR;
        
        
        BVCInvoiceLineitem__c invLineItemNonACR = new BVCInvoiceLineitem__c();
        invLineItemNonACR.BVCInvoice__c = bvcInvoiceNonACR.Id;
        invLineItemNonACR.Freight_Charges__c=10000;
        invLineItemNonACR.Subtotal__c = 10000;
        invLineItemNonACR.BVC_Order_Product__c=odP.id;
        
        Insert invLineItemNonACR;
        Test.setCreatedDate(invLineItemNonACR.Id, DateTime.newInstance(2025, 3, 20, 0, 0, 0));
        
       /* BVCCreditNote__c cn = new BVCCreditNote__c ();
        cn.bvcInvoice__c=bvcInvoiceNonACR.id;
        cn.Customer__c=accList[1].id;
        insert cn;*/
        
        Finance_Snapshot__c lastSnapshot = new Finance_Snapshot__c();
        lastSnapshot.Customer__c = accList[2].Id;
        lastSnapshot.BVC_Contract__c = oldContract.Id;
        lastSnapshot.Contract_Number__c = 'CON123';
        lastSnapshot.Contract_Amount__c = 50000;
        lastSnapshot.Contract_Balance__c = 90000;
        lastSnapshot.Contract_Consumed__c = 10000;
        lastSnapshot.Contract_Start_Date__c = Date.newInstance(2024, 1, 1);
        lastSnapshot.Contract_End_Date__c = Date.newInstance(2025, 1, 1);
        insert lastSnapshot;  
        
        Test.startTest();
        Date testToday = Date.newInstance(2025, 4, 5); 
        FinanceSnapshotBatch batch = new FinanceSnapshotBatch(testToday);
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        System.debug('LineItem Invoice Id: ' + invLineItemNonACR.BVCInvoice__c);
        System.debug('LineItem Contract: ' + invLineItemNonACR.BVC_Order_Product__r.Non_ACR_Contracted_Price__r.BVC_Contract__c);
        System.debug('LineItem Customer (from Invoice): ' + invLineItemNonACR.BVCInvoice__r.Account__c);
        System.debug('LineItem Order Product: ' + invLineItemNonACR.BVC_Order_Product__c);
        System.debug('LineItem Order Product contract: ' + invLineItemNonACR.BVC_Order_Product__r.Non_ACR_Contracted_Price__r.BVC_Contract__c);
        
        List<Finance_Snapshot__c> snapshots = [SELECT Id, Customer__r.name,Customer__c, Customer_Oracle_Number__c,BVC_Contract__c,Contract_Number__c,Contract_Amount__c,Contract_Balance__c,
                                               Customer_Type__c,Contract_Consumed__c,Contract_Start_Date__c,Contract_End_Date__c,BVCInvoice__c,Wallet_Balance__c FROM Finance_Snapshot__c];
        system.debug('non acr cust=='+snapshots[0].Customer__r.name);
        system.debug('acr cust=='+snapshots[2].Customer__r.name);
        System.debug('Snapshot Customer: ' + snapshots[2].Customer__c);
        System.debug('Snapshot Contract: ' + snapshots[2].BVC_Contract__c);
        System.debug('Snapshot Type: ' + snapshots[2].Customer_Type__c);
        
        System.assertEquals(4, snapshots.size(), 'Three Finance Snapshot records should be created.');
        

    }
    @isTest
    static void testScheduleMonthlyJobMethod() {
        Test.startTest();
        FinanceSnapshotScheduler.scheduleMonthlyJob();
        Test.stopTest();
    }

}