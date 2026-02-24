public class createAwbNumberRecord {
 


    @InvocableMethod
    public static void createAWBRecords(List<Id> LinehaulIds) {
        if (LinehaulIds == null || LinehaulIds.isEmpty()) return;

      System.enqueueJob(new CreateAwbQueueable(LinehaulIds, 0));
       // createAWBRecords1(LinehaulIds, 0);
    }

    
    public static void createAWBRecords1(List<Id> LinehaulIds, Integer retryCount) {
        if (LinehaulIds == null || LinehaulIds.isEmpty()) return;
        if (retryCount == null) retryCount = 0;

        Set<Id> shipmentIDs = new Set<Id>();
        Map<String, List<secure_bag__c>> shipmentBagMap = new Map<String, List<secure_bag__c>>();


        Linehaul_Tracking__c Line = [SELECT Id, Name, AWB_Number__c, Linehaul_Type__c, Finalized_Linehaul_Number__c 
                                     FROM Linehaul_Tracking__c 
                                     WHERE Id IN :LinehaulIds
                                     LIMIT 1];

        List<secure_bag__c> bagList = [SELECT Id, Name, Shipment__c, Linehaul_Tracking__c 
                                       FROM secure_bag__c 
                                       WHERE Linehaul_Tracking__c IN :LinehaulIds];
        system.debug('securebagList' + bagList);

        if (!bagList.isEmpty()) {
            for (secure_bag__c bg : bagList) {
                if (bg.Shipment__c != null) {
                    shipmentIDs.add(bg.Shipment__c);
                    if (!shipmentBagMap.containsKey(String.valueOf(bg.Shipment__c))) {
                        shipmentBagMap.put(String.valueOf(bg.Shipment__c), new List<secure_bag__c>());
                    }
                    shipmentBagMap.get(String.valueOf(bg.Shipment__c)).add(bg);
                }
            }
        }

        if (shipmentIDs.isEmpty()) return;

      
        List<AWB_Number__c> awbList = new List<AWB_Number__c>();
        List<AWB_Number__c> awbNumberList = [SELECT Id, Name, AWB_Code__c, Shipment__c, Linehaul_Tracking__c, Finalized_Linehaul_Number__c 
                                            FROM AWB_Number__c 
                                            WHERE Finalized_Linehaul_Number__c = :Line.Finalized_Linehaul_Number__c
                                              AND Shipment__c IN :shipmentIDs];

        if (awbNumberList.isEmpty()) {
            for (Id stId : shipmentIDs) {
                AWB_Number__c aw = new AWB_Number__c();
                if (Line.Linehaul_Type__c == 'Air') {
                    aw.AWB_Code__c = Line.AWB_Number__c;
                }
                aw.Linehaul_Tracking__c = Line.Id;
                aw.Shipment__c = stId;
                awbList.add(aw);
            }
            try {
                insert awbList;
            } catch (Exception e) {
                Linehaul_Error_Log__c er = new Linehaul_Error_Log__c();
                er.Error_Message__c = e.getMessage();
                er.Error_Stage__c = 'failed to create AWB number record';
                insert er;
            }
        }

     
        Map<String, Integer> shipmentTotalBagCountMap = new Map<String, Integer>();
        Map<String, Integer> shipmentBagsWithLTCountMap = new Map<String, Integer>();
        Map<String, Integer> shipmentBagsWithoutLTCountMap = new Map<String, Integer>();

        List<secure_bag__c> allBagsList = [SELECT Id, Name, Shipment__c, Linehaul_Tracking__c 
                                           FROM secure_bag__c 
                                           WHERE Shipment__c IN :shipmentIDs];

        for (secure_bag__c sbg : allBagsList) {
            String shipmentId = String.valueOf(sbg.Shipment__c);
            if (!shipmentTotalBagCountMap.containsKey(shipmentId)) shipmentTotalBagCountMap.put(shipmentId, 0);
            shipmentTotalBagCountMap.put(shipmentId, shipmentTotalBagCountMap.get(shipmentId) + 1);

            if (!shipmentBagsWithLTCountMap.containsKey(shipmentId)) shipmentBagsWithLTCountMap.put(shipmentId, 0);
            if (!shipmentBagsWithoutLTCountMap.containsKey(shipmentId)) shipmentBagsWithoutLTCountMap.put(shipmentId, 0);

            if (sbg.Linehaul_Tracking__c == null) {
                shipmentBagsWithoutLTCountMap.put(shipmentId, shipmentBagsWithoutLTCountMap.get(shipmentId) + 1);
            } else {
                shipmentBagsWithLTCountMap.put(shipmentId, shipmentBagsWithLTCountMap.get(shipmentId) + 1);
            }
        }

   
        List<shipment__c> shipList = new List<shipment__c>();
        for (String shipmentId : shipmentTotalBagCountMap.keySet()) {
            Integer totalBagsCountForShipment = shipmentTotalBagCountMap.get(shipmentId);
            system.debug('ShipmentCount ' + shipmentId + ' - Total Bags Count: ' + totalBagsCountForShipment);

            Integer bagsWithLTCount2 = shipmentBagsWithLTCountMap.containsKey(shipmentId) ? shipmentBagsWithLTCountMap.get(shipmentId) : 0;
            Integer bagsWithoutLTCount2 = shipmentBagsWithoutLTCountMap.containsKey(shipmentId) ? shipmentBagsWithoutLTCountMap.get(shipmentId) : 0;

            system.debug('Shipment3 ' + shipmentId + ' - Bags with Linehaul_Tracking__c Count: ' + bagsWithLTCount2);
            system.debug('Shipment3 ' + shipmentId + ' - Bags without Linehaul_Tracking__c Count: ' + bagsWithoutLTCount2);

            if (totalBagsCountForShipment == bagsWithLTCount2 && bagsWithoutLTCount2 == 0) {
               
                shipment__c sh = new shipment__c();
               if (sh.Linehaul_Completed__c == null || sh.Linehaul_Completed__c == false) {
                   
                sh.Id = (Id)shipmentId;
                    sh.Linehaul_Completed__c = true;
                    sh.Tracking_Status__c = 'Linehaul Finalised';
                     shipList.add(sh);
                }
              
                
            }
        }

        if (!shipList.isEmpty()) {
           
            Database.SaveResult[] sResults = Database.update(shipList, false);
            List<Id> lockedIds = new List<Id>();
            for (Integer i = 0; i < sResults.size(); i++) {
                if (!sResults[i].isSuccess()) {
                    for (Database.Error err : sResults[i].getErrors()) {
                        if (err.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW
                            || String.valueOf(err.getMessage()).contains('UNABLE_TO_LOCK_ROW')) {
                            lockedIds.add(shipList[i].Id);
                            break;
                        }
                    }
                }
            }

         
            if (!lockedIds.isEmpty()) {
          
                System.enqueueJob(new LockedShipmentRetryQueueable(lockedIds, 0));
            }
        }
    } 
 }