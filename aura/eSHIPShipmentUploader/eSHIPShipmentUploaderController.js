({
    onTableImport: function (cmp, evt, helper) {
        helper.disableExcelInput(cmp,evt);
        helper.importTableAndThrowEvent(cmp, evt, helper);
    }
})

/*({
    onTableImport: function (cmp, evt, helper) {
        try {
            helper.disableExcelInput(cmp, evt);
            helper.importTableAndThrowEvent(cmp, evt, helper);
        } catch (error) {
            console.error("Error in onTableImport: ", error);
            // Show a user-friendly error message
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    "title": "Error",
                    "message": "An unexpected error occurred. Please try again.",
                    "type": "error"
                });
                toastEvent.fire();
            } else {
                alert("An unexpected error occurred. Please check the console for details.");
            }
        }
    }
})*/