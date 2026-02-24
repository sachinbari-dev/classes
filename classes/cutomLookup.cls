public class cutomLookup {
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText,String RecordType, 
                                  string originPort, string DestPort,String SecPackType,String CusId,String fld_API_Text1){
                                      Id RecTypeId;
                                      // System.debug('11.CusId :'+CusId);
                                      System.debug('11.objectName :'+objectName);
                                      System.debug('11.fld_API_Text :'+fld_API_Text);
                                      System.debug('11.searchText :'+searchText);
                                      System.debug('11.fld_API_Text1 :'+fld_API_Text1);
                                      List<sObject> sobjList; 


                                      searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                                      String query;
                                      if(objectName=='FleetX_People__c')
                                      {
                                          query = 'SELECT Name,People_lastName__c,'+fld_API_Text+' ,'+fld_API_Val;
                                      }                                      
                                       if(objectName=='User')
                                      {
                                           query = 'SELECT Name,'+fld_API_Text+' ,'+fld_API_Val;
                                      }
                                      query += ' FROM '+objectName ;               
                                      Id Packagingtype;
                                      
                                      // query +=' WHERE ' +fld_API_Search+' LIKE '+searchText;
                                      // +fld_API_Text '='+fld_API_Text1+' AND '

                                      if(fld_API_Text1=='Gunmen')
                                      {
                                          String txt='Gunman (BVCL_VS_OP_FO_GM)';
                                          query +=' WHERE ('+fld_API_Text+'=\''+fld_API_Text1+'\' OR '+fld_API_Text+'=\''+txt+'\') AND ' +fld_API_Search+' LIKE '+searchText; 
                                      }
                                      else
                                      {
                                          if(objectName=='User')
                                          {
                                              query +=' WHERE '+fld_API_Text+'='+fld_API_Text1+' AND ' +fld_API_Search+' LIKE '+searchText;
                                          }
                                          else
                                          {
                                              query +=' WHERE '+fld_API_Text+'=\''+fld_API_Text1+'\' AND ' +fld_API_Search+' LIKE '+searchText;
                                          }
                                           
                                      }
                                      // query +=' WHERE '+fld_API_Text+'=\''+fld_API_Text1+'\' AND ' +fld_API_Search+' LIKE '+searchText;
                                      
                                      string whereClause = '';

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
                                          String text12 = String.valueOf(s.get('Name'));
                                          if(objectName=='FleetX_People__c')
                                          {
                                              String text13 = String.valueOf(s.get('People_lastName__c'));
                                              // obj.text = obj.text +' - '+ text12;
                                              obj.text = text12 +' - '+ text13;                                              
                                          }
                                          else if(objectName=='User')
                                          {
                                              obj.text = text12;
                                          }

                                          
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