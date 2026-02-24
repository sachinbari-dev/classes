public class DuplicateAccountChecker {

    public static void checkForDuplicateAccounts(List<Account> newAccounts) {
        Set<String> panNumbers = new Set<String>();
        Map<String, Id> existingAccountsMap = new Map<String, Id>();
        String recordTypeName = 'Shipping'; 

        // Collect PAN numbers from the new accounts, converting them to uppercase
        for (Account acc : newAccounts) {
            if (acc.PAN_Number_of_Entity__c != null) {
                panNumbers.add(acc.PAN_Number_of_Entity__c.toUpperCase());
            }
        }

        // Query existing accounts with the same PAN numbers and record type
        List<Account> existingAccounts = [SELECT Id, PAN_Number_of_Entity__c
                                          FROM Account
                                          WHERE PAN_Number_of_Entity__c IN :panNumbers
                                          AND RecordType.Name = :recordTypeName];

        // Populate the map with existing PAN numbers in uppercase
        for (Account existingAcc : existingAccounts) {
            existingAccountsMap.put(existingAcc.PAN_Number_of_Entity__c.toUpperCase(), existingAcc.Id);
        }

        // Check for duplicates and add error messages to the new accounts
        for (Account newAcc : newAccounts) {
            if (newAcc.PAN_Number_of_Entity__c != null) {
                // Convert PAN number to uppercase for consistency in comparison
                String panUpper = newAcc.PAN_Number_of_Entity__c.toUpperCase();
                if (existingAccountsMap.containsKey(panUpper)) {
                    newAcc.addError('A duplicate account with PAN Number ' + newAcc.PAN_Number_of_Entity__c +
                                    ' and record type ' + recordTypeName + ' already exists. Account Id: ' +
                                    existingAccountsMap.get(panUpper));
                }
            }
        }
    }
}