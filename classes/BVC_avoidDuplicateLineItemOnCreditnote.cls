public class BVC_avoidDuplicateLineItemOnCreditnote {

    public static string avoidDuplicateLineItem(List<BVCCredit_Note_Line__c> CreditNoteLineList){
        
         Set<Id> creditNoteIds = new Set<Id>();
        
           for(BVCCredit_Note_Line__c  ch : CreditNoteLineList){
            if(ch.BVCCreditNote__c != null){
                creditNoteIds.add(ch.BVCCreditNote__c);
            }
         }
        
             Map<Id, Map<String, BVCCredit_Note_Line__c>> existingMap = new Map<Id, Map<String, BVCCredit_Note_Line__c>>();
             Map<Id, Map<String, BVCCredit_Note_Line__c>> existingNameMap = new Map<Id, Map<String, BVCCredit_Note_Line__c>>();
        
        
            for (BVCCredit_Note_Line__c existing : [ SELECT Id,Charge_Head_Name__c,Charge_Head_Type__c, BVCCreditNote__c,BVCCreditNote__r.id, Line_Number__c, Name  FROM BVCCredit_Note_Line__c WHERE BVCCreditNote__c IN :creditNoteIds]){
                 
                if (!existingMap.containsKey(existing.BVCCreditNote__c)) {
                    existingMap.put(existing.BVCCreditNote__c, new Map<String, BVCCredit_Note_Line__c>());
                }
                 
                  existingMap.get(existing.BVCCreditNote__c).put(String.valueOf(existing.Line_Number__c), existing);
                 
                if (!existingNameMap.containsKey(existing.BVCCreditNote__c)) {
                    existingNameMap.put(existing.BVCCreditNote__c, new Map<String, BVCCredit_Note_Line__c>());
                }
                   existingNameMap.get(existing.BVCCreditNote__c).put(existing.Charge_Head_Type__c, existing);
             }
        
          for (BVCCredit_Note_Line__c b : CreditNoteLineList) {
               
                if (existingNameMap.containsKey(b.BVCCreditNote__c)) {
                    BVCCredit_Note_Line__c existing = existingNameMap.get(b.BVCCreditNote__c).get(b.Charge_Head_Type__c);
                    if (existing != null && existing.Id != b.Id) {
                      
                        return 'Credit Note Line with the same Charge Head Name already exists under this CreditNote.';
                    }
                }
                  
               
          }
        
        return null;
    }
    
    public static string avoidDuplicateLineNumber(List<BVCCredit_Note_Line__c> CreditNoteLineList){
        
           Set<Id> creditNoteIds = new Set<Id>();
        
           for(BVCCredit_Note_Line__c  ch : CreditNoteLineList){
            if(ch.BVCCreditNote__c != null){
                creditNoteIds.add(ch.BVCCreditNote__c);
            }
         }
        
             Map<Id, Map<String, BVCCredit_Note_Line__c>> existingMap = new Map<Id, Map<String, BVCCredit_Note_Line__c>>();
             Map<Id, Map<String, BVCCredit_Note_Line__c>> existingNameMap = new Map<Id, Map<String, BVCCredit_Note_Line__c>>();
        
        
            for (BVCCredit_Note_Line__c existing : [ SELECT Id,Charge_Head_Name__c,Charge_Head_Type__c, BVCCreditNote__c,BVCCreditNote__r.id, Line_Number__c, Name  FROM BVCCredit_Note_Line__c WHERE BVCCreditNote__c IN :creditNoteIds]){
                 
                if (!existingMap.containsKey(existing.BVCCreditNote__c)) {
                    existingMap.put(existing.BVCCreditNote__c, new Map<String, BVCCredit_Note_Line__c>());
                }
                 
                  existingMap.get(existing.BVCCreditNote__c).put(String.valueOf(existing.Line_Number__c), existing);
                 
             }
        
          for (BVCCredit_Note_Line__c b : CreditNoteLineList) {
               
                  if (existingMap.containsKey(b.BVCCreditNote__c)) {
                    Map<String, BVCCredit_Note_Line__c> childMap = existingMap.get(b.BVCCreditNote__c);
        
                    if (b.Line_Number__c != null && childMap.containsKey(String.valueOf(b.Line_Number__c)) 
                        && (Trigger.isInsert || (Trigger.isUpdate && b.Id != childMap.get(String.valueOf(b.Line_Number__c)).Id))) {
                
                       return 'Duplicate Line Number is not allowed on Credit Note Line records under the same CreditNote.';
                    }
                }
          }
        
        return null;
    }
}