/*Class      : AddressBookController
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : Sep 2023
 */
public with sharing class AddressBookController {
    public static void enforceContactLimit(List<Contact> newContacts) {
        Set<Id> addressBookIds = new Set<Id>();
        Map<Id, Integer> addressBookContactCount = new Map<Id, Integer>();

        for (Contact contact : newContacts) {
            if (contact.AddressBook__c != null) {
                addressBookIds.add(contact.AddressBook__c);
            }
        }

        List<AggregateResult> results = [
            SELECT AddressBook__c,Active_status__c, COUNT(Id) contactCount
            FROM Contact
            WHERE AddressBook__c IN :addressBookIds AND Active_status__c = True
            AND BVC_Contact_status__c = 'Active' 
            GROUP BY AddressBook__c , Active_status__c
        ];

        for (AggregateResult result : results) {
            Id addressBookId = (Id)result.get('AddressBook__c');
            Integer contactCount = (Integer)result.get('contactCount');
            addressBookContactCount.put(addressBookId, contactCount);
        }

        for (Contact contact : newContacts) {
            if (contact.AddressBook__c != null && addressBookContactCount.containsKey(contact.AddressBook__c)) {
                Integer contactCount = addressBookContactCount.get(contact.AddressBook__c);
                if (contactCount >= 12) {
                    contact.addError('Only 12 Active contacts are allowed per AddressBook.');
                }
            }
        }
    }
    //added by Govind 
     public static void enforceContactLimitForUpdate(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        for (Contact contact : newContacts) {
            if (contact.AddressBook__c != null && oldMap.containsKey(contact.Id)) {
                Contact oldContact = oldMap.get(contact.Id);
                if (!oldContact.Active_status__c && contact.Active_status__c) {
                    Integer activeContacts = [SELECT COUNT() 
                                              FROM Contact 
                                              WHERE AddressBook__c = :contact.AddressBook__c 
                                                AND Active_status__c = true 
                                                AND BVC_Contact_status__c = 'Active'];
                    if (activeContacts >= 12) {
                        contact.addError('Cannot change Active status from false to true if the AddressBook has 12 or more active contacts.');
                    }
                }
            }
        }
    }
}