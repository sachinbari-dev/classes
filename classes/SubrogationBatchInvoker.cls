public class SubrogationBatchInvoker {
    public class BatchInput {
        @InvocableVariable public Id accountId;
    }

    @InvocableMethod
    public static void runBatch(List<BatchInput> inputs) {
        Set<Id> accountIds = new Set<Id>();
        for (BatchInput input : inputs) {
            accountIds.add(input.accountId);
        }

        SubrogationShipmentBatch batch = new SubrogationShipmentBatch(accountIds);
        Database.executeBatch(batch, 50);
    }
}