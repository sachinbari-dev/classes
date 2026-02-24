/****************************************************************************************************************************
@Author 		: Imran
@Class     	: BVCPaymentTriggerController
@TestClass 	: 
@Created By 	: Imran
@Created Date 	: 06-10-2025
@Description 	: invoking from BVCPaymentTrigger from BVCPayment__cand updating BVCInvoice TDS_payment_status__c, TDS_Balance__c 
*****************************************************************************************************************************/
public class BVCPaymentTriggerController 
{
    
    public static void UpdateBVCInvoices1(List<String> BVCinvoiceIdList)
    {
        List<BVCInvoice__c> bvcInvoiceList = [select Id,TDS_Payment_Created__c,TDS_payment_status__c,TDS_Amount__c,TDS_Balance__c,Balance1__c,
                                              Total_Amount_With_Tax__c,Payments1__c,
                                              (select Id,Amount1__c,Payment_Type_new__c  from BVCPayments__r) 
                                              from BVCInvoice__c where Id IN : BVCinvoiceIdList];
        List<BVCInvoice__c> updateList = new List<BVCInvoice__c>();
        if(bvcInvoiceList.size()>0)
        {
            
            for(BVCInvoice__c bi : bvcInvoiceList)
            {
				bi.TDS_Balance__c = bi.TDS_Amount__c;
				decimal onlyTDSAmount = 0;
				decimal invWithTDSAmount = 0;
				decimal otherAmount = 0;
				
				decimal TotalPayments = 0;
				decimal Extra = 0;
				boolean isTDS=false;
				if(bi.BVCPayments__r.size()>0)
					{
						for(BVCPayment__c bp:bi.BVCPayments__r)
						{
							if(bp.Payment_Type_new__c=='TDS')
							{
								onlyTDSAmount +=bp.Amount1__c;
								isTDS=true;
								bi.TDS_Payment_Created__c = true;
							}
							if(bp.Payment_Type_new__c=='Invoice With TDS')
							{
								invWithTDSAmount +=bp.Amount1__c;
								isTDS=true;
							}
							if(bp.Payment_Type_new__c!='TDS' && bp.Payment_Type_new__c !='Invoice With TDS')
							{
								otherAmount +=bp.Amount1__c;
                                System.debug('76 otherAmount 44 :'+otherAmount);
							}
						}
                        System.debug('53 invWithTDSAmount :'+invWithTDSAmount);
                        System.debug('54 TotalPayments :'+TotalPayments);
						TotalPayments = otherAmount + invWithTDSAmount;
                        bi.Payments1__c = TotalPayments;
						System.debug('57 TotalPayments :'+TotalPayments);
						if(onlyTDSAmount>0)
						{
							bi.TDS_Balance__c = bi.TDS_Balance__c - onlyTDSAmount;
						}
						
						if(TotalPayments>bi.Total_Amount_With_Tax__c)
						{
							if(bi.TDS_Balance__c >0 && invWithTDSAmount>0)
							{
                                System.debug('67 TotalPayments :'+TotalPayments);
                                Extra = TotalPayments - bi.Total_Amount_With_Tax__c;
                                TotalPayments = TotalPayments - Extra;
                                System.debug('70 TotalPayments :'+TotalPayments);
                                System.debug('71 Extra :'+Extra);
                                System.debug('72 bi.Total_Amount_With_Tax__c :'+bi.Total_Amount_With_Tax__c);
                                if(Extra>=bi.TDS_Balance__c)
                                {                                    
                                    if(Extra == bi.TDS_Balance__c)
                                    {                                    
                                        bi.Balance1__c = bi.Total_Amount_With_Tax__c - TotalPayments;
                                        bi.TDS_Balance__c = 0;
                                        System.debug('79 TotalPayments :'+TotalPayments);
                                        System.debug('80 bi.Balance1__c :'+bi.Balance1__c);
                                        System.debug('81 bi.Total_Amount_With_Tax__c :'+bi.Total_Amount_With_Tax__c);
                                    }

                                   else if(Extra> bi.TDS_Balance__c)
                                    {                                        
                                        Extra = Extra - bi.TDS_Balance__c;
                                        bi.TDS_Balance__c = 0; 
                                        TotalPayments = TotalPayments+ Extra;
                                        bi.Balance1__c = bi.Total_Amount_With_Tax__c - TotalPayments;
                                    }  
                                    System.debug('91 TotalPayments :'+TotalPayments);
                                    System.debug('92 bi.Balance1__c :'+bi.Balance1__c);
                                    System.debug('93 bi.Total_Amount_With_Tax__c :'+bi.Total_Amount_With_Tax__c);
                                    
                                }
                                else
                                {
                                    bi.TDS_Balance__c = bi.TDS_Balance__c - Extra; 
                                    bi.Balance1__c = 0;
                                }								
							}
                            else
                            {
                                 bi.Balance1__c = bi.Total_Amount_With_Tax__c - TotalPayments;
                            }
						}
						else
						{
                            if(TotalPayments<bi.Total_Amount_With_Tax__c)
                            {
                                bi.Balance1__c = bi.Total_Amount_With_Tax__c - TotalPayments;
                                bi.Payments1__c = TotalPayments;
                            }
                            if(TotalPayments==bi.Total_Amount_With_Tax__c)
                            {
                               bi.Balance1__c = 0; 
                            }
						}
						if(bi.TDS_Balance__c==bi.TDS_Amount__c){ bi.TDS_payment_status__c = 'Unpaid';}
						if(bi.TDS_Balance__c<=0){ bi.TDS_payment_status__c = 'Paid';}
						if(bi.TDS_Balance__c<bi.TDS_Amount__c && bi.TDS_Balance__c>0){ bi.TDS_payment_status__c = 'Partially Paid';}
                        System.debug('76 bi :'+bi);
                        updateList.add(bi);
					}
					else
					{
						bi.TDS_payment_status__c = 'Unpaid';
						bi.Payments1__c = 0;
                        bi.Balance1__c = bi.Total_Amount_With_Tax__c;
						updateList.add(bi); 
					}
			}
        }
        if(updateList.size()>0)
        {
            try
            {
                update updateList;
                System.debug('76 updateList :'+updateList);
            }catch(Exception e)
            {
                Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'BVCPaymentTriggerController',Error__c=e.getLineNumber() +'-'+e.getStackTraceString() +'-'+e.getMessage());
                insert AEL;
            }
        }
    }
    
}