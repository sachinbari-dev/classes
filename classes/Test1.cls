public class Test1 {

    
    public static void getPDFBlobFromQuote(Id quoteId) {
        // Query for the ContentDocumentLink related to the Quote
        set<string> contentId = new set<string>();
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :quoteId 
        ];
     
        
        List<contentDistribution> cdList = [SELECT Id, ContentVersionId, ContentDocumentId, PdfDownloadUrl, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution where ContentDocumentId=:quoteId];
       
        if(!cdList.isEmpty()){
            downloadPDF(cdList[0].PdfDownloadUrl);
        }
        /*
        if (!docLinks.isEmpty()) {
            // Get the latest ContentVersion for the first ContentDocument
            List<ContentVersion> contentVersions = [
                SELECT VersionData 
                FROM ContentVersion 
                WHERE ContentDocumentId = '0690T000002FW1JQAW'
                ORDER BY VersionNumber DESC
                LIMIT 1
            ];

            if (!contentVersions.isEmpty()) {
                // Return the PDF Blob
                
              //  return contentVersions[0].VersionData;
            } else {
                System.debug('No ContentVersions found for the ContentDocument.');
                return null;
            }
        } else {
            System.debug('No ContentDocumentLinks found for the Quote.');
            return null;
        }  */
    }

       
    public static Blob downloadPDF(String pdfUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(pdfUrl);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            system.debug( 'file body@@@@+'+ res.getBodyAsBlob());
            sendPDFToAPI(pdfUrl,res.getBodyAsBlob());
            return res.getBodyAsBlob();
            
        } else {
            System.debug('Failed to download PDF. HTTP Status: ' + res.getStatusCode());
            return null;
        }
    }
    


    public static void sendPDFToAPI(String apiUrl, Blob pdfBlob) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl);
        req.setMethod('POST');
        
        // Set the boundary string for the multipart/form-data
        String boundary = '---------------------------' + String.valueOf(Datetime.now().getTime());
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);

        // Construct the multipart/form-data body
        String header = '--' + boundary + '\r\n' +
                        'Content-Disposition: form-data; name="file"; filename="filename.pdf"\r\n' +
                        'Content-Type: application/pdf\r\n\r\n';
        String footer = '\r\n--' + boundary + '--\r\n';

        // Convert header and footer to Blob
        Blob headerBlob = Blob.valueOf(header);
        Blob footerBlob = Blob.valueOf(footer);
        
        // Combine the Blobs by converting to base64 strings
        String bodyString = headerBlob.toString() + pdfBlob + footerBlob.toString();
      
       Blob bodyBlob = Blob.valueOf(bodyString);
     //   Blob bodyBlob = pdfBlob;
         system.debug('blob body'+bodyBlob );
        req.setBodyAsBlob(bodyBlob);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            system.debug('response body' + res.getBodyAsBlob());
            
            contentVersion cv = new ContentVersion();
              cv.Title = 'quote pdf';
              cv.FirstPublishLocationId = 'a1D0T000001Dg1NUAS';
              cv.VersionData =  res.getBodyAsBlob();
              cv.PathOnClient = 'title';
              cv.ContentUrl = '';
               insert CV;
            
              system.debug('CVid'+ cv);
            System.debug('PDF uploaded successfully to the API.');
        } else {
            System.debug('Failed to upload PDF to the API. HTTP Status: ' + res.getStatusCode());
            System.debug('Response: ' + res.getBody());
        }
    }
   /*
    // Test method to demonstrate usage
    public static void testMethod1(Id quoteId, String apiUrl) {
        Blob pdfBlob = getPDFBlobFromQuote(quoteId);
        if (pdfBlob != null) {
            sendPDFToAPI(apiUrl, pdfBlob);
        } else {
            System.debug('Failed to retrieve PDF for the Quote.');
        }
    }   */
}