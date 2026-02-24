public class BVCPaymentBuilder {
    public static void paymentLinkGenerator(String endpoint,String authorizationHeader,List<BVCInvoice__c> invoiceList)
    {
        List<Integration_Log__c> insertLogList = new List<Integration_Log__c>();
        Map<String,BVCInvoice__c> invMap = new Map<String,BVCInvoice__c>();
        Map<Id,List<BVC_Payment_Allocation_Invoice__c>> mapPaymentAllocations = new Map<Id,List<BVC_Payment_Allocation_Invoice__c>>();
        Map<Id,BVCPayment__c> mapPayments = new Map<Id,BVCPayment__c>();

        List<BVCPayment__c> BVCPayments = new List<BVCPayment__c>();
        List<BVC_Payment_Allocation_Invoice__c> BVC_PAI = new List<BVC_Payment_Allocation_Invoice__c>();
            
        String method = 'GET'; 
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod(method);
        req.setTimeout(120000);
        
        Map<Id,List<String>> mapInvoicePaymentIds = new Map<Id,List<String>>();
        
        for(BVCInvoice__c inv : invoiceList){
            // Create Razorpay PaymentId Map
            if(inv.BVC_Payment_Allocations_Invoice__r != null && inv.BVC_Payment_Allocations_Invoice__r.size()>0){                
                for(BVC_Payment_Allocation_Invoice__c paymentObj : inv.BVC_Payment_Allocations_Invoice__r){                    
                    if(paymentObj.RazorPay_PaymentId__c != null && mapInvoicePaymentIds.containsKey(inv.Id)){
                        mapInvoicePaymentIds.get(inv.Id).add(paymentObj.RazorPay_PaymentId__c);
                    }
                    else if(paymentObj.RazorPay_PaymentId__c != null ){
                        mapInvoicePaymentIds.put(inv.Id,new List<String>{paymentObj.RazorPay_PaymentId__c});
                    }                    
                }                
            }           
            System.debug('31 Invoice id--->'+inv.Id);
            string plinkd = inv.Razorpay_Id__c.replace('inv','plink');
            system.debug('33 Invoice RID+++-->  '+inv.Razorpay_Id__c+'RazorPay Id+++---> '+plinkd);
            invMap.put(plinkd,inv);
            req.setEndpoint(endpoint+plinkd);
            //System.debug('End Point ::::'+endpoint+plinkd);
            try{
                res = ht.send(req);
            }catch(Exception Ex){
                insertLogList.add(createIntegrationLog(inv.Id,'Razorpay Callout failed','','',''));
                continue;
            }
            
            // system.debug('44 **Response Code** '+res.getStatusCode()+' **Second Response Body** '+res.getBody()+' **Error Detail** '+res.getStatus());
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {

                System.debug('500000000000');
                
                BVCFetchPaymentsWrapper paymentJsonObj = (BVCFetchPaymentsWrapper)JSON.deserialize(res.getBody(),BVCFetchPaymentsWrapper.Class);
                System.debug('52 paymentJsonObj.reference_id: '+paymentJsonObj.reference_id);
                System.debug('52 paymentJsonObj.short_url: '+paymentJsonObj.short_url);
                System.debug('52 paymentJsonObj.order_id: '+paymentJsonObj.order_id);
                System.debug('52 paymentJsonObj.payments: '+paymentJsonObj.payments);
                if(paymentJsonObj != null && paymentJsonObj.payments != null){                                                      
                    Integer paidAmount = 0;
                    for(BVCFetchPaymentsWrapper.payments pay : paymentJsonObj.payments)
                    {
                        if(pay.amount != null && pay.amount >0)
                        {
                            if(pay.amount != null)
                            {
                                 paidAmount = pay.amount/100;
                            }
                    }
                    System.debug('68 paidAmount :'+paidAmount);
                    if(paidAmount > 0)
                    {
                        BVCPayment__c payment = new  BVCPayment__c();
                        payment.BVCInvoice__c = inv.Id;
                        payment.Account__c = inv.Account__c;
                        payment.Status_new__c = 'Posted';
                        payment.Amount1__c = paidAmount;
                        payment.Notes__c = 'Payment Successful with RazorPay';
                        payment.Payment_Type_new__c = 'Razorpay';
                        System.debug('79 payment :'+payment);
                        try {
                                insert payment;
                                System.debug(' 8 Inserted payment Values : '+payment);
                                for(BVCFetchPaymentsWrapper.payments pay1 : paymentJsonObj.payments)
                                {
                                    System.debug('84 pay1.payment_id :'+pay1.payment_id);
                                    System.debug('85 pay1.amount :'+pay1.amount);
                                    if(pay1.amount != null && pay1.amount >0)
                                    {
                                        System.debug('6444444 Enter Here 1');
                                        BVC_Payment_Allocation_Invoice__c pa = new BVC_Payment_Allocation_Invoice__c();
                                        pa.BVCInvoice__c = inv.Id;
                                        pa.RazorPay_PaymentId__c = pay1.payment_id;
                                        pa.Amount__c =(pay1.amount != null? pay1.amount/100 : 0); 
                                        pa.Type__c = 'Allocation';
                                        pa.BVCPayment__c = payment.Id; 
                                        BVC_PAI.add(pa);
                                    } 
                                } 
                        } 
                        catch(Exception e){
                                insertLogList.add(createIntegrationLog(invoiceList[0].Id,e.getMessage(),JSON.serialize(payment),JSON.serialize(payment),''));
                                System.debug(' 101  Insertion Error for payment : '+e.getMessage());
                                System.debug(' 102 payment Values : '+payment);
                        }                
                    }                                                          
                } 
                insertLogList.add(createIntegrationLog(inv.Id,'',req.getBody(),res.getBody(),string.valueOf(res.getStatusCode())));
            }  
            else{
                insertLogList.add(createIntegrationLog(inv.Id,String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('error')),req.getBody(),res.getBody(),string.valueOf(res.getStatusCode())));
            }
        }     

        try {
                insert BVC_PAI;                                  
               // insert insertLogList;
                System.debug(' 116 Inserted BVC_PAI Values : '+BVC_PAI);
        } catch (Exception ex) {
            insertLogList.add(createIntegrationLog(invoiceList[0].Id,ex.getMessage(),JSON.serialize(BVC_PAI),JSON.serialize(BVC_PAI),''));
            System.debug(' 119  Insertion Error for BVC_Payment_Allocation_Invoice__c : '+ex.getMessage());
            System.debug(' 120 Failed BVC_PAI Values : '+BVC_PAI);
        }
        // insert insertLogList;
    }
}  

    public static Integration_Log__c createIntegrationLog(Id invId,String errorMessage,String requestJson,String responseJson,String statusCode){
        
        Integration_Log__c log = new Integration_Log__c();
        log.Integration_Server__c = 'Razorpay';
        log.Request_JSON__c = requestJson;
        log.Response_JSON__c = responseJson;
    //    log.Invoice__c = invId; commented for uninstallation of CPQ
        log.Status_Code__c = statusCode ;
        log.Error_Reason__c = errorMessage;
        return log;
        
    }
    

}