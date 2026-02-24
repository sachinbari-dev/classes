/* Created By : Sanket Pisal */
/* Created Date : Feb 2025 */
public without sharing class AccountShareHelper {
    @InvocableMethod(label='Share BVC Contracts with Account Owners')
    public static void shareBVCContracts(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            System.debug('No account IDs provided.');
            return;
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, OwnerId, Sales_Secondary_Owner__c FROM Account WHERE Id IN :accountIds]
        );
        
        Set<Id> userIds = new Set<Id>();
        for (Account acc : accountMap.values()) {
            if (acc.OwnerId != null) userIds.add(acc.OwnerId);
            if (acc.Sales_Secondary_Owner__c != null) userIds.add(acc.Sales_Secondary_Owner__c);
        }
        
        // Fetch valid User IDs
        Set<Id> validUserIds = new Set<Id>();
        for (User usr : [SELECT Id FROM User WHERE Id IN :userIds]) {
            validUserIds.add(usr.Id);
        }

        // Fetch BVC_Contract__c records
        List<BVC_Contract__c> contracts = [
            SELECT Id, Customer_Name__c 
            FROM BVC_Contract__c 
            WHERE Customer_Name__c IN :accountIds AND Status__c IN ('Expired', 'Activated')
        ];

        // Fetch existing shares to prevent duplicates
        List<BVC_Contract__Share> existingShares = [
            SELECT ParentId, UserOrGroupId 
            FROM BVC_Contract__Share 
            WHERE ParentId IN :contracts AND UserOrGroupId IN :validUserIds
        ];

        Set<String> existingShareKeys = new Set<String>();
        for (BVC_Contract__Share share : existingShares) {
            existingShareKeys.add(share.ParentId + '_' + share.UserOrGroupId);
        }

        // Create new shares
        List<BVC_Contract__Share> sharesToInsert = new List<BVC_Contract__Share>();
        for (BVC_Contract__c contract : contracts) {
            Account acc = accountMap.get(contract.Customer_Name__c);
            if (acc != null) {
                if (acc.OwnerId != null && validUserIds.contains(acc.OwnerId) &&
                    !existingShareKeys.contains(contract.Id + '_' + acc.OwnerId)) {
                    sharesToInsert.add(createShareRecord(contract.Id, acc.OwnerId));
                }
                if (acc.Sales_Secondary_Owner__c != null && validUserIds.contains(acc.Sales_Secondary_Owner__c) &&
                    !existingShareKeys.contains(contract.Id + '_' + acc.Sales_Secondary_Owner__c)) {
                    sharesToInsert.add(createShareRecord(contract.Id, acc.Sales_Secondary_Owner__c));
                }
            }
        }

        System.debug('Shares to Insert: ' + sharesToInsert);

        // Insert the shares
        if (!sharesToInsert.isEmpty()) {
            try {
                insert sharesToInsert;
                System.debug('Inserted ' + sharesToInsert.size() + ' BVC_Contract__Share records.');
            } catch (DmlException ex) {
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    System.debug('DML Exception at row ' + i + ': ' + ex.getDmlMessage(i));
                }
            }
        } else {
            System.debug('No shares to insert.');
        }
    }

    private static BVC_Contract__Share createShareRecord(Id contractId, Id userId) {
        BVC_Contract__Share share = new BVC_Contract__Share();
        share.ParentId = contractId;
        share.UserOrGroupId = userId;
        share.AccessLevel = 'Read';
        share.RowCause = Schema.BVC_Contract__Share.RowCause.Manual; // Ensure this is valid for your object
        return share;
    }
}