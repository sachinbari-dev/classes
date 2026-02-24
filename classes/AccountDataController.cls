public with sharing class AccountDataController {
    public AccountDataController() {
        
    }
    @AuraEnabled (cacheable=true)
        public static List<Shipment__c> fetchShipments(){
            return [ SELECT Id, Name, Shipping_Note_Number__c, Shipment_Date__c, Destination_Address_Line1__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name, Delivery_Route_Assigned_To__c,
            Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,Number_of_Packages__c,Delivery_Route_Assigned_To__r.Name, 
                    Destination_Address_City__c FROM Shipment__c WHERE Shipment_Date__c = LAST_N_DAYS:30 AND
            		Shipping_Note_Number__c != null AND Tracking_Status__c='Destination Hub' order by Shipment_Date__c desc LIMIT 10000];       
    }
    @AuraEnabled (cacheable=true)
        public static List<Shipment__c> searchShipments(String searcchKey){
            return [SELECT Id, Name, Shipping_Note_Number__c, Shipment_Date__c, Destination_Address_Line1__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name, Delivery_Route_Assigned_To__c,
            Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,Number_of_Packages__c,Delivery_Route_Assigned_To__r.Name, 
                    Destination_Address_City__c FROM Shipment__c WHERE Shipment_Date__c = LAST_N_DAYS:30 AND
                    Shipping_Note_Number__c != null AND Shipping_Note_Number__c =: searcchKey AND Tracking_Status__c='Destination Hub' order by Shipment_Date__c desc];
        }
     @AuraEnabled
    public static ShipmentUpdateResponse updateShipments(List<Shipment__c> shipdata, String searcchKey) {
   
        ShipmentUpdateResponse response = new ShipmentUpdateResponse();
        List<Shipment__c> shipdatalist = new List<Shipment__c>();
        set<id> shipId = new Set<id>();
            
        for(Shipment__c  s :shipdata){
            shipId.add(s.id);
        }
        
     
        List<Secure_Bag__c> bags = [ SELECT Name, Current_Scan_Loction__c,Shipment__r.id  FROM Secure_Bag__c  WHERE Shipment__r.id IN:shipId];
            
        if (searcchKey != null) {
            for (Shipment__c s : shipdata) {
                
                Set<String> locationSet = new Set<String>();
                for (Secure_Bag__c bag : bags) {
                    if (bag.Current_Scan_Loction__c != null)
                        locationSet.add(bag.Current_Scan_Loction__c);
                }
    
                if (locationSet.size() > 1) {
                    List<String> bagNames = new List<String>();
                    for (Secure_Bag__c bag : bags) {
                        bagNames.add(bag.Name);
                    }
                    response.errorMessage = 'Mismatch Current Scan Location on Shipment: ' + s.Shipping_Note_Number__c ;
                    return response;
                }
    
                s.Delivery_Route_Assigned_To__c = searcchKey;
                shipdatalist.add(s);
            }
        }
    
        if (!shipdatalist.isEmpty()) {
            update shipdatalist;
        }
    
        response.updatedShipments = shipdatalist;
        return response;
    }   
        public class ShipmentUpdateResponse {
            
        @AuraEnabled public List<Shipment__c> updatedShipments { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    
        }
}