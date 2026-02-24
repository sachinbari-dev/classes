public class attachACRPDFToBVCQuote {

    
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


    
    public static void addFile(List<Id> quoteId){
        
        List<ContentVersion> cvList = new List<ContentVersion>();
         Blob pdfBlob;     
        BVCQuote__c quote = [select id,name,BVC_Service__c from BVCQuote__c where id IN :quoteId];
        if(quote.BVC_Service__c == 'ExhibiSHIP'){
            for(ID bvcq : quoteId) {
            PageReference pdfPage = Page.BVC_QuoteExhibishipPdfPage;
            pdfPage.getParameters().put('id', bvcq);
            
            try {
                if (!Test.isRunningTest()) {
                    pdfBlob = pdfPage.getContentAsPDF();
                } else {
                    pdfBlob = Blob.valueOf('Test PDF content');
                }
                String currentDate = String.valueOf(Date.today()).removeEnd(' 00:00:00');
              
                 ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'ACR Order Form'+'-'+ currentDate;
                contentVersion.PathOnClient = 'ACR Order Form.pdf';
                contentVersion.VersionData = pdfBlob;
                contentVersion.IsMajorVersion = true;
                contentVersion.FirstPublishLocationId = bvcq;

                cvList.add(contentVersion);
                
            } catch (Exception e) {
                System.debug('Exception while generating PDF: ' + e.getMessage());
            }
        }
        }else{
           
            for(ID bvcq : quoteId) {
            PageReference pdfPage = Page.BVCACRPdfVFpage;
            pdfPage.getParameters().put('id', bvcq);
            
            try {
                if (!Test.isRunningTest()) {
                    pdfBlob = pdfPage.getContentAsPDF();
                } else {
                    pdfBlob = Blob.valueOf('Test PDF content');
                }
                String currentDate = String.valueOf(Date.today()).removeEnd(' 00:00:00');
              
                 ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'ACR Order Form'+'-'+ currentDate;
                contentVersion.PathOnClient = 'ACR Order Form.pdf';
                contentVersion.VersionData = pdfBlob;
                contentVersion.IsMajorVersion = true;
                contentVersion.FirstPublishLocationId = bvcq;

                cvList.add(contentVersion);
                
            } catch (Exception e) {
                System.debug('Exception while generating PDF: ' + e.getMessage());
            }
        }
       }
       
        if(pdfBlob != null){
            sendEmailToCustomer(quoteId, pdfBlob);
        }
        
         
        if(!cvList.isEmpty()){
            insert cvList;
        }

        
    }

    @Future(callout=true)
    public static void sendEmailToCustomer (List<Id> quoteId, blob pdfFile){
        
       List<BVCQuote__c> QuoteList = [select id,Name,Account__r.Name,status__c from BVCQuote__c where ID IN: quoteId];
        
       List<People_Role__c>  peopleList=[ SELECT Role__c, BVCQuote__c, People__r.Name,People__r.Email, Name, Id FROM People_Role__c where BVCQuote__r.id IN :quoteId];
       system.debug('QuoteList'+ QuoteList);
        system.debug('QuoteList'+ QuoteList);
        
        List<string> ToEmail = new List<string>();
        List<string> CcEmail = new List<string>();
        set<id> AccId =  new Set<id>();
        
        string customerName= '';
        string QuoteName= '';
        
        for(BVCQuote__c bq : QuoteList){
            if(bq.status__c == 'Quote Sent'){
                customerName = bq.Account__r.Name;
                QuoteName = bq.name;
                AccId.add(bq.Account__c);
                for(People_Role__c pr : peopleList ){
                    ToEmail.add( pr.People__r.Email);
                    system.debug('ToEmail'+ ToEmail);
                }
            }
        }
        
        Account Acc = [select id, name , owner.name,owner.email from Account where ID IN: AccId];
        
        DateTime now = DateTime.now();
       
        Integer month = now.month();
        Integer year = now.year();
        
        String monthName = DateTime.newInstance(year, month, 1).format('MMMM');
         
        string subject = ' BVC Quotation '+' '+ QuoteName +' '+'for'+' '+ customerName+' '+monthName +' '+ year;
        
        string body ='Dear '+' '+ customerName +',' + '<br/><br/>';
                body = body + 'Greetings from BVC, the most secured logistics partner, having more than 60 years of experience in handling precious shipments !!!' + '<br/><br/>';
                body = body + 'Thank you for showing your interest to choose BVC as your logistics partner and giving us this opportunity to submit our quotation'+' <br/><br/>';
                body = body + 'Please find attached BVC’s quotation for services required by you. This quotation is valid for 30 days'+'<br/><br/>';
                body = body + 'If you have any clarifications regarding this quote, please feel free to get in touch with me '+'<br/><br/>';
                body = body + 'Looking forward to a long standing relationship between BVC and'+' '+ customerName +'<br/><br/>';
                body = body + 'Thanks and Regards,'+'<br/>';
                body = body + Acc.owner.name + '<br/>';
                body = body + Acc.owner.email + '<br/>';
                body = body +'BVC Logistics Pvt. Ltd.';  
        
      List<blob> blobList = new List<blob>{pdfFile} ;             
      List<string> attachmentNames = new List<string>{'ACR Order Form.pdf'};
         
       BVC_QuoteSendGridEmailAttachment.sendGridEmailMessagesAttachment(ToEmail, subject, body, blobList, attachmentNames);
        
    }
}