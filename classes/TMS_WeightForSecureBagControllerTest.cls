/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 04-01-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/

@isTest
public class TMS_WeightForSecureBagControllerTest {
    
    @isTest
    public static void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Weight__c weightObj = new Weight__c();
        weightObj.Volumetric_Weight__c = 568.43;
        weightObj.BVC_Gross_Weight__c = 684.25;
        weightObj.Number_of_Secure_Bags_Scanned__c = 2;
        Insert weightObj;
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Volumetric_Weight__c = 234.43;
        bag1.Length__c = 986.23;
        bag1.Weight__c = weightObj.Id;
        bag1.Width__c = 896.56;
        bag1.Height__c = 654.23;
        bag1.Weighing_Completed__c = true;
        insert bag1;
        
        TMS_WeightForSecureBagController.WeightSecBagWrap wtSecBagWrap = new TMS_WeightForSecureBagController.WeightSecBagWrap();
        
        string sign = 'ruirfgerufgduifufurryerioyioyiwjhdfbvdfuirfgurerofhefherhfouerh'; 
        
        ContentVersion cVersion = new ContentVersion();
        Id contentDocId;
        
        cVersion.ContentLocation = 'S';  
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png'; 
        cVersion.Origin = 'H';  
        cVersion.Title = 'Test.png'; 
        cVersion.VersionData = EncodingUtil.base64Decode(sign); 
        Insert cVersion;
        
        contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = contentDocId; 
        cDocLink.LinkedEntityId = Ship1.Id; 
        cDocLink.ShareType = 'V'; 
        cDocLink.Visibility = 'AllUsers';
        Upsert cDocLink;
        
        
        Test.startTest();
        
        Secure_Bag__c tmpSecObj = TMS_WeightForSecureBagController.fetchSecureBagData(bag1.Name);
        TMS_WeightForSecureBagController.createUpdateRecord(sign,bag1.Name,45.12,32.56,89.65,21.15,true,weightObj.Id,786.21);
        TMS_WeightForSecureBagController.photoUpload('just to check',bag1.Id,'testfile');
        TMS_WeightForSecureBagController.GetCoverage();
        Test.stopTest();
        
    }

}