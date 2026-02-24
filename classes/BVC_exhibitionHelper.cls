public class BVC_exhibitionHelper {

    
    public static void udpateSecurebagsIsExhibition(List<secure_bag__c> baglist, Map<Id, Secure_Bag__c> oldMap){
        
        Set<Id> shipmentIds = new Set<Id>();
        
        for(secure_bag__c sb : baglist){
           /* if(sb.Shipment__c != null && (oldMap == null || sb.Shipment__c != oldMap.get(sb.Id).Shipment__c)){
               shipmentIds.add(sb.Shipment__c);
            }   */
            if(sb.Shipment__c != null && sb.is_Exhibition__c == false){
               shipmentIds.add(sb.Shipment__c);
            }
           
        }
        
        if(!shipmentIds.isEmpty()){
            Map<Id, Shipment__c> exhibitionShipmentMap = new Map<Id, Shipment__c>();
            
                for (Shipment__c sh : [SELECT Id,Exhibition__c, IsExhibition__c FROM Shipment__c WHERE Id IN :shipmentIds AND Exhibition__c != NULL
                                       AND IsExhibition__c = true]) {
                                           
                   exhibitionShipmentMap.put(sh.Id, sh);
                                           
               }
            
             List<Secure_Bag__c> bagsToUpdate = new List<Secure_Bag__c>();
            
            for (Secure_Bag__c sb : baglist) {
                if (sb.Shipment__c != null &&
                    exhibitionShipmentMap.containsKey(sb.Shipment__c)) {
    
                    if (sb.Is_Exhibition__c != true) {
                        bagsToUpdate.add(new Secure_Bag__c( Id = sb.Id,Is_Exhibition__c = true));
                    }
                }
           }
            if(!bagsToUpdate.isEmpty()){
                update bagsToUpdate;
            }
        }
        
    }
    @invocableMethod
    public static void updateSecureBagIsExhibitionToFalse( List<Shipment__c> newList ) {
        Set<Id> shipmentIdsToClear = new Set<Id>();
         Set<Id> shipmentIdsToupdate = new Set<Id>();
        
     
        for (Shipment__c sh : newList) {
            /*
            Shipment__c oldSh = oldMap.get(sh.Id);
            
            Boolean wasExhibition = oldSh.Exhibition__c != null && oldSh.IsExhibition__c == true;

            Boolean isNowNonExhibition = sh.Exhibition__c == null ||sh.IsExhibition__c != true;

            Boolean isExhibition = oldSh.Exhibition__c == null || oldSh.IsExhibition__c != true;
            
            boolean newexhibi = sh.Exhibition__c != null && sh.IsExhibition__c == true;
             */
            if (sh.Exhibition__c == null || sh.IsExhibition__c != true) {
                shipmentIdsToClear.add(sh.Id);
            }
            if(sh.Exhibition__c != null && sh.IsExhibition__c == true){
                shipmentIdsToupdate.add(sh.id);
            }
        }

        if (!shipmentIdsToClear.isEmpty()){
            list<secure_bag__c> ssbList = new List<secure_Bag__c>();
            List<Secure_Bag__c> bagsToUpdate = [SELECT Id, Is_Exhibition__c FROM Secure_Bag__c WHERE Shipment__c IN :shipmentIdsToClear  AND Is_Exhibition__c = TRUE];

            if(!bagsToUpdate.isEmpty()){
                  for (Secure_Bag__c sb : bagsToUpdate) {
                sb.Is_Exhibition__c = false;
                ssbList.add(sb);
            }

            if (!ssbList.isEmpty()) {
                   update ssbList;
                }
            }
          
            }
        
        if(!shipmentIdsToupdate.isEmpty()){
            list<secure_bag__c> ssbList1 = new List<secure_Bag__c>();
             List<Secure_Bag__c> bagsToUpdate = [SELECT Id, Is_Exhibition__c FROM Secure_Bag__c WHERE Shipment__c IN :shipmentIdsToupdate  AND Is_Exhibition__c = false];

            if(!bagsToUpdate.isEmpty()){
                
                 for (Secure_Bag__c sb : bagsToUpdate) {
                sb.Is_Exhibition__c = true;
                ssbList1.add(sb);
            }

            if (!ssbList1.isEmpty()) {
                   update ssbList1;
                }
            }
           
        }

    }
   /* 
    public static void removeSealIdAndAwbNumberFromBag( List<Shipment__c> newList){
        
     
        set<id> spList = new set<id>();
        
        for(shipment__c s : newList){
          
            if(s.Tracking_Status__c == 'Destination Hub' && s.Exhibition__c != null  && s.IsExhibition__c == true ){
                spList.add(s.id);
            }
        }
        
        List<secure_bag__c> sbList = [select id, name ,Finalised_Linehaul_Number__c,Seal_Id__c,shipment__c,shipment__r.id from secure_bag__c where shipment__r.id IN:spList ];
        List<secure_bag__c> securebagList = new List<secure_bag__c>();
        
        for(secure_bag__c  sb: sbList){
            if(sb.Finalised_Linehaul_Number__c != null){
                sb.Finalised_Linehaul_Number__c = null;
             
            }
            if(sb.Seal_Id__c != null){
                sb.Seal_Id__c = null;
            }
            securebagList.add(sb);
        }
        
        if(!securebagList.isEmpty()){
            update securebagList;
        }
    } */
}