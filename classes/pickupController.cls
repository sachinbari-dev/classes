/****************************************************************************************************************************
 @Author 		: Imran
 @Class     	: pickupController
 @TestClass 	: 
 @Created By 	: Imran
 @Created Date 	: 9/09/2025
 @Description 	: controller class for CustomPath Aura component
 *****************************************************************************************************************************/
public class pickupController 
{
    @AuraEnabled    
    public static Boolean getErrorMessageValidation(String pickupId)
    {
        Boolean foundHol = false;
        System.debug('66 pickupId :'+pickupId);
        Pickup__c pk = [select Id,Origin_Address_State__c from Pickup__c where Id=:pickupId];
        System.debug('66 pk :'+pk);
        try
        {
            if(pk!=null)
            {
                Holiday_Data__c HD = [select Id from Holiday_Data__c  where State__c =: pk.Origin_Address_State__c and Date__c =: Date.today() limit 1];
                if(HD!=null)
                {
                    foundHol=true; 
                }
                
            }
            System.debug('66 foundHol :'+foundHol);
            if(DateTime.now().format('EEEE')=='Sunday')
            {
                foundHol=true; 
            }           
        }catch(exception e)
        {
            
        }
        
        System.debug('25 foundHol :'+foundHol);
        return foundHol;
    }
    @AuraEnabled    
    public static String updatePickup(String pickupId,String PickupStage)
    {
        String message=null;
        if(pickupId!=null)
        {
            Pickup__c pk = [select Id,Pickup_Status__c from Pickup__c where Id=:pickupId]; 
            try
            {
                pk.Pickup_Status__c = PickupStage;
                update pk;
                message ='success';
            }catch(exception e)
            {
                message = e.getMessage();
            }
        }
        return message;
    }
    
}