public class ShippingAccountDuplicate {
public static void checkForDuplicateShippPANNumber(List<Account> newAccounts) {
        
        Set<Id> validRecordTypeIds = new Set<Id>{
            '0125g0000002XazAAE',
            '0125g0000002Xay'
        };
        
    
        Set<String> newPanNumbers = new Set<String>();
        
    
        Map<String, Account> panToAccountMap = new Map<String, Account>();
        
       
        for (Account acc : newAccounts) {
            if (validRecordTypeIds.contains(acc.RecordTypeId) && acc.PAN_Number_of_Entity__c != null) {
                newPanNumbers.add(acc.PAN_Number_of_Entity__c);
                panToAccountMap.put(acc.PAN_Number_of_Entity__c, acc);
            }
        }
        
     
        if (!newPanNumbers.isEmpty()) {
         
            List<Account> existingAccounts = [
                SELECT Id, PAN_Number_of_Entity__c 
                FROM Account 
                WHERE PAN_Number_of_Entity__c IN :newPanNumbers
            ];
            
           
            for (Account existingAcc : existingAccounts) {
                if (panToAccountMap.containsKey(existingAcc.PAN_Number_of_Entity__c)) {
                    Account newAccount = panToAccountMap.get(existingAcc.PAN_Number_of_Entity__c);
                   newAccount.addError('An Shipping account with the same PAN Number (' + existingAcc.PAN_Number_of_Entity__c + ') and Account Id (' + existingAcc.Id + ') already exists.');
                }
            }
        }
    }
}