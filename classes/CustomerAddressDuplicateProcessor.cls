public class CustomerAddressDuplicateProcessor {

    private static Decimal THRESHOLD = 0.30;

    public static void processCustomer(Id accountId){

        Id shippingRT =
            Schema.SObjectType.AddressBook__c
                .getRecordTypeInfosByDeveloperName()
                .get('Shipping')
                .getRecordTypeId();

        List<AddressBook__c> addrs = [
            SELECT Id, Name, City__c, Pincode__c, AI_short_code__c
            FROM AddressBook__c
            WHERE Customer__c = :accountId
            AND RecordTypeId = :shippingRT
            AND City__c != null
            AND Pincode__c != null
        ];

        if(addrs.size() < 2) return;

        /* ----------------------------------
           RESET SEQUENCE EVERY RUN
        ---------------------------------- */
        Integer seq = 1;

        /* ----------------------------------
           Bucket by PINCODE + CITY
        ---------------------------------- */

        Map<String,List<AddressBook__c>> buckets = new Map<String,List<AddressBook__c>>();

        for(AddressBook__c a : addrs){

            if(a.AI_short_code__c != null) continue;

            String key = normalize(a.Pincode__c + ' ' + a.City__c);

            if(!buckets.containsKey(key))
                buckets.put(key,new List<AddressBook__c>());

            buckets.get(key).add(a);
        }

        List<AddressBook__c> updates = new List<AddressBook__c>();

        /* ----------------------------------
           FUZZY MATCHING
        ---------------------------------- */

        for(String k : buckets.keySet()){

            List<AddressBook__c> grp = buckets.get(k);
            if(grp.size() < 2) continue;

            Boolean[] used = new Boolean[grp.size()];
            for(Integer i=0;i<used.size();i++) used[i]=false;

            for(Integer i=0;i<grp.size();i++){

                if(used[i]) continue;

                List<AddressBook__c> dup = new List<AddressBook__c>();
                dup.add(grp[i]);

                String base = normalize(grp[i].Name + ' ' + grp[i].City__c + ' ' + grp[i].Pincode__c);

                for(Integer j=i+1;j<grp.size();j++){

                    if(used[j]) continue;

                    String cmp = normalize(grp[j].Name + ' ' + grp[j].City__c + ' ' + grp[j].Pincode__c);

                    if(tokenSimilarity(base,cmp) >= THRESHOLD){
                        dup.add(grp[j]);
                        used[j]=true;
                    }
                }

                if(dup.size() > 1){

                    String code = 'AI-' + String.valueOf(seq).leftPad(3,'0');
                    seq++;

                    for(AddressBook__c r : dup){
                        r.AI_short_code__c = code;
                        updates.add(r);
                    }
                }
            }
        }

        if(!updates.isEmpty())
            update updates;
    }

    /* ================= NORMALIZE ================= */
    private static String normalize(String s){
        if(s==null) return '';
        s = s.toLowerCase();
        s = s.replace('bengaluru','bangalore');
        s = s.replace('bombay','mumbai');
        s = s.replaceAll('[^a-z0-9 ]',' ');
        s = s.replaceAll('\\s+',' ').trim();
        return s;
    }

    /* ================= JACCARD ================= */
    private static Decimal tokenSimilarity(String a,String b){
        Set<String> setA = new Set<String>();
        Set<String> setB = new Set<String>();

        for(String s : a.split(' '))
            if(s != '') setA.add(s);

        for(String s : b.split(' '))
            if(s != '') setB.add(s);

        Set<String> intersection = new Set<String>();
        intersection.addAll(setA);
        intersection.retainAll(setB);

        Integer unionSize =
            setA.size() + setB.size() - intersection.size();

        if(unionSize == 0) return 0;

        return Decimal.valueOf(intersection.size()) /
               Decimal.valueOf(unionSize);
    }
}