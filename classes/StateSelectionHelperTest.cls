@isTest
public class StateSelectionHelperTest 
{
    @isTest
    public static void method1() 
    {
        test.StartTest();
        StateSelectionHelper.getUserDetails();
        List<String> statesList = new List<String>{'Punjab', 'Telangana', 'Andhra Pradesh'};
        State_Access__c statesRecord = new State_Access__c();
        statesRecord.Selected_Sates__c='Andhra;Kerala';
        statesRecord.Current_User__c=userInfo.getUserId();
        insert statesRecord;
        StateSelectionHelper.saveSates(statesList);
        test.StopTest();
    }
}