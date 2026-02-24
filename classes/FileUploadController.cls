public with sharing class FileUploadController {
    @AuraEnabled
    public static void updateFileLink(String recordId, String contentDocumentId) {
       
        ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
        if (!doc.Title.containsIgnoreCase('POD File')) {
            doc.Title += ' - POD File';
            update doc;
        }

       
        String fileUrl = URL.getOrgDomainUrl().toExternalForm() + 
                         '/sfc/servlet.shepherd/document/download/' + contentDocumentId;

        
        Vault_Shipmet__c vship = [
            SELECT Id, POD_Link_URL__c, Vault_Tracking_status__c 
            FROM Vault_Shipmet__c 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        vship.POD_Link_URL__c = fileUrl;
        vship.Vault_Tracking_status__c = 'Delivered';
        update vship;
    }
}