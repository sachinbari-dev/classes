({
	redirectTo : function(component,event,helper) {
		var recordId = component.get("v.recordId");
        console.log('444444 recordId :'+recordId);
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail" // options: detail, related
        });
        navEvent.fire();
        console.log('11111111 recordId :'+recordId);
	}
})