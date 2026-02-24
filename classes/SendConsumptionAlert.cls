public with sharing class SendConsumptionAlert {

    @InvocableMethod(label='Send BVC Consumption Alert Email')
    public static void sendAlert(List<Id> contractIds) {
        Id templateId = [
            SELECT Id 
            FROM EmailTemplate 
            WHERE DeveloperName = 'BVC_Contract_Consumption' 
            LIMIT 1
        ].Id;

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Id contractId : contractIds) {
            if (contractId == null) continue;

            BVC_Contract__c contract = [
                SELECT Id, Name, of_Contract_Consumption__c,
                       Customer_Name__c,
                       Customer_Name__r.OwnerId,
                       Customer_Name__r.Sales_Secondary_Owner__c
                FROM BVC_Contract__c
                WHERE Id = :contractId
                LIMIT 1
            ];

            if (contract.of_Contract_Consumption__c <= 1.2 || contract.Customer_Name__c == null) {
                continue;
            }

            Set<Id> contactIds = new Set<Id>();
            Set<Id> userIdsToEmail = new Set<Id>();

            for (AccountContactRole acr : [
                SELECT ContactId FROM AccountContactRole
                WHERE AccountId = :contract.Customer_Name__c AND Role != null
            ]) {
                if (acr.ContactId != null) {
                    contactIds.add(acr.ContactId);
                }
            }

            for (Contact c : [
                SELECT Id FROM Contact 
                WHERE Id IN :contactIds AND Email != null
            ]) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(c.Id);
                mail.setTemplateId(templateId);
                mail.setWhatId(contract.Id);
                mail.setSaveAsActivity(false);
                emailsToSend.add(mail);
            }

            if (contract.Customer_Name__r.OwnerId != null) {
                userIdsToEmail.add(contract.Customer_Name__r.OwnerId);
            }
            if (contract.Customer_Name__r.Sales_Secondary_Owner__c != null) {
                userIdsToEmail.add(contract.Customer_Name__r.Sales_Secondary_Owner__c);
            }

            for (User u : [
                SELECT Id FROM User 
                WHERE Id IN :userIdsToEmail AND Email != null
            ]) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(u.Id);
                mail.setTemplateId(templateId);
                mail.setSaveAsActivity(false);
                emailsToSend.add(mail);
            }
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}