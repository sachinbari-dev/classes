public with sharing class BVCContractConsumption80Mailer {
    @InvocableMethod(label='Send BVC Contract 80 Consumption Email')
    public static void sendContractConsumptionEmail(List<Id> contractIds) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // Step 1: Fetch contracts
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
            WHERE Id IN :contractIds
        ];

        // Step 2: Collect related Account Ids
        Set<Id> accountIds = new Set<Id>();
        for (BVC_Contract__c c : contracts) {
            if (c.Customer_Name__c != null) {
                accountIds.add(c.Customer_Name__c);
            }
        }

        // Step 3: Get related contacts via AccountContactRelation with Role = Finance or Legal
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

        // Step 4: Query contacts with email
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Email
            FROM Contact
            WHERE Id IN :contactIds AND Email != null
        ]);

        // Step 5: Build accountId -> List<Contact> map
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

        // Step 6: Build and send email per contract
        for (BVC_Contract__c contract : contracts) {
            List<String> recipients = new List<String>();

            // Add Finance/Legal contacts
            List<Contact> contacts = accountToContacts.get(contract.Customer_Name__c);
            if (contacts != null) {
                for (Contact c : contacts) {
                    if (!recipients.contains(c.Email)) {
                        recipients.add(c.Email);
                    }
                }
            }

            // Add Account Owner
            if (contract.Customer_Name__r.Owner != null && contract.Customer_Name__r.Owner.Email != null) {
                if (!recipients.contains(contract.Customer_Name__r.Owner.Email)) {
                    recipients.add(contract.Customer_Name__r.Owner.Email);
                }
            }

            // Add Sales Secondary Owner
            if (contract.Customer_Name__r.Sales_Secondary_Owner__r != null &&
                contract.Customer_Name__r.Sales_Secondary_Owner__r.Email != null) {
                if (!recipients.contains(contract.Customer_Name__r.Sales_Secondary_Owner__r.Email)) {
                    recipients.add(contract.Customer_Name__r.Sales_Secondary_Owner__r.Email);
                }
            }

            if (recipients.isEmpty()) continue;

            // Email body
            String body = 'Dear ' + contract.Customer_Name__r.Name + ',\n\n' +
                'Greetings from BVC, your most secure logistics partner with over 60 years of experience in handling precious shipments.\n' +
                'Please be informed that your Annual Contract with BVC has reached ' + contract.of_Contract_Consumption__c + '% of its consumption limit. We would appreciate the opportunity to discuss a renewal to ensure continued seamless shipping.\n\n' +

                'The summary of your Annual Contract is as follows:\n\n' +
                'Customer Name  : ' + contract.Customer_Name__r.Name + '\n' +
                'PAN Number     : ' + contract.Pan_Number__c + '\n' +
                'Annual Contract Number  : ' + contract.Name + '\n' +
                'Effective From     : ' + String.valueOf(contract.Contract_Start_Date__c) + '\n' +
                'Effective Till : ' + String.valueOf(contract.Contract_End_Date__c) + '\n' +
                'No. of Days in Annual Contract: ' + String.valueOf(contract.Number_of_days_of_Contract__c) + '\n' +
                'Balance No. of Days: ' + String.valueOf(contract.Balance_No_of_days_of_Annual_Contract__c) + '\n' +
                'Annual Contract Amount: ' + String.valueOf(contract.Contract_Amount__c) + '\n' +
                'Amount Consumed: ' + String.valueOf(contract.Consumed_Amount__c) + '\n' +
                '% of Contract Consumed: ' + String.valueOf(contract.of_Contract_Consumption__c) + '%\n' +
                'Balance Contract Amount: ' + String.valueOf(contract.Balance_Amount__c) + '\n' +
                'Number of Parcels Shipped: ' + String.valueOf(contract.Total_Packages_Shipped__c) + '\n' +
                'Net Weight Shipped (Grams): ' + String.valueOf(contract.Net_Weight__c) + '\n' +
                'Gross Weight Shipped (Grams): ' + String.valueOf(contract.Gross_Weight__c) + '\n' +
                'Product Value Shipped (INR): ' + String.valueOf(contract.Total_Shipment_Value__c) + '\n\n' +

                'The detailed shipment-wise report is attached for your reference.\n' +
                'Please note that the BVC Standard Tariff, as shown here ' + contract.Tariff_Plan__c + ', will apply once the ACR expires, either by date or consumption.\n' +
                'For renewing your contract or for any clarifications, please feel free to get in touch with me.\n\n' +
                'We look forward to a long-standing relationship between BVC and ' + contract.Customer_Name__r.Name + '.\n\n' +
                'Thanks and Regards,\n' +
                'Team BVC.';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(recipients);
            email.setSubject('Your Annual Contract Consumption with BVC');
            email.setPlainTextBody(body);
            email.setSaveAsActivity(false);
            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend, false);
        }
    }
}