@RestResource(urlMapping='/imagecompressor/')
global without sharing class ImageCompressorController {

    @HttpPost
    global static String uploadImage() {
        try {
            
            String requestBody = RestContext.request.requestBody.toString();
            System.debug('for checking Request Body: ' + requestBody);
            
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            String imageContent = (String) requestMap.get('imageContent');
            String recId = (String) requestMap.get('recId');
            
            if (String.isEmpty(imageContent) || String.isEmpty(recId)) {
                return 'Error: Missing imageContent or recId.';
            }
            
            if (imageContent.startsWith('data:image/jpeg;base64,')) {
                imageContent = imageContent.substring('data:image/jpeg;base64,'.length());
            }

            ContentVersion cVersion = new ContentVersion();
            cVersion.PathOnClient = 'CompressedImage.png'; 
            cVersion.Title = 'Compressed Image by Extension ' + Date.today().format(); 
            cVersion.VersionData = EncodingUtil.base64Decode(imageContent); 
            insert cVersion;

            if (cVersion.Id != null) {
                Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;

                ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
                conDocLinkObj.ContentDocumentId = contentDocId;
                conDocLinkObj.LinkedEntityId = recId;
                conDocLinkObj.ShareType = 'V';
                conDocLinkObj.Visibility = 'AllUsers';
                insert conDocLinkObj;
            }

            return 'Image uploaded and attached to record successfully!';
		
        } catch (Exception ex) {
            System.debug('for checking ex.getMessage() ' + ex.getMessage());
            System.debug('for checking ex.getLineNumber() ' + ex.getLineNumber());
            return 'Error: ' + ex.getMessage();
        }
    }
    
}