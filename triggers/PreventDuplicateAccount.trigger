trigger PreventDuplicateAccount on Account (before insert, after update) {
    // Run original duplicate prevention logic only for insert
    if (Trigger.isInsert) {
        Set<String> panNumbers = new Set<String>();
        Set<Id> recordTypeValuesToCheck = new Set<Id>{
            '0125g0000002XazAAE', '0125g0000002Xay', '0125g0000002Xaz'
        };

        for (Account acc : Trigger.new) {
            if (acc.RecordTypeId != null && recordTypeValuesToCheck.contains(acc.RecordTypeId) && 
                acc.PAN_Number_of_Entity__c != null) {
                panNumbers.add(acc.PAN_Number_of_Entity__c);
            }
        }

        List<Account> existingAccounts = [SELECT Id, PAN_Number_of_Entity__c
                                          FROM Account
                                          WHERE PAN_Number_of_Entity__c IN :panNumbers
                                          AND RecordTypeId IN :recordTypeValuesToCheck];

        Map<String, Id> existingPanNumbers = new Map<String, Id>();
        for (Account existingAcc : existingAccounts) {
            existingPanNumbers.put(existingAcc.PAN_Number_of_Entity__c, existingAcc.Id);
        }

        for (Account newAcc : Trigger.new) {
            if (newAcc.RecordTypeId != null && recordTypeValuesToCheck.contains(newAcc.RecordTypeId) &&
                existingPanNumbers.containsKey(newAcc.PAN_Number_of_Entity__c)) {
                newAcc.addError('A duplicate account with PAN Number ' + newAcc.PAN_Number_of_Entity__c +
                                ' and Record Type Shipping already exists. Account Id: ' +
                                existingPanNumbers.get(newAcc.PAN_Number_of_Entity__c));
            }
        }
    }

    // Run the handler logic for both insert and update
    AccountTriggerHandler.checkForDuplicatePANNumber(Trigger.new);

   
}