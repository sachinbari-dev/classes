public class DuplicateContactValidator {

    public static void checkDuplicates(List<Contact> newList) {
        checkDuplicates(newList, null);
    }

    public static void checkDuplicates(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> addressBookIds = new Set<Id>();
        Set<String> mobileKeys = new Set<String>();
        Set<String> emailKeys = new Set<String>();
        Map<String, Contact> keyToContactMap = new Map<String, Contact>();

        for (Contact con : newList) {
            if (con.AddressBook__c != null) {
                addressBookIds.add(con.AddressBook__c);

                if (con.MobilePhone != null) {
                    String mKey = con.AddressBook__c + '|' + con.MobilePhone.trim();
                    mobileKeys.add(mKey);
                    keyToContactMap.put(mKey, con);
                }

                if (con.Email != null) {
                    String eKey = con.AddressBook__c + '|' + con.Email.trim().toLowerCase();
                    emailKeys.add(eKey);
                    keyToContactMap.put(eKey, con);
                }
            }
        }

        if (!addressBookIds.isEmpty()) {
            List<Contact> existingContacts = [
                SELECT Id, AddressBook__c, MobilePhone, Email
                FROM Contact
                WHERE AddressBook__c IN :addressBookIds
                  AND (MobilePhone != null OR Email != null)
            ];

            for (Contact existing : existingContacts) {
                String mKey = existing.MobilePhone != null ? existing.AddressBook__c + '|' + existing.MobilePhone.trim() : null;
                String eKey = existing.Email != null ? existing.AddressBook__c + '|' + existing.Email.trim().toLowerCase() : null;

                if (mKey != null && mobileKeys.contains(mKey)) {
                    Contact incoming = keyToContactMap.get(mKey);
                    if (oldMap != null && incoming.Id == existing.Id) continue;
                    incoming.addError(
                        'AddressBook__c',
                        'A contact with the same MobilePhone already exists under this Address Book. Duplicate Contact Id: ' + existing.Id
                    );
                }

                if (eKey != null && emailKeys.contains(eKey)) {
                    Contact incoming = keyToContactMap.get(eKey);
                    if (oldMap != null && incoming.Id == existing.Id) continue;
                    incoming.addError(
                        'AddressBook__c',
                        'A contact with the same Email already exists under this Address Book. Duplicate Contact Id: ' + existing.Id
                    );
                }
            }
        }
    }
}