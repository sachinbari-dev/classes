/*
 * Trigger      : ShipmentTrackTrigger1
 * Author     : Imran
 * Date       : Jan 2024
 * Version    : 1.0     Making Callout when Tracking is Created
 *                      
 */
trigger ShipmentTrackTrigger1 on Shipment_Tracking__c (before insert,after insert,after update,after delete) 
{
    Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>(); 
   // Map<Id,Hub__c> hubsMap = new Map<Id,Hub__c>();
    //List<String> hubids = new List<String>();
    List<String> shipids = new List<String>();
    if(trigger.isInsert && trigger.isBefore)
    {        
        for(Shipment_Tracking__c st : trigger.new)
        {
            if(st.Shipment__c!=null)
            {
               shipids.add(st.Shipment__c) ;
            }
            /*
            if(st.Hub__c!=null)
            {
             hubids.add(st.Hub__c)   ;
            }
        */
        }
        List<Shipment__c> shipList = [select Id,Shipping_Note_Number__c,Actual_Delivery_Date_and_Time__c,
                                      POD_Link_Url__c
                                      from Shipment__c where Id IN : shipids];
        /*
         // getting the all Hubs related to Trackings
        List<Hub__c> hubList =[select Id,Name from Hub__c where Id IN :hubids];
        for(Hub__c h : hubList)
        {
            hubsMap.put(h.Id,h);
        }
        */
        for(Shipment__c ship:shipList)
        {
            shipMap.put(ship.Id,ship);
        }
        
        for(Shipment_Tracking__c st : trigger.new)
        {
            Shipment__c shp = shipMap.get(st.Shipment__c);  // getting related Shipment with values
            /*
            if(st.Hub__c!=null)
            {
                Hub__c hb = hubsMap.get(st.Hub__c);         
                st.City__c = hb.Name;
            }
            */
            if(st.Location__c=='Picked Up')
            {
               // st.Act_Delivery_Date__c=shp.Actual_Delivery_Date_and_Time__c;
                //st.Est_Delivery_Date__c=shp.Estimated_Delivery_Date__c;
                st.Shipping_Note_No__c = shp.Shipping_Note_Number__c;
            }
            else
            {
               // st.Act_Delivery_Date__c=shp.Actual_Delivery_Date_and_Time__c;
                if(st.Location__c=='Delivered'){
                    st.Act_Delivery_Date__c=Datetime.now();
                    System.debug('<===== DELIVERED TIME :'+Datetime.now());
                }
                //st.Est_Delivery_Date__c=shp.Estimated_Delivery_Date__c;
                //st.POD__c=shp.POD_Link_Url__c; 
                st.Shipping_Note_No__c = shp.Shipping_Note_Number__c;
            }
            
        }
        
        
    }
    List<Shipment_Tracking__c> stList = new List<Shipment_Tracking__c>();   
    if(trigger.isInsert && trigger.isAfter)
    {
        System.debug('After Insert Shipment_Tracking__c');
        //Map<Id,Shipment_Tracking__c> oldrec = trigger.OldMap;
        for(Shipment_Tracking__c st : trigger.new)
        {
            System.debug('After Insert Shipping_Note_No__c :'+st.Shipping_Note_No__c);
            
            if(st.Shipping_Note_No__c!=null)
            {
               // stList.add(st);
            }         
             stList.add(st);
        }       
    } // Location__c
    /*
    if(trigger.isUpdate && trigger.isAfter)
    {
        Map<Id,Shipment_Tracking__c> oldMap = trigger.OldMap;
        for(Shipment_Tracking__c st : trigger.new)
        {
            System.debug('After Update st.Location__c :'+st.Location__c);            
            System.debug('After Update Shipping_Note_No__c :'+st.Shipping_Note_No__c);
            Shipment_Tracking__c oldRec = oldMap.get(st.Id);
            System.debug('After Update oldRec.Location__c :'+oldRec.Location__c);           
            if(oldRec.Shipping_Note_No__c!=st.Shipping_Note_No__c)
            {                
                stList.add(st);
            }           
            // stList.add(st);
        }       
    }
    */
    if(stList.size()>0)
    {
        
       // String jsoncontent = ShipmentTrackingWebHook.jsonContent(stList);
       // ShipmentTrackingWebHook.sendRequest(jsoncontent);
    }     
}