trigger VaultShipmentTrigger on Vault_Shipmet__c (after update) {
   
    List<Vault_Shipmet__c> verifiedList = new List<Vault_Shipmet__c>();

    for (Vault_Shipmet__c vs : Trigger.new) {
        Vault_Shipmet__c oldVs = Trigger.oldMap.get(vs.Id);
        if (vs.Verified_for_Billing__c == true &&
            vs.Verified_for_Billing__c != oldVs.Verified_for_Billing__c) {
            verifiedList.add(vs);
        }
    }

    if (!verifiedList.isEmpty()) {
        VaultShipmentTriggerHelper.createBVCOrder(verifiedList);
    }


}