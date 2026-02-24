public class DeactivateAddressQueueable implements Queueable {

    private Set<Id> exhibitionIds;

    public DeactivateAddressQueueable(Set<Id> exhibitionIds) {
        this.exhibitionIds = exhibitionIds;
    }

    public void execute(QueueableContext context) {

        List<AddressBook__c> addresses = [
            SELECT Id, Is_Active__c
            FROM AddressBook__c
            WHERE Exhibition__c IN :exhibitionIds
            AND Is_Active__c = true
        ];

        for (AddressBook__c addr : addresses) {
            addr.Is_Active__c = false;
        }

        if (!addresses.isEmpty()) {
            update addresses;
        }
    }
}