trigger PickupDuplicateValidation on Pickup__c (before insert) 
{
    List<String> customerIds = new List<String>();

    for (Pickup__c pick : Trigger.new)
    {
        if (pick.Customer__c != null)
        {
            customerIds.add(pick.Customer__c);
        }
    }

    System.debug('Customer Ids Size: ' + customerIds.size());

    List<Pickup__c> recentAccounts = [
        SELECT Id, Name, CreatedDate, Shipper_Address__c, Shipper_Name__c, Customer__c, Pickup_Date_and_Time__c
        FROM Pickup__c 
        WHERE CreatedDate = TODAY 
          AND Customer__c IN :customerIds
    ];

    System.debug('Recent Accounts Size: ' + recentAccounts.size());

    DateTime currentDateTime = System.now();

    // *** Validation: Prevent past datetime ***
    for (Pickup__c pick : Trigger.new)
    {
        if (pick.Pickup_Date_and_Time__c != null)
        {
            if (pick.Pickup_Date_and_Time__c < currentDateTime.addMinutes(-1))
            {
                pick.addError('Pickup Date/Time cannot be earlier than the current time.');
            }
        }
        else
        {
            pick.Pickup_Date_and_Time__c = currentDateTime;  // auto-set if not provided
        }
    }

    // *** Duplicate Validation ***
    for (Pickup__c pk : recentAccounts)
    {
        for (Pickup__c pick : Trigger.new)
        {
            if (pick.Customer__c != null && pick.Shipper_Address__c != null && pick.Shipper_Name__c != null)
            {
                if (pk.Shipper_Address__c == pick.Shipper_Address__c &&
                    pk.Shipper_Name__c == pick.Shipper_Name__c &&
                    pk.Customer__c == pick.Customer__c &&
                    pick.Pickup_Date_and_Time__c >= pk.Pickup_Date_and_Time__c.addMinutes(-1) &&
                    pick.Pickup_Date_and_Time__c <= pk.Pickup_Date_and_Time__c.addMinutes(+1))
                {
                    pick.addError('Duplicate pickup creation detected at the same time');
                }
            }
        }
    }
}