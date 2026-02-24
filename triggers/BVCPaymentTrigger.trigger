/****************************************************************************************************************************
 @Author 		: Imran
 @Trigger     	: BVCPaymentTrigger
 @TestClass 	: 
 @Created By 	: Imran
 @Created Date 	: 06-10-2025
 @Description 	: using BVCPaymentTriggerController updating BVCInvoice TDS_payment_status__c, TDS_Balance__c 
 *****************************************************************************************************************************/
trigger BVCPaymentTrigger on BVCPayment__c (after insert,after update,after delete) 
{
    if(trigger.isAfter)
    {
        List<String> BVCinvoiceIdList = new List<String>();
        if(trigger.isInsert)
        {            
            for(BVCPayment__c bp: trigger.new)
            {
                if( bp.BVCInvoice__c!=null && !BVCinvoiceIdList.contains(bp.BVCInvoice__c))
                {
                    BVCinvoiceIdList.add(bp.BVCInvoice__c); 
                }
            }
        }
        
        if(trigger.isUpdate)
        {          
            
            for(BVCPayment__c bp: trigger.new)
            {
                BVCPayment__c op = trigger.oldMap.get(bp.Id);
                if( bp.BVCInvoice__c!=null && !BVCinvoiceIdList.contains(bp.BVCInvoice__c))
                {
                    BVCinvoiceIdList.add(bp.BVCInvoice__c); 
                }                                    
            }
        } 
        if(trigger.isDelete)
        {
            for(BVCPayment__c bp: trigger.old)
            {
                if(bp.BVCInvoice__c!=null && !BVCinvoiceIdList.contains(bp.BVCInvoice__c))
                {
                    BVCinvoiceIdList.add(bp.BVCInvoice__c); 
                }                                    
            }            
        }
        if(BVCinvoiceIdList.size()>0)
        {
           // BVCPaymentTriggerController.UpdateBVCInvoices1(BVCinvoiceIdList);
        }
    }
}