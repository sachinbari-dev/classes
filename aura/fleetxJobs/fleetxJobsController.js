({
    getFleetXDriver: function(component, event, helper) {
        helper.proceeds(component, event, 'FleetXDriver');
    },
    getFleetXGunMen: function(component, event, helper) {
        helper.proceeds(component, event, 'FleetXGunMen');
    },
    getFleetX_Escorter: function(component, event, helper) {
        helper.proceeds(component, event, 'FleetX_Escorter');
    },
    createdRecord: function(component, event, helper) {
        var vehicleNumber = component.get("v.vehicleNumber");
        var CurrencyIsoCode = component.get("v.CurrencyIsoCode");
        var integrationstatus = component.get("v.integrationstatus");
        var startDateTime = component.get("v.startDateTime");
        var lastModifiedDate = component.get("v.lastModifiedDate");
        var FleetX_RoutesName = component.get("v.FleetX_RoutesName");
        var scheduleDeparture = component.get("v.scheduleDeparture");
        var scheduleArrival = component.get("v.scheduleArrival");
        var FleetXJobID = component.get("v.FleetXJobID") || ''; // Default value if undefined
        
        var Daddresses = component.get("v.finalString");
        var GMaddresses = component.get("v.gmfinalString");
        var ESaddresses = component.get("v.esfinalString");
        
        var Dids = component.get("v.Id_List");
        var GMids = component.get("v.gmId_List");
        var ESids = component.get("v.esId_List");
        
        var addresses = component.get("v.D_List");
        // var addresses1 = component.get("v.points1");
        var finalString = component.get("v.finalString");
        console.log('Inside Create record 1111');
        var RNAME = component.get("v.rName");
        var idlist = component.get("v.Id_List");
        console.log('Daddresses :' + Daddresses);
        console.log('GMaddresses :' + GMaddresses);
        console.log('ESaddresses :' + ESaddresses);
        
        console.log('Dids :' + Dids);
        console.log('GMids :' + GMids);
        console.log('ESids :' + ESids);
        
        if (Daddresses != null && GMaddresses != null && ESaddresses != null &&
            vehicleNumber != null && startDateTime != null && scheduleArrival != null &&
            scheduleDeparture != null && FleetX_RoutesName != null) {
            console.log('CREATE RECORD');
            var action = component.get('c.saveFleetxAddress');
            
            action.setParams({
                DAddresses: Daddresses,
                GMAddresses: GMaddresses,
                ESAddresses: ESaddresses,
                Didlist: Dids,
                GMidlist: GMids,
                ESidlist: ESids,
                vehicleNumber: vehicleNumber,
                CurrencyIsoCode: CurrencyIsoCode,
                integrationstatus: integrationstatus,
                startDateTime: startDateTime,
                lastModifiedDate: lastModifiedDate,
                FleetX_RoutesName: FleetX_RoutesName,
                scheduleDeparture: scheduleDeparture,
                scheduleArrival: scheduleArrival,
                FleetXJobID: FleetXJobID
            });
            
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(response) {
                
                if (response.getState() == 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log("Result1 :" + result);
                    if (result != null) {
                        // Introduce a 2-second delay
                        setTimeout(function(){
                            // Code to be executed after the delay
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "FleetXJob " + result.Name + " Created Successfully.",
                                "type": "success"
                            });
                            toastEvent.fire();
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/lightning/o/FleetXJob__c/list?filterName=Recent"
                            });
                            urlEvent.fire();
                            
                        }, 2000); // 2000 milliseconds = 2 seconds
                        
                        
                    } else {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Error While Creating the Record"
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})