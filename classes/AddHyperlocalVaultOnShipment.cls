public class AddHyperlocalVaultOnShipment
{
    // Curently Using
    @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shipmentRecordId){
        try { 

            Shipment__c  shipmentRecord = new Shipment__c();

            Shipment__c [] tempDate = [
                SELECT ID, Name, Origin_Pincode__c,Number_of_Packages__c,Destination_Pincode__c,Customer_Product_Category__c,
                No_of_Vaults__c, Shipping_Note_Number__c FROM Shipment__c  WHERE Id =: shipmentRecordId LIMIT 1];
            return tempDate.size() > 0 ? tempDate[0] : null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // currently using
    @AuraEnabled
    public static Pickup__c pickupRecordGet(String pickupId){
        System.debug('27 pickupId :'+pickupId);
        try { 
			Pickup__c pickupRecord = [Select Id,No_of_Vaults__c,Name from Pickup__c where Id=: pickupId limit 1];
            System.debug('27 pickupRecord :'+pickupRecord);
            return pickupRecord;
            
        } catch (Exception e) {
           return null;
        }
    }    

    // currently Using
    @AuraEnabled
    public static Map<String,Hyperlocal_Vault__c> createAddHyperlocalVaultsForPickup(String bagId, String pickupId) {
        Hyperlocal_Vault__c HyperlocalVault = new Hyperlocal_Vault__c();
        Map<String,Hyperlocal_Vault__c> resMap = new  Map<String,Hyperlocal_Vault__c>();
        try {          
            HyperlocalVault = [select Id,Name,Secure_Packaging__r.Name,Pickup__c,Status__c,Shipment__c
                                                       from Hyperlocal_Vault__c 
                                                       where Name=:bagId limit 1];
            Pickup__c pickup = [select Id,Hyperlocal_Vault__c from Pickup__c where Id=:pickupId limit 1];
            String shipId = null;
            try{
                Shipment__c shipRec = [select Id from Shipment__c where 
                                       Pickup__c=:HyperlocalVault.Pickup__c and Pickup__r.Pickup_Status__c='Completed' limit 1];
                shipId = shipRec.Id;
            }catch(exception e){
            }
            
            if (HyperlocalVault!=null) {
                System.debug('52 5888 :');
                if (HyperlocalVault.Status__c == 'Available') {						
                    HyperlocalVault.Status__c='Consumed';
                    HyperlocalVault.Pickup__c = pickupId;
                    HyperlocalVault.Assigned_To__c = UserInfo.getUserId();
                    if(shipId!=null)
                    {
                        HyperlocalVault.Shipment__c = shipId; 
                    }
                    Database.update(HyperlocalVault);
                    resMap.put('success',HyperlocalVault);
                    pickup.Hyperlocal_Vault__c = HyperlocalVault.Id;
                    Database.update(pickup);
                } else {
                    resMap.put('HyperlocalVault is not available',HyperlocalVault);
                }
            } else {
                resMap.put('No HyperlocalVault found.',HyperlocalVault);
            }

        } catch (Exception e) {
        }
        return resMap;
    }    
    
    
// currently Using
    @AuraEnabled
    public static Boolean saveSecureBagPhoto(String fileData, String secBagName){
        
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'HyperlocalVault.png'; 
            cVersion.Title = 'Hyperlocal Vault Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = secBagName;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            contentDocumentList.add(conDocLinkObj);
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
        
            return false;
        }
        
    }
    
    // currently Using
    @AuraEnabled
    public static List<Hyperlocal_Vault__c> getHyperlocalVault(String pickupId ){
        System.debug('365 pickupId:'+pickupId);
        List<Hyperlocal_Vault__c> HyperlocalVaultList = [select Id,Name,Secure_Packaging__r.Name,Pickup__c,Pickup__r.Name
                                                         from Hyperlocal_Vault__c where Pickup__c=:pickupId];
        System.debug('365 HyperlocalVaultList:'+HyperlocalVaultList);
        if(HyperlocalVaultList.size()>0)
        {
            return HyperlocalVaultList;
        }
        else
        {
            return null;
        }
    }
    
}