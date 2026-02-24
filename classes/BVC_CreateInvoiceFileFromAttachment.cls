public class BVC_CreateInvoiceFileFromAttachment {

     public static void createContentVersion(List<Attachment> attachments) {
          
        Set<Id> attachIds = new Set<Id>();

        for (Attachment attach : attachments) {
           
            if (attach.ParentId.getSObjectType() == BVCInvoice__c.SObjectType) {
                attachIds.add(attach.ParentId);
            }
        }

        if (!attachIds.isEmpty()) {
            List<ContentVersion> contVersionList = new List<ContentVersion>();
            for (Attachment att : [SELECT Id, ParentId, Name, Body, OwnerId, Description 
                                    FROM Attachment 
                                    WHERE ParentId = :attachIds LIMIT 1]) {
                ContentVersion objCntVersion = new ContentVersion();
                objCntVersion.Title = att.Name;
                objCntVersion.PathOnClient = att.Name;
                objCntVersion.VersionData = att.Body;
                objCntVersion.Description = att.Description;
                objCntVersion.SharingPrivacy = 'N';
                objCntVersion.FirstPublishLocationId = att.ParentId; 
               
                contVersionList.add(objCntVersion);
            }
            insert contVersionList;
        }
         
     }
}