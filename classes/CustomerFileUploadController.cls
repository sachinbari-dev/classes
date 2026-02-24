public class CustomerFileUploadController {
      @AuraEnabled
    public static void updateFileLink1(String recordId, String contentDocumentId) {
       
        ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
        if (!doc.Title.containsIgnoreCase('Customer File')) {
            doc.Title += ' - Customer File';
            update doc;

}
    }
}