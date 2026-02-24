@isTest
public class BrinksAgreementTrigger_Test {

    @isTest
    Public static void testMethod1(){
        
         Zoho_Access_Token__c tokenSetting = new Zoho_Access_Token__c(
            Name = 'Default', // Required Name field for custom settings
            Access_Token__c = '1000.e43c5bbeb14b605b9984ff7a139ae903.05d9372e9766995ae5c27d336ec4d50b'
        );
        upsert tokenSetting;
        
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(),
            BVC_Company_Type__c = 'Domestic',
            KYC_Indicator_for_Domestic_Flag__c = true,
            Customer_Status__c = 'Active',
            Category__c = 'Manufacturer',
            Type_Of_Customer__c = 'Both',
            BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited',
            Primary_Customer_Email__c = 'abc@sdcn.com',
            Phone = '94746367837',
            First_Name__c = 'billing firstname',
            Last_Name__c = 'billing lst name',
            Name_As_Per_PAN_Manual_Input__c = 'new cust',
            PAN_Number_of_Entity__c = 'EQUPNB543K'
        );
        insert acc;
        
         BVC_bulk_Agreement_signing__c quote = new BVC_bulk_Agreement_signing__c(
            Customer_Name__c = acc.Id,
            Customer_Address__c='Test add',
            Documentstatus__c='Draft',
             BVC_Brink_s_Office_Address__c='test add',
             Customer_GST_No__c='GThh989',
             Customer_IEC_No__c = 'HG767',
            status__c = 'Contract sent',
            RequestId__c = '60959000000416407',
            DocumentId__c = '60959000000416408'
        );
        insert quote;
        
        BVC_bulk_Agreement_signing__c bv =[select id, APICalled__c from BVC_bulk_Agreement_signing__c where id=: quote.id LIMIT 1];
        bv.APICalled__c = true;
        
        update bv;
        
        
    }
}