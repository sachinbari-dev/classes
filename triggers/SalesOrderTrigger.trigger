trigger SalesOrderTrigger on Sales_Order__c (before insert,before update, after insert, after update) {

    //Before
    if(Trigger.isBefore){
        
    //Before Insert
        if(Trigger.isInsert){
            
        }
     //Before Update   
        if(Trigger.isUpdate){
            
                Set<Id> salesOrderIds = new Set<Id>();
             List<Sales_Order__c> salesOrderList = new List<Sales_Order__c>();
             List<Sales_Order__c> soToUpdate = new List<Sales_Order__c>();
              List<Sales_Order__c> salesOrderList1 = new List<Sales_Order__c>();
             List<Sales_Order__c> soToUpdate2 = new List<Sales_Order__c>();
             List<Sales_Order__c> soToUpdate3 = new List<Sales_Order__c>();
            List<Sales_Order__c> soToUpdate4 = new List<Sales_Order__c>();
            
                for (Sales_Order__c so : Trigger.new) {
                    Sales_Order__c oldSO = Trigger.oldMap.get(so.Id);
            
                    
                    if (so.sales_order_status__c != oldSO.sales_order_status__c && ((oldSO.sales_order_status__c == 'Draft' && so.sales_order_status__c == 'Stock Reserved'))) {
                        salesOrderIds.add(so.Id);
                    }
                    
                     if (so.sales_order_status__c != oldSO.sales_order_status__c && ((oldSO.sales_order_status__c =='Draft' && so.sales_order_status__c == 'Dispatched'))) {
                        salesOrderIds.add(so.Id);
                    }
                    /*
                    if (so.sales_order_status__c != oldSO.sales_order_status__c && ((oldSO.sales_order_status__c =='Stock Reserved' && so.sales_order_status__c == 'Dispatched'))) {
                        salesOrderIds.add(so.Id);
                    }  */
                    
                    if(so.Sales_Order_Status__c == 'Returned' && so.Returned_Reasons__c == null){
                        so.addError('Please Add Returned Reason');
                    }else if(oldSO.Returned_Reasons__c == null && so.Returned_Reasons__c !=null){
                       so.Sales_Order_Status__c = 'Returned';
                    }else if(oldSO.Sales_Order_Status__c =='Returned' && so.Sales_Order_Status__c !='Returned'){
                        so.addError('You can not change status of sales order once it is Returned');
                    }else if(so.Sales_Order_Status__c =='Cancel' && oldSO.Sales_Order_Status__c !='Dispatched'){
                         so.addError('cancel is allowed only after dispatch');
                    }
                    if (so.Sales_Order_Status__c != oldSo.Sales_Order_Status__c) {

                    // allow ONLY Stock Reserved → Dispatched
                    if (so.Sales_Order_Status__c == 'Dispatched'
                        && oldSo.Sales_Order_Status__c != 'Stock Reserved') {
                
                        so.addError('Cannot dispatch Sales Order without stock reserved.');
                    }
                  }
                }
            
                if (!salesOrderIds.isEmpty()) {
                    WMS_ValidateProductOnSalesOrder.validateSalesOrderUpdate(salesOrderIds, Trigger.new);
                }
            
            
        }
    }
    
    //After
    if(Trigger.isAfter){
        
        //After Insert
        if(Trigger.isInsert){
            
        }
        //After Update
        if(Trigger.isUpdate){
            
            Set<id>  salesOrderIds = new Set<id>();
            Set<id>  SoidStatus = new Set<id>();
            Set<Id> dispatchedOrderIds = new Set<Id>();
            List<Sales_Order__c> salesOrderList = new List<Sales_Order__c>();
             List<Sales_Order__c> soToUpdate = new List<Sales_Order__c>();
            List<Sales_Order__c> soToUpdate1 = new List<Sales_Order__c>();
            List<Sales_Order__c> soToUpdate2 = new List<Sales_Order__c>();
            List<Sales_Order__c> soToUpdate3 = new List<Sales_Order__c>();
            List<Sales_Order__c> soToUpdate4 = new List<Sales_Order__c>();
            
            for(Sales_Order__c  So : Trigger.new){
                
                salesOrderIds.add(so.id);
                Sales_Order__c oldSo = Trigger.oldMap.get(so.Id);
                
                system.debug('salesOrderIds');
                
                if(so.Sales_Order_Status__c == 'Dispatched' && oldSo.Sales_Order_Status__c == 'Stock Reserved' && so.Is_Dispatched__c == false){
                     salesOrderUpdate.updateSalesOrderStatus(salesOrderIds);
                }
               if (oldSo.Is_Dispatched__c == false && so.Is_Dispatched__c == true) {
                        dispatchedOrderIds.add(so.Id);
                    }
                
               if (!dispatchedOrderIds.isEmpty()) {
                    salesOrderUpdate.updateProductMaster(dispatchedOrderIds);
                }
                
                //sales order retrun flow :Line 74 to 80
                if(oldSo.Sales_Order_Status__c =='Dispatched' && so.Sales_Order_Status__c =='Returned'){
                   salesOrderList.add(so);
                }
                 if(oldSo.Sales_Order_Status__c =='	Stock Reserved' && so.Sales_Order_Status__c =='Cancel'){
                   salesOrderList.add(so);
                }
                  
                if(!salesOrderList.isEmpty()){
                    WMS_returnSalesOrder.returnSalesOrder(salesOrderList);
                }
                
                if( so.Sales_Order_Status__c != oldSo.Sales_Order_Status__c ){
                    SoidStatus.add(so.Id);
                    
                }
                
                if(so.Sales_Order_Status__c =='Dispatched' && oldSo.Sales_Order_Status__c !='Dispatched'){
                     soToUpdate.add( new Sales_Order__c(Id = so.Id));
                }
               
            }
            
            if(!SoidStatus.isEmpty()){
                salesOrderUpdate.updateWMSProductStatus(SoidStatus);
            }
            
            if(!soToUpdate.isEmpty()){
               salesOrderUpdate.updateStockOutDateAndUser(soToUpdate);
            }
            
        }
        
        
    }
}