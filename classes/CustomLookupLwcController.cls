/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 04-04-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/
public with sharing class CustomLookupLwcController {

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {
        
        String userId = UserInfo.getUserId();
        FSE_Sales__c fs = [SELECT Sales_Person__c, Id, Name, Hub__c,Hub__r.Branch__c FROM FSE_Sales__c where Sales_Person__c=:userId LIMIT 1];
        string EmpHub = fs.Hub__r.Branch__c;
        
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id, Name, Trunk_name__r.Name, Trunk_name__r.Trunk_Tear_Weight__c, Linehaul_Tracking__c, Linehaul_Tracking__r.Origin__c, RecordType.Name, Left_Seal__c, Left_Seal__r.Name, AWB_number__c From ' + sObjectApiName + ' Where Left_Seal__r.Name Like : sWildCardText AND Linehaul_Tracking__r.Origin__c =: EmpHub order by createdDate DESC LIMIT 10';
        //string sQuery = 'Select Id, Name, Trunk_name__r.Name, Linehaul_Tracking__c, Linehaul_Tracking__r.Origin__c, RecordType.Name, Left_Seal__c, Left_Seal__r.Name, AWB_number__c From ' + sObjectApiName + ' Where Left_Seal__r.Name Like : sWildCardText order by createdDate DESC LIMIT 10';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    
}