trigger securePackagingTrigger on Secure_Packaging__c (before insert,after update) {

    if(Trigger.isAfter){
        if(trigger.isUpdate){
       
        }
    }
}