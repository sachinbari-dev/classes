@isTest
public class BVC_BrinksAgreementController_Test {

    @isTest
    public static void testMethod1(){
        
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
        
          Test.startTest();
        PageReference pageRef = Page.BVC_BrinksAgreementPdfPage;
        pageRef.getParameters().put('id', quote.id);
        Test.setCurrentPage(pageRef);

        BVC_BrinksAgreementController controller = new BVC_BrinksAgreementController();
        Test.stopTest();
    }
}