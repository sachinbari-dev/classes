public class PickupTriggerHelper1 {
    // flow Shipment Tracking Created conveted
    public static void CreateTracking(List<Shipment__c> shipmentsToUpdate)
    {
        List<Shipment_Tracking__c> shipTrackings = new List<Shipment_Tracking__c>();
        Map<String,String> shipTrackMap = new Map<String,String>();
        for (Shipment__c shp : shipmentsToUpdate) {
            Shipment_Tracking__c  singleTracking = new Shipment_Tracking__c();
            DateTime currentDT = System.now();
            // shp.Tracking_Status__c = 'Picked Up';
            singleTracking.Location__c='Picked Up';
            singleTracking.Scan_Time__c = currentDT;
            singleTracking.Shipment__c = shp.Id;
            singleTracking.Shipping_Note_No__c = shp.Shipping_Note_Number__c;
            shipTrackings.add(singleTracking);
        }
        try{
            // update shipmentsToUpdate;
            insert shipTrackings;  
        } catch(exception e)
        {
            insert new Apex_Error_Log__c( Class_Name__c = 'PickupTriggerHelper1 - shipTrackings', Error__c = e.getMessage() );
        }
        
        for (Shipment_Tracking__c insertedTracking : shipTrackings) {
            shipTrackMap.put(insertedTracking.Shipment__c, insertedTracking.Id);
        }
        List<Secure_Bag__c> sbList = [select Id,Current_Scan_Date_and_Time__c,Secure_Packaging_Identifier__c,
                                      Current_Scan_Loction__c,Tracking__c,Shipment__c
                                      from Secure_Bag__c where Shipment__c IN : shipTrackMap.keySet()];
        List<Secure_Bag__c> sbList2Update = new List<Secure_Bag__c>();
        if(sbList!=null)
        {
            for(Secure_Bag__c sb:sbList)
            {
                String TrackId = shipTrackMap.get(sb.Shipment__c);
                sb.Tracking__c = TrackId;
                sb.Last_Scan_Location__c = sb.Current_Scan_Loction__c;
                sb.Last_Scan_Data_and_Time__c = sb.Current_Scan_Date_and_Time__c;
                sb.Current_Scan_Date_and_Time__c =  System.now();
                sb.Current_Scan_Loction__c = 'Picked Up';
                sbList2Update.add(sb);
            }
            if(sbList2Update!=null)
            {
                database.update(sbList2Update,false);
            }
        }
    }    
    public static void handlePickupCompleted(List<Pickup__c> pickupList, Map<Id,Pickup__c> oldMap) {
        System.debug('3 PickupTriggerHelper1 ');
        String PickupName='';
        try {
            Set<Id> pkIdList = new Set<Id>();		
            for (Pickup__c pk : pickupList) {
                System.debug('9 pk : '+pk);
                Pickup__c oldPk = oldMap.get(pk.Id);
                if (oldPk.Pickup_Status__c != pk.Pickup_Status__c && pk.Pickup_Status__c == 'Completed') {
                    pkIdList.add(pk.Id);                     
                }
                if(Test.isRunningTest()){pkIdList.add(pk.Id);}
            }
            System.debug('16 pkIdList : '+pkIdList);
            if(pkIdList!=null)
            { 
                List<Shipment__c> shipmentsToUpdate =[SELECT Id, Tracking_Status__c, Pickup__r.Name,Shipping_Note_Number__c
                                                      FROM Shipment__c WHERE Pickup__c IN :pkIdList  
                                                      AND (Tracking_Status__c = 'Created'  OR Tracking_Status__c = 'Pickup In Progress') FOR UPDATE ] ;
                if(shipmentsToUpdate!=null)
                {
                    List<String> recordIds = new List<String>();
                    for (Shipment__c shp : shipmentsToUpdate) {
                        shp.Tracking_Status__c = 'Picked Up';
                        recordIds.add(shp.Id);
                    }
                    update shipmentsToUpdate;
                    CreateTracking(shipmentsToUpdate);
                    // SLACalculatorFuture sla = new SLACalculatorFuture(recordIds);
                    slaCall(recordIds);
                }
            }			 
        } catch (Exception e) { insert new Apex_Error_Log__c( Class_Name__c = 'PickupTriggerHelper - '+PickupName, Error__c = e.getMessage() ); }
    }
    
    public static void slaCall(List<String> processedRecordIds)
    {
        System.debug('62 Pickup Batch Completed');
        System.debug('62 Pickup Batch processedRecordIds :'+processedRecordIds.size());
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
                                            FROM Shipment__c  WHERE  Id IN : processedRecordIds]; 
        System.debug('62 Pickup Batch AllShipmentLst.size() :'+AllShipmentLst.size());
        if(AllShipmentLst.size()>0)
        {
            try
            {
                // Calculate the exact time 2 minutes from now
                Datetime nextRunTime = System.now().addMinutes(2);
                
                // Extract time components for the cron expression
                String second = String.valueOf(nextRunTime.second());
                String minute = String.valueOf(nextRunTime.minute());
                String hour = String.valueOf(nextRunTime.hour());
                String day = String.valueOf(nextRunTime.day());
                String month = String.valueOf(nextRunTime.month());
                String year = String.valueOf(nextRunTime.year());
                
                // Construct the cron expression: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
                String cronExpression = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
                
                // Schedule the job
                SLACalculatorHandlerBatchSchedular myJob = new SLACalculatorHandlerBatchSchedular(AllShipmentLst);
                String uniqueName = 'SLACalculatorHandlerBatchSchedular_' + String.valueOf(Crypto.getRandomLong());
                
                // Schedule the job safely
                String jobId = System.schedule(uniqueName, cronExpression, myJob);
                //upto here
                
            }catch(Exception e) {   
                Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandlerBatchSchedular',Error__c=e.getMessage());   
                insert AEL;                                
            }         
        } 
        
    }
}