global class TMS_updateShipmentNoteNumberBatch implements Database.Batchable<SObject> {

    private List<Shipment__c> shipmentsToProcess;

    // Constructor to accept a list of Shipments
    public TMS_updateShipmentNoteNumberBatch(List<Shipment__c> shipments) {
        this.shipmentsToProcess = shipments;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Convert the input shipment list into a queryable string for the batch process
        Set<Id> shipmentIds = new Set<Id>();
        for (Shipment__c shipment : shipmentsToProcess) {
            shipmentIds.add(shipment.Id);
        }

        // Fetch shipments to process based on the provided IDs
        return Database.getQueryLocator([ SELECT Id, Name, Shipping_Note_Number__c FROM Shipment__c WHERE Id IN :shipmentIds]);
    }

    global void execute(Database.BatchableContext bc, List<Shipment__c> scope) {
        // Fetch available Secure Packaging records
        List<Secure_Packaging__c> availableSecurePackages = [ SELECT Id, Name, Status__c, Shipment__c, Digital__c, Type_of_Packaging__c, RecordTypeId
                                                            FROM Secure_Packaging__c
                                                            WHERE Status__c = 'Available'
                                                            AND Shipment__c = null
                                                            AND Digital__c = true
                                                            AND RecordTypeId = '0125g0000003dGBAAY'
                                                            AND Type_of_Packaging__c = 'Shipping Label'
                                                            ORDER BY Name ASC LIMIT :scope.size()
                                                        ];

        if (availableSecurePackages.isEmpty() || scope.isEmpty()) {
            System.debug('No records found to process.');
            return;
        }

        // Map to pair Secure Packaging and Shipments
        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>();
        Map<Id, Secure_Packaging__c> securePackagingMap = new Map<Id, Secure_Packaging__c>();

        // Pair shipments and secure packaging records
        for (Integer i = 0; i < scope.size(); i++) {
            Shipment__c shipment = scope[i];
            Secure_Packaging__c securePackage = availableSecurePackages[i];

            // Assign Shipping Note Number
            shipment.Shipping_Note_Number__c = securePackage.Name;
            shipmentMap.put(shipment.Id, shipment);

            // Update Secure Packaging
            securePackage.Status__c = 'Consumed';
            securePackage.Shipment__c = shipment.Id;
            securePackagingMap.put(securePackage.Id, securePackage);
        }

        // Perform database updates
        if (!shipmentMap.isEmpty()) {
            update shipmentMap.values();
            System.debug('Updated Shipments: ' + shipmentMap.values());
        }
        if (!securePackagingMap.isEmpty()) {
            update securePackagingMap.values();
            System.debug('Updated Secure Packaging: ' + securePackagingMap.values());
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch process completed successfully.');
    }
}