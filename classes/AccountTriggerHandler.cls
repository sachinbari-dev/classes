public class AccountTriggerHandler {
    public static void checkForDuplicatePANNumber(List<Account> newAccounts) {
        Set<Id> validRecordTypeIds = new Set<Id>{
            '0125g0000002XavAAE',
            '0125g0000002XaxAAE'
        };
        Id existingRecordTypeId = '0125g0000002XavAAE';

        Set<String> newPanNumbers = new Set<String>();
        Map<String, Account> panToAccountMap = new Map<String, Account>();
        Set<Id> newAccountIds = new Set<Id>();

        // Determine the user's profile and ID
        String sysAdminProfileName = 'System Administrator'; 
        String currentUserProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        Id specificUserId = '0055g00000HZlpNAAT';

        // Collect PAN numbers and map them to accounts, excluding unchanged PAN numbers during update
        for (Account acc : newAccounts) {
            Account oldAcc = null;
            if (Trigger.isUpdate) {
                oldAcc = (Account) Trigger.oldMap.get(acc.Id); // Explicitly cast to Account
            }

            if (validRecordTypeIds.contains(acc.RecordTypeId) && acc.PAN_Number_of_Entity__c != null && 
                (oldAcc == null || acc.PAN_Number_of_Entity__c != oldAcc.PAN_Number_of_Entity__c)) {
                newPanNumbers.add(acc.PAN_Number_of_Entity__c);
                panToAccountMap.put(acc.PAN_Number_of_Entity__c, acc);
                newAccountIds.add(acc.Id); // Collect IDs for exclusion
            }
        }

        if (!newPanNumbers.isEmpty()) {
            // Query existing accounts with matching PAN numbers, excluding the current records being updated
            List<Account> existingAccounts = [
                SELECT Id, PAN_Number_of_Entity__c, RecordTypeId 
                FROM Account 
                WHERE PAN_Number_of_Entity__c IN :newPanNumbers 
                AND RecordTypeId = :existingRecordTypeId 
                AND Id NOT IN :newAccountIds
            ];

            for (Account existingAcc : existingAccounts) {
                if (panToAccountMap.containsKey(existingAcc.PAN_Number_of_Entity__c)) {
                    Account newAccount = panToAccountMap.get(existingAcc.PAN_Number_of_Entity__c);

                    // Add error if the user is not a System Administrator or is the specific user
                    if (!currentUserProfileName.equals(sysAdminProfileName) || UserInfo.getUserId() == specificUserId) {
                        newAccount.addError('A billing account with the same PAN Number (' + existingAcc.PAN_Number_of_Entity__c + ') and Account Id (' + existingAcc.Id + ') already exists.');
                    }
                }
            }
        }
    }
}