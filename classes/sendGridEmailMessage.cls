/*
   Class Name       :   sendGridEmailMessage
   Description      :   helper Class to send emails using sendGrid endpoint 
   Description   	:   Method that provides provision to set email address,subject of email,body,attachment and attachment name
   Input Parameter	:	ID
   return type   	:   
   Developer Name   :   Mr.Sangale Govind    
   Created Date     :   11/01/2024
   Development Type :   REST API Integration with SendGrid using key Authorization.
*/

public class sendGridEmailMessage {
 
  //  @future(callout =true)
    public static void sendGridEmailMessages(List<String> toEmails, String subject, String body){
       
        // veriable to store endpoint ,sendGrid key and senderEmail.
        
        String Endpoint = '';  
        String key = '';  
        string SenderEmail = '';
        
        // custom metadata type to make endpoint and key dynamic and assign endpoint and key values from this metadata.
        List<sendGrid__mdt> mdtList = [select id,endpoint__c,key__c,Sender_Email__c from sendGrid__mdt where label ='EndpointKey' Limit 1];
        
        system.debug('sendGrid metadata' + mdtList);
        
            for(sendGrid__mdt m: mdtList){
                EndPoint = mdtList[0].endpoint__c;
                key = mdtList[0].key__c;
                SenderEmail = mdtList[0].Sender_Email__c;
                
                system.debug('endpoint@@@'+ EndPoint);
                system.debug('key@@@@'+ key);
                system.debug('senderEmail@@@@'+ SenderEmail);
            }

        // Loop over list of email to send bulk email or single email- this is managing both single and bulk operation, we need to send List of email only.
             
        for(string emails : toEmails ){
            
           String emailContent = '{"personalizations": [{"to": [{"email": "' + emails + '"}]}],"from": {"email": " '+ SenderEmail +'"},"subject": "' + subject + '","custom_args": {"module": "SF","extra_info": "additional_data"},"content": [{"type": "text/plain", "value": "' + body + '"},  {"type": "text/html", "value": "' + body + '"}]}';
            system.debug('emailContent request@@@' + emailContent);

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