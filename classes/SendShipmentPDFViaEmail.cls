/*Class          : SendShipmentPDFViaEmail
*Author          : Sanket.pisal@bvclogistics.com
*Date            : Aug 2023
*update by		 : This class is updated by Govind, to replace email message part by sendGrid integration to send emails.
*Modified date	 : 17/01/2024
*updated by		 : Rafi Khan - added code for sending authority letter with dockets.
*Modified date	 : 27/02/2024
*@updated By    : Shaik Imran - added code for send email only for selected states
*@Modified Date : 04-11-2024
*updated by		 : Rafi Khan - added code for sending authority letter with dockets for Bihar Only.
*Modified date	 : 25/09/2025
*updated by		 : Imran Shaik - replaced the VF Page with renderd as PDF.
*Modified date	 : 20/10/2025
*/
public with sharing class SendShipmentPDFViaEmail {
    private static Map<String, List<String>> emailToRecordIdsMap = new Map<String, List<String>>();
    
    @InvocableMethod(label='Shipment DSN details PDF' description='Generates and Emails a DSN PDF')
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
		System.debug('46 emailBody: ' + emailBody);        
        Map<String, Shipment__c> shipmentMap = new Map<String, Shipment__c>(
            [SELECT Shipping_Note_Number__c, Pickup__c, Pickup__r.Name, Name,
             Origin_Address_State__c, Destination_Address_State__c
             FROM Shipment__c 
             WHERE Id IN :recordIds]);
        System.debug('52 shipmentMap: ' + shipmentMap); 
        String pickupName = '';
        Blob pdfBlob;
        Blob pdfBlob1;
        
        List<blob> blobList = new List<Blob>();
        List<string> attachmentNames = new List<string>();
        
        for (String recordId : recordIds) { System.debug('60 recordId: ' + recordId); 
            PageReference invoicePDF = Page.TMS_ShippingNewPdfPage;	// commented by Imran on 20/10/2025
            //PageReference invoicePDF = Page.TMS_ShippingNewPdfPage1;	// added by Imran on 20/10/2025
            invoicePDF.getParameters().put('Id', recordId);
            
            PageReference authorityLetterPDF = Page.TMS_AuthorityLetterPDF; 
            authorityLetterPDF.getParameters().put('Id', recordId);
            
            
            String shippingNoteNumber = '';
            Shipment__c shipment = shipmentMap.get(recordId);
            System.debug('70 shipment: ' + shipment); 
            if (shipment != null) {
                shippingNoteNumber = shipment.Shipping_Note_Number__c;
                attachmentNames.add(shippingNoteNumber +'.pdf');
                
                //attachmentNames.add(shippingNoteNumber +'- Authority Letter.pdf');
                
                if (shipment.Pickup__c != null) {
                    pickupName = shipment.Pickup__r.Name; 
                }
                System.debug('80 shipment.Pickup__c: ' + shipment.Pickup__c); 
                try {System.debug('81 shipment.Pickup__c '); 
                    pdfBlob = invoicePDF.getContent();
                    blobList.add(pdfblob);
                    System.debug('81 shipment.Pickup__c '); 
                    //pdfBlob1 = authorityLetterPDF.getContent();
                    //blobList.add(pdfBlob1);
                    
                    System.debug('for checking shipment.Origin_Address_State__c '+shipment.Origin_Address_State__c);
                    System.debug('for checking shipment.Destination_Address_State__c '+shipment.Destination_Address_State__c);
                    
                    
                    if (shipment.Origin_Address_State__c == 'Jharkhand' || shipment.Destination_Address_State__c == 'Jharkhand' || shipment.Origin_Address_State__c == 'Jharkhand' || shipment.Destination_Address_State__c == 'Jharkhand') {
                        pdfBlob1 = authorityLetterPDF.getContent();
                        blobList.add(pdfBlob1);
                        attachmentNames.add(shippingNoteNumber + '- Authority Letter.pdf');
                    }
                     
                     
                    // added by Imran
                   // String userId =UserInfo.getUserId();
                   // System.debug('userId :'+userId);
                    /*try
                    {
                        //State_Access__c statesRecord = [select Id,Name,Current_User__c,Selected_Sates__c from State_Access__c 
                                                        //where Current_User__c=:userId limit 1]; 
                        System.debug('104 shipment.Pickup__c '); 
                        State_Access__c statesRecord = [select Id,Name,Current_User__c,Selected_Sates__c from State_Access__c limit 1];
                        if(statesRecord.Selected_Sates__c.contains(shipment.Origin_Address_State__c) || statesRecord.Selected_Sates__c.contains(shipment.Destination_Address_State__c))
                        {
                            pdfBlob1 = authorityLetterPDF.getContent();
                            blobList.add(pdfBlob1);
                            attachmentNames.add(shippingNoteNumber + '- Authority Letter.pdf');
                        } 
                        System.debug('111 statesRecord:'+statesRecord);
                    }
                    catch(Exception e){
                        
                    }*/

                    // upto here
                    
                    emailBody += 'Shipping Note Number: ' + shippingNoteNumber + '<br>';
                    emailBody += 'Shipment Name: ' + shipment.Name + '<br><br>'; 
                } catch (VisualforceException e) {
                    pdfBlob = Blob.valueOf('Error generating PDF: ' + e.getMessage());
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
        
    }
}