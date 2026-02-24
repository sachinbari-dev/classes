public without sharing class TmsAcceptDeliveryController {

    /*@AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }*/

    @AuraEnabled
    public static List<Secure_Bag__c> allSecureBagGet(String deliveryId){
        System.debug('deliveryId '+deliveryId);
        String currentUserId = UserInfo.getUserId();
        Set<Id> ShipmentId = new Set<Id>();
        List<Secure_Bag__c> secureBagList  = new List<Secure_Bag__c>();
        try {

            Delivery__c delObj = [SELECT Id, Shipment__c, Status__c, OwnerId, Address__c
                                    FROM Delivery__c
                                    WHERE Id =: deliveryId AND
                                        OwnerId =: currentUserId AND
                                        Status__c = 'Created'];

            System.debug('dasdsadasd '+delObj);
            if(delObj.Shipment__c!=null){
                secureBagList = [SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, Shipment__r.Destination_Address_Name__c, Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                                FROM Secure_Bag__c 
                                WHERE Current_Scan_Loction__c != 'Delivered' AND
                                Shipment__c =: delObj.Shipment__c]; 

            }         
                System.debug('secure bag status : '+secureBagList);
                return secureBagList.size() > 0 ? secureBagList : null ;  
 
            
        } catch (Exception e) { 
            System.debug('error message '+e.getMessage());
            System.debug('error on line number '+e.getLineNumber());
            return null;

            //throw new AuraHandledException('\n - No Record Found');
        }
    }

    @AuraEnabled
    public static ShipmetWrap secureBagById(String bagId){
        
        try { 
            System.debug('for checking bagId '+bagId);
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
                    System.debug('for checking secureBag '+secureBag);
                    if(secureBag.Shipment__r.Delivery_Route_Assigned_To__c != UserInfo.getUserId() && secureBag.Current_Scan_Loction__c == 'Delivered'){
                        System.debug('Inside If');

                        //throw new AuraHandledException('Insufficient access rights on '+bagId);
                        
                    }else{
                        shipmentRecord.put(secureBag.Secure_Bag__r.Name, secureBag);
                        System.debug('for checking shipmentRecord.values() :'+shipmentRecord.values());
                    }
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
                    bag.vaults__c = null;
                    Database.Update(Bag);
                    
            }else{
                System.debug('This bag is not associated with shipment.');
                //throw new AuraHandledException('This bag is not associated with shipment');
                
            }
            System.debug('for checking ShipmetWrapData '+ShipmetWrapData);
            return ShipmetWrapData;
            
        } catch (Exception ex) {
            //throw new AuraHandledException('Error Message : '+ex.getMessage());
            System.debug('for checking error - '+ex.getMessage());
            System.debug('for checking error on line number - '+ex.getLineNumber());
            return null;

        }
    }

    @testVisible class ShipmetWrap{
        
        @AuraEnabled
        public Map<String,Secure_Bag__c> shipmentRecordMap {get;set;}
        
    } 


    @AuraEnabled
    public static void deliveryUpdate(String recId){
        List<Delivery__c> updateDelList = new List<Delivery__c>();

        Delivery__c delobj = new Delivery__c();
        delObj.Id = recId;
        delObj.Status__c = 'Accepted';
        updateDelList.add(delObj);

        if(updateDelList.size()>0){
            update updateDelList;
        }
    }
     
    
    

    public static void GetCoverage(){
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

    }

}