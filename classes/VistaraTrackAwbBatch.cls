global class VistaraTrackAwbBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful  {

   public List<Linehaul_Tracking__c> insertLineTrack	= new List<Linehaul_Tracking__c>();
    public List<Linehaul_Tracking__c> updatetLineTrack	= new List<Linehaul_Tracking__c>(); 
    
   global Database.QueryLocator Start(Database.BatchableContext bc){
       
         String vistaraJet = 'Vistara';
         String getAWB =  'SELECT id,Name,AWB_Number__c,AWB_Consumed__c FROM Linehaul__c WHERE AWB_Number__c != null AND AWB_Consumed__c = true AND AirLine_Name__c =: vistaraJet AND  CreatedDate = LAST_N_DAYS:2';
         return Database.getQueryLocator(getAWB);
    }
    
    global void execute(Database.BatchableContext bc,List<Linehaul__c> awbList){
         
        system.debug('awbList  ==='+ awbList);
        system.debug('awbList  ==='+ awbList.size());
        
        Map<String,String> awbStatusMap = new Map<String,String>();
         AWB_Tracking_Status__mdt[] awbStatusList = [SELECT MasterLabel,Vistara_AWB_Status__c 
                                                 FROM AWB_Tracking_Status__mdt 
                                                 WHERE 
                                                 DeveloperName = 'AWB_Booked' OR DeveloperName = 'AWB_Finalized' OR DeveloperName = 'Airline_Deposited' OR 
                                                 DeveloperName = 'On_Route_Airport' OR DeveloperName = 'Pre_Flight_at_Airport' OR DeveloperName = 'Flight_Departed'OR
                                                 DeveloperName = 'Flight_Arrived' OR DeveloperName = 'Pre_Retrieval_at_Airport' OR DeveloperName = 'Retrieved'  OR DeveloperName = 'Offload'];
        
        for(AWB_Tracking_Status__mdt awbStatus:awbStatusList ){
            if(awbStatus.Vistara_AWB_Status__c != null && awbStatus.Vistara_AWB_Status__c !=''){
                awbStatusMap.put(awbStatus.Vistara_AWB_Status__c,awbStatus.MasterLabel);
            }
        }
        set<id> LinehaulId = new set<id>();
        
        for(Linehaul__c l : awblist){
            LinehaulId.add(l.id);
            
        }
        List<linehaul_Tracking__c>  LinehaulTrackingList = [SELECT Id, Name, AWB_Number__c,description__c,Airline__c,Last_Activity__c,Status__c, Linehaul_Name__r.Name, Linehaul_Name__r.id FROM Linehaul_Tracking__c WHERE  Last_Activity__c != null AND Status__c != null AND description__c !=null  AND Airline__c ='Vistara' AND  CreatedDate = LAST_N_DAYS:3 ];  
        set<id> LineId = new Set<id>();
       
            for(linehaul_Tracking__c  ltTrack : LinehaulTrackingList){
                  LineId.add(ltTrack.Linehaul_Name__r.id);
                  
            }
        
        Set<id> uniqueValuesSet = new Set<id>();
      
        for(id setID1 : LinehaulId){
            if(!LineId.Contains(setID1)){
                uniqueValuesSet.add(setID1);
            }
            
        }
        
        for(id setId2 : LineId){
            if(!LinehaulId.contains(setId2)){
                uniqueValuesSet.add(setId2);
            }
        }
        
         List<Linehaul__c> linehaulList = [SELECT id,Name,AWB_Number__c,AWB_Consumed__c FROM Linehaul__c WHERE AWB_Number__c != null AND AWB_Consumed__c = true AND AirLine_Name__c =:'Vistara' AND  Id IN :uniqueValuesSet];
        
        string TokenNumber = vistaraTrackAWBHelper.generateToken();
        if(TokenNumber != null && TokenNumber !=''){
            insertLineTrack.addALL(vistaraTrackAWBHelper.trackAWB(linehaulList, TokenNumber, awbStatusMap));
            updatetLineTrack.addALL(vistaraTrackAWBHelper.updateTrackAWB(LinehaulTrackingList, TokenNumber, awbStatusMap));
        }
        
         if(!insertLineTrack.isEmpty()){
            Database.insert(insertLineTrack, false);
        }
        
        if(!LinehaulTrackingList.isEmpty()){
            database.update(updatetLineTrack,false);
        }
        
        Map<String,String> awbNumbers = new Map<String,String>();
        Map<Id,String> shipmentRecordMap = new Map<Id,String>();
        List<Shipment__c> updateShipmentList = new List<Shipment__c>();
        List<Shipment_Tracking__c> createTrackingList = new List<Shipment_Tracking__c>();
        Map<Id,String> previousTracking = new Map<Id,String>();
        
          for(Linehaul_Tracking__c linehaulTrackingRecord: [SELECT Id,Name,CreatedDate,Status__c,Linehaul_Name__c,AWB_Number__c FROM Linehaul_Tracking__c WHERE CreatedDate = today]){
       // store line Linehaul_Tracking__c record's AWB_Number__c as ID and Status__c is Values in awbNumbers map
            awbNumbers.put(linehaulTrackingRecord.AWB_Number__c,linehaulTrackingRecord.Status__c);
            
        }
         if(!awbNumbers.isEmpty()){
      // get AWB_Number__c record where AWB_Code__c is in  awbNumbers map keyset     
            for(AWB_Number__c awbNumberRecord : [SELECT Id,Name,AWB_Code__c,Linehaul_Tracking__c,Shipment__c,Shipment__r.Id FROM AWB_Number__c WHERE AWB_Code__c IN: awbNumbers.keySet()]){
      // get AWB code from awbNumbers map and store in status variable
                String status = awbNumbers.get(awbNumberRecord.AWB_Code__c);
     // add ABW number record shipment as id and status in shipmentRecordMap variable  
                shipmentRecordMap.put(awbNumberRecord.Shipment__r.Id,status);
            }
            
        }
         for(Shipment_Tracking__c shipTracking : [SELECT Id,Name,Location__c,Shipment__c FROM Shipment_Tracking__c WHERE Shipment__c IN: shipmentRecordMap.keySet()]){
            previousTracking.put(shipTracking.Id,shipTracking.Location__c);
        }
        
        if(!shipmentRecordMap.isEmpty()){
    //get shipment record  whose id in shipmentRecordMap map
            for(Shipment__c shipmentRecord : [SELECT Id,Name,Tracking_Status__c,Origin_Hub__c FROM Shipment__c WHERE Id IN: shipmentRecordMap.keySet()]){
    // check previousTracking map shipment id is not equal to the shipmentRecordMap shipmentRecord shipment id if not same then create shipment tracking record     
                if(previousTracking.get(shipmentRecord.Id) != shipmentRecordMap.get(shipmentRecord.Id)){
                Shipment_Tracking__c  shipmentTracking = new Shipment_Tracking__c ();
                shipmentTracking.Shipment__c = shipmentRecord.Id;
                shipmentTracking.Hub__c = shipmentRecord.Origin_Hub__c;
                //shipmentTracking.Airport__c = shipmentRecord
                shipmentTracking.Location__c = shipmentRecordMap.get(shipmentRecord.Id);
                createTrackingList.add(shipmentTracking);
                }
            }
        }
         if(createTrackingList.size() > 0){
            Database.Insert(createTrackingList,false);
        }
    }
    
   global void finish(Database.BatchableContext bc){
        
    }
}