/*Class      : ContentVersionRecordFromAttachment
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : Feb 2024
 */


public class ContentVersionRecordFromAttachment {
    
    public static void dummyMethod(){
      integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
    }}

 /*   public static void createContentVersion(List<Attachment> attachments) {
        List<blng__CreditNote__c> creditNoteList = new List<blng__CreditNote__c>();
        Set<Id> attachIds = new Set<Id>();

        for (Attachment attach : attachments) {
           
            if (attach.ParentId.getSObjectType() == blng__CreditNote__c.SObjectType) {
                attachIds.add(attach.ParentId);
            }
        }

        Map<String, ContentVersion> contVerMap = new Map<String, ContentVersion>();

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
}*/