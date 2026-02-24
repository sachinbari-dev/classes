/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 27-03-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/

@isTest
public class TMSVehicleDetailsControllerTest { 
    
    @isTest
    static void testCreateUpdateRecord() {
        Transport__c trObj = new Transport__c();
        trObj.Vehicle_Number__c = 'MH02J2015';
        insert trObj;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'HYDERABAD-SCP';
        newHub.Branch__c = 'HYDERABAD';
        insert newHub;
        
        String blobData = 'sampleImageData'; 
        String vehicleNumber = 'MH02J2015';
        String startKM = '100';
        String endKM = '200';
        String typeTest = '2';
        
        Vehicle_Data__c vdObj = new Vehicle_Data__c();
        vdObj.Start_KM__c = startKM;
        vdObj.End_KM__c = endKM;
        vdObj.Type__c = '11111';
        vdObj.Mode__c = 'Start';
        vdObj.User_Hub__c = newHub.Id;
        if(startKM != '' || startKM != null){
                vdObj.Start_KM__c = startKM;
            }
            if(endKM != '' || endKM != null){
                vdObj.End_KM__c = endKM;
            }
            if(!String.isEmpty(startKM))
            {
                vdObj.Mode__c = 'Start';
                vdObj.Time_in__c = System.now();

            } else {
                vdObj.Mode__c = 'End';
                vdObj.Time_out__c = System.now();

            }
        insert vdObj;
        
        Test.startTest();
        String result = TMSVehicleDetailsController.createUpdateRecord(blobData, 
                                                                       trObj.Id,'Start', 
                                                                       vdObj.Escorter__c,
                                                                       typeTest, 
                                                                       startKM, 
                                                                       endKM,'select');
        User loggedInUser = TMSVehicleDetailsController.getUserInfo();
        String testResult = TMSVehicleDetailsController.imageUpload(blobData, vdObj.Id);
        TMSVehicleDetailsController.GetCoverage();
        Test.stopTest();
        
    }
    
}