public with sharing class ProductMasterController {
    @AuraEnabled(cacheable=true)
    public static List<Product_Master__c> getProducts() {
        return [
            SELECT Name, Stock_Sold__c, Available_Stock__c, Total_Reserved_Stock__c, 
                   Category__c, Stock_Left__c, Description__c, Hub__c, Hub__r.Name,Customer__r.Name
            FROM Product_Master__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getCategoryPicklistValues() {
        List<String> categories = new List<String>();
        Schema.DescribeFieldResult fieldResult = Product_Master__c.Category__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            categories.add(entry.getValue());
        }
        return categories;
    }

 /*   @AuraEnabled(cacheable=true)
    public static List<String> getHubPicklistValues() {
        Set<String> hubSet = new Set<String>();
        for (Product_Master__c product : [SELECT Hub__r.Name FROM Product_Master__c WHERE Hub__r.Name != NULL]) {
            hubSet.add(product.Hub__r.Name);
        }
        return new List<String>(hubSet);
    } */
}