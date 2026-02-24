public class sendEmailToDestinations {

    @InvocableMethod
    public static void sendEmailOnDestinationEmail(List<String> recordId) {

       
        List<Linehaul_Tracking__c> linehaulTrackList = [
            SELECT Id, Name, AWB_Number__c, Finalized_Linehaul_Number__c, Origin__c, 
                   No_of_Shipping_Notes__c, Total_Number_of_Airline_Packages__c, 
                   No_of_Shipment_Notes__c, No_of_Packages__c, No_of_Package__c, 
                   No_of_Trunks__c, Flight_Date__c, Airline__c, Destination__c, 
                   No_of_OSB__c, No_of_OST__c, No_of_Airline_Trunk__c,
                   Estimate_Time_of_Arrival__c, Description__c, Estimate_Time_of_Departure__c, 
                   CreatedDate, Flight_Number__c, Email_Status__c,
                   Linehaul_Name__r.Id, Linehaul_Name__r.Manual__c
            FROM Linehaul_Tracking__c
            WHERE Id IN :recordId
        ];

       
        Map<Id, List<Secure_Bag__c>> bagsByLinehaul = new Map<Id, List<Secure_Bag__c>>();
        for (Secure_Bag__c sb : [
            SELECT Id, Finalised_Linehaul_Number__c, AWB_Number__c, Origin_City__c, 
                   Destination_City__c, Trunk_Id__r.Name, Seal_Id__r.Name, Right_Seal_Id__r.Name, 
                   Shipping_Note_Number__c, Shipper_Account__c, Consignee_Account__c,
                   Shipment_Origin__c, Shipment_Destination__c, Secure_Bag__r.Name, 
                   Master_AWB__c, Linehaul_Tracking__c, shipment__r.Shipper_Name_TMS__c, 
                   shipment__r.Consignee_Name_TMS__c, shipment__r.Origin__c, shipment__r.Destination__c, 
                   Airline_Trunk__c, Oversize_Bag__c, Oversize_Trunk__c
            FROM Secure_Bag__c
            WHERE Linehaul_Tracking__c IN :recordId
        ]) {
            if (!bagsByLinehaul.containsKey(sb.Linehaul_Tracking__c)) {
                bagsByLinehaul.put(sb.Linehaul_Tracking__c, new List<Secure_Bag__c>());
            }
            bagsByLinehaul.get(sb.Linehaul_Tracking__c).add(sb);
        }

    
        Set<String> destinations = new Set<String>();
        for (Linehaul_Tracking__c l : linehaulTrackList) {
            destinations.add(l.Destination__c);
        }

        Map<String, Transport__c> transportByDest = new Map<String, Transport__c>();
        for (Transport__c t : [
            SELECT Id, Name, Notify_Email__c 
            FROM Transport__c 
            WHERE Name IN :destinations
        ]) {
            transportByDest.put(t.Name, t);
        }

       
        for (Linehaul_Tracking__c line : linehaulTrackList) {
            List<Secure_Bag__c> bagList = bagsByLinehaul.get(line.Id);

            // build csvs
            String csvBody = 'AWB_Number__c,Origin__c,Destination__c,Select_Airline__c,Flight_Date__c,No.of Shipping Notes,Total Number of Airline Packages,No of Packages\n';
            csvBody += '"' + line.AWB_Number__c + '","' + line.Finalized_Linehaul_Number__c + '","' + line.Origin__c + '","' + line.Destination__c + '","' +
                       line.Airline__c + '","' + line.Flight_Date__c + '","' + line.No_of_Shipment_Notes__c + '","' + line.Total_Number_of_Airline_Packages__c + '","' +
                       line.No_of_Package__c + '"\n';

            String csvBody1 = 'AWB number,Trunk No,Oversize Bag,Oversize Trunk,Airline Trunk,Left Seal Id, Right Seal Id, Shipping Note Number,Shipper Account,Consignee Account,Shipment origin,Origin City,Shipment Destination,Destination City,Secure Bag No\n';

            if (bagList != null) {
                for (Secure_Bag__c sb : bagList) {
                    csvBody1 += '"' + sb.Finalised_Linehaul_Number__c + '","' + sb.AWB_Number__c + '","' + sb.Trunk_Id__r.Name + '","' + sb.Oversize_Bag__c + '","' +
                                sb.Oversize_Trunk__c + '","' + sb.Airline_Trunk__c + '","' + sb.Seal_Id__r.Name + '","' + sb.Right_Seal_Id__r.Name + '","' + sb.Shipping_Note_Number__c + '","' +
                                sb.Shipper_Account__c + '","' + sb.Consignee_Account__c + '","' + sb.Shipment_Origin__c + '","' + sb.Origin_City__c + '","' + sb.Shipment_Destination__c + '","' +
                                sb.Destination_City__c + '","' + sb.Secure_Bag__r.Name + '"\n';
                }
            }

            
            Transport__c trans = transportByDest.get(line.Destination__c);
            if (trans == null) continue; 

            String[] emailAddresses = trans.Notify_Email__c != null ? trans.Notify_Email__c.split(',') : new String[]{};
            Datetime originalDate = line.Flight_Date__c;
            String formattedDate = (originalDate != null) ? originalDate.format('MMMM dd, yyyy') : '';

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

    
       
        Linehaul__c ltList = [select id,manual__c from Linehaul__c where id=: line.Linehaul_Name__r.id];
        
        string subject = 'MAWB Pre-Alert - ' + line.Name + ' from ' + line.Origin__c + ' - ' + line.Airline__c + ' - ' + line.Description__c + ' - ' + formattedDate;
        string subject1 = 'MAWB Pre-Alert -'+' '+ line.Name +' '+ 'from'+' ' + line.Origin__c +'-'+' '+ line.Airline__c +'-'+' '+ formattedDate;
       
        Blob csvBodyBlob = Blob.valueOf(csvbody);
        Blob csvBody1Blob = Blob.valueOf(csvbody1);
        
        List<blob> blobList = new List<blob>{csvBodyBlob,csvBody1Blob} ;             
        List<string> attachmentNames = new List<string>{'AWB Summary.csv','AWB details.csv'};
            
        List<string> emailList = new List<string>();
        
        for(string em :emailAddresses){
            em = em.trim();
            emailList.add(em);
        } 
         if(ltList.manual__c == false){
              sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject, body, blobList, attachmentNames);            
              line.Email_Status__c = 'sent';
               update line;
           }else{
              sendGridEmailMessageAttachments.sendGridEmailMessagesAttachment(EmailList, subject1, body1, blobList, attachmentNames);
              line.Email_Status__c = 'sent';
                update line;
         }
        }
    }
}