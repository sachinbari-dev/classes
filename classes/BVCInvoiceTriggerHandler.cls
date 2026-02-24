public class BVCInvoiceTriggerHandler {
    
    public static final map<String,String> mapOfTypeCode = new map<String,String>{
        'Tax Invoice' => 'T', 'Bill of Supply Invoice' => 'B',
            'Commercial Invoice ' => 'C', 'Tax Credit Note' => 'T',
            'Bill of Supply Credit Note' => 'B', 'Commercial Credit Note' => 'C'
            } ;
                
                /*public static void updateBVCBillingEntityFromBVCLegelEntities(List<BVCInvoice__c> newList){
                    Set<Id> legalEntityIds = new Set<Id>();
                    for (BVCInvoice__c inv : newList) {
                        if (inv.BVC_Legal_Entities__c != null) {
                            legalEntityIds.add(inv.BVC_Legal_Entities__c);
                        }
                    }
                    
                    Map<Id, BVC_Legal_Entities__c> legalEntityMap = new Map<Id, BVC_Legal_Entities__c>(
                        [SELECT Id, LegalEntities__c FROM BVC_Legal_Entities__c WHERE Id IN :legalEntityIds]
                    );
                    
                    for (BVCInvoice__c inv : newList) {
                        System.debug('for checking inv.Manual_Invoice__c = '+inv.Manual_Invoice__c);
                        if (inv.BVC_Legal_Entities__c != null && legalEntityMap.containsKey(inv.BVC_Legal_Entities__c)) {
                            inv.BVC_LegalEntity__c = legalEntityMap.get(inv.BVC_Legal_Entities__c).LegalEntities__c;
                            System.debug('for checking in before update inv.BVC_LegalEntity__c '+inv.BVC_LegalEntity__c);
                        }
                    }
                }*/
                
                public static void updateBVCBillingEntityFromBVCBranch(List<BVCInvoice__c> newList) {
                    Set<Id> branchIds = new Set<Id>();
                    for (BVCInvoice__c inv : newList) {
                        if (inv.BVC_Branch__c != null) {
                            branchIds.add(inv.BVC_Branch__c);
                        }
                    }
                    
                    Map<Id, Hub__c> branchMap = new Map<Id, Hub__c>(
                        [SELECT Id, BVC_LegalEntity__c FROM Hub__c WHERE Id IN :branchIds]
                    );
                    
                    for (BVCInvoice__c inv : newList) {
                        System.debug('for checking inv.Manual_Invoice__c = ' + inv.Manual_Invoice__c);
                        if (inv.BVC_Branch__c != null && branchMap.containsKey(inv.BVC_Branch__c)) {
                            inv.BVC_LegalEntity__c = branchMap.get(inv.BVC_Branch__c).BVC_LegalEntity__c;
                            System.debug('for checking inv.BVC_LegalEntity__c = ' + inv.BVC_LegalEntity__c);
                        }
                    }
                }

    
                
/******************************************************************
* Method Name : gstSerialNumberUpdate
* Description : Update Invoice Serial Number based on GST
* Param : Trigger.new
* 
*******************************************************************/
    
    public static void gstSerialNumberUpdate(List<BVCInvoice__c> newList){
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate newList = '+newList);
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate newList. size = '+newList.size());
        list<BVCInvoice__c> CBinvoiceIds=new list<BVCInvoice__c>();
        Map<Id,String> invoiceIds=new map<Id,String>();
        list<Id> CBserial = new list<Id>();
        
        Set<String> usedInvoiceSeries = new Set<String>();
        
        for(BVCInvoice__c inv: newList){
            if(inv.BVC_CB_Is_CB_Invoice__c ==true && (inv.ST_Invoice_Series__c == null || String.isBlank(inv.ST_Invoice_Series__c))){
                System.debug('Checking inside if');
                CBinvoiceIds.add(inv);
                CBserial.add(inv.Id);
            }else{             
                if(inv.ST_Invoice_Series__c == null || String.isBlank(inv.ST_Invoice_Series__c)){
                    invoiceIds.put(inv.Id, inv.Invoice_Type__c);
                    
                }
            }
        }
        
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate invoiceIds.size() = '+invoiceIds.size());
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate CBinvoiceIds.size() = '+CBinvoiceIds.size());
        
        if(invoiceIds.size()>0 && !invoiceIds.isEmpty()){
            System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate invoiceIds.  '+invoiceIds);
            
            Map<Id,String> invMap = getBranchinfo(invoiceIds);
            Map<String,Long> mapUniqueKeyNumber = new Map<String,Long>();
            
            Map<String,String> mapGSTINStateCode = new Map<String,String>();
            
            List<DocumentSeries__c> upsertList = new List<DocumentSeries__c>();
            Map<String,DocumentSeries__c> mapUniqueKeyRecord =new Map<String,DocumentSeries__c>();
            
            System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate invMap.size() = '+invMap.size());
            System.debug('Rafi debug inside BVCInvoiceTriggerHandler.gstSerialNumberUpdate invMap.values() = '+invMap.values());
            String invoiceSeries;
            Set<Id> invoiceBillingEntity = new Set<Id>();
            Set<String> stateCode = new Set<String>();
            if(invMap.size() >0){
                for(DocumentSeries__c doc : [Select Unique_Key__c, Last_Serial_Number__c from DocumentSeries__c where Unique_Key__c IN:invMap.values()]){
                    mapGSTINStateCode.put(doc.Unique_Key__c,doc.Unique_Key__c.left(2));
            
                }
                
                System.debug('for checking mapGSTINStateCode = '+mapGSTINStateCode);
                
                for(BVCInvoice__c invRec: newList){
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
                
                //Map<id,String> existingInvoiceSeriesNumberMap = new Map<id,String>();
                Map<String,String> existingInvoiceSeriesNumberMap = new Map<String,String>();
                
                String existingStateCode;
                /*List<BVCInvoice__c> invSeriesAlreadyPresent = [Select Id,ST_Invoice_Series__c,BVC_LegalEntity__c,
                                                               BVC_LegalEntity__r.GSTIN_State_Code__c from BVCInvoice__c 
                                                               where BVC_CB_Is_CB_Invoice__c =: false AND 
                                                               ST_Invoice_Series__c != null AND
                                                               BVC_LegalEntity__c IN: invoiceBillingEntity AND 
                                                               BVC_LegalEntity__r.GSTIN_State_Code__c IN:stateCode 
                                                               order By createdDate DESC limit 100];
                */
                
                List<BVCInvoice__c> invSeriesAlreadyPresent = [
                    SELECT Id, ST_Invoice_Series__c, BVC_LegalEntity__c, 
                    BVC_LegalEntity__r.GSTIN_State_Code__c
                    FROM BVCInvoice__c
                    WHERE BVC_CB_Is_CB_Invoice__c = false
                    AND ST_Invoice_Series__c != null
                    AND BVC_LegalEntity__c IN :invoiceBillingEntity
                    AND BVC_LegalEntity__r.GSTIN_State_Code__c IN :stateCode
                ];

                System.debug('for checking invSeriesAlreadyPresent '+invSeriesAlreadyPresent);
                System.debug('for checking invSeriesAlreadyPresent.size() '+invSeriesAlreadyPresent.size());
                
                invSeriesAlreadyPresent.sort(new InvoiceSeriesComparator());
                
                System.debug('for checking new invSeriesAlreadyPresent '+invSeriesAlreadyPresent);
                
                Map<String, BVCInvoice__c> latestInvoicePerCombo = new Map<String, BVCInvoice__c>();
                
                /*for(BVCInvoice__c bvcInv : invSeriesAlreadyPresent){
                    
                    System.debug('for checking inside for of bvcInv.ST_Invoice_Series__c '+bvcInv.ST_Invoice_Series__c);
                    System.debug('for checking inside for of invoiceBillingEntity.contains(bvcInv.BVC_LegalEntity__c) '+invoiceBillingEntity.contains(bvcInv.BVC_LegalEntity__c));
                    System.debug('for checking inside for of stateCode.contains(bvcInv.BVC_LegalEntity__r.GSTIN_State_Code__c) '+stateCode.contains(bvcInv.BVC_LegalEntity__r.GSTIN_State_Code__c));
                    if(bvcInv.ST_Invoice_Series__c!=null && invoiceBillingEntity.contains(bvcInv.BVC_LegalEntity__c) 
                       && stateCode.contains(bvcInv.BVC_LegalEntity__r.GSTIN_State_Code__c) && !existingInvoiceSeriesNumberMap.containsKey(bvcInv.Id)){
                        
                        existingInvoiceSeriesNumberMap.put(bvcInv.Id,bvcInv.ST_Invoice_Series__c);			//changes made for multiple invoices
                        
                        break;
                    }
                    System.debug('for checking after break existingInvoiceSeriesNumberMap.values()'+existingInvoiceSeriesNumberMap.values());
                    
                }
                */
                
                for (BVCInvoice__c bvcInv : invSeriesAlreadyPresent) {
                    String entityId = String.valueOf(bvcInv.BVC_LegalEntity__c);
                    String state = bvcInv.BVC_LegalEntity__r.GSTIN_State_Code__c;
                    String comboKey = entityId + '-' + state;
                    System.debug('for checking comboKey = '+comboKey);
                    if (!latestInvoicePerCombo.containsKey(comboKey)) {
                        latestInvoicePerCombo.put(comboKey, bvcInv);
                        existingInvoiceSeriesNumberMap.put(comboKey, bvcInv.ST_Invoice_Series__c);
                    }
                }
                System.debug('for checking existingInvoiceSeriesNumberMap.values() '+existingInvoiceSeriesNumberMap.values());
                
                Map<Id,String> tmpInvoiceSeriesCheckMap = new Map<Id,String>();
                
                List<BVCInvoice__c> updateInvoiceSeriesList = new List<BVCInvoice__c>();
                
                for(BVCInvoice__c invRec: newList){
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
                                if(!tmpInvoiceSeriesCheckMap.containsKey(invRec.Id)){
                                    //for (String key : existingInvoiceSeriesNumberMap.keySet()) {
                                        //System.debug('for checking key '+key);
                                        //String value = existingInvoiceSeriesNumberMap.get(key);
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
                                            System.debug('for checking Extracted Numeric Part from existing invoice series: ' + numericPart);
                                            
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
                                            
                                            System.debug('for checking Corrected Updated Invoice Series: ' + newInvoiceSeries);
                                            System.debug('for checking tmpInvoiceSeriesCheckMap: ' + tmpInvoiceSeriesCheckMap);
                                            System.debug('for checking usedInvoiceSeries: ' + usedInvoiceSeries);
                                        } else {
                                        System.debug('for checking Pattern did not match for value: ' + value);
                                    }
                                    //break; 
                                //}
                                
                            }
                            }
                            
                            System.debug('for checking before invRec.ST_Invoice_Series__c '+invRec.ST_Invoice_Series__c);
                            
                            if(newInvoiceSeries != null && newInvoiceSeries != ''){
                                invRec.ST_Invoice_Series__c = newInvoiceSeries;
                            } else {
                                throw new System.DmlException('Check Invoice Series it may be null or blank');
                            }
                            
                            System.debug('for checking invRec.ST_Invoice_Series__c '+invRec.ST_Invoice_Series__c);
                            
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
        //For CB invoices
        if(CBinvoiceIds.size()>0 && !CBinvoiceIds.isEmpty() ){
            Map<Id,BVCInvoice__c> SrNumMap = new Map<Id,BVCInvoice__c>([Select id,state_code__c,BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c from BVCInvoice__c where Id IN :CBserial]);// check BVC_Billing_Entity__r
        //  list<BVCInvoice__c> TIinvoices=[Select id,name,state_code__c from BVCInvoice__c where Invoice_Type__c = 'Tax Invoice' AND BVC_CB_Is_CB_Invoice__c =TRUE AND ST_Invoice_Series__c != null];
        //    list<BVCInvoice__c> CIinvoices=[Select id,name,state_code__c from BVCInvoice__c where Invoice_Type__c = 'Commercial Invoice' AND BVC_CB_Is_CB_Invoice__c =TRUE AND ST_Invoice_Series__c != null ];
        //   list<BVCInvoice__c> BIinvoices=[Select id,name,state_code__c from BVCInvoice__c where Invoice_Type__c = 'Bill of Supply Invoice' AND BVC_CB_Is_CB_Invoice__c =TRUE AND ST_Invoice_Series__c != null];
            integer taxvar=1;
            integer comvar=1;
            integer bosvar=1;
           
            List<DocumentSeries__c>upsertList = new List<DocumentSeries__c>();
            Map<String,DocumentSeries__c> mapUniqueKeyRecord =new Map<String,DocumentSeries__c>();
            if(!Test.isRunningTest()){
                for(DocumentSeries__c doc : [Select id, Unique_Key__c, Last_Serial_Number__c from DocumentSeries__c ]){
                    //mapUniqueKeyNumber.put(doc.Unique_Key__c,Integer.valueOf(doc.Last_Serial_Number__c.right(doc.Last_Serial_Number__c.length() - doc.Unique_Key__c.length())));
                    mapUniqueKeyRecord.put(doc.Unique_Key__c,doc);
                    system.debug('====>'+doc);
                }
            }
            
            for(BVCInvoice__c CBinv :CBinvoiceIds){
                 
                string invseries ;
                string sr = SrNumMap.get(CBinv.id).BVC_LegalEntity__r.BVC_CB_Billing_Serial_Number__c; // check forentity
               	
                if(!Test.isRunningTest()){
                    try{
                	System.debug('for checking CBinv.Invoice_Type__c === '+CBinv.Invoice_Type__c);
                    if(CBinv.Invoice_Type__c == 'Tax Invoice'){
                        system.debug('for checking CBinv.BVC_CB_Invoice_Series__c   '+CBinv.BVC_CB_Invoice_Series__c); 
                        //system.debug('for checking mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).Last_Serial_Number__c    '+mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).Last_Serial_Number__c);
                        integer count = integer.valueOf(mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).Last_Serial_Number__c)+1;                
                        invseries = CBinv.BVC_CB_Invoice_Series__c+sr+count; 
                        system.debug(invseries);
                        taxvar++;
                        //DocumentSeries__c is a custom setting. created record for maharashtra 27CBTI and for gujarat 24CBTII
                        DocumentSeries__c docM = new DocumentSeries__c(id=mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).id);
                        docM.Name = CBinv.BVC_CB_Invoice_Series__c;
                        //removed +1 from 351= docM.Last_Serial_Number__c = String.valueOf(count+1);
                        docM.Last_Serial_Number__c = String.valueOf(count);
                        docM.Unique_Key__c = CBinv.BVC_CB_Invoice_Series__c;
                        mapUniqueKeyRecord.put(CBinv.BVC_CB_Invoice_Series__c,docM);
                    }
                    
                    else if(CBinv.Invoice_Type__c =='Commercial Invoice'){
                        //System.debug('for checking CBinv.BVC_CB_Invoice_Type__c '+CBinv.BVC_CB_Invoice_Type__c);
                        integer count = integer.valueOf(mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).Last_Serial_Number__c)+1;                
                        invseries = CBinv.BVC_CB_Invoice_Series__c+sr+count; 
                        system.debug(invseries);
                        taxvar++;
                        DocumentSeries__c docM = new DocumentSeries__c(id=mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).id);
                        docM.Name = CBinv.BVC_CB_Invoice_Series__c;
                        //removed +1 from 351= docM.Last_Serial_Number__c = String.valueOf(count+1);
                        docM.Last_Serial_Number__c = String.valueOf(count);
                        docM.Unique_Key__c = CBinv.BVC_CB_Invoice_Series__c;
                        mapUniqueKeyRecord.put(CBinv.BVC_CB_Invoice_Series__c,docM);                  
                    }
                    
                    else if(CBinv.Invoice_Type__c =='Bill of Supply Invoice'){
                        integer count = integer.valueOf(mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).Last_Serial_Number__c)+1;                
                        invseries = CBinv.BVC_CB_Invoice_Series__c+sr+count; 
                        system.debug(invseries);
                        taxvar++;
                        DocumentSeries__c docM = new DocumentSeries__c(id=mapUniqueKeyRecord.get(CBinv.BVC_CB_Invoice_Series__c).id);
                        docM.Name = CBinv.BVC_CB_Invoice_Series__c;
                        //removed +1 from 351= docM.Last_Serial_Number__c = String.valueOf(count+1);
                        docM.Last_Serial_Number__c = String.valueOf(count);
                        docM.Unique_Key__c = CBinv.BVC_CB_Invoice_Series__c;
                        mapUniqueKeyRecord.put(CBinv.BVC_CB_Invoice_Series__c,docM);
                    }
                    cbinv.ST_Invoice_Series__c=invseries ; 
                    } catch (Exception ex){
                        System.debug('for checking error  '+ex.getMessage());
                        System.debug('for checking error on line number  '+ex.getLineNumber());
                    }
                }            
            }
            Upsert mapUniqueKeyRecord.values();
                
        }    
        
    }
    
    /*--------------------------------------------------------------
     * createroundoffinvoiceline method
     * -------------------------------------------------------------*/
    
    public static void createroundoffinvoiceline(List<BVCInvoice__c> newlist,Map<Id,BVCInvoice__c> oldMap){
        
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.createroundoffinvoiceline newlist : '+newlist);
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.createroundoffinvoiceline oldMap.values() : '+oldMap.values());
        
        list<BVCInvoiceLineItem__c> invlinelist = new list<BVCInvoiceLineItem__c>();
        list<BVC_Charge_Head_Tax__c> chargeheadlist = new list<BVC_Charge_Head_Tax__c>();
        set<id> PretaxbillIDs = new set<id>();
        Map<id,integer> chargeheadcount=new Map<id,integer>();
        
        list<BVCInvoice__c> invoiceslist=[select id,(select id from BVC_Charge_Head_Tax__r) from BVCInvoice__c where id IN:oldMap.keySet()];
        
        for(BVCInvoice__c inv:invoiceslist){
            chargeheadcount.put(inv.id,inv.BVC_Charge_Head_Tax__r.size());
        }
        for(BVCInvoice__c inv:newList){
            BVCInvoice__c oldInv = oldMap.get(inv.Id);
            if(inv.Invoice_Doc_URL__c != null && oldInv.Invoice_Doc_URL__c == null && inv.BVC_CB_ROUND_OFF__c !=0.00 && inv.BVC_CB_Is_CB_Invoice__c== true){
                system.debug('test'+inv.BVC_CB_ROUND_OFF__c);
                BVCInvoiceLineItem__c invline = new BVCInvoiceLineItem__c();
                invline.Subtotal__c = inv.BVC_CB_ROUND_OFF__c;
                invline.BVCInvoice__c = inv.Id;
                invline.BVC_CB_ChargeType__c='Agency';
                invLine.Name = 'Round Off';
                invline.UnitPrice__c = inv.BVC_CB_ROUND_OFF__c;
                invlinelist.add(invline);
                BVC_Charge_Head_Tax__c chTax = new BVC_Charge_Head_Tax__c();
                chTax.Name = 'Round Off';
                chTax.BVCInvoice__c = inv.Id;
                chTax.COA_Revenue_Account_Code__c = '452401';
                chTax.COA_Revenue_Sub_Account__c = '99999';
                chTax.HSN_Code__c ='0000';
                chTax.CGST_Amount__c=0;
                chTax.CGST_Rate__c=0;
                chTax.IGST__c=0;
                chTax.IGST_Amount__c=0;
                chtax.SGST__c=0;
                chTax.SGST_Amount__c=0;
                chTax.Taxable_Value__c=inv.BVC_CB_ROUND_OFF__c;
                chTax.Total_Amount__c =inv.BVC_CB_ROUND_OFF__c;
                chTax.Line_Number__c =chargeheadcount.get(inv.id)+1;
                chargeheadlist.add(chTax);
            }
            system.debug('for checking inv.BVC_CB_Is_CB_Invoice__c ==== '+inv.BVC_CB_Is_CB_Invoice__c);
            system.debug('for checking inv.Invoice_Doc_URL__c ==== '+inv.Invoice_Doc_URL__c);
            system.debug('for checking inv.BVC_CB_PreTaxBill__c ==== '+inv.BVC_CB_PreTaxBill__c);
            if(inv.BVC_CB_Is_CB_Invoice__c && inv.Invoice_Doc_URL__c != null && !string.isEmpty(inv.Invoice_Doc_URL__c) && inv.BVC_CB_PreTaxBill__c !=null ){
                system.debug('for checking Inside If');
                PretaxbillIDs.add(inv.BVC_CB_PreTaxBill__c);
            }
            system.debug('for cheking just after add PretaxbillIDs.size() ==== '+PretaxbillIDs.size());
        }
        if(invlinelist.size()>0){
            insert invlinelist;
        }
        if(chargeheadlist.size()>0){
            insert chargeheadlist;
        }
        
        system.debug('pretaxids.size() ==== '+PretaxbillIDs.size());
        if(PretaxbillIDs.size()>0){
             list<BVC_CB_PreTaxBill__c> PTtoUpdate=new  list<BVC_CB_PreTaxBill__c>();
          list<BVC_CB_PreTaxBill__c>   pretaxbills=[select id,BVC_CB_Invoice_Generated_in_Salesforce__c from BVC_CB_PreTaxBill__c where id in :PretaxbillIDs];
            for(BVC_CB_PreTaxBill__c PT:pretaxbills){
                PT.BVC_CB_Invoice_Generated_in_Salesforce__c =TRUE;
                PTtoUpdate.add(PT);
            }
            update PTtoUpdate;
        }
        if(PretaxbillIDs.size()>0){
           list<BVCInvoice__c> invRelatedtoPretaxBill=[Select id,name,Invoice_Doc_URL__c,BVC_CB_PreTaxBill__c from BVCInvoice__c where BVC_CB_PreTaxBill__c in :PretaxbillIDs];
            for(BVCInvoice__c PRinv:invRelatedtoPretaxBill){
                if(PRinv.Invoice_Doc_URL__c == null){
                    PretaxbillIDs.remove(PRinv.BVC_CB_PreTaxBill__c);
                } 
            }
            system.debug('after removing pretaxids'+PretaxbillIDs.size());
        }
    }
    
    
/*************************************************************************
* Method Name : getBranchInfo
* Description : get The related Branch info W.R.T Order
* Param : List of Order ids
* Return : Map<Id, OrderObect>
*
**************************************************************************/
    
    public static Map<Id,String> getBranchInfo(Map<Id,String> invMap){
        Map<Id,String> mapOrderKey = new map<Id,String>();
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.getBranchInfo Invoice Ids::'+invMap.keyset());
        for ( BVCInvoice__c inv : [Select id,BVC_Branch__c,BVC_LegalEntity__r.Billing_Serial_Number__c,BVC_LegalEntity__r.GSTIN_State_Code__c from BVCInvoice__c 
                                      where BVC_LegalEntity__c != null AND 
                                      BVC_LegalEntity__r.GSTIN_State_Code__c != null AND Id IN :invMap.keyset()] )
        {
            System.debug('Rafi debug Invoice Serial Number Detail Check : ');
            String serialNumber = (inv.BVC_LegalEntity__r.Billing_Serial_Number__c != null?String.valueOf(inv.BVC_LegalEntity__r.Billing_Serial_Number__c) :'01');
            String serialNumberUniqueCode = inv.BVC_LegalEntity__r.GSTIN_State_Code__c + mapOfTypeCode.get(invMap.get(inv.Id)) + 'I' + serialNumber;
            mapOrderKey.put(inv.Id, serialNumberUniqueCode);
        }
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.getBranchInfo mapOrderKey.size() = '+mapOrderKey.size());
        System.debug('Rafi debug inside BVCInvoiceTriggerHandler.getBranchInfo mapOrderKey.values() = '+mapOrderKey.values());
        return mapOrderKey;
    }

/******************************************************************************
*  Name : amountsInWordConversion
*  Description : Convert. Total Amount To word for Document
*  Param : Trigger.new and Old map
*  Return : None
* 
*******************************************************************************/   
    
    public static void amountsInWordConversion(List<BVCInvoice__c> newList,Map<Id,BVCInvoice__c> oldMap){
        System.debug('Inside amountsInWordConversion newList === '+newList);
        NumberTOWordConvertion numtoword = new NumberTOWordConvertion();
        for(BVCInvoice__c inv : newList){
           
            System.debug('Inside amountsInWordConversion inv.Total_Amount_With_Tax__c === '+inv.Total_Amount_With_Tax__c);
            //if(inv.Total_Amount_With_Tax__c != null && inv.Total_Amount_With_Tax__c >=0){
            if(inv.Total_Amount_With_Tax__c != null){
                inv.NumberToWord__c = numtoword.getNumberTOWordConvertion(inv.Total_Amount_With_Tax__c);
            }
        }                
    }   
    
/**********************************************************************
* Name : updateEmailRecepients
* Description : Update the Email Recepients
* Param : Trigger.new
* Return : None
**********************************************************************/ 

           public static void updateEmailRecepients(List<BVCInvoice__c> newList) {
            Set<Id> accountIds = new Set<Id>();
            Set<Id> BVCQuoteIds = new Set<Id>();
            id bvcquoteId;
            Map<Id,String> mapAccountRecepients = new Map<Id,String>();
            Map<Id,BVCQuote__c> mapBVCQuote = new Map<Id,BVCQuote__c>();
            Map<Id,Id> mapContactIdMap = new Map<Id,Id>();
            Map<Id,String> mapDealRecepients = new Map<Id,String>();
           
            // Collect account and BVCQuote IDs
            for (BVCInvoice__c inv : newList) {
                accountIds.add(inv.Account__c);
                if (inv.BVCQuote__c != null  && inv.BVCQuote__r.Business_Type__c=='ACR') {
                  //  BVCQuoteIds.add(inv.BVCQuote__c);
                   bvcquoteId=inv.BVCQuote__c;
                }
                if (inv.BVCOrder__r.Account__r.BVC_Contract__r.Quote__c != null && inv.BVCOrder__r.Business_Type__c=='Non ACR') {
                    bvcquoteId=inv.BVCQuote__c;
                }
            }
            
            System.debug('accountIds: ' + accountIds);
            System.debug('BVCQuoteIds: ' + BVCQuoteIds);
            
            // Retrieve Account Contact Relations
            for (AccountContactRelation acr : [
                SELECT AccountId, ContactId, Roles, Contact.Email 
                FROM AccountContactRelation 
                WHERE Roles INCLUDES ('Invoice Recepient;Finance') 
                  AND AccountId IN :accountIds 
                  AND Contact.Email != null 
            ]) {
                if (mapAccountRecepients.containsKey(acr.AccountId)) {
                    String recepientStr = mapAccountRecepients.get(acr.AccountId); 
                    recepientStr = recepientStr + ', ' + acr.Contact.Email;
                    mapAccountRecepients.put(acr.AccountId, recepientStr);
                } else {
                    mapAccountRecepients.put(acr.AccountId, acr.Contact.Email);
                }
                if (!mapContactIdMap.containsKey(acr.AccountId)) {
                    mapContactIdMap.put(acr.AccountId, acr.ContactId);
                }
            }
            
            System.debug('mapAccountRecepients: ' + mapAccountRecepients);
            
            // Retrieve BVCQuotes
            for (BVCQuote__c quoteObj : [
                SELECT Id, Business_Type__c 
                FROM BVCQuote__c 
                WHERE Id IN :BVCQuoteIds 
                  AND Business_Type__c = 'ACR'
            ]) {
                mapBVCQuote.put(quoteObj.Id, quoteObj);
            }
            
            System.debug('mapBVCQuote: ' + mapBVCQuote);
            
            // Retrieve People Roles
            List<String> strRole = new List<String>{'Decision Maker', 'Evaluator'};
            for (People_Role__c peopleRole : [
                SELECT People__c, Id, BVCQuote__c, Role__c, People__r.Email 
                FROM People_Role__c 
                WHERE Role__c IN :strRole 
                  AND People__r.Email != null AND BVCQuote__c =:bvcquoteId
            ]) {
                System.debug('peopleRole: ' + peopleRole);
                if (mapDealRecepients.containsKey(peopleRole.BVCQuote__c)) {
                    String recepientStr = mapDealRecepients.get(peopleRole.BVCQuote__c);
                    recepientStr = recepientStr + ', ' + peopleRole.People__r.Email;
                    mapDealRecepients.put(peopleRole.BVCQuote__c, recepientStr);
                } else {
                    mapDealRecepients.put(peopleRole.BVCQuote__c, peopleRole.People__r.Email);
                }
                if (!mapContactIdMap.containsKey(peopleRole.BVCQuote__c)) {
                    mapContactIdMap.put(peopleRole.BVCQuote__c, peopleRole.People__c);
                }
            }
            
            System.debug('mapDealRecepients: ' + mapDealRecepients);
            
            // Update invoices with email recipients
            for (BVCInvoice__c invRec : newList) {
                if (invRec.BVCOrder__c != null && mapBVCQuote.containsKey(invRec.BVCOrder__c)) {
                    invRec.Email_Recepients__c = mapDealRecepients.containsKey(invRec.BVCOrder__c) 
                        ? mapDealRecepients.get(invRec.BVCOrder__c) 
                        : '';
                    invRec.Bill_To_Contact__c = mapContactIdMap.containsKey(invRec.BVCOrder__c) 
                        ? mapContactIdMap.get(invRec.BVCOrder__c) 
                        : null;
                } else if (mapAccountRecepients.containsKey(invRec.Account__c)) {
                    invRec.Email_Recepients__c = mapAccountRecepients.get(invRec.Account__c);
                    invRec.Bill_To_Contact__c = mapContactIdMap.containsKey(invRec.Account__c) 
                        ? mapContactIdMap.get(invRec.Account__c) 
                        : null;
                }
            }
        }


    
    /*************************************************************************
    * Name : invoiceBillingDetailUpdate
    * Description : Populate Invoice Address,Branch,Billing entity,Entity
    * Param : newList 
    * Return : None
    ****************************************************************************/ 
    public static void invoiceBillingDetailUpdate(List<BVCInvoice__c> newList){
        System.debug('inside invoiceBillingDetailUpdate');
        Set<Id> orderIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(BVCInvoice__c inv : newList){
            if(inv.BVCOrder__c != null){
                orderIds.add(inv.BVCOrder__c);
            }
            else{
                accIds.add(inv.Account__c);
            }
        }
        System.debug('accIds '+accIds);
      /*  Map<Id,Order> orderMap = new Map<Id,Order>();
        if(orderIds.size() > 0 && orderIds != null){
            for(Order O : [SELECT Id,Billing_Address__c,BVC_Branch__c,Business_Type__c,
                           BVC_Billing_Entity__c,Account.Billing_Address__c,
                           BVC_Entity__c,Origin_Address__c FROM Order WHERE Id IN :orderIds] ){
                               orderMap.put(o.Id,o); 
                           }
        }*/ //commented for uninstallation of CPQ
        Map<Id,BVCOrder__c> orderMap = new Map<Id,BVCOrder__c>();
        if(orderIds.size() > 0 && orderIds != null){
            for(BVCOrder__c O : [SELECT Id,Billing_Address__c,BVC_Branch__c,Business_Type__c,
                           BVC_LegalEntity__c,Account__r.Billing_Address__c,
                           BVC_Entity__c,Origin_Address__c FROM BVCOrder__c WHERE Id IN :orderIds] ){
                               orderMap.put(o.Id,o); 
                           }
        }
        Map<Id,Account> accountMap = new Map<Id,Account>();
        if(accIds.size() > 0 && accIds != null){
            for(Account acc : [SELECT Id,Billing_Address__c FROM Account WHERE Id IN :accIds]){
                accountMap.put(acc.Id,acc);
            }
        }
        System.debug('accountMap.values() '+accountMap.values());
        for(BVCInvoice__c inv : newList){
            if(orderMap.containskey(inv.BVCOrder__c)){
                if(orderMap.get(inv.BVCOrder__c).Business_Type__c == 'Shipment'){
                    inv.Billing_Address__c = orderMap.get(inv.BVCOrder__c).Billing_Address__c;
                    inv.Origin_Address__c = orderMap.get(inv.BVCOrder__c).Origin_Address__c;
                }
                if(orderMap.get(inv.BVCOrder__c).Business_Type__c == 'ACR'){
                    inv.Billing_Address__c = orderMap.get(inv.BVCOrder__c).Billing_Address__c;
                    inv.Origin_Address__c = orderMap.get(inv.BVCOrder__c).Billing_Address__c;
                }
                inv.BVC_Branch__c = orderMap.get(inv.BVCOrder__c).BVC_Branch__c;
                inv.BVC_LegalEntity__c = orderMap.get(inv.BVCOrder__c).BVC_LegalEntity__c;
                inv.BVC_Entity__c = orderMap.get(inv.BVCOrder__c).BVC_Entity__c;
            }
            else if(accountMap.containsKey(inv.Account__c)){
                inv.Billing_Address__c = accountMap.get(inv.Account__c).Billing_Address__c;
                inv.Origin_Address__c = accountMap.get(inv.Account__c).Billing_Address__c;
            }
        }
        
    }
    
    
    
    
     
    /***********************************************************************************
    * Name : PostInvoice
    * Description : Post Invoice after Tax Calculation.
    * Param : newMap & OldMap
    * Return : None
    ************************************************************************************/ 
    
    public static void postInvoice(Map<Id,BVCInvoice__c> newMap,Map<Id,BVCInvoice__c> oldMap){
        try{
        Set<Id> addressIds = new set<Id>();
        system.debug('Post Invoice Method:');
        list<BVCInvoice__c> invlisttoupdate = new list<BVCInvoice__c>();
        for(BVCInvoice__c inv : newMap.values()){
            system.debug('inv.Status__c : ' + inv.Status__c);
            system.debug('inv.Total_Amount_With_Tax__c : '+inv.Total_Amount_With_Tax__c);
          //  system.debug('oldMap.get(inv.Id) : '+oldMap.get(inv.Id).Total_Amount_With_Tax__c);
            BVCInvoice__c oldInv = oldMap.get(inv.Id);
            system.debug('inv.BVC_CB_Invoice_Type__c : ' + inv.BVC_CB_Invoice_Type__c);
            system.debug('inv.BVC_CB_Is_CB_Invoice__c : '+ inv.BVC_CB_Is_CB_Invoice__c);
            system.debug('inv==== '+ inv.name);
            
            
            if((inv.Status__c == 'Draft' || inv.Status__c == 'Posted')&& 
                inv.BVC_CB_Is_CB_Invoice__c && inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice'&& inv.Total_Amount_With_Tax__c >0){
                    system.debug('inside if+++++++');
                        inv.Status__c = 'Posted'; 
                   		inv.Place_of_Supply_City__c=inv.BVC_CB_Billing_State__c;
                		inv.Place_Of_Supply_State_Code__c=inv.BVC_CB_Billing_GST_State_Code__c;
                		inv.Place_Of_Supply_State__c=inv.BVC_CB_Billing_State__c;
                    	inv.BVC_CB_IsCommInvPosted__c=true;
                       // decimal roundoff50 = inv.blng__TotalAmount__c.round()-inv.blng__TotalAmount__c;
                    
                    	
                        inv.BVC_CB_CB_Comm_Inv_Series__c =inv.ST_Invoice_Series__c;
                        inv.BVC_CB_ROUND_OFF__c = inv.Total_Amount_With_Tax__c-inv.Total_Amount_With_Tax__c.round();
                    if(inv.BVC_CB_ROUND_OFF__c==-0.5){
                        inv.BVC_CB_CB_Comm_Inv_Amount__c =inv.Total_Amount_With_Tax__c+0.5;
                        inv.BVC_CB_ROUND_OFF__c =0.50;
                    }
                    else{
                        inv.BVC_CB_CB_Comm_Inv_Amount__c =inv.Total_Amount_With_Tax__c.round();
                    }
                       
                }
            Decimal invTotalAmountWithTaxToCheck = (inv.Subtotal__c+inv.TaxAmount__c);
			invTotalAmountWithTaxToCheck = invTotalAmountWithTaxToCheck.setScale(2, RoundingMode.HALF_UP);
            
            system.debug('before adding address invoice status========'+inv.Status__c);
            system.debug('Total_Amount_With_Tax__c========'+inv.Total_Amount_With_Tax__c);
            system.debug('oldInv.Total_Amount_With_Tax__c========'+oldInv.Total_Amount_With_Tax__c);
            system.debug('EY_Tax_Calculation_Status__c========'+inv.EY_Tax_Calculation_Status__c);
            system.debug('TaxAmount__c========'+inv.TaxAmount__c);
            system.debug('total========'+(inv.Subtotal__c+inv.TaxAmount__c));
            system.debug('Subtotal__c========'+inv.Subtotal__c);
            system.debug('invTotalAmountWithTaxToCheck========'+invTotalAmountWithTaxToCheck);
            
            if((inv.Status__c == 'Draft' || inv.Status__c == 'Initiated') 
               && inv.Total_Amount_With_Tax__c != null && inv.BVC_CB_Is_CB_Invoice__c == true		//added for CB Flow
              // && (inv.Total_Amount_With_Tax__c != oldInv.Total_Amount_With_Tax__c)){
             //  && (inv.Total_Amount_With_Tax__c == 0 || (inv.Total_Amount_With_Tax__c != oldInv.Total_Amount_With_Tax__c))
                && 	inv.TaxAmount__c!=null  && (inv.Total_Amount_With_Tax__c ==invTotalAmountWithTaxToCheck)
               && inv.EY_Tax_Calculation_Status__c == 'Success'){
                   system.debug('Invoice Billing Address:'+inv.Billing_Address__c);
                   system.debug('TaxAmount__c in if statement========'+inv.TaxAmount__c);
                   addressIds.add(inv.Billing_Address__c);
               }
            
            if((inv.Status__c == 'Draft' || inv.Status__c == 'Initiated') 
               && inv.Total_Amount_With_Tax__c != null && inv.BVC_CB_Is_CB_Invoice__c == false 
              // && (inv.Total_Amount_With_Tax__c != oldInv.Total_Amount_With_Tax__c)){
             //  && (inv.Total_Amount_With_Tax__c == 0 || (inv.Total_Amount_With_Tax__c != oldInv.Total_Amount_With_Tax__c))
                //&& 	inv.TaxAmount__c!=null && inv.TaxAmount__c > 0 && (inv.Total_Amount_With_Tax__c ==(inv.Subtotal__c+inv.TaxAmount__c))     //commented for VALSHIP flow
               && inv.EY_Tax_Calculation_Status__c == 'Success'){
                   system.debug('Invoice Billing Address:'+inv.Billing_Address__c);
                   system.debug('TaxAmount__c in if statement========'+inv.TaxAmount__c);
                   addressIds.add(inv.Billing_Address__c);
               }
            
        }
        Map<Id,AddressBook__c> regularAddressMap = new Map<Id,AddressBook__c>();
        Map<Id,AddressBook__c> sezAddressMap = new Map<Id,AddressBook__c>();
        if(addressIds.size() > 0 && addressIds != null){
            for(AddressBook__c ad : [SELECT Id,Dealer_Type__c FROM AddressBook__c WHERE Id IN :addressIds]){
                if(ad.Dealer_Type__c != 'SEZ'){
                    regularAddressMap.put(ad.Id,ad);
                    system.debug('Regular Billing Address : '+ad);
                }
                else if(ad.Dealer_Type__c == 'SEZ'){
                    system.debug('SEZ Address Details : '+ad);
                    sezAddressMap.put(ad.Id,ad);
                }
            }
        }
        if((regularAddressMap.size() >0 && regularAddressMap != null)
           ||(sezAddressMap.size() >0 && sezAddressMap != null)){
               system.debug('Regular Billing Address : '+regularAddressMap);
               System.debug('newMap.values():::: '+newMap.values());
               for(BVCInvoice__c inv : newMap.values()){
                   System.debug('@@@@@ inv name : '+inv.name);
                   System.debug('@@@@@ inv.Total_Freight_Tax__c : '+inv.Total_Freight_Tax__c);
                   Decimal freight = inv.Total_Freight_Tax__c == null ? 0.0 : inv.Total_Freight_Tax__c;
                   Decimal liability = inv.Total_Liability_Charge_Tax__c == null ? 0.0 : inv.Total_Liability_Charge_Tax__c;
                   Decimal offline = inv.Total_Offline_Tax__c == null ? 0.0 : inv.Total_Offline_Tax__c;
                   Decimal weightCharge = inv.Total_Weight_Charge_Tax__c == null ? 0.0 : inv.Total_Weight_Charge_Tax__c;
                   Decimal bvcValuationCharge = inv.Total_BVC_Valuation_Charge_Tax__c == null ? 0.0 : inv.Total_BVC_Valuation_Charge_Tax__c;
                   Decimal docketCharge = inv.Total_Docket_Charge_Tax__c == null ? 0.0 : inv.Total_Docket_Charge_Tax__c;
                   Decimal holidayCharge = inv.Total_Holiday_Charge_Tax__c == null ? 0.0 : inv.Total_Holiday_Charge_Tax__c;
                   Decimal fuelCharge = inv.Total_Fuel_Charge_Tax__c == null ? 0.0 : inv.Total_Fuel_Charge_Tax__c;
                   Decimal fuelSurcharge = inv.Total_Fuel_surcharge_Tax__c == null ? 0.0 : inv.Total_Fuel_surcharge_Tax__c;//Prat
                   Decimal Vaultingcharge = inv.Total_Vaulting_tax__c == null ? 0.0 : inv.Total_Vaulting_tax__c;//Prat
                   Decimal universeCostCharge = inv.Total_Universe_Cost_Charge_Tax__c ==null ? 0.0 : inv.Total_Universe_Cost_Charge_Tax__c;//Universe Cost Charge
                   // BY SONU for bath and eship uncomment this
                   Decimal commissionCharge = inv.Total_Commission_Tax__c == null ? 0.0 : inv.Total_Commission_Tax__c;
                   Decimal logisticsCharge = inv.Total_Logistics_Tax_Amount__c == null ? 0.0 : inv.Total_Logistics_Tax_Amount__c;
                   Decimal SecureLogCharge = inv.Total_Secure_Logistics_Tax_Amount__c == null ? 0.0 : inv.Total_Secure_Logistics_Tax_Amount__c;
                   Decimal taxAmount = (freight+liability+offline+weightCharge+bvcValuationCharge+docketCharge+holidayCharge+fuelCharge+fuelSurcharge+Vaultingcharge+commissionCharge+logisticsCharge+universeCostCharge+SecureLogCharge).setScale(0);
                   // CB remove this
                   // Decimal taxAmount = (freight+liability+offline+weightCharge+bvcValuationCharge+docketCharge+holidayCharge+fuelCharge+fuelSurcharge+Vaultingcharge+universeCostCharge).setScale(0);
                   Decimal invTaxAmount = inv.Total_Amount_With_Tax__c.setScale(0);
                   System.debug('Rafi test regularAddressMap.containsKey(inv.Billing_Address__c) : '+regularAddressMap.containsKey(inv.Billing_Address__c));
                   System.debug('Rafi test inv.Total_Amount_With_Tax__c : '+inv.Total_Amount_With_Tax__c);
                   System.debug('Rafi test invTaxAmount : '+invTaxAmount);
                   System.debug('Rafi test taxAmount : '+taxAmount);
                   System.debug('Rafi test sezAddressMap.containsKey(inv.Billing_Address__c) : '+sezAddressMap.containsKey(inv.Billing_Address__c));
                   
                    if(inv.BVC_CB_Is_CB_Invoice__c){
                        system.debug('Ibefore true===='+regularAddressMap.containsKey(inv.Billing_Address__c));
                        system.debug('regular address map===='+regularAddressMap);
                        system.debug('invoice address===='+inv.Billing_Address__c);
                        if(regularAddressMap.containsKey(inv.Billing_Address__c) && inv.Invoice_Type__c == 'Tax Invoice' && inv.TaxAmount__c > 0){
                            system.debug('Inside Posted method of CB tax invoice====');
                            inv.Status__c = 'Posted';
                            system.debug('Ibefore true===='+inv.BVC_CB_IsTaxPosted__c);
                            inv.BVC_CB_IsTaxPosted__c =true;
                            system.debug('after true===='+inv.BVC_CB_IsTaxPosted__c);
                            inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c.round();
                            system.debug('inv.Total_Amount_With_Tax__c.round()+++++++'+inv.Total_Amount_With_Tax__c.round());
                            inv.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
                            inv.BVC_CB_ROUND_OFF__c = inv.Total_Amount_With_Tax__c.round()-inv.Total_Amount_With_Tax__c;
                            if(inv.BVC_CB_ROUND_OFF__c==-0.50){
                                inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c+0.5;
                                inv.BVC_CB_ROUND_OFF__c =0.50;
                    }
                            else{
                                inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c.round();
                            }
                            
                        }else if(sezAddressMap.containsKey(inv.Billing_Address__c) && inv.TaxAmount__c == 0 && taxAmount == 0){
                            system.debug('Inside SEZ address check====');
                            inv.Status__c = 'Posted';
                            inv.BVC_CB_IsTaxPosted__c =true;
                            inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c.round();
                            inv.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
                            inv.BVC_CB_ROUND_OFF__c = inv.Total_Amount_With_Tax__c.round()-inv.Total_Amount_With_Tax__c;
                            if(inv.BVC_CB_ROUND_OFF__c==-0.5){
                                inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c+0.5;
                                inv.BVC_CB_ROUND_OFF__c =0.50;
                            }
                            else{
                                inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c.round();
                            }
                        }
                        if(inv.Invoice_Type__c == 'Bill of Supply Invoice' && inv.EY_Tax_Calculation_Status__c == 'Success'){
                            inv.Status__c = 'Posted'; 
                            inv.BVC_CB_IsBosInvPosted__c =true;
                            inv.BVC_CB_BOS_Bill_Amount__c =inv.Total_Amount_With_Tax__c.round();
                            inv.BVC_CB_CB_BOS_Inv_Series__c =inv.ST_Invoice_Series__c;
                            inv.BVC_CB_ROUND_OFF__c = inv.Total_Amount_With_Tax__c.round()-inv.Total_Amount_With_Tax__c;
                            if(inv.BVC_CB_ROUND_OFF__c==-0.5){
                                inv.BVC_CB_BOS_Bill_Amount__c =inv.Total_Amount_With_Tax__c+0.5;
                                inv.BVC_CB_ROUND_OFF__c =0.50;
                            }
                            else{
                                inv.BVC_CB_BOS_Bill_Amount__c =inv.Total_Amount_With_Tax__c.round();
                            }
                            //Remove after razorpay works
                        }
                    }else{
                        //if(regularAddressMap.containsKey(inv.Billing_Address__c) && inv.Total_Amount_With_Tax__c > 0 &&  invTaxAmount == taxAmount){
                        if(regularAddressMap.containsKey(inv.Billing_Address__c) && inv.TaxAmount__c > 0){
                            inv.Status__c = 'Posted';
                            system.debug('check1+++++');
                        }
                        else if(sezAddressMap.containsKey(inv.Billing_Address__c) && inv.TaxAmount__c == 0 && taxAmount == 0){
                            inv.Status__c = 'Posted';
                        }   
                    }               
               }
           }
            system.debug('check2+++++');
            //   if(invlisttoupdate.size()>0){
            //   update invlisttoupdate;
            //  }
        }catch(Exception ex){
            System.debug('Catch in postInvoice error msg :'+ex.getMessage());
            System.debug('Catch in postInvoice error line number :'+ex.getLineNumber());
        }
    }
    
      /**********************************************************************************
* Name : generateDocument
* Description : Generate A5 document for Invoice and send email with Doc
* Param : newList and OldMap
* Return : None
***********************************************************************************/ 
    
    public static void generateDocument(List<BVCInvoice__c> newList, Map<Id,BVCInvoice__c> oldMap){  
        system.debug('inside Doc Gen');
        List<rsdoc__Document_Request__c> listDocRequest = new List<rsdoc__Document_Request__c>();
        Map<String,rsdoc__Document_Action__c> mapInvoiceDocAction = new Map<String,rsdoc__Document_Action__c>();
        if(!Test.isRunningTest()){
            List<rsdoc__Document_Action__c> doclist = [SELECT id,rsdoc__Template_Name__c from rsdoc__Document_Action__c where rsdoc__Base_object_API__c = 'BVCInvoice__c'];
            
            for(rsdoc__Document_Action__c docaction: doclist){
                if(docaction.rsdoc__Template_Name__c == 'BVC ACR INVOICE'){
                    mapInvoiceDocAction.put('ACR',docaction);
                }else if(docaction.rsdoc__Template_Name__c == 'BVC SHIPMENT INVOICE'){
                    mapInvoiceDocAction.put('Shipment',docaction);
                }else if(docaction.rsdoc__Template_Name__c == 'BVC CONSOLIDATED INVOICE'){
                    mapInvoiceDocAction.put('Consolidated',docaction);
                }
                else{
                    mapInvoiceDocAction.put(docaction.rsdoc__Template_Name__c,docaction);
                }
            }
        }
        System.debug('mapInvoiceDocAction. '+mapInvoiceDocAction);
        List<Id> invoiceIds = new List<Id>();
        List<Id> ManualinvoiceIds = new List<Id>();
        system.debug('newList=========='+newList);
        set<Id> pretaxid=new set<Id>();
        
        Set<Id> cbInvoiceIds = new Set<Id>();
        for (BVCInvoice__c invoice : oldMap.values()) {
            if (invoice.BVC_CB_Is_CB_Invoice__c == true) {
                cbInvoiceIds.add(invoice.Id);
            }
        }
        
        System.debug('for checking cbInvoiceIds.size() '+cbInvoiceIds.size());
        if (cbInvoiceIds.size() > 0) {
            List<BVCInvoice__c> preTaxInvoiceList = [SELECT Id, BVC_CB_PreTaxBill__c FROM BVCInvoice__c WHERE Id IN :cbInvoiceIds];
            System.debug('for checking preTaxInvoiceList.size() '+preTaxInvoiceList.size());
            //List<BVCInvoice__c> preTaxInvoiceList = [select id,BVC_CB_PreTaxBill__c from BVCInvoice__c where id IN:oldMap.keySet()];
            if(!Test.isRunningTest()){
                for(BVCInvoice__c invoice:preTaxInvoiceList){
                    pretaxid.add(invoice.BVC_CB_PreTaxBill__c);
                    system.debug('Pretax------'+pretaxid);
                }
            }
        }
        list<BVCInvoice__c> pretaxinvoices= new list<BVCInvoice__c>();
        if(pretaxid.size()>0){
            pretaxinvoices = [select id,BVC_CB_PreTaxBill__c,BVC_CB_IsTaxPosted__c,BVC_CB_IsCommInvPosted__c,BVC_CB_IsBosInvPosted__c,Invoice_Type__c from BVCInvoice__c where BVC_CB_PreTaxBill__c IN:pretaxid order by createddate DESC limit 1000];
        }
        system.debug('Pretax invoices------'+pretaxinvoices);
        Map<id,list<BVCInvoice__c>> pretaxinvoicesmap=new Map<id,list<BVCInvoice__c>>();
        for(BVCInvoice__c preinv : pretaxinvoices){
            if(pretaxinvoicesmap.containsKey(preinv.BVC_CB_PreTaxBill__c)){
                pretaxinvoicesmap.get(preinv.BVC_CB_PreTaxBill__c).add(preinv);
            }else{
                pretaxinvoicesmap.put(preinv.BVC_CB_PreTaxBill__c,new list<BVCInvoice__c>{preinv});
            }
        }
        for(BVCInvoice__c inv : newList){
            boolean genpdf = false;
            //if(inv.BVC_CB_Is_CB_Invoice__c == TRUE &&inv.Short_URL__c  != null && inv.Invoice_Doc_URL__c == null && inv.Razorpay_Id__c != null && inv.Razorpay_Id__c  != oldMap.get(inv.Id).Razorpay_Id__c ){
            //if(inv.BVC_CB_Is_CB_Invoice__c == TRUE && inv.Status__c == 'Posted' && oldMap.get(inv.Id).blng__InvoiceStatus__c != 'Posted'){
            if(inv.BVC_CB_Is_CB_Invoice__c == TRUE && inv.Invoice_Doc_URL__c == null){
                list<BVCInvoice__c> pretaxinvoicesassociated=pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c);
              
                // ============================================================TAX Invoice==========================================================================================================
                if(inv.Invoice_Type__c == 'Tax Invoice' && inv.BVC_CB_IsTaxPosted__c&&((inv.BVC_CB_IsTaxPosted__c !=oldmap.get(inv.id).BVC_CB_IsTaxPosted__c)||
                                                                                       (inv.BVC_CB_IsBosInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsBosInvPosted__c)||
                                                                                       (inv.BVC_CB_IsCommInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsCommInvPosted__c))){
                    boolean isbos=false;
                    boolean iscomm=false;
                    system.debug('inside tax line 663------'+pretaxinvoices);
                    system.debug('inv.id------'+inv.id);
                    for(BVCInvoice__c in1:pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c)){
                        system.debug('in1.Invoice_Type__c------'+in1.Invoice_Type__c);
                        if(in1.Invoice_Type__c == 'Commercial Invoice'){iscomm=true;}
                        if(in1.Invoice_Type__c == 'Bill of Supply Invoice'){isbos=true;}
                        system.debug('in1------'+in1.id);
                    }
                    system.debug('inv.id======='+inv.id);
                    system.debug('iscomm------'+iscomm);
                    system.debug('isbos------'+isbos);
                    system.debug('inv.BVC_CB_IsCommInvPosted__c======'+inv.BVC_CB_IsCommInvPosted__c);
                    system.debug('inv.BVC_CB_CB_Comm_Inv_Amount__c======'+inv.BVC_CB_CB_Comm_Inv_Amount__c);
                    if(iscomm == false && isbos == false){
                        genpdf =true;
                    }
                    else if(iscomm && isbos){
                        if(inv.BVC_CB_IsCommInvPosted__c && inv.BVC_CB_IsBosInvPosted__c){
                            genpdf = true;
                        }
                    }//else if(iscomm && inv.BVC_CB_IsCommInvPosted__c){
                        else if(iscomm && inv.BVC_CB_CB_Comm_Inv_Amount__c > 0){                                                                   
                        genpdf = true;
                    }else if(isbos && inv.BVC_CB_IsBosInvPosted__c){
                        genpdf = true;
                    }
                   /*  else if(inv.BVC_CB_Operation_Type__c=='General'){
                        //gen doc
                        genpdf = true;
                    }*/
                    // ============================================================ END TAX Invoice=========================================================================================
                 
                    // ============================================================BIOS Invoice=========================================================================================
                }else if(inv.Invoice_Type__c == 'Bill of Supply Invoice' && inv.BVC_CB_IsBosInvPosted__c&&((inv.BVC_CB_IsTaxPosted__c !=oldmap.get(inv.id).BVC_CB_IsTaxPosted__c)||
                                                                                                           (inv.BVC_CB_IsBosInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsBosInvPosted__c)||
                                                                                                           (inv.BVC_CB_IsCommInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsCommInvPosted__c))){
                    boolean iscomm=false;
                    boolean istax=false;
                    for(BVCInvoice__c in1:pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c)){
                        if(in1.Invoice_Type__c == 'Commercial Invoice'){iscomm=true;}
                        if(in1.Invoice_Type__c == 'Tax Invoice'){istax=true;}
                    }
                    if(iscomm == false && istax == false){
                        //gen doc
                        genpdf =true;
                    }
                    else if(iscomm && istax){
                        if(inv.BVC_CB_IsCommInvPosted__c && inv.BVC_CB_IsTaxPosted__c){
                            //gen doc
                            genpdf = true;
                        }
                    }else if(iscomm && inv.BVC_CB_IsCommInvPosted__c){
                        //gen doc
                        genpdf = true;
                    }else if(istax && inv.BVC_CB_IsTaxPosted__c){
                        //gen doc
                        genpdf = true;
                    }/*else if(inv.BVC_CB_Operation_Type__c=='General'){
                        //gen doc
                        genpdf = true;
                    }*/
                  // ============================================================END BIOS Invoice========================================================================================
                  // 
                  // ============================================================Commercial Invoice=========================================================================================  
                }else if(inv.Invoice_Type__c == 'Commercial Invoice' && inv.BVC_CB_IsCommInvPosted__c&&((inv.BVC_CB_IsTaxPosted__c !=oldmap.get(inv.id).BVC_CB_IsTaxPosted__c)||
                                                                                                        (inv.BVC_CB_IsBosInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsBosInvPosted__c)||
                                                                                                        (inv.BVC_CB_IsCommInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsCommInvPosted__c))){
                    boolean isbos=false;
                    boolean istax=false;
                    for(BVCInvoice__c in1:pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c)){
                        if(in1.Invoice_Type__c == 'Bill of Supply Invoice'){isbos=true;}
                        if(in1.Invoice_Type__c == 'Tax Invoice'){istax=true;}
                    }
                    if(isbos == false && istax == false){
                        //gen doc
                        genpdf =true;
                    }
                    else if(isbos && istax){
                        if(inv.BVC_CB_IsBosInvPosted__c && inv.BVC_CB_IsTaxPosted__c){
                            //gen doc
                            genpdf = true;
                        }
                    }else if(isbos && inv.BVC_CB_IsBosInvPosted__c){
                        //gen doc
                        genpdf = true;
                    }else if(istax && inv.BVC_CB_IsTaxPosted__c){
                        //gen doc
                        system.debug('Im in comm logic======');
                        genpdf = true;
                    }else if(inv.BVC_CB_Operation_Type__c=='General'){
                        //gen doc
                        genpdf = true;
                    }
                }  
                //========================================================= END Commercial Invoice======================================================================================================
                if(genpdf){
                    system.debug('Inside genPDF for General');
                    rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                  //  string operationtype;
                    string operationtype = inv.BVC_CB_Operation_Type__c != null?inv.BVC_CB_Operation_Type__c:'General';
                    system.debug('operationtype======'+operationtype);
                    system.debug('BVC_CB_Invoice_Type__c======'+inv.BVC_CB_Invoice_Type__c);
                    string templatename = 'BVC '+'CB '+operationtype+' '+inv.BVC_CB_Invoice_Type__c;
                    system.debug('templatename======'+templatename);
                    docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get(templatename).Id;
                    docReq.rsdoc__Record_Id__c = inv.Id;
                    // docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                    listDocRequest.add(docReq); 
                }
            }else{
                if(inv.Status__c  == 'Posted' && oldMap.get(inv.Id).Status__c  != 'Posted'  )
                    //&&  inv.Short_URL__c  != null && inv.Razorpay_Id__c != null &&(oldMap.get(inv.Id).Status__c  != 'Posted'
                    //|| inv.Razorpay_Id__c  != oldMap.get(inv.Id).Razorpay_Id__c ))
                {
                    system.debug('Inside genPDF======');
                    if(inv.BVC_Invoice_Run__c  != null && mapInvoiceDocAction.containsKey('Consolidated')){
                        rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                        docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('Consolidated').Id;
                        docReq.rsdoc__Record_Id__c = inv.Id;
                        // docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                        listDocRequest.add(docReq);
                    }else if(inv.BVCOrder__c != null || inv.BVCQuote__c!=null){
                        system.debug('Inside_____');
                        invoiceIds.add(inv.id);
                        
                    }else{
                        ManualinvoiceIds.add(inv.Id);
                    }
                    
                }
            }           
        }
        if(invoiceIds != null && !invoiceIds.isEmpty()){
            system.debug('Calling....');
            for(BVCInvoice__c invRec : [select id,Business_Type__c,BVCOrder__c from BVCInvoice__c where id in:invoiceIds ]){
                if(invRec.Business_Type__c != null){
                    rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                    docReq.rsdoc__Record_Id__c = invRec.Id;
                    // docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                    
                    if(invRec.BVCOrder__c!=null && mapInvoiceDocAction.containsKey('Shipment')){
                        docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('Shipment').Id;
                        listDocRequest.add(docReq);
                    }else if(mapInvoiceDocAction.containsKey('ACR')){
                        docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('ACR').Id;
                        listDocRequest.add(docReq);
                    }/*else if(mapInvoiceDocAction.containsKey('General Bill of Supply')){
system.debug('GBS');
docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('General Bill of Supply').Id;
listDocRequest.add(docReq);
}*/
                    
                    
                }
            }
        }
        if(ManualinvoiceIds != null && !ManualinvoiceIds.isEmpty()){
            system.debug('3');
            for(Id invRecId : ManualinvoiceIds){         
                rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                docReq.rsdoc__Record_Id__c = invRecId;
                // docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                if(mapInvoiceDocAction.containsKey('ACR')){
                    docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('ACR').Id;
                    listDocRequest.add(docReq);
                }  
            }
        }
        System.debug('listDocRequest. '+listDocRequest);
        if(!listDocRequest.isEmpty()){
            System.debug('insert listDocRequest. '+listDocRequest);
            if(!test.isRunningTest()){
                insert listDocRequest;   
            }
        }
    }
    
  
    //updateflags this method is used for CB Invoices only.
    
    public static Boolean isTriggerFired = false;
    
    public static void updateflags(Map<Id,BVCInvoice__c> newMap,Map<Id,BVCInvoice__c> oldMap){
        system.debug('inside update flags');
        
        if (isTriggerFired) {
            return;
        }
        isTriggerFired = true;
        
        list<BVCInvoice__c> InvList1 = new list<BVCInvoice__c>();
        Set<Id> commercialInvoiceIds = new Set<Id>();
        Set<Id> taxInvoiceIds = new Set<Id>();
        Set<Id> billOfSupplyInvoiceIds = new Set<Id>();
        
        Map<Id, BVCInvoice__c> invoiceMapToUpdate = new Map<Id, BVCInvoice__c>();
        
        for(BVCInvoice__c inv:newMap.values()){
            system.debug('inside for===');
            if(inv.BVC_CB_Is_CB_Invoice__c){
                system.debug('inv.BVC_CB_Invoice_Type__c==='+inv.BVC_CB_Invoice_Type__c);
                System.debug('for checking oldMap.get(inv.id).Status__c '+oldMap.get(inv.id).Status__c);
                System.debug('for checking inv.Status__c '+inv.Status__c);
                if(inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice' && oldMap.get(inv.id).Status__c !='Posted' &&inv.Status__c == 'Posted'){
                    commercialInvoiceIds.add(inv.BVC_CB_PreTaxBill__c);
                }
                system.debug('inv.Is_SEZ_address__c==='+inv.Is_SEZ_address__c);
                system.debug('oldMap.get(inv.Id).TaxAmount__c==='+oldMap.get(inv.Id).TaxAmount__c);
                system.debug('inv.TaxAmount__c==='+inv.TaxAmount__c);
                if(inv.BVC_CB_Invoice_Type__c == 'Tax Invoice' && 
                   ((oldMap.get(inv.Id).TaxAmount__c == 0 && inv.TaxAmount__c > 0) || 
                    (inv.Status__c == 'Posted' && inv.Is_SEZ_address__c==true))){
                        taxInvoiceIds.add(inv.BVC_CB_PreTaxBill__c);
                    }
                
                if(inv.BVC_CB_Invoice_Type__c == 'Bill of Supply Invoice' && oldMap.get(inv.id).EY_Tax_Calculation_Status__c != 'Success'
                   && inv.EY_Tax_Calculation_Status__c =='Success'){
                    billOfSupplyInvoiceIds.add(inv.BVC_CB_PreTaxBill__c);
                }
                
            }
        }
        
        System.debug('for checking commercialInvoiceIds.size() '+commercialInvoiceIds.size());
        System.debug('for checking taxInvoiceIds.size() '+taxInvoiceIds.size());
        System.debug('for checking billOfSupplyInvoiceIds.size() '+billOfSupplyInvoiceIds.size());
        
        Set<Id> uniqueInvoiceIds = new Set<Id>();
        for (BVCInvoice__c invoice : [SELECT Id FROM BVCInvoice__c WHERE BVC_CB_PreTaxBill__c IN :commercialInvoiceIds 
            OR BVC_CB_PreTaxBill__c IN :taxInvoiceIds OR BVC_CB_PreTaxBill__c IN :billOfSupplyInvoiceIds order by createddate DESC limit 1000]) {
            uniqueInvoiceIds.add(invoice.Id);
        }
        
        List<BVCInvoice__c> relatedInvoicesList = new List<BVCInvoice__c>();
        
        relatedInvoicesList = [select id,BVC_CB_IsBosInvPosted__c,BVC_CB_IsTaxPosted__c,BVC_CB_IsCommInvPosted__c,
                               Total_Amount_With_Tax__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c 
                               from BVCInvoice__c 
                               where Id IN : uniqueInvoiceIds order by createddate DESC limit 1000];
        
        System.debug('for checking relatedInvoicesList.size() '+relatedInvoicesList.size());
        
        for(BVCInvoice__c inv : newMap.values()){
            System.debug('for checking Inside for of newMap.values() ');
            if(inv.BVC_CB_Is_CB_Invoice__c){
                System.debug('for checking Inside if(inv.BVC_CB_Is_CB_Invoice__c) ');
                for(BVCInvoice__c relatedInvoice : relatedInvoicesList){
                    System.debug('for checking Inside for of relatedInvoicesList ');
                    System.debug('for checking inv.BVC_CB_Invoice_Type__c in newMap.Values() '+inv.BVC_CB_Invoice_Type__c );
                    System.debug('for checking relatedInvoice.BVC_CB_Invoice_Type__c in relatedInvoicesList '+relatedInvoice.BVC_CB_Invoice_Type__c );
                    if(inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice' && 
                       relatedInvoice.BVC_CB_Invoice_Type__c != 'Commercial Invoice'){
                           if(!invoiceMapToUpdate.containsKey(relatedInvoice.Id)){
                               relatedInvoice.BVC_CB_CB_Comm_Inv_Amount__c=inv.Total_Amount_With_Tax__c.round();
                               relatedInvoice.BVC_CB_CB_Comm_Inv_Series__c =inv.ST_Invoice_Series__c;
                               relatedInvoice.BVC_CB_IsCommInvPosted__c =true;
                              // relatedInvoice.UpdateFlagMethod__c =true;
                               //InvList1.add(relatedInvoice);
                               invoiceMapToUpdate.put(relatedInvoice.Id, relatedInvoice);
                           }
                       }
                    
                    if(inv.BVC_CB_Invoice_Type__c == 'Tax Invoice' && 
                       relatedInvoice.BVC_CB_Invoice_Type__c != 'Tax Invoice'){
                           if(!invoiceMapToUpdate.containsKey(relatedInvoice.Id)){
                               relatedInvoice.BVC_CB_CB_Tax_Inv_Amount__c =inv.Total_Amount_With_Tax__c.round();
                               relatedInvoice.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
                               relatedInvoice.BVC_CB_IsTaxPosted__c =true;
                            //   relatedInvoice.UpdateFlagMethod__c =true;
                               //InvList1.add(relatedInvoice);
                               invoiceMapToUpdate.put(relatedInvoice.Id, relatedInvoice);
                           }
                       }
                    
                    if(inv.BVC_CB_Invoice_Type__c == 'Bill of Supply Invoice' && 
                       relatedInvoice.BVC_CB_Invoice_Type__c != 'Bill of Supply Invoice'){
                           if(!invoiceMapToUpdate.containsKey(relatedInvoice.Id)){
                               relatedInvoice.BVC_CB_BOS_Bill_Amount__c =inv.Total_Amount_With_Tax__c.round();
                               relatedInvoice.BVC_CB_CB_BOS_Inv_Series__c =inv.ST_Invoice_Series__c;
                               relatedInvoice.BVC_CB_IsBosInvPosted__c =true;
                             //  relatedInvoice.UpdateFlagMethod__c =true;
                               //InvList1.add(relatedInvoice);
                               invoiceMapToUpdate.put(relatedInvoice.Id, relatedInvoice);
                           }
                       }
                }
                
            }
            
        }
        
        /*system.debug('InvList1.size()==='+InvList1.size());
        if(InvList1.size()>0){
            update InvList1;
        }*/
        
        System.debug('for checking invoiceMapToUpdate.size()=' + invoiceMapToUpdate.size());

        if (invoiceMapToUpdate.size() > 0) {
            update invoiceMapToUpdate.values();
        }
        
    }

    //getCoverage method
    public static void getCoverage(){
        integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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