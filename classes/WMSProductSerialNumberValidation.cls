public class WMSProductSerialNumberValidation 
{
    public static String validateNumbers(List<String> keywords)
    {
              String query = 'SELECT Id, Name, Serial_Number__c, Sales_Order__c, Purchase_Order__c ' +
               'FROM WMS_Products__c ' +
               'WHERE Sales_Order__c = null AND Purchase_Order__c != null AND (Serial_Number__c LIKE \'%' + String.escapeSingleQuotes(keywords[0]) + '%\'';

            for (Integer i = 1; i < keywords.size(); i++) {
                query += ' OR Serial_Number__c LIKE \'%' + String.escapeSingleQuotes(keywords[i]) + '%\'';
            }
            
            query += ')'; 
            
            String result = null;
            
            List<WMS_Products__c> productsList = Database.query(query);
            System.debug(productsList);
            
            if (productsList.size() > 0) {
                result = 'Already Existed Serial Numbers ';
                for (WMS_Products__c wp : productsList) {
                    result += ' ' + wp.Serial_Number__c;
                }
            }
            
            return result;
    
    }
    
       public static String validateSalesOrderNumbers(List<String> keywords)
    {
        String query = 'SELECT Id, Name, Serial_Number__c, Sales_Order__c, Purchase_Order__c ' +
               'FROM WMS_Products__c ' +
               'WHERE Sales_Order__c != null AND Purchase_Order__c = null AND (Serial_Number__c LIKE \'%' + String.escapeSingleQuotes(keywords[0]) + '%\'';

            for (Integer i = 1; i < keywords.size(); i++) {
                query += ' OR Serial_Number__c LIKE \'%' + String.escapeSingleQuotes(keywords[i]) + '%\'';
            }
            
            query += ')'; 
            
            String result = null;
            
            List<WMS_Products__c> productsList = Database.query(query);
            System.debug(productsList);
            
            if (productsList.size() > 0) {
                result = 'Already Existed Serial Numbers ';
                for (WMS_Products__c wp : productsList) {
                    result += ' ' + wp.Serial_Number__c;
                }
            }
            
            return result;
    }
}