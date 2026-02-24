/**
* @File Name : BarcodeGeneratorController.cls
* @Description :
* @Author : Imran
* @Last Modified By :
* @Last Modified On : November 14, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 14, 2025 |   | Initial Version
**/

public class BarcodeGeneratorController {
	@AuraEnabled
	public static String getRecordDetails(String recordId,String objectApiName){
		String recordName;
		String query='SELECT Id,Name';
		if(objectApiName=='Shipment__c')
		{
			query += ',Shipping_Note_Number__c   FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
		}
		else
		{
			query += ' FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
		}
		
		try {
            // Use Database.query for dynamic SOQL
            List<sObject> records = Database.query(query);

            if (!records.isEmpty()) {
                // Access the 'Name' field generically
                recordName = String.valueOf(records[0].get('Shipping_Note_Number__c'));
            }
        } catch (DmlException e) {
            // Handle any potential exceptions (e.g., if the object doesn't have a 'Name' field, 
            // or the user lacks permissions)
            System.debug('Error querying for record name: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving record name: ' + e.getMessage());
        }
		return recordName;
	}
}