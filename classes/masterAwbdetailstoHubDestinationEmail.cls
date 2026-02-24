public class masterAwbdetailstoHubDestinationEmail {
    
   @InvocableMethod
    public static void  createMasterAwbSheet(List<List<String>> recid){
         List<String> idList = recid[0];
         String emails   = idList[0];
         String recordId = idList[1];      

  
        Linehaul_Tracking__c line = [
            SELECT Id, Name, AWB_Number__c, Finalized_Linehaul_Number__c, Origin__c, Destination__c,
                   Airline__c, Flight_Date__c, CreatedDate, Description__c, Flight_Number__c,
                   Estimate_Time_of_Departure__c, Estimate_Time_of_Arrival__c,
                   No_of_Shipping_Notes__c, No_of_Shipment_Notes__c, No_of_Packages__c, No_of_Package__c,
                   Total_Number_of_Airline_Packages__c, No_of_Trunks__c, No_of_OSB__c, No_of_OST__c,
                   No_of_Airline_Trunk__c, Linehaul_Name__r.Id, Linehaul_Name__r.Manual__c
            FROM Linehaul_Tracking__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        
        List<Secure_Bag__c> bagList = [
            SELECT Id, Finalised_Linehaul_Number__c, AWB_Number__c, Origin_City__c, Destination_City__c,
                   Trunk_Id__r.Name, Seal_Id__r.Name, Right_Seal_Id__r.Name, Shipping_Note_Number__c,
                   Shipper_Account__c, Consignee_Account__c, Shipment_Origin__c, Shipment_Destination__c,
                   Secure_Bag__r.Name, Master_AWB__c, Linehaul_Tracking__c, 
                   Shipment__r.Shipper_Name_TMS__c, Shipment__r.Consignee_Name_TMS__c,
                   Shipment__r.Origin__c, Shipment__r.Destination__c,
                   Airline_Trunk__c, Oversize_Bag__c, Oversize_Trunk__c
            FROM Secure_Bag__c
            WHERE Linehaul_Tracking__c = :recordId
        ];
        
        // CSV building
        String csvbody = 'AWB_Number__c,Finalized Linehaul Number,Origin__c,Destination__c,Select_Airline__c,Flight_Date__c,No.of Shipping Notes,Total Number of Airline Packages,No of Packages\n';       
        csvbody += '"' + line.AWB_Number__c + '","' + line.Finalized_Linehaul_Number__c + '","' + line.Origin__c + '","' +
                   line.Destination__c + '","' + line.Airline__c + '","' + line.Flight_Date__c + '","' +
                   line.No_of_Shipment_Notes__c + '","' + line.Total_Number_of_Airline_Packages__c + '","' +
                   line.No_of_Package__c + '"\n';

        String csvbody1 = 'Finalized Linehaul Number,AWB Number,Trunk No,Oversize Bag,Oversize Trunk,Airline Trunk,Left Seal Id, Right Seal Id, Shipping Note Number,Shipper Account,Consignee Account,Shipment origin,Origin City,Shipment Destination,Destination City,Secure Bag No\n';
        for(Secure_Bag__c sb : bagList){
            csvbody1 += '"' + sb.Finalised_Linehaul_Number__c + '","' + sb.AWB_Number__c + '","' + sb.Trunk_Id__r.Name + '","' + sb.Oversize_Bag__c + '","' +
                        sb.Oversize_Trunk__c + '","' + sb.Airline_Trunk__c + '","' + sb.Seal_Id__r.Name + '","' + sb.Right_Seal_Id__r.Name + '","' +
                        sb.Shipping_Note_Number__c + '","' + sb.Shipper_Account__c + '","' + sb.Consignee_Account__c + '","' + sb.Shipment_Origin__c + '","' +
                        sb.Origin_City__c + '","' + sb.Shipment_Destination__c + '","' + sb.Destination_City__c + '","' + sb.Secure_Bag__r.Name + '"\n';
        }
        
        Datetime originalDate = line.Flight_Date__c;
        String formattedDate = originalDate.format('MMMM dd, yyyy');

        string body ='Hello Team'+' '+ line.Destination__c +',' + '<br/><br/>';
                body = body + 'Here are the details of the pre-alert:' + '<br/><br/>';
                body = body + 'Date:'+' '+ line.CreatedDate +' <br/>';
                body = body + 'AWB:'+' '+ line.AWB_Number__c +'<br/>';
                body = body + 'Finalized Linehaul Number:'+' '+ line.Finalized_Linehaul_Number__c +'<br/>';
                body = body + 'Airline:'+' '+ line.Airline__c +'<br/>';
                body = body + 'Cargo type:'+ ' '+ line.Description__c +'<br/>';
                body = body + 'Total No. of Airline Packages:'+' '+ line.Total_Number_of_Airline_Packages__c+'<br/>';
                body = body + 'No. of Shipping Notes:'+' '+ line.No_of_Shipment_Notes__c+'<br/>';
                body = body + 'No. of Secure Bags:'+' '+ line.No_of_Package__c + '<br/>';
                body = body + 'From:'+' '+ line.Origin__c + '<br/>';
                body = body + 'To:'+' '+ line.Destination__c + '<br/>';
                body = body + 'Flight Number:'+' '+ line.Flight_Number__c + '<br/>';
                body = body + 'Departure Time:'+' '+ line.Estimate_Time_of_Departure__c +'<br/>';
                body = body + 'Arrival Time:'+' '+ line.Estimate_Time_of_Arrival__c + '<br/><br/>';
                body = body + 'Thank you.'+'<br/><br/>';
                body = body + 'Regards,' + '<br/>';
                body = body + 'Team BVC';
        
             
         string body1 ='Hello Team'+' '+ line.Destination__c +',' + '<br/><br/>';
                body1 = body1 + 'Here are the details of the pre-alert:' + '<br/><br/>';
                body1 = body1 + 'Date:'+' '+ line.CreatedDate +' <br/>';
                body1 = body1 + 'AWB:'+' '+ line.AWB_Number__c +'<br/>';
                body1 = body1 + 'Finalized Linehaul Number:'+' '+ line.Finalized_Linehaul_Number__c +'<br/>';
                body1 = body1 + 'Airline:'+' '+ line.Airline__c +'<br/>';     
                body1 = body1 + 'Total No. of Airline Packages:'+' '+ line.Total_Number_of_Airline_Packages__c+'<br/>';
                body1 = body1 + 'No. of Shipping Notes:'+' '+ line.No_of_Shipment_Notes__c+'<br/>';
                body1 = body1 + 'No. of Secure Bags:'+' '+ line.No_of_Package__c + '<br/>';
                body1 = body1 + 'From:'+' '+ line.Origin__c + '<br/>';
                body1 = body1 + 'To:'+' '+ line.Destination__c + '<br/>';                           
                body1 = body1 + 'Thank you.'+'<br/><br/>';
                body1 = body1 + 'Regards,' + '<br/>';
                body1 = body1 + 'Team BVC';

       // collect date from master awb record and store in attachment varible to send email. 
      
        string subject = 'MAWB Pre-Alert - ' + line.Name + ' from ' + line.Origin__c + ' - ' + line.Airline__c + ' - ' + line.Description__c + ' - ' + formattedDate;
        string subject1 = 'MAWB Pre-Alert -'+' '+ line.Name +' '+ 'from'+' ' + line.Origin__c +'-'+' '+ line.Airline__c +'-'+' '+ formattedDate;

        Blob csvBodyBlob  = Blob.valueOf(csvbody);
        Blob csvBody1Blob = Blob.valueOf(csvbody1);
        
        List<String> EmailList = new List<String>{emails};
        List<Blob> blobList = new List<Blob>{csvBodyBlob, csvBody1Blob};             
        List<String> attachmentNames = new List<String>{'AWB summary.csv','AWB details.csv'};

      
        if(line.Linehaul_Name__r.Manual__c == false){
            sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject, body, blobList, attachmentNames);
        } else {
            sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject1, body1, blobList, attachmentNames);
        }

        line.Email_Status__c = 'sent';
        update line;
    }
}