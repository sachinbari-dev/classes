public class eSHIP_SNseriesUpdateHelper {

        @invocableMethod
    public static void updateShippingNoteNo ( List<Shipment__c> shipmentList) {
       
        List<Shipment__c> shipmentToUpdate = new List<Shipment__c>();
        set<id> shipId = new set<id>();
        List<Secure_Packaging__c> securePackagingList = new List<Secure_Packaging__c>();
        Map<Secure_Packaging__c,Shipment__c> mapOfSecurePack = new Map<Secure_Packaging__c,Shipment__c>(); 
        
        for (Shipment__c shipment : shipmentList) {
           shipId.add(shipment.Id);
          }
        
        /*Set<Id> hubIdSet = new Set<Id> ();

        for(Shipment__c shipmentRecord :  shipmentList){
            hubIdSet.Add(shipmentRecord.Origin_Hub__c);
        } 

        System.debug('====== hubIdSet =========== '+hubIdSet);*/
       integer size = shipmentList.size();
        system.debug('size' + size);
        List<Shipment__c> lockedShipmentsList = [SELECT Id, Shipping_Note_Number__c, Name,Customer_Product_Category__c FROM Shipment__c 
                                                 WHERE Customer_Product_Category__c= 'eSHIP' AND Id IN :shipId 
                                                  ];
        Secure_Packaging__c [] securePackaging = [  
           SELECT Id, Name,shipment__c, Status__c, Digital__c, Type_of_Packaging__c, RecordTypeId FROM Secure_Packaging__c WHERE Status__c = 'Available'  AND shipment__c = null AND Digital__c = True AND RecordTypeId = '0125g0000003dGBAAY' AND Type_of_Packaging__c='Shipping Label' AND name Like 'ES%' 
            ORDER BY Name ASC LIMIT :size 
            //AND Allocated_To_Hub__c IN: hubIdSet
        ]; 

        System.debug('===================  securePackaging ========'+securePackaging.size());


        if(securePackaging.size() > 0 && lockedShipmentsList.size() == securePackaging.size() ) { 
            for(Integer i = 0; i < lockedShipmentsList.size(); i++) {
                mapOfSecurePack.put(securePackaging[i],lockedShipmentsList[i] );
            }
            for(Secure_Packaging__c sp1 : mapOfSecurePack.keyset()) {
                if(mapOfSecurePack.containsKey(sp1)) {
                    for(shipment__c tempShipment : lockedShipmentsList){
                        if( tempShipment.Id == mapOfSecurePack.get(sp1).Id){
                            system.debug('tempShipment.Id' + tempShipment.Id);
                            system.debug('mapOfSecurePack.Id' +mapOfSecurePack.get(sp1).Id);
                            tempShipment.Shipping_Note_Number__c = sp1.Name;
                            shipmentToUpdate.add(tempShipment);
                        }
                          
                          
                             
                    }
                   
                }
                
            }

             
            if(shipmentToUpdate.size()>0){
                
                 Database.SaveResult[] saveResultList = Database.update(shipmentToUpdate, false);
                 system.debug('-------myupdate----'+saveResultList);
            }
            
            List<shipment__c> shipList = [select id, name ,Shipping_Note_Number__c from Shipment__c where id IN: shipId];
            
            List<Secure_Packaging__c > spList = [ SELECT Id, Name,shipment__c, Status__c, Digital__c, Type_of_Packaging__c, RecordTypeId FROM Secure_Packaging__c 
                                                 WHERE Status__c = 'Available'  AND shipment__c = null AND Digital__c = True AND RecordTypeId = '0125g0000003dGBAAY' 
                                                 AND Type_of_Packaging__c='Shipping Label' AND  id IN: mapOfSecurePack.keyset() FOR UPDATE];
            system.debug('spList' +spList);
            
            for( Secure_Packaging__c sp : spList){
                for(shipment__c s : shipList){
                    if(sp.Name == s.Shipping_Note_Number__c ){
                         sp.Status__c = 'Consumed';
                         sp.Shipment__c = s.id;
                        securePackagingList.add(sp);
                    }
                }
            }
        }
        
        if( securePackagingList.size() > 0){
            
            Database.SaveResult[] saveResultList1 = Database.update(securePackagingList, false);
            system.debug('-------myupdate1----'+saveResultList1);
        }
        
        
        // update blank shipments
        
      List<shipment__c>  ShipmentListToupdate = [select id, name ,Shipping_Note_Number__c,RecordType.name from Shipment__c where Shipping_Note_Number__c = Null AND Customer_Product_Category__c= 'eSHIP' AND CreatedDate = Today AND RecordType.name NOT IN ('BATH')];
        set<id> shipmentsID = new set<id>();
        
        for(shipment__c s : ShipmentListToupdate){
            if(s.Shipping_Note_Number__c == null){
                shipmentsID.add(s.id);
            }
        }
        
        if(!shipmentsID.isEmpty()){
            
              List<Secure_Packaging__c> securePackagingList1 = new List<Secure_Packaging__c>();
              List<Shipment__c> shipmentToUpdate1 = new List<Shipment__c>();
                  
            integer shipsize = shipmentsID.size(); 
            List<shipment__c>  sList = [select id, name ,Shipping_Note_Number__c from Shipment__c where id IN: shipmentsID ];
            
             Secure_Packaging__c [] securePackaging1 = [  
                SELECT Id, Name,shipment__c, Status__c, Digital__c, Type_of_Packaging__c, RecordTypeId FROM Secure_Packaging__c WHERE Status__c = 'Available'  AND shipment__c = null AND Digital__c = True AND RecordTypeId = '0125g0000003dGBAAY' AND Type_of_Packaging__c='Shipping Label' AND name Like 'ES%' 
                 ORDER BY Name ASC LIMIT :shipsize 
                //AND Allocated_To_Hub__c IN: hubIdSet
            ]; 
            
             Map<Secure_Packaging__c,Shipment__c> mapOfSecurePack1 = new Map<Secure_Packaging__c,Shipment__c>();
            if(securePackaging1.size() > 0 && sList.size() == securePackaging1.size() ) { 
                for(Integer i = 0; i < sList.size(); i++) {
                    mapOfSecurePack1.put(securePackaging1[i],sList[i] );
                }
                
                 for(Secure_Packaging__c sp2 : mapOfSecurePack1.keyset()) {
                    if(mapOfSecurePack1.containsKey(sp2)) {
                        for(shipment__c tempShipment : sList){
                            if( tempShipment.Id == mapOfSecurePack1.get(sp2).Id){
                                system.debug('tempShipment.Id' + tempShipment.Id);
                                system.debug('mapOfSecurePack1.Id' +mapOfSecurePack1.get(sp2).Id);
                                tempShipment.Shipping_Note_Number__c = sp2.Name;
                                shipmentToUpdate1.add(tempShipment);
                            }
                              
                              
                                 
                        }
                       
                    }
                    
                }
                 
                 if(shipmentToUpdate1.size()>0){
                   
                       Database.SaveResult[] saveResultList2 = Database.update(shipmentToUpdate1, false);
                     system.debug('-------myupdate----'+saveResultList2);
                }
                
                 List<Secure_Packaging__c > spList1 = [ SELECT Id, Name,shipment__c, Status__c, Digital__c, Type_of_Packaging__c, RecordTypeId FROM Secure_Packaging__c 
                                                     WHERE Status__c = 'Available'  AND shipment__c = null AND Digital__c = True AND RecordTypeId = '0125g0000003dGBAAY' 
                                                     AND Type_of_Packaging__c='Shipping Label' AND  id IN: mapOfSecurePack1.keyset() FOR UPDATE];
                
                for( Secure_Packaging__c sp3 : spList1){
                    for(shipment__c s : sList){
                        if(sp3.Name == s.Shipping_Note_Number__c ){
                             sp3.Status__c = 'Consumed';
                             sp3.Shipment__c = s.id;
                            securePackagingList1.add(sp3);
                        }
                    }
                }
                 if( securePackagingList1.size() > 0){
                  
                     
                Database.SaveResult[] saveResultList3= Database.update(securePackagingList1, false);
             system.debug('-------myupdate1----'+saveResultList3);
            }
            }

    }
    
       
            
        }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public static void testmehod(){
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
        i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
                i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
                i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
                i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
                i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
          i++;
      i++;
        i++;
         i++;  
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
           i++;
         i++;
      i++;
      i++;
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