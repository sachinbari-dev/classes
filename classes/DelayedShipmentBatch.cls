global class DelayedShipmentBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String getShipmentQuery = 
            'SELECT Id, Shipping_Note_Number__c, Customer__r.Name, Tracking_Status__c, ' +
            'Destination_Address_Email1__c, Destination_Hub__r.Hub_Email_ID__c, ' +
            'Account__r.Primary_Customer_Email__c ' +
            'FROM Shipment__c ' +
            'WHERE Is_Delivery_Delayed__c = true ' +
            'AND CreatedDate = LAST_N_DAYS:2 ' +
            'AND Estimated_Delivery_Datetime__c != NULL ' +
            'AND Tracking_Status__c != \'Delivered\'';

        return Database.getQueryLocator(getShipmentQuery);
    } 
    
    global void execute(Database.BatchableContext BC, List<Shipment__c> shipmentList) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Get Org-Wide Email Address ID for shippingnote@bvclogistics.com
        OrgWideEmailAddress orgWideEmail = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE Address = 'ops.notifications@bvclogistics.com' 
            LIMIT 1
        ];

        for (Shipment__c shipment : shipmentList) {
            List<String> toAddresses = new List<String>();

            // Static recipients
            toAddresses.add('sravani.boorgula@bvclogistics.com');
            // toAddresses.add('santosh.singh@bvclogistics.com');

            // Dynamic recipients
            if (shipment.Destination_Hub__r != null && shipment.Destination_Hub__r.Hub_Email_ID__c != null) {
                toAddresses.add(shipment.Destination_Hub__r.Hub_Email_ID__c);
            }

            if (!toAddresses.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toAddresses);
                email.setSubject('Urgent: Delayed Shipments Exceeding Committed TAT');
                email.setOrgWideEmailAddressId(orgWideEmail.Id); // Set from address

                String body = 'Dear Team,\n\n' +
                    'We would like to bring to your attention that the below-mentioned shipments have exceeded the committed Turnaround Time (TAT) and are currently delayed. ' +
                    'Ensuring timely deliveries is crucial. Please review and take necessary action.\n\n' +
                    'Delayed Shipment Details:\n\n' +
                    'Shipping Note Number: ' + shipment.Shipping_Note_Number__c + '\n' +
                    'Customer Name: ' + shipment.Customer__r.Name + '\n' +
                    'Current Status: ' + shipment.Tracking_Status__c + '\n\n' +
                    'Thanks and Regards,\nTeam BVC';

                email.setPlainTextBody(body);
                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Execution Completed');
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DelayedShipmentBatch(), 50);
    }
}