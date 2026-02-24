@RestResource(urlMapping='/CustomerDocuments/*')
global with sharing class ShipmentRestService {
   
    global class CreateShipmentResponse {         
        String Status {get;set;}
        String ErrorDetails {get;set;}
        String Message {get;set;}
        String RecordId {get;set;}
        String URL {get;set;}  
    } 

    global class ShipmentRequest {
        public String CustomerDocumentId;   // <-- new field
        public String Shipment;      
        public Decimal TotalNetWeight;        
        public Decimal InvoiceValue;         
        public String Referencenumber;        
        public String Documenttype;        
        public String CustomerDocumentsURL;        
        public String UnitWeight;
        public String CustomerProductCategory;
        public String ProductDescription;
        public String AdharUrl;
        public String PANUrl;
    }
    
    @HttpPost
    global static String CustomerDocumentAPI() {
        try {
            RestRequest request = RestContext.request;
            String requestPayload = request.requestBody.toString(); 
            
            List<ShipmentRequest> shipmentRequests = 
                (List<ShipmentRequest>)JSON.deserialize(requestPayload, List<ShipmentRequest>.class);
           
            List<Customer_Documents__c> recordsToInsert = new List<Customer_Documents__c>();
            List<Customer_Documents__c> recordsToUpdate = new List<Customer_Documents__c>();
            
            for (ShipmentRequest shipmentRequest : shipmentRequests) {
                if (String.isNotBlank(shipmentRequest.CustomerDocumentId)) {
                    // Update existing record
                    Customer_Documents__c existingRecord = new Customer_Documents__c(
                        Id = shipmentRequest.CustomerDocumentId,
                        Unit_Weight__c = shipmentRequest.UnitWeight,
                        Total_Net_Weight__c = shipmentRequest.TotalNetWeight,
                        Invoice_Value__c = shipmentRequest.InvoiceValue,
                        Reference_number__c = shipmentRequest.Referencenumber,
                        Document_type__c = shipmentRequest.Documenttype,
                        Customer_Documents_URL__c = shipmentRequest.CustomerDocumentsURL,
                        Product_Description__c = shipmentRequest.ProductDescription,
                        Customer_Product_Category__c = shipmentRequest.CustomerProductCategory,
                        Aadhar_Url__c = shipmentRequest.AdharUrl,
                        PAN_Url__c = shipmentRequest.PANUrl
                    );
                    recordsToUpdate.add(existingRecord);
                } else {
                    // Create new record
                    Customer_Documents__c newRecord = new Customer_Documents__c(
                        Shipment__c = shipmentRequest.Shipment,
                        Unit_Weight__c = shipmentRequest.UnitWeight,
                        Total_Net_Weight__c = shipmentRequest.TotalNetWeight,
                        Invoice_Value__c = shipmentRequest.InvoiceValue,
                        Reference_number__c = shipmentRequest.Referencenumber,
                        Document_type__c = shipmentRequest.Documenttype,
                        Customer_Documents_URL__c = shipmentRequest.CustomerDocumentsURL,
                        Product_Description__c = shipmentRequest.ProductDescription,
                        Customer_Product_Category__c = shipmentRequest.CustomerProductCategory,
                        Aadhar_Url__c = shipmentRequest.AdharUrl,
                        PAN_Url__c = shipmentRequest.PANUrl
                    );
                    recordsToInsert.add(newRecord);
                }
            }
            
            if (!recordsToInsert.isEmpty()) insert recordsToInsert;
            if (!recordsToUpdate.isEmpty()) update recordsToUpdate;
            
            return 'Customer document records processed successfully.';
        } catch (Exception e) {
            return 'Error creating/updating document records: ' + e.getMessage();
        }
    }
}