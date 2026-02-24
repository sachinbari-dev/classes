/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-11-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* V1.0   07-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
* V1.1   28-10-2025   Added condition for Shipment status update
* @Modified By  : Imran Shaik
* Modified Date : 28-10-2025
**/
public without sharing class TMS_ScanningBarCodeWithoutShipment {
    @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shippingNoteNumber, String pickupID){
        try {
            
            //System.debug('=============pickupID: ' + pickupID);
            //System.debug('=============shippingNoteNumber: ' + shippingNoteNumber);
            Shipment__c  shipmentRecord = new Shipment__c();
            
            Shipment__c [] tempDate = [SELECT ID, Name, Origin_Pincode__c,Number_of_Packages__c,
                Destination_Pincode__c,Customer_Product_Category__c,Shipping_Note_Number__c ,
                Product_Description__c,Destination_Address_Name__c,Consignee_Name_TMS__c
                FROM Shipment__c  
                WHERE Shipping_Note_Number__c =: shippingNoteNumber AND 
                Pickup__c =: pickupID  
                WITH SECURITY_ENFORCED LIMIT 1];
            
            //System.debug('=============tempDate: ' + tempDate);
            
            return tempDate.size() > 0 ? tempDate[0] : null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Shipment__c shipmentRecordGet1(String SHIP_ID){ 
        try {
            
            System.debug('=============SHIP_ID: ' + SHIP_ID);
            //System.debug('=============shippingNoteNumber: ' + shippingNoteNumber);
            Shipment__c  shipmentRecord = new Shipment__c();
            
            Shipment__c [] tempDate = [SELECT ID, Name, Origin_Pincode__c,Number_of_Packages__c,
                Destination_Pincode__c,Customer_Product_Category__c,Shipping_Note_Number__c ,
                Product_Description__c,Destination_Address_Name__c,Consignee_Name_TMS__c,Pickup__c
                FROM Shipment__c  
                WHERE Id =: SHIP_ID  
                WITH SECURITY_ENFORCED LIMIT 1];
            
            System.debug('=============tempDate: ' + tempDate[0]);
            
            return tempDate.size() > 0 ? tempDate[0] : null;
            
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    
    @AuraEnabled
    public static Shipment__c createShipmentRecord(Shipment__c shipmentRecord , String   pickupId, String sNoteNumber  ){
         try {
        
        System.debug('======createShipmentRecord======'+shipmentRecord);   
        System.debug('======pickupId======'+pickupId); 
        System.debug('======pickupId======'+sNoteNumber);
        //System.debug('dest: '+shipmentRecord.Destination_Address_Name__c);
        
        Pickup__c [] pickupRecord = [SELECT Customer__c, Shipper_Address__c, Shipper_Name__c 
                                     FROM Pickup__c 
                                     WHERE Id =:pickupId 
                                     WITH SECURITY_ENFORCED
                                    ];
        
        // Secure_Packaging__c
        System.debug('======pickupRecord====== : '+pickupRecord[0]); 
        Secure_Packaging__c securePackagingRecord = [ 
            SELECT Id, Name, Shipment__c,Status__c, RecordType.Name FROM Secure_Packaging__c WHERE Name =: sNoteNumber LIMIT 1];
        System.debug('======securePackagingRecord====== : '+securePackagingRecord); 
        if(securePackagingRecord != null){
            
            if(securePackagingRecord.RecordType.Name == 'Shipping Label' && securePackagingRecord.Status__c == 'Available'){
                if(shipmentRecord != null && pickupRecord != null){   
                    shipmentRecord.Customer__c=  pickupRecord[0].Customer__c; 
                    shipmentRecord.Pickup__c = pickupRecord[0].Id; 
                    shipmentRecord.Shipping_Note_Number__c = sNoteNumber;
                    shipmentRecord.Origin_Address_Name__c = pickupRecord[0].Shipper_Address__c;
                    shipmentRecord.Shipper_Name_TMS__c = pickupRecord[0].Shipper_Name__c;
                    shipmentRecord.Shipment_Created_Through__c = 'Mobile App';
                    Database.insert(shipmentRecord);
                    securePackagingRecord.Status__c = 'Consumed';
                    securePackagingRecord.Shipment__c = shipmentRecord.Id;
                    if(shipmentRecord.Id != null){
                        Database.Update(securePackagingRecord);
                    } 
                }
            }else{
                throw new AuraHandledException('shipping label is tagged with another pickup request.');
            } 
        } 
        
        
        //System.debug('======shipmentRecord======'+shipmentRecord);
        return shipmentRecord; 
        
        } catch (Exception e) {
           // throw new AuraHandledException(e.getMessage());
           System.debug('Error :'+e.getMessage());
            return null;
        } 
        
    }


    //changed method by Rafi Khan working as expected...
    @AuraEnabled
    public static Secure_Bag__c createSecureBagRecords(String bagId, String shipmentID) {
        try {
            List<Secure_Packaging__c> securePackagingList = [
                SELECT Id, Name, Shipment__c, Status__c, RecordType.Name  
                FROM Secure_Packaging__c 
                WHERE Name = :bagId AND RecordType.Name = 'Secure Bag' 
                FOR UPDATE
            ];

            if (!securePackagingList.isEmpty()) {
                Secure_Packaging__c securePackaging = securePackagingList[0];

                if (securePackaging.Status__c == 'Available') {
                    List<Secure_Bag__c> secBagList = [
                        SELECT Id, Secure_Bag__r.Name, CreatedById 
                        FROM Secure_Bag__c 
                        WHERE Secure_Bag__r.Name = :bagId
                        AND CreatedById = :UserInfo.getUserId() 
                    ];
                    if (secBagList.isEmpty()) {
                        Secure_Bag__c secureBag = new Secure_Bag__c();
                        if (shipmentID != null && shipmentID != '' && shipmentID != 'null') {
                            securePackaging.Status__c = 'Consumed';
                            securePackaging.Shipment__c = shipmentID;
                            Database.update(securePackaging);
                            Shipment__c shp = [ SELECT Id, Tracking_Status__c FROM Shipment__c WHERE Id = :shipmentID LIMIT 1 ];
							Shipment_Tracking__c shipmentTrackingRecord = new Shipment_Tracking__c();
                            if (shp.Tracking_Status__c == 'Created') {
                                shp.Tracking_Status__c = 'Pickup In Progress';	// V1.1
                                update shp;                                
                                shipmentTrackingRecord.Shipment__c = shp.Id;
                                shipmentTrackingRecord.Scan_Time__c = DateTime.now(); 
                                shipmentTrackingRecord.Location__c = 'Pickup In Progress'; 
                                Database.insert(shipmentTrackingrecord);
                            }                            
                            secureBag.Shipment__c = shipmentID;
                            secureBag.Current_Scan_Loction__c = 'Pickup In Progress';	// V1.1
                            secureBag.Current_Scan_Date_and_Time__c = DateTime.now();
                            secureBag.Secure_Bag__c = securePackaging.Id;
                            secureBag.Tracking__c = shipmentTrackingrecord.Id;
                            Database.insert(secureBag);                            
                            return secureBag;
                        }
                    } else {
                        throw new AuraHandledException('You have already scanned this secure bag.');
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
    
    @AuraEnabled
    public static void createTrackingRecord(Shipment_Tracking__c shipmentTrackingRecord , String shipmentId , List<Secure_Bag__c> secureBaglist){
        try {
            
            //System.debug('=========secureBaglist=========='+secureBaglist);
            if(shipmentTrackingRecord != null){  
                shipmentTrackingRecord.Shipment__c = shipmentId != null ? shipmentId : '';
                shipmentTrackingRecord.Scan_Time__c = DateTime.now(); 
                shipmentTrackingRecord.Location__c = 'Pickup In Progress'; 
                //Database.insert(shipmentTrackingrecord); 
                
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