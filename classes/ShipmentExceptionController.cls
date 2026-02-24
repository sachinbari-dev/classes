/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : ShipmentExceptionController
 * Author          : <YourName>
 * Created Date    : Feb 20, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Feb 20, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Feb 20, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class ShipmentExceptionController {

    /* ============================================================
       FETCH SHIPMENT + CHECK EXISTING EXCEPTION
       ============================================================ */
    @AuraEnabled(cacheable=true)
    public static ShipmentWrapper fetchShipmentData(String shippingNoteNumber) {

        if(String.isBlank(shippingNoteNumber)){
            throw new AuraHandledException('Shipping Note Number is required.');
        }

        List<Shipment__c> shipments = [SELECT Id, Name, Shipping_Note_Number__c, Customer__c, Origin__c, Destination__c FROM Shipment__c WHERE Shipping_Note_Number__c = :shippingNoteNumber LIMIT 1];

		if(shipments.isEmpty()){
			throw new AuraHandledException('No Shipment found for this Shipping Note Number.');
		}

		Shipment__c shipment = shipments[0];

		// 🔥 Query bags separately instead of subquery
		List<Secure_Bag__c> bags = [SELECT Id, Name FROM Secure_Bag__c WHERE Shipment__c = :shipment.Id];

        // Check if exception already exists
        //List<Shipment_Exception__c> existingList = [SELECT Id, Status__c FROM Shipment_Exception__c WHERE Shipment__c = :shipment.Id LIMIT 1];

        ShipmentWrapper wrapper = new ShipmentWrapper();
        wrapper.shipment = shipment;
		wrapper.bags = bags;
		/*
        if(!existingList.isEmpty()){
            wrapper.existingException = existingList[0];
        }
		*/
        return wrapper;
    }


    /* ============================================================
       SAVE OR UPDATE SHIPMENT EXCEPTION
       ============================================================ */
    @AuraEnabled
    //public static Id saveException(ShipmentExceptionDTO dto) {

	public static String saveException(ShipmentExceptionDTO dto) {
        if(dto == null){
            throw new AuraHandledException('Invalid data received.');
        }

        if(dto.shipmentId == null){
            throw new AuraHandledException('Shipment Id is required.');
        }

        if(String.isBlank(dto.customerRemarks)){
            throw new AuraHandledException('Customer Visible Remarks is mandatory.');
        }

        // Validate at least one bag has issue
        Boolean hasIssue = false;

        for(BagDTO bag : dto.bags){
            if(bag.issueType != null && bag.issueType != 'No Issue'){
                hasIssue = true;

                // Server validation for seal rules
                if(
                    (bag.issueType == 'Seal Broken' ||
                     bag.issueType == 'Seal Mismatch')
                    && String.isBlank(bag.actualSeal)
                ){
                    throw new AuraHandledException(
                        'Actual Seal No is mandatory for Seal issues.'
                    );
                }
            }
        }

        if(!hasIssue){
            throw new AuraHandledException('At least one bag must have an issue selected.');
        }

        //Shipment_Exception__c parent;

        // UPDATE FLOW
        if(dto.exceptionId != null){

            //parent = [SELECT Id, Status__c FROM Shipment_Exception__c WHERE Id = :dto.exceptionId LIMIT 1];

        } 
        // CREATE FLOW
        else {

            // Enforce one per shipment
            //List<Shipment_Exception__c> existing = [SELECT Id FROM Shipment_Exception__c WHERE Shipment__c = :dto.shipmentId LIMIT 1];
			/*
            if(!existing.isEmpty()){
                parent = existing[0];
            } else {
                parent = new Shipment_Exception__c();
                parent.Shipment__c = dto.shipmentId;

                // Default status behavior
                if(dto.raisedChannel == 'Internal'){
                    parent.Status__c = 'Acknowledged';
                } else {
                    parent.Status__c = 'Reported';
                }
            }*/
        }
		/*
        // Set common fields
        parent.Customer_Visible_Remarks__c = dto.customerRemarks;
        parent.Internal_Remarks__c = dto.internalRemarks;
        parent.Detected_Stage__c = dto.detectedStage;
        parent.Detected_Location__c = dto.detectedLocation;
        parent.Observation_Time__c = dto.observationTime;
        parent.Raised_By_Channel__c = dto.raisedChannel;

        upsert parent;
		*/
        /* ============================================================
           BAG ROW HANDLING (SYNC MODEL)
           Delete old rows & recreate fresh
           ============================================================ */

        //List<Shipment_Exception_Bag_Detail__c> oldRows = [SELECT Id FROM Shipment_Exception_Bag_Detail__c WHERE Shipment_Exception__c = :parent.Id];
		/*
        if(!oldRows.isEmpty()){
            delete oldRows;
        }

        List<Shipment_Exception_Bag_Detail__c> newRows =
            new List<Shipment_Exception_Bag_Detail__c>();

        for(BagDTO bag : dto.bags){

            if(bag.issueType != null && bag.issueType != 'No Issue'){

                Shipment_Exception_Bag_Detail__c row =
                    new Shipment_Exception_Bag_Detail__c();

                row.Shipment_Exception__c = parent.Id;
                row.Secure_Bag__c = bag.bagId;
                row.Expected_Seal_No__c = bag.expectedSeal;
                row.Actual_Seal_No__c = bag.actualSeal;
                row.Issue_Type__c = bag.issueType;
                row.Bag_Remarks__c = bag.remarks;

                newRows.add(row);
            }
        }

        if(!newRows.isEmpty()){
            insert newRows;
        }

        return parent.Id;
		*/
		return 'SUCCESS';
    }


    /* ============================================================
       WRAPPER CLASSES
       ============================================================ */

    public class ShipmentWrapper {
        @AuraEnabled public Shipment__c shipment;
		@AuraEnabled public List<Secure_Bag__c> bags;
        //@AuraEnabled public Shipment_Exception__c existingException;
    }

    public class ShipmentExceptionDTO {
        @AuraEnabled public Id exceptionId;
        @AuraEnabled public Id shipmentId;
        @AuraEnabled public String customerRemarks;
        @AuraEnabled public String internalRemarks;
        @AuraEnabled public String detectedStage;
        @AuraEnabled public Id detectedLocation;
        @AuraEnabled public Datetime observationTime;
        @AuraEnabled public String raisedChannel;
        @AuraEnabled public List<BagDTO> bags;
    }

    public class BagDTO {
        @AuraEnabled public Id bagId;
        @AuraEnabled public String expectedSeal;
        @AuraEnabled public String actualSeal;
        @AuraEnabled public String issueType;
        @AuraEnabled public String remarks;
    }
}