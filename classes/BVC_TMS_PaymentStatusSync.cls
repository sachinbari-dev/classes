public class BVC_TMS_PaymentStatusSync {

      
    @InvocableMethod(label='Get Payment Status' description='Update Payment Status on Invoice')
    public static void SyncPayment(List<Shipment__c> shipmentList) {
        
        List<SyncWrapper> recordDataList = new List<SyncWrapper>();
        List<BVCInvoice__c> invoiceList = new List<BVCInvoice__c>();
        API_Integration_Credential__mdt razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');
        
        String endpoint = razorPayLoginCredentials.Server_URL__c+'/';     
        String username = razorPayLoginCredentials.UserName__c; 
        String password = razorPayLoginCredentials.Password__c;
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        
        for(Shipment__c shipment : shipmentList){
            recordDataList.add(currentInvoice(shipment));
        }    
        
        if(recordDataList.size() > 0 ){
            for(SyncWrapper data :recordDataList ){
                if(data.invoiceData != null){
                    invoiceList.add(data.invoiceData);
                }
            }
        }
        
        System.debug('======= Invoice List =======: '+invoiceList);  
        System.debug('======= endpoint =======: '+endpoint);  
        System.debug('======= authorizationHeader =======: '+authorizationHeader);  
        
        if(invoiceList.size()>0){
            BVCPaymentBuilder.paymentLinkGenerator(endpoint,authorizationHeader,invoiceList); 
        }
    }
    
    public static syncWrapper currentInvoice(Shipment__c shipmentRecord){
       	System.debug('====== Shipment ======'+shipmentRecord);
        Set<id> orderIdSet = new Set<Id>();
        SyncWrapper syncRecord = new SyncWrapper();
        
        if(shipmentRecord != null){
            syncRecord.shipmentData = shipmentRecord;
            for(BVCOrder__c orderRcord : [SELECT Id, Shipment__C FROM BVCOrder__c WHERE Shipment__C =: shipmentRecord.Id AND Valid_Order__c = true ORDER BY CreatedDate DESC LIMIT 1]){
                orderIdSet.add(orderRcord.Id);
                syncRecord.orderData = orderRcord;
            }
            
        }
        
        
        
        if(orderIdSet.size() > 0){
            for(BVCInvoice__c  invoiceRecord : [ SELECT Id,Name,Razorpay_Id__c,Short_URL__c,Account__c,Total_Amount_With_Tax__c, 
                                                (SELECT Id,Name,Amount__c,BVCInvoice__c, Payment_Type_new__c FROM BVCPayments__r 
                                                 WHERE Payment_Type_new__c = 'Razorpay' Order By createdDate desc LIMIT 1), 
                                                (SELECT id,BVCPayment__c,RazorPay_PaymentId__c from BVC_Payment_Allocations_Invoice__r
                                                 WHERE BVCPayment__r.Payment_Type_new__c = 'Razorpay' AND RazorPay_PaymentId__c != null) 
                                                FROM BVCInvoice__c  WHERE Razorpay_Id__c != null AND  Short_URL__c != null AND
                                                Status__c = 'Posted' AND Payment_Status__c != 'Paid 'AND BVCOrder__c IN: orderIdSet
                                                ORDER BY CreatedDate DESC]){
                syncRecord.invoiceData = invoiceRecord;
            }
        }
        System.debug('=======syncRecord ====: '+syncRecord);
        return  syncRecord;
    }
    
    
    
    Class syncWrapper{
        Shipment__C shipmentData;
        BVCOrder__c orderData;
        BVCInvoice__c invoiceData;
        
        public syncWrapper(){
            shipmentData = new Shipment__C();
            orderData = new BVCOrder__c();
            invoiceData = new BVCInvoice__c();
        }
    }
}