@RestResource(urlMapping='/PurchaseOrder/')
global with sharing class BVC_wmsPurchaseOrderAPI {

    global class POResponse {
        public Boolean success;
        public String message;
        public Id recordId;
        public String action;
        public List<String> errors = new List<String>();
    }

    @HttpPost
    global static POResponse upsertPO() {

        POResponse res = new POResponse();
        Savepoint sp = Database.setSavepoint();

        try {

            Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped( RestContext.request.requestBody.toString());

            String poId =  payload.containsKey('Id') && payload.get('Id') != null ? String.valueOf(payload.get('Id')).trim(): null;

            Boolean isCreate = String.isBlank(poId);

            Purchase_Order__c po;

            if(!isCreate) {

                po = [ SELECT Id FROM Purchase_Order__c WHERE Id = :poId LIMIT 1 ];

                res.action = 'UPDATED';

            } else {

                po = new Purchase_Order__c();
                res.action = 'CREATED';
            }

            mapPOFields(payload, po);

            if(isCreate)
                validateMandatoryFields(po);

            if(isCreate) insert po;
            else update po;

            if(isCreate) {

                if(payload.containsKey('kycFiles')) {

                    uploadFiles((List<Object>) payload.get('kycFiles'),po.Id);
                }

                if(payload.containsKey('invoiceDocuments')) {

                    processInvoiceDocuments((List<Object>) payload.get('invoiceDocuments'),po.Id);
                }
            }

            res.success = true;
            res.recordId = po.Id;
            res.message = 'Stock Inward ' + res.action + ' successfully';

        }
        catch(Exception e) {

            Database.rollback(sp);

            res.success = false;
            res.message = 'Transaction failed';
            res.errors.add(e.getMessage());
        }

        return res;
    }

    private static void mapPOFields(Map<String,Object> payload, Purchase_Order__c po) {

            if(payload.containsKey('Customer Account'))
                po.Shipping_Partner__c = (Id) payload.get('Customer Account');
    
            if(payload.containsKey('Shipping Address'))
                po.Customer_Address__c = (Id) payload.get('Shipping Address');

            if(payload.containsKey('Hub'))
                po.Hub__c =(Id) payload.get('Hub');
    
               po.Received_From__c =(String) payload.get('Received From');

            if(payload.containsKey('Received By'))
                po.Received_By__c =(Id) payload.get('Received By');
    
                po.Shipping_Partner_n__c =(String) payload.get('Shipping Partner');
    
                po.Batch_Number__c = (String) payload.get('Batch Number');
        
                po.Customer_Phone__c = (String) payload.get('Customer Phone');
        
                po.Customer_Email__c = (String) payload.get('Customer Email');
        
                po.PO_Status__c = (String) payload.get('PO Status');

            if(payload.containsKey('Pickup date'))
                po.Pickup_date__c = Date.valueOf(String.valueOf(payload.get('Pickup date')) );
    
                po.Tracking_Number__c = (String) payload.get('Tracking Number');
        
                po.Transport_type__c = (String) payload.get('Transport type');
        
                po.Remarks__c = (String) payload.get('Remark');
        
                po.PO_Type__c = (String) payload.get('PO Type');

            if(payload.containsKey('PO Date'))
                po.PO_Date__c =  Date.valueOf(String.valueOf(payload.get('PO Date')));
    
                po.Created_Through__c = (String) payload.get('Created Through');
        
                po.Shipper_Address__c = (String) payload.get('Shipper Address');
        
                po.Shipper_Email__c = (String) payload.get('Shipper Email');
        
                po.Shipper_Name__c = (String) payload.get('Shipper Name');
        
                po.Shipper_Mobile_Number__c = (String) payload.get('Shipper Mobile Number');
        
                po.Type_of_document_for_KYC__c = (String) payload.get('Type of document');
    }

    private static void validateMandatoryFields(Purchase_Order__c po) {

        List<String> missing = new List<String>();

        if(po.Shipping_Partner__c == null)
            missing.add('Customer Account');

        if(po.Customer_Address__c == null)
            missing.add('Shipping Address');

        if(po.Hub__c == null)
            missing.add('Hub');

        if(String.isBlank(po.Received_From__c))
            missing.add('Received From');

        if(po.Received_By__c == null)
            missing.add('Received By');


        if(!missing.isEmpty())
            throw new AuraHandledException('Missing fields: ' + String.join(missing, ', ')
         );
    }

   private static List<Id> uploadFiles(List<Object> files,Id parentId) {
        
            if(files == null || files.isEmpty())
                
             return new List<Id>();
        
            List<ContentVersion> versions = new List<ContentVersion>();
        
            for(Object obj : files) {
        
                Map<String,Object> file = (Map<String,Object>) obj;
        
                ContentVersion cv = new ContentVersion();
                cv.Title = (String) file.get('fileName');
                cv.PathOnClient = '/' + cv.Title;
                cv.VersionData =EncodingUtil.base64Decode((String) file.get('base64Data'));
        
                versions.add(cv);
            }
        
            insert versions;
        
            Map<Id,Id> versionToDoc = new Map<Id,Id>();
        
            for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :versions]) {
                versionToDoc.put(cv.Id, cv.ContentDocumentId);
            }
        
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        
            for(Id docId : versionToDoc.values()) {
        
                links.add(new ContentDocumentLink(
                    ContentDocumentId = docId,
                    LinkedEntityId = parentId,
                    ShareType = 'V'
                ));
            }
        
            insert links;
        
            return versionToDoc.values();
 }

   private static void processInvoiceDocuments(List<Object> invoices, Id poId) {
    
        Decimal totalAmount = 0;
        Date latestInvoiceDate;
        List<String> invoiceNumbers = new List<String>();
        List<WMS_Customer_Document__c> docsToInsert = new List<WMS_Customer_Document__c>();
    
        for(Object obj : invoices) {
    
            Map<String,Object> inv = (Map<String,Object>) obj;
    
            WMS_Customer_Document__c doc = new WMS_Customer_Document__c();
    
            doc.Stock_Inward__c = poId;
              
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
    
       
        Purchase_Order__c poUpdate = new Purchase_Order__c(
            Id = poId,
            Invoice_No__c = String.join(invoiceNumbers, ', '),
            Invoice_Amount__c = totalAmount,
            Invoice_Date__c = latestInvoiceDate
        );
    
        update poUpdate;
 }
    
    private static String getOrCreateDistributionUrl(Id contentDocumentId) {
        
         
            List<ContentDistribution> existing = [ SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId = :contentDocumentId  LIMIT 1];
        
            if(!existing.isEmpty()) {
                return existing[0].ContentDownloadUrl;
            }
        
              
                ContentDistribution cd = new ContentDistribution();
            
                cd.Name = 'Auto Share';
                
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesLinkLatestVersion = true;
            
                insert cd;
        
                cd = [ SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id = :cd.Id ];
            
                return cd.ContentDownloadUrl;
        }
}