({
    doInit : function(component, event, helper) { 
        console.log('Current recordId :'+component.get("v.recordId"));
        
        var action = component.get('c.getErrorMessageValidation');
         action.setParams({pickupId:component.get("v.recordId")});
        action.setCallback(this,function(resp){
            if (action.getState() === 'SUCCESS')
            {                
                console.log('10 RES :'+resp.getReturnValue());
                component.set("v.isHoliday",resp.getReturnValue());

            } else if (action.getState() === 'ERROR'){
                var errors = action.getError(); 
                console.log('15 Error :'+JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);        
        
    },
    handleSelect : function (component, event, helper) {
     var stepName = event.getParam("detail").value;
     var isHoliday = component.get("v.isHoliday");
        console.log('04 Selected Satge name :'+stepName);
        component.set("v.pickupStage",stepName);
        if(stepName=='Completed' && isHoliday==true)
        {
            component.set("v.showModal",true);
        }
        else
        {
            console.log('33');
            component.set("v.showModal",false); 
            component.set("v.isLoading",true);
            var action = component.get('c.updatePickup');
            action.setParams({ pickupId: component.get("v.recordId"),PickupStage: component.get("v.pickupStage")});    
            action.setCallback(this, function(resp) {
                if (action.getState() === 'SUCCESS') {                
                    console.log('RES :' + resp.getReturnValue());
                    
                    if (resp.getReturnValue() == 'success') {
                        // Show success toast
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The record has been updated successfully.",
                            "type": "success",
                            "mode": "dismissible"
                        });
                        toastEvent.fire();
                        
                        // Redirect to the same or another record page
                        var navEvent = $A.get("e.force:navigateToSObject");
                        navEvent.setParams({
                            "recordId": component.get("v.recordId"), // or another Id
                            "slideDevName": "detail"
                        });
                        // Optional: small delay so toast shows before navigation
                        window.setTimeout(function() {
                            navEvent.fire();
                        }, 500);
                        
                    } else {
                        // Show error toast
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": resp.getReturnValue(),
                            "type": "error",
                            "mode": "dismissible"
                        });
                        toastEvent.fire();
                    }
                } else if (action.getState() === 'ERROR') {
                    var errors = action.getError(); 
                    console.log('Error :' + errors);
                }
                component.set("v.isLoading",false);
            });
            
            $A.enqueueAction(action);
        }
    },

continueUpdate : function (component,event,helper) {
    component.set("v.showModal",false);  
    component.set("v.isLoading",true);
    var action = component.get('c.updatePickup');
    action.setParams({ pickupId: component.get("v.recordId"),PickupStage: component.get("v.pickupStage")});    
    action.setCallback(this, function(resp) {
        if (action.getState() === 'SUCCESS') {                
            console.log('RES :' + resp.getReturnValue());
            
            if (resp.getReturnValue() == 'success') {
                // Show success toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type": "success",
                    "mode": "dismissible"
                });
                toastEvent.fire();

                // Redirect to the same or another record page
                var navEvent = $A.get("e.force:navigateToSObject");
                navEvent.setParams({
                    "recordId": component.get("v.recordId"), // or another Id
                    "slideDevName": "detail"
                });
                // Optional: small delay so toast shows before navigation
                window.setTimeout(function() {
                    navEvent.fire();
                }, 500);

            } else {
                // Show error toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": resp.getReturnValue(),
                    "type": "error",
                    "mode": "dismissible"
                });
                toastEvent.fire();
            }

        } else if (action.getState() === 'ERROR') {
            var errors = action.getError(); 
            console.log('Error :' + errors);
        }
        component.set("v.isLoading",false);
    });

    $A.enqueueAction(action); 
},
    closeModal : function (cmp,event,helper)
    {
        cmp.set("v.showModal",false);
        helper.redirectTo(cmp, event, helper);
    },
    
})