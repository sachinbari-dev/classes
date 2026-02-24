/**
* @description       : 
* @author            : Sanket
* @group             : 
* @last modified on  : 22-12-2025
* @last modified by  : Sanket
**/
public class TMS_Lookup4 {
    @AuraEnabled(cacheable=true)
    public static String searchDB(String isParent,
        						  String CustAcId,
                                  String objectName, 
                                  String fld_API_Text, 
                                  String fld_API_Val, 
                                  Integer lim,
                                  String fld_API_Search,
                                  String searchText,
                                  String RecordType, 
                                  string originPort, 
                                  string DestPort,
                                  String SecPackType,
                                  String CusId,
                                  String fld_API_Text1,
                                  String Exhibition){
        Id RecTypeId;
        Boolean active = true;
        System.debug('11.CusId :'+CusId);
        System.debug('11.isParent :'+isParent);                              // isParent
        System.debug('11.CusId :'+CustAcId);
        System.debug('11.objectName :'+objectName);
        System.debug('11.fld_API_Text :'+fld_API_Text);
        System.debug('11.searchText :'+searchText);
        List<sObject> sobjList; 
        if(objectName=='Account' && string.isNotBlank(RecordType)){
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        }
        // get Recprd type
        if(objectName=='Account' && RecordType =='Billing')
        {
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        }      
        if(objectName=='Account' && RecordType =='Shipping')
        {
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        }      
        
        
        //        List<sObject> sobjList;                        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val;
        
        if(objectName=='Account' && RecordType =='Billing')
        {
            query += ' ,'+fld_API_Text1+',Credit_Status__c,(select Id,Name from ChildAccounts) '; 
        }                       
        query += ' FROM '+objectName ;               
        Id Packagingtype;
        
        query +=' WHERE ' +fld_API_Search+' LIKE '+searchText;
        
        string whereClause = '';
      
        if (objectName == 'AddressBook__c') {

    whereClause += 'AND Customer__c = \'' + CusId + '\' ';
    whereClause += 'AND Is_Active__c = ' + active + ' ';
    whereClause += 'AND Pincode_Types__c = \'Serviceable\' ';

    
  if (String.isNotBlank(Exhibition)) {
    whereClause += 'AND Exhibition__c = \'' + Exhibition + '\' ';
}

}
                              
                                      
        if(isParent=='true')
        {
            whereClause += 'AND ParentId = null ';
        }                                      
        if(objectName=='Contact')
        {
            boolean status=true;
            whereClause += 'AND AddressBook__c =\''+CusId+'\' and Active_status__c= true ';
        } 

        if(CustAcId!=null)
        {
            whereClause += 'AND ParentId =\''+CustAcId+'\' ';
            System.debug('11=>got CustAcId :'+CustAcId);
        }        
        
        if(objectName=='Account' && RecordType =='Shipping'){
            String actStatus='Active';
            whereClause += 'AND Customer_Status__c =\''+actStatus+'\' ';  
        }
        
        system.debug('lokkupresp@@ '+originPort +''+ Destport);
        if(objectName=='Account' && String.isNotBlank(RecTypeId)){
            whereClause += 'AND RecordTypeId =:RecTypeId ';
        }
        
        // Add condition for Customer_Category_Static__c being 'ACR' for Billing accounts
      //if (objectName == 'Account' && RecordType == 'Billing') {
          // whereClause += 'AND Customer_Category_Static__c = \'ACR\' ';
       // }  
    if (objectName == 'Account' && RecordType == 'Billing') {
    whereClause += 'AND ((Customer_Category_Static__c = \'ACR\' AND (Credit_Status__c = \'Credit\' OR Credit_Status__c = \'Non Credit\')) ';
    whereClause += 'OR (Customer_Category_Static__c = \'Non-ACR\' AND Credit_Status__c = \'Credit\')) ';
}



//if (objectName == 'Account' && RecordType == 'Billing') {
  //  whereClause += 'AND NOT (Customer_Category_Static__c = \'Non-ACR\' AND Customer_Status__c = \'Non Credit\') ';
//}                        
                                      
                                      
        if(whereClause.left(3)=='AND')
            whereClause = whereClause.substringAfter('AND');
        query += ' AND '+whereClause;                          
        query=  query.removeEnd('AND ');
        query += ' LIMIT '+lim;
        System.debug('query ===> '+query);
        try{
            sobjList = Database.query(query);
        }
        catch(exception e){
            throw new AuraHandledException('Error: '+e.getMessage());
        }
        
        
        
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        for(SObject s : sobjList){
            System.debug('S :'+s);
            ResultWrapper obj = new ResultWrapper();
            
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)); 
            obj.val = String.valueOf(s.get(fld_API_Val));
           // obj.childAc=Integer.valueOf(s.get(ChildAccounts.size()));
            if(objectName=='Account' && RecordType =='Billing'){
                if(fld_API_Text1!=null)
                {
                    obj.text1 = String.valueOf(s.get(fld_API_Text1));
                     obj.CreditStatus = String.valueOf(s.get('Credit_Status__c'));
                    if(obj.text1=='Non ACR')
                    {
                     //   obj.CreditStatus = String.valueOf(s.get('Credit_Status__c'));
                    }                	
                }
                Account a = (Account)s;
                System.debug('Size :'+a.ChildAccounts.size());
                obj.childAc=a.ChildAccounts.size();
            }  

            lstRet.add(obj);        
        } 
        system.debug('lnokkupresp@@ '+JSON.serialize(lstRet));
        return JSON.serialize(lstRet) ;
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        public String text1{get;set;}
        public Integer childAc{get;set;}
        public String CreditStatus{get;set;}
        
    }
}