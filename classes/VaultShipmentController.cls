public with sharing class VaultShipmentController {

    @AuraEnabled(cacheable=true)
    public static List<Vault_Shipmet__c> getVaultShipments() {
        return [
            SELECT Id, Name, Customer__r.Name, Billing_Account__r.Name,Secure_Bags__c
            FROM Vault_Shipmet__c
            LIMIT 100
        ];
    }

    /**
     * Generate and merge PDF labels for multiple Vault_Shipment__c records
     */
    @AuraEnabled
    public static String generateVaultShipmentLabels(List<Id> shipmentIds) {
        if (shipmentIds == null || shipmentIds.isEmpty()) {
            throw new AuraHandledException('No shipments selected.');
        }

        String orgUrl = URL.getOrgDomainUrl().toExternalForm();

        List<String> pdfUrls = new List<String>();
        for (Id shipmentId : shipmentIds) {
            String vfPageUrl = orgUrl + '/apex/VaultShipmentPrintLabelPdf?id=' + shipmentId;
            pdfUrls.add(vfPageUrl);
        }

        String mergedUrl = orgUrl + '/apex/VaultShipmentPrintLabelPdf?ids=' + String.join((List<String>)shipmentIds, ',');

        return mergedUrl;
    }
}