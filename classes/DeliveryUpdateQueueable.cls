public class DeliveryUpdateQueueable implements Queueable {
    private List<Id> shipmentIds;
    private Id recId;
    private Delivery__c deliveryData;
    private Id contentDocId;

    public DeliveryUpdateQueueable(List<Id> shipmentIds, Id recId, Delivery__c deliveryData, Id contentDocId) {
        this.shipmentIds = shipmentIds;
        this.recId = recId;
        this.deliveryData = deliveryData;
        this.contentDocId = contentDocId;
    }

    public void execute(QueueableContext context) {
        List<Delivery_Error_Log__c> errorLogs = new List<Delivery_Error_Log__c>();
        System.debug('➡ Inside DeliveryUpdateQueueable');
        
        try {
            if (shipmentIds.isEmpty()) return;
            
            Map<Id, Integer> totalBags = new Map<Id, Integer>();
            for (AggregateResult ar : [SELECT Shipment__c shipId, COUNT(Id) cnt FROM Secure_Bag__c
                WHERE Shipment__c IN :shipmentIds GROUP BY Shipment__c]) {
                totalBags.put((Id)ar.get('shipId'), (Integer)ar.get('cnt'));
            }
            
            Map<Id, Integer> deliveredBags = new Map<Id, Integer>();
            for (AggregateResult ar : [SELECT Shipment__c shipId, COUNT(Id) cnt FROM Secure_Bag__c
                WHERE Shipment__c IN :shipmentIds AND Current_Scan_Loction__c = 'Delivered' GROUP BY Shipment__c]) {
                deliveredBags.put((Id)ar.get('shipId'), (Integer)ar.get('cnt'));
            }
            
            List<Delivery__c> deliveries = [SELECT Id, Status__c, Shipment__c FROM Delivery__c WHERE Shipment__c IN :shipmentIds];
            
            List<Delivery__c> deliveriesToUpdate = new List<Delivery__c>();
            
            for (Delivery__c d : deliveries) {
                Integer total = totalBags.containsKey(d.Shipment__c) ? totalBags.get(d.Shipment__c) : 0;
                Integer delivered = deliveredBags.containsKey(d.Shipment__c) ? deliveredBags.get(d.Shipment__c) : 0;
                
                System.debug('Shipment ' + d.Shipment__c + ' -> total: ' + total + ', delivered: ' + delivered + ', status: ' + d.Status__c);
                
                if (delivered == total && total > 0 && d.Status__c == 'Accepted') {
                    deliveriesToUpdate.add(new Delivery__c(
                        Id = d.Id,
                        Status__c = 'Delivered',
                        Consignee_Name__c = deliveryData.Consignee_Name__c,
                        Consignee_Designation__c = deliveryData.Consignee_Designation__c,
                        Delivered_To_Person__c = deliveryData.Consignee_Name__c,
                        Actual_Delivery_Date_and_Time__c = System.now(),
                        Error_Remark__c = false,
                        Error_Remark_Description__c = '',
                        OTP_Verified__c = true
                    ));
                }
            }
            
            System.debug('✅ deliveriesToUpdate.size() = ' + deliveriesToUpdate.size());
            
            if (!deliveriesToUpdate.isEmpty()) {
                update deliveriesToUpdate;
            }
            
            if (contentDocId != null) {
                List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
                for (Id shipId : shipmentIds) {
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
            errorLogs.add(new Delivery_Error_Log__c(
                Name = 'DeliveryUpdate Error',
                Delivery_Id__c = recId,
                Error_Message__c = e.getMessage()
            ));
        }
        
        if (!errorLogs.isEmpty()) insert errorLogs;
    }

}