/**
* @File Name : UniversalLookupController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 24, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 24, 2025 |   | Initial Version
**/

public with sharing class UniversalLookupController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> searchRecords(String objectApiName, String searchField, String searchTerm, Integer limitSize) {
        String searchText='\'%'+searchTerm+'%\'';
        String query = 'SELECT Id, ' + searchField + ' FROM ' + objectApiName +
                       ' WHERE ' + searchField + ' LIKE  ' + searchText + '' +
                       ' ORDER BY ' + searchField + ' LIMIT :limitSize';
        System.debug('21 query :'+query);
        return Database.query(query);
    }
}