public class CreateSalesOrderController {

     public class InvoiceWrapper {
        @AuraEnabled public String invoiceNo;
        @AuraEnabled public Date invoiceDate;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String docType;
        @AuraEnabled public Id fileId;
    }

    @AuraEnabled
    public static void createCustomerDocuments(Id salesOrderId,String invoicesJson) {

        if (salesOrderId == null) {
            throw new AuraHandledException('Sales Order Id missing');
        }
        
         List<InvoiceWrapper> invoices = (List<InvoiceWrapper>) JSON.deserialize(invoicesJson,List<InvoiceWrapper>.class);
        
         Savepoint sp = Database.setSavepoint();

        

             try {
        
                // STEP 1 — Create WMS document records
                List<WMS_Customer_Document__c> docs = new List<WMS_Customer_Document__c>();
        
                for (InvoiceWrapper inv : invoices) {
        
                    docs.add(new WMS_Customer_Document__c(
                        Stock_Outward__c = salesOrderId,
                        Invoice_No__c = inv.invoiceNo,
                        Invoice_Date__c = inv.invoiceDate,
                        Invoice_Amount__c = inv.amount,
                        Document_Type__c = inv.docType,
                        Customer_Documents_URL__c = '/sfc/servlet.shepherd/document/download/' + inv.fileId
                    ));
                }
        
                insert docs;
                 
                 
                 Decimal totalAmount = 0;
                 Date latestInvoiceDate;
                List<String> invoiceNumbers = new List<String>();
                
                for (WMS_Customer_Document__c d : docs) {
                
                    if (d.Invoice_Amount__c != null)
                        totalAmount += d.Invoice_Amount__c;
                
                    if (!String.isBlank(d.Invoice_No__c))
                        invoiceNumbers.add(d.Invoice_No__c);
                    
                     if (d.Invoice_Date__c != null) {

                      latestInvoiceDate = d.Invoice_Date__c;       
                    }
                }
                
                // STEP 2 — Update Sales Order
                Sales_Order__c soUpdate = new Sales_Order__c(
                    Id = salesOrderId,
                    Invoice_No__c = String.join(invoiceNumbers, ', '),
                    Amount__c = totalAmount,
                    date__c = latestInvoiceDate
                );
                
                update soUpdate;
                 
        
                // STEP 2 — Attach files ONLY to WMS document records
                List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        
                for (Integer i = 0; i < invoices.size(); i++) {
        
                    if (invoices[i].fileId != null) {
        
                        links.add(new ContentDocumentLink(
                            ContentDocumentId = invoices[i].fileId,
                            LinkedEntityId = docs[i].Id, 
                            ShareType = 'V'
                        ));
                    }
                }
        
                if (!links.isEmpty()) {
                    insert links;
                }
                 
                 
                       
                Set<Id> docIds = new Set<Id>();

                for (InvoiceWrapper inv : invoices) {
                    if (inv.fileId != null)
                        docIds.add(inv.fileId);
                }
                
                // Query existing distributions
                Map<Id, String> distUrlMap = new Map<Id, String>();
                
                for (ContentDistribution cd : [
                    SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl
                    FROM ContentDistribution
                    WHERE ContentDocumentId IN :docIds
                ]) {
                    distUrlMap.put(cd.ContentDocumentId, cd.ContentDownloadUrl);
                }
                
                // Update WMS docs with URL
                List<WMS_Customer_Document__c> updateDocs = new List<WMS_Customer_Document__c>();
                
                for (Integer i = 0; i < invoices.size(); i++) {
                
                    Id fileId = invoices[i].fileId;
                
                    if (fileId != null && distUrlMap.containsKey(fileId)) {
                
                        updateDocs.add(new WMS_Customer_Document__c(
                            Id = docs[i].Id,
                            Customer_Documents_URL__c = distUrlMap.get(fileId)
                        ));
                    }
                }
                
                if (!updateDocs.isEmpty()) {
                    update updateDocs;
                }
                
                 
        
            } catch (Exception e) {
                Database.rollback(sp);
                throw new AuraHandledException(e.getMessage());
            }
            
    
    }
    
    @AuraEnabled
    public static void attachKycFile(Id soId, Id fileId) {
    
        if(soId == null || fileId == null) return;
    
        insert new ContentDocumentLink(
            ContentDocumentId = fileId,
            LinkedEntityId = soId,
            ShareType = 'V'
        );
    }
}