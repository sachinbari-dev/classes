public class PickupTriggerHelperBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Set<Id> processedRecordIds = new Set<Id>();    
    Set<Id> pkIdList = new Set<Id>();
    
    public PickupTriggerHelperBatch(Set<Id> pkIdList) {
        this.pkIdList = pkIdList;
    }    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('11 PickupTriggerHelperBatch :');
        System.debug('12 PickupTriggerHelperBatch pkIdList :'+pkIdList);
       // String query ='Select Id from Account limit 1';
        String query =  'SELECT Id, Tracking_Status__c, Pickup__r.Name FROM Shipment__c  WHERE Pickup__c IN :pkIdList  AND (Tracking_Status__c = \'Created\'  OR Tracking_Status__c = \'Pickup In Progress\')';
        System.debug('22  query :'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Shipment__c> shipmentsToUpdate) {
        System.debug('18 PickupTriggerHelperBatch shipmentsToUpdate :'+shipmentsToUpdate.size());
        String PickupName='';		        
        if (!pkIdList.isEmpty()) {           
            if(shipmentsToUpdate.size()>0)
            {
                for (Shipment__c shp : shipmentsToUpdate) {
                    shp.Tracking_Status__c = 'Picked Up';
                    PickupName = shp.Pickup__r.Name;
                    processedRecordIds.add(shp.Id); 
                }
                
                if (!shipmentsToUpdate.isEmpty()) {
                    try
                    {
                        update shipmentsToUpdate;
                    } catch (Exception e) {
                        insert new Apex_Error_Log__c( Class_Name__c = 'PickupTriggerHelperBatch - '+PickupName, Error__c = e.getMessage() );
                    }
                    
                }               
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) 
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
                Datetime nextRunTime = System.now().addMinutes(3);
                
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
                String jobId = System.schedule('SLACalculatorHandlerBatchSchedular ' + String.valueOf(System.now()), cronExpression, myJob);
                
                
                
            }catch(Exception e) {   
                Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandlerBatchSchedular',Error__c=e.getMessage());   
                insert AEL;                                
            }         
        } 
        
        
    }
}