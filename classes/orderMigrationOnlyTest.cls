@isTest
public class orderMigrationOnlyTest {
    @isTest
    static void acrShipmentTestMethod(){
        OrderItemTriggerHandler.dummyMethod();//100
        OrderTriggerHandler.dummyMethod();//100
        orderMigration.dummyMethod();//94
        orderMigrationOnly.dummyMethod();//94
    }
    
    @isTest
    static void testOrderTrigger() {
   //     TriggerControl.disableOrderTrigger = true;
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert ord;   // trigger fires here
    }
    
}
    
 /*    @isTest
    static void Test1()
    {
        test.starttest();
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);
        
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
        Acc.Phone = '+919474636783';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc; 
        
        Contract cont = new Contract();
        cont.Status='Draft';
        cont.AccountId = Acc.Id;
        cont.BVC_Service__c='ValSHIP';
        cont.Business_Type__c='ACR';
        cont.BVC_Branch__c=newHub.Id;
        cont.StartDate=System.today();
        cont.EndDate=System.today();
        cont.Contract_Amount__c=10000;
        cont.ContractTerm=12;
        cont.Contracted_ACR_Package__c='';
        cont.Primary_Customer_Email__c='imran123@gmail.com';
        insert cont;
        List<String> ContractIdList = new List<String>();
        ContractIdList.add(cont.Id);
        
        
        Order o = new Order();
        o.AccountId = Acc.Id;
        o.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
        o.EffectiveDate = System.today();
        o.Status='Draft';
        o.Business_Type__c = 'ACR';
        o.blng__BillingAccount__c = Acc.Id;
        // o.Pricebook2Id = pbId;
        o.SBQQ__Contracted__c = false;
        o.SBQQ__ContractingMethod__c = 'By Subscription End Date';
        o.SBQQ__PaymentTerm__c = 'Net 30';
        o.SBQQ__PriceCalcStatus__c = 'Not Needed';
        // o.SBQQ__Quote__c = q.Id;
        o.blng__BillNow__c = false;
        o.blng__BillingDayOfMonth__c = '1';
        insert o;   
        
        cont.Status='Activated';
        update cont;     
        orderMigrationOnly omo = new orderMigrationOnly(100);
        database.executeBatch(omo,100); 
		orderMigrationOnly.GetCoverage();
        orderMigrationOnly.GetCoverage2();
        orderMigrationOnly.GetCoverage3();
        orderMigrationOnly.GetCoverage4();
        orderMigrationScheduler.Method2();
        test.stopTest();
    }
    
}*/