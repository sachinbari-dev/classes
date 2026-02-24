public class VehicleDashBoardHelper 
{
 @AuraEnabled
 public static List<Transport__c> getVehicles(boolean startedVehicles)
 {
   User currentUser = [select Id,Name,City,User_Hub__c from User where Id=:UserInfo.getUserId() limit 1] ;
   List<Transport__c> vehiclesList = new List<Transport__c>();
     if(currentUser.City!=null)
     {
         if(startedVehicles)
         {
            vehiclesList = [select Id,Name,Vehicle_Number__c,Driver__c,Driver__r.Name,Is_Inactive__c,Vehicle_Reported__c,
                        Reporting_Time__c,Vendor_Name__c,Schedule_Time__c,Vehicle_Status__c,Outside_Driver__c,Outside_Gunmen__c,
                        FleetX_People__c,FleetX_People__r.Name
                    // from Transport__c WHERE Reporting_Time__c >= TODAY and Current_BVC_Hub__r.Name=: currentUser.City];         
                    from Transport__c WHERE (Current_BVC_Hub__r.Name=: currentUser.City or Current_BVC_Hub__r.Branch__c =: currentUser.City or  Current_BVC_Hub__r.Name =: currentUser.User_Hub__c) and Vehicle_Status__c=:'Started']; 
         }
         else
         {
            vehiclesList = [select Id,Name,Vehicle_Number__c,Driver__c,FleetX_People__r.Name,Driver__r.Name,Is_Inactive__c,
                        Reporting_Time__c,Vendor_Name__c,Schedule_Time__c,Vehicle_Status__c,Outside_Driver__c,Outside_Gunmen__c,
                            FleetX_People__c
                    // from Transport__c WHERE Reporting_Time__c >= TODAY and Current_BVC_Hub__r.Name=: currentUser.City];         
                    from Transport__c WHERE (Current_BVC_Hub__r.Name=: currentUser.City or Current_BVC_Hub__r.Branch__c =: currentUser.City or Current_BVC_Hub__r.Name =: currentUser.User_Hub__c ) and Is_Inactive__c= false]; 
         }
     	
     }
   return vehiclesList;
 }
 @AuraEnabled
 public static String updateVehicle(String vehId,
                                    String vendName,
                                    String DriverId,
                                    String RepTime,
                                    String ShedtimeValue,
									String Gunmen,
                                    String BranchName,
                                    String VendorDriver1,
                                    String VendorDriverEmpCode1,	
									String VendorGunMen1,
                                    String VendorGunmentEmpCode1,
                                    String VendorDriver2,
                                    String VendorDriverEmpCode2,	
									String VendorGunMen2,
                                    String VendorGunmentEmpCode2
                                   )
 {
	String res;
     try
     {
      Transport__c transport = [select Id,Vendor_Gunmen1__c,Vendor_Gunmen_EMP_Code1__c,Vendor_Gunmen_EMP_Code2__c,Driver__c,Model__c,Vendor_Driver1__c,Vendor_Driver_EMP_Code1__c,Vendor_Driver_EMP_Code2__c,Vehicle_Number__c,Outside_Gunmen__c,Outside_Driver__c,Reporting_Time__c,Vendor_Name__c
                       from Transport__c where Id=:vehId limit 1];          System.debug('vehId :'+vehId);
         System.debug('DriverId :'+DriverId);
         System.debug('vendName :'+vendName);
         System.debug('RepTime :'+RepTime);
         System.debug('ShedtimeValue :'+ShedtimeValue);
         System.debug('Gunmen :'+Gunmen);
         System.debug('BranchName :'+BranchName);
         System.debug('VendorDriver1 :'+VendorDriver1);
         System.debug('VendorDriverEmpCode1 :'+VendorDriverEmpCode1);
         System.debug('VendorGunMen1 :'+VendorGunMen1);
         System.debug('VendorDriverEmpCode2 :'+VendorDriverEmpCode2);
         System.debug('VendorDriver2 :'+VendorDriver2);
         System.debug('VendorGunMen2 :'+VendorGunMen2);
         System.debug('VendorGunmentEmpCode2 :'+VendorGunmentEmpCode2);
         // Get today's date
        Date todayDate = Date.today();

        // Split the time string into components
        List<String> ReptimeParts = RepTime.split(':');
        Integer Rphours = Integer.valueOf(ReptimeParts[0]);
        Integer Rpminutes = Integer.valueOf(ReptimeParts[1]);
        Integer Rpseconds = Integer.valueOf(ReptimeParts[2].split('\\.')[0]); // Extract seconds

         List<String> ShedtimeParts = ShedtimeValue.split(':');
         Integer Shhours = Integer.valueOf(ShedtimeParts[0]);
         Integer Shminutes = Integer.valueOf(ShedtimeParts[1]);
         Integer Shseconds = Integer.valueOf(ShedtimeParts[2].split('\\.')[0]); // Extract seconds
         
        // Create DateTime using today's date and parsed time
        DateTime RepdateTimeValue = DateTime.newInstance( todayDate.year(), todayDate.month(), todayDate.day(), Rphours, Rpminutes, Rpseconds );
         DateTime SheddateTimeValue = DateTime.newInstance( todayDate.year(), todayDate.month(), todayDate.day(), Shhours, Shminutes, Shseconds );
         System.debug('RepdateTimeValue :'+RepdateTimeValue);         
         transport.Reporting_Time__c=RepdateTimeValue;
         transport.Schedule_Time__c=SheddateTimeValue;
         if(DriverId!=null){transport.Driver__c=DriverId;}
         if(vendName!=null){transport.Vendor_Name__c=vendName;}

         if(Gunmen!=null){transport.FleetX_People__c=Gunmen;}										
         if(BranchName!=null){transport.Current_BVC_Hub__c=BranchName;}
         if(VendorDriver1!=null){transport.Outside_Driver__c=VendorDriver1;}	
         if(VendorDriverEmpCode1!=null){transport.Vendor_Driver_EMP_Code1__c=VendorDriverEmpCode1;}
         if(VendorGunMen1!=null){transport.Outside_Gunmen__c=VendorGunMen1;}										
         if(VendorGunmentEmpCode1!=null){transport.Vendor_Gunmen_EMP_Code1__c=VendorGunmentEmpCode1;}
         if(VendorDriver2!=null){transport.Vendor_Driver1__c=VendorDriver2;}
		 
         if(VendorDriverEmpCode2!=null){transport.Vendor_Driver_EMP_Code2__c=VendorDriverEmpCode2;}										
         if(VendorGunMen2!=null){transport.Vendor_Gunmen1__c=VendorGunMen2;}
         if(VendorGunmentEmpCode2!=null){transport.Vendor_Gunmen_EMP_Code2__c=VendorGunmentEmpCode2;}
         
         update transport;
         res='success';
     }catch(exception e)
     {
         System.debug('e.getMessage() :'+e.getMessage());
        res=e.getMessage(); 
     }
   
    return res;
 }
}