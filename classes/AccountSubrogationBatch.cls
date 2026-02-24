global class AccountSubrogationBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Id orgWideEmailId;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = Date.today();
        Set<Date> notificationDates = new Set<Date>{
            today.addDays(6), today.addDays(3), today
        };

      
        OrgWideEmailAddress owea = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE Address = 'bvclinvoicesubmission@bvclogistics.com' 
            LIMIT 1
        ];
        orgWideEmailId = owea.Id;

      
        return Database.getQueryLocator([
            SELECT Id, Name, PAN_Number_of_Entity__c, Subrogation_End_Date__c,
                   Owner.Email, Sales_Secondary_Owner__r.Email
            FROM Account
            WHERE Subrogation_End_Date__c IN :notificationDates
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Date today = Date.today();

      
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

      
        Map<Id, Set<String>> accountContactEmailsMap = new Map<Id, Set<String>>();
        for (AccountContactRelation acr : [
            SELECT AccountId, Contact.Email
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds
              AND Roles != null
              AND Contact.Email != null
        ]) {
            if (!accountContactEmailsMap.containsKey(acr.AccountId)) {
                accountContactEmailsMap.put(acr.AccountId, new Set<String>());
            }
            accountContactEmailsMap.get(acr.AccountId).add(acr.Contact.Email);
        }

      
        for (Account acc : accounts) {
            if (acc.Subrogation_End_Date__c == null) continue;

            Integer daysDiff = today.daysBetween(acc.Subrogation_End_Date__c);
            String messageNote = '';
            String subject = '';

            if (daysDiff == 6) {
                messageNote = 'This is a reminder that the Subrogation Policy for the following customer will expire in 6 days:';
                subject = 'Subrogation Policy Expiry in 6 Days – ' + acc.Name;
            } else if (daysDiff == 3) {
                messageNote = 'This is a reminder that the Subrogation Policy for the following customer will expire in 3 days:';
                subject = 'Subrogation Policy Expiry in 3 Days – ' + acc.Name;
            } else if (daysDiff == 0) {
                messageNote = 'This is a reminder that the Subrogation Policy for the following customer is expiring today:';
                subject = 'Subrogation Policy Expiring Today – ' + acc.Name;
            }

            if (messageNote != '') {
                Set<String> toAddresses = new Set<String>();

              
                if (acc.Owner != null && acc.Owner.Email != null)
                    toAddresses.add(acc.Owner.Email);
                if (acc.Sales_Secondary_Owner__r != null && acc.Sales_Secondary_Owner__r.Email != null)
                    toAddresses.add(acc.Sales_Secondary_Owner__r.Email);

              
                if (accountContactEmailsMap.containsKey(acc.Id)) {
                    toAddresses.addAll(accountContactEmailsMap.get(acc.Id));
                }

                if (!toAddresses.isEmpty()) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(orgWideEmailId);
                    email.setToAddresses(new List<String>(toAddresses));
                    email.setCcAddresses(new List<String>{ 'bvclinvoicesubmission@bvclogistics.com' });
                    email.setSubject(subject);
                    email.setPlainTextBody(
                        'Dear Customer,\n\n' +
                        messageNote + '\n\n' +
                        'Customer Name: ' + acc.Name + '\n' +
                        'Billing ID: ' + acc.PAN_Number_of_Entity__c + '\n' +
                        'Subrogation End Date: ' + acc.Subrogation_End_Date__c.format() + '\n\n' +
                        'Please review the policy and take necessary action to update or renew it before the expiry date to avoid any disruption.\n' +
                        'If the policy has already been updated, no further action is needed.\n\n' +
                        'Regards,\nTeam BVC'
                    );
                    emailsToSend.add(email);
                }
            }
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    global void finish(Database.BatchableContext bc) {
       
    }
}