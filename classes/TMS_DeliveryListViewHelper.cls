public class TMS_DeliveryListViewHelper 
{
    public static void CreateDeliveryStop(List<Delivery__c> delList2Create)
    {
        System.debug('55555555555555 TMS_DeliveryListViewHelper');
        List<String> recordIds = new List<String>();
        for(Delivery__c d:delList2Create)
        {
            recordIds.add(d.Id);
        }
        processRecords(recordIds);
    }
	@future
    public static void processRecords(List<String> recordIds)
    {   
        System.debug('1666666 recordIds :'+recordIds);
		List<Delivery__c> dList = [select Id,Reciever_Name__c,Consignee_Account__c,Address__c,
                                   Delivery_Address_Stop__c 
                                   from Delivery__c where Id In : recordIds];
        System.debug('2000000 dList :'+dList);
        Map<String,List<Delivery__c>> DeliveryMap = new Map<String,List<Delivery__c>>();
        for(Delivery__c d: dList)
        {
            System.debug('244444 d :'+d);
            String damKey = d.Consignee_Account__c+'-'+d.Address__c;
            System.debug('25555 damKey :'+damKey);
            if(DeliveryMap.containsKey(damKey))
            {
               // List<Delivery__c> existingdList = DeliveryMap.get(damKey);
               // existingdList.add(d);   
                DeliveryMap.get(damKey).add(d);
            }
            else
            {
                List<Delivery__c> newDList = new List<Delivery__c>();
                newDList.add(d);
                DeliveryMap.put(damKey,newDList); 
            }              
            System.debug('28888 DeliveryMap :'+DeliveryMap);
        }
        System.debug('24 DeliveryMap :'+DeliveryMap);
        List<Delivery_Address_Stop__c> dasList = [select Id,Unique_Name1__c from  Delivery_Address_Stop__c 
                                                  where Unique_Name1__c IN : DeliveryMap.keySet()  and All_Deliveries_Closed__c=:false];
        System.debug('27 dasList :'+dasList);
        Map<String,String> dasMap = new Map<String,String>();
        List<Delivery__c> delList2Update = new List<Delivery__c>();
        List<Delivery_Address_Stop__c> das2Create = new List<Delivery_Address_Stop__c>();
        List<String> newdasKeys = new List<String>();
        if(dasList!=null){
            for(Delivery_Address_Stop__c das: dasList)
            {
                dasMap.put(das.Unique_Name1__c,das.Id);
            }
            
        for(String key:DeliveryMap.keySet())
        {
           // Delivery__c d = DeliveryMap.get(key);
            List<Delivery__c> existingdList = DeliveryMap.get(key);
            System.debug('41 existingdList :'+existingdList);
            System.debug('42 key :'+key);
            if(dasMap.containsKey(key))
            {                
                String k = dasMap.get(key);
                for(Delivery__c d : existingdList)
                {
                    d.Delivery_Address_Stop__c = k;
                    delList2Update.add(d);
                }
               // d.Delivery_Address_Stop__c = k;
               // delList2Update.add(d);
                
                System.debug('48:');
            }
            else
            {
                System.debug('52:');
                Delivery_Address_Stop__c das = new Delivery_Address_Stop__c();
                das.Contact_Name__c = existingdList[0].Reciever_Name__c;
                das.Customer_Name__c = existingdList[0].Consignee_Account__c;
                das.Address_Name__c = existingdList[0].Address__c;
                das.Unique_Name1__c = key;
                das2Create.add(das); 
                newdasKeys.add(key);
                System.debug('60:');
            }
        }
            insert das2Create;
        }
		System.debug('65 newdasKeys:'+newdasKeys);        
        if(newdasKeys!=null)
        {                
            List<Delivery_Address_Stop__c> dasNewList = [select Id,Unique_Name1__c from Delivery_Address_Stop__c 
                                                         where Unique_Name1__c IN : newdasKeys and All_Deliveries_Closed__c=:false];
            System.debug('70 dasNewList:'+dasNewList);  
            for(Delivery_Address_Stop__c dass : dasNewList)
            {
               // Delivery__c d = DeliveryMap.get(dass.Unique_Name1__c);
                List<Delivery__c> existingdList = DeliveryMap.get(dass.Unique_Name1__c);
                for(Delivery__c d : existingdList)
                {
                    System.debug('74 d:'+d);
                    d.Delivery_Address_Stop__c = dass.Id;
                    delList2Update.add(d);  
                }                
            }                
        }
        System.debug('79:'+delList2Update);
          update delList2Update;
        System.debug('81:'+delList2Update);
    }
}