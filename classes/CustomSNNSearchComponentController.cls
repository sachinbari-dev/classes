/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CustomSNNSearchComponentController
 * Author          : <YourName>
 * Created Date    : Feb 23, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Feb 23, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Feb 23, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class CustomSNNSearchComponentController {

    // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName , String recType) {    
        List < sObject > sObjList = new List < sObject > ();
        string sText = '%' + searchKey + '%';
        //string sWildCardText =  recType;
        string sQuery = 'Select Id,Shipping_Note_Number__c From ' + sObjectApiName + ' Where Shipping_Note_Number__c Like : sText order by Name ASC LIMIT 1000' ;
        
    system.debug('sQuery--->'+sQuery);
    for (sObject obj: database.query(sQuery)) {
        sObjList.add(obj);
    }
    System.debug('sObjList---'+sObjList);
    return sObjList;
}
}