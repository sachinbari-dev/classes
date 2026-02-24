public with sharing class ContactValidationHelper {
    
    private static final String RESTRICTED_RECORDTYPE_ID = '0125g0000002Xb0AAE';
    private static final Set<String> RESTRICTED_PROFILES = new Set<String>{
        'Operations Office Executive',
        'Operations Field Executive'
    };

    public static void preventRestrictedContactCreation(List<Contact> newContacts) {
        Set<Id> addressBookIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AddressBook__c != null) {
                addressBookIds.add(con.AddressBook__c);
            }
        }

        if (addressBookIds.isEmpty()) {
            return;
        }

        // Query AddressBook__c records to get their RecordTypeIds
        Map<Id, AddressBook__c> addressBookMap = new Map<Id, AddressBook__c>(
            [SELECT Id, RecordTypeId FROM AddressBook__c WHERE Id IN :addressBookIds]
        );

        // Get the current user's profile name
        String currentProfileName = [
            SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()
        ].Name;

        // Apply restriction
        for (Contact con : newContacts) {
            AddressBook__c addr = addressBookMap.get(con.AddressBook__c);
            if (
                addr != null &&
                addr.RecordTypeId == RESTRICTED_RECORDTYPE_ID &&
                RESTRICTED_PROFILES.contains(currentProfileName)
            ) {
                con.addError('You are not allowed to create a Contact for this Billing Address.');
            }
        }
    }
}