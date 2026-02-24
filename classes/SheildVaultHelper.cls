public class SheildVaultHelper 
{
    @AuraEnabled
public static void updatePickupStatusToCompleted(Id pickId) {
    Pickup__c pickup = [SELECT Id,Pickup_Status__c	 FROM Pickup__c WHERE Id = :pickId LIMIT 1];
    pickup.Pickup_Status__c	 = 'Completed';
    update pickup;
}

    @AuraEnabled
    public static Pickup__c getPickupDetails(String pickId)
    {
        System.debug('6 pickId :'+pickId);
        Pickup__c pickup = new Pickup__c();
        try{
            pickup = [select Id,Name,Shipment__c,Shipment__r.Name,Shipment__r.Shipping_Note_Number__c,
                      Customer__r.Name,Customer__c,Origin_Address_Name__c,Origin_Address_Name__r.Name
                      from Pickup__c where Id=:pickId and Shipment__c!=null limit 1];
        }catch(Exception e)
        {
            System.debug('14 Error :'+e.getMessage());
            return null;
        }
        System.debug('17 pickup :'+pickup);
        return pickup; 
    }

    //Added by Rafi Khan for image compression
    //to get loggedIn user Name for saving it on images.
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    //to upload Photo
    @AuraEnabled
    public static String photoUpload(String fileData, String recId){
                       
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            String nm = 'Compress Pickup.png';
            cVersion.PathOnClient = nm; 
            cVersion.Title = nm; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;

            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = recId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            
            return 'Success';
            
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            return 'Null';
        }
        
       
    }

    //upto here

}