trigger BVC_AutoGenerateQuoteLines on BVCQuote__c (after update,after Insert) 
{
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            List<BVCQuote__c> bvcQList = new List<BVCQuote__c>();
            for(BVCQuote__c q:trigger.new)
            {                
                if(q.BVC_Service__c=='eSHIP' && (q.Tariff_Plan__c=='Custom' || q.Tariff_Plan__c=='Standard'))
                {
                    bvcQList.add(q);
                }
            }
            if(bvcQList.size()>0)
            {
                BVC_AutoGenerateQuoteLinesTriggerHelper.createeShipCustomPricing(bvcQList);
            }
        }
        
        if(trigger.isUpdate)
        {
            Set<String> PriceSlabList = new Set<String>();
            Map<String,BVCQuote__c> quoteMap = new Map<String,BVCQuote__c>();
            for(BVCQuote__c q:trigger.new)
            {
                BVCQuote__c oldQuote = trigger.OldMap.get(q.Id);
                if(oldQuote.BVC_Price_Slab__c != q.BVC_Price_Slab__c)
                { quoteMap.put(q.BVC_Price_Slab__c,q);  PriceSlabList.add(q.BVC_Price_Slab__c); }
            }            
            if(quoteMap.size()>0)
            {
                 BVC_AutoGenerateQuoteLinesTriggerHelper.ChangePriceSlab(quoteMap,PriceSlabList); 
            }            
        }
	
    }
}