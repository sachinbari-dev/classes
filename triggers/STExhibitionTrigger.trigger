trigger STExhibitionTrigger on ST_Exhibition__c (after update) {

    Set<Id> inactiveExhibitionIds = new Set<Id>();

    for (ST_Exhibition__c newRec : Trigger.new) {
        ST_Exhibition__c oldRec = Trigger.oldMap.get(newRec.Id);

       
        if (oldRec.ST_Active__c == true &&
            newRec.ST_Active__c == false) {

            inactiveExhibitionIds.add(newRec.Id);
        }
    }

    if (!inactiveExhibitionIds.isEmpty()) {
        System.enqueueJob(
            new DeactivateAddressQueueable(inactiveExhibitionIds)
        );
    }
}