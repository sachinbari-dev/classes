public class StateSelectionHelper 
{
    
    @AuraEnabled
    public static User getUserDetails()
    { 
        String userId =UserInfo.getUserId();
        System.debug('userId :'+userId);
        User currentUser = [select Id,name,Profile.Name from User where Id=:userId limit 1];
        return currentUser;
    }
     @AuraEnabled
    public static State_Access__c getStateAccess()
    { 
        return  [select Id,Name,Current_User__c,Selected_Sates__c from State_Access__c limit 1];
    }

    @AuraEnabled
    public static String saveSates(List<String> statesList)
    {        
        System.debug('36 States List :'+statesList);
        String Result;
        String AllStates;
        for(String s:statesList)
        {
            if(AllStates==null)
            {
                AllStates = s;
            }
            else
            {
                AllStates = AllStates+';'+s;
            }
        }        
        try
        {
            String userId =UserInfo.getUserId();
            System.debug('userId :'+userId);
            User currentUser = [select Id,name,Profile.Name from User where Id=:userId limit 1];
            if(currentUser.Profile.Name=='System Administrator' || currentUser.Profile.Name=='Operations Admin')
            {
                State_Access__c statesRecord = [select Id,Name,Current_User__c,Selected_Sates__c from State_Access__c limit 1];
                if(statesRecord!=null)
                {            
                    statesRecord.Selected_Sates__c=AllStates;
                    update statesRecord;
                    Result = 'States Updated Successfully for '+statesRecord.Name;
                } 
            }
        }
        catch(exception e)
        {System.debug('Exception :'+e.getMessage());}
        return Result;
    }
}