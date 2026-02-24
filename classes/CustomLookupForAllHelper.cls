/**
* @File Name : CustomLookupForAllHelper.cls
* @Description :
* @Author : Imran
* @Last Modified By :
* @Last Modified On : June 20, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 20, 2025 |   | Initial Version
**/

public class CustomLookupForAllHelper {

    @AuraEnabled
    public static String getCustomLookup(String ObjName,String FilterField,String searchText,
                                         String userCity,List<String> filterList, String LookupFiledObjName,
										 String parentFieldName,String parentFieldValue,String mainobjectfieldname
										 )
    {
        List<sObject> sobjList;
        String res;
        System.debug('ObjName :'+ObjName);
        System.debug('FilterField :'+FilterField);
        System.debug('searchText :'+searchText);
		System.debug('LookupFiledObjName :'+LookupFiledObjName);
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
            if(searchText!=null)
            {
                if(searchText.length()>=2)
                {
                    searchText='\'%'+searchText+'%\'';
                    queryString = queryString+' where '+FilterField+' like '+searchText;
                }                
            }
            if(ObjName=='Account')
            {
                if(LookupFiledObjName=='Vault_Shipmet__c' && mainobjectfieldname=='Shipping_Account__c')
                {
                    String FielterValue='Shipping';
                    queryString = queryString+' and RecordType.Name  = \'' + FielterValue + '\'';
                }else if(parentFieldName!=null && parentFieldName!='' && parentFieldValue!=null && parentFieldValue!='')
                {
                    queryString = queryString+' and '+parentFieldName+' = \'' + parentFieldValue + '\'';
                }
                
            }
            if(ObjName=='AddressBook__c')
            {
                if(LookupFiledObjName=='Vault_Shipmet__c' && mainobjectfieldname=='Stall_Details_Shipping_Address__c')
                {
                    if(parentFieldName!=null && parentFieldName!='' && parentFieldValue!=null && parentFieldValue!='')
                    {
                        String FielterValue='Billing';
                        queryString = queryString+' and Is_Active__c  = true  and Pincode_Types__c !=\'Non-Serviceable\'';
                         queryString = queryString+' and '+parentFieldName+' = \'' + parentFieldValue + '\'';
                    }

                } else if(parentFieldName!=null && parentFieldName!='' && parentFieldValue!=null && parentFieldValue!='')
                {
                    queryString = queryString+' and '+parentFieldName+' = \'' + parentFieldValue + '\'';
                }                
            }
            if(ObjName=='BVC_Vault_Master__c')
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
            obj.val = String.valueOf(s.get('Name')); 
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