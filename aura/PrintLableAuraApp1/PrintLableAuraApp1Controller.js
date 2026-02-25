({
    doInit : function(component, event, helper) {
        document.title = "TMS_ShippingPdfPage"; // <-- custom name
        const url = new URL(window.location.href);
        const recId = url.searchParams.get("recordId");
        component.set("v.recordId", recId);
        console.log('recordId :'+recId);
    },
    printPage : function() {
        window.print();
    }
})