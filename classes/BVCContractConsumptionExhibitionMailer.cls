public with sharing class BVCContractConsumptionExhibitionMailer {
@InvocableMethod(label='Send BVC Contract Consumption Exhibition Email')
    public static void sendContractConsumptionEmail(List<Id> contractIds) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        List<BVC_Contract__c> contracts = [
            SELECT Id, Name, of_Contract_Consumption__c, Customer_Name__c,
                   Customer_Name__r.Name, Customer_Name__r.Owner.Email,
                   Customer_Name__r.Sales_Secondary_Owner__r.Email,
                   Pan_Number__c, Contract_Start_Date__c, Contract_End_Date__c,
                   Number_of_days_of_Contract__c, Balance_No_of_days_of_Annual_Contract__c,
                   Contract_Amount__c, Consumed_Amount__c, Balance_Amount__c,
                   Total_Packages_Shipped__c, Net_Weight__c, Gross_Weight__c,
                   Total_Shipment_Value__c, Tariff_Plan__c
            FROM BVC_Contract__c
            WHERE Id IN :contractIds AND BVC_Service__c = 'ExhibiSHIP'
        ];

     
        Set<Id> accountIds = new Set<Id>();
        for (BVC_Contract__c c : contracts) {
            if (c.Customer_Name__c != null) {
                accountIds.add(c.Customer_Name__c);
            }
        }

        
        Map<Id, List<Id>> accountToContactIds = new Map<Id, List<Id>>();
        Set<Id> contactIds = new Set<Id>();

        for (AccountContactRelation acr : [
            SELECT AccountId, ContactId, Roles
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds AND Roles != null
        ]) {
            if (!accountToContactIds.containsKey(acr.AccountId)) {
                accountToContactIds.put(acr.AccountId, new List<Id>());
            }
            accountToContactIds.get(acr.AccountId).add(acr.ContactId);
            contactIds.add(acr.ContactId);
        }

       
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Email
            FROM Contact
            WHERE Id IN :contactIds AND Email != null
        ]);

       
        Map<Id, List<Contact>> accountToContacts = new Map<Id, List<Contact>>();
        for (Id accId : accountToContactIds.keySet()) {
            List<Contact> contacts = new List<Contact>();
            for (Id contactId : accountToContactIds.get(accId)) {
                if (contactMap.containsKey(contactId)) {
                    contacts.add(contactMap.get(contactId));
                }
            }
            accountToContacts.put(accId, contacts);
        }

      
        for (BVC_Contract__c contract : contracts) {
            List<String> recipients = new List<String>();

         
            List<Contact> contacts = accountToContacts.get(contract.Customer_Name__c);
            if (contacts != null) {
                for (Contact c : contacts) {
                    if (!recipients.contains(c.Email)) {
                        recipients.add(c.Email);
                    }
                }
            }

          
            if (contract.Customer_Name__r.Owner != null &&
                contract.Customer_Name__r.Owner.Email != null &&
                !recipients.contains(contract.Customer_Name__r.Owner.Email)) {
                recipients.add(contract.Customer_Name__r.Owner.Email);
            }

           
            if (contract.Customer_Name__r.Sales_Secondary_Owner__r != null &&
                contract.Customer_Name__r.Sales_Secondary_Owner__r.Email != null &&
                !recipients.contains(contract.Customer_Name__r.Sales_Secondary_Owner__r.Email)) {
                recipients.add(contract.Customer_Name__r.Sales_Secondary_Owner__r.Email);
            }

            if (recipients.isEmpty()) continue;

            // HTML body
            String htmlBody = 'Dear ' + contract.Customer_Name__r.Name + ',<br><br>' +
                'Greetings from BVC, your most secure logistics partner with over 60 years of experience in handling precious shipments.<br>' +
                'We would like to inform you that your Exhibition Contract with BVC has already reached  ' + contract.of_Contract_Consumption__c + '% of the allocated limit. ' +
                'We recommend discussing the renewal to ensure uninterrupted service for your upcoming exhibitions.<br><br>' +

                'The summary of your Annual Contract is as follows:<br><br>' +
                'Customer Name  : ' + contract.Customer_Name__r.Name + '<br>' +
                'PAN Number     : ' + contract.Pan_Number__c + '<br>' +
                'Annual Contract Number  : ' + contract.Name + '<br>' +
                'Effective From     : ' + String.valueOf(contract.Contract_Start_Date__c) + '<br>' +
                'Effective Till : ' + String.valueOf(contract.Contract_End_Date__c) + '<br>' +
                'No. of Days in Annual Contract: ' + String.valueOf(contract.Number_of_days_of_Contract__c) + '<br>' +
                'Balance No. of Days: ' + String.valueOf(contract.Balance_No_of_days_of_Annual_Contract__c) + '<br>' +
                'Annual Contract Amount: ' + String.valueOf(contract.Contract_Amount__c) + '<br>' +
                'Amount Consumed: ' + String.valueOf(contract.Consumed_Amount__c) + '<br>' +
                '% of Contract Consumed: ' + contract.of_Contract_Consumption__c + '%<br>' +
                'Balance Contract Amount: ' + String.valueOf(contract.Balance_Amount__c) + '<br>' +
                'Number of Parcels Shipped: ' + String.valueOf(contract.Total_Packages_Shipped__c) + '<br>' +
                'Net Weight Shipped (Grams): ' + String.valueOf(contract.Net_Weight__c) + '<br>' +
                'Gross Weight Shipped (Grams): ' + String.valueOf(contract.Gross_Weight__c) + '<br>' +
                'Product Value Shipped (INR): ' + String.valueOf(contract.Total_Shipment_Value__c) + '<br><br>' +

                'For renewing your contract or for any clarifications, please feel free to get in touch with me.<br><br>' +
                'We look forward to a long-standing relationship between BVC and ' + contract.Customer_Name__r.Name + '.<br><br>' +
                'Thanks and Regards,<br>' +
                'Team BVC.';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(recipients);
            email.setSubject('Your Exhibition Contract Consumption with BVC');
            email.setHtmlBody(htmlBody);
            email.setSaveAsActivity(false);
            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend, false);
        }
    }
}