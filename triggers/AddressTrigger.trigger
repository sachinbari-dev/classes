/*
 * Last Modified By 	: Imran
 * Last Modified Date 	: 08-10-2025
 * Changes 				: Section 1 Added
 * Description 			: control record insert/update, to avoid looping (recursion)
 */
trigger AddressTrigger on AddressBook__c (after insert,after update) {
    // section 1
    if (ApexTriggerControl.hasAlreadyRun) {
        return;
    }
    ApexTriggerControl.hasAlreadyRun = true;
    // section 1
    List<Address_Status__mdt> addstatus=[Select id,AddressTriggerStatus__c,RegAccountTriggerStatus__c from Address_Status__mdt limit 1];
    if(addstatus.size()>=1 && addstatus[0].AddressTriggerStatus__c==True && addstatus[0].AddressTriggerStatus__c!=null){
        system.debug('AddressTrigger Before Return');
        return;
    }
    system.debug('AddressTrigger After Return');
    if(Trigger.isAfter && Trigger.isInsert){      
        Address_TriggerHandlerServiceCtrl a=new Address_TriggerHandlerServiceCtrl();
        if(!Test.isRunningTest()){
            Address_TriggerHandlerServiceCtrl.updateBillingAddressCheckBox(Trigger.new);
        }
        Address_TriggerHandlerServiceCtrl.addressPickupMappingCreation(Trigger.new);
        Address_TriggerHandlerServiceCtrl.createPICKUPADDRESSMAPPING(Trigger.new);
       
    }
    if(Trigger.isAfter && Trigger.isUpdate){        
        Address_TriggerHandlerServiceCtrl a=new Address_TriggerHandlerServiceCtrl();        
        if(!Test.isRunningTest()){
            Address_TriggerHandlerServiceCtrl.updateBillingAddressCheckBox(Trigger.new);
        }
    }
}