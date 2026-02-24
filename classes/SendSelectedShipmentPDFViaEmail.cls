/*Description      	: to send selected dockets email to the shippper email on pickup.
 *Author     		: rafi.khan@bvclogistics.com
 *Date       		: 20-12-2023
 *update by         : This class is updated by Govind, to replace email message part by sendGrid integration to send emails.
 *Modified date     : 17/01/2024
 *updated by		: Rafi Khan - added code for sending authority letter with selected dockets.
 *Modified date		: 26/02/2024
 * @updated By    	: Shaik Imran - added code for send email only for selected states
 * @Modified Date 	: 04-11-2024
 *updated by		: Rafi Khan - added code for sending authority letter with dockets for Bihar Only.
 *Modified date	 	: 25/09/2025
*/
public with sharing class SendSelectedShipmentPDFViaEmail {
    private static Map<String, List<String>> emailToRecordIdsMap = new Map<String, List<String>>();

    public static void sendPDF(List<List<String>> argsList) {
        System.debug('Args List: ' + argsList);

        for (List<String> args : argsList) {
            for (Integer i = 0; i < args.size(); i += 2) {
                if (i + 1 < args.size()) {
                    String email = args[i];
                    String recordId = args[i + 1];

                    if (!emailToRecordIdsMap.containsKey(email)) {
                        emailToRecordIdsMap.put(email, new List<String>());
                    }

                    if (!emailToRecordIdsMap.get(email).contains(recordId)) {
                        emailToRecordIdsMap.get(email).add(recordId);
                    }
                }
            }
        }

        
        for (String email : emailToRecordIdsMap.keySet()) {
            List<String> recordIds = emailToRecordIdsMap.get(email);
            sendBatchedEmailWithAttachments(email, recordIds);
        }
    }

      public static void sendBatchedEmailWithAttachments(String email, List<String> recordIds) {
     
        String emailBody = 'Dear Customer,<br>Kindly verify and download the Dockets attached below:<br><br>';

        Map<String, Shipment__c> shipmentMap = new Map<String, Shipment__c>(
            [SELECT Shipping_Note_Number__c, Pickup__c, Pickup__r.Name, Name,
             Origin_Address_State__c, Destination_Address_State__c
             FROM Shipment__c 
             WHERE Id IN :recordIds]);

        String pickupName = '';
        Blob pdfBlob;
        Blob pdfBlob1;
        
        List<blob> blobList = new List<Blob>();
        
        List<string> attachmentNames = new List<string>();
             
        for (String recordId : recordIds) {
            PageReference invoicePDF = Page.TMS_ShippingNewPdfPage; 
            invoicePDF.getParameters().put('Id', recordId);
            
            PageReference authorityLetterPDF = Page.TMS_AuthorityLetterPDF; 
            authorityLetterPDF.getParameters().put('Id', recordId);
           
            String shippingNoteNumber = '';
            String shippingNoteNumber1 = '';

            Shipment__c shipment = shipmentMap.get(recordId);

            if (shipment != null) {
                shippingNoteNumber = shipment.Shipping_Note_Number__c;
                attachmentNames.add(shippingNoteNumber +'.pdf');
                
                //attachmentNames.add(shippingNoteNumber +'- Authority Letter.pdf');
                
                if (shipment.Pickup__c != null) {
                    pickupName = shipment.Pickup__r.Name; 
                }

                try {
                    pdfBlob = invoicePDF.getContent();
                    blobList.add(pdfblob);
                    
                   // pdfBlob1 = authorityLetterPDF.getContent();
                   // blobList.add(pdfBlob1);
                    
                    
                    System.debug('for checking shipment.Origin_Address_State__c '+shipment.Origin_Address_State__c);
                    System.debug('for checking shipment.Destination_Address_State__c '+shipment.Destination_Address_State__c);
                    // below 90 to 95 commented by Imran
                    // Uncommented from 93 to 97 by Rafi for Maharashtra state - 16-12-2025.
                    if (shipment.Origin_Address_State__c == 'Jharkhand' || shipment.Destination_Address_State__c == 'Jharkhand' || shipment.Origin_Address_State__c == 'Jharkhand' || shipment.Destination_Address_State__c == 'Jharkhand') {
                        pdfBlob1 = authorityLetterPDF.getContent();
                        blobList.add(pdfBlob1);
                        attachmentNames.add(shippingNoteNumber + '- Authority Letter.pdf');
                    }
                	
                    // below line added by Imran 98 to 110
                    /*try
                    {
                        State_Access__c statesRecord = [select Id,Name,Current_User__c,Selected_Sates__c from State_Access__c limit 1];
                        if(statesRecord.Selected_Sates__c.contains(shipment.Origin_Address_State__c) || statesRecord.Selected_Sates__c.contains(shipment.Destination_Address_State__c))
                        {
                            pdfBlob1 = authorityLetterPDF.getContent();
                            blobList.add(pdfBlob1);
                            attachmentNames.add(shippingNoteNumber + '- Authority Letter.pdf');
                        } 
                    }
                    catch(Exception e){
                        
                    }*/
                    
                    emailBody += 'Shipping Note Number: ' + shippingNoteNumber + '<br>';
                    emailBody += 'Shipment Name: ' + shipment.Name + '<br><br>'; 
                } catch (VisualforceException e) {
                    pdfBlob = Blob.valueOf('Error generating docketPDF: ' + e.getMessage());
                    pdfBlob1 = Blob.valueOf('Error generating authorityLetterPDF: ' + e.getMessage());

                }
            }
        }
 
        emailBody += 'Pickup Name: ' + pickupName + '<br><br>';
        emailBody += 'Thank you!<br>Regards,<br>Team BVC.';
       
        string subject = '';
         if (!recordIds.isEmpty()) {
            subject = ('Digital Shipping Note PDFs for Pickup: ' + pickupName);
        } else {
            subject = ('Digital Shipping Note PDFs');
        }
        
          List<string>EmailList = new List<string>();
          EmailList.add(email);
          
          sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject, emailBody, blobList, attachmentNames);
          
          
          /*try{
              if (!blobList.isEmpty()) {
                  List<String> EmailList = new List<String>{email};
                  sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject, emailBody, blobList, attachmentNames);
              } else {
                  System.debug('No PDFs generated. Email not sent.');
              }
          }catch(Exception ex){
              System.debug('for checking ex.getMessage()'+ex.getMessage());
              System.debug('for checking ex.getLineNumber() '+ex.getLineNumber());
          }*/
      }
    
}