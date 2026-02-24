public with sharing class SendEmailController1 {
    @InvocableMethod(label='Send Shipment PDFs via Email')
    public static void sendShipmentPDFs(List<String> emailInputList) {
        List<String> pickupIds = new List<String>();
        System.debug('5 emailInputList:'+emailInputList);
        for (String input : emailInputList) {
            pickupIds.add(input);
        }
        System.debug('9 emailInputList:'+emailInputList);
        List<Pickup__c> pickupsWithShipments = [SELECT Id,Primary_Customer_Email__c,Shipper_Email__c,
                                                (SELECT Id,DSN__c, Shipment_Created_Through__c FROM Shipments__r ) 
                                                FROM Pickup__c
                                                WHERE Id IN :pickupIds];
        System.debug('14 pickupsWithShipments:'+pickupsWithShipments);
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
        System.debug('29 argsList:'+argsList);
        SendShipmentPDFViaEmail1.sendPDF(argsList);
    }
    
    @AuraEnabled
    public static Integer sendMailsToStates(List<String> statesList)
    {        
        System.debug('36 States List :'+statesList);
        List<String> pickupIds = new List<String>();
        List<Pickup__c> pickupList = [select Id from Pickup__c where Shipper_Email__c!=null
                                      and Origin_Address_Name__r.Pincode_TMS__r.State_New__c IN : statesList];
        System.debug('40 pickupList Size:'+pickupList.size());
        if(pickupList.size()>0)
        {
            
            for(Pickup__c pk:pickupList)
            {
                pickupIds.add(pk.Id);
            }
             SendEmailController1.sendShipmentPDFs(pickupIds);
        }
        System.debug('50 pickupIds:'+pickupIds);
        return pickupIds.size();
    }
}