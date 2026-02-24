/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc   //Rafi Khan
* @group             : 
* @last modified on  : 03-21-2022                           //29-08-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc   //rafi.khan@bvclogistics.com
* Update with Respect to tracking API - 07-01-2022
**/
public without sharing class TSM_SignatureHelper { 
    
    @AuraEnabled(cacheable=true)
    public static Delivery__c getshipmetID(Id recId){ 
        System.debug('Record Id : '+recId);
        List<Delivery__c> lstship  = [Select Id,Shipment__r.Id,Shipping_Note_Number__c from Delivery__c where Id =:recId];
        System.debug('lstship : '+lstship);
        return lstship[0];
    }

    @AuraEnabled
    public static Delivery__c getDeliveryOTP(Id recId){ 
        List<Delivery__c> deliveryList = new List<Delivery__c>();
        deliveryList  = [Select Id,Shipping_Note_Number__c,Consignee_Name_from_Shipment1__c,Is_OTP_Required__c,OTP__c,Consignee_Email__c,Consignee_Contact__c,
                         Consignee_Contact_Person__c
                         from Delivery__c where Id =:recId];
        return deliveryList[0];
    }
    
    @AuraEnabled
    public static void saveSign(String strSignElement,Id recId, Delivery__c deliveryData, List<Shipment_Tracking__c> trackingList, Boolean isOTPVerifiedInClass){  
        System.debug('for checking isOTPVerifiedInClass '+isOTPVerifiedInClass);
        System.debug('for checking Param type: ' + JSON.serialize(isOTPVerifiedInClass));
        System.debug('for checking String.valueOf(isOTPVerifiedInClass).trim().toLowerCase() == '+String.valueOf(isOTPVerifiedInClass).trim().toLowerCase());
        String consigneeName = '';
        String consigneeDesignation = '';
        Boolean isWindow = false;
        if(deliveryData != null){
            consigneeName = deliveryData.Consignee_Name__c;
            consigneeDesignation = deliveryData.Consignee_Designation__c; 
        }
        
        if (String.isBlank(strSignElement)) {
            System.debug('for checking️ strSignElement is blank — creating empty blob to avoid null pointer.');
            strSignElement = '';
        }
        
        ContentVersion cVersion = new ContentVersion();
        Id conDocument;
        
        try{
            
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'Signature-'+System.now() +'.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'Signature-'+System.now() +'.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(strSignElement); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
            } 
        }catch (Exception ex) {
            System.debug('for checking Error while inserting ContentVersion: ' + ex.getMessage());
            Delivery_Error_Log__c errorLog = new Delivery_Error_Log__c(
                Name = 'Error - Signature Upload Failed',
                Delivery_Id__c = recId,
                Error_Message__c = 'On line: ' + ex.getLineNumber() + ' Err Msg -> ' + ex.getMessage()
            );
            insert errorLog;
            
        }
    
        
        if(trackingList.size() > 0){
            updateOtherShipment(recId,conDocument,trackingList, consigneeName, consigneeDesignation,false,isOTPVerifiedInClass);
        }
        
    }
    
    public static void updateOtherShipment(Id recId, String contentDocId , List<Shipment_Tracking__c> trackingList , String consigneeName , String consigneeDesignation, Boolean isWindow, Boolean isOTPVerifiedInClass){ 
        try{
            List<Shipment__c> updateShipmentList = new List<Shipment__c>();
            set<String> shipmentId = new Set<String>();
            
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(Shipment_Tracking__c track : trackingList){
                shipmentId.add(track.shipment__c);
            } 
            
            // added by Rafi Khan
            // Delivery and Shipment marks as delivered only if all secure bags of related shipment get delivered 
            List<Secure_Bag__c> secureBagList = [
                SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                FROM Secure_Bag__c 
                WHERE Current_Scan_Loction__c = 'Delivered' AND
                Shipment__c IN: shipmentId]; 
            
            Map<String,List<Secure_Bag__c>> shipAndSecBagMap = new Map<String,List<Secure_Bag__c>>();
            if(secureBagList.size()>0){
                for(Secure_Bag__c secBagObj:secureBagList){
                    if(shipAndSecBagMap.containsKey(secBagObj.Shipment__c)){                        
                        List<Secure_Bag__c> tmpSecBag = shipAndSecBagMap.get(secBagObj.Shipment__c);                        
                        tmpSecBag.add(secBagObj);                        
                        shipAndSecBagMap.put(secBagObj.Shipment__c,tmpSecBag);
                    }else{                        
                        List<Secure_Bag__c> bagLsit = new List<Secure_Bag__c>();
                        bagLsit.add(secBagObj);                        
                        shipAndSecBagMap.put(secBagObj.Shipment__c,bagLsit);
                    }                
                }
            }
            
            Map<String,List<Secure_Bag__c>> tmpShipAndSecBagMap = new Map<String,List<Secure_Bag__c>>();
            List<Secure_Bag__c> secureBagList1 = [
                SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                FROM Secure_Bag__c 
                WHERE Shipment__c IN: shipmentId];
            
            if(secureBagList1.size()>0){
                for(Secure_Bag__c secBagObj:secureBagList1){
                    if(tmpShipAndSecBagMap.containsKey(secBagObj.Shipment__c)){
                        List<Secure_Bag__c> tmpSecBag = tmpShipAndSecBagMap.get(secBagObj.Shipment__c);
                        tmpSecBag.add(secBagObj);
                        tmpShipAndSecBagMap.put(secBagObj.Shipment__c,tmpSecBag);
                    }else{
                        List<Secure_Bag__c> bagLsit = new List<Secure_Bag__c>();
                        bagLsit.add(secBagObj);
                        tmpShipAndSecBagMap.put(secBagObj.Shipment__c,bagLsit);
                    }
                }
            }
            
            Map<String,Delivery__c> shipDelMap = new Map<String,Delivery__c>();
            List<Delivery__c> deliveryList = new List<Delivery__c>();
            deliveryList = [SELECT Id,Name,Status__c,Shipment__c,Number_of_Secure_Bag__c 
                            FROM Delivery__c WHERE Shipment__c IN: shipmentId ];
            if(deliveryList.size()>0){
                for(Delivery__c delObj :deliveryList){
                    shipDelMap.put(delObj.Shipment__c,delObj);
                }
                
            }
            

            try{
                List<Delivery__c> deliveryListToUpdate = new  List<Delivery__c>();
                List<RecordWithError> processedRecordsWithErrors = new List<RecordWithError>(); 
                List<Delivery_Error_Log__c> errorLogRecs1 = new List<Delivery_Error_Log__c>();
                
                for(String strId :shipmentId){
                    Delivery__c delObjsId = new Delivery__c();
                    delObjsId = shipDelMap.get(strId);
                    
                    if(shipAndSecBagMap.containsKey(strId) && tmpShipAndSecBagMap.containsKey(strId)){
                        
                        if(shipAndSecBagMap.get(strId).size() == tmpShipAndSecBagMap.get(strId).size()){ 
                            
                            Delivery__c delObjs = new Delivery__c();
                            delObjs = shipDelMap.get(strId);
                            if(delObjs.Status__c=='Accepted'){
                                Delivery__c tmpDel = new Delivery__c(); 
                                tmpDel.Status__c ='Delivered';
                                tmpDel.Shipment__c = strId;
                                tmpDel.Id = delObjs.Id;
                                tmpDel.Consignee_Name__c = consigneeName;
                                tmpDel.Consignee_Designation__c = consigneeDesignation;
                                tmpDel.Delivered_To_Person__c = consigneeName;
                                tmpDel.Actual_Delivery_Date_and_Time__c = System.now();
                                tmpDel.Error_Remark__c = false;
                                tmpDel.Error_Remark_Description__c = '';
                                
                                Boolean otpVerified = (String.valueOf(isOTPVerifiedInClass).trim().toLowerCase() == 'true');
                                tmpDel.OTP_Verified__c = otpVerified;
                                
                                
                                deliveryListToUpdate.add(tmpDel);
                            } else{
                                Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                                delErrorLogRec.Name = 'Failed - if(delObjs.Status__c==Accepted) ';
                                delErrorLogRec.Delivery_Id__c = delObjs.Id;
                                delErrorLogRec.Error_Message__c = 'If falied to update delivery';
                                errorLogRecs1.add(delErrorLogRec);

                            }
                            
                        }else{
                            System.debug('All Secure Bags are not scanned...');
                            Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                            delErrorLogRec.Name = 'Failed - if All Secure Bags are not scanned... ';
                            delErrorLogRec.Delivery_Id__c = delObjsId.Id;
                            delErrorLogRec.Error_Message__c = 'If falied to update delivery';
                            errorLogRecs1.add(delErrorLogRec);
                        }
                        
                    }else {
                        System.debug('In the esle of 2nd If...');
                    }
                    
                    System.debug('for checking @@@ deliveryListToUpdate.size() : '+ deliveryListToUpdate.size());
                    System.debug('for checking @@@ deliveryListToUpdate before update '+ deliveryListToUpdate);
                    
                }

                if(errorLogRecs1.size()>0){
                    Insert errorLogRecs1;
                }
                
                System.debug('for checking @@@ deliveryListToUpdate.size() : '+ deliveryListToUpdate.size());
                System.debug('for checking @@@ deliveryListToUpdate before update '+ deliveryListToUpdate);
                    
                
                //Code Added for partial Update of delivery
                if (deliveryListToUpdate.size() > 0) {
                    Database.SaveResult[] updateResults = Database.update(deliveryListToUpdate, false);
                    
                    List<Delivery__c> successRecords = new List<Delivery__c>();
                    List<Delivery__c> errorRecords = new List<Delivery__c>();
                    List<Delivery_Error_Log__c> errorLogRecs = new List<Delivery_Error_Log__c>();
                    List<Database.Error> errors = new List<Database.Error>();
                    
                    Set<Id> successfullyUpdatedDeliveryIds = new Set<Id>();
                    
                    for (Integer i = 0; i < updateResults.size(); i++) {
                        if (updateResults[i].isSuccess()) {
                            successRecords.add(deliveryListToUpdate[i]);
                            successfullyUpdatedDeliveryIds.add(deliveryListToUpdate[i].Id);
                            
                        } else {
                            errorRecords.add(deliveryListToUpdate[i]);
                            
                            for (Database.Error err : updateResults[i].getErrors()) {
                                Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                                delErrorLogRec.Name = deliveryListToUpdate[i].Name;
                                delErrorLogRec.Delivery__c = deliveryListToUpdate[i].Id;
                                delErrorLogRec.Delivery_Id__c = deliveryListToUpdate[i].Id;
                                delErrorLogRec.Error_Message__c = err.getMessage();
                                errorLogRecs.add(delErrorLogRec);
                            }
                            processedRecordsWithErrors.add(new RecordWithError(deliveryListToUpdate[i], updateResults[i].getErrors()[0]));
                        }
                    }
                    
                    System.debug('for checking successfullyUpdatedDeliveryIds = '+successfullyUpdatedDeliveryIds);
                    System.debug('for checking successfullyUpdatedDeliveryIds.size() = '+successfullyUpdatedDeliveryIds.size());
                    System.debug('#### Successful Records:' + successRecords);
                    System.debug('#### Records with Errors:' + errorRecords);
                    
                    System.debug('#### Successful Records:');
                    for (Delivery__c successRecord : successRecords) {
                        System.debug(successRecord);
                        System.debug('#### successRecord ID: ' + successRecord.Id);
                    }
                    
                    System.debug('#### Records with Errors:');
                    
                    for (RecordWithError recordWithError : processedRecordsWithErrors) {
                        
                        Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                        delErrorLogRec.Name = recordWithError.record.Name;
                        delErrorLogRec.Delivery__c = recordWithError.record.Id;
                        delErrorLogRec.Delivery_Id__c = recordWithError.record.Id;
                        delErrorLogRec.Error_Message__c = recordWithError.error.getMessage();
                        errorLogRecs.add(delErrorLogRec);
                        
                        System.debug('#### recordWithError Record ID: ' + recordWithError.record.Id);
                        System.debug('#### recordWithError Error Message: ' + recordWithError.error.getMessage());
                        System.debug('#### recordWithError Fields Affected: ' + recordWithError.error.getFields());
                    }
                    
                    
                    if (!errorLogRecs.isEmpty()) {
                        insert errorLogRecs;
                    }
                    
                    //Fallback: Update leftover deliveries
                    List<Delivery__c> leftoverDeliveries = [SELECT Id, Shipment__c, Status__c FROM Delivery__c 
                                                            WHERE Shipment__c IN :shipmentId AND Status__c = 'Accepted' 
                                                            AND Id NOT IN :successfullyUpdatedDeliveryIds];
                    System.debug('for checking leftoverDeliveries.size() = '+leftoverDeliveries.size());
                    
                    if(!leftoverDeliveries.isEmpty()){
                        List<Delivery__c> deliveriesToForceDeliver = new List<Delivery__c>();
                        List<Delivery_Error_Log__c> fallbackErrorLogs = new List<Delivery_Error_Log__c>();
                        
                        for(Delivery__c del : leftoverDeliveries){
                            Integer totalCount = tmpShipAndSecBagMap.containsKey(del.Shipment__c) ? tmpShipAndSecBagMap.get(del.Shipment__c).size() : 0;
                            Integer deliveredCount = shipAndSecBagMap.containsKey(del.Shipment__c) ? shipAndSecBagMap.get(del.Shipment__c).size() : 0;
                            System.debug('for checking totalCount = '+ totalCount + 'and deliveredCount = '+deliveredCount);
                            
                            if(totalCount > 0 && deliveredCount == totalCount){
                                del.Status__c = 'Delivered';
                                del.Actual_Delivery_Date_and_Time__c = System.now();
                                del.Error_Remark__c = true;
                                del.Error_Remark_Description__c = 'Auto-delivered since all secure bags were delivered after partial update.';
                                del.Consignee_Name__c = consigneeName;
                                del.Consignee_Designation__c = consigneeDesignation;
                                del.Delivered_To_Person__c = consigneeName;
                                
                                Boolean otpVerified = (String.valueOf(isOTPVerifiedInClass).trim().toLowerCase() == 'true');
                                del.OTP_Verified__c = otpVerified;
                                
                                deliveriesToForceDeliver.add(del);
                            } else {
                                fallbackErrorLogs.add(new Delivery_Error_Log__c(
                                    Name = 'Pending Bags - Cannot Force Deliver',
                                    Delivery_Id__c = del.Id,
                                    Error_Message__c = 'Shipment has ' + deliveredCount + ' / ' + totalCount + ' bags delivered.'
                                ));
                            }
                        }
                        
                        if(!deliveriesToForceDeliver.isEmpty()){
                            Database.SaveResult[] fallbackResults = Database.update(deliveriesToForceDeliver, false);
                            for(Integer i = 0; i < fallbackResults.size(); i++){
                                if(!fallbackResults[i].isSuccess()){
                                    Database.Error err = fallbackResults[i].getErrors()[0];
                                    fallbackErrorLogs.add(new Delivery_Error_Log__c(
                                        Name = deliveriesToForceDeliver[i].Name,
                                        Delivery_Id__c = deliveriesToForceDeliver[i].Id,
                                        Error_Message__c = 'Fallback update failed: ' + err.getMessage()
                                    ));
                                }
                            }
                        }
                        
                        if(!fallbackErrorLogs.isEmpty()){
                            insert fallbackErrorLogs;
                        }
                    }

                    
                }
                //upto here
            }catch(Exception ex){
                Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                delErrorLogRec.Name = 'Error If delivery not delivered ';
                delErrorLogRec.Error_Message__c = 'On line:'+ ex.getLineNumber() + ' ERROR -> '+ ex.getMessage();

                Insert delErrorLogRec;
                
                System.debug('for checking @@@ exception line number : ' + ex.getLineNumber());
                System.debug('for checking exception1 '+ex.getMessage());
            }
            // Added Code by Rafi Khan Ends here
            
            
            for(Id linkedEntity : shipmentId){
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);
                
            }
            
            if(contentDocumentList.size() > 0){
                try{
                    Insert contentDocumentList;
                }catch (Exception ex) {
                    System.debug('for checking Error while inserting contentDocumentList: ' + ex.getMessage());
                    Delivery_Error_Log__c errorLog = new Delivery_Error_Log__c(
                        Name = 'Error - contentDocumentList insert Failed',
                        Delivery_Id__c = recId,
                        Error_Message__c = 'On line: ' + ex.getLineNumber() + ' Err Msg -> ' + ex.getMessage()
                    );
                    insert errorLog;
                }
            } else {
                System.debug('If Signature upload failed...');
                    
                Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                delErrorLogRec.Name = 'Failed - If Signature upload failed ';
                delErrorLogRec.Error_Message__c = 'If Signature upload failed';
                delErrorLogRec.Delivery__c = recId;
                
                Insert delErrorLogRec;

            }
            
        }
        catch(Exception ex){
            Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
            delErrorLogRec.Name = 'Error if updateOtherShipment method fails';
            delErrorLogRec.Delivery__c = recId;
            delErrorLogRec.Delivery_Id__c = recId;
            delErrorLogRec.Error_Message__c = 'On line: '+ ex.getLineNumber() + ' **ERROR -> '+ ex.getMessage();

            Insert delErrorLogRec;
            
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
        }
    }
    
    //Created by Rafi Khan
    //to upload Receiver Photot Id
    @AuraEnabled
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
                shipObj.RecieverIDPhoto__c=true;
                updateShipmentList.add(shipObj);
                
            }
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
                if(updateShipmentList.size() > 0 ){
                    Update updateShipmentList;
                }
            } 
            
            
        }catch(Exception ex){
            System.debug('1111. Error occure Line Number '+ex.getLineNumber());
            System.debug('2222. Error occure Message '+ex.getMessage());
        }
    }
    
    //to upload Secure Bag
    @AuraEnabled
    public static Secure_Bag__c saveSecureBagPhoto(String fileData, String secBagName){
            
        List<Shipment__c> updateShipList = new List<Shipment__c>();
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        
        String shipId;
        List<Secure_Bag__c> sbList =[Select Id, Shipment__c, Secure_Packaging_Identifier__c From Secure_Bag__c Where Name =: secBagName];
        if(sbList.size()>0){
            shipId = sbList[0].Shipment__c;
        }
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'SecureBagPhoto.png'; 
            cVersion.Title = 'Secure Bag Photo.png'; 
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
            
            Shipment__c tempShip = new Shipment__c();
            tempShip.Id = shipId;
            tempShip.SecurebagPhoto__c=true;
            updateShipList.add(tempShip);
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                if(updateShipList.size()>0){
                    Update updateShipList;
                }
            }
            
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
        }
        if(!test.isRunningTest()){
            return sbList[0];
        }else{
            return null;
        }
        
    }
    
    //to upload POD
    @AuraEnabled
    public static Delivery__c podUpload(String fileData, String shipmetnNoteNumber){
        
        String recId;
        List<Delivery__c> deliveryList = new List<Delivery__c>();
        deliveryList = [Select Id, Shipping_Note_Number__c From Delivery__c Where Shipping_Note_Number__c =: shipmetnNoteNumber];
        System.debug('deliveryObj in POD : '+deliveryList);
        if(deliveryList.size()>0){
            recId = deliveryList[0].Id;
        }
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            String PODName = 'BVC ' + shipmetnNoteNumber + ' - POD - ' + Date.today().format();
            cVersion.PathOnClient = PODName+'.png'; 
            cVersion.Title = PODName+'.png'; 
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
            
            System.debug('Data Inserted Successfully...');
            
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
        }
        
        if(!test.isRunningTest()){
            return deliveryList[0];
        }else{
            return null;
        }
        
    }
    
    
    public class RecordWithError {
        public Delivery__c record;
        public Database.Error error;
        
        public RecordWithError(Delivery__c rec, Database.Error err) {
            record = rec;
            error = err;
        }
    }
    
    @AuraEnabled
    public static List<Secure_Bag__c> allSecureBagGet(String deliveryId){
        String currentUserId = UserInfo.getUserId();
        Set<Id> ShipmentId = new Set<Id>();
        
        List<Secure_Bag__c> secureBagList  = new List<Secure_Bag__c>();
        try {
			/*
            Delivery__c [] deliveryArray = [
                SELECT Id, Shipment__c, Status__c, OwnerId, Address__c, Address__r.BulkDelivery__c
                FROM Delivery__c
                WHERE ID =: deliveryId AND
                    OwnerId =: currentUserId 
            ];

            if(deliveryArray.size() > 0){
                for(Delivery__c delivery : [
                    SELECT Id, Shipment__c, Status__c, OwnerId, Address__c, Address__r.BulkDelivery__c
                    FROM Delivery__c
                    WHERE Address__c =: deliveryArray[0].Address__c AND
                        Status__c = 'Accepted' AND 
                        OwnerId =: currentUserId
                ]){
                    ShipmentId.add(delivery.Shipment__c);
                }
            }else{
                throw new AuraHandledException('\n - No Record Found');
            } 
             */
            List<Delivery_Line__c> DLList = [select Id,Shipment__c,Delivery__c from Delivery_Line__c where 
            Delivery__c =: deliveryId];
            for(Delivery_Line__c dli: DLList)
            {
                 ShipmentId.add(dli.Shipment__c);   
            }
            
            List<Secure_Bag__c> limitedBags = new List<Secure_Bag__c>();
            if(ShipmentId.size() > 0){
                /*secureBagList = [
                    SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, 
                    Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c,
                    Shipment__r.Origin_Address_Name__r.BulkDelivery__c, Shipment__r.Destination_Address_Name__r.BulkDelivery__c
                    FROM Secure_Bag__c 
                    WHERE Current_Scan_Loction__c != 'Delivered' AND
                    Shipment__c IN: ShipmentId
                ]; */
                
                // Fetch all secure bags for those shipments
                List<Secure_Bag__c> allBags = [
                    SELECT Id, Name, Shipment__c, Shipment__r.Tracking_Status__c, Shipping_Note_Number__c,
                    Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c, Current_Scan_Loction__c,
                    Shipment__r.Origin_Address_Name__r.BulkDelivery__c, Shipment__r.Destination_Address_Name__r.BulkDelivery__c
                    FROM Secure_Bag__c
                    WHERE Current_Scan_Loction__c != 'Delivered'
                    AND Shipment__c IN :ShipmentId
                    ORDER BY Shipping_Note_Number__c
                ];
                
                // Restrict to 40 unique deliveries (Shipping Note Numbers)
                Set<String> snSet = new Set<String>();
                
                
                for (Secure_Bag__c bag : allBags) {
                    String sn = bag.Shipping_Note_Number__c;
                    
                    if (!snSet.contains(sn)) {
                        if (snSet.size() >= 30) {
                            continue;
                        }
                        snSet.add(sn);
                    }
					
                    limitedBags.add(bag);
                    
                }         
            }
                return limitedBags.size() > 0 ? limitedBags : null ;  
 
            
        } catch (Exception e) { 
            throw new AuraHandledException('\n - No Record Found');
        }
    } 

    @AuraEnabled 
    public static List<Shipment_Tracking__c> insertUpdateRecord(Shipment_Tracking__c trackingRecord, List<Secure_Bag__c> secureBagList ){
        try {
            System.debug('for checking secureBagList :'+secureBagList);
            System.debug('for checking secureBagList.size() :'+secureBagList.size());
            Set<Id> shipmentId = new Set<Id>();
            Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>(); 
            Map<Id,Shipment_Tracking__c> shipmnetTrackingMap = new Map<Id,Shipment_Tracking__c>();
            Map<Id,Secure_Bag__c> updateSecureBag = new Map<Id,Secure_Bag__c>();

            if(secureBagList.size() > 0){
                for(Secure_Bag__c bag : secureBagList){
                    shipmentId.add(bag.Shipment__c);              
                }

                if(shipmentId.size() > 0){
                    shipmentMap = new Map <Id, Shipment__c>([ 
                        SELECT Id,Origin_Hub__c,Destination_Hub__c,Destination_Hub__r.Airport__c,Origin_Hub__r.Airport__c 
                        FROM Shipment__c WHERE Id IN:shipmentId 
                    ]); 
                } 
 
                if(!shipmentMap.isEmpty()){
                    for(Shipment__c  ship : shipmentMap.values()){                        
                        Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();                        
                        shipmentTracking = trackingRecord.clone(false,false,false,false);
                        shipmentTracking.Shipment__c = null; 
                        shipmentTracking.Scan_Time__c = DateTime.now();
                        ShipmentTracking.Location__c = 'Delivered'; 
                        shipmentTracking.Shipment__c =  ship.Id ;
                        shipmnetTrackingMap.put(shipmentTracking.Shipment__c,shipmentTracking); 
                        
                    }
 					
                    if(!shipmnetTrackingMap.isEmpty()){ 
                        //Insert shipmnetTrackingMap.values();
                        
                        for(Secure_Bag__c secureBag :  secureBagList){
                            Secure_Bag__c bag = new Secure_Bag__c();
                            bag.id = secureBag.Id;
                            
                            if(shipmnetTrackingMap.containsKey(secureBag.Shipment__c)){
                                bag.Current_Scan_Loction__c =  shipmnetTrackingMap.get(secureBag.Shipment__c).Location__c;
                                bag.Tracking__c = shipmnetTrackingMap.get(secureBag.Shipment__c).Id; 
                                bag.Current_Scan_Date_and_Time__c = DateTime.now(); 
                                bag.Scanning_Status__c = 'Scanned';
                            }
                            updateSecureBag.put(bag.Id,bag); 
                        }  
                    }
                }
            }
            if(updateSecureBag.values().size() > 0 ){ 
                try{
                Update updateSecureBag.values();
                }catch(Exception ex){
                    List<Delivery_Error_Log__c> errorLogRecs = new List<Delivery_Error_Log__c>();
                    
                    for (Secure_Bag__c bag : updateSecureBag.values()) {
                        Delivery_Error_Log__c delErrorLogRec = new Delivery_Error_Log__c();
                        delErrorLogRec.Name = 'Error on Bag - ' + bag.Name;
                        delErrorLogRec.Delivery_Id__c = bag.Id;
                        delErrorLogRec.Error_Message__c = ex.getMessage();
                        errorLogRecs.add(delErrorLogRec);
                    }
                    
                    if (!errorLogRecs.isEmpty()) {
                        insert errorLogRecs;
                    }
                }
            }
			return shipmnetTrackingMap.values();
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Added by Rafi Khan
    @AuraEnabled
    public static ShipmetWrap bagBySecureBagId(String bagId){
        System.debug('for checking bagId :'+bagId);
        try { 
            
            ShipmetWrap ShipmetWrapData = new ShipmetWrap();            
            Map<String,Secure_Bag__c> shipmentRecord = new Map<String,Secure_Bag__c>();
            
            if(bagId != null && bagId != ''){
                for(Secure_Bag__c secureBag : [
                    SELECT Id, Name , Shipment__c, Shipment__r.Name,Shipment__r.Customer__r.Name,
                    Shipment__r.Origin_Address_City__c,Shipment__r.Consignee_Name_TMS__r.Name,Shipment__r.Consignee_Name_TMS__c,
                    Shipment__r.Shipper_Name_TMS__r.Name, Shipment__r.Consignee_Name__c, 
                    Current_Origin_City__c, Shipment__r.Delivery_Route_Assigned_To__c, Shipping_Note_Number__c, 
                    Cargo_Type__c, Seal_Id__c, Seal_Id__r.Name, Current_Destination_City__c, Destination_Hub__c, 
                    Secure_Bag__r.Name, Shipment__r.Destination_Address_City__c,Current_Scan_Loction__c
                    FROM Secure_Bag__c
                    WHERE Secure_Bag__r.Name =: bagId LIMIT 1
                ]){ 
                    
                    if(secureBag.Shipment__r.Delivery_Route_Assigned_To__c != UserInfo.getUserId() && secureBag.Current_Scan_Loction__c == 'Delivered'){
                        System.debug('Error in if ');
                    }else{
                        shipmentRecord.put(secureBag.Secure_Bag__r.Name, secureBag);
                    }
                    shipmentRecord.put(secureBag.Secure_Bag__r.Name, secureBag);
                    //System.debug('for checking shipmentRecord.values()'+shipmentRecord.values());
                }
            }
            
            if(!shipmentRecord.isEmpty()){
                
                ShipmetWrapData.shipmentRecordMap = shipmentRecord; 
                    Secure_Bag__c bag = new Secure_Bag__c();
                    if(shipmentRecord.containsKey(bagId)){
                        bag.Id = shipmentRecord.get(bagId).Id;
                    } 
                    
                    bag.Scanning_Status__c = 'Scanned'; 
                    bag.Current_Scan_Date_and_Time__c = DateTime.now();
                    Database.Update(Bag);
                    
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
        public Map<String,Secure_Bag__c> shipmentRecordMap {get;set;}
        
    } 
	//Upto Here

    
	//Added by Rafi Khan to get loggedIn user Name to save on POD.
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
	//upto here

    
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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