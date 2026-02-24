public class SecureBagUpdateQueueable implements Queueable {
    private List<Secure_Bag__c> bagsToUpdate;
    private Id recId;
    private String strSignElement;
    private Delivery__c deliveryData;
    private List<Id> shipmentIds;

    public SecureBagUpdateQueueable(List<Secure_Bag__c> bagsToUpdate, Id recId, String strSignElement, Delivery__c deliveryData, List<Id> shipmentIds) {
        this.bagsToUpdate = bagsToUpdate;
        this.recId = recId;
        this.strSignElement = strSignElement;
        this.deliveryData = deliveryData;
        this.shipmentIds = shipmentIds;
    }

    public void execute(QueueableContext context) {
        try {
            List<Secure_Bag__c> finalBagsToUpdate = new List<Secure_Bag__c>();
            List<Secure_Bag__c> uniqueBags = dedupeBags(bagsToUpdate);
            
            for (Secure_Bag__c bag : uniqueBags) {
                
                finalBagsToUpdate.add(new Secure_Bag__c(
                    Id = bag.Id,
                    Current_Scan_Loction__c = 'Delivered',
                    Current_Scan_Date_and_Time__c = System.now(),
                    Scanning_Status__c = 'Scanned'
                ));
            }
            System.debug('for checking finalBagsToUpdate.size() : '+finalBagsToUpdate.size());
            if (!finalBagsToUpdate.isEmpty()) {
                update finalBagsToUpdate;
                
                /*for (List<Secure_Bag__c> chunk : splitBags(prepared, 200)) {
                    update chunk;
                }
                */
                System.debug('for checking strSignElement : '+strSignElement);
                
                Id contentDocId;
                if (String.isNotBlank(strSignElement)) {
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S';
                    cVersion.PathOnClient    = 'Signature-' + System.now() + '.png';
                    cVersion.Origin          = 'H';
                    cVersion.Title           = 'Signature-' + System.now() + '.png';
                    cVersion.VersionData     = EncodingUtil.base64Decode(strSignElement);
                    insert cVersion;
                    
                    contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cVersion.Id LIMIT 1].ContentDocumentId;
                }
                
                System.debug('for checking calling DeliveryUpdateQueueable');
                System.enqueueJob(new DeliveryUpdateQueueable(shipmentIds, recId, deliveryData, contentDocId));

            }

            
        } catch (Exception e) {
            insert new Delivery_Error_Log__c(
                Name = 'BagUpdate Error',
                Delivery_Id__c = recId,
                Error_Message__c = e.getMessage()
            );
        }
    }
    
     private static List<Secure_Bag__c> dedupeBags(List<Secure_Bag__c> bags) {
        Map<Id, Secure_Bag__c> uniqueMap = new Map<Id, Secure_Bag__c>();
        for (Secure_Bag__c b : bags) {
            if (b.Id != null) uniqueMap.put(b.Id, b);
        }
        return uniqueMap.values();
    }
    
    /*
    private static List<List<Secure_Bag__c>> splitBags(List<Secure_Bag__c> input, Integer size) {
        List<List<Secure_Bag__c>> parts = new List<List<Secure_Bag__c>>();
        
        for (Integer i = 0; i < input.size(); i += size) {
            List<Secure_Bag__c> chunk = new List<Secure_Bag__c>();
            
            Integer last = Math.min(i + size, input.size());
            for (Integer j = i; j < last; j++) {
                chunk.add(input[j]);
            }
            
            parts.add(chunk);
        }
        
        return parts;
    }
	*/
}