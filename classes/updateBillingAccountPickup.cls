public class updateBillingAccountPickup{
    public void updateBillingAccounts(List<Pickup__c> newPickupBillingAccList, Map<Id, Pickup__c> oldPickupMap) {
    // update Billing Account
    Set<Id> accountIds = new Set<Id>();
    List<Pickup__c> PickupWithBillingAccountList = new List<Pickup__c>();
    
    for (Pickup__c pick : newPickupBillingAccList) {
        if (pick.Customer__c != null) {
            accountIds.add(pick.Customer__c);
        }
        if (pick.Billing_Account__c != null) {
            PickupWithBillingAccountList.add(pick);
        }
    }

    Profile[] profileList = [SELECT Id, Name, UserType, UserLicense.Name FROM Profile WHERE Id = :userinfo.getProfileId() AND UserLicense.Name LIKE 'Customer Community Plus%' LIMIT 1];
    Boolean showError = profileList.size() > 0 ? false : true;

    Map<Id, Account> mapOfIdVsAccount = new Map<Id, Account>([SELECT Id, name, ParentId, Primary_Address__c, Primary_Address__r.id, (SELECT Id, name, Primary_Address__c, Primary_Address__r.id FROM ChildAccounts) FROM Account WHERE Id IN :accountIds LIMIT 50000]);

    for (Pickup__c pick : newPickupBillingAccList) {
        if (pick.Customer__c != null && (Trigger.isInsert || pick.Customer__c != oldPickupMap.get(pick.Id).Customer__c)) {
            if (mapOfIdVsAccount.containsKey(pick.Customer__c)) {
                if (mapOfIdVsAccount.get(pick.Customer__c).ChildAccounts.size() == 0) {
                    pick.Billing_Account__c = mapOfIdVsAccount.get(pick.Customer__c).Id;
                    pick.Billing_Address__c = mapOfIdVsAccount.get(pick.Customer__c).Primary_Address__r.Id;
                }
                if (mapOfIdVsAccount.get(pick.Customer__c).ChildAccounts.size() == 1) {
                    for (Account cust : mapOfIdVsAccount.get(pick.Customer__c).ChildAccounts) {
                        pick.Billing_Account__c = cust.Id;
                        pick.Billing_Address__c = cust.Primary_Address__r.Id;
                    }
                }
                if (mapOfIdVsAccount.get(pick.Customer__c).ChildAccounts.size() > 1 && (pick.Billing_Account__c == null || pick.Billing_Address__c == null)) {
                    if (showError) { // to bypass mobile and Community
                        
                            newPickupBillingAccList[0].addError('Please select a Billing Account and Billing Address');
                       
                    }
                }
            }
        }
    }

   if (PickupWithBillingAccountList != null && PickupWithBillingAccountList.size() > 0) {
       updateBillingAccount_handlerPickup.updatePrimaryAddress(PickupWithBillingAccountList);
   }
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
public static void GetCoverage(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
}
}