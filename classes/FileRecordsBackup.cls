public class FileRecordsBackup {}//commented for uninstallation of CPQ
    /* Method to retrieve and backup Files/Attachments
    public static void backupFiles() {
        List<Docusign_Backup__c> backupRecords = new List<Docusign_Backup__c>();
        
        // Query Files/Attachments
        //List<Attachment> attachments = [SELECT Id, Name, Body, ParentId FROM Attachment];
        // If you're using Files instead of Attachments, use 
        List<ContentDocumentLink> attachments =[SELECT LinkedEntityId, ContentDocument.Title,ContentDocument.LatestPublishedVersion.VersionData,ContentDocumentId,  ContentDocument.FileType, ContentDocument.LatestPublishedVersionId
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId IN (SELECT Id FROM SBQQ__Quote__c )];
        
        for(ContentDocumentLink attachment : attachments) {
            Attachment attachment1 = new Attachment();
            attachment1.Name = attachment.ContentDocument.Title;
            attachment1.Body = attachment.ContentDocument.LatestPublishedVersion.VersionData;
            attachment1.ParentId=attachment.LinkedEntityId;
            insert attachment1;
            String base64Data = EncodingUtil.base64Encode(attachment1.Body);
            Docusign_Backup__c backupRecord = new Docusign_Backup__c();
            backupRecord.Name = attachment.ContentDocument.Title;
            //backupRecord.File_Data__c =EncodingUtil.base64Encode(attachment.ContentDocument.LatestPublishedVersion.VersionData);
           // backupRecord.File_Data__c = base64Data;
            backupRecord.File_Id__c= attachment1.Id;
            backupRecord.Quote_Id__c = attachment.LinkedEntityId; // Link to the record where the file belongs
            backupRecords.add(backupRecord);
        }
        
        // Insert backup records into custom object
        if(!backupRecords.isEmpty()) {
            insert backupRecords;
        }
    }
    
}*/