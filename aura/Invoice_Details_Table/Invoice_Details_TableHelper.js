({
	addRow : function(component,event,helper) {
		var rowValue = component.get("v.ValList");
        rowValue.push({
            "NetWeightCarat":0,
            "ReferenceNumber":"",
            "InvoiceValue":0
        })
        component.set("v.ValList",rowValue);
	}
})