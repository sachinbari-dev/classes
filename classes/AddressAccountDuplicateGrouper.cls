public with sharing class AddressAccountDuplicateGrouper {

    public static void run(){

        List<Account> accts = [
            SELECT Id, ShippingCity, ShippingPostalCode
            FROM Account
            WHERE ShippingCity != null
              AND ShippingPostalCode != null
        ];

        Map<String,Id> shippingIndex = new Map<String,Id>();

        for(Account a : accts){
            String norm = normalize(a.ShippingCity, a.ShippingPostalCode);
            if(!String.isBlank(norm)){
                shippingIndex.put(norm, a.Id);
            }
        }

        Id shippingRT = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'AddressBook__c'
              AND DeveloperName = 'Shipping'
            LIMIT 1
        ].Id;

        List<AddressBook__c> addrs = [
            SELECT Id, City__c, Pincode__c, AI_short_code__c
            FROM AddressBook__c
            WHERE RecordTypeId = :shippingRT
              AND City__c != null
              AND Pincode__c != null
        ];

        Map<Id,List<AddressBook__c>> clusters = new Map<Id,List<AddressBook__c>>();

        for(AddressBook__c ad : addrs){

            String norm = normalize(ad.City__c, ad.Pincode__c);

            if(shippingIndex.containsKey(norm)){

                Id accId = shippingIndex.get(norm);

                if(!clusters.containsKey(accId)){
                    clusters.put(accId, new List<AddressBook__c>());
                }

                clusters.get(accId).add(ad);
            }
        }

        List<AddressBook__c> updates = new List<AddressBook__c>();

        for(Id accId : clusters.keySet()){

            List<AddressBook__c> addrGroup = clusters.get(accId);

            if(addrGroup.size() < 2) continue;

            String gid = 'ADDR-' + generateShortId();

            for(AddressBook__c a : addrGroup){
    			a.AI_short_code__c = gid;
    			
   				 updates.add(a);
			}

        }

if(!updates.isEmpty()){

    Integer chunkSize = 1;   // change to 1 if Flow still fails

    for(Integer i = 0; i < updates.size(); i += chunkSize){

        List<AddressBook__c> chunk = new List<AddressBook__c>();

        for(Integer j = i; j < Math.min(i + chunkSize, updates.size()); j++){
            chunk.add(updates[j]);
        }

        try{
            update chunk;
        }
        catch(Exception e){
            System.debug('Chunk failed: ' + e.getMessage());
        }
    }
}


        System.debug('Updated records: ' + updates.size());
    }

    private static String normalize(String city, String pin){

        String s = city + ' ' + pin;

        if(String.isBlank(s)) return '';

        s = s.toLowerCase();
        s = s.replaceAll('[^a-z0-9 ]',' ');
        s = s.replaceAll('\\s+',' ').trim();

        return s;
    }

    private static String generateShortId(){
        Blob b = Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(Math.random())));
        return EncodingUtil.convertToHex(b).substring(0,8);
    }
}