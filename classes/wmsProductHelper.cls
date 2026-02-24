/*
 * 
 * Last Modified By : Imran
 * date odified : 13-11-2025
 * V1.1 : method countProductsOnProductMaster added for Calculating Product_Master__c Stock Quantity and Stock Price 
 * v1.2 : method avoidSeriesUpdate added in WMS 2.0 to restrict series update if PO is Verified by Govind on 13 jan 2026
 */
public class wmsProductHelper 
{
	public static void CalculateValues(Map<Id,WMS_Products__c> newPMap,Map<Id,WMS_Products__c> oldPMap,String function)
    {
		if(function=='update')
        {
           afterUpdate(newPMap,oldPMap); 
        } 
		if(function=='delete')
        {
           // afterUpdate(newPMap,oldPMap); 
        }         
    }
    public static void countProductsOnProductMaster(  Set<String>pmIdList)
    {
        
        if(pmIdList.size()>0)
        {
          Map<Id,Product_Master__c> pmMap = new Map<Id,Product_Master__c>([select Id,Stock_Quantity__c,Stock_Price__c,
                                                  (select Id,Quantity__c,Product_Master__c,status__c,Total_Price__c,Purchase_Order__c 
                                                   from WMS_Products__r where status__c = 'Available') 
                                                   from Product_Master__c where Id IN : pmIdList]);
            List<WMS_Products__c> wProductsList = [select Id,Quantity__c,status__c,Product_Master__c,Purchase_Order__c,Purchase_Order__r.id 
                                                   from WMS_Products__c where status__c = 'Available' AND Product_Master__c IN : pmMap.keySet() ];
            if(pmMap.size()>0) {
                for (Id pmId : pmMap.keySet()){
                    Product_Master__c pmRecord = pmMap.get(pmId);
                    Decimal Quantitycount=0;
                    Decimal TotalPrice = 0;
                    if (pmRecord.WMS_Products__r != null && !pmRecord.WMS_Products__r.isEmpty()){                        
                        for (WMS_Products__c wmsProd : pmRecord.WMS_Products__r){
                            if(wmsProd.Quantity__c!=null && wmsProd.Quantity__c>0 && wmsProd.Purchase_Order__c!=null) {
                                System.debug('42 wmsProd: ' + wmsProd);
                                Quantitycount = Quantitycount + wmsProd.Quantity__c;
                                System.debug('Quantity: ' + wmsProd.Quantity__c);
                                TotalPrice = TotalPrice + wmsProd.Total_Price__c;
                                System.debug('Total_Price__c: ' + wmsProd.Total_Price__c); 
                            }                            
                        }
                    }
                    pmRecord.Stock_Quantity__c = Quantitycount;
                    pmRecord.Stock_Price__c = TotalPrice;
                }
            }  
            update pmMap.values();
        }
       
        

    }
    
    
    public static void afterInsert(List<WMS_Products__c> productsList)
    {        
        Set<String> pmIdList = new Set<String>();
        set<id> poIdList = new set<id>();
        for(WMS_Products__c p:productsList)
        {
            if(p.Product_Master__c!=null)
            {
               pmIdList.add(p.Product_Master__c);
            }
            if(p.Purchase_Order__c!=null)
            {
                if(!poIdList.contains(p.Purchase_Order__c))
                {
                    poIdList.add(p.Purchase_Order__c);
                }               
            }
        }
        if(pmIdList.size()>0)
        {
           countProductsOnProductMaster(pmIdList);
        }
        if(poIdList.size()>0)
        {
            List<Purchase_Order__c> poList = [select Id,Multi_Products__c,
                                                  (SELECT Id, Name FROM WMS_Products__r)
                                                  from Purchase_Order__c where Id In : poIdList];
            if(poList.size()>0)
            {
                List<Purchase_Order__c> poList2Update = new List<Purchase_Order__c>();
                for(Purchase_Order__c po:poList)
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
                    System.debug('4999 allNames :'+allNames);
                    if(allNames!='')
                    {
                        allNames = allNames.substring(0, allNames.length() - 1);
                        po.Multi_Products__c = allNames;
                        poList2Update.add(po);
                    }
                }
                
                if(poList2Update.size()>0)
                {
                    System.debug('59 poList2Update :'+poList2Update);
                    update poList2Update;
                }
            }
        }

    }
    public static void afterUpdate(Map<Id,WMS_Products__c> newPMap,Map<Id,WMS_Products__c> oldPMap)
    {
        System.debug('157 afterUpdate');
        Set<String> pmIds = new Set<String>();
          set<id> poIdList = new set<id>();
        List<WMS_Products__c> pList = [select Id,Product_Master__c ,Purchase_Order__c from WMS_Products__c where Id IN :newPMap.keySet()];
         System.debug('157 pList :'+pList);
        if(pList.size()>0)
        {
            for(WMS_Products__c p:pList)
            {
                if(p.Product_Master__c!=null)
                {
                    pmIds.add(p.Product_Master__c);
                }
                  if(p.Purchase_Order__c!=null)
            {
                if(!poIdList.contains(p.Purchase_Order__c))
                {
                    poIdList.add(p.Purchase_Order__c);
                }               
            }
            }
            System.debug('157 pmIds :'+pmIds);
            if(pmIds.size()>0 && poIdList.size()>0)
            {
                //commented by govind for WMS 2.0 enhancements, new method added : purchaseOrderTriggerhelper.updateStockOnProductMaster
              //  countProductsOnProductMaster(poIdList);
            }
        }        
    }    
   // method added in WMS 2.0 to restrict series update if PO is Verified by Govind 
    public static string avoidSeriesUpdate(List<WMS_Products__c> wpList){
        
        set<id> PoId = new set<id>();
        
        for(WMS_Products__c wp : wpList){
            if(wp.Purchase_Order__c != null){
                poId.add(wp.Purchase_Order__c);
            }
        }
        
        List<Purchase_Order__c> poList = [select id ,name,PO_Status__c,Verified_PO__c from Purchase_Order__c where ID IN:PoId];
        for(Purchase_Order__c po : poList){
            if(po.Verified_PO__c == true){
                return 'PO is verified ,can not change series.';
            }
        } 
        return null;
    }
    
  public static void lockDispatchedProducts(List<WMS_Products__c> newList,Map<Id, WMS_Products__c> oldMap) {
       
        Set<String> allowedNextStatuses = new Set<String>{'Delivered','Returned','On Hold'};
    
        for (WMS_Products__c newRec : newList) {
            WMS_Products__c oldRec = oldMap.get(newRec.Id);
    
          
            if (oldRec.Status__c == 'Dispatched'
                && newRec.Status__c != oldRec.Status__c
                && !allowedNextStatuses.contains(newRec.Status__c)) {
    
                newRec.addError(
                    'Dispatched product can only be moved to Delivered, Returned, or On Hold.'
                );
            }
        }
    }

    
    public static void updatePOProductCount(List<WMS_Products__c> newList,Map<Id, WMS_Products__c> oldMap,Boolean isInsert,Boolean isUpdate) {
        
        Set<Id> poIds = new Set<Id>();

        if (isInsert) {
            for (WMS_Products__c w : newList) {
                if (w.Purchase_Order__c != null) {
                    poIds.add(w.Purchase_Order__c);
                }
            }
        }

        if (isUpdate) {
            for (WMS_Products__c w : newList) {
                WMS_Products__c oldW = oldMap.get(w.Id);

                 if (oldW.Purchase_Order__c != null && w.Purchase_Order__c == null) {
            poIds.add(oldW.Purchase_Order__c);
        }
            }
        }

        if (poIds.isEmpty()) return;

        
        Map<Id, Integer> poToCount = new Map<Id, Integer>();

        for (AggregateResult ar : [SELECT Purchase_Order__c poId, COUNT(Id) cnt FROM WMS_Products__c WHERE Purchase_Order__c IN :poIds GROUP BY Purchase_Order__c]) {
            
            poToCount.put((Id) ar.get('poId'), (Integer) ar.get('cnt'));
        }

        
        List<Purchase_Order__c> poUpdates = new List<Purchase_Order__c>();

        for (Id poId : poIds) {
            poUpdates.add(new Purchase_Order__c(
                                                Id = poId,
                                                Product_Count__c = poToCount.containsKey(poId)? poToCount.get(poId): 0
                                            ));
        }

        update poUpdates;
    }
    
    
}