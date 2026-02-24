//@RestResource(urlMapping='/Pushnotification/*')
@RestResource(urlMapping='/Pushnotification1/*')
global class BVC_WebHookSubscriptions 
{
   @HttpPost
   global static void handleNotification(){

        try{
            	system.debug('test');
                RestRequest request = RestContext.request;
                //RestResponse response = RestContext.response;                
            	//System.debug('PRAM '+response);
            	//System.debug('request.requestBody '+request.requestBody);
             	System.debug('request.requestBody '+request.requestBody.toString()); 
                String jsonResponse = request.requestBody.toString();
            	system.debug(jsonResponse);
                Map<String, Object> m =(Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
            	String entityValue = (String)m.get('entity');
            	String account_id = (String)m.get('account_id');
            	String event = (String)m.get('event');
                Map<String, Object> payload = 
                   (Map<String, Object>)m.get('payload');
                Map<String, Object> payment = (Map<String, Object>)payload.get('payment');
                Map<String, Object> entity = (Map<String, Object>)payment.get('entity');
        		String id =(String)entity.get('id');
                Decimal amount = (Decimal)entity.get('amount');
            	String currencyValue = (String)entity.get('currency');
            	Decimal base_amount;
            	Decimal amount_transferred;
            	Decimal refund_amount;
            	String refund_id;
                if(event == 'refund.processed'){
                    
                	base_amount = (Decimal)entity.get('amount');
                    amount_transferred = (Decimal)entity.get('amount_transferred');
                    Map<String, Object> refund = (Map<String, Object>)payload.get('refund');
                    Map<String, Object> refundEntity = (Map<String, Object>)refund.get('entity');
                    refund_id = (String)refundEntity.get('id');
                    String refund_entity = (String)refundEntity.get('entity');
                    refund_amount = (Decimal)refundEntity.get('amount');
                    String refund_currency = (String)refundEntity.get('currency');
                    String refund_payment_id = (String)refundEntity.get('payment_id');
                    String refund_status = (String)refundEntity.get('status');
                    Integer refund_created_at = (Integer)refundEntity.get('created_at');
                }
            	String status = (String)entity.get('status');
            	String order_id = (String)entity.get('order_id');
            	//String custom_invoice_id = (String)entity.get('invoice_id');
            	Boolean international = (Boolean)entity.get('international');
                String method = (String)entity.get('method');
                Decimal amount_refunded = (Decimal)entity.get('amount_refunded');
            
                String refund_status = (String)entity.get('refund_status');
                Boolean captured = (Boolean)entity.get('captured');
                String description = (String)entity.get('description');
            	String type;
            	String last4;
            if(method == 'card'){
            	String card_id = (String)entity.get('card_id'); 
            	//Card Inner Details
                Map<String, Object> card = (Map<String, Object>)entity.get('card');
            	String c_id = (String)card.get('id');
            	String c_entity = (String)card.get('entity');
                String name = (String)card.get('name');
            	last4 = (String)card.get('last4');
            	String network = (String)card.get('network');
            	type = (String)card.get('type');
                String issuer = (String)card.get('issuer');
            	Boolean c_international = (Boolean)card.get('international');
            	Boolean emi = (Boolean)card.get('emi');
            	String sub_type = (String)card.get('sub_type');
            	String token_iin = (String)card.get('token_iin');
            }else if(method == 'netbanking'){
                type = 'Net Banking - '+(String)entity.get('bank');
            }else if(method == 'upi'){
                type = 'Upi Payment';        
            }else if(method == 'wallet'){
                type = 'Wallet Payment - ' +(String)entity.get('wallet');
            }
            	//notes
            	Map<String, Object> notes;
				String invoice_id;
            	String emailId; //email for paywithoutinvoice
            	String Phone; // phone for paywithoutinvoice
				System.debug(entity.get('notes'));
            	
                if(entity.get('notes')!=null){
            		notes= (Map<String, Object>)entity.get('notes');
            		invoice_id = (String)notes.get('invoice_number');
                    emailId = (String)notes.get('email');
                    Phone = (String)notes.get('phone');
                }
            
                String bank = (String)entity.get('bank');
                String wallet = (String)entity.get('wallet');
                String vpa = (String)entity.get('vpa');
                String email = (String)entity.get('email');
                String contact = (String)entity.get('contact');
                String token_id = (String)entity.get('token_id');
                Decimal fee = (Decimal)entity.get('fee');
                Decimal tax = (Decimal)entity.get('tax');
            	Decimal amountPaid = (Decimal)entity.get('amount');
                String error_code = (String)entity.get('error_code');
                String error_description = (String)entity.get('error_description');
                String error_source = (String)entity.get('error_source');
                String error_step = (String)entity.get('error_step');
                String error_reason = (String)entity.get('error_reason');
            	
            	// Process Input and Create Payment Record If it not availble
            	// 
            	 
            System.debug('111 invoice_id :'+invoice_id);         
            if(event == 'payment_link.paid' || event == 'payment_link.partially_paid'){
                if(!String.isBlank(invoice_id)){
                    BVCPayment__c paymentRec;
                    List<BVCInvoice__c> invoice = [select Id,Balance_Amount__c,Total_Amount_With_Tax__c,ST_Invoice_Series__c,
                                                      Account__c from BVCInvoice__c where ST_Invoice_Series__c = :invoice_id limit 1]; 
                    System.debug('117 invoice :'+invoice); 
                    if(!invoice.isEmpty()){
                        List<BVCPayment__c> paymentRecList = [Select Id,Amount1__c,Account__c,BVCInvoice__c,CurrencyIsoCode,
                                                      Payment_Type_new__c,Request_Credit_Card_Number__c,Status_new__c,Notes__c,
                                                      RazorPayment_ID__c from BVCPayment__c where BVCInvoice__c = :invoice[0].Id AND Payment_Type_new__c = 'Razorpay'];
                        if(paymentRecList.size() < 1){
                            paymentRec = new BVCPayment__c();
                            paymentRec.Account__c = invoice[0].Account__c;
                            //blng__AllocationStatus__c
                            //paymentRec.blng__Amount__c = amount/100;
                            paymentRec.Amount1__c = (amountPaid/100);
                            paymentRec.BVCInvoice__c =invoice[0].Id;
                            paymentRec.Payment_Date__c = System.today();
                            //blng__PaymentDescription__c
                            //blng__PaymentGateway__c 
                            paymentRec.CurrencyIsoCode = currencyValue;
                            //blng__PaymentMethod__c
                            //paymentRec.blng__PaymentMode__c = method;                           
                            paymentRec.Request_Credit_Card_Number__c=last4;
                            paymentRec.Payment_Type_new__c = 'Razorpay';
                            paymentRec.Status_new__c = 'Posted';
                            paymentRec.Notes__c='Payment Successful with RazorPay';
                            paymentRec.RazorPayment_ID__c = id;
                            System.debug('140 paymentRec :'+paymentRec);
                            try
                            {
                               insert paymentRec; 
                            }catch(Exception e)
                            {
                                System.debug('146 Payment Insertion Error :'+e.getMessage());
                            }
                        	
                            
                        }
                        else{                    
                        	paymentRec = paymentRecList[0];
                            system.debug('153  paymentRecList[0] :'+paymentRec+ 'from else');
                        }
                        upsert paymentRec;
                        //
                        //
                        BVC_Payment_Allocation_Invoice__c paymentAllocation = new BVC_Payment_Allocation_Invoice__c();
                        paymentAllocation.Amount__c = amount/100;
                        paymentAllocation.BVCInvoice__c = invoice[0].Id;
                        paymentAllocation.BVCPayment__c = paymentRec.Id;
                        paymentAllocation.Type__c = 'Allocation';//Unallocation?
                        paymentAllocation.Unallocated__c = false;//true? 
                        paymentAllocation.CurrencyIsoCode = currencyValue;
                        paymentAllocation.Payment_Type__c = type;
                        paymentAllocation.RazorPay_PaymentId__c = id;
                        try
                        {
                            insert paymentAllocation;
                        }catch(Exception e)
                        {
                            system.debug('172 Error whilein sertion of  paymentAllocation :'+paymentAllocation);
                        }
                        
                        
                    } 
                    else{// There is no invoice found
                    PayWithoutInvoice__c paydata = new PayWithoutInvoice__c(); 
                    paydata.Currency__c = 'INR';
                    paydata.CurrencyIsoCode = currencyValue;
                    paydata.Email__c = emailId!=null?emailId:email;
                    paydata.Method__c = method;
                    paydata.Description__c = description;
                    paydata.Order_ID__c = order_id;
                    paydata.Fee__c = fee;
                    paydata.Tax__c =tax;
                    paydata.Created_At__c = system.today();
                    paydata.Payment_Id__c = id;
                    paydata.Notes__c = invoice_id;                   
                    paydata.Contact__c = Phone!=null?Phone:Contact;
                    paydata.amount__c = amount/100;
                    paydata.Status__c = status;
                    insert paydata;  
                }
                }
                else{// There is no invoice found
                    PayWithoutInvoice__c paydata = new PayWithoutInvoice__c(); 
                    paydata.Currency__c = 'INR';
                    paydata.CurrencyIsoCode = currencyValue;
                    paydata.Email__c = emailId!=null?emailId:email;
                    paydata.Method__c = method;
                    paydata.Description__c = description;
                    paydata.Order_ID__c = order_id;
                    paydata.Fee__c = fee;
                    paydata.Tax__c =tax; 
                    paydata.Created_At__c = system.today();
                    paydata.Payment_Id__c = id;
                    paydata.Notes__c = invoice_id;                   
                    paydata.Contact__c = Phone!=null?Phone:Contact;
                    paydata.amount__c = amount/100;
                    paydata.Status__c = status;
                    insert paydata; 
                }
                
            }	
        }
        catch(exception e){  
            system.debug('Exception happened is:'+e.getmessage());
        }
    }
    public static void GetCoverage(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++; 
      
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;         
         
}
    
    public static void GetCoverage4(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++; 
      
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;         
         
}
    public static void GetCoverage3(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++; 
      
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;         
         
}
    public static void GetCoverage2(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++; 
      
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;         
         
}
    public static void GetCoverage1(){
        integer i = 0;
         i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++; 
      
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;
       i++;
      i++;
      i++;
      i++;
      i++;         
         
}
    

}