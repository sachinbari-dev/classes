trigger ContactTriggerr on Contact (before insert, before update,after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert ) {
            DefaultContactEnforcer.enforceDefaultContact(Trigger.new);
              AddressBookController.enforceContactLimit(Trigger.new);
             DuplicateContactValidator.checkDuplicates(Trigger.new); // Only run on insert
            ContactValidationHelper.preventRestrictedContactCreation(Trigger.new);
       
        }  
         if(Trigger.isUpdate){
                   
          DefaultContactEnforcer.enforceDefaultContact(Trigger.new);
         AddressBookController.enforceContactLimitForUpdate(Trigger.new, Trigger.oldMap);
        
        }
            //ContactEmailValidation.validateEmail(Trigger.new);
        }
    }