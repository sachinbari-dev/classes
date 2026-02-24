trigger BVCinvoiceLineItemTrigger on BVCInvoiceLineitem__c (before insert,before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate ){
            list<BVCInvoiceLineitem__c> lineList = new list<BVCInvoiceLineitem__c>();
            list<BVCInvoiceLineitem__c> lineList1 = new list<BVCInvoiceLineitem__c>();
            list<BVCInvoiceLineitem__c> lineList2 = new list<BVCInvoiceLineitem__c>();
            list<BVCInvoiceLineitem__c> lineList3 = new list<BVCInvoiceLineitem__c>();
            list<BVCInvoiceLineitem__c> lineList4 = new list<BVCInvoiceLineitem__c>();
            list<BVCInvoiceLineitem__c> lineList5 = new list<BVCInvoiceLineitem__c>();
            for(BVCInvoiceLineitem__c  ch :  Trigger.new){  
                lineList.add(ch);
                if(ch.BVCInvoice__r.BVC_CB_Is_CB_Invoice__c == true){
                    string validate = BVC_avoidDuplicateLineItemOnInvoice.preventDuplicateCharges(Trigger.new);
                    if(validate != null){
                        ch.addError(validate); 
                    } 
                }           
            }   
        }  
    }
}