public class RoadLinehaulEmailPreAlert {
    
 @InvocableMethod
    public static void createSheetofRecord(List<list<string>>recid){
        List<String> idList = recid[0];
        String emails = idList[0];
        String recordId = idList[1]; 

        
        Linehaul_Tracking__c line = [
            SELECT Id, Name, AWB_Number__c, Finalized_Linehaul_Number__c, Vehicle_Number__c, Origin__c, Destination__c,
                   Airline__c, Total_Number_of_Airline_Packages__c, No_of_Shipment_Notes__c, No_of_Package__c,
                   No_of_Trunks__c, No_of_OSB__c, No_of_OST__c, No_of_Airline_Trunk__c, Flight_Date__c, Estimate_Time_of_Arrival__c,
                   Description__c, Estimate_Time_of_Departure__c, CreatedDate, Flight_Number__c,
                   (SELECT Id, Finalised_Linehaul_Number__c, Origin_City__c, Destination_City__c, Trunk_Id__r.Name, Seal_Id__r.Name,
                           Right_Seal_Id__r.Name, Shipping_Note_Number__c, Shipper_Account__c, Consignee_Account__c,
                           Shipment_Origin__c, Shipment_destination__c, Secure_Bag__r.Name, Master_AWB__c, Linehaul_Tracking__c,
                           Shipment__r.Shipper_Name_TMS__c, Shipment__r.Consignee_Name_TMS__c,
                           Shipment__r.Origin__c, Shipment__r.Destination__c, Airline_Trunk__c, Oversize_bag__c, Oversize_Trunk__c
                    FROM Secure_Bags__r)
            FROM Linehaul_Tracking__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Prepare CSV
        String csvbody = 'Finalized Linehaul Number,Origin,Destination,Vehicle Number,Flight_Date,No.of Shipping Notes,Total Number of Airline Packages,No of Packages\n';
        String csvbody1 = 'Finalized Linehaul Number,Trunk No,Oversize Bag,Oversize Trunk,Airline Trunk,Left Seal Id, Right Seal Id, Shipping Note Number,Shipper Account,Consignee Account,Shipment origin,Origin City,Shipment Destination,Destination City,Secure Bag No\n';

        for (secure_bag__c sb : line.Secure_Bags__r) {
            csvbody1 += '"' + sb.Finalised_Linehaul_Number__c + '","' + sb.Trunk_Id__r.Name + '","' + sb.Oversize_bag__c + '","' + sb.Oversize_Trunk__c + '","' + sb.Airline_Trunk__c + '","' + sb.Seal_Id__r.Name + '","' + sb.Right_Seal_Id__r.Name + '","' + sb.Shipping_Note_Number__c + '","' + sb.Shipper_Account__c + '","' + sb.Consignee_Account__c + '","' + sb.Shipment_Origin__c + '","' + sb.Origin_City__c + '","' + sb.Shipment_destination__c + '","' + sb.Destination_City__c + '","' + sb.Secure_Bag__r.Name + '"\n';
        }

        csvbody += '"' + line.Finalized_Linehaul_Number__c + '","' + line.Origin__c + '","' + line.Destination__c + '","' + line.Vehicle_Number__c + '","' + line.Flight_Date__c + '","' + line.No_of_Shipment_Notes__c + '","' + line.Total_Number_of_Airline_Packages__c + '","' + line.No_of_Package__c + '"\n';

        // Email body
        Datetime originalDate = line.Flight_Date__c;
        String formattedDate = originalDate.format('MMMM dd, yyyy');

        String body = 'Hello Team ' + line.Destination__c + ',<br/><br/>';
        body += 'Here are the details of the pre-alert:<br/><br/>';
        body += 'Date: ' + line.Flight_Date__c + ' <br/>';
        body += 'Finalized Linehaul Number: ' + line.Finalized_Linehaul_Number__c + '<br/>';
        body += 'Total No. of Airline Packages: ' + line.Total_Number_of_Airline_Packages__c + '<br/>';
        body += 'No. of Shipping Notes: ' + line.No_of_Shipment_Notes__c + '<br/>';
        body += 'No. of Secure Bags: ' + line.No_of_Package__c + '<br/>';
        body += 'From: ' + line.Origin__c + '<br/>';
        body += 'To: ' + line.Destination__c + '<br/>';
        body += 'Thank you.<br/><br/>';
        body += 'Regards,<br/>Team BVC';

        String subject = 'Road Movement Pre-Alert - ' + line.Vehicle_Number__c + ' from ' + line.Origin__c + ' - ' + line.Description__c + ' - ' + formattedDate;

        // Attachments
        Blob csvBodyBlob = Blob.valueOf(csvbody);
        Blob csvBody1Blob = Blob.valueOf(csvbody1);
        List<Blob> blobList = new List<Blob>{csvBodyBlob, csvBody1Blob};
        List<String> attachmentNames = new List<String>{'Road Movement Summary.csv', 'Road Movement Details.csv'};

        // Send email
        List<String> EmailList = new List<String>{emails};
        sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject, body, blobList, attachmentNames);

        // Update email status
        line.Email_Status__c = 'sent';
        update line;
          
        /*
          
          Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Road Movement Summary.csv');
            attachment.setBody(Blob.valueOf(csvBody));
        
          Messaging.EmailFileAttachment attachment1 = new Messaging.EmailFileAttachment();
            attachment1.setFileName('Road Movement Details.csv');
            attachment1.setBody(Blob.valueOf(csvBody1));
     
        List<Linehaul_Tracking__c > linelist = [select id,Vehicle_Number__c,Email_status__c,Email_error_message__c from Linehaul_Tracking__c where id=:recordId LIMIT 1];
        
           List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
           Map<Messaging.SingleEmailMessage, Linehaul_Tracking__c> emailToLinehaulMap = new Map<Messaging.SingleEmailMessage, Linehaul_Tracking__c>();

             for(Linehaul_Tracking__c l :linelist ){
                 if (l != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Road Movement Pre-Alert -'+' '+ line.Vehicle_Number__c +' '+ 'from'+' ' + line.Origin__c +'-'+' '+ line.Description__c +'-'+' '+ formattedDate);
                    email.setHtmlBody(body);
                    email.setToAddresses(new String[] { emails });
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment, attachment1 });
        
                    emailsToSend.add(email);
                    emailToLinehaulMap.put(email, l);
                }
                // Send email
            
         //   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
          
               }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend);

    // Process email results
            Integer index = 0; // Track index for results
            for (Messaging.SendEmailResult result : results) {
                Messaging.SingleEmailMessage email = emailsToSend[index];
                Linehaul_Tracking__c linehaul = emailToLinehaulMap.get(email);
                index++;
        
                if (result.isSuccess()) {
                    if (linehaul != null) {
                        linehaul.Email_Status__c = 'Sent';
                        update linehaul;
                    }
                } else {
                    if (linehaul != null) {
                        linehaul.Email_Status__c = 'Error';
                        linehaul.Email_Error_Message__c = result.getErrors()[0].getMessage();
                        update linehaul;
                    }
                }
            }
         */
    }
}