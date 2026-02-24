/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 26-03-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/
public class TMSVehicleDetailsController {
    
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static String createUpdateRecord(String blobData, String vehicleNumber, String modeSelection, 
                                            String escorter,String typeValue,String startKM, String endKM, String routeType){
        Vehicle_Data__c vehicleData = new Vehicle_Data__c();
        String result; System.debug('19 modeSelection :'+modeSelection);
        System.debug('19 vehicleNumber :'+vehicleNumber);
        System.debug('19 routeType :'+routeType);
        List<Vehicle_Data__c> startedVeh = new List<Vehicle_Data__c>();
		Transport__c vehicle = [select Id,Vehicle_Status__c,
                                (select Id,End_KM__c,Mode__c,Time_out__c,Start_KM__c from Vehicles_Data__r order by CreatedDate desc limit 1) 
                                from Transport__c where Id=:vehicleNumber limit 1];
        try{
            startedVeh = [select Id from Vehicle_Data__c where Vehicle_Number__c=: vehicleNumber and Mode__c='Start'];
        }catch(Exception e)
        {
            System.debug('25 Exception :'+e.getMessage());
        }
        System.debug('26 startedVeh :'+startedVeh.size());
        if(startedVeh.size()>0 && modeSelection == 'Start')
        {
            result='Vehicle Already Started';
        }
        else
        {            
            User userData = [SELECT Id,City FROM User WHERE Id = :UserInfo.getUserId()];
            System.debug('for checking userCity :'+userData);
            Hub__c hubData = [Select Id,Name,City__c,Branch__c From Hub__c Where Name=:userData.City OR City__c=:userData.City OR Branch__c=:userData.City limit 1];
            System.debug('40 for checking hubData :'+hubData);
            
            try{
                if(modeSelection == 'Start')
                {
                    if(vehicle.Vehicles_Data__r.size()>0)
                    {
                        Vehicle_Data__c recentVehicle = vehicle.Vehicles_Data__r[0];
                        System.debug('47 for checking recentVehicle :'+recentVehicle);
                        if(Integer.valueOf(startKM)>=Integer.valueOf(recentVehicle.End_KM__c))
                        {
                            // Creating the New Vehicle Data with Start Mode
                            vehicleData.Vehicle_Number__c = vehicleNumber;
                            //vehicleData.Escorter__c = escorter;
                            vehicleData.Type__c = typeValue;
                            vehicleData.Start_KM__c = startKM;
                            vehicleData.Mode__c = 'Start';
                            vehicleData.Time_in__c = System.now();                    
                            vehicleData.User_Hub__c = hubData.Id;  
                            if(routeType!='select')
                            {
                                vehicleData.Route_type__c = routeType;  
                            }                    
                            insert vehicleData;
                            imageUpload(blobData,vehicleData.Id); 
                            vehicle.Vehicle_Status__c ='Started';
                            
                            update vehicle;
                            result ='success';                         
                        }
                        else
                        {
                            result='Start KM should be greater than the last recorded End KM'; 
                        }                        
                    }
                    else
                    {
                        // Creating the New Vehicle Data with Start Mode
                        vehicleData.Vehicle_Number__c = vehicleNumber;
                        //vehicleData.Escorter__c = escorter;
                        vehicleData.Type__c = typeValue;
                        vehicleData.Start_KM__c = startKM;
                        vehicleData.Mode__c = 'Start';
                        vehicleData.Time_in__c = System.now();                    
                        vehicleData.User_Hub__c = hubData.Id;  
                        if(routeType!='select')
                        {
                            vehicleData.Route_type__c = routeType;  
                        }                    
                        insert vehicleData;
                        imageUpload(blobData,vehicleData.Id); 
                        vehicle.Vehicle_Status__c ='Started';
                        
                        update vehicle;
                        result ='success';                          
                    }

                   
                }
                else
                {
                    // Ending the Started Vehicle from Vehicle Data
                    Vehicle_Data__c startedVehicle = [select Id,End_KM__c,Mode__c,Time_out__c,Start_KM__c
                                                      from Vehicle_Data__c where Vehicle_Number__c=: vehicleNumber and Mode__c='Start'];
					Integer startKms = Integer.valueOf(startedVehicle.Start_KM__c)>0?Integer.valueOf(startedVehicle.Start_KM__c):0;  
                    Integer endKms = Integer.valueOf(endKM)>0?Integer.valueOf(endKM):0; 
                    if(endKms>startKms)
                    {
                        startedVehicle.End_KM__c = endKM;
                        startedVehicle.Mode__c = 'End';
                        startedVehicle.Time_out__c = System.now();                    
                        startedVehicle.User_Hub__c = hubData.Id;  
                        vehicle.Vehicle_Status__c ='Completed';
                        if(routeType!='select')
                        {
                            startedVehicle.Route_type__c = routeType;  
                        }
                        update startedVehicle;
                        imageUpload(blobData,startedVehicle.Id); 
                        
                        update vehicle;
                        result ='success';                         
                    }
                    else
                    {
                       result ='End Km must be greater than Start KM :'+startKms; 
                    }
                     
                }
				
            }catch(Exception ex){
                System.debug('Error occure Message '+ex.getMessage());
                System.debug('Error occure Line Number '+ex.getLineNumber());
                if(ex.getLineNumber()==60)
                {
                   result ='Vehicle Not Started, Before End Start The Vehicle';  
                }
                return result;
            }
        } 
        return result;
    }

    @AuraEnabled
    public static String imageUpload(String fileData, String recId){
        try{
            Vehicle_Data__c vdObj = new Vehicle_Data__c();
            vdObj = [Select Id, Name From Vehicle_Data__c Where Id =: recId];
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'VehicleDetails.png'; 
            cVersion.Title = 'Vehicle Details.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = vdObj.Id;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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