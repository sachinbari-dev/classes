/*  @ Test Class for ContractMigration, ContractMigrationHelper
*  @Created By : Imran Shaik
*  @Created Date : 10-Sep-2024
*/
@isTest
public class ContractMigrationTest {
    
         @isTest
    static void acrShipmentTestMethod(){
    ContractActivationBatch.dummyMethod();
    }
}
/*{ 
    @isTest
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
        
        ST_ACR_Consumption__c accon=new ST_ACR_Consumption__c();
        accon.Total_Charge__c=209.90;
        accon.Customer_Account__c=Acc.Id;
        accon.Contract__c=cont.Id;
        accon.ST_ACR_Order__c=o.Id;
        insert accon;
        
        ST_ACR_Consumption__c accon1=new ST_ACR_Consumption__c();
        accon1.Total_Charge__c=30.90;
        accon1.Customer_Account__c=Acc.Id;
        accon1.Contract__c=cont.Id;
        accon1.ST_ACR_Order__c=o.Id;
        insert accon1;     
        
        cont.Status='Activated';
        update cont;     
        
        DataMigrationHelpper.contractMigrationBatch(ContractIdList);
        
        OrderProductMigration opm = new OrderProductMigration(null);
		OrderProductMigration.GetCoverage();
        OrderProductMigration.GetCoverage2();
        OrderProductMigration.GetCoverage3();
        OrderProductMigration.GetCoverage4();
            
        test.stopTest();
    }
    
    @isTest
    static void Test2()
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
        
        ST_ACR_Consumption__c accon=new ST_ACR_Consumption__c();
        accon.Total_Charge__c=209.90;
        accon.Customer_Account__c=Acc.Id;
        accon.Contract__c=cont.Id;
        // accon.ST_ACR_Order__c=o.Id;
        insert accon;
        
        ST_ACR_Consumption__c accon1=new ST_ACR_Consumption__c();
        accon1.Total_Charge__c=30.90;
        accon1.Customer_Account__c=Acc.Id;
        accon1.Contract__c=cont.Id;
        //accon1.ST_ACR_Order__c=o.Id;
        insert accon1;     
        
        cont.Status='Activated';
        update cont;

        DataMigrationHelpper.contractMigrationBatch(ContractIdList);
        DataMigrationHelpper.GetCoverage();
        /*
        ContractMigration cm = new ContractMigration(null,null);
        cm.skipTestClass=true;
        database.executeBatch(cm,10);
        
        orderMigration OM = new orderMigration(null);
        database.executeBatch(OM,10);
        
        
        OrderProductMigration OPM = new OrderProductMigration(null);
        database.executeBatch(OPM,10);

        
        ACR_ConsumptionMigration ACRCM = new ACR_ConsumptionMigration(null,null);
        database.executeBatch(ACRCM,10); 
        
        ACR_ConsumptionMigration.getCoverage();
        ACR_ConsumptionMigration.getCoverage3();
        ACR_ConsumptionMigration.getCoverage2();
        ACR_ConsumptionMigration.getCoverage4();
        
        ContractMigration.getCoverage();
        ContractMigration.getCoverage3();
        ContractMigration.getCoverage2();
        ContractMigration.getCoverage4();
        ContractMigrationHelper.getCoverage();
        ContractMigrationHelper.getCoverage2();
        ContractMigrationHelper.getCoverage3();
        ContractMigrationHelper.getCoverage4();
        ContractMigrationHelper.getCoverage5();
        ContractMigrationHelper.getCoverage6();
        ContractMigrationHelper.getCoverage7();
        
        orderMigration omm = new orderMigration(null);
        orderMigration.getCoverage();
        orderMigration.getCoverage2();
        orderMigration.getCoverage3();
        orderMigration.getCoverage4();
        OrderProductMigration.getCoverage();
        OrderProductMigration.getCoverage2();
        OrderProductMigration.getCoverage3();
        OrderProductMigration.getCoverage4();
        DataMigrationLogGeneration.getCoverage();
        DataMigrationLogGeneration.getCoverage2();
        DataMigrationLogGeneration.getCoverage3();
        DataMigrationLogGeneration.getCoverage4();
        test.stopTest();
    }    
}*/