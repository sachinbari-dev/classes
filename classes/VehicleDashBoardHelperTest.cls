@isTest(SeeAllData=true)
public class VehicleDashBoardHelperTest 
{
 @isTest
 public static void getVehiclesTest()
 {
   test.StartTest();
	VehicleDashBoardHelper.getVehicles(false);
    TestData();
    FleetX_People__c fp = [select Id,Name from FleetX_People__c where People_userType__c = 'DRIVER' limit 1];
    Transport__c DelhiVehicle = BVCL_TestDataFactory.CreateAirport('Delhi Vehicle',true);
     VehicleDashBoardHelper.getVehicles(true);
     VehicleDashBoardHelper.getVehicles(false);
     Transport__c transport = [select Id,Vendor_Gunmen1__c,Vendor_Gunmen_EMP_Code1__c,Vendor_Gunmen_EMP_Code2__c,Driver__c,Model__c,Vendor_Driver1__c,Vendor_Driver_EMP_Code1__c,Vendor_Driver_EMP_Code2__c,Vehicle_Number__c,Outside_Gunmen__c,Outside_Driver__c,Reporting_Time__c,Vendor_Name__c
                       from Transport__c where Id!=null limit 1];
     try
     {
        VehicleDashBoardHelper.updateVehicle(transport.Id,'Tata',null,'08:45:30','08:45:30',null,null,null,null,null,null,null,null,null,null);  
     }catch(Exception e)
     {
         
     }
    
   test.StopTest();     
 }
    
 public static void TestData()
 {
     FleetX_People__c fp = new FleetX_People__c();
     fp.Name = 'James Thampson';
     fp.People_userType__c='DRIVER';
     insert fp;
 }
}