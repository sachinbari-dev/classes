/*
   Class Name       :   sendGridEmailMessageAttachments
   Description      :   helper Class to send emails using sendGrid endpoint 
   Description   	:   Method that provides provision to set email addresses,subject of email,body,attachments and attachment name
   Input Parameter	:	ID
   return type   	:   
   Developer Name   :   Mr.Sangale Govind    
   Created Date     :   11/01/2024
   Development Type :   REST API Integration with SendGrid using key Authorization.
   Modified Date    :   26/06/2025 (added Ops Email details for Linehual Email process)
   Modified By      :   Mr.Sangale Govind
*/

public class sendGridEmailMessageAttachments {

      @Future(callout=true)
     public static void sendGridEmailMessagesAttachment(List<String> toEmails, String subject, String body,List<Blob> attachments, List<String> attachmentNames){
       
         // veriable to store endpoint ,sendGrid key and senderEmail.
         
        String Endpoint = '';  
        String key = '';  
        string SenderEmail = '';
        
        // custom metadata type to make endpoint,key and sender Email dynamic and assign endpoint and key values from this metadata.
          List<sendGrid__mdt> mdtList = [select id,endpoint__c,key__c,Sender_Email__c,Ops_Email__c from sendGrid__mdt where label ='EndpointKey' Limit 1];
            system.debug('sendGrid metadata' + mdtList);
         
        //This subject condition sis only added for Linehaul process 
        
          if (subject != null && (subject.containsIgnoreCase('Road Movement Pre-Alert') || subject.containsIgnoreCase('MAWB Pre-Alert'))) {
            
            for(sendGrid__mdt m: mdtList){
                EndPoint = mdtList[0].endpoint__c;
                key = mdtList[0].key__c;
                SenderEmail = mdtList[0].Ops_Email__c;
                
                system.debug('endpoint@@@'+ EndPoint);
                system.debug('key@@@@'+ key);
                system.debug('senderEmail@@@@'+ SenderEmail);
            }
              
          }else{
           
             for(sendGrid__mdt m: mdtList){
                EndPoint = mdtList[0].endpoint__c;
                key = mdtList[0].key__c;
                SenderEmail = mdtList[0].Sender_Email__c;
                
                system.debug('endpoint@@@'+ EndPoint);
                system.debug('key@@@@'+ key);
                system.debug('senderEmail@@@@'+ SenderEmail);
            }
          }
         
         
        //  encode attachment-attachmentContent  and sendGrid request- emailContent this is handling multiple and single attachments, check content type 
        
        List<String> attachmentContents = new List<String>();
             
            for (Integer i = 0; i < attachments.size(); i++) {
               string  filetype = attachmentNames[i].substringAfterLast('.');
                
            String contentType;
            if (fileType.equalsIgnoreCase('pdf')) {
                contentType = 'application/pdf';
            } else if (fileType.equalsIgnoreCase('csv')) {
                contentType = 'text/csv';
            } else if (fileType.equalsIgnoreCase('xlsx')) {
                contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            } else if (fileType.equalsIgnoreCase('txt')) {
                contentType = 'text/plain';
            } else {        
                contentType = 'application/octet-stream';
         }
                
                attachmentContents.add('{"content": "' + EncodingUtil.base64Encode(attachments[i]) + '","filename": "' + attachmentNames[i] + '","type": "' + contentType + '"}');
            }
             
         String attachmentsPart = String.join(attachmentContents, ',');

        // Loop over multiple emails list to send emails on multiple mail id's.
         for(string emails : toEmails){
             
            //   String emailContent = '{"personalizations": [{"to": [{"email": "' + emails + '"}]}],"from": {"email": "' + senderEmail + '"},"subject": "' + subject + '","content": [{"type": "text/plain", "value": "' + body + '"}],"attachments": [' + attachmentsPart + ']}';
            //   System.debug('emailContent request@@@' + emailContent);
             String emailContent = '{"personalizations": [{"to": [{"email": "' + emails + '"}]}],"from": {"email": "' + senderEmail + '"},"subject": "' + subject + '","custom_args": {"module": "SF","extra_info": "additional_data"},"content": [{"type": "text/plain", "value": "' + body + '"}, {"type": "text/html", "value": "' + body + '"}],"attachments": [' + attachmentsPart + ']}';
             
             System.debug('emailContent request@@@' + emailContent);

       //Http callout to hit sendGrid endpoint to send emails
             
            http htt = new http();
            httpRequest req= new httpRequest();
            req.setEndpoint(Endpoint);
            req.setMethod('POST');
            req.setTimeout(120000); 
            req.setHeader('Authorization', 'Bearer ' + key);
            req.setheader('Content-Type', 'application/json');        
            req.setBody(emailContent);
            
            HttpResponse res = htt.send(req);
                    
                if(res.getStatusCode()==202){
                    system.debug('Email send successfully' + res.getStatus());
                   
                }else{
                    system.debug('Email is not send');
                }   
         }                      
        
    }
          
}