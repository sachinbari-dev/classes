public without sharing  class TMS_updateShippingNoteNumber {
    
    @invocableMethod
    public static void updateShippingNoteNo ( List<Shipment__c> shipmentList) {
       
        List<Shipment__c> shipmentToUpdate = new List<Shipment__c>();
        List<Secure_Packaging__c> securePackagingList = new List<Secure_Packaging__c>();
        Map<Secure_Packaging__c,Shipment__c> mapOfSecurePack = new Map<Secure_Packaging__c,Shipment__c>(); 
        
        
        /*Set<Id> hubIdSet = new Set<Id> ();

        for(Shipment__c shipmentRecord :  shipmentList){
            hubIdSet.Add(shipmentRecord.Origin_Hub__c);
        } 

        System.debug('====== hubIdSet =========== '+hubIdSet);*/
   
        Secure_Packaging__c [] securePackaging = [  
            SELECT Id, Name,shipment__c, Status__c, Digital__c, Type_of_Packaging__c, RecordTypeId FROM Secure_Packaging__c WHERE Status__c = 'Available'  AND shipment__c = null AND Digital__c = True AND RecordTypeId = '0125g0000003dGBAAY' AND Type_of_Packaging__c='Shipping Label'
            ORDER BY Name ASC  LIMIT 1000
            //AND Allocated_To_Hub__c IN: hubIdSet
        ]; 

        System.debug('===================  securePackaging ========'+securePackaging.size());


        if(securePackaging.size() > 0 && shipmentList.size() <= securePackaging.size() ) { 
            for(Integer i = 0; i < shipmentList.size(); i++) {
                mapOfSecurePack.put(securePackaging[i],shipmentList[i] );
            }
            for(Secure_Packaging__c sp1 : mapOfSecurePack.keyset()) {
                if(mapOfSecurePack.containsKey(sp1)) {

                    Shipment__c tempShipment = new Shipment__c();
                    tempShipment.Id = mapOfSecurePack.get(sp1).Id;
                    tempShipment.Shipping_Note_Number__c = sp1.Name;
                    shipmentToUpdate.add(tempShipment);
                    
                    Secure_Packaging__c tempsbag = new Secure_Packaging__c();
                    tempsbag.Id = sp1.Id;
                    tempsbag.Status__c = 'Consumed';
                    tempsbag.Shipment__c = tempShipment.Id;
                    securePackagingList.add(tempsbag);
                }
                
            }
        }
        
        if(shipmentToUpdate.size()>0 && securePackagingList.size() > 0){
            Database.SaveResult[] saveResultList = Database.update(shipmentToUpdate, false);
            system.debug('-------myupdate----'+saveResultList);
            Database.SaveResult[] saveResultList1 = Database.update(securePackagingList, false);
            system.debug('-------myupdate1----'+saveResultList1);
        }
    }   
}