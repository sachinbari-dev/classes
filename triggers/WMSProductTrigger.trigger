trigger WMSProductTrigger on WMS_Products__c (before insert,before update,after insert,after update,after delete){
   
    if (Trigger.isBefore && Trigger.isInsert) {
        for (WMS_Products__c wp : Trigger.new) {

          
            if (wp.Serial_Number__c != null) {
                wp.Closing_Stock__c = 1;
                wp.Serial_Number_Search__c =
                    wp.Serial_Number__c.substring(0, Math.min(255, wp.Serial_Number__c.length()));
            } else {
                wp.Serial_Number_Search__c = null;
            }

            if (wp.Batch_Number__c != null) {
                wp.Batch_Number_Search__c =
                    wp.Batch_Number__c.substring(0, Math.min(255, wp.Batch_Number__c.length()));
            } else {
                wp.Batch_Number_Search__c = null;
            }

        
            if (wp.Serial_Number__c != null) {
                /*if (wp.Purchase_Order__c != null && wp.Sales_Order__c == null) {
                    List<String> slNoList = wp.Serial_Number__c.split(',');
                    String res = WMSProductSerialNumberValidation.validateNumbers(slNoList);
                    if (res != null) {
                        wp.Serial_Number__c.addError('Error :' + res);
                    }
                }  
                if (wp.Purchase_Order__c == null && wp.Sales_Order__c != null) {
                    List<String> slNoList = wp.Serial_Number__c.split(',');
                    String res = WMSProductSerialNumberValidation.validateSalesOrderNumbers(slNoList);
                    if (res != null) {
                        wp.Serial_Number__c.addError('Error :' + res);
                    }
                }*/
            }
        }
    }

    
    if (Trigger.isBefore && Trigger.isUpdate) {
        
        // lock WMS product for dispatch
        
          wmsProductHelper.lockDispatchedProducts(Trigger.new,Trigger.oldMap);
        
        for (WMS_Products__c wp : Trigger.new) {
            WMS_Products__c oldRec = Trigger.oldMap.get(wp.Id);
                 
            if(wp.Serial_Number__c != null && wp.Closing_Stock__c == 1 && wp.Sales_Order__c != null){
                wp.Closing_Stock__c = 0;
            }
          
            if (wp.Serial_Number__c != oldRec.Serial_Number__c) {
                if (wp.Serial_Number__c != null) {
                    wp.Serial_Number_Search__c =
                        wp.Serial_Number__c.substring(0, Math.min(255, wp.Serial_Number__c.length()));
                } else {
                    wp.Serial_Number_Search__c = null;
                }
            }

            if (wp.Batch_Number__c != oldRec.Batch_Number__c) {
                if (wp.Batch_Number__c != null) {
                    wp.Batch_Number_Search__c =
                        wp.Batch_Number__c.substring(0, Math.min(255, wp.Batch_Number__c.length()));
                } else {
                    wp.Batch_Number_Search__c = null;
                }
            }
           // added as WMS 2.0 part to avoid series update for verified PO. 
            if(wp.Serial_Number__c != oldRec.Serial_Number__c){
                string error = wmsProductHelper.avoidSeriesUpdate(Trigger.new);
                if(error != null){
                   wp.Serial_Number__c.addError(error); 
                }
                
            }
        }
    }

   
    if (Trigger.isAfter && Trigger.isInsert) {
        wmsProductHelper.afterInsert(Trigger.new);
        wms_ProductHelperForSO.multiProductUpdateOnSO(Trigger.new);
        wmsProductHelper.updatePOProductCount(Trigger.new,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
        
      
    }

    
    if (Trigger.isAfter && Trigger.isUpdate) {
        wmsProductHelper.CalculateValues(Trigger.newMap, Trigger.oldMap, 'update');
       wmsProductHelper.updatePOProductCount(Trigger.new,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
    }

   
}