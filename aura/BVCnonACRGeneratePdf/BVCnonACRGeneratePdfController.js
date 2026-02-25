({
    generateAndAttachPdf: function(component, event, helper) {
        var action = component.get("c.attachPdfToQuote");
        action.setParams({ quoteId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('PDF has been successfully attached to the quote.');
            } else {
                console.error('Error attaching PDF:', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    doInit: function(component, event, helper) {
        // Initialization logic if needed
    }
})