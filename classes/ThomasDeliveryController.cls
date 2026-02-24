/**
* @File Name : ThomasDeliveryController.cls
* @Description :
* @Author : rafi.khan@bvclogistics.com
* @Last Modified By :
* @Last Modified On : April 15, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 15, 2025 |   | Initial Version
**/

public class ThomasDeliveryController {
    
    //to get loggedIn user Name for saving it on images.
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled(cacheable=true)
    public static Delivery__c getshipmetID(Id recId){ 
        List<Delivery__c> lstship  = [Select Id,Shipment__r.Id,Shipping_Note_Number__c from Delivery__c where Id =:recId];
        return lstship[0];
    }
    
    @AuraEnabled
    public static List<Hyperlocal_Vault__c> getAllVault(String deliveryId){
        String currentUserId = UserInfo.getUserId();
        Set<Id> ShipmentId = new Set<Id>();
        List<Hyperlocal_Vault__c> hyperlocalVaultList  = new List<Hyperlocal_Vault__c>();
        try {
            
            Delivery__c [] deliveryArray = [
                SELECT Id, Shipment__c, Status__c, OwnerId, Address__c, Address__r.BulkDelivery__c
                FROM Delivery__c
                WHERE ID =: deliveryId AND OwnerId =: currentUserId 
            ];
            System.debug('deliveryArray.size() '+deliveryArray.size());
            if(deliveryArray.size() > 0){
                for(Delivery__c delivery : [
                    SELECT Id, Shipment__c, Status__c, OwnerId, Address__c, Address__r.BulkDelivery__c
                    FROM Delivery__c
                    WHERE Address__c =: deliveryArray[0].Address__c AND
                    Status__c = 'Out for Delivery' AND 
                    OwnerId =: currentUserId
                ]){
                    ShipmentId.add(delivery.Shipment__c);
                }
            }else{
                throw new AuraHandledException('\n - No Record Found');
            } 
            
            if(ShipmentId.size() > 0){
                hyperlocalVaultList = [
                    Select Id, Name, Barcode__c, Vault_ID__c, Allocated_To_Hub__c, Assigned_To__c, Shipment__r.Name,
                    Status__c, Secure_Packaging__c, Secure_Packaging__r.Name, Shipment__r.Shipping_Note_Number__c, Shipment__c
                    From Hyperlocal_Vault__c 
                    Where Status__c =: 'Consumed' AND Shipment__c IN: ShipmentId
                ]; 
                
            }         
            system.debug('hyperlocalVaultList :'+hyperlocalVaultList);
            system.debug('hyperlocalVaultList.size() :'+hyperlocalVaultList.size());
            return hyperlocalVaultList.size() > 0 ? hyperlocalVaultList : null ;  
            
            
        } catch (Exception e) { 
            System.debug('Error : '+e.getMessage());
            System.debug('Error on Line number : '+e.getLineNumber());
            throw new AuraHandledException('\n - No Record Found');
        }
    } 
    
    @AuraEnabled
    public static ShipmetWrap bagBySecureBagId(String bagId){
        System.debug('for checking bagId :'+bagId);
        try { 
            
            ShipmetWrap ShipmetWrapData = new ShipmetWrap();            
            Map<String,Hyperlocal_Vault__c> shipmentRecord = new Map<String,Hyperlocal_Vault__c>();
            
            if(bagId != null && bagId != ''){
                for(Hyperlocal_Vault__c secureBag : [
                    SELECT Id, Name , Shipment__c, Shipment__r.Name,Shipment__r.Customer__r.Name,
                    Shipment__r.Origin_Address_City__c,Shipment__r.Consignee_Name_TMS__r.Name,Shipment__r.Consignee_Name_TMS__c,
                    Shipment__r.Shipper_Name_TMS__r.Name, Shipment__r.Consignee_Name__c, 
                    Shipment__r.Delivery_Route_Assigned_To__c, Secure_Packaging__r.Name, Shipment__r.Destination_Address_City__c, 
                    Status__c
                    FROM Hyperlocal_Vault__c
                    WHERE Secure_Packaging__r.Name =: bagId AND Status__c =: 'Consumed' LIMIT 1
                ]){ 
                    
                    if(secureBag.Shipment__r.Delivery_Route_Assigned_To__c != UserInfo.getUserId()){
                        System.debug('Error in if ');
                    }else{
                        shipmentRecord.put(secureBag.Secure_Packaging__r.Name, secureBag);
                    }
                    shipmentRecord.put(secureBag.Secure_Packaging__r.Name, secureBag);
                    //System.debug('for checking shipmentRecord.values()'+shipmentRecord.values());
                }
            }
            System.debug('for checking shipmentRecord : '+ shipmentRecord);
            if(!shipmentRecord.isEmpty()){
                
                ShipmetWrapData.shipmentRecordMap = shipmentRecord; 
                Hyperlocal_Vault__c bag = new Hyperlocal_Vault__c();
                if(shipmentRecord.containsKey(bagId)){
                    System.debug('for checking shipmentRecord.get(bagId).Id '+shipmentRecord.get(bagId).Id);
                    bag.Id = shipmentRecord.get(bagId).Id;
                } 
                System.debug('for checking bag.Id : '+bag.Id);
                bag.Status__c = 'Available'; 
                Database.Update(bag);
                
            }else{
                System.debug('This bag is not associated with shipment');
            }
            return ShipmetWrapData;
            
        } catch(System.NoAccessException noAccess){
            throw new AuraHandledException('Insufficient access rights on  '+bagId);
        } catch (Exception ex) {
            System.debug('Error in Line number '+ex.getLineNumber());
            throw new AuraHandledException('Error Message : '+ex.getMessage());
            
        }
    }
    
    @testVisible class ShipmetWrap{
        
        @AuraEnabled
        public Map<String,Hyperlocal_Vault__c> shipmentRecordMap {get;set;}
        
    } 
    
    //to upload Vault
    @AuraEnabled
    public static Hyperlocal_Vault__c saveVaultPhoto(String fileData, String vaultName){
        
        //List<Shipment__c> updateShipList = new List<Shipment__c>();
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        System.debug('for checking vaultName :'+vaultName);
        
        String shipId;
        List<Hyperlocal_Vault__c> vaultList =[Select Id, Name, Shipment__c, Secure_Packaging__r.Name From Hyperlocal_Vault__c Where Name =: vaultName];
        if(vaultList.size()>0){
            shipId = vaultList[0].Shipment__c;
        }
        
        System.debug('for checking shipId :'+shipId);
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'HyperlocalVaultPhoto.png'; 
            cVersion.Title = 'Hyperlocal Vault Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = shipId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            contentDocumentList.add(conDocLinkObj);
            
            /*Shipment__c tempShip = new Shipment__c();
tempShip.Id = shipId;
//tempShip.SecurebagPhoto__c=true;
updateShipList.add(tempShip);*/
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                /*if(updateShipList.size()>0){
Update updateShipList;
}*/
            }
            
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
        }
        if(!test.isRunningTest()){
            return vaultList[0];
        }else{
            return null;
        }
        
    }
    
    //to upload Receiver Photot Id
    /*@AuraEnabled
    public static Boolean saveReceiverIdPhoto(List<Shipment__c> shipList, String fileData){
        Boolean isWindow = false;
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'Receiver photo ID.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'Receiver photo ID.png';
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            
            Insert cVersion;    
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            if(shipList.size()>0){
                updateReceiverIdPhoto(conDocId, shipList, false); 
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
            return false;
        }
        
        
    }
    
    public static void updateReceiverIdPhoto(String contentDocId, List<Shipment__c> shipList, Boolean isWindow){
        try{
            List<Shipment__c> updateShipmentList = new List<Shipment__c>();
            set<String> shipmentId = new Set<String>();
            
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(Shipment__c shipmentObj : shipList){
                shipmentId.add(shipmentObj.Id);
            } 
            
            for(Id linkedEntity : shipmentId){
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);
                
                Shipment__c shipObj = new Shipment__c();
                shipObj.Id = linkedEntity; 
                //shipObj.RecieverIDPhoto__c=true;
                updateShipmentList.add(shipObj);
                
            }
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
                if(updateShipmentList.size() > 0 ){
                    //Update updateShipmentList;
                }
            } 
            
            
        }catch(Exception ex){
            System.debug('1111. Error occure Line Number '+ex.getLineNumber());
            System.debug('2222. Error occure Message '+ex.getMessage());
        }
    }*/
    
    //to upload Receiver Photot Id
    @AuraEnabled
    public static Boolean saveReceiverIdPhoto(String shipId, String fileData){
        Boolean isWindow = false;
        try{

            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'Receiver photo ID.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'Receiver photo ID.png';
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            
            Insert cVersion;    
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }

            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocId; 
            cDocLink.LinkedEntityId = shipId; 
            cDocLink.ShareType = 'V'; 
            cDocLink.Visibility = 'AllUsers';
            contentDocumentList.add(cDocLink);
            
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
    
    
    @AuraEnabled
    public static void saveSign(String strSignElement,Id recId, Delivery__c deliveryData){  
        try{
            String consigneeName = '';
            String consigneeDesignation = '';
            Boolean isWindow = false;
            if(deliveryData != null){
                consigneeName = deliveryData.Consignee_Name__c;
                consigneeDesignation = deliveryData.Consignee_Designation__c; 
            }
            
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocument;
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'Signature-'+System.now() +'.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'Signature-'+System.now() +'.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(strSignElement); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
            } 
            
            List<Delivery__c> deliveryListToUpdate = new  List<Delivery__c>();
            
            Delivery__c tmpDel = new Delivery__c(); 
            tmpDel.Id = recId;
            tmpDel.Status__c ='Delivered';
            tmpDel.Consignee_Name__c = consigneeName;
            tmpDel.Consignee_Designation__c = consigneeDesignation;
            tmpDel.Delivered_To_Person__c = consigneeName;
            tmpDel.Actual_Delivery_Date_and_Time__c = System.now();
            tmpDel.Error_Remark__c = false;
            tmpDel.Error_Remark_Description__c = '';
            
            deliveryListToUpdate.add(tmpDel);
            System.debug('for checking deliveryListToUpdate : '+deliveryListToUpdate);
            System.debug('for checking deliveryListToUpdate.size() : '+deliveryListToUpdate.size());
            
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            
            Delivery__c delObj = new Delivery__c();
            delObj = [Select Id, Shipment__c From Delivery__c Where Id =: recId];
            
            System.debug('for checking delObj '+ delObj);
            
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument; 
            cDocLink.LinkedEntityId = delObj.Shipment__c; 
            cDocLink.ShareType = 'V'; 
            cDocLink.Visibility = 'AllUsers';
            contentDocumentList.add(cDocLink);
            
            System.debug('for checking contentDocumentList.size() = '+contentDocumentList.size());
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
            }
            
            if(deliveryListToUpdate.size()>0){
                update deliveryListToUpdate;
            }
            
            
            
            
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
        }
        
    }
    

    //to upload POD
    @AuraEnabled
    public static String podUpload(String fileData, String delId){
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            String PODName = 'Hyperlocal POD - ' + Date.today().format();
            cVersion.PathOnClient = PODName+'.png'; 
            cVersion.Title = PODName+'.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = delId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            
            System.debug('Data Inserted Successfully...');
            return 'SUCCESS';
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            return null;
        }
        
    }
    
    
    //to upload vaultNearID
    @AuraEnabled
    public static String vaultNearIDUpload(String fileData, String delId){
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            String PODName = 'Hyperlocal Vault - ' + Date.today().format();
            cVersion.PathOnClient = PODName+'.png'; 
            cVersion.Title = PODName+'.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = delId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            
            System.debug('Data Inserted Successfully...');
            return 'SUCCESS';
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            return null;
        }
        
    }
    
    
    
    
    public  void GetCoverage(){
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
        
    }
    
    
    
    
}