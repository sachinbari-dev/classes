public class CustomLookupHelper 
{
    @AuraEnabled
    public static String getCustomLookup(String ObjName,String FilterField,String searchText,
                                         String FilterField1,String searchValue1,String userCity,
                                         List<String> filterList, String parentFieldName,String parentFieldValue)
    {
        List<sObject> sobjList;
        String res;
        System.debug('ObjName :'+ObjName);
        System.debug('FilterField :'+FilterField);
        System.debug('searchText :'+searchText);
        System.debug('FilterField1 :'+FilterField1);
        System.debug('searchValue1 :'+searchValue1);
        System.debug('filterList :'+filterList);
        String stringList='(';
        for(String s:filterList)
        {
            stringList=stringList+'\''+s+'\',';
        }
        stringList = stringList.substring(0, stringList.length() - 1);
        stringList=stringList+')';
        System.debug('stringList :'+stringList);

        if(ObjName!=null)
        {
            String queryString = 'select Id,Name from '+ObjName;
            if(ObjName=='FleetX_People__c')
            {
               queryString = 'select Id,Name,Employee_Code__c from '+ObjName; 
            }
            
            if(searchText!=null)
            {
                if(searchText.length()>=2)
                {
                    searchText='\'%'+searchText+'%\'';
                    queryString = queryString+' where '+FilterField+' like '+searchText;
                }                
            }
            //if((FilterField1!=null && searchValue1!=null) && (searchValue1!='' && FilterField1!=''))
             if(ObjName=='FleetX_People__c' && (searchValue1!=null && searchValue1!=''))
            {
                // queryString = 'select Id,Name,Employee_Code__c from '+ObjName;
                Id userId = UserInfo.getUserId();
                User currentUser = [select Id,city from User where Id=:userId limit 1];
                searchValue1='\''+searchValue1+'\'';                
                String searchCity;
                // searchCity= currentUser.city!=null?'\''+currentUser.city+'\'':null;
                searchCity = userCity!=null?'\''+userCity+'\'':null;
               // searchCity= '\''+searchCity+'\'';
                if (queryString.contains('where')) 
                {
                    if(filterList.size()>0)
                    {
                        queryString = queryString+' and People_userType__c IN '+stringList;
                    }
                    else
                    {
                        queryString = queryString+' and People_userType__c = '+searchValue1;
                    }
                    
                    //queryString = queryString+' and Employee_PunchIN_Date__c = TODAY';
                    if(searchCity!=null)
                    {
                        queryString = queryString+' and City__c ='+searchCity;
                    } 
                    
                } 
                else 
                {
                    if(filterList.size()>0)
                    {
                        queryString = queryString+' where People_userType__c IN '+stringList;
                    }
                    else
                    {
                        queryString = queryString+' where People_userType__c= '+searchValue1;
                    }
                    
                    //queryString = queryString+' and Employee_PunchIN_Date__c = TODAY';
                    if(searchCity!=null)
                    {
                        queryString = queryString+' and City__c ='+searchCity;
                    }
                }
                
            }
            if(ObjName=='FleetX_People__c')
            {
                String active='True';
                queryString = queryString+' and IsActive__c = \'' + active + '\'';
            }            
            if(ObjName=='Account')
            {
                queryString = queryString+' and '+parentFieldName+' = \'' + parentFieldValue + '\'';
            }
            if(ObjName=='AddressBook__c')
            {
                queryString = queryString+' and '+parentFieldName+' = \'' + parentFieldValue + '\'';
            }
            queryString = queryString+' limit 1000';
			System.debug('queryString :'+queryString);
            try{
            sobjList = Database.query(queryString);
            }
            catch(exception e){
                throw new AuraHandledException('Error: '+e.getMessage());
            }
			System.debug('sobjList :'+sobjList);
            ResultWrapper testt = new ResultWrapper();
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        for(SObject s : sobjList){
            System.debug('S :'+s);
            ResultWrapper obj = new ResultWrapper();
            
            obj.objName = ObjName;
            obj.text = String.valueOf(s.get('Id')); 
            if(ObjName=='FleetX_People__c')
            {
                obj.val = String.valueOf(s.get('Name'))+' - '+String.valueOf(s.get('Employee_Code__c')); 
            }
            else {
                obj.val = String.valueOf(s.get('Name')); 
            }
            
            lstRet.add(obj);        
        } 
        system.debug('lnokkupresp@@ '+JSON.serialize(lstRet));
        res = JSON.serialize(lstRet) ;

        }  
        return res;
    }
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}        
    }
}