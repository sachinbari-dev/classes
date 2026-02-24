@isTest
public class ACRAdjustmentMigrationTest {
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
     
     ACR_Adjustment__c adj = new ACR_Adjustment__c( Name = 'CarryforwardAdjustment1',
                                                     Account__c = cont.AccountId,
                                                     Contract__c = cont.Id,
                                                     Adjustment_Amount__c = 5000,
                                                     Adjustment_Type__c = 'Carry Forward');
        insert adj;
     
     
     BVC_Contract__c singleBvcContract = new BVC_Contract__c();
     singleBvcContract.Status__c = cont.Status; 
     singleBvcContract.Migrated_Contract__c = cont.Id;
     insert singleBvcContract;
     ACRAdjustmentMigration acrAdj = new ACRAdjustmentMigration();
     database.executeBatch(acrAdj,10);
     test.stopTest();
 }
}