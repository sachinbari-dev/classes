public class SecureBagPDFcontroller {

    public Shipment__c shipment { get; set; }
    public List<Secure_Bag__c> secureBags { get; set; }

    public SecureBagPDFcontroller(ApexPages.StandardController controller) {
        
        string shipId = ApexPages.currentPage().getParameters().get('id');
        this.shipment = (Shipment__c) controller.getRecord();
       
        this.secureBags = [ SELECT Name,Secure_Packaging_Identifier__c,Consignee_Account__c,shipment__r.Number_of_Packages__c, Shipping_Note_Number__c,Current_Origin_City__c,Shipment_Origin__c, Current_Destination_City__c,Destination_City__c,
                            Shipment_destination__c,Next_Destination__c,Destination_Hub__c,Bag_Gross_Weight__c,BVC_Gross_Weight_Manual_in_Grams__c,Volumetric_Weight__c,Weight__c,
                            Secure_Bag__c,Secure_Bag__r.name,Secure_Bag__r.id,Secure_Bag__r.Barcode__c,Secure_Bag__r.barcodeurl__c
                            FROM Secure_Bag__c
                            WHERE Shipment__c = :shipment.Id
                            ORDER BY Name ASC
                        ];
    }
    
}