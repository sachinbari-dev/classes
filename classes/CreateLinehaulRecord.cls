public class CreateLinehaulRecord {

    @future(callout=true)
    public static void createMasterAWBRecord(string LHNumber,string AirLHNumber,string origin,string destination,DateTime fltDate,string airline){
        
        List<Linehaul__c> linehualList = new List<Linehaul__c>();
        
        try{
            
          Linehaul__c l = new Linehaul__c();
           l.AWB_Number__c = LHNumber;
           l.Flt_DateTime__c = fltDate;
           l.Flight_Date__c  = fltDate.date();
           l.Origin__c = origin;
           l.Destination__c = destination;
           l.Select_Airline__c = airline;
           l.Finalized_Linehaul_Number__c = AirLHNumber;
           l.Manual__c = true;
         
            linehualList.add(l);
            
          if(!linehualList.isEmpty()){
                insert linehualList;
            }
            
            
           List<secure_bag__c> bgList = new List<secure_bag__c>();
                List<secure_bag__c> basgList = [select id,master_awb__c from secure_bag__c where Finalised_Linehaul_Number__c =:linehualList[0].AWB_Number__c];
                      system.debug('bagsList@@@@@'+ basgList);
                    for(secure_bag__c s: basgList){
                        if(s.master_awb__c == null  ){
                            s.master_awb__c = l.id;
                            bgList.add(s);
                        }
                    }
                      if(!bgList.isEmpty()){
                          update bgList;  
                      }
            
        }catch(exception e){
             system.debug('error message '+ e);
        }

        
    }
    @future(callout=true)
    public static void createLinehualTracking(Id linehaulId,string AirLHNumber,string destination,string Origin ){
        
           Linehaul__c lh = [SELECT Id, Name,AWB_Number__c,Select_Airline__c, Origin__c,Flt_DateTime__c, Destination__c,Flight_Number__c,Arrival_Time__c,Departure_Time__c,Commodity_Description__c, Flight_Date__c 
                              FROM Linehaul__c 
                              WHERE Id = :linehaulId 
                              LIMIT 1];
        
              List<Linehaul_Tracking__c> LtLIst = new List<Linehaul_Tracking__c>();
        
                              Linehaul_Tracking__c Lt2 = new Linehaul_Tracking__c();
                                     Lt2.AWB_Number__c = lh.AWB_Number__c;
                                     Lt2.Finalized_Linehaul_Number__c = AirLHNumber;
                                     Lt2.Airline__c = lh.Select_Airline__c;
                                     Lt2.Linehaul_Name__c = lh.Id;
                                     lt2.Destination__c = destination;
                                      if(lh.Flt_DateTime__c != null){
                                           lt2.Flight_Date__c = lh.Flt_DateTime__c.date();
                                      }
                                    
                                     lt2.Linehaul_Type__c = 'Air';
                                     lt2.Status__c = 'AWB Finalized';
                                     lt2.Origin__c = Origin;
                                     lt2.Flight_Number__c = lh.Flight_Number__c;
                                     lt2.Estimate_Time_of_Arrival__c = lh.Arrival_Time__c;
                                     lt2.Estimate_Time_of_Departure__c = lh.Departure_Time__c;
                                     lt2.Description__c = lh.Commodity_Description__c;   
                                     LtLIst.add(Lt2);  
    }
    
    public static void updatebags ( List<Linehaul_Tracking__c> LtLIst, List<secure_bag__c> bgList){
        
    }
}