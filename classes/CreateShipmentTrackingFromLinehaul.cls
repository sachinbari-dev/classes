public class CreateShipmentTrackingFromLinehaul {
     
    @InvocableMethod
    public static void createShipmentTracking(List<id> ShipmentIDs){
        
        List<Shipment__c> shipList = [SELECT id,Name,Linehaul_Completed__c,Tracking_status__c from shipment__c where id IN:shipmentIds];
        

    //    List<awb_number__c> awbNumList = [SELECT id,Name,shipment__c,Linehaul_Tracking__c,Linehaul_Tracking__r.name,shipment__r.id from awb_number__c where  Linehaul_Tracking__c!= Null AND shipment__r.id=:shipmentIds ];
        List<secure_bag__c> sbList = [SELECT id, name,Linehaul_Tracking__c,shipment__r.id,shipment__c,Linehaul_Tracking__r.name from secure_bag__c where Linehaul_Tracking__c != Null AND shipment__r.id=:shipmentIds LIMIT 1];
       
        List<Shipment_Tracking__c>  shipTrackingList = new List<Shipment_Tracking__c>();
        
        for(Shipment__c s : shipList){
            if(s.Linehaul_Completed__c == true && s.Tracking_Status__c == 'Linehaul Finalised'){
                Shipment_Tracking__c  st = new Shipment_Tracking__c();
                  st.Location__c = 'In Transit';
                  st.Scan_Time__c = System.now();
                  st.Linehaul__c = sbList[0].Linehaul_Tracking__r.name;
                  st.Shipment__c = s.Id;
                  shipTrackingList.add(st);
            }
        }
        if(!shipTrackingList.isEmpty()){
            
            insert shipTrackingList;
        }
         
       
    }
}