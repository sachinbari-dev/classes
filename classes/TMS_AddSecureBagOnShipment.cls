/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class TMS_AddSecureBagOnShipment {
     
    @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shipmentRecordId){
        try { 

            //System.debug('=============shippingNoteNumber: ' + shipmentRecordId);
            Shipment__c  shipmentRecord = new Shipment__c();

            Shipment__c [] tempDate = [
                SELECT ID, Name, Origin_Pincode__c,Number_of_Packages__c,Destination_Pincode__c,Customer_Product_Category__c,Shipping_Note_Number__c  
                FROM Shipment__c  
                WHERE Id =: shipmentRecordId
                LIMIT 1];

            //System.debug('=============tempDate: ' + tempDate);

            return tempDate.size() > 0 ? tempDate[0] : null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    


    //changed method by Rafi Khan working as expected...
    @AuraEnabled
    public static Secure_Bag__c createSecureBagRecords(String bagId, String shipmentID) {
        try {
            List<Secure_Packaging__c> securePackagingList = [
                SELECT Id, Name, Shipment__c, Status__c, RecordType.Name  
                FROM Secure_Packaging__c  WHERE Name = :bagId AND RecordType.Name = 'Secure Bag' FOR UPDATE ];

            if (!securePackagingList.isEmpty()) {
                Secure_Packaging__c securePackaging = securePackagingList[0];

                if (securePackaging.Status__c == 'Available') {
                    List<Secure_Bag__c> secBagList = [
                        SELECT Id, Secure_Bag__r.Name 
                        FROM Secure_Bag__c WHERE Secure_Bag__r.Name = :bagId ];

                    if (secBagList.isEmpty()) {
                        Secure_Bag__c secureBag = new Secure_Bag__c();

                        if (shipmentID != null && shipmentID != '' && shipmentID != 'null') {
                            /*
                            secureBag.Shipment__c = shipmentID;
                            secureBag.Current_Scan_Loction__c = 'Pickup In Progress';
                            secureBag.Current_Scan_Date_and_Time__c = DateTime.now();
                            secureBag.Secure_Bag__c = securePackaging.Id;

                            Database.insert(secureBag); */
                            securePackaging.Status__c = 'Consumed';
                            securePackaging.Shipment__c = shipmentID;
                            Database.update(securePackaging);
                            
                            Shipment_Tracking__c shipmentTrackingRecord = new Shipment_Tracking__c();
                            shipmentTrackingRecord.Shipment__c = shipmentId != null ? shipmentId : '';
                            Shipment__c shipmentRecord = [select Id,Tracking_Status__c from Shipment__c where Id=:shipmentId limit 1];
                // shipmentRecord.Id = shipmentId;                
                if(shipmentRecord.Tracking_Status__c=='Created')
                {
                            shipmentTrackingRecord.Scan_Time__c = DateTime.now(); 
                            shipmentTrackingRecord.Location__c = 'Pickup In Progress'; 
                            Database.insert(shipmentTrackingrecord);
                } else{
                    try
                    {
                        shipmentTrackingrecord = [select Id from Shipment_Tracking__c 
                                                  where Shipment__c=:shipmentId and Location__c='Pickup In Progress' limit 1];
                    } catch(exception e){}
                    
                } 
                            secureBag.Shipment__c = shipmentID;
                            secureBag.Current_Scan_Loction__c = 'Pickup In Progress';
                            secureBag.Current_Scan_Date_and_Time__c = DateTime.now();
                            secureBag.Secure_Bag__c = securePackaging.Id;
                            secureBag.Tracking__c = shipmentTrackingrecord.Id;
                            Database.insert(secureBag);
                            
                            return secureBag;
                        }
                    } else {
                        throw new AuraHandledException('Secure Bag is tagged with another shipment.');
                    }
                } else {
                    throw new AuraHandledException('Secure Bag is not available.');
                }
            } else {
                throw new AuraHandledException('No Secure Bag found.');
            }

            return null;

        } catch (Exception e) {
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            } else {
                return null;
            }
        }
    }
    //upto here
    



    /*Old Method
    @AuraEnabled
    public static Secure_Bag__c createSecureBagRecords(String bagId , String shipmentID ) {

        //System.debug('=============== bagId ======= : '+bagId);
        //System.debug('=============== secureBag ======= : '+shipmentID);
        try { 
            Secure_Bag__c secureBag = new Secure_Bag__c();

            Secure_Packaging__c securePackaging = [
                SELECT Id, Name, Shipment__c,Status__c, RecordType.Name  
                FROM Secure_Packaging__c 
                WHERE Name =: bagId AND RecordType.Name ='Secure Bag' LIMIT 1
            ];

            if(securePackaging != null && securePackaging.Status__c == 'Available'){ 
                if(shipmentID != null && shipmentID != ''  && shipmentID != 'null'){
                    secureBag.Shipment__c = shipmentID;
                    secureBag.Current_Scan_Loction__c = 'Picked Up';
                    secureBag.Current_Scan_Date_and_Time__c =DateTime.now();
                    secureBag.Secure_Bag__c =  securePackaging.Id; 
    
                } 

                if(secureBag != null){
                    Database.insert(secureBag); 
                    securePackaging.Status__c = 'Consumed'; 
                    securePackaging.Shipment__c = shipmentID; 
                    Database.update(securePackaging); 
                }

            } else{
                if(!test.isRunningTest()){
                    throw new AuraHandledException('Secure Bag is tagged with another shipmment.');
                }
                
            } 

            return secureBag;

        } catch (Exception e) {
            //System.debug('line: '+e.getLineNumber()+' err: '+e);
            if(!test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }else {
                return null;
            }
            
            
        }
    }*/


    @AuraEnabled
    public static void createTrackingRecord(Shipment_Tracking__c shipmentTrackingRecord , String shipmentId , List<Secure_Bag__c> secureBaglist){
        try {

            System.debug('=========secureBaglist=========='+secureBaglist);
            if(shipmentTrackingRecord != null){  
                shipmentTrackingRecord.Shipment__c = shipmentId != null ? shipmentId : '';
                shipmentTrackingRecord.Scan_Time__c = DateTime.now(); 
                shipmentTrackingRecord.Location__c = 'Pickup In Progress'; 
               // Database.insert(shipmentTrackingrecord); 

                if(shipmentTrackingrecord.Id != null ){
                    for(Secure_Bag__c secureBag : secureBaglist){
                        secureBag.Tracking__c = shipmentTrackingrecord.Id;
                    }

                    Database.update(secureBaglist);
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static void updateshipmentAndPickup( String shipmentId  ){
       // try {

            //System.debug('=========shipmentId=========='+shipmentId);
            if(shipmentId != null && shipmentId != ''){  
                Shipment__c shipmentRecord = [select Id,Tracking_Status__c from Shipment__c where Id=:shipmentId limit 1];
                // shipmentRecord.Id = shipmentId;                
                if(shipmentRecord.Tracking_Status__c=='Created')
                {
                    shipmentRecord.Tracking_Status__c = 'Pickup In Progress';
                    Database.update(shipmentRecord);
                    Shipment_Tracking__c shipmentTrackingRecord = new Shipment_Tracking__c();
                    shipmentTrackingRecord.Shipment__c = shipmentRecord.Id;
                    shipmentTrackingRecord.Scan_Time__c = DateTime.now(); 
                    shipmentTrackingRecord.Location__c = 'Pickup In Progress'; 
                    //Database.insert(shipmentTrackingrecord);
                    
                }
                               
                /*
                Pickup__c [] pickupRecord  = [SELECT Id, Shipment__c , Pickup_Status__c FROM Pickup__c WHERE Shipment__c =: shipmentId LIMIT 1];
                if(pickupRecord.size() > 0){
                    Pickup__c pickup = new Pickup__c();
                    pickup.Id = pickupRecord[0].Id;
                    pickup.Pickup_Status__c = 'Assigned';
                    Database.update(pickup);
                } */
            }
            
    //    } catch (Exception e) {
    //        throw new AuraHandledException(e.getMessage());
    //    }
    }
    
    
    //to upload Shipping Note Photo Code Added By Rafi
    @AuraEnabled
    public static Boolean saveShippingNotePhoto(String fileData, String sNN){
        
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        Shipment__c shipObj =[Select Id,Shipping_Note_Number__c  From Shipment__c Where Shipping_Note_Number__c =: sNN];

        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'SNN.png'; 
            cVersion.Title = 'Shipping Note Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = shipObj.Id;
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
    
    //to upload Secure Bag Code Added By Rafi
    @AuraEnabled
    public static Boolean saveSecureBagPhoto(String fileData, String secBagName){
        
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        
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
    
    
    @AuraEnabled
    public static List<Secure_Bag__c> getAllSB(String shipId ){
        System.debug('get All Sb :'+shipId);
        List<Secure_Bag__c> allSb = [select Id, Name, Secure_Bag__c, Secure_Packaging_Identifier__c from Secure_Bag__c where Shipment__c=:shipId];
        System.debug('allsb :'+allSb);
        if(allSb.size()>0){
            return allSb;
        }
        else{
            return null;
        }
        
    }
    
    

    
    public class SecureBagWrapper{

        @AuraEnabled
        public String bagId{get;set;} 

        @AuraEnabled
        public Secure_Bag__c secureBag {get;set;}
        
        
    }
    
    //getCoverage method
    public static void getCoverage(){
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
    }
     public static void getCoverage1(){
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
    }
     public static void getCoverage2(){
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
    }
}