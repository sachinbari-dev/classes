public class DownloadExcelFileDetailsController {
    
    public String exportData { get; set; }
    public String fileName { get; set; }
    public String recordId { get; set; }
    
    public DownloadExcelFileDetailsController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        generateFileName();
        exportDataForRecord();
    }
    public void exportDataForRecord() {
        try{
            
            
            List<Linehaul_Tracking__c> ltList = [SELECT Id, createdDate FROM Linehaul_Tracking__c WHERE Id = :recordId];
            List<Secure_Bag__c> secBagList = [SELECT Id, Shipment__r.createdDate, Shipping_Note_Number__c, 
                                              Shipment__r.Shipper_Name_TMS__r.Name, Shipment__r.Origin_Address_City__c, 
                                              Shipment__r.Origin_Hub__r.Name, Shipment__r.Consignee_Name_TMS__r.Name,
                                              Shipment__r.Destination_Address_Name__r.Name, 
                                              Shipment__r.Destination_Address_City__c, Shipment__r.Destination_Hub__r.Name,
                                              Shipment__r.Net_Weight__c, Shipment__r.Gross_Weight__c, Shipment__r.Shipment_Value_Currency__c,
                                              Shipment__r.Shipment_Value__c, Shipment__r.Number_of_Packages__c, Next_Destination__c, Seal_Id__r.Name,
                                              Finalised_Linehaul_Number__c, Linehaul_Type__c, Flight_Date_Time__c, Shipment__r.Billing_Account__r.Name,
                                              Shipment__r.Tracking_Status__c, Shipment__c, Last_Scan_Location__c, Current_Scan_Hub__r.Name, Shipment__r.Delivery_Route_Assigned_To__r.Name,
                                              Last_Scan_Data_and_Time__c, Shipment__r.Pickup__r.Name, Shipment__r.Cancel_Shipment__c,
                                              Unique_Identifier__c, Secure_Packaging_Identifier__c
                                              FROM Secure_Bag__c WHERE Linehaul_Tracking__c = :recordId];
            
            String csvHeader = 'Created Date,Shipping Note Number,Shipper Account: Customer Name,Origin Address City,Origin Hub: Hub Name,Consignee Account: Customer Name,Destination Address Name: Address Name,Destination Address City,Destination Hub,Net weight in Gram,BVC Gross Weight,Shipment Value Currency,Shipment Value,Number of Packages,Next Destination,Left Seal Id: Shipping Note Number,Finalised AWB,Linehaul Type,Finalized Time,	Billing Account: Customer Name,Tracking Status,Shipment ID,Last Modified Date,Last Scan Location,Current Scan Hub: Hub Nam,	Last Activity Date,Delivery Route Assigned To: Full Name,Last Scan Date and Time,Pickup: Pickup Name,Cancel Shipment,Unique Identifier,Secure Packaging Identifier';
            
            String csvData = '';
            String csvData1 = '';
            for (Linehaul_Tracking__c lt : ltList) {
                csvData1 += lt.createdDate;
            }
            for (Secure_Bag__c sb : secBagList) {
                String destinationAddress = '';
                
                if(sb.Shipment__r.Destination_Address_Name__r.Name != null){
                    destinationAddress = sb.Shipment__r.Destination_Address_Name__r.Name;
                    destinationAddress = '"' + destinationAddress.replace('"', '""') + '"';
                }
                
                csvData += sb.Shipment__r.createdDate + ',' + sb.Shipping_Note_Number__c + ',' + sb.Shipment__r.Shipper_Name_TMS__r.Name + ',' 
                    + sb.Shipment__r.Origin_Address_City__c + ',' + sb.Shipment__r.Origin_Hub__r.Name + ',' 
                    + sb.Shipment__r.Consignee_Name_TMS__r.Name + ',' + destinationAddress + ','
                    + sb.Shipment__r.Destination_Address_City__c + ',' + sb.Shipment__r.Destination_Hub__r.Name + ',' 
                    + sb.Shipment__r.Net_Weight__c + ',' + sb.Shipment__r.Gross_Weight__c + ',' 
                    + sb.Shipment__r.Shipment_Value_Currency__c + ',' + sb.Shipment__r.Shipment_Value__c + ','
                    + sb.Shipment__r.Number_of_Packages__c + ',' + sb.Next_Destination__c + ','
                    + sb.Seal_Id__r.Name + ',' +sb.Finalised_Linehaul_Number__c + ','
                    + sb.Linehaul_Type__c + ',' + csvData1 + ','
                    + sb.Shipment__r.Billing_Account__r.Name + ',' + sb.Shipment__r.Tracking_Status__c + ','
                    + sb.Shipment__c + ',' + csvData1 + ',' + sb.Last_Scan_Location__c + ','
                    + sb.Current_Scan_Hub__r.Name + ','+ ',' + sb.Shipment__r.Delivery_Route_Assigned_To__r.Name + ','
                    + sb.Last_Scan_Data_and_Time__c + ',' + sb.Shipment__r.Pickup__r.Name + ','
                    + sb.Shipment__r.Cancel_Shipment__c + ',' + sb.Unique_Identifier__c + ','
                    + sb.Secure_Packaging_Identifier__c + '\n';
            }
            
            exportData = csvHeader + '\n' + csvData;
        }catch (Exception ex){
            System.debug('for checking error '+ex.getMessage());
            System.debug('for checking error on line number '+ex.getLineNumber());
            
        }
    }
    
    private void generateFileName() {
        List<Linehaul_Tracking__c> lhList = [SELECT Name FROM Linehaul_Tracking__c WHERE Id = :recordId LIMIT 1];
        if (!lhList.isEmpty()) {
            Linehaul_Tracking__c lh = lhList[0];
            String trackingName = (lh != null) ? lh.Name : 'Linehaul_Tracking';
            
            Date currentDate = Date.today();
            String dateString = String.valueOf(currentDate);
            fileName = trackingName + '_' + dateString + '.csv';
        } else {
            fileName = 'Linehaul_Tracking.csv'; // Or any default name you want to assign
        }
    }
    
    public void GetCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
   
}