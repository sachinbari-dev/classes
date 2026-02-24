/**
* @description       : Helper class for SecurityScan
* @author            : Imran Shaik
* @last modified on  : 16-09-2025
**/
public class SecurityScanHelper {
    public class ResponseWrapper {
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Secure_Packaging__c spRecord { get; set; }
        @AuraEnabled public List<Secure_Packaging__c> spRecordiLst { get; set; }
    }
    
    public class spList {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
    }
    // completeScanAction
    @AuraEnabled
    public static ResponseWrapper completeScanAction(String scannedItems,String selectedMovementTypeValue,String vehicleNumber)
    {
        ResponseWrapper res = new ResponseWrapper();
        String ErrorMessage = '';
        
        System.debug('16 scannedItems :'+scannedItems);
        List<spList> recordsList = (List<spList>) JSON.deserialize(scannedItems, List<spList>.class);
        List<String> spNales =  new List<String>();
        System.debug('22 recordsList :'+recordsList);
        if(recordsList.size()>0)
        {
            for(spList sp:recordsList)
            {
                spNales.add(sp.name) ;
            }
            System.debug('spNales :'+spNales);
            List<Secure_Packaging__c> spList = [
                SELECT id, Name, Shipment__r.Name, Shipment__c, Type_of_Packaging__c,
                Shipment__r.Pickup__c, Shipment__r.Pickup__r.Name,Vehicle_Number__c,
                Security_Scanned__c, Scanned_User__c, Scanned_Time__c, Scanned_Hub__c, Scanned_Hub__r.Name,
                Linehaul_Scanned_User__c, Linehaul_Scanned_Time__c, Linehaul_Scanned_Hub__c,
                Delivery_Scanned_User__c, Delivery_Scanned_Time__c, Delivery_Scanned_Hub__c,
                Shipment__r.Pickup__r.Pickup_Assigned_To__c, Shipment__r.Pickup__r.Pickup_Assigned_To__r.Name,
                Shipment__r.Tracking_Status__c, Shipment__r.Origin_Hub__r.Name, Shipment__r.Shipping_Note_Number__c,
                Shipment__r.Destination_Hub__c, Shipment__r.Destination_Hub__r.Name,Movement_Type__c,
                Pickup_Security_Scanned__c,Linehaul_Security_Scanned__c,Delivery_Security_Scanned__c,
                Shipment__r.Delivery_Route_Assigned_To__c, Shipment__r.Delivery_Route_Assigned_To__r.Name
                FROM Secure_Packaging__c WHERE Name IN : spNales];            
            
            System.debug('43 spList :'+spList);
            if(spList.size()>0)
            {
                User currentUser = [SELECT Id, Name, City, User_Hub__c,Hub__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                Hub__c hub;
                if (currentUser != null && currentUser.City != null) {
                    List<Hub__c> hubs = [SELECT Id, Name, City__c, Hub_City__c FROM Hub__c WHERE Name = :currentUser.Hub__c LIMIT 1];
                    if (!hubs.isEmpty()) {  hub = hubs[0]; }
                }
                
                List<Security_Scan_Packs__c> scspList = new List<Security_Scan_Packs__c>();
                List<Secure_Packaging__c> spListToUpdate = new List<Secure_Packaging__c>();
                for(Secure_Packaging__c spp:spList) 
                {
                    Security_Scan_Packs__c scsp = new Security_Scan_Packs__c();
                    scsp.Scanned_By__c = currentUser.Id;
                    scsp.Secure_Packaging__c = spp.Id;
                    scsp.Movement_Type__c = selectedMovementTypeValue;
                    scspList.add(scsp);
                    if(hub!=null){  spp.Scanned_Hub__c = hub.Id; }
                    spp.Scanned_Time__c = Datetime.now();
                    spp.Scanned_User__c = currentUser.Id;
                    spp.Pickup_Security_Scanned__c = true;
                    spp.Movement_Type__c = selectedMovementTypeValue;
                    if(vehicleNumber!=null && vehicleNumber!='')
                    {
                        spp.Vehicle_Number__c = vehicleNumber;
                    }
                    spListToUpdate.add(spp);
                    System.debug('65 spp :'+spp);
                }
                try{                 
                    System.debug('68 spListToUpdate :'+spListToUpdate);
                    update spListToUpdate;
                    insert scspList;
                    res.message = 'Success';
                    res.spRecordiLst = spListToUpdate;
                    System.debug('6999999999999 SUCCESS');
                }catch(exception e)
                {
                    res.message = 'fail'+e.getMessage();
                    res.spRecordiLst = null; 
                }
            }
        }
        return res;
    }
    
    @AuraEnabled
    public static String checkRecord(String spName)
    {
        String result;
        try
        {
            Secure_Packaging__c sp = [select Id from Secure_Packaging__c where Name =:spName limit 1];
            if(sp!=null)
            {
                result = 'success';
            }
        }catch(Exception e)
        {
            result='fail';
        }  
        return result;
    }
    @AuraEnabled
    public static User geCurrenttUserRecord() {
        return [SELECT Id, Name, City, User_Hub__c,Hub__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    @AuraEnabled
    public static List<Security_Scan_Packs__c> getTodaySSPRecords() {
        List<Security_Scan_Packs__c> sspList =[select Id,Scanned_By__c,Scanned_By__r.Name,Movement_Type__c,Secure_Packaging__c,
                                               Secure_Packaging__r.Id,Secure_Packaging__r.Shipment__r.Name,Secure_Packaging__r.Name,
                                               Secure_Packaging__r.Shipment__c, CreatedDate,
                                               Secure_Packaging__r.Shipment__r.Pickup__c, 
                                               Secure_Packaging__r.Shipment__r.Pickup__r.Name,
                                               Secure_Packaging__r.Scanned_User__r.Name,
                                               Secure_Packaging__r.Security_Scanned__c, 
                                               Secure_Packaging__r.Scanned_User__c, 
                                               Secure_Packaging__r.Scanned_Time__c, 
                                               Secure_Packaging__r.Scanned_Hub__c, 
                                               Secure_Packaging__r.Scanned_Hub__r.Name,
                                               Secure_Packaging__r.Linehaul_Scanned_Time__c,
                                               Secure_Packaging__r.Delivery_Scanned_Time__c,
                                               Secure_Packaging__r.Shipment__r.Pickup__r.Pickup_Assigned_To__c, 
                                               Secure_Packaging__r.Shipment__r.Pickup__r.Pickup_Assigned_To__r.Name,
                                               Secure_Packaging__r.Shipment__r.Tracking_Status__c, 
                                               Secure_Packaging__r.Shipment__r.Origin_Hub__r.Name, 
                                               Secure_Packaging__r.Shipment__r.Shipping_Note_Number__c,
                                               Secure_Packaging__r.Shipment__r.Destination_Hub__c, 
                                               Secure_Packaging__r.Shipment__r.Destination_Hub__r.Name,
                                               Secure_Packaging__r.Vehicle_Number__c,
                                               Secure_Packaging__r.Movement_Type__c,
                                               Secure_Packaging__r.Pickup_Security_Scanned__c,
                                               Secure_Packaging__r.Linehaul_Security_Scanned__c,
                                               Secure_Packaging__r.Delivery_Security_Scanned__c,
                                               Secure_Packaging__r.Shipment__r.Delivery_Route_Assigned_To__c, 
                                               Secure_Packaging__r.Shipment__r.Delivery_Route_Assigned_To__r.Name
                                               from Security_Scan_Packs__c 
                                               where Scanned_By__c=:UserInfo.getUserId() and CreatedDate=TODAY order by CreatedDate desc ];
        
        return sspList;        
    }
    @AuraEnabled
    public static List<Secure_Packaging__c> getTodayRecords() {              
        return [ SELECT id, Name, Shipment__r.Name, Shipment__c, Shipment__r.Pickup__c, Shipment__r.Pickup__r.Name,Scanned_User__r.Name,
                Security_Scanned__c, Scanned_User__c, Scanned_Time__c, Scanned_Hub__c, Scanned_Hub__r.Name,
                Linehaul_Scanned_Time__c, Delivery_Scanned_Time__c, // Added for query consistency
                Shipment__r.Pickup__r.Pickup_Assigned_To__c, Shipment__r.Pickup__r.Pickup_Assigned_To__r.Name,
                Shipment__r.Tracking_Status__c, Shipment__r.Origin_Hub__r.Name, Shipment__r.Shipping_Note_Number__c,
                Shipment__r.Destination_Hub__c, Shipment__r.Destination_Hub__r.Name,Vehicle_Number__c,Movement_Type__c,
                Pickup_Security_Scanned__c,Linehaul_Security_Scanned__c,Delivery_Security_Scanned__c,
                Shipment__r.Delivery_Route_Assigned_To__c, Shipment__r.Delivery_Route_Assigned_To__r.Name
                FROM Secure_Packaging__c WHERE (Scanned_Time__c = TODAY OR Linehaul_Scanned_Time__c = TODAY OR Delivery_Scanned_Time__c = TODAY)
                and Scanned_User__c=:UserInfo.getUserId() order by LastmodifiedDate desc  ];
    }
    
    @AuraEnabled
    public static ResponseWrapper getRecord(String Name, String ButtonName) {
        ResponseWrapper res = new ResponseWrapper();
        String ErrorMessage = '';
        System.debug('33 Name :'+Name+' ButtonName :'+ButtonName);
        
        List<Secure_Packaging__c> spList = [
            SELECT id, Name, Shipment__r.Name, Shipment__c, Type_of_Packaging__c,
            Shipment__r.Pickup__c, Shipment__r.Pickup__r.Name,
            Security_Scanned__c, Scanned_User__c, Scanned_Time__c, Scanned_Hub__c, Scanned_Hub__r.Name,
            Linehaul_Scanned_User__c, Linehaul_Scanned_Time__c, Linehaul_Scanned_Hub__c,
            Delivery_Scanned_User__c, Delivery_Scanned_Time__c, Delivery_Scanned_Hub__c,
            Shipment__r.Pickup__r.Pickup_Assigned_To__c, Shipment__r.Pickup__r.Pickup_Assigned_To__r.Name,
            Shipment__r.Tracking_Status__c, Shipment__r.Origin_Hub__r.Name, Shipment__r.Shipping_Note_Number__c,
            Shipment__r.Destination_Hub__c, Shipment__r.Destination_Hub__r.Name,
            Pickup_Security_Scanned__c,Linehaul_Security_Scanned__c,Delivery_Security_Scanned__c,
            Shipment__r.Delivery_Route_Assigned_To__c, Shipment__r.Delivery_Route_Assigned_To__r.Name
            FROM Secure_Packaging__c
            WHERE Name = :Name
            LIMIT 1
        ];
        System.debug('50 spList :'+spList);
        if (!spList.isEmpty()) {
            Secure_Packaging__c sp = spList[0];
            boolean hasShipment = sp.Shipment__c != null;
            
            
            if (hasShipment) {
                if (ButtonName == 'Pickup Scan' && sp.Shipment__r.Tracking_Status__c != 'Picked Up') {
                    ErrorMessage = 'Please scan a valid Secure bag with Tracking status = Picked Up';
                } else if (ButtonName == 'Linehaul Scan' && sp.Shipment__r.Tracking_Status__c != 'Linehaul Finalised') {
                    ErrorMessage = 'Please scan a valid Secure bag with Tracking status = Linehaul Finalized';
                } else if (ButtonName == 'Delivery Scan' && sp.Shipment__r.Tracking_Status__c != 'Out for Delivery') {
                    ErrorMessage = 'Please scan a valid Secure bag with Tracking status = Out for Delivery';
                }
            }
            
            if (String.isNotBlank(ErrorMessage)) {
                res.message = 'Error: ' + ErrorMessage;
                res.spRecord = null;
            } else {
                
                User currentUser = [SELECT Id, Name, City, User_Hub__c,Hub__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                Hub__c hub;
                if (currentUser != null && currentUser.City != null) {
                    List<Hub__c> hubs = [SELECT Id, Name, City__c, Hub_City__c FROM Hub__c WHERE Name = :currentUser.Hub__c LIMIT 1];
                    if (!hubs.isEmpty()) {  hub = hubs[0]; }
                }
                boolean recordUpdated = false;
                if (hub != null)
                {  sp.Scanned_Hub__c = hub.Id; }
                sp.Scanned_Time__c = Datetime.now();
                sp.Scanned_User__c = currentUser.Id;
                sp.Pickup_Security_Scanned__c = true;
                recordUpdated = true;
                if (recordUpdated) {
                    try {
                        update sp;                       
                        Secure_Packaging__c sp1 = [
                            SELECT id, Name, Shipment__r.Name, Shipment__c, Shipment__r.Pickup__c, Shipment__r.Pickup__r.Name,
                            Security_Scanned__c, Scanned_User__c, Scanned_Time__c, Scanned_Hub__c, Scanned_Hub__r.Name,
                            Shipment__r.Pickup__r.Pickup_Assigned_To__c, Shipment__r.Pickup__r.Pickup_Assigned_To__r.Name,
                            Shipment__r.Tracking_Status__c, Shipment__r.Origin_Hub__r.Name, Shipment__r.Shipping_Note_Number__c,
                            Shipment__r.Destination_Hub__c, Shipment__r.Destination_Hub__r.Name,
                            Pickup_Security_Scanned__c,Linehaul_Security_Scanned__c,Delivery_Security_Scanned__c,
                            Shipment__r.Delivery_Route_Assigned_To__c, Shipment__r.Delivery_Route_Assigned_To__r.Name
                            FROM Secure_Packaging__c
                            WHERE Id = :sp.Id
                            LIMIT 1
                        ];
                        res.message = 'Success';
                        res.spRecord = sp1;
                    } catch (Exception e) { res.message = 'Error on update: ' + e.getMessage(); res.spRecord = null; }
                } else {  res.message = 'Error: This item has already been scanned for the "' + ButtonName + '" stage or the action is invalid.';
                        res.spRecord = null;
                       }
            }
        } else {  res.message = 'Error: No record found with that name.';  res.spRecord = null; }
        return res;
    }
}