trigger AttachmentInvoiceTrigger on Attachment (after insert) { 
    
    //*************************************************************************************************************
    //        Test class = ShipmentSummaryTriggerHandlerTest_2
    //
    //**************************************************************************************************************************
  /*  Boolean isCaseAttachment = FALSE;    
       List<blng__Invoice__c> invoiceList = new List<blng__Invoice__c>(); 
       Map<Id,Id> attachemntInvoiceMap = new Map<Id,Id>(); 
         Set<Id> accIds = new Set<Id>();  
         for(Attachment att : trigger.New){  
              /*Check if uploaded attachment is related to Case Attachment and same Case is already added 
              if(att.ParentId.getSobjectType() == blng__Invoice__c.SobjectType && (!attachemntInvoiceMap.containsKey(att.ParentId))){  
                   // Map InvoiceId and Attachment Id
                   attachemntInvoiceMap.put(att.ParentId, att.Id);
              }  
         }
         for(blng__Invoice__c inv :[Select id,Invoice_AttachmentId__c from blng__Invoice__c where Id in:attachemntInvoiceMap.keySet() ]){
            inv.Invoice_AttachmentId__c = attachemntInvoiceMap.get(inv.Id);
            invoiceList.add(inv);
         }
         //finally update Cases  
         update invoiceList;  */
    
       
     List<BVCInvoice__c> BVCinvoiceList = new List<BVCInvoice__c>(); 
       Map<Id,Id> attachemntInvoiceMap1 = new Map<Id,Id>(); 
        
         for(Attachment att : trigger.New){  
              /*Check if uploaded attachment is related to Case Attachment and same Case is already added*/  
              if(att.ParentId.getSobjectType() == BVCInvoice__c.SobjectType && (!attachemntInvoiceMap1.containsKey(att.ParentId))){  
                   // Map InvoiceId and Attachment Id
                   attachemntInvoiceMap1.put(att.ParentId, att.Id);
              }  
         }
         for(BVCInvoice__c inv :[Select id,Invoice_AttachmentId__c from BVCInvoice__c where Id in:attachemntInvoiceMap1.keySet() ]){
            inv.Invoice_AttachmentId__c = attachemntInvoiceMap1.get(inv.Id);
            BVCinvoiceList.add(inv);
         }
         //finally update Cases  
         update BVCinvoiceList;  
  }