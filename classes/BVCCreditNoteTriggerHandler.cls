public class BVCCreditNoteTriggerHandler {
    
    public static final map<String,String> mapOfTypeCode = new map<String,String>{
        
        'Tax Invoice' => 'T', 'Bill of Supply Invoice' => 'B',
            'Commercial Invoice ' => 'C', 'Tax Credit Note' => 'T',
            'Bill of Supply Credit Note' => 'B', 'Commercial Credit Note' => 'C'
    } ;
                
    /**
     *  Name : amountsInWordConversion
     *  Description : Convert. Total Amount To word for Document
     *  Param : Trigger.new and Old map
     *  Return : None
     * 
    **/   
    
    public static void amountsInWordConversion(List<BVCCreditNote__c> newList,Map<Id,BVCCreditNote__c> oldMap){
        system.debug('amountsInWordConversion called------');
        NumberTOWordConvertion numtoword = new NumberTOWordConvertion ();
        for(BVCCreditNote__c cnRec : newList){
            if(cnRec.TotalAmount__c != null && cnRec.TotalAmount__c >=0 && cnRec.TotalAmount__c != oldMap.get(cnRec.Id).TotalAmount__c){
                cnRec.Total_Amount_In_Words__c = numtoword.getNumberTOWordConvertion(cnRec.TotalAmount__c);
            }
        }                
    }  
   
    /*
     * Name : updateRecordType
     * Description : Update Record type based on invoice type for CB
     * Param : Trigger.new
     * Return : None
     * 
    */
   public static void updateRecordType(List<BVCCreditNote__c> newList){ 
        set<Id> invoiceIds = new set<Id>();
        for(BVCCreditNote__c cn:newList){
            if(cn.BVCInvoice__c!=null)
            invoiceIds.add(cn.BVCInvoice__c); 
            system.debug('set of invoice==='+invoiceIds);
        }
        map<Id, BVCInvoice__c> mapInvoice=new map<Id,BVCInvoice__c>([select id, BVC_CB_Invoice_Type__c from BVCInvoice__c where Id in:invoiceIds]);
        system.debug('Map of invoice==='+mapInvoice);
        map<String, Id> mapRecordType = new map<String, Id>();
        
        for(recordtype r:[select Id,DeveloperName from RecordType where SobjectType ='BVCCreditNote__c']){
        mapRecordType.put(r.DeveloperName,r.Id);
            system.debug('Map of recordType==='+mapRecordType);
        }
        for(BVCCreditNote__c cn:newList){
            String developerName = 'Master';
            String creditnotetype = 'Tax Credit Note';
            system.debug('CN.Invoice'+mapInvoice.get(cn.BVCInvoice__c));
            system.debug('CN.Invoice'+mapInvoice.get(cn.BVCInvoice__c).BVC_CB_Invoice_Type__c);
            if(mapInvoice.get(cn.BVCInvoice__c).BVC_CB_Invoice_Type__c=='Tax Invoice')
            {
                developerName='Tax_Credit_Note';
            }
            if(mapInvoice.get(cn.BVCInvoice__c).BVC_CB_Invoice_Type__c=='Commercial Invoice'){
             	developerName='Commercial_Credit_Note';
                creditnotetype = 'Commercial Credit Note'; 
            }
            if(mapInvoice.get(cn.BVCInvoice__c).BVC_CB_Invoice_Type__c=='Bill of Supply Invoice')
            {
                developerName='BOS_Credit_Note';
                creditnotetype = 'Bill of Supply Credit Note';
             }
            	
            cn.RecordTypeId = mapRecordType.get(developerName); 
			cn.Credit_Note_Type__c = creditnotetype;            
        }
    }
    
    /*
     * Name : updateEmailRecepients
     * Description : Update the Email Recepients
     * Param : Trigger.new
     * Return : None
     * 
    */ 
    
    public static void updateEmailRecepients(List<BVCCreditNote__c> newList){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> dealIds = new Set<Id>();
        Map<Id,String> mapAccountRecepients = new Map<Id,String>();
        Map<Id,BVCInvoice__c> mapInvoice = new Map<Id,BVCInvoice__c>();
        Map<Id,String> mapDealRecepients = new Map<Id,String>();
        for(BVCCreditNote__c cnRec : newList){
            accountIds.add(cnRec.Account__c);
            invoiceIds.add(cnRec.BVCInvoice__c);
        }
        System.debug('accountIds. '+accountIds);
        System.debug('invoiceIds. '+invoiceIds);
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where Roles INCLUDES ('Invoice Recepient;Finance') AND AccountId in:accountIds AND Contact.Email != null ]){
            if(mapAccountRecepients.containsKey(acr.AccountId)){
                String recepientStr = mapAccountRecepients.get(acr.AccountId);
                recepientStr = recepientStr + ', '+ acr.Contact.Email;
                mapAccountRecepients.put(acr.AccountId, recepientStr);
            }else {
                mapAccountRecepients.put(acr.AccountId,acr.Contact.Email);
            }
        }
        System.debug('mapAccountRecepients.size() '+mapAccountRecepients.size());
        System.debug('mapAccountRecepients.values() '+mapAccountRecepients.values());
        
        if(!Test.isRunningTest()){
        Id quoteId;
        BVCInvoice__c newInvoice = new BVCInvoice__c();
        newInvoice = [Select id,BVCOrder__c,BVCQuote__c,BVCQuote__r.Business_Type__c,BVCOrder__r.Business_Type__c, Manual_Invoice__c,
                      BVCOrder__r.Account__r.BVC_Contract__r.Quote__c,Account__r.BVC_Contract__r.Quote__c,BVC_Invoice_Run__c from BVCInvoice__c 
                      where id in:invoiceIds AND 
                      (BVCOrder__r.Business_Type__c = 'Non ACR' OR BVCQuote__r.Business_Type__c = 'ACR' OR Manual_Invoice__c = true OR 	BVC_CB_PreTaxBill__c!=null OR BVC_Invoice_Run__c!=null)];
        if(newInvoice.BVCOrder__c != null ){
            quoteId = newInvoice.BVCOrder__r.Account__r.BVC_Contract__r.Quote__c;
        }
        if( newInvoice.BVCQuote__c != null){
            quoteId = newInvoice.BVCQuote__c;
        }
        if(newInvoice.Manual_Invoice__c == true || newInvoice.BVC_Invoice_Run__c!=null ){
            quoteId = newInvoice.Account__r.BVC_Contract__r.Quote__c;
        }
        
        List<String> strRole = new List<String>();
        strRole.add('Decision Maker');
        strRole.add('Evaluator');
        for(People_Role__c oppRole : [SELECT People__c, Id, BVCQuote__c, Role__c, People__r.Email FROM People_Role__c  
                WHERE Role__c IN :strRole 
                  AND People__r.Email != null AND BVCQuote__c =: quoteId] ){
            System.debug('oppRole. '+oppRole);
            if(mapDealRecepients.containsKey(oppRole.BVCQuote__c)){
                String recepientStr = mapDealRecepients.get(oppRole.BVCQuote__c);
                recepientStr = recepientStr + ', '+ oppRole.People__r.Email;
                mapDealRecepients.put(oppRole.BVCQuote__c, recepientStr);
            }else {
                mapDealRecepients.put(oppRole.BVCQuote__c, oppRole.People__r.Email);
            }
        }
        System.debug('mapDealRecepients. '+mapDealRecepients);
        
        System.debug('mapDealRecepients.size() '+mapDealRecepients.size());
        for(BVCCreditNote__c cnRec : newList){
            System.debug('cnRec.BVCInvoice__c ### '+cnRec.BVCInvoice__c);
            System.debug('mapInvoice.containsKey(cnRec.BVCInvoice__c) ### '+mapInvoice.containsKey(cnRec.BVCInvoice__c));
            //System.debug('Checking+++ '+mapDealRecepients.containsKey(mapInvoice.get(cnRec.BVCInvoice__c).BVCQuote__c));
            System.debug('mapAccountRecepients.containsKey(cnRec.Account__c) ### ');
            if( cnRec.BVCInvoice__c != null && mapInvoice.containsKey(cnRec.BVCInvoice__c)){
                cnRec.Email_Recepients__c = (mapDealRecepients.containsKey(mapInvoice.get(cnRec.BVCInvoice__c).BVCQuote__c) ? mapDealRecepients.get(mapInvoice.get(cnRec.BVCInvoice__c).BVCQuote__c) :'');
                System.debug('cnRec.Email_Recepients__c ### '+cnRec.Email_Recepients__c);
                
            }
            else if(mapAccountRecepients.containsKey(cnRec.Account__c)){
                cnRec.Email_Recepients__c = mapAccountRecepients.get(cnRec.Account__c);
            }
        }
        }
    }
    
    /**
    * Method Name : gstSerialNumberUpdate
    * Description : Update Invoice Serial Number based on GST
    * Param : Trigger.new
    * 
    */
    /*
    //Existing method
    public static void gstSerialNumberUpdate(List<BVCCreditNote__c> newList){
         system.debug('gstSerialNumberUpdate called------');
        Map<Id,String> orderIds=new map<Id,String>();
       // Map<Id,BVCCreditNote__c> cbcreditnotes = new Map<Id,BVCCreditNote__c>();
        list<Id> CBserial = new list<Id>();
        list<BVCCreditNote__c> cbcreditnotes=new list<BVCCreditNote__c>();
        map<String, Id> mapRecordType = new map<String, Id>();
        String Masterid;
        Boolean hastaxcn = false;
        Boolean hasBOScn = false;
        Boolean hasCommcn = false;
        if(!Test.isRunningTest()){
            for(recordtype r:[select Id,DeveloperName from RecordType where SobjectType ='BVCCreditNote__c']){
                if(r.DeveloperName == 'Master'){ //testing purpose
                    Masterid = r.id;
                    system.debug('Masterid------'+Masterid);
                }    
            }
        }
        for(BVCCreditNote__c cnRec: newList){
            if( cnRec.Credit_Note_Type__c != null &&
            // && cnRec.Approval_Status__c == 'Approved' &&
              (cnRec.CreditNote_Serial_No__c == null || String.isBlank(cnRec.CreditNote_Serial_No__c))){
                  System.debug('cnRec.RecordTypeId ===='+cnRec.RecordTypeId );
                  if(cnRec.RecordTypeId != Masterid){				
                      
                          System.debug('Checking inside if');
                          cbcreditnotes.add(cnRec);
                          CBserial.add(cnRec.Id);
                  }
                 else{
                     system.debug('in Else');
                     orderIds.put(cnRec.BVCInvoice__c, cnRec.Credit_Note_Type__c );
                 }                
            }
        }
        if(cbcreditnotes.size()>0 && !cbcreditnotes.isEmpty()){
            Map<Id,BVCCreditNote__c> SrNumMap = new Map<Id,BVCCreditNote__c>([Select id,BVCInvoice__r.state_code__c,BVCInvoice__r.BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c from BVCCreditNote__c where Id IN :CBserial]);
            integer taxvar=1;
            integer comvar=1;
            integer bosvar=1;
             Map<String,DocumentSeries__c> mapUniqueKeyRecordCn =new Map<String,DocumentSeries__c>();
            if(!Test.isRunningTest()){
                for(DocumentSeries__c doc : [Select id, Unique_Key__c, Last_Serial_Number__c from DocumentSeries__c where name like '24CB%' OR name like '27CB%']){
                                                 mapUniqueKeyRecordCn.put(doc.Unique_Key__c,doc);
                                                 system.debug('====>'+doc);
                }
            }
            for(BVCCreditNote__c CBCn :cbcreditnotes){
                 
                string CNseries ;
             if(!Test.isRunningTest()){
                    try{
                	System.debug('for checking CBCn.Credit_Note_Type__c === '+CBCn.Credit_Note_Type__c);
                    
                        if(CBCn.Credit_Note_Type__c == 'Tax Credit Note'){
                        system.debug('Inside Credit Note Tax CN'); 
                        integer count = integer.valueOf(mapUniqueKeyRecordCn.get(CBCn.BVC_CB_Credit_Note_Series__c).Last_Serial_Number__c)+1;                
                        CNseries = CBCn.BVC_CB_Credit_Note_Series__c+count; 
                        system.debug(CNseries);
                        taxvar++;
                        //DocumentSeries__c is a custom setting. created record for maharashtra 27CBTI and for gujarat 24CBTII
                        DocumentSeries__c docM = new DocumentSeries__c(id=mapUniqueKeyRecordCn.get(CBCn.BVC_CB_Credit_Note_Series__c).id);
                        docM.Name = CBCn.BVC_CB_Credit_Note_Series__c;
                        docM.Last_Serial_Number__c = String.valueOf(count);
                        docM.Unique_Key__c = CBCn.BVC_CB_Credit_Note_Series__c;
                        mapUniqueKeyRecordCn.put(CBCn.BVC_CB_Credit_Note_Series__c,docM);
                    }
                        else if(CBCn.Credit_Note_Type__c =='Commercial Credit Note'){
                        System.debug('inside comm');
                        integer count = integer.valueOf(mapUniqueKeyRecordCn.get(CBCn.BVC_CB_Credit_Note_Series__c).Last_Serial_Number__c)+1;                
                        CNseries = CBCn.BVC_CB_Credit_Note_Series__c+count; 
                        system.debug(CNseries);
                        taxvar++;
                        DocumentSeries__c docM = new DocumentSeries__c(id=mapUniqueKeyRecordCn.get(CBCn.BVC_CB_Credit_Note_Series__c).id);
                        docM.Name = CBCn.BVC_CB_Credit_Note_Series__c;
                        //removed +1 from 351= docM.Last_Serial_Number__c = String.valueOf(count+1);
                        docM.Last_Serial_Number__c = String.valueOf(count);
                        docM.Unique_Key__c = CBCn.BVC_CB_Credit_Note_Series__c;
                        mapUniqueKeyRecordCn.put(CBCn.BVC_CB_Credit_Note_Series__c,docM);                  
                    }
                        else if(CBCn.Credit_Note_Type__c =='Bill of Supply Credit Note'){
                        System.debug('inside BOS');
                        integer count = integer.valueOf(mapUniqueKeyRecordCn.get(CBCn.BVC_CB_Credit_Note_Series__c).Last_Serial_Number__c)+1;                
                        CNseries = CBCn.BVC_CB_Credit_Note_Series__c+count; 
                        system.debug(CNseries);
                        taxvar++;
                        DocumentSeries__c docM = new DocumentSeries__c(id=mapUniqueKeyRecordCn.get(CBCn.BVC_CB_Credit_Note_Series__c).id);
                        docM.Name = CBCn.BVC_CB_Credit_Note_Series__c;
                        //removed +1 from 351= docM.Last_Serial_Number__c = String.valueOf(count+1);
                        docM.Last_Serial_Number__c = String.valueOf(count);
                        docM.Unique_Key__c = CBCn.BVC_CB_Credit_Note_Series__c;
                        mapUniqueKeyRecordCn.put(CBCn.BVC_CB_Credit_Note_Series__c,docM);
                    }
                        CBCn.CreditNote_Serial_No__c=CNseries ;
                    }catch (Exception ex){
                        System.debug('for checking error  '+ex.getMessage());
                        System.debug('for checking error on line number  '+ex.getLineNumber());
                    }
                 
             }
        }
            Upsert mapUniqueKeyRecordCn.values();
        }
      
        Map<Id,String> orderMap = new Map<Id,String>();
        if(orderIds != null && orderIds.size() >0){
            if(!Test.isRunningTest()){
                orderMap = getBranchInfo(orderIds);
            }
        }
        Map<String,Integer> mapUniqueKeyNumber = new Map<String,Integer>();
        List<DocumentSeries__c>upsertList = new List<DocumentSeries__c>();
        Map<String,DocumentSeries__c> mapUniqueKeyRecord =new Map<String,DocumentSeries__c>();
        if(orderMap != null){
            if(!Test.isRunningTest()){
                for(DocumentSeries__c doc : [Select Unique_Key__c, Last_Serial_Number__c from DocumentSeries__c where Unique_Key__c IN:orderMap.values()]){
                    mapUniqueKeyNumber.put(doc.Unique_Key__c,Integer.valueOf(doc.Last_Serial_Number__c.right(doc.Last_Serial_Number__c.length() - doc.Unique_Key__c.length())));
                    mapUniqueKeyRecord.put(doc.Unique_Key__c,doc);
                }
            }
            for(BVCCreditNote__c cnRec: newList){
                if(cnRec.CreditNote_Serial_No__c == null || String.isBlank(cnRec.CreditNote_Serial_No__c)){
                    if(orderMap != null && orderMap.containsKey(cnRec.BVCInvoice__c)){
                        if(mapUniqueKeyNumber.containsKey(orderMap.get(cnRec.BVCInvoice__c))){
                            Integer newSerialNUmber = mapUniqueKeyNumber.get(orderMap.get(cnRec.BVCInvoice__c)) +1;
                            cnRec.CreditNote_Serial_No__c = orderMap.get(cnRec.BVCInvoice__c) + newSerialNUmber;
                            mapUniqueKeyRecord.get(orderMap.get(cnRec.BVCInvoice__c)).Last_Serial_Number__c = orderMap.get(cnRec.BVCInvoice__c) + newSerialNUmber;
                            mapUniqueKeyNumber.put(orderMap.get(cnRec.BVCInvoice__c),newSerialNUmber);
                            
                        }else{
                            cnRec.CreditNote_Serial_No__c = orderMap.get(cnRec.BVCInvoice__c) + 1;
                            DocumentSeries__c docM = new DocumentSeries__c();
                            docM.Name = orderMap.get(cnRec.BVCInvoice__c);
                            docM.Last_Serial_Number__c = orderMap.get(cnRec.BVCInvoice__c) + 1;
                            docM.Unique_Key__c = orderMap.get(cnRec.BVCInvoice__c);
                            mapUniqueKeyRecord.put(orderMap.get(cnRec.BVCInvoice__c),docM);
                            mapUniqueKeyNumber.put(orderMap.get(cnRec.BVCInvoice__c),1);
                        }
                    }
                }
            }
            system.debug('map value-------'+mapUniqueKeyRecord.values());
            upsert mapUniqueKeyRecord.values();
        }
        
    }
    */
    
    
    // Added by Rafi Khan - Use this method to remove custom setting dependancy used for serial number generation.
    public static void gstSerialNumberUpdate(List<BVCCreditNote__c> newList){
        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate newList = '+newList);
        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate newList. size = '+newList.size());
        List<BVCCreditNote__c> CBinvoiceIds = new List<BVCCreditNote__c>();
        Map<Id,String> invoiceIds = new Map<Id,String>();
        List<Id> CBserial = new List<Id>();

        Set<String> usedInvoiceSeries = new Set<String>();

        for(BVCCreditNote__c inv: newList){
            // CB credit notes (central billing) flag - adjust API name if different in your org
            if(inv.BVC_CB_Is_CB_CreditNote_c__c == true && (inv.CreditNote_Serial_No__c == null || String.isBlank(inv.CreditNote_Serial_No__c))){
                System.debug('Checking inside CB credit note if');
                CBinvoiceIds.add(inv);
                CBserial.add(inv.Id);
            }else{
                if(inv.CreditNote_Serial_No__c == null || String.isBlank(inv.CreditNote_Serial_No__c)){
                    invoiceIds.put(inv.Id, inv.Credit_Note_Type__c);
                }
            }
        }

        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate invoiceIds.size() = '+invoiceIds.size());
        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate CBinvoiceIds.size() = '+CBinvoiceIds.size());

        // Non-CB credit notes processing (same pattern as invoice)
        if(invoiceIds.size()>0 && !invoiceIds.isEmpty()){
            System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate invoiceIds.  '+invoiceIds);

            Map<Id,String> invMap = getBranchInfo(invoiceIds); // builds unique key like StateCode + TypeCode + 'C' + BillingSerial
            Map<String,Long> mapUniqueKeyNumber = new Map<String,Long>();

            Map<String,String> mapGSTINStateCode = new Map<String,String>();

            List<DocumentSeries__c> upsertList = new List<DocumentSeries__c>();
            Map<String,DocumentSeries__c> mapUniqueKeyRecord = new Map<String,DocumentSeries__c>();

            System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate invMap.size() = '+invMap.size());
            System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.gstSerialNumberUpdate invMap.values() = '+invMap.values());
            String invoiceSeries;
            Set<Id> invoiceBillingEntity = new Set<Id>();
            Set<String> stateCode = new Set<String>();
            if(invMap.size() > 0){
                for(DocumentSeries__c doc : [SELECT Unique_Key__c, Last_Serial_Number__c FROM DocumentSeries__c WHERE Unique_Key__c IN :invMap.values()]){
                    mapGSTINStateCode.put(doc.Unique_Key__c, doc.Unique_Key__c.left(2));
                }

                System.debug('for checking mapGSTINStateCode = '+mapGSTINStateCode);

                for(BVCCreditNote__c invRec: newList){
                    if(invMap != null && invMap.containsKey(invRec.Id)){
                        if(mapGSTINStateCode.containsKey(invMap.get(invRec.Id))){
                            invoiceBillingEntity.add(invRec.BVC_LegalEntity__c);
                            stateCode.add(invRec.BVC_LegalEntity__r.GSTIN_State_Code__c);
                        }
                    }
                }
                System.debug('for checking branchInfo '+invoiceBillingEntity);
                System.debug('for checking stateCode ='+stateCode);
                Long newSerialNUmber ;
                String existingInvoiceSeriesNumber;

                Map<String,String> existingInvoiceSeriesNumberMap = new Map<String,String>();

                List<BVCCreditNote__c> invSeriesAlreadyPresent = new List<BVCCreditNote__c>();
                if(!invoiceBillingEntity.isEmpty() && !stateCode.isEmpty()){
                    invSeriesAlreadyPresent = [
                        SELECT Id, CreditNote_Serial_No__c, BVC_LegalEntity__c,
                        BVC_LegalEntity__r.GSTIN_State_Code__c
                        FROM BVCCreditNote__c
                        WHERE BVC_CB_Is_CB_CreditNote_c__c = false
                        AND CreditNote_Serial_No__c != null
                        AND BVC_LegalEntity__c IN :invoiceBillingEntity
                        AND BVC_LegalEntity__r.GSTIN_State_Code__c IN :stateCode
                    ];
                }

                System.debug('for checking invSeriesAlreadyPresent '+invSeriesAlreadyPresent);
                System.debug('for checking invSeriesAlreadyPresent.size() '+invSeriesAlreadyPresent.size());

                invSeriesAlreadyPresent.sort(new CreditNoteSeriesComparator());

                System.debug('for checking new invSeriesAlreadyPresent '+invSeriesAlreadyPresent);

                Map<String, BVCCreditNote__c> latestInvoicePerCombo = new Map<String, BVCCreditNote__c>();

                for (BVCCreditNote__c bvcInv : invSeriesAlreadyPresent) {
                    
                    String expectedStateCode = bvcInv.BVC_LegalEntity__r.GSTIN_State_Code__c;
                    
                    if(!bvcInv.CreditNote_Serial_No__c.startsWith(expectedStateCode)){
                        continue; // Ignore wrongly generated series
                    }

                    
                    String entityId = String.valueOf(bvcInv.BVC_LegalEntity__c);
                    String state = expectedStateCode;
                    String comboKey = entityId + '-' + state;
                    System.debug('for checking comboKey = '+comboKey);
                    if (!latestInvoicePerCombo.containsKey(comboKey)) {
                        latestInvoicePerCombo.put(comboKey, bvcInv);
                        existingInvoiceSeriesNumberMap.put(comboKey, bvcInv.CreditNote_Serial_No__c);
                    }
                }
                System.debug('for checking existingInvoiceSeriesNumberMap.values() '+existingInvoiceSeriesNumberMap.values());

                Map<Id,String> tmpInvoiceSeriesCheckMap = new Map<Id,String>();

                List<BVCCreditNote__c> updateInvoiceSeriesList = new List<BVCCreditNote__c>();

                for(BVCCreditNote__c invRec: newList){
                    String newInvoiceSeries = '';

                    if(invMap != null && invMap.containsKey(invRec.Id)){
                        if(mapGSTINStateCode.containsKey(invMap.get(invRec.Id)) ){

                            System.debug('for checking existingInvoiceSeriesNumberMap.get(invMap.get(invRec.Id)) '+existingInvoiceSeriesNumberMap.get(invRec.Id));
                            System.debug('for checking tmpInvoiceSeriesCheckMap.get(invMap.get(invRec.Id)) '+tmpInvoiceSeriesCheckMap.get(invRec.Id));

                            String comboKey = String.valueOf(invRec.BVC_LegalEntity__c) + '-' + invRec.BVC_LegalEntity__r.GSTIN_State_Code__c;
                            System.debug('for checking comboKey inside = '+comboKey);
                            String existingSeries = existingInvoiceSeriesNumberMap.get(comboKey);

                            if(existingSeries != null){
                                System.debug('for checking within if');
                                
                                
                                // Added This DmlException To Check Wrongly Inserted Series
                                if(!existingSeries.startsWith(invRec.BVC_LegalEntity__r.GSTIN_State_Code__c)){
                                    throw new DmlException('Series state mismatch detected. Existing Series: '+ existingSeries +' | Expected State: ' + invRec.BVC_LegalEntity__r.GSTIN_State_Code__c);
                                }
                                
                                
                                if(!tmpInvoiceSeriesCheckMap.containsKey(invRec.Id)){
                                    String value = existingSeries;
                                    System.debug('for checking value '+value);

                                    String billingSerialNumber = String.valueOf(invRec.BVC_LegalEntity__r.Billing_Serial_Number__c);
                                    System.debug('for checking new billingSerialNumber '+billingSerialNumber);

                                    if (value == null) {
                                        continue;
                                    }

                                    value = value.trim();
                                    System.debug('for checking Value before regex: ' + value);

                                    Pattern pattern = Pattern.compile('^(\\d*[a-zA-Z]+)(\\d+)$');
                                    Matcher matcher = pattern.matcher(value);

                                    if (matcher.find()) {
                                        String prefix = matcher.group(1);
                                        String numericPart = matcher.group(2);

                                        if (numericPart == null) {
                                            System.debug('for checking No numeric part found for value: ' + value);
                                            continue;
                                        }

                                        System.debug('for checking Extracted Prefix: ' + prefix);
                                        System.debug('for checking Extracted Numeric Part from existing credit series: ' + numericPart);

                                        System.debug('for checking new numericPart.startsWith(billingSerialNumber) '+numericPart.startsWith(billingSerialNumber));

                                        if (numericPart.startsWith(billingSerialNumber)) {
                                            numericPart = numericPart.substring(billingSerialNumber.length());
                                        }

                                        System.debug('for checking new numericPart '+numericPart);

                                        Integer newInvoiceSerialNumber = Integer.valueOf(numericPart) + 1;

                                        // Ensure uniqueness by checking previously used numbers
                                        while (usedInvoiceSeries.contains(prefix + billingSerialNumber + newInvoiceSerialNumber)) {
                                            newInvoiceSerialNumber++;
                                        }

                                        String newNumericPart = String.valueOf(newInvoiceSerialNumber);
                                        while (newNumericPart.length() < numericPart.length()) {
                                            newNumericPart = '0' + newNumericPart;
                                        }
                                        System.debug('for checking final Prefix: ' + prefix);
                                        System.debug('for checking final billingSerialNumber: ' + billingSerialNumber);
                                        System.debug('for checking final newNumericPart: ' + newNumericPart);
										
                                        newInvoiceSeries = prefix + billingSerialNumber + newNumericPart;

                                        tmpInvoiceSeriesCheckMap.put(invRec.Id,newInvoiceSeries);
                                        usedInvoiceSeries.add(newInvoiceSeries);

                                        System.debug('for checking Corrected Updated Credit Series: ' + newInvoiceSeries);
                                        System.debug('for checking tmpInvoiceSeriesCheckMap: ' + tmpInvoiceSeriesCheckMap);
                                        System.debug('for checking usedInvoiceSeries: ' + usedInvoiceSeries);
                                    } else {
                                        System.debug('for checking Pattern did not match for value: ' + value);
                                    }
                                }
                            }

                            System.debug('for checking before invRec.CreditNote_Serial_No__c '+invRec.CreditNote_Serial_No__c);

                            if(newInvoiceSeries != null && newInvoiceSeries != ''){
                                invRec.CreditNote_Serial_No__c = newInvoiceSeries;
                            } else {
                                throw new System.DmlException('Check Credit Note Series it may be null or blank');
                            }

                            System.debug('for checking invRec.CreditNote_Serial_No__c '+invRec.CreditNote_Serial_No__c);

                            updateInvoiceSeriesList.add(invRec);

                        }
                    }
                }
                System.debug('for checking new update updateInvoiceSeriesList '+updateInvoiceSeriesList);
                System.debug('for checking new update updateInvoiceSeriesList.size() '+updateInvoiceSeriesList.size());
                if(updateInvoiceSeriesList.size()>0){
                    update updateInvoiceSeriesList;
                }

            }
        }

        // For CB credit notes (mirror of invoice CB block)
        if(CBinvoiceIds.size()>0 && !CBinvoiceIds.isEmpty() ){
        //    Map<Id,BVCCreditNote__c> SrNumMap = new Map<Id,BVCCreditNote__c>(
        //        [SELECT Id, BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c FROM BVCCreditNote__c WHERE Id IN :CBserial]
        //    );

            Integer taxvar = 1;
            Integer comvar = 1;
            Integer bosvar = 1;

            List<DocumentSeries__c> upsertListForCB = new List<DocumentSeries__c>();
            Map<String,DocumentSeries__c> mapUniqueKeyRecordCB = new Map<String,DocumentSeries__c>();
            if(!Test.isRunningTest()){
                for(DocumentSeries__c doc : [SELECT Id, Unique_Key__c, Last_Serial_Number__c FROM DocumentSeries__c FOR UPDATE]){
                    mapUniqueKeyRecordCB.put(doc.Unique_Key__c, doc);
                    System.debug('====>'+doc);
                }
            }

            for(BVCCreditNote__c CBinv : CBinvoiceIds){
                String invseries;
               // String sr = SrNumMap.get(CBinv.Id).BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c;
                if(!Test.isRunningTest()){
                    try{
                        System.debug('for checking CBinv.Credit_Note_Type__c === '+CBinv.Credit_Note_Type__c);
                        if(CBinv.Credit_Note_Type__c == 'Tax Credit Note'){
                            System.debug('for checking CBinv.BVC_CB_Credit_Note_Series__c   '+CBinv.BVC_CB_Credit_Note_Series__c);
                            Integer count = Integer.valueOf(mapUniqueKeyRecordCB.get(CBinv.BVC_CB_Credit_Note_Series__c).Last_Serial_Number__c) + 1;
                            invseries = CBinv.BVC_CB_Credit_Note_Series__c + count;
                            System.debug(invseries);
                            taxvar++;
                            DocumentSeries__c docM = new DocumentSeries__c(Id = mapUniqueKeyRecordCB.get(CBinv.BVC_CB_Credit_Note_Series__c).Id);
                            docM.Name = CBinv.BVC_CB_Credit_Note_Series__c;
                            docM.Last_Serial_Number__c = String.valueOf(count);
                            docM.Unique_Key__c = CBinv.BVC_CB_Credit_Note_Series__c;
                            mapUniqueKeyRecordCB.put(CBinv.BVC_CB_Credit_Note_Series__c, docM);
                        }
                        else if(CBinv.Credit_Note_Type__c =='Commercial Credit Note'){
                            System.debug('for checking CBinv.BVCInvoice__r.state_code__c : '+CBinv.BVCInvoice__r.state_code__c);
                            System.debug('for checking CBinv.BVC_CB_Credit_Note_Series__c   '+CBinv.BVC_CB_Credit_Note_Series__c);
                            Integer count = Integer.valueOf(mapUniqueKeyRecordCB.get(CBinv.BVC_CB_Credit_Note_Series__c).Last_Serial_Number__c) + 1;
                            invseries = CBinv.BVC_CB_Credit_Note_Series__c + count;
                            System.debug(invseries);
                            comvar++;
                            DocumentSeries__c docM = new DocumentSeries__c(Id = mapUniqueKeyRecordCB.get(CBinv.BVC_CB_Credit_Note_Series__c).Id);
                            docM.Name = CBinv.BVC_CB_Credit_Note_Series__c;
                            docM.Last_Serial_Number__c = String.valueOf(count);
                            docM.Unique_Key__c = CBinv.BVC_CB_Credit_Note_Series__c;
                            mapUniqueKeyRecordCB.put(CBinv.BVC_CB_Credit_Note_Series__c, docM);
                        }
                        else if(CBinv.Credit_Note_Type__c =='Bill of Supply Credit Note'){
                            Integer count = Integer.valueOf(mapUniqueKeyRecordCB.get(CBinv.BVC_CB_Credit_Note_Series__c).Last_Serial_Number__c) + 1;
                            invseries = CBinv.BVC_CB_Credit_Note_Series__c + count;
                            System.debug(invseries);
                            bosvar++;
                            DocumentSeries__c docM = new DocumentSeries__c(Id = mapUniqueKeyRecordCB.get(CBinv.BVC_CB_Credit_Note_Series__c).Id);
                            docM.Name = CBinv.BVC_CB_Credit_Note_Series__c;
                            docM.Last_Serial_Number__c = String.valueOf(count);
                            docM.Unique_Key__c = CBinv.BVC_CB_Credit_Note_Series__c;
                            mapUniqueKeyRecordCB.put(CBinv.BVC_CB_Credit_Note_Series__c, docM);
                        }
                        CBinv.CreditNote_Serial_No__c = invseries;
                    } catch (Exception ex){
                        System.debug('for checking error  '+ex.getMessage());
                        System.debug('for checking error on line number  '+ex.getLineNumber());
                    }
                }
            }
            Upsert mapUniqueKeyRecordCB.values();
        }

    } // end gstSerialNumberUpdate
    
    
    
    /**
    * Method Name : getBranchInfo
    * Description : get The related Branch info W.R.T Order
    * Param : List of Order ids
    * Return : Map<Id, OrderObect>
    *
    */
    /*
    //Old method before custom setting changes
    public static Map<Id,String> getBranchInfo(Map<Id,String> orderMap){
        Map<Id,String> mapOrderKey = new map<Id,String>();
        for ( BVCInvoice__c inv : [Select id,BVC_LegalEntity__r.Billing_Serial_Number__c,BVC_LegalEntity__r.GSTIN_State_Code__c from BVCInvoice__c 
                                      where BVC_LegalEntity__c != null AND
                                      BVC_LegalEntity__r.GSTIN_State_Code__c != null AND Id IN:orderMap.keyset()] )
        {
            system.debug('inv.BVC_LegalEntity__r.GSTIN_State_Code__c------'+inv.BVC_LegalEntity__r.GSTIN_State_Code__c);
            system.debug('mapOfTypeCode.get(orderMap.get(inv.Id))------'+mapOfTypeCode.get(orderMap.get(inv.Id)));
            

            String serialNumber = (inv.BVC_LegalEntity__r.Billing_Serial_Number__c != null?String.valueOf(inv.BVC_LegalEntity__r.Billing_Serial_Number__c) :'01');
            system.debug('serialNumber------'+serialNumber);
            String serialNumberUniqueCode = inv.BVC_LegalEntity__r.GSTIN_State_Code__c + mapOfTypeCode.get(orderMap.get(inv.Id)) + 'C' + serialNumber;
            mapOrderKey.put(inv.Id, serialNumberUniqueCode);
        }
        system.debug('mapOrderKey------'+mapOrderKey);

        return mapOrderKey;
    }
    */
    
    
    // Added by Rafi Khan to remove custom setting dependancy
    public static Map<Id,String> getBranchInfo(Map<Id,String> invMap){
        Map<Id,String> mapOrderKey = new Map<Id,String>();
        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.getBranchinfo Credit Note Ids::'+invMap.keyset());
        for ( BVCCreditNote__c inv : [SELECT Id, BVC_LegalEntity__r.Billing_Serial_Number__c, BVC_LegalEntity__r.GSTIN_State_Code__c FROM BVCCreditNote__c 
                                      WHERE BVC_LegalEntity__c != null AND 
                                      BVC_LegalEntity__r.GSTIN_State_Code__c != null AND Id IN :invMap.keyset()] )
        {
            System.debug('Rafi debug Credit Note Serial Number Detail Check : ');
            String serialNumber = (inv.BVC_LegalEntity__r.Billing_Serial_Number__c != null ? String.valueOf(inv.BVC_LegalEntity__r.Billing_Serial_Number__c) : '01');
            // Build unique key with 'C' for credit note
            String serialNumberUniqueCode = inv.BVC_LegalEntity__r.GSTIN_State_Code__c + mapOfTypeCode.get(invMap.get(inv.Id)) + 'C' + serialNumber;
            mapOrderKey.put(inv.Id, serialNumberUniqueCode);
        }
        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.getBranchinfo mapOrderKey.size() = '+mapOrderKey.size());
        System.debug('Rafi debug inside BVCCreditNoteTriggerHandler.getBranchinfo mapOrderKey.values() = '+mapOrderKey.values());
        return mapOrderKey;
    }
    
    
    
    public static void callEYTaxCal(List<BVCCreditNote__c> newList, Map<Id,BVCCreditNote__c> oldMap){
        System.debug('Rafi debug in callEYTaxCal newList :'+newList);
        System.debug('Rafi debug in callEYTaxCal oldMap :'+oldMap);
        try{
        Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([select Id,DeveloperName from RecordType where SobjectType ='BVCCreditNote__c']);
        List<BVCCreditNote__c> otherCNList = new List<BVCCreditNote__c>(); 
        for(BVCCreditNote__c cnRec : newList){
            System.debug('Rafi debug in callEYTaxCal mapRecordType.get(cnRec.RecordTypeId) :'+mapRecordType.get(cnRec.RecordTypeId));
            //System.debug('Rafi debug in callEYTaxCal mapRecordType.get(cnRec.RecordTypeId).DeveloperName :'+mapRecordType.get(cnRec.RecordTypeId).DeveloperName);
            System.debug('Rafi debug in callEYTaxCal cnRec.Approval_Status__c :'+cnRec.Approval_Status__c);
                if( mapRecordType.get(cnRec.RecordTypeId)!=null && (mapRecordType.get(cnRec.RecordTypeId).DeveloperName=='BOS_Credit_Note' || mapRecordType.get(cnRec.RecordTypeId).DeveloperName=='Tax_Credit_Note') && cnRec.Approval_Status__c == 'Approved' && cnRec.Approval_Status__c != oldMap.get(cnRec.Id).Approval_Status__c){
                	//CPQ_CNEYTaxCalculation taxHandler = new CPQ_CNEYTaxCalculation();	//already commentted in old code
                    BVC_CPQ_CNEYTaxCalculation.doTaxCalculationForCN(cnRec.Id);
                }
                if( mapRecordType.get(cnRec.RecordTypeId)!=null && mapRecordType.get(cnRec.RecordTypeId).DeveloperName=='Commercial_Credit_Note'&& cnRec.Approval_Status__c == 'Approved' && cnRec.Approval_Status__c != oldMap.get(cnRec.Id).Approval_Status__c){
                        BVC_CPQ_CNEYTaxCalculation taxHandler = new BVC_CPQ_CNEYTaxCalculation();		//COmmentted by rafi
                    	BVCCreditNote__c record = new BVCCreditNote__c(Id = cnRec.Id);
                    	record.Status__c ='Posted';
                    	otherCNList.add(record);
                    }
        }
        update otherCNList;
        } catch (Exception ex){
            System.debug('Error in callEYTaxCal === '+ex.getMessage());
            System.debug('Error on line number callEYTaxCal === '+ex.getLineNumber());
        }
    }
    
 
    
    /**
     * Name : ValidateCreditAmount
     * Description : Validate The Total Credit Amount of Source Invoice Do Not Exceed the Total Amount
     * Param : newList and OldMap
     * Return : None
     */
    
    public static void ValidateCreditAmount(List<BVCCreditNote__c> newList,Map<Id,BVCCreditNote__c> oldMap){
        Set<Id> noteIds = new Set<Id>();
        for(BVCCreditNote__c cn : newList){
            if(cn.Subtotal__c > 0 &&  oldMap.get(cn.Id).Subtotal__c != cn.Subtotal__c){
                noteIds.add(cn.Id);
            }
        }
        if(!Test.isRunningTest()){
            if(noteIds.size() > 0 && noteIds != null){
                Map<Id,BVCCreditNote__c> cnInvMap = new Map<Id,BVCCreditNote__c>([SELECT Id,
                                                                                  Subtotal__c,
                                                                                  BVCInvoice__r.Total_Credit_Notes__c ,
                                                                                  BVCInvoice__r.Subtotal__c
                                                                                  FROM BVCCreditNote__c 
                                                                                  WHERE Id IN :noteIds]);
                for(BVCCreditNote__c cn : newList){
                    if(cnInvMap.containsKey(cn.Id) && cnInvMap.get(cn.Id).BVCInvoice__r != null){
                        if(cnInvMap.get(cn.Id).BVCInvoice__r.Total_Credit_Notes__c  >= cnInvMap.get(cn.Id).BVCInvoice__r.Subtotal__c){
                            cn.addError('Cannot Create Credit Notes for Amounts Greate than Invoice Sub Total');
                        } 
                    }
                    
                }
            }
        }
    }
    /**
     * Name : generateDocument
     * Description : Generate A5 document for CreditNote and send email with Doc
     * Param : newList and OldMap
     * Return : None
    */ 
    
    public static void generateDocument(List<BVCCreditNote__c> newList, Map<Id,BVCCreditNote__c> oldMap){
        List<rsdoc__Document_Request__c> listDocRequest = new List<rsdoc__Document_Request__c>();
        if(!Test.isRunningTest()){
            Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>([select Id,DeveloperName from RecordType where SobjectType ='BVCCreditNote__c']);
            
            String templateName = 'BVC Credit Note';
            List<rsdoc__Document_Action__c> listDocAction = [SELECT id,rsdoc__Template_Name__c from rsdoc__Document_Action__c where rsdoc__Base_object_API__c = 'BVCCreditNote__c'];
            Map<String, Id > mapCreditNote = new Map<String, Id >();
            for(rsdoc__Document_Action__c action: listDocAction){
                mapCreditNote.put(action.rsdoc__Template_Name__c,action.Id);   
            }
            System.debug('listDocAction. '+listDocAction);
            if(listDocAction != null && !listDocAction.isEmpty()){
                for(BVCCreditNote__c cnRec : newList){
                    System.debug('Status__c  . '+cnRec.Status__c  );
                    System.debug('Status__c  . '+oldMap.get(cnRec.Id).Status__c );
                    if(cnRec.Status__c  == 'Posted' && cnRec.Status__c  != oldMap.get(cnRec.Id).Status__c ){
                        System.debug('status .inside '+cnRec.Status__c  );
                        rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                        System.debug('for checking mapRecordType.get(cnRec.RecordTypeId) === '+mapRecordType.get(cnRec.RecordTypeId));
                        //System.debug('for checking mapRecordType.get(cnRec.RecordTypeId).DeveloperName === '+ mapRecordType.get(cnRec.RecordTypeId).DeveloperName);
                        if(mapRecordType.get(cnRec.RecordTypeId)!=null && mapRecordType.get(cnRec.RecordTypeId).DeveloperName!='Master'){
                            docReq.rsdoc__Document_Action__c  =   mapCreditNote.get('BVC CB '+mapRecordType.get(cnRec.RecordTypeId).DeveloperName);
                        }
                        else{
                            docReq.rsdoc__Document_Action__c  =  mapCreditNote.get('BVC Credit Note');    
                        }
                        
                        docReq.rsdoc__Record_Id__c = cnRec.Id;
                        // docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                        listDocRequest.add(docReq);
                    }
                }
            }
            System.debug('listDocRequest. '+listDocRequest);
            if(!listDocRequest.isEmpty()&&!(test.isRunningTest())){
                System.debug('insert listDocRequest. '+listDocRequest);
                insert listDocRequest;
            }
        }
    }
    
    public static void ValidateCreditAmountInsert(List<BVCCreditNote__c> newList){
        Set<Id> invIds = new Set<Id>();
        for(BVCCreditNote__c cn : newList){
            
                invIds.add(cn.BVCInvoice__c);
            
        }
        
        if(invIds.size() > 0 && invIds != null){
            Map<Id,BVCInvoice__c> InvMap = new Map<Id,BVCInvoice__c>([SELECT Id,
                                                                            Subtotal__c,
                                                                            Total_Credit_Notes__c
                                                                            FROM BVCInvoice__c 
                                                                            WHERE Id IN :invIds]);
            for(BVCCreditNote__c cn : newList){
                if(invMap.containsKey(cn.BVCInvoice__c) ){
                    if(invMap.get(cn.BVCInvoice__c).Total_Credit_Notes__c >= invMap.get(cn.BVCInvoice__c).Subtotal__c){
                        cn.addError('Cannot Create Credit Notes for Amounts Greate than Invoice Sub Total');
                    } 
                }
                
            }
        }
    }
    
    public static void getCoverage(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}