@isTest
public class primaryAcctOwnerAssignmentTest {

    @isTest
    static void testUpdateAccountOwner() {
       
    user u = [SELECT Id, Name, State_Ownership__c,isActive,userRoleId FROM User where  isActive = true AND State_Ownership__c != Null  LIMIT 1 ];
        
        // Create test Accounts with different BillingState values
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
        Acc.BillingState = 'Odisha';
        Acc.OwnerId =u.id;
        Insert Acc;
        

      List<string> accountIds = new List<String>();      
        accountIds.add(acc.id);
        
        
        Test.startTest();
         primaryAcctOwnerAssignment.updateAccountOwner(accountIds);
        primaryAcctOwnerAssignment.codeCoverage();
        Test.stopTest();

       
    }

   
}