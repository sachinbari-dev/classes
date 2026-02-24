/**
* @description       : 
* @author            : Imran
* @group             : 
* @last modified on  : 10-25-2023
* @last modified by  : Imran
**/
public class TMS_Lookup3 {
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText,String RecordType, 
                                  string originPort, string DestPort,String SecPackType,String CusId,String fld_API_Text1){
                                      Id RecTypeId;
                                      System.debug('11.CusId :'+CusId);
                                      System.debug('11.objectName :'+objectName);
                                      System.debug('11.fld_API_Text :'+fld_API_Text);
                                      System.debug('11.searchText :'+searchText);
                                      List<sObject> sobjList; 
                                      /*
                                      if(objectName=='Account' && string.isNotBlank(RecordType)){
                                          RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
                                      }

                                      if(objectName=='Account' && RecordType =='Billing')
                                      {
                                          RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
                                      }      
                                      if(objectName=='Account' && RecordType =='Shipping')
                                      {
                                          RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
                                      }      
                                      
                                      */
                                                            
                                      searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                                      
                                      String query = 'SELECT Address_Name__c,Address_Details__c,Address_Code__c,'+fld_API_Text+' ,'+fld_API_Val;
                                      /*
                                      if(objectName=='Account' && RecordType =='Billing')
                                      {
                                          query += ' ,'+fld_API_Text1; 
                                      }        
                                      */
                                      query += ' FROM '+objectName ;               
                                      Id Packagingtype;
                                      
                                      query +=' WHERE ' +fld_API_Search+' LIKE '+searchText;
                                      
                                      string whereClause = '';
                                      /*
                                      if(objectName=='AddressBook__c')
                                      {
                                          whereClause += 'AND Customer__c =\''+CusId+'\' ';
                                          //Customer__c =\''+CusId+'\' ';
                                      }      
                                      if(objectName=='Contact')
                                      {
                                          whereClause += 'AND AddressBook__c =\''+CusId+'\' ';
                                          System.debug('11=>got Contact');
                                      } 
                                      
                                      if(objectName=='Account' && RecordType =='Shipping'){
                                          String actStatus='Active';
                                          whereClause += 'AND Customer_Status__c =\''+actStatus+'\' ';  
                                      }
                                      
                                      system.debug('lokkupresp@@ '+originPort +''+ Destport);
                                      if(objectName=='Account' && String.isNotBlank(RecTypeId)){
                                          whereClause += 'AND RecordTypeId =:RecTypeId ';
                                      } 
                                      */
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
                                          ResultWrapper obj = new ResultWrapper();
                                          obj.objName = objectName;
                                          obj.text = String.valueOf(s.get(fld_API_Text)); 
                                          String text12 = String.valueOf(s.get('Address_Name__c'));
                                          String text13 = String.valueOf(s.get('Address_Details__c'));
                                          // obj.text = obj.text +' - '+ text12;
                                          obj.text = text12 +' - '+ text13;
                                          obj.Idval = String.valueOf(s.get('Id'));
                                          obj.val = String.valueOf(s.get(fld_API_Val));           
                                          
                                          System.debug('Obj Val :'+obj.text);
                                          lstRet.add(obj);        
                                      } 
                                      system.debug('lnokkupresp@@ '+JSON.serialize(lstRet));
                                      return JSON.serialize(lstRet) ;
                                  }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String Idval {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        public String text1{get;set;}
        
    }
    
}