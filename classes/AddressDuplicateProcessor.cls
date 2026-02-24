public class AddressDuplicateProcessor {

    public static void processCustomer(Id accountId) {

        if (accountId == null) {
            System.debug('Account Id is null');
            return;
        }

        // Get Shipping Record Type Id
        Map<String, Schema.RecordTypeInfo> rtMap =
            Schema.SObjectType.AddressBook__c.getRecordTypeInfosByDeveloperName();

        if (!rtMap.containsKey('Shipping')) {
            System.debug('Shipping Record Type not found');
            return;
        }

        Id shippingRTId = rtMap.get('Shipping').getRecordTypeId();

        // Fetch Shipping Addresses for this Account
        List<AddressBook__c> addressList = [
            SELECT Id, AI_short_code__c, Name, Pincode__c
            FROM AddressBook__c
            WHERE Customer__c = :accountId
            AND RecordTypeId = :shippingRTId
        ];

        if (addressList.isEmpty()) {
            System.debug('No Shipping Addresses Found');
            return;
        }

        // Map to group normalized addresses
        Map<String, List<AddressBook__c>> addressMap = new Map<String, List<AddressBook__c>>();

        for (AddressBook__c addr : addressList) {
            String normalized = normalizeAddress(
                addr.Name,
                addr.Pincode__c
            );

            if (!addressMap.containsKey(normalized)) {
                addressMap.put(normalized, new List<AddressBook__c>());
            }
            addressMap.get(normalized).add(addr);
        }

        // Assign same AI_short_code__c to duplicates
        List<AddressBook__c> updates = new List<AddressBook__c>();

        for (String key : addressMap.keySet()) {
            List<AddressBook__c> addrGroup = addressMap.get(key); // renamed from 'group'

            if (addrGroup.size() > 1) {
                // Generate collision-safe short code using MD5 hash
                String shortCode = 'AI-' + EncodingUtil.convertToHex(
                    Crypto.generateDigest('MD5', Blob.valueOf(key))
                ).substring(0, 10); // first 10 chars of hash

                for (AddressBook__c rec : addrGroup) {
                    rec.AI_short_code__c = shortCode;
                    updates.add(rec);
                }
            }
        }

        if (!updates.isEmpty()) {
            update updates;
            System.debug('Duplicates updated successfully: ' + updates.size());
        } else {
            System.debug('No duplicates found');
        }
    }

    // Helper method to normalize Name + Pincode
    private static String normalizeAddress(String name, String pincode) {
        String full = (name == null ? '' : name) +
                      (pincode == null ? '' : pincode);
        full = full.toLowerCase();
        full = full.replaceAll('\\s+', '');
        full = full.replaceAll('[^a-z0-9]', '');
        return full;
    }
}