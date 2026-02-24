@isTest
private class SendShipmentPDFViaEmailTest {

    @isTest
    static void testSendPDF() {
        
         Test.setMock(HttpCalloutMock.class, new sendGridEmailMessageAttachmentsMock()); 
        List<Shipment__c> shipments = new List<Shipment__c>();
        for (Integer i = 0; i < 2; i++) {
            shipments.add(new Shipment__c(Shipping_Note_Number__c = 'SN' + i)); // Using a custom field
        }
        insert shipments;

      
        List<List<String>> argsList = new List<List<String>>();
        argsList.add(new List<String>{'test1@example.com', shipments[0].Id});
        argsList.add(new List<String>{'test2@example.com', shipments[1].Id});

        Test.startTest();
       
        SendShipmentPDFViaEmail.sendPDF(argsList);
        Test.stopTest();

       
   

        
    }
}