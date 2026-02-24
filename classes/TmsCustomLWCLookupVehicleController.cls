/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 26-03-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/
public with sharing class TmsCustomLWCLookupVehicleController {

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id, Name, Vehicle_Number__c,Outside_Driver__c,Outside_Gunmen__c,FleetX_People__c,Reporting_Time__c,Schedule_Time__c,FleetX_People__r.Name,Driver__c,Driver__r.Name From ' + sObjectApiName + ' Where Vehicle_Number__c Like : sWildCardText order by createdDate DESC LIMIT 10';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
}