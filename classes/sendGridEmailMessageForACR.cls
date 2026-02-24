/*Class               : sendGridEmailMessageForACR
 *Author              : govind.sangale@bvclogistics.com
 *Modified Date       : 07 May 2024
 */


public class sendGridEmailMessageForACR {

    @Future(callout=true)
    public static void sendGridEmailMessages(List<String> toEmails, List<String> ccEmails, String subject, String body){
        
        // Variables to store endpoint, SendGrid key, and sender email.
        String endpoint = '';  
        String key = '';  
        String senderEmail = '';
        
        // Custom metadata type to make endpoint and key dynamic and assign endpoint and key values from this metadata.
        
        List<sendGrid__mdt> mdtList = [SELECT endpoint__c, key__c, ACR_Sender_Email__c FROM sendGrid__mdt WHERE label ='EndpointKey' LIMIT 1];
        
        system.debug('sendGrid metadata' + mdtList);
        
        if(!mdtList.isEmpty()){
            endpoint = mdtList[0].endpoint__c;
            key = mdtList[0].key__c;
            senderEmail = mdtList[0].ACR_Sender_Email__c;
            
            system.debug('endpoint@@@'+ endpoint);
            system.debug('key@@@@'+ key);
            system.debug('senderEmail@@@@'+ senderEmail);
            
            // Construct the email JSON payload.
             
          Map<String, Object> emailContent = new Map<String, Object>{
                'personalizations' => new List<Map<String, Object>>{
                                                                    new Map<String, Object>{
                                                                        'to' => new List<Map<String, String>>{},
                                                                        'cc' => new List<Map<String, String>>{},
                                                                        'subject' => subject
                                                                    }
                },
                'from' => new Map<String, String>{ 'email' => senderEmail },
                'custom_args' => new Map<String, String>{
                    'module' => 'SF',
                    'extra_info' => 'additional_data'
                },
                'content' => new List<Map<String, String>>{
                    new Map<String, String>{ 'type' => 'text/plain', 'value' => body },
                    new Map<String, String>{ 'type' => 'text/html', 'value' => body }
                }
            };

            
            // Add recipients to the email payload directly.
            
            List<Map<String, String>> toList = new List<Map<String, String>>();
            for(String toEmail : toEmails) {
                toList.add(new Map<String, String>{ 'email' => toEmail });
            }
            
            ((List<Map<String, Object>>)emailContent.get('personalizations')).get(0).put('to', toList);
            
            List<Map<String, String>> ccList = new List<Map<String, String>>();
            
            for(String ccEmail : ccEmails) {
                ccList.add(new Map<String, String>{ 'email' => ccEmail });
            }
            ((List<Map<String, Object>>)emailContent.get('personalizations')).get(0).put('cc', ccList);
            
                // Perform the HTTP callout to send the email.
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setTimeout(120000); 
                req.setHeader('Authorization', 'Bearer ' + key);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(emailContent));
                
                HttpResponse res = http.send(req);
                    
            if(res.getStatusCode() == 202){
                System.debug('Email sent successfully' + res.getStatus());
            } else {
                System.debug('Email was not sent');
            }
        } else {
            System.debug('No SendGrid metadata found.');
        }
    }
}