public class ShippingAddressDuplicateService {

    private static Decimal THRESHOLD = 0.50;

    /* ================================================
       STATS TRACKING (like Python)
    ================================================ */
    private static Integer statExactMatch  = 0;
    private static Integer statFuzzyMatch  = 0;
    private static Integer statNewCode     = 0;
    private static Integer statRejectedPin = 0;
    private static Integer statRejectedLow = 0;

    /* ================================================
       MAIN METHOD - Single Customer
    ================================================ */
    public static void processCustomer(Id accountId) {

        // Reset stats
        statExactMatch  = 0;
        statFuzzyMatch  = 0;
        statNewCode     = 0;
        statRejectedPin = 0;
        statRejectedLow = 0;

        /* -----------------------------------------------
           STEP 0 - Clear ALL AI codes for this customer
        ----------------------------------------------- */
        List<AddressBook__c> allAddrs = [
            SELECT Id, AI_short_code__c
            FROM AddressBook__c
            WHERE Customer__c = :accountId
            AND AI_short_code__c != null
        ];
        for (AddressBook__c a : allAddrs) {
            a.AI_short_code__c = null;
        }
        if (!allAddrs.isEmpty()) {
            Database.update(allAddrs, false);
            System.debug('Cleared ' + allAddrs.size() + ' old codes');
        }

        /* -----------------------------------------------
           STEP 1 - Get Shipping Record Type
        ----------------------------------------------- */
        Id shippingRT =
            Schema.SObjectType.AddressBook__c
                .getRecordTypeInfosByDeveloperName()
                .get('Shipping')
                .getRecordTypeId();

        /* -----------------------------------------------
           STEP 2 - Fetch all shipping addresses
        ----------------------------------------------- */
        List<AddressBook__c> addrs = [
            SELECT Id, Name, City__c, Pincode__c, AI_short_code__c
            FROM AddressBook__c
            WHERE Customer__c = :accountId
            AND RecordTypeId = :shippingRT
            AND City__c != null
            AND Pincode__c != null
            ORDER BY Pincode__c, City__c, Name
        ];

        if (addrs.isEmpty()) {
            System.debug('No shipping addresses found for: ' + accountId);
            return;
        }

        System.debug('========================================');
        System.debug('Total addresses found: ' + addrs.size());
        System.debug('========================================');

        /* -----------------------------------------------
           STEP 3 - Clear Shipping codes + Refetch
        ----------------------------------------------- */
        for (AddressBook__c a : addrs) {
            a.AI_short_code__c = null;
        }
        Database.update(addrs, false);

        addrs = [
            SELECT Id, Name, City__c, Pincode__c, AI_short_code__c
            FROM AddressBook__c
            WHERE Customer__c = :accountId
            AND RecordTypeId = :shippingRT
            AND City__c != null
            AND Pincode__c != null
            ORDER BY Pincode__c, City__c, Name
        ];

        /* -----------------------------------------------
           STEP 4 - Build TWO LEVEL INDEX (like Python)
           Level 1: Exact match index
           Level 2: Fuzzy match index
        ----------------------------------------------- */
        Map<String, String> exactIndex = new Map<String, String>();
        Map<String, String> fuzzyIndex = new Map<String, String>();

        // Also bucket by Pincode + City
        Map<String, List<AddressBook__c>> buckets = 
            new Map<String, List<AddressBook__c>>();
        List<String> keyOrder = new List<String>();

        for (AddressBook__c a : addrs) {
            // Exact key = raw address + pincode (before normalization)
            String exactKey = a.Name.trim() + '|' + a.Pincode__c.trim();

            // Fuzzy key = normalized address + pincode
            String normalized = normalize(
                a.Name + ' ' + a.City__c + ' ' + a.Pincode__c
            );
            String fuzzyKey = normalized + '|' + a.Pincode__c.trim();

            // Bucket key = pincode + city
            String bucketKey = normalize(a.Pincode__c + ' ' + a.City__c);

            if (!buckets.containsKey(bucketKey)) {
                buckets.put(bucketKey, new List<AddressBook__c>());
                keyOrder.add(bucketKey);
            }
            buckets.get(bucketKey).add(a);
        }

        /* -----------------------------------------------
           STEP 5 - Fuzzy match and assign codes
        ----------------------------------------------- */
        Integer seq = 1;
        List<AddressBook__c> toUpdate = new List<AddressBook__c>();

        for (String k : keyOrder) {
            List<AddressBook__c> grp = buckets.get(k);

            Boolean[] used = new Boolean[grp.size()];
            for (Integer i = 0; i < used.size(); i++) used[i] = false;

            for (Integer i = 0; i < grp.size(); i++) {
                if (used[i]) continue;

                List<AddressBook__c> dup = new List<AddressBook__c>();
                dup.add(grp[i]);
                used[i] = true;

                // ✅ FIX 1 - Exact key check FIRST (like Python)
                String exactKeyI = grp[i].Name.trim() + '|' + 
                                   grp[i].Pincode__c.trim();

                String baseNorm = normalize(
                    grp[i].Name + ' ' + 
                    grp[i].City__c + ' ' + 
                    grp[i].Pincode__c
                );

                // Extract numbers from base (like Python)
                Set<String> baseNumbers = extractNumbers(baseNorm);

                for (Integer j = i + 1; j < grp.size(); j++) {
                    if (used[j]) continue;

                    String pincodeI = grp[i].Pincode__c.trim();
                    String pincodeJ = grp[j].Pincode__c.trim();

                    // ✅ FIX 2 - Pincode MUST match exactly (like Python)
                    if (pincodeI != pincodeJ) {
                        statRejectedPin++;
                        continue;
                    }

                    // ✅ FIX 3 - Exact match check BEFORE fuzzy (like Python)
                    String exactKeyJ = grp[j].Name.trim() + '|' + 
                                       grp[j].Pincode__c.trim();

                    if (exactKeyI == exactKeyJ) {
                        dup.add(grp[j]);
                        used[j] = true;
                        statExactMatch++;
                        System.debug('EXACT MATCH: ' + grp[i].Name + 
                                     ' == ' + grp[j].Name);
                        continue;
                    }

                    // ✅ FIX 4 - Fuzzy match with number check (like Python)
                    String cmpNorm = normalize(
                        grp[j].Name + ' ' + 
                        grp[j].City__c + ' ' + 
                        grp[j].Pincode__c
                    );

                    // Number check — if both have numbers they must share one
                    Set<String> cmpNumbers = extractNumbers(cmpNorm);
                    if (!baseNumbers.isEmpty() && !cmpNumbers.isEmpty()) {
                        Set<String> numIntersect = new Set<String>(baseNumbers);
                        numIntersect.retainAll(cmpNumbers);
                        if (numIntersect.isEmpty()) {
                            statRejectedLow++;
                            System.debug('REJECTED (different numbers): ' + 
                                         grp[i].Name + ' vs ' + grp[j].Name);
                            continue;
                        }
                    }

                    // ✅ FIX 5 - Multi score similarity (like Python)
                    Decimal jaccard   = tokenSimilarity(baseNorm, cmpNorm);
                    Decimal tokenSort = tokenSortSimilarity(baseNorm, cmpNorm);
                    Decimal bestScore = Math.max(jaccard, tokenSort);

                    System.debug('COMPARING: ' + grp[i].Name + 
                                 ' vs ' + grp[j].Name);
                    System.debug('  Jaccard: '    + (jaccard * 100).setScale(1) + '%' +
                                 ' | TokenSort: ' + (tokenSort * 100).setScale(1) + '%' +
                                 ' | Best: '      + (bestScore * 100).setScale(1) + '%');

                    if (bestScore >= THRESHOLD) {
                        dup.add(grp[j]);
                        used[j] = true;
                        statFuzzyMatch++;
                        System.debug('  → FUZZY MATCH ✅ (' + 
                                     (bestScore * 100).setScale(1) + '%)');
                    } else {
                        statRejectedLow++;
                        System.debug('  → NO MATCH ❌ (' + 
                                     (bestScore * 100).setScale(1) + '%)');
                    }
                }

                // Assign code to ALL in cluster
                String code = 'AI-' + String.valueOf(seq).leftPad(3, '0');
                seq++;
                statNewCode++;

                for (AddressBook__c r : dup) {
                    r.AI_short_code__c = code;
                    toUpdate.add(r);
                }
            }
        }

        /* -----------------------------------------------
           STEP 6 - Save to Salesforce
        ----------------------------------------------- */
        if (!toUpdate.isEmpty()) {
            List<Database.SaveResult> results = 
                Database.update(toUpdate, false);

            Integer success = 0;
            Integer failed  = 0;

            for (Database.SaveResult r : results) {
                if (r.isSuccess()) {
                    success++;
                } else {
                    failed++;
                    System.debug('FAILED ID: ' + r.getId() +
                                 ' | Error: ' + 
                                 r.getErrors()[0].getMessage());
                }
            }

            /* -----------------------------------------------
               STEP 7 - Print Stats (like Python)
            ----------------------------------------------- */
            System.debug('');
            System.debug('========================================');
            System.debug('           PROCESSING STATS             ');
            System.debug('========================================');
            System.debug('Total Addresses    : ' + addrs.size());
            System.debug('Total Codes Assigned: ' + (seq - 1));
            System.debug('----------------------------------------');
            System.debug('Matches:');
            System.debug('  Exact Matches    : ' + statExactMatch);
            System.debug('  Fuzzy Matches    : ' + statFuzzyMatch);
            System.debug('  New Codes        : ' + statNewCode);
            System.debug('----------------------------------------');
            System.debug('Rejections:');
            System.debug('  Diff Pincode     : ' + statRejectedPin);
            System.debug('  Low Similarity   : ' + statRejectedLow);
            System.debug('----------------------------------------');
            System.debug('Database:');
            System.debug('  SUCCESS          : ' + success);
            System.debug('  FAILED           : ' + failed);
            System.debug('========================================');
        }
    }

    /* ================================================
       NORMALIZE - Extensive (upgraded)
    ================================================ */
    private static String normalize(String s) {
        if (s == null) return '';

        s = s.toLowerCase();

        // Remove pincode from address text (like Python)
        s = s.replaceAll('\\b\\d{6}\\b', ' ');

        // City corrections
        s = s.replace('bengaluru',   'bangalore');
        s = s.replace('bangaluru',   'bangalore');
        s = s.replace('bombay',      'mumbai');
        s = s.replace('madras',      'chennai');
        s = s.replace('calcutta',    'kolkata');
        s = s.replace('poona',       'pune');
        s = s.replace('mangaluru',   'mangalore');
        s = s.replace('gurugram',    'gurgaon');
        s = s.replace('vizag',       'visakhapatnam');
        s = s.replace('secundrabad', 'secunderabad');

        // Floor numbers
        s = s.replace('ground floor', 'gf');
        s = s.replace('grd floor',    'gf');
        s = s.replace('1st floor',    '1 floor');
        s = s.replace('2nd floor',    '2 floor');
        s = s.replace('3rd floor',    '3 floor');
        s = s.replace('4th floor',    '4 floor');
        s = s.replace('5th floor',    '5 floor');
        s = s.replace('first floor',  '1 floor');
        s = s.replace('second floor', '2 floor');
        s = s.replace('third floor',  '3 floor');
        s = s.replace('fourth floor', '4 floor');
        s = s.replace('fifth floor',  '5 floor');

        // Ordinals
        s = s.replace('2nf',    '2');
        s = s.replace('2nd',    '2');
        s = s.replace('1st',    '1');
        s = s.replace('3rd',    '3');
        s = s.replace('4th',    '4');
        s = s.replace('5th',    '5');
        s = s.replace('6th',    '6');
        s = s.replace('7th',    '7');
        s = s.replace('8th',    '8');
        s = s.replace('9th',    '9');
        s = s.replace('first',  '1');
        s = s.replace('second', '2');
        s = s.replace('third',  '3');
        s = s.replace('fourth', '4');
        s = s.replace('fifth',  '5');

        // Road types
        s = s.replace('strt',  'street');
        s = s.replace('str',   'street');
        s = s.replace('st',    'street');
        s = s.replace('rd',    'road');
        s = s.replace('rd.',   'road');
        s = s.replace('ave',   'avenue');
        s = s.replace('blvd',  'boulevard');
        s = s.replace('ln',    'lane');
        s = s.replace('marg',  'road');
        s = s.replace('ngr',   'nagar');

        // Building types
        s = s.replace('flr',   'floor');
        s = s.replace('fl.',   'floor');
        s = s.replace('bldg',  'building');
        s = s.replace('bld',   'building');
        s = s.replace('blg',   'building');
        s = s.replace('flat',  'apartment');
        s = s.replace('apt',   'apartment');
        s = s.replace('appt',  'apartment');
        s = s.replace('unit',  'apartment');
        s = s.replace('h no',  'door no');
        s = s.replace('h.no',  'door no');
        s = s.replace('hn',    'door no');
        s = s.replace('d no',  'door no');
        s = s.replace('d.no',  'door no');
        s = s.replace('plt',   'plot');
        s = s.replace('shp',   'shop');

        // Locality
        s = s.replace('col.',  'colony');
        s = s.replace('clny',  'colony');
        s = s.replace('extn',  'extension');
        s = s.replace('ext',   'extension');
        s = s.replace('encl',  'enclave');
        s = s.replace('lt',    'layout');
        s = s.replace('sec',   'sector');
        s = s.replace('blk',   'block');
        s = s.replace('ph',    'phase');

        // Landmarks
        s = s.replace('opp',   'opposite');
        s = s.replace('nr',    'near');
        s = s.replace('adj',   'adjacent');
        s = s.replace('beh',   'behind');
        s = s.replace('jn',    'junction');
        s = s.replace('junc',  'junction');
        s = s.replace('xrd',   'junction');

        // Market
        s = s.replace('mkt',   'market');
        s = s.replace('mrkt',  'market');
        s = s.replace('cmplx', 'complex');
        s = s.replace('cmpx',  'complex');
        s = s.replace('plza',  'plaza');
        s = s.replace('plz',   'plaza');
        s = s.replace('ctr',   'center');
        s = s.replace('centre','center');
        s = s.replace('indl',  'industrial');
        s = s.replace('est',   'estate');

        // Cross / Main
        s = s.replace('cr',    'cross');
        s = s.replace('crs',   'cross');
        s = s.replace('mn',    'main');

        // Symbols
        s = s.replace('&',     'and');
        s = s.replace('w/',    'with');
        s = s.replace('c/o',   'care of');

        // Typos
        s = s.replace('steet',     'street');
        s = s.replace('raod',      'road');
        s = s.replace('rooad',     'road');
        s = s.replace('nagr',      'nagar');
        s = s.replace('apratment', 'apartment');
        s = s.replace('aparment',  'apartment');
        s = s.replace('buliding',  'building');
        s = s.replace('buidling',  'building');
        s = s.replace('buiding',   'building');
        s = s.replace('colny',     'colony');
        s = s.replace('coloney',   'colony');
        s = s.replace('socity',    'society');
        s = s.replace('soceity',   'society');

        // Remove state names (like Python)
        s = s.replace('andhra pradesh', '');
        s = s.replace('karnataka',      '');
        s = s.replace('maharashtra',    '');
        s = s.replace('tamil nadu',     '');
        s = s.replace('telangana',      '');
        s = s.replace('kerala',         '');
        s = s.replace('gujarat',        '');
        s = s.replace('rajasthan',      '');
        s = s.replace('west bengal',    '');
        s = s.replace('uttar pradesh',  '');

        // Remove special chars
        s = s.replaceAll('[^a-z0-9 ]', ' ');

        // Remove duplicate consecutive words (like Python)
        s = removeDuplicateWords(s);

        // Collapse spaces
        s = s.replaceAll('\\s+', ' ').trim();

        return s;
    }

    /* ================================================
       REMOVE DUPLICATE CONSECUTIVE WORDS (like Python)
    ================================================ */
    private static String removeDuplicateWords(String s) {
        if (s == null || s.trim() == '') return '';
        List<String> words = s.split(' ');
        List<String> result = new List<String>();
        String prev = '';
        for (String w : words) {
            if (w != '' && w.toLowerCase() != prev.toLowerCase()) {
                result.add(w);
                prev = w;
            }
        }
        return String.join(result, ' ');
    }

    /* ================================================
       EXTRACT NUMBERS (like Python)
    ================================================ */
    private static Set<String> extractNumbers(String s) {
        Set<String> numbers = new Set<String>();
        if (s == null) return numbers;
        Matcher m = Pattern.compile('\\d+').matcher(s);
        while (m.find()) {
            numbers.add(m.group());
        }
        return numbers;
    }

    /* ================================================
       JACCARD SIMILARITY
    ================================================ */
    private static Decimal tokenSimilarity(String a, String b) {
        Set<String> setA = new Set<String>();
        Set<String> setB = new Set<String>();

        for (String s : a.split(' '))
            if (s != '') setA.add(s);
        for (String s : b.split(' '))
            if (s != '') setB.add(s);

        Set<String> intersection = new Set<String>(setA);
        intersection.retainAll(setB);

        Integer unionSize = setA.size() + setB.size() - intersection.size();
        if (unionSize == 0) return 0;

        return Decimal.valueOf(intersection.size()) /
               Decimal.valueOf(unionSize);
    }

    /* ================================================
       TOKEN SORT SIMILARITY (like Python token_sort_ratio)
       Sorts words alphabetically before comparing
       Handles word order differences
    ================================================ */
    private static Decimal tokenSortSimilarity(String a, String b) {
        List<String> wordsA = new List<String>();
        List<String> wordsB = new List<String>();

        for (String s : a.split(' '))
            if (s != '') wordsA.add(s);
        for (String s : b.split(' '))
            if (s != '') wordsB.add(s);

        // Sort both lists alphabetically
        wordsA.sort();
        wordsB.sort();

        String sortedA = String.join(wordsA, ' ');
        String sortedB = String.join(wordsB, ' ');

        // Run Jaccard on sorted strings
        return tokenSimilarity(sortedA, sortedB);
    }
}