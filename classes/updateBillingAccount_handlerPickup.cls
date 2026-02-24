public class updateBillingAccount_handlerPickup {
// Added to update primary billing address from billing account
    public static void updatePrimaryAddress(List<Pickup__c> PickList) {
        Set<Id> BillingAccSet = new Set<Id>();
        for (Pickup__c pick : PickList) {
            BillingAccSet.add(pick.Billing_Account__c);
        }

        Map<Id, Account> PrimaryAddressMap = new Map<Id, Account>([SELECT Primary_Address__c FROM Account WHERE Id IN :BillingAccSet]);
        
        for (Pickup__c pick : PickList) {
            if (PrimaryAddressMap.containsKey(pick.Billing_Account__c) && PrimaryAddressMap.get(pick.Billing_Account__c).Primary_Address__c != null) {
                pick.Billing_Address__c = PrimaryAddressMap.get(pick.Billing_Account__c).Primary_Address__c;
                //pick.BillTo_Party_Address__c = PrimaryAddressMap.get(pick.Billing_Account__c).Primary_Address__c;
            }
        }
    }
}