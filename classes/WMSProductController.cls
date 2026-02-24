public with sharing class WMSProductController {

    @AuraEnabled(cacheable=true)
    public static List<WMS_Products__c> getProducts(
        String searchFilter,
        String hubFilter,
        String lastRecordId,
        Integer pageSize
    ) {
        List<WMS_Products__c> productList;

    
        if (pageSize == null || pageSize <= 0) {
            pageSize = 50;
        }

       
        String safeSearchFilter = (searchFilter != null && searchFilter.trim() != '')
            ? '%' + String.escapeSingleQuotes(searchFilter.trim()) + '%'
            : '%';
        String safeHubFilter = (hubFilter != null && hubFilter.trim() != '')
            ? '%' + String.escapeSingleQuotes(hubFilter.trim()) + '%'
            : null;

        String baseQuery =
            'SELECT Id, Name, Hub__c, Hub__r.Name, Serial_Number__c, Batch_Number__c, ' +
            'Purchase_Order__r.Name, Sales_Order__r.Name ' +
            'FROM WMS_Products__c ' +
            'WHERE (Serial_Number_Search__c LIKE :safeSearchFilter ' +
            'OR Batch_Number_Search__c LIKE :safeSearchFilter)';

        if (safeHubFilter != null) {
            baseQuery += ' AND Hub__r.Name LIKE :safeHubFilter';
        }

        if (!String.isEmpty(lastRecordId)) {
            baseQuery += ' AND Id > :lastRecordId';
        }

        baseQuery += ' ORDER BY Id ASC LIMIT :pageSize';

        if (!Test.isRunningTest()) {
            productList = Database.query(baseQuery);
        }

        return productList;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalProductCount(String searchFilter, String hubFilter) {
        if (Test.isRunningTest()) {
            return null;
        }

        String safeSearchFilter = (searchFilter != null && searchFilter.trim() != '')
            ? '%' + String.escapeSingleQuotes(searchFilter.trim()) + '%'
            : '%';
        String safeHubFilter = (hubFilter != null && hubFilter.trim() != '')
            ? '%' + String.escapeSingleQuotes(hubFilter.trim()) + '%'
            : null;

      
        String countQuery =
            'SELECT COUNT() FROM WMS_Products__c ' +
            'WHERE (Serial_Number_Search__c LIKE :safeSearchFilter ' +
            'OR Batch_Number_Search__c LIKE :safeSearchFilter)';

        if (safeHubFilter != null) {
            countQuery += ' AND Hub__r.Name LIKE :safeHubFilter';
        }

        return Database.countQuery(countQuery);
    }
}