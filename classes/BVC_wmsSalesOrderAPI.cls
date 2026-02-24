@RestResource(urlMapping='/SalesOrder/')
global with sharing class BVC_wmsSalesOrderAPI {

    global class SOResponse {
        public Boolean success;
        public String message;
        public Id recordId;
        public String action;
        public List<String> errors = new List<String>();
    }



    @HttpPost
    global static SOResponse upsertSO() {

        SOResponse res = new SOResponse();
        Savepoint sp = Database.setSavepoint();

        try {

            Map<String,Object> payload =(Map<String,Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            String soId = payload.containsKey('Id') && payload.get('Id') != null ? String.valueOf(payload.get('Id')).trim(): null;

            Boolean isCreate = String.isBlank(soId);

            Sales_Order__c so;

            if(!isCreate) {

                so = [SELECT Id FROM Sales_Order__c WHERE Id = :soId LIMIT 1 ];

                res.action = 'UPDATED';

            } else {

                so = new Sales_Order__c();
                res.action = 'CREATED';
            }

            mapSOFields(payload, so);
             
              if(isCreate)
                validateMandatoryFields(so);
             
            if(isCreate) insert so;
            else update so;

              if(isCreate) {

                if(payload.containsKey('kycFiles')) {

                    uploadFiles((List<Object>) payload.get('kycFiles'),so.Id);
                }

                if(payload.containsKey('invoiceDocuments')) {

                    processInvoiceDocuments((List<Object>) payload.get('invoiceDocuments'),so.Id);
                }
            }

            res.success = true;
            res.recordId = so.Id;
            res.message = 'Stock Outward ' + res.action + ' successfully';

        }
        catch(Exception e) {

            Database.rollback(sp);

            res.success = false;
            res.message = 'Transaction failed';
            res.errors.add(e.getMessage());
            res.errors.add('Type: ' + e.getTypeName());
            res.errors.add('Line: ' + e.getLineNumber());
            res.errors.add('Stack: ' + e.getStackTraceString());
        }

        return res;
    }

    private static void mapSOFields(Map<String,Object> payload,Sales_Order__c so) {

            so.Batch_Number__c =(String) payload.get('Batch Number');

        if(payload.containsKey('Batch Size'))
            so.Batch_Size__c = Integer.valueOf(String.valueOf( payload.get('Batch Size')));
    
            so.Consignee_delivery_partner__c =(String) payload.get('Consignee(delivery partner)' );

            if(payload.containsKey('Contact Person')) {
    
              String cp =String.valueOf(payload.get('Contact Person')).trim();
        
                    if(!String.isBlank(cp)) {
                        so.Contact_Person__c = (Id) cp;
                    }
                }

            so.Customer_Name__c =(String) payload.get('Customer Name');
    
            so.Customer_Phone__c = (String) payload.get('Customer Phone');

        if(payload.containsKey('Dispatched By')) {

          String cp =String.valueOf(payload.get('Dispatched By')).trim();
    
                if(!String.isBlank(cp)) {
                    so.Dispatched_By__c = (Id) cp;
                }
            }
        
           if(payload.containsKey('Hub')) {

          String cp =String.valueOf(payload.get('Hub')).trim();
    
                if(!String.isBlank(cp)) {
                    so.Hub__c = (Id) cp;
                }
            }
     
            so.Location_Tracking__c = (String) payload.get('Location Tracking');
    
            so.Mode_Of_Transport__c =(String) payload.get('Mode Of Transport');
    
            so.Rack_Number__c =(String) payload.get('Rack Number');
    
            so.Sales_Order_Status__c =(String) payload.get('Sales Order Status');
            
             if(payload.containsKey('Vendor Name')) {
    
              String cp =String.valueOf(payload.get('Vendor Name')).trim();
        
                    if(!String.isBlank(cp)) {
                        so.Shipping_Partner__c = (Id) cp;
                    }
                }
         
                so.Transport_Partner__c =(String) payload.get('Transport Partner');
        
            if(payload.containsKey('Vendor Address')) {
    
              String cp =String.valueOf(payload.get('Vendor Address')).trim();
        
                    if(!String.isBlank(cp)) {
                        so.Vendor_Address__c = (Id) cp;
                    }
                }
         
            
            
            if(payload.containsKey('Estimated Delivery Date'))
                so.Estimated_Delivery_Date__c =Datetime.valueOf( String.valueOf(payload.get('Estimated Delivery Date'))
                                                                
               );
        
                so.Sender_Address__c =(String) payload.get('Sender Address');
        
                so.Sender_Email__c =(String) payload.get('Sender Email');
        
                so.Sender_Name__c = (String) payload.get('Sender Name');
        
                so.Sender_Phone__c =(String) payload.get('Sender Phone');
        
                so.Created_Through__c =(String) payload.get('Created Through');
    
            if(payload.containsKey('SO Date'))
                so.SO_Date__c = Date.valueOf( String.valueOf(payload.get('SO Date'))
              );
    
              if(payload.containsKey('Type Of Document') && payload.get('Type Of Document') != null) {
    
                   String docType =String.valueOf(payload.get('Type Of Document')).trim();
    
                    if(!String.isBlank(docType)) {
                        so.Type_Of_Document__c = docType;
                    }
                }
        
                so.Reference_Doc_Number__c =(String) payload.get('Reference doc number');
    }
   
     private static void validateMandatoryFields(Sales_Order__c so) {

        List<String> missing = new List<String>();

        if(so.Shipping_Partner__c == null)
            missing.add('Vendor Name');

        if(so.Hub__c == null)
            missing.add('Hub');



        if(!missing.isEmpty())
            throw new AuraHandledException('Missing fields: ' + String.join(missing, ', ')
            );
    }


    private static void processInvoiceDocuments(List<Object> invoices,Id parentId) {
    
        Decimal totalAmount = 0;
            Date latestInvoiceDate;
            List<String> invoiceNumbers = new List<String>();
            List<WMS_Customer_Document__c> docsToInsert = new List<WMS_Customer_Document__c>();
        
            for(Object obj : invoices) {
        
                Map<String,Object> inv = (Map<String,Object>) obj;
        
                WMS_Customer_Document__c doc = new WMS_Customer_Document__c();
        
                doc.Stock_outward__c = parentId;
                  
                if(inv.containsKey('invoiceNo') && inv.get('invoiceNo') != null) {
                    String invNo = String.valueOf(inv.get('invoiceNo'));
                    doc.Invoice_No__c = invNo;
                    invoiceNumbers.add(invNo);
                }
        
               
                if(inv.containsKey('invoiceDate') && inv.get('invoiceDate') != null) {
        
                    Date invDate = Date.valueOf(String.valueOf(inv.get('invoiceDate')));
                    doc.Invoice_Date__c = invDate;
        
                    if(latestInvoiceDate == null || invDate > latestInvoiceDate)
                        latestInvoiceDate = invDate;
                }
        
               
                if(inv.containsKey('invoiceAmount') && inv.get('invoiceAmount') != null) {
        
                    Decimal amt = Decimal.valueOf(String.valueOf(inv.get('invoiceAmount')));
                    doc.Invoice_Amount__c = amt;
        
                    totalAmount += amt;
                }
        
                if(inv.containsKey('DocumentType') && inv.get('DocumentType') != null) {
                    doc.Document_Type__c = String.valueOf(inv.get('DocumentType'));
                }
        
                docsToInsert.add(doc);
            }
        
            insert docsToInsert;
        
            
            for(Integer i=0; i<invoices.size(); i++) {
        
                Map<String,Object> inv = (Map<String,Object>) invoices[i];
        
                List<Id> docIds = uploadFiles((List<Object>) inv.get('files'), docsToInsert[i].Id);
        
                if(!docIds.isEmpty()) {
        
                    String downloadUrl = getOrCreateDistributionUrl(docIds[0]);
        
                    docsToInsert[i].Customer_Documents_URL__c = downloadUrl;
                }
            }
        
            update docsToInsert;
        
           
            Sales_Order__c poUpdate = new Sales_Order__c(
                Id = parentId,
                Invoice_No__c = String.join(invoiceNumbers, ', '),
                Amount__c = totalAmount,
                Date__c = latestInvoiceDate
            );
        
            update poUpdate;
    }

    private static List<Id> uploadFiles(List<Object> files,Id parentId ) {

        if(files == null || files.isEmpty())
            return new List<Id>();

        List<ContentVersion> versions = new List<ContentVersion>();

        for(Object obj : files) {

            Map<String,Object> file = (Map<String,Object>) obj;

            versions.add(new ContentVersion(
                Title = (String) file.get('fileName'),
                PathOnClient ='/' + file.get('fileName'),
                VersionData =EncodingUtil.base64Decode((String) file.get( 'base64Data'))
            ));
        }

        insert versions;

        Map<Id,Id> mapIds = new Map<Id,Id>();

        for(ContentVersion cv : [ SELECT Id, ContentDocumentId FROM ContentVersion  WHERE Id IN :versions]) {
            mapIds.put(cv.Id, cv.ContentDocumentId);
        }

        List<ContentDocumentLink> links =new List<ContentDocumentLink>();

        for(Id docId : mapIds.values()) {

            links.add(new ContentDocumentLink(
                    ContentDocumentId = docId,
                    LinkedEntityId = parentId,
                    ShareType = 'V'
                )
            );
        }

        insert links;

        return new List<Id>(mapIds.values());
    }


    private static String getOrCreateDistributionUrl( Id docId) {

        List<ContentDistribution> existing = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId = :docId LIMIT 1];

        if(!existing.isEmpty())
            return existing[0].ContentDownloadUrl;

        ContentDistribution cd = new ContentDistribution( Name = 'Auto Share',
                                                           PreferencesAllowOriginalDownload = true,
                                                           PreferencesLinkLatestVersion = true );

        insert cd;

        return [SELECT ContentDownloadUrl FROM ContentDistribution  WHERE Id = :cd.Id].ContentDownloadUrl;
    }
}