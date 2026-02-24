public class ShipmentSlAMapping 
{   
    public static void getShipmentSla(List<Shipment__c> shList)
    {
        System.debug('getShipmentSla');
        if(shList.size()>0)
        {
            List<String> shipIds = new List<String>();
            List<String> OriginCities = new List<String>();
            Map<String,City_To_City_SLA__c> slaMap = new Map<String,City_To_City_SLA__c>();
            
            for(Shipment__c sh : shList)
            {
                if(sh.Origin_Address_City__c!=null &&sh.Origin_Address_City__c!='' && 
                   sh.Destination_Address_City__c!=null && sh.Destination_Address_City__c!='' 
                   && sh.Physical_Pickup_Completed_Time__c!=null)
                {                    
                    OriginCities.add(sh.Origin_Address_City__c);
                    shipIds.add(sh.Id);
                }
            }  
            System.debug('20 shipIds:'+shipIds);
            if(shipIds.size()>0)
            {
                List<Shipment__c> shipListToModify = [select Id,Origin_Hub__c,Origin_Hub__r.Name,Destination_Hub__c,Destination_Hub__r.Name,
                                                      Destination_Hub__r.Hub_Pincode__r.Sunday__c,Destination_Hub__r.Hub_Pincode__r.Monday__c,
                                                      Destination_Hub__r.Hub_Pincode__r.Tuesday__c,Destination_Hub__r.Hub_Pincode__r.Wednesday__c,
                                                      Destination_Hub__r.Hub_Pincode__r.Thursday__c,Destination_Hub__r.Hub_Pincode__r.Friday__c,
                                                      Destination_Hub__r.Hub_Pincode__r.Saturday__c,Destination_Hub__r.Hub_Pincode__c,
                                                      Destination_Address_Name__r.Active_Pincode__r.Sunday__c,Destination_Address_Name__r.Active_Pincode__r.Monday__c,
                                                      Destination_Address_Name__r.Active_Pincode__r.Tuesday__c,Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                                                      Destination_Address_Name__r.Active_Pincode__r.Thursday__c,Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                                                      Destination_Address_Name__r.Active_Pincode__r.Saturday__c,Physical_Pickup_Completed_Time__c,
                                                      
                                                      SLA_in_days__c,Destination_Address_City__c,Origin_Address_City__c
                                                      from Shipment__c where Id IN : shipIds];
                System.debug('26 OriginCities:'+OriginCities);
                if(OriginCities.size()>0)
                {
                    List<City_To_City_SLA__c> slaList = [select Id,Pickup_City__c,Destination_City__c,
                                                         Pickup_Hub_Name__c,SLA_in_days__c, Destination_Hub_Name__c
                                                         from City_To_City_SLA__c where Pickup_City__c IN : OriginCities
                                                         and SLA_in_days__c!=null];                    
                    System.debug('34 slaList.size():'+slaList.size());
                    System.debug('35 slaList:'+slaList);
                    if(slaList.size()>0)
                    {
                        for(City_To_City_SLA__c sla:slaList)
                        {
                            System.debug('40 Each sla:'+sla); //cityName.toLowerCase()
                            String key =sla.Pickup_City__c.toLowerCase()+'-'+sla.Destination_City__c.toLowerCase();
                            System.debug('40 Each key:'+key);
                            slaMap.put(key,sla);
                        }
                        System.debug('44 slaMap size:'+slaMap.size());
                        System.debug('45 slaMap size:'+slaMap);                        
                        if(shipListToModify.size()>0 && slaList.size()>0)
                        {
                            List<Shipment__c> shipListToUpdate = new List<Shipment__c>();
                            for(Shipment__c shp:shipListToModify) 
                            {
                                String Shipkey =shp.Origin_Address_City__c.toLowerCase()+'-'+shp.Destination_Address_City__c.toLowerCase();
                                System.debug('52 Shipkey:'+Shipkey);
                                
                                List<String> HolidaysList = new List<String>();
                                
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Sunday__c!=true)
                                {HolidaysList.add('Sunday');}
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Monday__c!=true)
                                { HolidaysList.add('Monday'); }                                        
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Tuesday__c!=true)
                                { HolidaysList.add('Tuesday'); }
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Wednesday__c!=true)
                                { HolidaysList.add('Wednesday'); } 
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Thursday__c!=true)
                                { HolidaysList.add('Thursday'); }
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Friday__c!=true)
                                { HolidaysList.add('Friday'); } 
                                if(shp.Destination_Address_Name__r.Active_Pincode__r.Saturday__c!=true)
                                { HolidaysList.add('Saturday'); }                                          
                                
                                
                                City_To_City_SLA__c slaRec = slaMap.get(Shipkey);
                                System.debug('54 slaRec:'+slaRec);
                                if(slaRec!=null)
                                {                                  
                                    DateTime Physical_Pickup_Completed_Time = shp.Physical_Pickup_Completed_Time__c;
                                    Date currentDate = Physical_Pickup_Completed_Time.date();
                                    
                                    // Date currentDate = Date.today();
                                    Integer  slaDays = (Integer) slaRec.SLA_in_days__c;
                                    
                                    Integer calSLADays = slaDays;
                                    System.debug('66 calSLADays :'+calSLADays);
 
                                    System.debug('126 HolidaysList :'+HolidaysList); 
                                    Date newDeliveryDate = currentDate.addDays(calSLADays); 
                                    
                                    Date TodayDate =  Physical_Pickup_Completed_Time.date();
                                    // Date TodayDate = System.today();
                                    newDeliveryDate = TodayDate.addDays(1);
                                    
                                    System.debug('132 newDeliveryDate :'+newDeliveryDate);
                                    Integer calSLADaysTemp = calSLADays;
                                    integer Totalcount =0;
                                    while(calSLADaysTemp>0)
                                    {
                                        DateTime tempDate = newDeliveryDate;
                                        String DeldayName = tempDate.format('EEEEEE');
                                        System.debug('120 tempDate :'+tempDate+' <--> DeldayName :'+DeldayName);
                                        if (HolidaysList.contains(DeldayName))
                                        {
                                            System.debug('141 This Day Found Holiday :'+DeldayName);
                                            newDeliveryDate = newDeliveryDate.addDays(1);
                                            calSLADays+=1;
                                        }
                                        else
                                        {                                            
                                            calSLADaysTemp-=1;
                                            newDeliveryDate = newDeliveryDate.addDays(1);
                                            calSLADays+=1;
                                            System.debug('149 calSLADaysTemp :'+calSLADaysTemp+' Working Day :'+DeldayName);
                                        }  
                                        Totalcount = Totalcount+1;
                                        System.debug('152 NextDay Date :'+newDeliveryDate+' Total calSLADays :'+calSLADays);                                        
                                    }
                                    System.debug('99 newDeliveryDate :'+newDeliveryDate);
                                    
                                    shp.SLA_in_days__c = Totalcount;
                                    shipListToUpdate.add(shp); 
                                    System.debug('59 shipListToUpdate:'+shipListToUpdate);
                                }                                                                    
                            }                            
                            try{
                                update shipListToUpdate;
                                System.debug('60 Updated Successfully');
                            }catch(Exception e)
                            {
                                System.debug('63 Exception found :'+e.getMessage());
                            }
                        }                        
                    }
                    
                }
            }
        }
        
    }
}