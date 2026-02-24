@IsTest
public class BVCACRconsumptionTriggerTest {
    @TestSetup
    static void setupData() {
     
        
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
       
        BVCQuote__c acrQuote = new BVCQuote__c();
     acrQuote.Account__c = Acc.id;
     acrQuote.status__C = 'Draft';
     acrQuote.Business_Type__c = 'ACR';  
     acrQuote.BVC_Service__c='ValSHIP';
     insert acrQuote;
        
        
        
       BVC_Contract__c Conrt = New BVC_Contract__c();
        Conrt.Quote__c= acrQuote.Id;
         insert Conrt;
        
        
        BVC_ACR_Consumption__c consumptionRecord = new BVC_ACR_Consumption__c();
           consumptionRecord.Account__c= Acc.Id;
           consumptionRecord.BVC_Contract__c= Conrt.id;
        insert consumptionRecord;  
        
        
    }
  
    @IsTest
    static void testDeletionAsNonSystemAdmin() {
      
        Profile nonAdminProfile = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1];
        User nonAdminUser = new User(
            Alias = 'nadmin',
            Email = 'nadmin@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NonAdmin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'nadmin@test.com',
            IsActive = True
        );
        insert nonAdminUser;

       
        System.runAs(nonAdminUser) {
          
            BVC_ACR_Consumption__c consumptionRecord = [SELECT Id FROM BVC_ACR_Consumption__c LIMIT 1];

          
            Test.startTest();
            try {
                delete consumptionRecord;
                System.assert(false, 'Expected DMLException was not thrown');
            } catch (DmlException e) {
                
               
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testDeletionAsSystemAdmin() {
       
        User sysAdminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

    }
}