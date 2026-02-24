global class retrieveContentVersionRecordsInExcel implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    // This variable will hold the aggregated CSV data across batches
    private String csvBody = 'id,ContentDocumentId,VersionData\n';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String contentVersionRecords = 'SELECT Id, ContentDocumentId, VersionData FROM ContentVersion '; // Limit records
        return Database.getQueryLocator(contentVersionRecords);
    }

    global void execute(Database.BatchableContext bc, List<ContentVersion> contentVersionList) {
        // Process each ContentVersion and build the CSV
        for (ContentVersion cv : contentVersionList) {
            // Build the CSV row with VersionData
            String versionDataBase64 = EncodingUtil.base64Encode(cv.VersionData);
            csvBody += '"' + cv.Id + '","' + cv.ContentDocumentId + '","' + versionDataBase64 + '"\n';
        }

        // Optionally send an email after processing each batch if needed
        if (bc.getJobId() != null) {
            sendEmailWithAttachment();
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Final email sending in the finish method
        sendEmailWithAttachment();
    }

    private void sendEmailWithAttachment() {
        // Only send the email if csvBody is not empty
        if (!String.isEmpty(csvBody)) {
            List<Blob> blobList = new List<Blob>{Blob.valueOf(csvBody)};
            List<String> attachmentNames = new List<String>{'ContentVersion Records.csv'};
            String subject = 'These are the content version records';
            String body = 'This is the demo body';
            List<String> emailList = new List<String>{'govind.sangale@bvclogistics.com'};

            // Send the email with the CSV attached
            sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(emailList, subject, body, blobList, attachmentNames);
        }
    }
}