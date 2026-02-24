/*
 * Class      : DefaultContactEnforcer
 * Author     : Sanket.pisal@bvclogistics.com
 * Date       : Sep 2023
 */
public class DefaultContactEnforcer {
    public static void enforceDefaultContact(List<Contact> newContacts) {
        Set<Id> addressBookIds = new Set<Id>();
        Map<Id, Contact> existingDefaultContacts = new Map<Id, Contact>();

        for (Contact contact : newContacts) {
            if (contact.Default__c && contact.AddressBook__c != null) {
                addressBookIds.add(contact.AddressBook__c);
            }
        }

        if (!addressBookIds.isEmpty()) {
            existingDefaultContacts = getExistingDefaultContacts(addressBookIds);
        }

        for (Contact contact : newContacts) {
            if (contact.Default__c && contact.AddressBook__c != null) {
                Contact existingDefaultContact = existingDefaultContacts.get(contact.AddressBook__c);
                if (existingDefaultContact != null && existingDefaultContact.Id != contact.Id) {
                    contact.addError('There can only be one default contact per AddressBook.');
                }
            }
        }
    }

    public static Map<Id, Contact> getExistingDefaultContacts(Set<Id> addressBookIds) {
        Map<Id, Contact> existingDefaultContacts = new Map<Id, Contact>();
        for (Contact contact : [
            SELECT Id, AddressBook__c
            FROM Contact
            WHERE Default__c = true AND AddressBook__c IN :addressBookIds
        ]) {
            if (!existingDefaultContacts.containsKey(contact.AddressBook__c)) {
                existingDefaultContacts.put(contact.AddressBook__c, contact);
            }
        }
        return existingDefaultContacts;
    }
}