({
    startFlow : function(component, event, helper) {
        var flow = component.find("flowData");
        var recordId = component.get("v.recordId");
        var inputVariables = [
            {
                name: "quoteIDs",
                type: "String",
                value: recordId
            }
        ];
        flow.startFlow("zohoSignAction", inputVariables);
    },

    handleStatusChange: function(component, event) {
        if (event.getParam('status') === "FINISHED") {
            $A.get("e.force:showToast").setParams({
                "title": "Success!",
                "message": "The flow has been executed successfully.",
                "type": "success"
            }).fire();
        }
    }
})