public class BVC_GenerateBrinksPDFQueueable implements Queueable, Database.AllowsCallouts {

    Id recordId;

    public BVC_GenerateBrinksPDFQueueable(Id recId) {
        this.recordId = recId;
    }

    public void execute(QueueableContext context) {
        Blob pdfBlob;
        
        PageReference pdfPage = Page.BVC_BrinksAgreementPdfPage;
        pdfPage.getParameters().put('id', recordId);
        if(!Test.isRunningTest()){
            pdfBlob = pdfPage.getContent();
        }
        

        String fileName = 'BVC Brinks Agreement ' + String.valueOf(Date.today()) + '.pdf';

        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        if(!Test.isRunningTest()){
             cv.VersionData = pdfBlob;
        }else{
            cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        }
     
        insert cv;

        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion  WHERE Id = :cv.Id ];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedVersion.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        BVC_bulk_Agreement_signing__c  bv = new BVC_bulk_Agreement_signing__c();
        bv.id = recordId;
        
        if(!Test.isRunningTest()){
             bv.APICalled__c = true;
        }else{
            bv.APICalled__c = false;
        }
        
        
        update bv;
    }
}