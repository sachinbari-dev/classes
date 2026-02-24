/**
 * @description       : 
 * @author            : rafi.khan@bvclogistics.com
 * @group             : 
 * @last modified on  : 27-03-2024
 * @last modified by  : rafi.khan@bvclogistics.com
**/
public with sharing class TmsVehicleCustomLookupEscorter {

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {  
        System.debug('for checking searchKey '+ searchKey);
        
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        //string sQuery = 'Select Id, Name, People_userType__c From ' + sObjectApiName + ' Where People_userType__c IN (\'ESCORTER\', \'ESCORTER (BVCL_VS_OP_FO_ESC)\') AND Name Like : sWildCardText order by createdDate DESC LIMIT 10';
        string sQuery = 'Select Id, Name, UserRole.Name From ' + sObjectApiName + ' Where UserRole.Name = \'ESCORTER\' AND Name Like \'' + sWildCardText + '\' order by createdDate DESC LIMIT 10';
        System.debug('for cheking sQuery:'+sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
}