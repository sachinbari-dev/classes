public class attch_eShipDocumentOnQuote {

       @InvocableMethod
    public static void getPdfBlob(List<Id> quoteId) {
        List<BVCQuote__c> QuoteList = new List<BVCQuote__c>();
 
        // Update records with new dates
        for(Id qID : quoteId){
            BVCQuote__c bvcq = new BVCQuote__c();
            bvcq.id = qID;
            bvcq.Status__c = 'Quote Sent';
            bvcq.Quote_Sent_Date__c = system.today();
            bvcq.Document_Date__c = system.today();
            QuoteList.add(bvcq);
        }
        if(!QuoteList.isEmpty()){
            update QuoteList;
        }

    addFile(quoteId);

   
    }
    
    @Future(callout=true)
    public static void addFile(List<Id> quoteId){
        BVCQuote__c bcq = [Select id,name from BVCQuote__c where id IN:quoteId];
        List<ContentVersion> cvList = new List<ContentVersion>();
         Blob pdfBlob;     
        
        for(ID bvcq : quoteId) {
            PageReference pdfPage = Page.eShipDocument;
            pdfPage.getParameters().put('id', bvcq);
            
            try {
                pdfBlob = pdfPage.getContentAsPDF();
                String currentDate = String.valueOf(Date.today()).removeEnd(' 00:00:00');
              
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'e-Ship Quote Quotation' + '-' + bcq.name;
                contentVersion.PathOnClient = 'e-Ship Quote Quotation.pdf';
                contentVersion.VersionData = pdfBlob;
                contentVersion.IsMajorVersion = true;
                contentVersion.FirstPublishLocationId = bvcq;
                cvList.add(contentVersion);
                
            } catch (Exception e) {
                System.debug('Exception while generating PDF: ' + e.getMessage());
            }
        }
        if(pdfBlob != null){
           sendEmailToCustomer(quoteId, pdfBlob); 
        }
        
        
        if(!cvList.isEmpty()){
            insert cvList;
        }

        
    }
    
    public static void sendEmailToCustomer (List<Id> quoteId, blob pdfFile){
        List<BVCQuote__c> QuoteList = [SELECT Id, Name, Account__r.Name, Status__c FROM BVCQuote__c WHERE Id IN :quoteId];
        
        List<People_Role__c> peopleList = [SELECT Role__c, BVCQuote__c, People__r.Name, People__r.Email, Name, Id FROM People_Role__c WHERE BVCQuote__r.Id IN :quoteId];
        System.debug('QuoteList: ' + QuoteList);
        System.debug('PeopleList: ' + peopleList);
        
        List<String> ToEmail = new List<String>();
        Set<Id> AccId = new Set<Id>();
        String customerName = '';
        String QuoteName = '';
        
        for(BVCQuote__c bq : QuoteList){
            if(bq.Status__c == 'Quote Sent'){
                customerName = bq.Account__r.Name;
                QuoteName = bq.Name;
                AccId.add(bq.Account__c);
                for(People_Role__c pr : peopleList){
                    ToEmail.add(pr.People__r.Email);
                    System.debug('ToEmail: ' + ToEmail);
                }
            }
        }
        
        Account Acc = [SELECT Id, Name, Owner.Name, Owner.Email FROM Account WHERE Id IN :AccId];
         
        DateTime now = DateTime.now();
        Integer month = now.month();
        Integer year = now.year();
        String monthName = DateTime.newInstance(year, month, 1).format('MMMM');
         
        String subject = 'BVC Quotation ' + QuoteName + ' for ' + customerName + ' ' + monthName + ' ' + year;
        String body = 'Dear ' + customerName + ',' + '<br/><br/>';
        body += 'Greetings from BVC, the most secured logistics partner, having more than 60 years of experience in handling precious shipments !!!' + '<br/><br/>';
        body += 'Thank you for showing your interest to choose BVC as your logistics partner and giving us this opportunity to submit our quotation' + '<br/><br/>';
        body += 'Please find attached BVC’s quotation for services required by you. This quotation is valid for 30 days' + '<br/><br/>';
        body += 'If you have any clarifications regarding this quote, please feel free to get in touch with me' + '<br/><br/>';
        body += 'Looking forward to a long standing relationship between BVC and ' + customerName + '<br/><br/>';
        body += 'Thanks and Regards,' + '<br/>';
        body += Acc.Owner.Name + '<br/>';
        body += Acc.Owner.Email + '<br/>';
        body += 'BVC Logistics Pvt. Ltd.';
        
        List<blob> blobList = new List<blob>{pdfFile};             
        List<String> attachmentNames = new List<String>{'e-Ship Quote Quotation.pdf'};
         
       BVC_QuoteSendGridEmailAttachment.sendGridEmailMessagesAttachment(ToEmail, subject, body, blobList, attachmentNames);
    }
}