({
    // doInitHelper : function(component,event){
    //     component.set('v.columns',[
    //          {
    //             label : 'Customer Name',
    //             fieldName : 'Account',
    //             type : 'text',
    //             sortable : true
    //         },
    //         {
    //             label : 'CreditNote No',
    //             fieldName : 'recordId',
    //             type : 'url',
    //             typeAttributes : {label:{fieldName:'recordName'},target:'_blank'}
    //         },
    //         {
    //             label : 'CreditNote Date',
    //             fieldName : 'CreditNoteDate',
    //             type : 'date',
    //             typeAttributes : {year:"2-digit",month:"short",day:"2-digit"},
    //             sortable : true
    //         },
    //         {
    //             label : 'CreditNote Amount',
    //             fieldName : 'Subtotal',
    //             type : 'text',
    //             sortable : true
    //         },
    //         {
    //             label : 'Internal Comments',
    //             fieldName : 'InternalComments',
    //             type : 'text',
    //             sortable : true
    //         },
    //          {
    //             label :'Remarks',
    //             fieldName :'Remarks',
    //             type : 'text',
    //             sortable : true
    //         },
    //         {
    //             label : 'Reason For CreditNote',
    //             fieldName : 'ReasonForCreditnote',
    //             type : 'text',
    //             sortable : true
    //         },
    //          {
    //             label : 'Submitted by',
    //             fieldName : 'submittedBy',
    //             type : 'text',
    //             sortable : true
    //         }
    //     ]);
    //     this.getData(component,event);
    // },
    
    // getData : function(component,event){
    //     var spinner = component.find("spinnerId");
    //     $A.util.toggleClass(spinner, "slds-hide");
    //     var toastRef = $A.get('e.force:showToast');
    //     var action = component.get('c.getSubmittedRecords');
    //     action.setCallback(this,function(response){
    //         var state = response.getState();
    //         if(state == 'SUCCESS'){
    //             var records = response.getReturnValue();
    //             records.forEach(function(record){
    //                record.recordId = '/'+record.recordId;
    //             });
    //              $A.util.toggleClass(spinner, "slds-hide");
    //             if(records.length == 0){
    //                 toastRef.setParams({
    //                     'type' : 'Alert',
    //                     'title' : 'Error',
    //                     'message' : 'No records found',
    //                     'mode' : 'sticky'
    //                 });
    //					toastRef.fire();
    //             }
    //             component.set('v.data',records);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    
    // handleSortingOfRows : function(component,event){
    //     var sortedBy = event.getParam('fieldName');
    //     var sortedDirection = event.getParam('sortDirection');
    //     component.set('v.sortedBy',sortedBy);
    //     component.set('v.sortedDirection',sortedDirection);
    //     this.sortRecords(component,event,helper,sortedBy,sortedDirection);
    // },
    
    // sortRecords : function(component,event,helper,sortedBy,sortedDirection){
    //     var records = component.get('v.data');
    //     var direction = sortedDirection == 'asc' ? 1 : -1;
    //     var fieldValue = function(record){ return record[sortedBy]; }
    //     records.sort(function(record1,record2){
    //         var fieldValue1 = fieldValue(record1);
    //         var fieldValue2 = fieldValue(record2);
    //         return direction * (fieldValue1 > fieldValue2) - (fieldValue2 > fieldValue1);
    //     });
    //     component.set('v.data',records);
    // },
    
    // handleRowSelection : function(component,event,helper){
    //     var rowsSelected = event.getParam('selectedRows');
    //     if(rowsSelected.length > 0){
    //         component.find('approvalButtonId').set('v.disabled',false);
    //         component.find('rejectButtonId').set('v.disabled',false);
    //     }
    //     else{
    //         component.find('approvalButtonId').set('v.disabled',true);
    //         component.find('rejectButtonId').set('v.disabled',true);
    //     }
    // },
    
    // processSelectedRecords : function(component,event,helper,processType){
    //     component.find('approvalButtonId').set('v.disabled',true);
    //     component.find('rejectButtonId').set('v.disabled',true);
    //     var selectedRows = component.find('approvalRecordsTableId').get('v.selectedRows');
    //     var action = component.get('c.processRecords');
    //     action.setParams({
    //         lstWorkItemIds : selectedRows,
    //         processType : processType
    //     });
    //     action.setCallback(this,function(response){
    //         var state = response.getState();
    //         var toastRef = $A.get('e.force:showToast');
    //         if(state == 'SUCCESS'){
    //             var message = response.getReturnValue();
    //             toastRef.fire();
    //             $A.get('e.force:refreshView').fire();
    //         }
    //     });
    //     $A.enqueueAction(action);
    // }
})