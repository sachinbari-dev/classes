public class IndigoAWBTrackingControllerBatchHelper {

    
    @AuraEnabled(cacheable=false)
    public static AWBTrackingWrapper getTrackingDetails(String awbNumber,string token, string sessionId) {
        AWBTrackingWrapper result = new AWBTrackingWrapper();
      
            String loginName = '';
            String station = '';
            String awbPrefix = '';
            String endpoint = '';
            
            List<Airline_API__mdt> indigoAirline = [ SELECT LoginName__c, Station__c, AWB_Prefix__c, Endpoint__c FROM Airline_API__mdt WHERE DeveloperName = 'Indigo_Track_AWB' LIMIT 1];
            
            if(!indigoAirline.isEmpty()){
                endpoint = indigoAirline[0].Endpoint__c;
                loginName = indigoAirline[0].LoginName__c;
                station = indigoAirline[0].Station__c;
                awbPrefix = indigoAirline[0].AWB_Prefix__c;
            } 
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setBody('{"loginName":"'+ loginName +'","sessionId":"'+ sessionId +'","awbPrefix":"'+ awbPrefix +'","awbNumber":"'+ awbNumber +'","station":"'+ station +'","TokenNumber":"'+ token +'"}');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                indigo_TrackAWBResponseWrapper responseWrap = indigo_TrackAWBResponseWrapper.parse(res.getBody());
                String d = responseWrap.d;
                String jsonPart = d.subStringBetween('RESULT_START:',':RESULT_END');
                system.debug('jsonPart' + jsonPart);
                if(String.isNotBlank(jsonPart)){
                    //result = (AWBTrackingWrapper) JSON.deserialize(jsonPart, AWBTrackingWrapper.class);
                     AWBTrackingWrapper apiWrapper = (AWBTrackingWrapper) JSON.deserialize(jsonPart, AWBTrackingWrapper.class);
                        
                        result.Table1 = apiWrapper.Table1;
                     
                }

                return result;
            } else {
                throw new AuraHandledException('Error ' + res.getStatusCode() + ': ' + res.getBody());
            }
       
    }

     public static void sendEmailfOffloaded(List<Linehaul__c> lineList) {
                Set<String> hubNames = new Set<String>();
                for (Linehaul__c l : lineList) {
                    if (String.isNotBlank(l.Origin__c)) hubNames.add(l.Origin__c);
                    if (String.isNotBlank(l.Destination__c)) hubNames.add(l.Destination__c);
                }
            
                Map<String, Hub__c> hubsByName = new Map<String, Hub__c>();
                for (Hub__c h : [
                    SELECT Id, Name, City__c, Hub_Email_ID__c, Branch__c
                    FROM Hub__c
                    WHERE Name IN :hubNames
                ]) {
                    hubsByName.put(h.Name, h);
                }
            
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
                for (Linehaul__c l : lineList) {
                    Hub__c originHub = hubsByName.get(l.Origin__c);
                    Hub__c destHub   = hubsByName.get(l.Destination__c);
            
                    List<String> toEmails = new List<String>();
                    String subject = '🚨 Indigo Offloaded Notification - ' + l.AWB_Number__c 
                                       + ' | Flight No: ' + l.Flight_Number__c 
                                       + ' | Flight Date: ' + l.Flight_Date__c;
            
                    String body = 'Dear Team,' + '<br/><br/>'
                                    + 'Please note the following AWBs have been OFFLOADED:' + '<br/><br/>'
                                    + 'AWB Number: ' + l.AWB_Number__c + '<br/>'
                                    + 'Flight No: ' + l.Flight_Number__c + '<br/>'
                                    + 'Flight Date: ' + l.Flight_Date__c + '<br/><br/>';
                        
                    if (originHub != null) {
                        body += 'Origin Hub: ' + originHub.Name + '<br/>';
                        if (!String.isBlank(originHub.Hub_Email_ID__c)) {
                            toEmails.add(originHub.Hub_Email_ID__c);
                        }
                    }
            
                    if (destHub != null) {
                        body += 'Destination Hub: ' + destHub.Name + '<br/>';
                        if (!String.isBlank(destHub.Hub_Email_ID__c)) {
                            toEmails.add(destHub.Hub_Email_ID__c);
                        }
                    }
            
                    body += '<br/>Regards,<br/>✈ Salesforce AWB Tracking System';
            
                    
                    toEmails = new List<String>(new Set<String>(toEmails));
            
                    if (!toEmails.isEmpty()) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toEmails);
                        mail.setSubject(subject);
                        mail.setHtmlBody(body);
                        emails.add(mail);
                    }
                }
            
             
                if (!emails.isEmpty()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                }
    }

    public class AWBTrackingWrapper {
  
         @AuraEnabled public List<Table1> Table1;
       
    }
   
    public class Table1{
        public String Milestone;
            public String FlightNo;
            public String FlightDate;
    }
    
    
    
}