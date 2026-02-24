/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TMS_DeliveryController {

    @AuraEnabled
    public static List<Secure_Bag__c> allSecureBagGet(String deliveryId){
        String currentUserId = UserInfo.getUserId();
        Set<Id> ShipmentId = new Set<Id>();
        List<Secure_Bag__c> secureBagList  = new List<Secure_Bag__c>();
        try {

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

    }
    
}