@RestResource(urlMapping='/generateQuotePdf')
global with sharing class GenerateQuotePdfRESTResource {
    
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        String quoteId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try {
            BVCnonAcrQuotePdfController.generateAndAttachPdf(Id.valueOf(quoteId));
            return 'PDF generated and attached successfully';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}