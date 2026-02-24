public without sharing class OTPGenerator {
    
    @InvocableMethod(label = 'Generate OTP')
    public static void otpGenerator(List<AcceptDeliveryWrapper> input) {
        System.debug('5 input :'+input);
        Set<Id> deliveryIds = new Set<Id>();
        for (AcceptDeliveryWrapper w : input) {
            deliveryIds.add(w.deliveryId);
        }
        System.debug('10 deliveryIds :'+deliveryIds);
        // Step 1: Fetch triggering deliveries
        List<Delivery__c> triggerDeliveries = [SELECT Id, Consignee_Contact__c, Consignee_Email__c, Address__c FROM Delivery__c WHERE Id IN :deliveryIds];
        System.debug('13 triggerDeliveries :'+triggerDeliveries);
        // Build grouping key: Contact + Address
        Set<String> groupingKeys = new Set<String>();
        Map<Id, String> deliveryIdToKey = new Map<Id, String>();
        
        for (Delivery__c d : triggerDeliveries) {
            if (String.isBlank(d.Consignee_Contact__c) || String.isBlank(d.Address__c)) {
                continue;
            }
            
            String key = d.Consignee_Contact__c + '|' + d.Address__c;
            
            groupingKeys.add(key);
            deliveryIdToKey.put(d.Id, key);
        }
        System.debug('28 deliveryIdToKey :'+deliveryIdToKey);
        System.debug('29 groupingKeys :'+groupingKeys);
        // Step 2: Fetch existing deliveries with OTP for same consignee+address
        List<Delivery__c> existingDeliveries = [SELECT Id, OTP__c, OTP_Expiration__c, Consignee_Contact__c, Address__c FROM Delivery__c
                                                WHERE Consignee_Contact__c != null AND Address__c != null AND OTP__c != null AND Status__c = 'Accepted' AND OTP_Expiration__c > :System.now()];
        System.debug('33 existingDeliveries :'+existingDeliveries);
        // Map existing OTP per key
        Map<String, String> keyToExistingOTP = new Map<String, String>();
        
        for (Delivery__c d : existingDeliveries) {
            String key = d.Consignee_Contact__c + '|' + d.Address__c;
            
            if (groupingKeys.contains(key) && !keyToExistingOTP.containsKey(key)) {
                keyToExistingOTP.put(key, d.OTP__c);
            }
        }
        System.debug('33 keyToExistingOT :'+keyToExistingOTP);
        // Step 3: Assign OTPs
        List<Delivery__c> updates = new List<Delivery__c>();
        
        for (Delivery__c d : triggerDeliveries) {
            String key = deliveryIdToKey.get(d.Id);
            if (key == null) continue;
            
            String otp;
            if (keyToExistingOTP.containsKey(key)) {
                // otp = keyToExistingOTP.get(key); // reuse
                otp = generateOTP();
            } else {
                otp = generateOTP();             // generate once
                keyToExistingOTP.put(key, otp);
            }
            
            updates.add(new Delivery__c(
                Id = d.Id,
                OTP__c = otp,
                OTP_Expiration__c = System.now().addHours(48)
            ));
        }
        System.debug('66 updates :'+updates);
        if (!updates.isEmpty()) {
            update updates;
        }
    }
    
    private static String generateOTP() {
        String digits = '0123456789';
        String otp = '';
        while (otp.length() < 4) {
            Integer idx = Math.mod(
                Math.abs(Crypto.getRandomInteger()),
                digits.length()
            );
            otp += digits.substring(idx, idx + 1);
        }
        return otp;
    }
    
    public class AcceptDeliveryWrapper {
        @InvocableVariable(required = true)
        public Id deliveryId;
    }
}