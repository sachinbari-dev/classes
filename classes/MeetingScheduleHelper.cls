public class MeetingScheduleHelper 
{
    @AuraEnabled(cacheable=true)
    public static String saveMS(String customerId) {
     System.debug('Inside saveMS');
     System.debug('Inside saveMS accountId:');
     return '123';  
    }
    
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static String SaveRecord(String CustomerId,String UserId,String Notes,String Duration,Date visitedDate,
                                    String visitedTime,String blobData,String customerName) //Date visitDate,Time visitedTime,
    {
        System.debug('Inside Save record');
        System.debug('Inside Save CustomerId'+CustomerId);
        System.debug('Inside Save UserId'+UserId);
        System.debug('Inside Save visitedTime'+visitedTime);
        Meeting_Schedule__c ms = new Meeting_Schedule__c();
        if(visitedTime!=null)
        {
            List<String> tm = visitedTime.split(':');
           // List<String> min =tm[2].split('.');
            Time myTime = Time.newInstance(Integer.valueOf(tm[0]), Integer.valueOf(tm[1]),Integer.valueOf(tm[2]), 0); 
             ms.Time__c=myTime;
        }

       // Time timeValue = Time.valueOf(visitedTime);
        	if(CustomerId=='')
            {
                System.debug('CustomerId Empty');
            }
        	if(CustomerId==null)
            {
                System.debug('CustomerId Null');
            }
			if(CustomerId!=null && CustomerId!='') 
            {
                System.debug('CustomerId Have Value :'+CustomerId);
                ms.Customer__c=CustomerId;
            }
            
        
        ms.Duration__c=Duration;
        ms.Notes__c=Notes;
        // ms.Time__c=visitTime;
        // ms.User__c=UserId;
        ms.User__c=UserInfo.getUserId();
        ms.Visit_Date__c=visitedDate;
        ms.Customer_Name__c = customerName;
       // ms.Location__Latitude__s=lat;
      //  ms.Location__Longitude__s=lon;
        insert ms;
        imageUpload(blobData,ms.Id);
        System.debug('Inside Saved record');
        System.debug('Inside Saved record :'+ms.Id);
        return ms.Id;  
    }    


    @AuraEnabled
    public static String imageUpload(String fileData, String recId){
        try{
        Meeting_Schedule__c meetingScheduleObj = new Meeting_Schedule__c();
            meetingScheduleObj = [Select Id, Name From Meeting_Schedule__c Where Id =: recId];
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'Meeting_Schedule.png'; 
            cVersion.Title = 'Meeting_Schedule.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = meetingScheduleObj.Id;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            Insert conDocLinkObj;
            return 'Success';
        }catch(Exception ex){
            System.debug('for checking in file upload ex.getMessage() '+ex.getMessage());
            System.debug('for checking in file upload ex.getLineNumber() '+ex.getLineNumber());
            return null;
        }
    }
    



    
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }        
}