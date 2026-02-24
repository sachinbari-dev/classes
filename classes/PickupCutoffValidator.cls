public class PickupCutoffValidator {

    public static void validatePickupTime(List<Pickup__c> pickups) {

    
        String currentProfile = [
            SELECT Profile.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].Profile.Name;

        Set<String> excludedProfiles = new Set<String>{
            'Operations Field Executive',
            'Operations Admin',
            'Operations Office Executive'
        };

        Boolean isExcludedUser = excludedProfiles.contains(currentProfile);

        Set<Id> addressIds = new Set<Id>();

        for (Pickup__c p : pickups) {
            if (p.Shipper_Address__c != null) {
                addressIds.add(p.Shipper_Address__c);
            }
        }

        if (addressIds.isEmpty()) {
            return;
        }

     
        Map<Id, AddressBook__c> addressMap = new Map<Id, AddressBook__c>(
            [SELECT Id,
                    Active_Pincode__r.Pickup_End_Cutoff_Time__c,
                    Active_Pincode__r.Creation_Lead_Time__c,
                    Active_Pincode__r.Name
             FROM AddressBook__c
             WHERE Id IN :addressIds]
        );

        Time currentTime = Datetime.now().time();

        for (Pickup__c pickup : pickups) {

            AddressBook__c addr = addressMap.get(pickup.Shipper_Address__c);

            if (addr == null || addr.Active_Pincode__r == null) {
                continue;
            }

         
            if (isExcludedUser) {
                if (String.isBlank(pickup.Remarks__c)) {
                    pickup.Remarks__c.addError('Please Fill Remarks, As Pickup CutOff Time Is Over.');
                }
                continue; 
            }

           
            if (addr.Active_Pincode__r.Pickup_End_Cutoff_Time__c != null &&
                addr.Active_Pincode__r.Creation_Lead_Time__c != null) {

                Time endTime = addr.Active_Pincode__r.Pickup_End_Cutoff_Time__c;
                Integer leadHours = Integer.valueOf(addr.Active_Pincode__r.Creation_Lead_Time__c);

                Datetime cutoffDT = Datetime.newInstance(Date.today(), endTime);
                Datetime allowedDT = cutoffDT.addHours(-leadHours);

                if (currentTime > allowedDT.time()) {

                    pickup.addError(
                        'Pickup cannot be created after ' +
                        allowedDT.format('hh:mm a') +
                        ' for pincode ' +
                        addr.Active_Pincode__r.Name +
                        ' as per cutoff configuration.'
                    );
                }
            }
        }
    }
}