public class BVC_avoidDuplicateLineItemOnInvoice {

    public static String preventDuplicateCharges(List<BVCInvoiceLineitem__c> lineItemList) {
        
        Set<Id> invoiceIds = new Set<Id>();
        
        for(BVCInvoiceLineitem__c  ch : lineItemList){
            if(ch.BVCInvoice__c != null ){
                invoiceIds.add(ch.BVCInvoice__c);
                 system.debug('size of invoice' + invoiceIds.size());
            }
            
           
             Map<Id, Map<String, BVCInvoiceLineitem__c>> existingNameMap = new Map<Id, Map<String, BVCInvoiceLineitem__c>>();
            
             for (BVCInvoiceLineitem__c existing : [ SELECT Id, BVCInvoice__c,BVCInvoice__r.id,BVCInvoice__r.BVC_CB_Is_CB_Invoice__c, Name,BVC_CB_ChargeDescription__c  FROM BVCInvoiceLineitem__c WHERE BVCInvoice__r.BVC_CB_Is_CB_Invoice__c = true AND  BVCInvoice__c IN :invoiceIds]) {
                 
                if (!existingNameMap.containsKey(existing.BVCInvoice__c)) {
                    existingNameMap.put(existing.BVCInvoice__c, new Map<String, BVCInvoiceLineitem__c>());
                }
                   existingNameMap.get(existing.BVCInvoice__c).put(existing.BVC_CB_ChargeDescription__c, existing);
             }
            
              for (BVCInvoiceLineitem__c b : lineItemList) {
               
                if (existingNameMap.containsKey(b.BVCInvoice__c)) {
                    BVCInvoiceLineitem__c existing = existingNameMap.get(b.BVCInvoice__c).get(b.BVC_CB_ChargeDescription__c);
                    if (existing != null && existing.Id != b.Id) {
                      
                        return 'Line item record with the same Charge already exists under this Invoice.';
                    }
                }
          }
            
        }
        return null;
    } 
}