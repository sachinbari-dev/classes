public class BVC_preventDuplicateChargeHeadRecord {

    public static string avoidDuplicateChaergeHead(List<BVC_Charge_Head_Tax__c> ChargeHeadList){
        Set<Id> invoiceIds = new Set<Id>();
        
        for(BVC_Charge_Head_Tax__c  ch : ChargeHeadList){
            if(ch.BVCInvoice__c != null){
                invoiceIds.add(ch.BVCInvoice__c);
               
            }
            
             Map<Id, Map<String, BVC_Charge_Head_Tax__c>> existingMap = new Map<Id, Map<String, BVC_Charge_Head_Tax__c>>();
             Map<Id, Map<String, BVC_Charge_Head_Tax__c>> existingNameMap = new Map<Id, Map<String, BVC_Charge_Head_Tax__c>>();
            
             for (BVC_Charge_Head_Tax__c existing : [ SELECT Id, BVCInvoice__c,BVCInvoice__r.id, Line_Number__c, Name  FROM BVC_Charge_Head_Tax__c WHERE BVCInvoice__c IN :invoiceIds]) {
                 
                if (!existingMap.containsKey(existing.BVCInvoice__c)) {
                    existingMap.put(existing.BVCInvoice__c, new Map<String, BVC_Charge_Head_Tax__c>());
                }
                 
                  existingMap.get(existing.BVCInvoice__c).put(String.valueOf(existing.Line_Number__c), existing);
                 
                if (!existingNameMap.containsKey(existing.BVCInvoice__c)) {
                    existingNameMap.put(existing.BVCInvoice__c, new Map<String, BVC_Charge_Head_Tax__c>());
                }
                   existingNameMap.get(existing.BVCInvoice__c).put(existing.Name, existing);
             }
            
              for (BVC_Charge_Head_Tax__c b : ChargeHeadList) {
               
                if (existingNameMap.containsKey(b.BVCInvoice__c)) {
                    BVC_Charge_Head_Tax__c existing = existingNameMap.get(b.BVCInvoice__c).get(b.Name);
                    if (existing != null && existing.Id != b.Id) {
                      
                        return 'Charge Head record with the same Name already exists under this Invoice.';
                    }
                }
                  
                  if (existingMap.containsKey(b.BVCInvoice__c)) {
                    Map<String, BVC_Charge_Head_Tax__c> childMap = existingMap.get(b.BVCInvoice__c);
        
                    if (b.Line_Number__c != null && childMap.containsKey(String.valueOf(b.Line_Number__c)) 
                        && (Trigger.isInsert || (Trigger.isUpdate && b.Id != childMap.get(String.valueOf(b.Line_Number__c)).Id))) {
                
                       return 'Duplicate Line Number is not allowed on charge head records under the same invoice.';
                    }
                }  
          }
            
            
        }
        return null;
    } 
     
     
}