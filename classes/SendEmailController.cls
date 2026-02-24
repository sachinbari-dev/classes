/*Class      : SendEmailController
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : Aug 2023
 */
public with sharing class SendEmailController {

    @InvocableMethod(label='Send Shipment PDFs via Email')
    public static void sendShipmentPDFs(List<EmailInputWrapper> emailInputList) {
        List<Id> pickupIds = new List<Id>();
        
        for (EmailInputWrapper input : emailInputList) {
            pickupIds.add(input.pickupId);
        }
        
        List<Pickup__c> pickupsWithShipments = [SELECT Id,Primary_Customer_Email__c,Shipper_Email__c,
                                                (SELECT Id,DSN__c, Shipment_Created_Through__c FROM Shipments__r ) 
                                                FROM Pickup__c
                                                WHERE Id IN :pickupIds];
        
        List<List<String>> argsList = new List<List<String>>();
        for (Pickup__c pickup : pickupsWithShipments) {
            for (Shipment__c shipment : pickup.Shipments__r) {
                if (shipment.DSN__c == true && 
                    !('Universe API'.equals(shipment.Shipment_Created_Through__c) || 
                      'Universe'.equals(shipment.Shipment_Created_Through__c) || 
                      'Universe Bulk Upload'.equals(shipment.Shipment_Created_Through__c))) {
                    List<String> args = new List<String>();
                    args.add(pickup.Shipper_Email__c);
                    args.add(shipment.Id);
                    argsList.add(args);
                }
            }
        }
        
        SendShipmentPDFViaEmail.sendPDF(argsList);
    }
    
    public class EmailInputWrapper {
        @InvocableVariable(required=true)
        public Id pickupId;
    }
}