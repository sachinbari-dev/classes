public class HolidayChargeBatch implements Database.Batchable<SObject> {

    public String query;
    private Set<Id> pickupIds;

    public HolidayChargeBatch(Set<Id> pickupIds) {
        this.pickupIds = pickupIds;

        if (pickupIds != null && !pickupIds.isEmpty()) {
            query = 'SELECT Id, Physical_Pickup_Completed_Time__c ' +
                    'FROM Pickup__c ' +
                    'WHERE Physical_Pickup_Completed_Time__c != null AND Id IN :pickupIds';
        } else {
            query = 'SELECT Id FROM Pickup__c WHERE Id = null'; 
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Pickup__c> pickupList = (List<Pickup__c>) scope;
        Set<Id> pickupIds = new Set<Id>();
        Set<Date> allDates = new Set<Date>();

        for (Pickup__c pickup : pickupList) {
            if (pickup.Physical_Pickup_Completed_Time__c != null) {
                pickupIds.add(pickup.Id);
                allDates.add(pickup.Physical_Pickup_Completed_Time__c.date());
            }
        }

        Map<Id, List<Shipment__c>> pickupToShipments = new Map<Id, List<Shipment__c>>();
        Set<String> allStates = new Set<String>();
 system.debug('HOLIDAY-BATCHCLASS');
        List<Shipment__c> shipments = [
            SELECT Id, Origin_Address_State__c, Destination_Address_State__c, Pickup__c, holiday_sunday_charges1__c
            FROM Shipment__c
            WHERE Pickup__c IN :pickupIds
        ];

        for (Shipment__c ship : shipments) {
            if (ship.Origin_Address_State__c != null) allStates.add(ship.Origin_Address_State__c);
            if (ship.Destination_Address_State__c != null) allStates.add(ship.Destination_Address_State__c);

            if (!pickupToShipments.containsKey(ship.Pickup__c)) {
                pickupToShipments.put(ship.Pickup__c, new List<Shipment__c>());
            }
            pickupToShipments.get(ship.Pickup__c).add(ship);
        }

        Map<String, Set<Date>> holidayMap = new Map<String, Set<Date>>();
        for (Holiday_Data__c hd : [
            SELECT State__c, Date__c
            FROM Holiday_Data__c
            WHERE State__c IN :allStates AND Date__c IN :allDates
        ]) {
            if (!holidayMap.containsKey(hd.State__c)) {
                holidayMap.put(hd.State__c, new Set<Date>());
            }
            holidayMap.get(hd.State__c).add(hd.Date__c);
        }

        List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();

        for (Pickup__c pickup : pickupList) {
            Date pickupDate = pickup.Physical_Pickup_Completed_Time__c.date();
            Boolean isSunday = pickupDate == pickupDate.toStartOfWeek();

            List<Shipment__c> relatedShipments = pickupToShipments.get(pickup.Id);
            if (relatedShipments == null) continue;

            for (Shipment__c ship : relatedShipments) {
                Boolean isHoliday = (ship.Origin_Address_State__c != null &&
                                     holidayMap.get(ship.Origin_Address_State__c)?.contains(pickupDate) == true) ||
                    (ship.Destination_Address_State__c != null &&
                     holidayMap.get(ship.Destination_Address_State__c)?.contains(pickupDate) == true);
                
                Boolean shouldCheck = (isSunday || isHoliday);
                Boolean currentValue = ship.holiday_sunday_charges1__c == true;
                
                if (currentValue != shouldCheck) {
                    ship.holiday_sunday_charges1__c = shouldCheck;
                    shipmentsToUpdate.add(ship);
                }
            }
        }
        
        if (!shipmentsToUpdate.isEmpty()) {
            update shipmentsToUpdate;
            
        }
        
    }

    public void finish(Database.BatchableContext bc) {
         try {
            
            List<String> pickupIdList = new List<String>();
            for (Id pid : pickupIds) {
                pickupIdList.add((String) pid);
            }

            //  Chain the SLA batch
            SLACalculatorHandlerBatchHandler.callbatchHelper(pickupIdList);

            System.debug('Chained SLA batch successfully.');
        } catch (Exception e) {
            System.debug('Error calling SLA batch: ' + e.getMessage());
            insert new Apex_Error_Log__c(
                Class_Name__c = 'HolidayChargeBatch.finish()',
                Error__c = e.getMessage()
            );
        }
        
    }
}