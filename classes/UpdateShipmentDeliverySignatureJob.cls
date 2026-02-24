public class UpdateShipmentDeliverySignatureJob implements Queueable {

    private Set<Id> shipmentIds;
    private Id recId;
    private Delivery__c deliveryData;
    private String strSignElement;
    private Id contentDocId;

    public UpdateShipmentDeliverySignatureJob(Set<Id> shipmentIds, Id recId, Delivery__c deliveryData, String strSignElement) {
        this.shipmentIds = shipmentIds;
        this.recId = recId;
        this.deliveryData = deliveryData;
        this.strSignElement = strSignElement;
    }

    public void execute(QueueableContext context) {
        try {
            if (String.isNotBlank(strSignElement)) {
                ContentVersion cVersion = new ContentVersion(
                    ContentLocation = 'S',
                    PathOnClient = 'Signature-' + System.now() + '.png',
                    Origin = 'H',
                    Title = 'Signature-' + System.now() + '.png',
                    VersionData = EncodingUtil.base64Decode(strSignElement)
                );
                insert cVersion;

                contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id LIMIT 1].ContentDocumentId;
            }

            List<Delivery__c> deliveries = [SELECT Id, Status__c, Shipment__c FROM Delivery__c WHERE Shipment__c IN :shipmentIds];

            if (deliveries.isEmpty()) return;

            Set<Id> shipIds = new Set<Id>();
            for (Delivery__c d : deliveries) {
                if (d.Shipment__c != null) shipIds.add(d.Shipment__c);
            }

            Map<Id, Integer> totalCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : [SELECT Shipment__c shipId, COUNT(Id) total FROM Secure_Bag__c WHERE Shipment__c IN :shipIds
                                       GROUP BY Shipment__c]) {
                totalCountMap.put((Id)ar.get('shipId'), (Integer)ar.get('total'));
            }

            Map<Id, Integer> deliveredCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : [SELECT Shipment__c shipId, COUNT(Id) delivered FROM Secure_Bag__c
                                       WHERE Shipment__c IN :shipIds AND Current_Scan_Loction__c = 'Delivered'
                                       GROUP BY Shipment__c]) {
                deliveredCountMap.put((Id)ar.get('shipId'), (Integer)ar.get('delivered'));
            }

            List<Delivery__c> updatedeliveriesToDelivered = new List<Delivery__c>();
            for (Delivery__c d : deliveries) {
                Integer total = totalCountMap.get(d.Shipment__c);
                Integer delivered = deliveredCountMap.get(d.Shipment__c);
                if (delivered == total && total > 0 && d.Status__c == 'Accepted') {
                    Delivery__c up = new Delivery__c(
                        Id = d.Id,
                        Status__c = 'Delivered',
                        Consignee_Name__c = deliveryData != null ? deliveryData.Consignee_Name__c : null,
                        Consignee_Designation__c = deliveryData != null ? deliveryData.Consignee_Designation__c : null,
                        Delivered_To_Person__c = deliveryData != null ? deliveryData.Consignee_Name__c : null,
                        Actual_Delivery_Date_and_Time__c = System.now(),
                        Error_Remark__c = false,
                        Error_Remark_Description__c = '',
                        OTP_Verified__c = true
                    );
                    updatedeliveriesToDelivered.add(up);
                }
            }

            if (!updatedeliveriesToDelivered.isEmpty()) {
                update updatedeliveriesToDelivered;
            }

            // Attach signature to shipments
            if (contentDocId != null) {
                List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
                for (Id shipId : shipIds) {
                    docLinks.add(new ContentDocumentLink(
                        ContentDocumentId = contentDocId,
                        LinkedEntityId = shipId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                }
                insert docLinks;
            }
        } catch (Exception e) {
            Delivery_Error_Log__c delLogErrorRec = new Delivery_Error_Log__c(
                Name = 'DeliveryUpdate Error',
                Delivery_Id__c = recId,
                Error_Message__c = 'Error on Line => ' + e.getLineNumber() + ' Error Message => ' + e.getMessage()
            );
            insert delLogErrorRec;
        }
    }
    
    /*private List<Shipment__c> shipsToUpdate;
    private List<Delivery__c> deliveriesToUpdate;
    private List<ContentDocumentLink> docLinks;
    private Id recId;

    public UpdateShipmentDeliverySignatureJob(List<Delivery__c> deliveries, List<ContentDocumentLink> docs, Id recId) {
        this.deliveriesToUpdate = deliveries;
        this.docLinks = docs;
        this.recId = recId;
    }

    public void execute(QueueableContext qc) {
        System.debug('for checking Inside execute of UpdateShipmentDeliverySignatureJob');
        try {
            if (!deliveriesToUpdate.isEmpty()) {
                update deliveriesToUpdate;
            }
            if (!docLinks.isEmpty()) {
                insert docLinks;
            }
        } catch (Exception e) {
            insert new Delivery_Error_Log__c(
                Name = 'Error in UpdateShipmentJob',
                Delivery_Id__c = recId,
                Error_Message__c = 'Line ' + e.getLineNumber() + ': ' + e.getMessage()
            );
        }
    }*/
}