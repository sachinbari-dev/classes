public class CustomSearchController {
    @AuraEnabled
    public static List<Pickup__c> searchRecords(String searchTerm) {
        String searchQuery = '%' + searchTerm + '%';
        List<Pickup__c> searchResults = [SELECT Customer_PAN__c FROM Pickup__c
                                               WHERE Customer_PAN__c LIKE :searchQuery ];
        return searchResults;
    }
}