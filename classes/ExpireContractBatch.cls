global class ExpireContractBatch implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Replace field names with actual API names
        return Database.getQueryLocator(
            [SELECT Id, Status__c,Contract_End_Date__c   FROM BVC_Contract__c   WHERE Contract_End_Date__c = :Date.newInstance(1998, 1, 1)] //this batch will not trigger as condition will never meet. This was on CPQ object so replaced with BVC contract
        );
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<BVC_Contract__c  > contracts = (List<BVC_Contract__c  >) scope;
        List<BVC_Contract__c  > contractsToUpdate = new List<BVC_Contract__c  >();
         Date todayDate = Date.today();

        for (BVC_Contract__c   c : contracts) {
            if (c.Status__c != 'Expired' && c.Contract_End_Date__c  < todayDate) {
                c.Status__c = 'Expired';
                contractsToUpdate.add(c);
            }
        }

        if (!contractsToUpdate.isEmpty()) {
            update contractsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ExpireContractBatch());
    }
}