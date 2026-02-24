/*Class      : ShipmentApprovalController
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : Nov 2024
 */
public with sharing class ShipmentApprovalController {
    @AuraEnabled(cacheable=true)
    public static List<Shipment__c> getPendingShipments() {
        List<Shipment__c> shipments = [
            SELECT Id, Transport_Type__c, Extra_Charges_Amount__c, Origin_Address_City__c, Destination_Address_City__c, Shipping_Note_Number__c, Extra_Charge__c, Customer__r.Name, Customer__c
            FROM Shipment__c
            WHERE Extra_Charges_Amount__c = Null AND Extra_Charge__c != Null AND CreatedDate = LAST_N_DAYS :7
        ];
        System.debug('Retrieved Shipments: ' + shipments);  
        return shipments;
    }

    @AuraEnabled
    public static void submitForApproval(List<Id> shipmentIds) {
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();

        for (Id shipmentId : shipmentIds) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(shipmentId);
            approvalRequests.add(req);
        }

        if (!approvalRequests.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(approvalRequests);
            for (Approval.ProcessResult result : results) {
                if (!result.isSuccess()) {
                    throw new AuraHandledException('Failed to submit for approval: ' + result.getErrors().get(0).getMessage());
                }
            }
        }
    }
@AuraEnabled
public static void approveShipments(List<Id> shipmentIds) {
    List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();
    List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();

    for (Id shipmentId : shipmentIds) {
        List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :shipmentId];
        for (ProcessInstanceWorkitem workItem : workItems) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Approve');
            req.setWorkitemId(workItem.Id);
            approvalRequests.add(req);
        }
    }

    if (!approvalRequests.isEmpty()) {
        Approval.ProcessResult[] results = Approval.process(approvalRequests);
        for (Approval.ProcessResult result : results) {
            if (!result.isSuccess()) {
                throw new AuraHandledException('Failed to approve: ' + result.getErrors().get(0).getMessage());
            } else {
                // Find the TargetObjectId from the ProcessResult and update the corresponding Shipment__c record
                Id approvedRecordId = result.getInstanceId();
                ProcessInstance instance = [SELECT TargetObjectId FROM ProcessInstance WHERE Id = :approvedRecordId];
                shipmentsToUpdate.add(new Shipment__c(Id = instance.TargetObjectId, Approval_Pending__c = false));
            }
        }
    }

    if (!shipmentsToUpdate.isEmpty()) {
        update shipmentsToUpdate;
    }
}

    @AuraEnabled
    public static void rejectShipments(List<Id> shipmentIds) {
        List<Approval.ProcessWorkitemRequest> rejectionRequests = new List<Approval.ProcessWorkitemRequest>();

        for (Id shipmentId : shipmentIds) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :shipmentId];
            for (ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Reject');
                req.setWorkitemId(workItem.Id);
                rejectionRequests.add(req);
            }
        }

        if (!rejectionRequests.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(rejectionRequests);
            for (Approval.ProcessResult result : results) {
                if (!result.isSuccess()) {
                    throw new AuraHandledException('Failed to reject: ' + result.getErrors().get(0).getMessage());
                }
            }
        }
    }
 @AuraEnabled
public static void updateExtraCharge(Id shipmentId, Decimal extraCharge) {
    try {
        Shipment__c shipment = [SELECT Id, Extra_Charge__c FROM Shipment__c WHERE Id = :shipmentId LIMIT 1];
        shipment.Extra_Charge__c = extraCharge;
        update shipment;
    } catch (QueryException e) {
        throw new AuraHandledException('Shipment not found for the given Id: ' + shipmentId);
    } catch (Exception e) {
        throw new AuraHandledException('An error occurred while updating the shipment: ' + e.getMessage());
    }
}

}