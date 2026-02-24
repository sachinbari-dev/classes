public class AddressUpdateQueue implements Queueable {

    List<AddressBook__c> recs;
    Integer index;

    public AddressUpdateQueue(List<AddressBook__c> r, Integer i){
        recs = r;
        index = i;
    }

    public void execute(QueueableContext qc){

        Integer batchSize = 20;

        Integer endIndex = Math.min(index + batchSize, recs.size());

        List<AddressBook__c> part = new List<AddressBook__c>();

        for(Integer i = index; i < endIndex; i++){
            part.add(recs[i]);
        }

        update part;

        if(endIndex < recs.size()){
            System.enqueueJob(new AddressUpdateQueue(recs, endIndex));
        }
    }
}