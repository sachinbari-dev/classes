public class BVCContractTriggerHandler {
    public static void handleContractEmails(List<BVC_Contract__c> newList, Map<Id, BVC_Contract__c> oldMap) {
        List<Id> toSend = new List<Id>();

        for (BVC_Contract__c contract : newList) {
            BVC_Contract__c oldCon = oldMap != null ? oldMap.get(contract.Id) : null;

            // Ensure contract is latest
            if (contract.Latest_Contract__c != true || contract.Customer_Name__c == null) {
                continue;
            }

            // Skip if no change in of_Contract_Consumption__c
            if (oldCon != null && contract.of_Contract_Consumption__c == oldCon.of_Contract_Consumption__c) {
                continue;
            }

            Decimal percent = contract.of_Contract_Consumption__c;
            if (percent == null) continue;

            // Check threshold logic
            if ((percent > 80 && percent < 119) || percent >= 120) {
                toSend.add(contract.Id);
            }
        }

        if (!toSend.isEmpty()) {
            BVCContractConsumptionMailer.sendContractConsumptionEmail(toSend);
        }
    }
}