//Created BY : Sanket Pisal
// Date: 14-08-2025
public without sharing class BillingReportHelper {

    public class ShipmentWrapper {
        @AuraEnabled public Shipment__c shipment;
        @AuraEnabled public Boolean hasFile;
        @AuraEnabled public String customerName;
         @AuraEnabled public String originHub;
        
    }

    public class PaginatedResult {
        @AuraEnabled public List<ShipmentWrapper> records;
        @AuraEnabled public Integer totalCount;
    }

    @AuraEnabled
  public static PaginatedResult getBillingShipments(String searchText, Integer offsetSize, Integer pageSize) {
    PaginatedResult result = new PaginatedResult();

    // Base filter that is always applied
    String whereClause = 
        ' WHERE Tracking_Status__c IN (\'Created\', \'Picked Up\', \'Origin Hub\', \'Transit Hub\', \'Linehaul Finalised\') ' +
        'AND (CreatedDate = Today OR CreatedDate = Yesterday) ' +
        'AND Cancel_Shipment__c = false ' +
        'AND (Shipment_Value_Mismatched__c = true OR Excess_Gross_Weight__c = true OR Threshold_Exceeded__c = true OR Billing_Shipping_Account_Mismatch__c = true) ' +
        'AND IsExhibition__c = false ' +
        'AND RecordTypeId != \'0125g000002BJMGAA4\''+
        'AND Verified_for_Billing__c = false';

    // Add search filter if provided
    if (String.isNotBlank(searchText)) {
        whereClause += 
            ' AND (Shipping_Note_Number__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
            'OR Customer__r.Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\')';
    }

    // 1. Get total count
    result.totalCount = Database.countQuery('SELECT COUNT() FROM Shipment__c' + whereClause);

    // 2. Get paginated records
    List<Shipment__c> shipments = Database.query(
        'SELECT Id, Shipping_Note_Number__c, Shipment_Date__c, Gross_Weight__c, Net_Weight__c, ' +
        'Excess_Gross_Weight__c, Threshold_Exceeded__c, Shipment_Value_Mismatched__c,Origin_Hub__r.Name, ' +
        'Billing_Shipping_Account_Mismatch__c,Total_Invoice_Value__c, Shipment_Value__c, Verified_for_Billing__c, ' +
        'Customer__r.Name ' +
        'FROM Shipment__c ' + whereClause +
        ' ORDER BY Shipment_Date__c DESC ' +
        'LIMIT :pageSize OFFSET :offsetSize'
    );

    // 3. Wrap data
    result.records = new List<ShipmentWrapper>();
    for (Shipment__c s : shipments) {
        ShipmentWrapper wrap = new ShipmentWrapper();
        wrap.shipment = s;
        wrap.hasFile = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :s.Id LIMIT 1
        ].size() > 0;
        wrap.customerName = s.Customer__r != null ? s.Customer__r.Name : '';
         wrap.originHub = s.Origin_Hub__r != null ? s.Origin_Hub__r.Name : '';
        result.records.add(wrap);
    }

    return result;
}

    @AuraEnabled
    public static void updateShipmentFields(List<Shipment__c> shipmentUpdates) {
        List<Shipment__c> toUpdate = new List<Shipment__c>();
        for (Shipment__c s : shipmentUpdates) {
            toUpdate.add(new Shipment__c(
                Id = s.Id,
                Gross_Weight__c = s.Gross_Weight__c,
                Verified_for_Billing__c = s.Verified_for_Billing__c,
                Shipment_Value__c = s.Shipment_Value__c,
                Total_Invoice_Value__c = s.Total_Invoice_Value__c
            ));
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}