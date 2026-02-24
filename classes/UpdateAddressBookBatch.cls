/*Class      : UpdateAddressBookBatch 
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : May 2024
 * Updated Date       : Sept 2025
 */

global class UpdateAddressBookBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> activePincodeIds;
    private Map<Id, String> recordTypeMap;
    private Id userId;
    private Integer successCount = 0;
    private Integer failureCount = 0;
    private List<String> exceptionMessages = new List<String>(); // List to store exception messages

    global UpdateAddressBookBatch(Set<Id> activePincodeIds, Map<Id, String> recordTypeMap, Id userId) {
        this.activePincodeIds = activePincodeIds;
        this.recordTypeMap = recordTypeMap;
        this.userId = userId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, RecordTypeId, Is_Active__c, Active_Pincode__c
            FROM AddressBook__c
            WHERE RecordTypeId = '0125g0000002Xb1AAE'
            AND Active_Pincode__c IN :activePincodeIds
        ]);
    }

    global void execute(Database.BatchableContext BC, List<AddressBook__c> addressBooks) {
        List<AddressBook__c> toUpdate = new List<AddressBook__c>();

        for (AddressBook__c addressBook : addressBooks) {
            try {
                String pincodeType = recordTypeMap.get(addressBook.Active_Pincode__c);
                if ((pincodeType == 'Non-Serviceable' && addressBook.Is_Active__c) ||
                    (pincodeType == 'Serviceable' && !addressBook.Is_Active__c)) {
                    addressBook.Is_Active__c = (pincodeType == 'Serviceable');
                    toUpdate.add(addressBook);
                }
                successCount++;
            } catch (Exception e) {
                failureCount++;
                exceptionMessages.add('Record ID: ' + addressBook.Id + ', Error: ' + e.getMessage());
            }
        }

        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
            } catch (Exception e) {
                failureCount += toUpdate.size();
                exceptionMessages.add('Update Error: ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Send email to the user + additional recipients
        sendCompletionEmail();
    }

    private void sendCompletionEmail() {
        User user = [SELECT Email FROM User WHERE Id = :userId LIMIT 1];
        String subject = 'Batch Job Completed';
        String body = 'The job for updating Serviceable/Non-serviceable Pincode records has completed.\n\n' +
                      'Success Count: ' + successCount + '\n' +
                      'Failure Count: ' + failureCount + '\n';

        if (!exceptionMessages.isEmpty()) {
            body += '\nExceptions:\n';
            for (String message : exceptionMessages) {
                body += message + '\n';
            }
        }

        body += '\nThank you.';

        // Add multiple recipients here
        List<String> recipients = new List<String>{
            user.Email,
            'krishnakumar.mahule@bvclogistics.com',
            'sravani.boorgula@bvclogistics.com'
        };

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(recipients);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}