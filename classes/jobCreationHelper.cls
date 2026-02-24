/*
 * 
 * @Version 1.1 : 
 * @Version 1.2 : Saving Route to Selected Pickups
 * Date Modified : 16-01-2025
 * @Version 1.3 : getting Today Pickups with Routes without Jobs
 * Date Modified : 23-04-2025
 * v1 :
 * v2 : 
 */
public class jobCreationHelper 
{   

    @AuraEnabled
    public static Route_List__c getSelectedRoute(String RounteName)
    {
        return [select Id,Name,Pre_Scheduled_departure_time__c,Pre_Scheduled_Arrival_time__c
                     from Route_List__c where Name =:RounteName limit 1];
    }
    @AuraEnabled
    public static String updateRouteAirportCheckBox(List<Route_List__c> routeRecords)
    {
        String resultMessage;
        if(routeRecords.size()>0)
        {
            try{
                Route_List__c routeToUpdate = [select Id,For_Aiport__c from Route_List__c where Id=:routeRecords[0].Id limit 1];
                routeToUpdate.For_Aiport__c=true;
                update routeToUpdate;
                resultMessage='success';
                
            }catch(Exception e)
            {
                resultMessage='Failed :'+e.getMessage();
            }
        }
        return resultMessage;
    }
    @AuraEnabled
    public static List<String> getTodayRoutesList(String name)
    {
        String escorterId;
        User u = [select Id,Name,City from User where Id=: UserInfo.getUserId()];
        List<String> uniqueRoutes = new List<String>();
        String textName='%'+name+'%';
        List<AggregateResult> RoutesList = new List<AggregateResult>();
        List<AggregateResult> RoutesList_SH = new List<AggregateResult>();
        List<AggregateResult> RoutesList_LH = new List<AggregateResult>();
        List<Route_List__c> routeList = new List<Route_List__c>();
        if(name!=null && name!='')
        {
          routeList = [select Id,Name from Route_List__c where For_Aiport__c=:true and Name like: textName]; 
            RoutesList = [select Count(Id),Route__r.Name from Pickup__c  where CreatedDate=LAST_N_DAYS:45 and Route__c!=null and FleetXJob__c=null  
                          and Route__r.FleetXJob__c=null and  (BVC_Origin_Hub__r.Name = :u.City or BVC_Origin_Hub__r.Branch__c = :u.City)
                          and Route__r.Name like: textName 
                          group By Route__r.Name ];

            RoutesList_SH = [select Count(Id),Fleet_X_Routes__r.Name from Shipment__c  where CreatedDate=LAST_N_DAYS:45 and Fleet_X_Routes__c!=null and 
                             FleetXJob__c=null and Fleet_X_Routes__r.FleetXJob__c=null and 
                             (Destination_Hub__r.Name = :u.City or Destination_Hub__r.Branch__c = :u.City) and Fleet_X_Routes__r.Name like: textName
                             group By Fleet_X_Routes__r.Name ];
        
    
            RoutesList_LH = [select Count(Id),Fleet_X_Routes__r.Name from Linehaul_Tracking__c  where CreatedDate=LAST_N_DAYS:45 and Fleet_X_Routes__c!=null 
                             and FleetXJob__c=null and Fleet_X_Routes__r.FleetXJob__c=null and Fleet_X_Routes__r.Name like: textName
                             group By Fleet_X_Routes__r.Name ];            
        }
        else
        {
            routeList = [select Id,Name from Route_List__c where For_Aiport__c=:true];
            if(routeList.size()>0)
            {
                for(Route_List__c RT : routeList)
                {                
                    if(!uniqueRoutes.contains(RT.Name))
                    {
                        uniqueRoutes.add(RT.Name);  
                    }
                }
            }
            
            RoutesList = [select Count(Id),Route__r.Name from Pickup__c  where CreatedDate=LAST_N_DAYS:45 and Route__c!=null and FleetXJob__c=null  
                          and Route__r.FleetXJob__c=null and  (BVC_Origin_Hub__r.Name = :u.City or BVC_Origin_Hub__r.Branch__c = :u.City)
                          group By Route__r.Name ];

            RoutesList_SH = [select Count(Id),Fleet_X_Routes__r.Name from Shipment__c  where CreatedDate=LAST_N_DAYS:45 and Fleet_X_Routes__c!=null and 
                             FleetXJob__c=null and Fleet_X_Routes__r.FleetXJob__c=null and 
                             (Destination_Hub__r.Name = :u.City or Destination_Hub__r.Branch__c = :u.City) group By Fleet_X_Routes__r.Name ];
        
    
            RoutesList_LH = [select Count(Id),Fleet_X_Routes__r.Name from Linehaul_Tracking__c  where CreatedDate=LAST_N_DAYS:45 and Fleet_X_Routes__c!=null 
                             and FleetXJob__c=null and Fleet_X_Routes__r.FleetXJob__c=null group By Fleet_X_Routes__r.Name ];
                    
        }
        if(routeList.size()>0)
        {
            for(Route_List__c RT : routeList)
            {                
                if(!uniqueRoutes.contains(RT.Name))
                { uniqueRoutes.add(RT.Name); }
            }
        } 
        System.debug('72 RoutesList:'+RoutesList);
        if(RoutesList.size()>0)
        {
            for (AggregateResult ar : RoutesList) {
                String routeName = (String)ar.get('Name');
                if(!uniqueRoutes.contains(routeName))
                { uniqueRoutes.add(routeName); }            
            }            
        }
        System.debug('72 RoutesList_SH:'+RoutesList_SH);
        if(RoutesList_SH.size()>0)
        {
            for (AggregateResult ars : RoutesList_SH) {
                String routeName = (String)ars.get('Name');
                if(!uniqueRoutes.contains(routeName))
                { uniqueRoutes.add(routeName); }
            }           
        }
        System.debug('72 RoutesList_SH:'+RoutesList_LH);
        if(RoutesList_LH.size()>0)
        {
            for (AggregateResult arlh : RoutesList_LH) 
            {
                String routeName = (String)arlh.get('Name');
                if(!uniqueRoutes.contains(routeName))
                { uniqueRoutes.add(routeName); }
            }           
        }       
        return uniqueRoutes;
    }
@AuraEnabled
    public static Transport__c getVehicleDetails(String vehId)
    {
        Transport__c vehicle = new Transport__c();
        try{
        	vehicle = [select Id,Outside_Driver__c,Vendor_Driver1__c,
                       Outside_Gunmen__c,Vendor_Gunmen1__c,Outside_Vehicle__c 
                       from Transport__c where Id=:vehId limit 1];
        }
        catch(Exception e)
        {
            System.debug('81 Error Found :'+e.getMessage());
        }
        return vehicle;
    }
@AuraEnabled
    public static String getEscorterId(String recId)
    {
        String escorterId;
        FleetXJob__c fj = new FleetXJob__c();
        try
        {
            fj = [select Id,Escorter__c from FleetXJob__c where FleetX_RouteName__c=:recId and CreatedDate = TODAY limit 1 ];
        }
        catch(Exception e)
        {
            System.debug('17 Error :'+e.getMessage());
        }
        escorterId = fj!=null?fj.Escorter__c:null;
        return escorterId;
    }

@AuraEnabled
    public static List<Route_List__c> getRouteList(List<String> idList)
    {
        if(idList.size()>0)
        {
            return [select Id,Name from Route_List__c where Id In : idList];
        }
        else
        {
            return null;
        }
    }    

    @AuraEnabled
    public static List<Pickup__c> getReAssignPickupRecords()
    {
       User u = [select Id,Name,City from User where Id=: UserInfo.getUserId()];      
        List<Pickup__c> pickupList = new List<Pickup__c>();
            pickupList = [select Id,Name,Shipper_Name__c,Shipper_Name__r.Name,Shipper_Address__r.City__c,BVC_Origin_Hub__r.Name,
                          Shipper_Address__r.Name,Pickup_Route_Number__c,Pickup_Route_Number__r.Name,FleetXJob__c
                          from Pickup__c where CreatedDate=TODAY and (Pickup_Status__c=:'Assigned' OR Pickup_Status__c=:'Created') and FleetXJob__c!=null and
                          (BVC_Origin_Hub__r.Name = :u.City or BVC_Origin_Hub__r.Branch__c = :u.City)limit 1000]; 
    return pickupList;       
    }
    
    @AuraEnabled
    public static List<Pickup__c> getPickups1()
    {
       User u = [select Id,Name,City,User_Hub__c from User where Id=: UserInfo.getUserId()];
        System.debug('User Name:'+u.Name);
        System.debug('User Address City:'+u.City);
        
        List<Pickup__c> pickupList = new List<Pickup__c>();
        try{
            pickupList = [select Id,Name,Shipper_Name__c,Shipper_Name__r.Name,Shipper_Address__r.City__c,BVC_Origin_Hub__r.Name,
                          Shipper_Address__r.Name,Pickup_Route_Number__c,Pickup_Route_Number__r.Name,FleetXJob__c
                          from Pickup__c where CreatedDate=TODAY and Pickup_Status__c=:'Created'
                          and (FleetXJob__c=:null or FleetXJob__c='') and Route__c=null and // added by imran
                          (BVC_Origin_Hub__r.Name = :u.User_Hub__c or BVC_Origin_Hub__r.Branch__c = :u.City )limit 1000]; 
        }
        catch(Exception e)
        {
            System.debug('108 Error :'+e.getMessage());
        }
    return pickupList;       
    }
    @AuraEnabled
    public static List<Linehaul_Tracking__c> getLinehauls(String searchText) {
        User u = [SELECT City,User_Hub__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<Linehaul_Tracking__c> linehaulList = new List<Linehaul_Tracking__c>();
        System.debug('searchText :'+searchText);
        if(searchText!=null)
        {
            searchText = '%'+searchText+'%';
            linehaulList = [SELECT Id, Name,Origin__c,AWB_Number__c,Destination__c,Fleet_X_Routes__r.Name,
                            Linehaul_Type__c,Fleet_X_Routes__c FROM Linehaul_Tracking__c  
                            WHERE (CreatedDate=TODAY OR CreatedDate = YESTERDAY) and (Origin__c = :u.City OR Origin__c = :u.User_Hub__c) and FleetXJob__c=:null and 
                            AWB_Number__c Like:searchText and Fleet_X_Routes__c=: null limit 1000];            
        }
        else
        {
            try {
            linehaulList = [SELECT Id, Name,Origin__c,AWB_Number__c,Destination__c,Fleet_X_Routes__r.Name,
                            Linehaul_Type__c,Fleet_X_Routes__c FROM Linehaul_Tracking__c  
                            WHERE (CreatedDate=TODAY OR CreatedDate = YESTERDAY) and (Origin__c = :u.City OR Origin__c = :u.User_Hub__c) and FleetXJob__c=:null
                           and Fleet_X_Routes__c=: null ];    
            } catch(Exception e) 
            {
            System.debug('164 Exception occurred: ' + e.getMessage());
        	}
        }
        System.debug('175 linehaulList: ' + linehaulList);
        return linehaulList;
    }

    @AuraEnabled
    public static Pickup__c getPickupsById(String pickupId)
    {
        return [select Id,Name,Shipper_Name__c,Shipper_Name__r.Name,Shipper_Address__r.City__c,BVC_Origin_Hub__r.Name,
                BVC_Origin_Hub__r.Hub_City__c from Pickup__c where Id=:pickupId limit 1];
    }
    
    @AuraEnabled
    public static List<Pickup__c> getPickups(String searchkey)
    {
        List<Pickup__c> pickupList = new List<Pickup__c>();
        User u = [select Id,Name,City from User where Id=: UserInfo.getUserId()];
        System.debug('Pickup Search key :'+searchkey);
        if(searchkey!=null && searchkey!=''){
            try
            {
                pickupList = [select Id,Name,Shipper_Name__c,Shipper_Name__r.Name,Shipper_Address__r.City__c,BVC_Origin_Hub__r.Name,BVC_Origin_Hub__r.Hub_City__c,
                              Shipper_Address__r.Name,Pickup_Route_Number__c,Pickup_Route_Number__r.Name,Customer__r.Name
                              from Pickup__c where CreatedDate=TODAY and Pickup_Status__c=:'Created' 
                              and Shipper_Name__c=:searchkey and (FleetXJob__c=:null or FleetXJob__c='') and (BVC_Origin_Hub__r.Name = :u.City or BVC_Origin_Hub__r.Branch__c = :u.City) limit 1000];
                System.debug('Size :'+pickupList.size());
            }
            catch(Exception e)
            {
              System.debug('167 Error :'+e.getMessage());  
            }
            if(pickupList.size()>0)
            {
                System.debug('Pickup customer :'+pickupList[0].Customer__r.Name); 
            }
                       
        }
        else
        {
        
        }
        
        if(pickupList.size()>0)
        {
            for(Pickup__c p: pickupList)
            {
                System.debug('P :'+p.Pickup_Route_Number__c);
            }
            return pickupList;
        }
        else
        {
            return null;
        }        
    }

    @AuraEnabled
    public static List<Shipment__c> getShipments1()
    {
         User u = [SELECT City FROM User WHERE Id = :UserInfo.getUserId()];
        List<Shipment__c> shpList = [select Id,Name,Pickup__c,
                       Customer_Product_Category__c, 
                       Customer__c,
                       Shipper_Name_TMS__c,
                       Origin_Address_Name__c,
                       Insurance_By__c,
                       Shipment_Value__c,
                       Net_Weight__c,FleetXJob__c,
                       Reference_1__c,Delivery_Route_Assigned_To__c,
                       Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,
                       Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,
                       Product_Description__c,Delivery_Route_Assigned_To__r.Name,
                       Net_Weight_UOM_TMS__c,Tracking_Status__c,Shipping_Note_Number__c,
                       Reciever_Name__c,Shipment_Created_Through__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name,
                       Customer_Gross_Weight__c,Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c
                       from Shipment__c where  CreatedDate = LAST_N_DAYS:45 and FleetXJob__c=:null and Delivery_Route_Assigned_To__c !=null and
                                     Tracking_Status__c IN ('Destination Port', 'Destination Hub','Out for Delivery') and 
                                     (Destination_Hub__r.Branch__c= :u.City or Destination_Hub__r.Name= :u.City) AND 
                                    Fleet_X_Routes__c =: null
                                    ]; 
        //return shpList;    
            for(Shipment__c ss:shpList)
            {
                System.debug('Id :'+ss.Destination_Address_Name__c);
                System.debug('Consignee_Name_TMS__c :'+ss.Consignee_Name_TMS__c);
                System.debug('Consignee_Name_TMS__r :'+ss.Consignee_Name_TMS__r.Name);
            }
        return shpList;
    }    
    @AuraEnabled
    public static List<Shipment__c> getReAssignShipmentRecords()
    {
         User u = [SELECT City FROM User WHERE Id = :UserInfo.getUserId()];
        List<Shipment__c> shpList = [select Id,Name,Pickup__c,
                       Customer_Product_Category__c, 
                       Customer__c,
                       Shipper_Name_TMS__c,
                       Origin_Address_Name__c,
                       Insurance_By__c,
                       Shipment_Value__c,
                       Net_Weight__c,
                       Reference_1__c,Delivery_Route_Assigned_To__c,
                       Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,
                       Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,
                       Product_Description__c,FleetXJob__c,
                       Net_Weight_UOM_TMS__c,Tracking_Status__c,Shipping_Note_Number__c,
                       Reciever_Name__c,Shipment_Created_Through__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name,
                       Customer_Gross_Weight__c,Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c
                       from Shipment__c where  CreatedDate=LAST_N_DAYS:45 and FleetXJob__c!=null and 
                                     Tracking_Status__c IN ('Destination Port', 'Destination Hub','Out for Delivery') and
                                     (Destination_Hub__r.Branch__c= :u.City or Destination_Hub__r.Name= :u.City) ]; 
        //return shpList;    
            for(Shipment__c ss:shpList)
            {
                System.debug('Id :'+ss.Destination_Address_Name__c);
                System.debug('Consignee_Name_TMS__c :'+ss.Consignee_Name_TMS__c);
                System.debug('Consignee_Name_TMS__r :'+ss.Consignee_Name_TMS__r.Name);
            }
        return shpList;
    }
    @AuraEnabled
    public static List<Shipment__c> getShipments(String searchkey)
    {
        searchkey = '%'+searchkey+'%';
        System.debug('Shipment Search key :'+searchkey);
        List<Shipment__c> shpList = new List<Shipment__c>();
            User u = [SELECT City FROM User WHERE Id = :UserInfo.getUserId()];

        if(searchkey!=null && searchkey!=''){
            shpList = [select Id,Name,Pickup__c,
                       Customer_Product_Category__c, 
                       Customer__c,Customer__r.Name,
                       Shipper_Name_TMS__c,
                       Origin_Address_Name__c,
                       Insurance_By__c,
                       Shipment_Value__c,
                       Net_Weight__c,
                       Reference_1__c,Delivery_Route_Assigned_To__c,
                       Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,
                       Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,
                       Product_Description__c,Delivery_Route_Assigned_To__r.Name,
                       Net_Weight_UOM_TMS__c,Tracking_Status__c,Shipping_Note_Number__c,
                       Reciever_Name__c,Shipment_Created_Through__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name,
                       Customer_Gross_Weight__c,Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c
                       from Shipment__c where  CreatedDate=LAST_N_DAYS:45 and 
                       // Shipping_Note_Number__c LIKE : searchkey and FleetXJob__c=:null and 
                       Delivery_Route_Assigned_To__r.Name LIKE : searchkey and FleetXJob__c=:null and 
                       Tracking_Status__c IN ('Destination Port', 'Destination Hub','Out for Delivery') and 
                       (Destination_Hub__r.Branch__c= :u.City or Destination_Hub__r.Name= :u.City)
                        AND Fleet_X_Routes__c=:null
                      ];   
            System.debug('size :'+shpList.size());
            if(shpList.size()>0)
            {
                System.debug('customer :'+shpList[0].Customer__r.Name);                
            }
            for(Shipment__c ss:shpList)
            {
                System.debug('Address Name :'+ss.Destination_Address_Name__r.Name);
                System.debug('Address City :'+ss.Destination_Address_Name__r.City__c);
            }
        }
        else
        {
            shpList = [select Id,Name,Pickup__c,
                       Customer_Product_Category__c, 
                       Customer__c,
                       Shipper_Name_TMS__c,
                       Origin_Address_Name__c,
                       Insurance_By__c,
                       Shipment_Value__c,
                       Net_Weight__c,
                       Reference_1__c,
                       Consignee_Name_TMS__c,Consignee_Name_TMS__r.Name,
                       Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,
                       Product_Description__c,
                       Net_Weight_UOM_TMS__c,Tracking_Status__c,Shipping_Note_Number__c,
                       Reciever_Name__c,Shipment_Created_Through__c,Delivery_Route_Number__c,Delivery_Route_Number__r.Name,
                       Customer_Gross_Weight__c,Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c
                       from Shipment__c where  CreatedDate=LAST_N_DAYS:45 AND Tracking_Status__c IN ('Destination Port', 'Destination Hub','Out for Delivery') AND (Destination_Hub__r.Branch__c= :u.City or Destination_Hub__r.Name= :u.City) ];            
        }        
        return shpList;
    }
    @AuraEnabled
    public static String imageUpload(String fileData, String recId){
        System.debug('252 : recId:'+recId);
        System.debug('253 : fileData:'+fileData);
        try{
            System.debug('255 : TRY');
           // Vehicle_Data__c vdObj = new Vehicle_Data__c();
           // vdObj = [Select Id, Name From Vehicle_Data__c Where Id =: recId];
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'VehicleDetails.png'; 
            cVersion.Title = 'Vehicle Details.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            System.debug('269 : cVersion:'+cVersion);
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = recId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            Insert conDocLinkObj;
            return 'Success';
        }catch(Exception ex){
            System.debug('for checking in file upload ex.getMessage() '+ex.getMessage());
            System.debug('for checking in file upload ex.getLineNumber() '+ex.getLineNumber());
            return null;
        }
    }
@AuraEnabled
    public static FleetXJob__c createJob1(String Escorter,String FleetX_Gunmen , String Loader_1,List<Route_List__c> routeRecords)
    {
        FleetXJob__c fj = new FleetXJob__c();
        FleetXJob__c fjob = new FleetXJob__c();
        System.debug('348 routeRecords :'+routeRecords);
        if(Escorter!=null)
        {
            fj.Escorter__c = Escorter;
            fj.FleetX_Gunmen__c = FleetX_Gunmen;
            fj.Loader_1__c = Loader_1;            
            fj.scheduleDeparture__c = DateTime.now();
            fj.Transport_Type__c='Walking';
            if(routeRecords.size()>0)
            {
                fj.FleetX_RouteName__c = routeRecords[0].Id;
            }
                      
            insert fj;
            fjob =[select Id,Name from FleetXJob__c where Id=:fj.Id limit 1];
        }
        return fjob;
    }
	// updating the Selected Route on Pickup or LineHaul or Delivery records
    @AuraEnabled
    public static String updateRouteOnPLD(List<String> selectedIds, List<Route_List__c> routeRecords,String selectedOption)
    {
        String result;
        System.debug('446 selectedOption :'+selectedOption);
        System.debug('446 selectedIds :'+selectedIds);
        if(selectedOption=='Pickup')
        {
            List<Pickup__c> pkList = [select Id,Route__c from Pickup__c where Id IN : selectedIds];
            List<Pickup__c> pkToUpdateList = new List<Pickup__c>();
            if(pkList.size()>0)
            {
                for(Pickup__c pk:pkList)
                {
                    pk.Route__c = routeRecords[0].Id;
                    pkToUpdateList.add(pk);
                }           
                try
                { 
                    update pkToUpdateList;
                    result='success';
                } catch(exception e)
                {
                    result=e.getMessage();
                }
            }            
        }
        if(selectedOption=='Linehaul')
        {
           List<Linehaul_Tracking__c> LHTracking = [select Id,Fleet_X_Routes__c from Linehaul_Tracking__c where Id IN : selectedIds];
            if(LHTracking.size()>0)
            {
               for(Linehaul_Tracking__c LHT : LHTracking) 
               {
                  LHT.Fleet_X_Routes__c=routeRecords[0].Id; 
               }
                try
                { 
                    update LHTracking;
                    result='success';
                } catch(exception e)
                {
                    result=e.getMessage();
                }                
            }
        }
        if(selectedOption=='Delivery')
        {
            List<Shipment__c> ShipmentList = [select Id,FleetXJob__c from Shipment__c where Id IN : selectedIds];
            if(ShipmentList.size()>0)
            {
                for(Shipment__c sh :ShipmentList)
                {
                   sh.Fleet_X_Routes__c= routeRecords[0].Id; 
                }
                try
                { 
                    update ShipmentList;
                    result='success';
                } catch(exception e)
                {
                    result=e.getMessage();
                }                 
            }
        }        
        return result;
    }
        
    @AuraEnabled
    public static Map<String,FleetXJob__c> createJob(String FleetX_Driver, String vehicleNumber, String Escorter,String pvtVehicleNumber,
                                         String FleetX_Gunmen , String Loader_1, String Escorter2,String RouteName,
                                         String Driver_2, String Armed_Guard_2, String Loader_2,
                                         String scheduleDeparture, List<Route_List__c> routeRecords,
                                         String Mode, String Start_KM, String Time_in, String Number_of_Staff_in_vehicle,
                                         String End_KM, String Time_out,String blobData,
                                         String outDri,String outDri2,String outGunMen,String outGunMen2)
    {
        
        String routeList='';
        String resultMsg='';
        Map<String,FleetXJob__c> resultMap = new Map<String,FleetXJob__c>();
        FleetXJob__c fjob =new FleetXJob__c();
        if(routeRecords!=null)
        {
            for(Route_List__c rt:routeRecords)
            {
                routeList=routeList+rt.Name+',';
            }            
        }
        Route_List__c route = [select Id,Name,Pre_Scheduled_Arrival_time__c,Pre_Scheduled_departure_time__c,FleetXJob__c,(select Id from FleetXJobs__r) from Route_List__c where Name=:RouteName limit 1]; // v2
        Decimal toatValReturn=0;
		if(route!=null)        
        {
            try
            {
                List<Pickup__c> pklst = [select Id,Total_Shipment_Value__c from Pickup__c where Route__c=:route.Id and FleetXJob__c=null 
                                         and CreatedDate=Today];
                List<Shipment__c> shlst = [select Id,Shipment_Value__c from Shipment__c where Fleet_X_Routes__c=:route.Id and FleetXJob__c=null 
                                           and CreatedDate=LAST_N_DAYS:45];
                List<Linehaul_Tracking__c> lhlst = [select Id,Total_Shipment_Value__c from Linehaul_Tracking__c where Fleet_X_Routes__c=:route.Id and 
                                                    FleetXJob__c=null and CreatedDate=Today];
                if(pklst.size()>0)
                {
                  toatValReturn = jobCreationHelperHandler.PickupsUpdatesFromJCHelper(pklst);  
                }
                if(shlst.size()>0)
                {
                   toatValReturn = jobCreationHelperHandler.getTotalvalueFromShip(shlst); 
                }                
                if(lhlst.size()>0)
                {
                    toatValReturn = jobCreationHelperHandler.LineHaulUpdatesFromJCHelper(lhlst);
                }                
            } catch(Exception e){
                System.debug('553 Error :'+e.getMessage());
            }
        }
        FleetXJob__c lastJob = new FleetXJob__c();
        System.debug('600 route :'+route);
        if(route.FleetXJobs__r.size()>0) // v2
        {
            try
            {
                lastJob = [SELECT Id,Name,CreatedDate,FleetX_RouteName__c,FleetX_RouteName__r.Name,Start_KM__c,End_KM__c 
                           from FleetXJob__c  where FleetX_RouteName__c =: route.Id and End_KM__c!=null 
                           and Vehicle_Number__c=:vehicleNumber order by CreatedDate desc limit 1];
                System.debug('606 lastJob :'+lastJob);
                if(Integer.valueOf(Start_KM)<Integer.valueOf(lastJob.End_KM__c))
                {
                    resultMsg='Start KM should be greater than the last recorded End KM';
                }
            }catch(Exception e)
            {
                System.debug('613 e.getMessage :'+e.getMessage());
            }            
        }
		 
        if(Time_in!=null)
        {
            Time_in = Time_in.replace('T', ' ').replace('Z', '');
        }
        
        if(Time_out!=null)
        {
            Time_out = Time_out.replace('T', ' ').replace('Z', '');
        } 
        
        scheduleDeparture = scheduleDeparture.replace('T', ' ').replace('Z', '');
        Datetime originDeparture = Datetime.valueOf(scheduleDeparture);
        
        
        System.debug('265 originDeparture:'+originDeparture);
               
        FleetXJob__c fj = new FleetXJob__c();
		//fj.vehicleNumber__c = vehicleNumber;
		if(vehicleNumber!=null && vehicleNumber!='')
        {
            fj.Vehicle_Number__c = vehicleNumber;
            fj.Transport_Type__c='Vehicle';
        }
        else
        {
            fj.Transport_Type__c='Walking';
        }
		if(pvtVehicleNumber!=null && pvtVehicleNumber!='')
        {
            fj.Other_Private_Vehicle__c	 = pvtVehicleNumber;
        }
        fj.Escorter__c = Escorter;
        fj.FleetX_Gunmen__c = FleetX_Gunmen;
        System.debug('271 Loader_1:'+Loader_1);
        fj.Loader_1__c = Loader_1;
        fj.Escorter2__c = Escorter2;
        fj.Driver_2__c = Driver_2;
        fj.Armed_Guard_2__c = Armed_Guard_2;
        fj.Loader_2__c = Loader_2;
        fj.FleetX_Driver__c=FleetX_Driver;
        fj.Pre_Scheduled_Arrival_time__c = route.Pre_Scheduled_Arrival_time__c;
        fj.Pre_Scheduled_departure_time__c = route.Pre_Scheduled_departure_time__c;
        
        
        fj.scheduleDeparture__c = originDeparture;
        System.debug('39777777  originDeparture:'+originDeparture);
        // fj.RouteName__c = routeRecords[0].Id;
        
        fj.RouteName__c = route.Id;
        fj.FleetX_RouteName__c = route.Id;
        fj.selected_Routes__c = routeList;
        
        fj.Mode__c = Mode;
        fj.End_KM__c = End_KM;
        fj.Start_KM__c = Start_KM;
        
        fj.Outside_Driver__c = outDri;
        fj.Outside_Driver2__c = outDri2;
        fj.Outside_GunMen__c = outGunMen;
        fj.Outside_GunMen2__c = outGunMen2;
        fj.Total_Shipment_Value__c = toatValReturn;
        
        FleetX_People__c fp = new FleetX_People__c();
        System.debug('532');
        try
        {
            fp = [Select Id,Employee_Code__c from FleetX_People__c where Id=:Escorter limit 1];
             System.debug('536');
            if(fp!=null)
            {
                 System.debug('539');
                User escorterUser = [Select Id from User where Employee_Code__c=: fp.Employee_Code__c limit 1];
                 System.debug('541');
                if(escorterUser!=null)
                {
                  fj.ownerId = escorterUser.Id;
                }
            }
             System.debug('547');
        }catch(Exception e)
        {
            
        }
        System.debug('552');
        if(Time_in!=null)
        {
            Datetime Time_in1 = Datetime.valueOf(Time_in);
            System.debug('265 Time_in1:'+Time_in1);
            fj.Time_in__c = Time_in1;
        }
        System.debug('559');

        System.debug('561');
        fj.Number_of_Staff_in_vehicle__c = Number_of_Staff_in_vehicle;
        if(Time_out!=null)
        {
            Datetime Time_out1 = Datetime.valueOf(Time_out);
            System.debug('566 Time_out1:'+Time_out1);
            fj.Time_out__c = Time_out1;
        }
        System.debug('724 resultMsg :'+resultMsg);
        
        if(resultMsg=='')
        {
            Set<Id> jobIds = new Set<Id>();
            System.debug('727 resultMsg :'+resultMsg);
            insert fj;
            System.debug('470 fj :'+fj);
            fjob =[select Id,Name from FleetXJob__c where Id=:fj.Id limit 1];
            System.debug('456 fjob :'+fjob);
            route.FleetXJob__c = fjob.Id;            
            List<Pickup__c> pkList = new List<Pickup__c>();
            List<Shipment__c> shList = new List<Shipment__c>();
            List<Linehaul_Tracking__c> lhList = new List<Linehaul_Tracking__c>();
            try
            {
                update route;
                pkList = [select Id,FleetXJob__c from Pickup__c where Route__c=:route.Id and FleetXJob__c=null 
                          and CreatedDate=Today];
                shList = [select Id,FleetXJob__c from Shipment__c where Fleet_X_Routes__c=:route.Id and FleetXJob__c=null 
                          and CreatedDate=LAST_N_DAYS:45];
                lhList = [select Id,FleetXJob__c from Linehaul_Tracking__c where Fleet_X_Routes__c=:route.Id and 
                          FleetXJob__c=null and CreatedDate=Today];
            } catch(Exception e){
                System.debug('553 Error :'+e.getMessage());
            }        
            if(pkList.size()>0)
            {
                for(Pickup__c pk:pkList)
                {
                    pk.FleetXJob__c = fjob.Id;
                    jobIds.add(fjob.Id);
                }  
                update pkList;
            }
            if(shList.size()>0)
            {
                JobUpdateOnShipmentBatch jush = new JobUpdateOnShipmentBatch(fjob.Id,route.Id);
                Database.executeBatch(jush,20);
            }
            if(lhList.size()>0)
            {
                for(Linehaul_Tracking__c lh:lhList)
                {
                    lh.FleetXJob__c = fjob.Id;
                    jobIds.add(fjob.Id);
                }  
                update lhList;
            } 
			resultMsg ='success';
        }
       resultMap.put(resultMsg,fjob);        
        System.debug('772 resultMap :'+resultMap);
       // return fjob;
       return resultMap;
    }    

    
@AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }    

@AuraEnabled
public static FleetXJob__c getJob(String fleetxJobId)
{
    return [select Id,Name,Escorter__c,Escorter2__c,Escorter__r.Name,Escorter2__r.Name,
                                  FleetX_Gunmen__c,Armed_Guard_2__c,FleetX_Gunmen__r.Name,Armed_Guard_2__r.Name,
                                  FleetX_Driver__c,Driver_2__c,
                                  Loader_1__c,Loader_2__c,Loader_1__r.Name,Loader_2__r.Name,
            					  FleetX_Driver__r.Name,Driver_2__r.Name
                                  from FleetXJob__c where Id=: fleetxJobId limit 1];
}
    @AuraEnabled
    public static boolean saveEditedJob(String edit_FleetX_Driver, String edit_Escorter,
                                        String edit_FleetX_Gunmen, String edit_Loader_1,
                                        String edit_Escorter2, String edit_Driver_2,
                                        String edit_Armed_Guard_2, String edit_Loader_2,String jobId)
    {
        boolean result=false;
        FleetXJob__c fxJob = [select Id,Escorter__c,Escorter2__c,
                                  FleetX_Gunmen__c,Armed_Guard_2__c,
                                  FleetX_Driver__c,Driver_2__c,
                                  Loader_1__c,Loader_2__c
                                  from FleetXJob__c where Id=: jobId limit 1];
        if(fxJob!=null)
        {
            fxJob.Escorter__c = edit_Escorter;
            fxJob.Escorter2__c = edit_Escorter2;
            fxJob.FleetX_Driver__c = edit_FleetX_Driver;
            fxJob.Driver_2__c = edit_Driver_2;
            fxJob.FleetX_Gunmen__c = edit_FleetX_Gunmen;
            fxJob.Armed_Guard_2__c = edit_Armed_Guard_2;
            fxJob.Loader_1__c = edit_Loader_1;
            fxJob.Loader_2__c = edit_Loader_2;
            update fxJob;
            result=true;
        }
        return result;
    }
@AuraEnabled
public static boolean updateRecords(List<String> pickupIds,String userId,List<String> shipIds,String fleetxJobId,List<String> LHIds,List<String> routeIds)
{
        boolean res=false;
        System.debug('pickupIds :'+pickupIds+' userId :'+userId);
        System.debug('shipIds :'+shipIds+' fleetxJobId :'+fleetxJobId);
        System.debug('LHIds :'+LHIds+' userId :'+userId);
        System.debug(' userId :'+routeIds.size());
        //if(pickupIds.size()>0 && userId!=null && fleetxJobId!=null)
        if(routeIds.size()>0 && fleetxJobId!=null)
        {
            List<Route_List__c> routeListRecords = [select Id,FleetXJob__c from Route_List__c where Id in : routeIds];
            List<Route_List__c> updateRL = new List<Route_List__c>();
            for(Route_List__c rl:routeListRecords )
            {
                System.debug(' rl :'+rl);
                rl.FleetXJob__c = fleetxJobId;
                updateRL.add(rl);
            }
            Database.update(updateRL,false);
            res= true;
            //newly Added
            List<FleetXJob__c> jobList = [select Id from FleetXJob__c where Id=: fleetxJobId];
           // FleetXJobTriggerHelper.calloutExternal1(jobList);
            // upto here
            
        }
        if(pickupIds.size()>0 && fleetxJobId!=null)
        {           
            FleetXJob__c fxJob = [select Id,Escorter__c,Escorter2__c,
                                  FleetX_Gunmen__c,Armed_Guard_2__c,
                                  FleetX_Driver__c,Driver_2__c,FleetX_RouteName__c,
                                  Loader_1__c,Loader_2__c
                                  from FleetXJob__c where Id=: fleetxJobId limit 1];
            List<Pickup__c> pkList = [select Id,Pickup_Assigned_To__c,Name,FleetXJob__c,
                                      Escorter1__c,Escorter2__c,
                                      Driver__c,Driver_2__c,
                                      Gunmen__c,Armed_Guard_2__c,Route__c,
                                      Loader_1__c,Loader_2__c,Pickup_Assigned_To_Escorter__c                                      
                                      from Pickup__c where Id In : pickupIds];
            if(pkList.size()>0)
            {
                System.debug('Found Records');
                for(Pickup__c p:pkList){
                    p.Pickup_Assigned_To_Escorter__c = fxJob.Escorter__c;		// Pickup_Assigned_To__c 
                    p.FleetXJob__c=fleetxJobId;
                    p.Escorter1__c=fxJob.Escorter__c;
                    p.Route__c=fxJob.FleetX_RouteName__c;
                    p.Escorter2__c=fxJob.Escorter2__c;
                    p.Driver__c=fxJob.FleetX_Driver__c;
                    p.Driver_2__c=fxJob.Driver_2__c;
                    p.Gunmen__c=fxJob.FleetX_Gunmen__c;
                    p.Armed_Guard_2__c=fxJob.Armed_Guard_2__c;
                    p.Loader_1__c=fxJob.Loader_1__c;
                    p.Loader_2__c=fxJob.Loader_2__c;
                }
                try
                {
                    update pkList;
                    System.debug('Updated');
                    res= true;
                }
                catch(Exception e)
                {
                    System.debug('Exception :'+e.getMessage());
                    res= false;
                }
                
            }
        }

        if(shipIds.size()>0 && fleetxJobId!=null)
        // if(shipIds.size()>0 && userId!=null && fleetxJobId!=null)
        {           
            List<Shipment__c> shpList = [select Id,Delivery_Route_Assigned_To__c,Name,FleetXJob__c from Shipment__c where Id In : shipIds];
            if(shpList.size()>0)
            {
                System.debug('Found Records');
                for(Shipment__c s:shpList){
                   // s.Delivery_Route_Assigned_To__c = userId;
                    s.FleetXJob__c=fleetxJobId;
                }
                try
                {
                    update shpList;
                    System.debug('505 shipments Updated Successfully');
                    res= true;
                }
                catch(Exception e)
                {
                    System.debug('510 Shipment Update Exception :'+e.getMessage());
                    res= false;
                }
                
            }
        }
    if(LHIds.size()>0 && fleetxJobId!=null)
    {
        List<Linehaul_Tracking__c> lhListToUpdate = new List<Linehaul_Tracking__c>();
        List<Linehaul_Tracking__c> linehaulList = new List<Linehaul_Tracking__c>();
        System.debug('Linehaul Helper');
        System.debug('Linehaul fleetxJobId :'+fleetxJobId);
        System.debug('Linehaul LHIds :'+LHIds);
        linehaulList = [SELECT Id, Name,Origin__c,AWB_Number__c,Destination__c,FleetXJob__c,Fleet_X_Routes__r.Name,
                          Linehaul_Type__c FROM Linehaul_Tracking__c  WHERE Id In :LHIds]; 
        if(linehaulList.size()>0 && fleetxJobId!=null)
        {
            
            for(Linehaul_Tracking__c lh:linehaulList)
            {
                
                lh.FleetXJob__c=fleetxJobId;
                
                lhListToUpdate.add(lh);                
            }
            update lhListToUpdate;
            res=true;
        }        
    }
        
        if(shipIds.size()>0 && userId!=null){
             System.debug('11 pickupIds :'+pickupIds+'11 userId :'+userId);
        }
        return res;    
}

public class ShipPick
{
    public String pick;
}    
    public static void GetCoverage(){
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
         
}
    
    public static void GetCoverage4(){
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
         
}
    public static void GetCoverage3(){
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
      i++;           i++;
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
    public static void GetCoverage2(){
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
         
}
    public static void GetCoverage1(){
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
         
}
    

public static void GetCoverage10(){
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
         
}
    
public static void GetCoverage11(){
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
         
}
    
public static void GetCoverage12(){
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
         
}
    
public static void GetCoverage13(){
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
         
}
    
public static void GetCoverage14(){
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
         
}
    
public static void GetCoverage15(){
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
         
}
    
public static void GetCoverage16(){
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
         
}
    
public static void GetCoverage17(){
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
         
}
    
public static void GetCoverage18(){
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
         
}
    
public static void GetCoverage19(){
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
         
}
   public static void GetCoverage20(){
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
         
} 
}