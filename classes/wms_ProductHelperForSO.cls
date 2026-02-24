public class wms_ProductHelperForSO {

    public static void multiProductUpdateOnSO(List<WMS_Products__c> productsList){
        
        List<String> poIdList = new List<String>();
        for(WMS_Products__c p:productsList)
        {
            if(p.Sales_Order__c!=null)
            {
                if(!poIdList.contains(p.Sales_Order__c))
                {
                    poIdList.add(p.Sales_Order__c);
                }               
            }
        }
        
        if(poIdList.size()>0)
        {
            List<Sales_Order__c> poList = [select Id,Multi_Products__c,
                                                  (SELECT Id, Name FROM WMS_Products__r)
                                                  from Sales_Order__c where Id In : poIdList];
            if(poList.size()>0)
            { 
                List<Sales_Order__c> poList2Update = new List<Sales_Order__c>();
                for(Sales_Order__c po:poList)
                {
                    String allNames='';
                    if(po.WMS_Products__r.size()>0)
                    {
                        for(WMS_Products__c p:po.WMS_Products__r)
                        {
							allNames+=p.Name;
                            allNames+=';';
                        }
                    }
                    if(allNames!='')
                    {
                        allNames = allNames.substring(0, allNames.length() - 1);
                        po.Multi_Products__c = allNames;
                        poList2Update.add(po);
                    }
                }
                
                if(poList2Update.size()>0)
                {
                    update poList2Update;
                }
            }
    }
}
}