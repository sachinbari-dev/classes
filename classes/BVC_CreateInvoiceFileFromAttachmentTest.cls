@isTest
public class BVC_CreateInvoiceFileFromAttachmentTest {

    @isTest
    static void testmethod1(){
        
          Account ac = new Account(Name = 'ACR Customer',
                                         PAN_Number_of_Entity__c = 'GYA623HA72',
                                         KYC_Status__c = 'API Verified',
                                         ST_Pricing_Type__c = 'Non ACR',
                                         Customer_Category__c = 'Non ACR Contracted',
                                         RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
                                         );
        insert ac;
        
         BVCInvoice__c invRec = new BVCInvoice__c();           
            invRec.Short_URL__c = 'www.google.com';
            invRec.Invoice_Type__c = 'Tax Invoice';
            invRec.Account__c = Ac.Id;
            insert invRec;
        
        List<Attachment> atList = new List<Attachment>();
        
         Attachment attach = new Attachment();
           attach.Name = 'Invoice Pdf';
           attach.Description = 'This is attachment of invoice record';
           attach.ContentType = 'Pdf';
           Blob c=Blob.valueOf('Unit Test Attachment Bodys');
           attach.Body =EncodingUtil.base64Decode('Unit Test Attachment Body');
           attach.ParentId = invRec.id;
           insert attach;
        
        atList.add(attach);
        
         ContentVersion cv= new Contentversion();
          cv.title= attach.name;
          cv.PathOnClient =attach.name;         
          cv.versiondata=attach.Body; 
          cv.SharingPrivacy = 'N';
          cv.FirstPublishLocationId = attach.ParentId;
          insert cv; 
        
        BVC_CreateInvoiceFileFromAttachment.createContentVersion(atList);
        ContentVersionRecordFromAttachment.dummyMethod();
    }
}