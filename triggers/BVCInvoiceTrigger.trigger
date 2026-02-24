trigger BVCInvoiceTrigger on BVCInvoice__c (before update, Before insert, After Insert,after update) {
    
    if(Trigger.isBefore && Trigger.isUpdate ){
        boolean callInvoiceSeriesUpdate = false;
        for(BVCInvoice__c inv : trigger.new){
            if(inv.Status__c != 'Posted' ){
              BVCInvoiceTriggerHandler.amountsInWordConversion(trigger.new,trigger.oldMap);
              //BVCInvoiceTriggerHandler.amountsInWordConversion(trigger.new);
        	  
            }
            System.debug('rafi test inv.BVC_CB_Is_CB_Invoice__c '+inv.BVC_CB_Is_CB_Invoice__c);
            System.debug('rafi test inv.Status__c '+inv.Status__c);
            System.debug('rafi test inv.ST_Invoice_Series__c  '+inv.ST_Invoice_Series__c );
            System.debug('rafi test UtilClass.recursionCheck  '+UtilClass.recursionCheck );
            if(inv.BVC_CB_Is_CB_Invoice__c == true && inv.Status__c != 'Posted' 
               && (inv.ST_Invoice_Series__c == null || String.isBlank(inv.ST_Invoice_Series__c))){
                System.debug('for checking CB Invoice in if gstSerialNumberUpdate ');
                   callInvoiceSeriesUpdate = true;
               }
		}
        
        if (callInvoiceSeriesUpdate) {
            System.debug('for checking after true callInvoiceSeriesUpdate');
            BVCInvoiceTriggerHandler.gstSerialNumberUpdate(trigger.new);
            //BVCInvoiceTriggerHandler.gstSerialNumberUpdate(trigger.new);
            UtilClass.recursionCheck = true;
        }
        
        system.debug('calling...');
        
        Map<Id,BVCInvoice__c> InvMap = new Map<Id,BVCInvoice__c>();
        
         for(BVCInvoice__c inv : trigger.New){
            if((inv.EY_Tax_Calculation_Status__c == 'Success' || inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice') && 
               inv.BVC_CB_Is_CB_Invoice__c == true && inv.Status__c!='Posted'){
                System.debug('for checking Inside AfterInsert inv:'+inv);
                    System.debug('for checking ids in eyInvoiceList');
                //    BVCInvoiceTriggerHandler.postInvoice(trigger.newMap, trigger.oldMap);
               InvMap.put(inv.Id,inv);
            }
			
             if(inv.BVC_CB_Is_CB_Invoice__c == false && inv.Status__c!='Posted'){
                 InvMap.put(inv.Id,inv);
             }
         }
        
        if(InvMap.size()>0){
           BVCInvoiceTriggerHandler.postInvoice(InvMap, trigger.oldMap); 
        }
        // BVCInvoiceTriggerHandler.postInvoice(trigger.newMap, trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
      /*  system.debug('for checking in after update');
        if(!UtilClass.recursionCheck){ 
            system.debug('for checking in after update in recurssive check');
            UtilClass.recursionCheck = true;*/
            
            //  BVCInvoiceTriggerHandler.generateDocument(trigger.new,trigger.oldMap);
            //---------------------------------------------------
            Set<ID> InvIdsGenerateDoc = new Set<ID>();
            Set<ID> InvIdsUpdateFlag = new Set<ID>();
            Set<ID> InvIdscreateroundoffinvoiceline = new Set<ID>();
            
            for (BVCInvoice__c invoice : Trigger.new) {
                System.debug('just to check invoice.ST_Invoice_Series__c '+invoice.ST_Invoice_Series__c);
                if (invoice.BVC_CB_IsTaxPosted__c && invoice.BVC_CB_Invoice_Type__c=='Tax Invoice'  && invoice.BVC_CB_Is_CB_Invoice__c == true && 
                    (invoice.BVC_CB_IsTaxPosted__c !=trigger.oldmap.get(invoice.id).BVC_CB_IsTaxPosted__c) && invoice.Invoice_Doc_URL__c==null && invoice.Business_Type__c!='Manual') {
                        // BVCInvoiceTriggerHandler.generateDocument(trigger.new, trigger.oldMap);
                        system.debug('For calling InvIdsGenerateDoc');
                        InvIdsGenerateDoc.add(invoice.id);   
                    }
                else if (invoice.Status__c == 'Posted' && invoice.BVC_CB_Is_CB_Invoice__c == true && invoice.Invoice_Doc_URL__c==null && invoice.Business_Type__c!='Manual') {
                    // BVCInvoiceTriggerHandler.generateDocument(trigger.new, trigger.oldMap);
                    InvIdsGenerateDoc.add(invoice.id);
                }
                if(invoice.BVC_CB_Is_CB_Invoice__c == false && invoice.Invoice_Doc_URL__c==null){
                    //  BVCInvoiceTriggerHandler.generateDocument(trigger.new, trigger.oldMap);
                    InvIdsGenerateDoc.add(invoice.id);
                }
                   system.debug('To check invoice.id==='+invoice.id);
                   system.debug('To check invoice.Status__c==='+invoice.Status__c);
                if (invoice.Status__c == 'Posted' && invoice.BVC_CB_Is_CB_Invoice__c == true && invoice.Invoice_Doc_URL__c==null && invoice.Business_Type__c!='Manual'){
                    system.debug('To check update flag triggering===');
                    InvIdsUpdateFlag.add(invoice.id);
                    // BVCInvoiceTriggerHandler.createroundoffinvoiceline(trigger.new,trigger.oldMap);
                    // BVCInvoiceTriggerHandler.updateflags(trigger.newMap,trigger.oldMap);
                    
                }
                if (invoice.Status__c == 'Posted' && invoice.BVC_CB_Is_CB_Invoice__c == true && invoice.Invoice_Doc_URL__c!=null && Trigger.oldMap.get(invoice.id).Invoice_Doc_URL__c==null ){
                    InvIdscreateroundoffinvoiceline.add(invoice.id);
                    // BVCInvoiceTriggerHandler.createroundoffinvoiceline(trigger.new,trigger.oldMap);
                    // BVCInvoiceTriggerHandler.updateflags(trigger.newMap,trigger.oldMap);
                    
                }
                
            }
            if(InvIdsGenerateDoc.size()>0){
                BVCInvoiceTriggerHandler.generateDocument(trigger.new, trigger.oldMap);
            }
            if(InvIdsUpdateFlag.size()>0){
               // BVCInvoiceTriggerHandler.createroundoffinvoiceline(trigger.new,trigger.oldMap);
                BVCInvoiceTriggerHandler.updateflags(trigger.newMap,trigger.oldMap);
            }
            if(InvIdscreateroundoffinvoiceline.size()>0){
                BVCInvoiceTriggerHandler.createroundoffinvoiceline(trigger.new,trigger.oldMap);
            }
            
            //--------------------------------------------------
            
       // }
    }
    
    if(Trigger.isBefore && Trigger.isInsert ){
        List<BVCInvoice__c> bvcInvoiceList = new List<BVCInvoice__c>();
        for(BVCInvoice__c inv:trigger.new){
            if(inv.Manual_Invoice__c == true){
                bvcInvoiceList.add(inv);
            }
        }
        if(bvcInvoiceList.size()>0){
            BVCInvoiceTriggerHandler.updateBVCBillingEntityFromBVCBranch(bvcInvoiceList);				//comment to upload query limit to 100 change
            //BVCInvoiceTriggerHandler.updateBVCBillingEntityFromBVCLegelEntities(bvcInvoiceList);
        }
        
        BVCInvoiceTriggerHandler.invoiceBillingDetailUpdate(trigger.new);
        BVCInvoiceTriggerHandler.updateEmailRecepients(trigger.new);
        
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('Inside AfterInsert');
        List<BVCInvoice__c> eyInvoiceList = new List<BVCInvoice__c>();
        
        for(BVCInvoice__c inv : trigger.New){
            if(inv.BVC_Invoice_Run__c == null && inv.Manual_Invoice__c == false && inv.status__c!='Posted' ){
                System.debug('for checking Inside AfterInsert inv:'+inv);
                    System.debug('for checking ids in eyInvoiceList');
                    eyInvoiceList.add(inv);
                
            }
        }
        System.debug('for checking eyInvoiceList === '+eyInvoiceList);
        System.debug('for checking eyInvoiceList.size() === '+eyInvoiceList.size());
        
        if(eyInvoiceList.size() > 0 && eyInvoiceList != null && !eyInvoiceList.isEmpty()){
          /*  list<AsyncApexJob> queuablejobnames=[select id,MethodName,ApexClass.name,JobType,Status,CreatedDate from AsyncApexJob where status!='completed' and status !='Failed' and jobtype='queueable'];
            for(integer i=0;i<queuablejobnames.size();i++){
                System.debug('for checking queuablejobnames '+queuablejobnames[i]);
            }*/
            
           System.enqueueJob(new autoEY_TaxIntegrationQueueable(eyInvoiceList)); 
           
        }
        
        
        //added by Rafi Khan for invoice series generation code 
        
        Map<Id, BVCInvoice__c> invoiceMap = new Map<Id, BVCInvoice__c>(
            [SELECT Id, BVC_CB_Is_CB_Invoice__c, ST_Invoice_Series__c, Invoice_Type__c, BVC_LegalEntity__c, BVC_Legal_Entities__c,
             BVC_LegalEntity__r.GSTIN_State_Code__c, BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c, Status__c,
             BVC_CB_Invoice_Series__c, Total_Amount_With_Tax__c, NumberToWord__c, BVC_LegalEntity__r.Billing_Serial_Number__c
             FROM BVCInvoice__c 
             WHERE Id IN :Trigger.newMap.keySet()]
        );
        
        List<BVCInvoice__c> updatedInvoices = new List<BVCInvoice__c>(invoiceMap.values());
        List<BVCInvoice__c> listToPassHandler = new List<BVCInvoice__c>();
        
        Set<String> existingSeriesNumbers = new Set<String>();
        
        boolean callInvoiceSeriesUpdate = false;
        for(BVCInvoice__c inv : updatedInvoices){
            
            System.debug('for checking in trigger inv.Status__c'+inv.Status__c);
            System.debug('for checking in trigger inv.ST_Invoice_Series__c '+inv.ST_Invoice_Series__c);
            System.debug('for checking in trigger inv.BVC_CB_Is_CB_Invoice__c '+inv.BVC_CB_Is_CB_Invoice__c);
            System.debug('for checking in trigger inv.BVC_LegalEntity__c '+inv.BVC_LegalEntity__c);
            
            if(!UtilClass.recursionCheck && inv.BVC_CB_Is_CB_Invoice__c == false && inv.Status__c != 'Posted' 
               && (inv.ST_Invoice_Series__c == null || String.isBlank(inv.ST_Invoice_Series__c)) 
               && (inv.BVC_LegalEntity__c != null) ){
                	listToPassHandler.add(inv);
                   
                    
            }
            
        }
        if(listToPassHandler.size()>0){
            System.debug('for checking Calling gstSerialNumberUpdate for Invoice: ');
                   BVCInvoiceTriggerHandler.gstSerialNumberUpdate(listToPassHandler);
        }
        UtilClass.recursionCheck = true;
        
        //upto here
        
        
    }
}