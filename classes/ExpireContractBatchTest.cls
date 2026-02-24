@isTest
public class ExpireContractBatchTest {
 @isTest
    static void acrShipmentTestMethod(){
        
        Test.startTest();
        
        Account Ac = New Account();
        Ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Ac.Name = 'TITANS COMPANY LIMITED - Billing EQUPNB123U';
       
        Ac.First_Name__c = 'billing firstname';               
        Ac.Last_Name__c = 'billing lst name';
        Ac.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Ac.PAN_Number_of_Entity__c = 'EQUPNB123R';      
        Insert Ac;

        BVC_Contract__c con = new BVC_Contract__c();
        con.Customer_Name__c = AC.Id;
        con.Status__c= 'Draft';
        con.Contract_End_Date__c = Date.newInstance(1998, 1, 1);
        insert con;
        
        ExpireContractBatch batch = new ExpireContractBatch();
        Database.executeBatch(batch);

        Test.stopTest();  // Forces execute() to run

    
    }}