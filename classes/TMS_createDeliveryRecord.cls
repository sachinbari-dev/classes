public class TMS_createDeliveryRecord {

    @invocableMethod
    public static void createDeliveryRecord(List<shipment__c>  shipList){
        
        set<id> shipId = new set<id>();
        
        for(shipment__c s: shipList){
            shipId.add(s.id);
        }
        
         List<secure_bag__c> allBagsList = [SELECT Id, Name,Current_Scan_Loction__c, Shipment__c, Linehaul_Tracking__c FROM secure_bag__c WHERE Shipment__r.Id IN :shipId];
           List<Delivery__c>  DeliveryList = new List<Delivery__c>(); 
        
          if (allBagsList != null && !allBagsList.isEmpty()) {
              
                  String baseLocation = allBagsList[0].Current_Scan_Loction__c;
                  Boolean allMatch = true;
                            
            
                  for (Secure_Bag__c bag : allBagsList) {
                        if (bag.Current_Scan_Loction__c != baseLocation) {
                              allMatch = false;
                                 break;
                       }
                   } 
              
                      if (allMatch){
                         
                         for(Shipment__c s: shipList){
                              
                             Delivery__c d = new Delivery__c();
                             d.Address__c = s.Destination_Address_Name__c;
                             d.Consignee_Contact__c = s.Destination_Address_PhoneNo__c;
                             d.Consignee_Name__c = s.Destination_Address_Email__c;
                             d.OwnerId = s.Delivery_Route_Assigned_To__c;
                             d.Shipment__c = s.Id;
                             d.Shipper_Address__c = s.Origin_Address_Name__c;
                             d.Shipper_Contact__c = s.Origin_Address_PhoneNo__c;
                             d.Shipper_Email__c = s.Origin_Address_Email__c;
                             d.Status__c ='Created';
                             
                             DeliveryList.add(d);
                       }
                         
                 }
          }
        
        if(!DeliveryList.isEmpty()){
            insert DeliveryList;
        }
        
    }
}