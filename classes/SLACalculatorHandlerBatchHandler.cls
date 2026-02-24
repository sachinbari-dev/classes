/*
 * @Created By :Imran
 * @CreatedDate: Sep 26 - 2025
 * @Last Modified By :Imran
 * @Last Midified Date : 28 - 10-2025
 * Changes :
 * 	V1 : Calling Batch class from Pickup Trigger TMS_PickupTrigger, previously called from Shipment Tigger
 *  V2 : Removed Trigger Loop stop Logic
 * 
 */
public class SLACalculatorHandlerBatchHandler 
{
    public static void callbatchHelper(List<String> pickupIdList)
    {
        List<Shipment__c> AllShipmentLst = [SELECT Id, Name, Origin_Hub__r.Name, Destination_Hub__r.Name, Shipping_Note_Number__c, Origin_Address_City__c,
                                            Pickup__r.Physical_Pickup_Completed_Time__c,Pickup__r.Pickup_Status__c,Estimated_Delivery_Date__c,SLA_Days_and_Hours__c,
                                            Physical_Pickup_Completed_Time1__c, Pickup__c, Origin_Address_Name__r.Active_Pincode__c, Origin_Address_Name__r.Active_Pincode__r.Name,
                                            Destination_Address_City__c, Destination_Address_Name__r.Active_Pincode__c,Destination_Address_Name__r.Active_Pincode__r.Name, 
                                            Destination_Address_Pincode__c, Origin_Address_Pincode__c, Destination_Address_Name__r.Active_Pincode__r.City__c,Tracking_Status__c,
                                            Destination_Address_Name__r.Active_Pincode__r.Sunday__c, Destination_Address_Name__r.Active_Pincode__r.Monday__c, 
                                            Destination_Address_Name__r.Active_Pincode__r.Tuesday__c, Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                                            Origin_Address_Name__r.STATE__c,Destination_Address_Name__r.STATE__c,holiday_sunday_charges1__c,Origin_Address_State__c,
                                            Destination_Address_Name__r.Active_Pincode__r.Thursday__c, Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                                            Destination_Address_Name__r.Active_Pincode__r.Saturday__c, Destination_Hub__r.Branch__c, Origin_Hub__r.Branch__c,Destination_Address_State__c
                                            FROM Shipment__c  WHERE  Pickup__c IN : pickupIdList]; 
        
        if(AllShipmentLst.size()>0)
        {
            try
            {
                //SLACalculatorHandlerBatch batch = new SLACalculatorHandlerBatch(AllShipmentLst);	// added by Imran on Sep 26 - 2025
                SLACalculatorBatch1 batch = new SLACalculatorBatch1(AllShipmentLst);				// added by Rafi after optimization on 08-12-2025
                Database.executeBatch(batch, 50); 
                
            }catch(Exception e) {   
                Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandlerBatchHandler',Error__c=e.getMessage());   
                insert AEL;                                
            }         
        }             
    }
}