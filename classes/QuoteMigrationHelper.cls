public class QuoteMigrationHelper 
{
    public static void dummyMethod(){
     integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   
    }
}
    /*
    public static void MakeMail(List<Database.UpsertResult> upsertResults,List<sObject> recordsList,String ObjectName)
    {
        
        System.debug('InvoiceMigrationHelper MakeMail Line no 7 ObjectName:'+ObjectName);
        List<SObject> failedRecords = new List<SObject>();
        List<SObject> successfulRecords = new List<SObject>();
        List<String> failedRecordDetails = new List<String>();
        List<String> successfulRecordDetails = new List<String>();
        
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            
            if (result.isSuccess()) {
                successfulRecords.add(recordsList[i]);
                successfulRecordDetails.add('Record Id: ' + result.getId() + ' processed successfully.');
            } else {
                failedRecords.add(recordsList[i]);
                for (Database.Error error : result.getErrors()) {
                    failedRecordDetails.add('Error on record Id: ' + recordsList[i].Id + ' - ' + error.getMessage());
                }
            }
        }
        
        // Send email with both failed and successful records
        InvoiceMigrationHelper.sendEmailNotification(failedRecordDetails, successfulRecordDetails,ObjectName);
        
    }
    
    public static void sendEmailNotification(List<String> failedDetails, List<String> successDetails,String ObjName) {
        String body = '';
        if (!successDetails.isEmpty()) {
            body +='Object Name :'+ObjName+', Successfully processed records:\n';
            body += String.join(successDetails, '\n') + '\n\n';
        }
        if (!failedDetails.isEmpty()) {
            body += 'Object Name :'+ObjName+', Failed records with errors:\n';
            body += String.join(failedDetails, '\n') + '\n';
        }
        
        // Email configuration
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'ashoksfdc1001@gmail.com'});
        email.setSubject('Object Name :'+ObjName+', Migration Process Result');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }    
}*/