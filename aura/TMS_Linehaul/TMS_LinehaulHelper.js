/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-22-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-17-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
({
  callAddBox: function(component, forceFlag) {
        var selectedSeal = component.get("v.SelectedSeal");
        var selectedRightSeal = component.get("v.SelectedRightSeal");
        var action = component.get("c.AddBox");

        action.setParams({
            "BagWrapJson": JSON.stringify(component.get("v.BagList")),
            "seal": selectedSeal ? selectedSeal.text : '',
            "rseal": selectedRightSeal ? selectedRightSeal.text : '',
            "rightSealId": selectedRightSeal ? selectedRightSeal.val : '',
            "SealId": selectedSeal ? selectedSeal.val : '',
            "Dest": component.get("v.SelectedDest"),
            "overbags": component.get("v.simplenewOversizeBag"),
            "overtrunks": component.get("v.simplenewOversizeTrunk"),
            "airTrunk": component.get("v.simpleAirlineTrunk"),
            "trunk": component.get("v.SelectedTrunk") ? component.get("v.SelectedTrunk").text : '',
            "trunkId": component.get("v.SelectedTrunk") ? component.get("v.SelectedTrunk").val : '',
            "force": forceFlag
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();

                if (res.requiresConfirmation) {
                    // show SLDS modal
                    component.set("v.confirmMessage", res.message || 'Are you sure you want to continue?');
                    component.set("v.showConfirmModal", true);
                    return;
                }

                if (res.success) {
                    component.set("v.BagList", res.bagWrapList);
                    component.set("v.SelectedSeal", null);
                    component.set("v.SelectedRightSeal", null);
                    component.set("v.SelectedDest", '');
                    component.set("v.simplenewOversizeBag", '');
                    component.set("v.simplenewOversizeTrunk", '');
                    component.set("v.simpleAirlineTrunk", '');
                    component.set("v.SelectedTrunk", null);
                    component.set("v.showModal", false);
                    this.showToast("Success!", res.message || "Airline Package added successfully.", "success");
                } else {
                    this.showToast("Error!", res.message || "Unknown server error", "error");
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.error("Apex Error:", message);
                this.showToast("Error!", message, "error");
            }
        }.bind(this));

        $A.enqueueAction(action);
    },
    
    saveBoxHelper: function(component, event, helper) {
          component.set("v.showContinueButton", false);
        var s = component.get("v.SelectedSeal");
        var s1 = component.get("v.SelectedRightSeal");
        var destination = component.get("v.SelectedDest");
        var oversizebags = component.get("v.simplenewOversizeBag");
        var oversizebtrunks = component.get("v.simplenewOversizeTrunk");
        var airlineTrunk = component.get("v.simpleAirlineTrunk");
        var trValue = component.get("v.TrunkVal");
        var selectedCount = component.get("v.selectedCount");
        var ScanselectedCount = component.get("v.ScanselectedCount");
        var SrchselectedCount = component.get("v.SearchselectedCount");
        var limit = 50;
        var destinationValue = "";
        var oversizeValue = "";
        var oversizeTrunkValue = "";
        var airlinetrValue = "";
        var sval = '';
        var stext = '';
        var ttext = '';
        var tval = '';
        var rval = '';
        var rtext = '';

        var isError = false;

        if (selectedCount <= limit && ScanselectedCount <= limit && SrchselectedCount <= limit) {
            if (s1 !== null && JSON.stringify(s1) === JSON.stringify(s)) {
                isError = true;
                helper.showToast("Error!", "Select different seal ID for each seal", "error");
                return;
            } else if (s1 === null && s !== null) {
                sval = s.val;
                stext = s.text;
            } else if ((s === null && destination === null) || (s === null && destination !== null) || (s !== null && destination === null)) {
                helper.showToast("Error!", "Next destination, Left seal and Airline Package are mandatory", "error");
                return;
            } else {
                rval = s1 ? s1.val : '';
                rtext = s1 ? s1.text : '';
                sval = s ? s.val : '';
                stext = s ? s.text : '';
            }

            if (trValue !== null && trValue !== undefined && trValue !== 'None' && trValue !== '') {
                if (trValue === 'TRUNK') {
                    var tempTrunk = component.get("v.SelectedTrunk");
                    if (tempTrunk !== null && tempTrunk !== undefined) {
                        tval = tempTrunk.val;
                        ttext = tempTrunk.text;
                    } else {
                        helper.showToast("Error!", "Please Select Trunk", "error");
                        return;
                    }
                }

                if (oversizebags !== null && oversizebags !== undefined) {
                    oversizeValue = oversizebags;
                }

                if (oversizebtrunks !== null && oversizebtrunks !== undefined) {
                    oversizeTrunkValue = oversizebtrunks;
                }

                if (airlineTrunk !== null && airlineTrunk !== undefined) {
                    airlinetrValue = airlineTrunk;
                }
            } else {
                isError = true;
            }

            if (destination !== null && destination !== undefined && destination !== "") {
                destinationValue = destination;
            } else {
                isError = true;
            }

            if (isError) {
                helper.showToast("Error!", "Next Destination, Airline Packages, and Left Secure Seal are required", "error");
            } else {
                component.set("v.showModal", false);
                // initial call force = false
                helper.callAddBox(component, false);
            }
        } else {
            helper.showToast("Error!", "Selection limit reached. You can select a maximum of 50 bags only.", "error");
            return;
        }
    },
   // calladdboxdraft

callAddBoxDraft: function(component,forceFlag) {
        var selectedSeal = component.get("v.SelectedSeal");
        var selectedRightSeal = component.get("v.SelectedRightSeal");
        var action = component.get("c.AddBoxDraft");
        
        action.setParams({
            "BagWrapJson": JSON.stringify(component.get("v.BagList")),
            "seal": selectedSeal ? selectedSeal.text : '',
            "rseal": selectedRightSeal ? selectedRightSeal.text : '',
            "rightSealId": selectedRightSeal ? selectedRightSeal.val : '',
            "SealId": selectedSeal ? selectedSeal.val : '',
            "Dest": component.get("v.SelectedDest"),
            "overbags": component.get("v.simplenewOversizeBag"),
            "overtrunks": component.get("v.simplenewOversizeTrunk"),
            "airTrunk": component.get("v.simpleAirlineTrunk"),
            "trunk": component.get("v.SelectedTrunk") ? component.get("v.SelectedTrunk").text : '',
            "trunkId": component.get("v.SelectedTrunk") ? component.get("v.SelectedTrunk").val : '',
            "force": forceFlag
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();

                if (res.requiresConfirmation) {
                    // show SLDS modal
                    component.set("v.confirmMessage", res.message || 'Are you sure you want to continue?');
                    component.set("v.showConfirmModal", true);
                    return;
                }

                if (res.success) {
                    component.set("v.BagList", res.bagWrapList);
                    component.set("v.SelectedSeal", null);
                    component.set("v.SelectedRightSeal", null);
                    component.set("v.SelectedDest", '');
                    component.set("v.simplenewOversizeBag", '');
                    component.set("v.simplenewOversizeTrunk", '');
                    component.set("v.simpleAirlineTrunk", '');
                    component.set("v.SelectedTrunk", null);
                    component.set("v.showModal", false);
                     component.set("v.reFreshList", true);
                   
                    this.showToast("Success!", res.message || "Airline Package added successfully.", "success");
                     
                    
                } else {
                    this.showToast("Error!", res.message || "Unknown server error", "error");
                }
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                console.error("Apex Error:", message);
                this.showToast("Error!", message, "error");
            }
        }.bind(this));

        $A.enqueueAction(action);
        
    },
 
   saveAsDraftBoxHelper: function(component, event, helper) {
        // This block mirrors your existing validations — kept intact.
        component.set("v.showContinueButton", true);
        var s = component.get("v.SelectedSeal");
        var s1 = component.get("v.SelectedRightSeal");
        var destination = component.get("v.SelectedDest");
        var oversizebags = component.get("v.simplenewOversizeBag");
        var oversizebtrunks = component.get("v.simplenewOversizeTrunk");
        var airlineTrunk = component.get("v.simpleAirlineTrunk");
        var trValue = component.get("v.TrunkVal");
        var selectedCount = component.get("v.selectedCount");
        var ScanselectedCount = component.get("v.ScanselectedCount");
        var SrchselectedCount = component.get("v.SearchselectedCount");
        var limit = 50;
        var destinationValue = "";
        var oversizeValue = "";
        var oversizeTrunkValue = "";
        var airlinetrValue = "";
        var sval = '';
        var stext = '';
        var ttext = '';
        var tval = '';
        var rval = '';
        var rtext = '';

        var isError = false;

        if (selectedCount <= limit && ScanselectedCount <= limit && SrchselectedCount <= limit) {
            if (s1 !== null && JSON.stringify(s1) === JSON.stringify(s)) {
                isError = true;
                helper.showToast("Error!", "Select different seal ID for each seal", "error");
                return;
            } else if (s1 === null && s !== null) {
                sval = s.val;
                stext = s.text;
            } else if ((s === null && destination === null) || (s === null && destination !== null) || (s !== null && destination === null)) {
                helper.showToast("Error!", "Next destination, Left seal and Airline Package are mandatory", "error");
                return;
            } else {
                rval = s1 ? s1.val : '';
                rtext = s1 ? s1.text : '';
                sval = s ? s.val : '';
                stext = s ? s.text : '';
            }

            if (trValue !== null && trValue !== undefined && trValue !== 'None' && trValue !== '') {
                if (trValue === 'TRUNK') {
                    var tempTrunk = component.get("v.SelectedTrunk");
                    if (tempTrunk !== null && tempTrunk !== undefined) {
                        tval = tempTrunk.val;
                        ttext = tempTrunk.text;
                    } else {
                        helper.showToast("Error!", "Please Select Trunk", "error");
                        return;
                    }
                }

                if (oversizebags !== null && oversizebags !== undefined) {
                    oversizeValue = oversizebags;
                }

                if (oversizebtrunks !== null && oversizebtrunks !== undefined) {
                    oversizeTrunkValue = oversizebtrunks;
                }

                if (airlineTrunk !== null && airlineTrunk !== undefined) {
                    airlinetrValue = airlineTrunk;
                }
            } else {
                isError = true;
            }

            if (destination !== null && destination !== undefined && destination !== "") {
                destinationValue = destination;
            } else {
                isError = true;
            }

            if (isError) {
                helper.showToast("Error!", "Next Destination, Airline Packages, and Left Secure Seal are required", "error");
            } else {
                component.set("v.showModal", false);
                // initial call force = false
                helper.callAddBoxDraft(component,false);
            }
        } else {
            helper.showToast("Error!", "Selection limit reached. You can select a maximum of 50 bags only.", "error");
            return;
        }
      
    },

    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type,
                mode: 'dismissible'
            });
            toastEvent.fire();
        } else {
            alert(title + ': ' + message);
        }
    },
  
    
    doInitHelper: function (component, event, helper) {
        window.console.log('====doInitHelper====');
        component.set("v.pageNum",1);
        component.set("v.Filter","Inbound"); 
        var timezone = $A.get("$Locale.timezone");
       
        // Returns the date string in the format "2022-11-04"
        $A.localizationService.getToday(timezone, function(today){
            component.set("v.FlightDateTime", today);
        });
        
        var hubObj = component.get("v.SelHub");
        var hubval = '';
        if(hubObj !== null){
            hubval = hubObj.text;
        }
        var action = component.get("c.Shipments");
        action.setParams({
            "filter":"Inbound",
            "Hub":hubval
        });
        
        var origin = component.get("v.OriginCity");
        var dest = component.get("v.DestCity");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var err = response.getReturnValue().error;
                component.set("v.ShipmentList", response.getReturnValue().lineHaulWrapList);
                component.set("v.ShowHub", response.getReturnValue().showHubFilter);
                if(err ==""){
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            } else {
                console.log("list: Error ");
            }
        }); 
        $A.enqueueAction(action);
        
        
        
        this.focusTimerStart(component);
    },
    handleSelectHelper : function(component, event, helper){
        console.log('===== ',component.find("select").get("v.value"));
        component.set("v.Filter",component.find("select").get("v.value"));
        var filt = component.get("v.Filter");
        if(filt =="Outbound"){
            component.set("v.DisableAddBox",false);
            component.set("v.DisableScan",false);
            component.set("v.DisableAddLineHaul",false);
            component.set("v.DisableRemove",true);
            //component.set("v.DisableAddDest",false);
            component.set("v.DisableSaveDraft",false);
        }else if(filt =="Inbound"){
            component.set("v.DisableAddBox",true);
             component.set("v.DisableScan",true);
            component.set("v.DisableAddLineHaul",true);
            component.set("v.DisableRemove",true);
            //component.set("v.DisableAddDest",true);
            component.set("v.DisableSaveDraft",true);
        }else if(filt =="Finalised"){
            component.set("v.DisableAddBox",true);
             component.set("v.DisableScan",true);
            component.set("v.DisableAddLineHaul",true);
              component.set("v.DisableRemove",true);
            //component.set("v.DisableAddDest",false);
            component.set("v.DisableSaveDraft",false);
        }
        var hubObj = component.get("v.SelHub");
        var hubval = '';
        if(hubObj !== null){
            hubval = hubObj.text;
        }
        var action = component.get("c.Shipments");
        action.setParams({
            "filter":component.find("select").get("v.value"),
            "Hub":hubval
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var err = response.getReturnValue().error;
                component.set("v.ShipmentList", response.getReturnValue().lineHaulWrapList);
                component.set("v.ShowHub", response.getReturnValue().showHubFilter);
                if(err ==""){
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            } else {
                console.log("list: Error ");
            }
        });
        $A.enqueueAction(action);
        
       
    },
    
    AddToLineHaulHelper : function(component, event, helper){
        
        var shipList = component.get("v.BagList");
        var LineHaulType = shipList[0].sb.Linehaul_Type__c;
       
        var fnlNum;
        
        var selectedCount = component.get("v.selectedCount");
        var ScanselectedCount = component.get("v.ScanselectedCount");
        var SrchselectedCount = component.get("v.SearchselectedCount");                         
        var limit = 50;
       
        console.log('selectedCount'+selectedCount);
        console.log('ScanselectedCount'+ScanselectedCount);
        console.log('SrchselectedCount'+SrchselectedCount);
        
        
        
        if (selectedCount <= limit && ScanselectedCount <= limit && SrchselectedCount <= limit) {
                
            console.log("in add to line");
            var action = component.get("c.AddBagToLineHaul");
            action.setParams({
                "BagWrapJson": JSON.stringify(shipList)

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue().options;
                var err = response.getReturnValue().error;
                var fnlBag = response.getReturnValue().finalBag;
                fnlNum = response.getReturnValue().FinalizedLHNumber;
                
                if(err==""){
                    component.set("v.pageNum",3);
                    var BPval = [];
                    for(var key in result){
                        BPval.push({key: key, value: result[key]});
                    }
                    component.set("v.picklistVal", BPval);
                    console.log("fnlBag",fnlBag);        
                    component.set("v.Airport",response.getReturnValue().Originport);
                    component.set("v.DestAirport",response.getReturnValue().Destport);
                    component.set("v.FlightSchedule",response.getReturnValue().Flight);
                    component.set("v.Vehicle",response.getReturnValue().Vehicle);
                    if(response.getReturnValue().haulType !==undefined){
                        LineHaulType = response.getReturnValue().haulType;
                    }
                    if(fnlBag !==undefined){
                        component.set("v.finalisedNumber",fnlBag.Finalised_Linehaul_Number__c);
                        component.set("v.FlightDateTime",fnlBag.Flight_Date_Time__c);
                    }
                    
                    component.set("v.finalisedNumberRoad",fnlNum);
                  
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                
            }
            window.setTimeout(
                $A.getCallback( function() {
                    if(fnlBag !==undefined){
                        component.set("v.LineHaulType",fnlBag.Linehaul_Type__c);
                    }
                    // Now set our preferred value
                    //component.find("a_opt").set("v.value", accounts[4].Id);
                }));
        });
              $A.enqueueAction(action);
       }else{
           helper.showToast("Error!", "Selection limit reached. You can select a maximum of 50 bags only.", "error");
            return;      
      }
        
    },
    
     AddToLineHaulDraftHelper : function(component, event, helper){
       
             
        var shipList = component.get("v.DraftBagList");
         console.log('shipList:', JSON.stringify(shipList));
        var LineHaulType = shipList[0].sb.Linehaul_Type__c;
       
        var fnlNum;
        
        var selectedCount = component.get("v.selectedCount");
        var ScanselectedCount = component.get("v.ScanselectedCount");
        var SrchselectedCount = component.get("v.SearchselectedCount");                         
        var limit = 50;
       
        console.log('selectedCount'+selectedCount);
        console.log('ScanselectedCount'+ScanselectedCount);
        console.log('SrchselectedCount'+SrchselectedCount);
        
        
        
        if (selectedCount <= limit && ScanselectedCount <= limit && SrchselectedCount <= limit) {
                
            console.log("in add to line");
            var action = component.get("c.AddBagToLineHaulDraft");
            action.setParams({
                "BagWrapJson": JSON.stringify(shipList)

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue().options;
                var err = response.getReturnValue().error;
                var fnlBag = response.getReturnValue().finalBag;
                fnlNum = response.getReturnValue().FinalizedLHNumber;
                
                if(err==""){
                    component.set("v.pageNum",3);
                    var BPval = [];
                    for(var key in result){
                        BPval.push({key: key, value: result[key]});
                    }
                    component.set("v.picklistVal", BPval);
                    console.log("fnlBag",fnlBag);        
                    component.set("v.Airport",response.getReturnValue().Originport);
                    component.set("v.DestAirport",response.getReturnValue().Destport);
                    component.set("v.FlightSchedule",response.getReturnValue().Flight);
                    component.set("v.Vehicle",response.getReturnValue().Vehicle);
                    if(response.getReturnValue().haulType !==undefined){
                        LineHaulType = response.getReturnValue().haulType;
                    }
                    if(fnlBag !==undefined){
                        component.set("v.finalisedNumber",fnlBag.Finalised_Linehaul_Number__c);
                        component.set("v.FlightDateTime",fnlBag.Flight_Date_Time__c);
                    }
                    
                    component.set("v.finalisedNumberRoad",fnlNum);
                  
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: err,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                
            }
            window.setTimeout(
                $A.getCallback( function() {
                    if(fnlBag !==undefined){
                        component.set("v.LineHaulType",fnlBag.Linehaul_Type__c);
                    }
                    // Now set our preferred value
                    //component.find("a_opt").set("v.value", accounts[4].Id);
                }));
        });
              $A.enqueueAction(action);
       }else{
           helper.showToast("Error!", "Selection limit reached. You can select a maximum of 50 bags only.", "error");
            return;      
      }
        
        
    },
  
    
    saveAsDraftHelper : function(component, event, helper){

        console.log('[debug] showDraftBags called');
        var action = component.get("c.getDraftBags"); // make sure this method exists in Apex

        // safety: null-check
        if (!action) {
            console.error('[debug] Apex action getDraftBags not found on server controller');
            return;
        }

        action.setCallback(this, function(response) {
            try {
                var state = response.getState();
                console.log('[debug] Apex response state =', state);

             
                console.log('[debug] raw response object:', response);

                if (state === "SUCCESS") {
                    var ret = response.getReturnValue();
                 
                    console.log('[debug] returnValue (raw):', ret);
                    console.log('[debug] typeof returnValue =', typeof ret);
                    var count = (ret && ret.length) ? ret.length : 0;
                    console.log('[debug] Draft bag count =', count);

                   
                    if (count > 0) {
                        try {
                            console.log('[debug] first item JSON:', JSON.stringify(ret[0], null, 2));
                            if (count > 1) {
                                console.log('[debug] second item JSON:', JSON.stringify(ret[1], null, 2));
                            }
                        } catch (e) {
                            console.warn('[debug] stringify failed', e);
                        }
                    }

                  
                    if (Array.isArray(ret)) {
                        component.set("v.DraftBagList", ret);
                        console.log('[debug] DraftBagList set and modal opened');
                    } else {
                        console.warn('[debug] returnValue is not an array — not setting DraftBagList', ret);
                        
                        component.set("v.DraftBagList", []);
                        component.set("v.pageNum",4);
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error('[debug] Apex ERROR:', errors);
                   
                    if (errors && errors.length) {
                        for (var i=0; i<errors.length; i++) {
                            console.error('[debug] error', i, errors[i]);
                        }
                    }
                    
                    alert('Error fetching draft bags. Check console for details.');
                } else if (state === "INCOMPLETE") {
                    console.warn('[debug] Apex response INCOMPLETE. Possibly network issue or offline.');
                    alert('Request incomplete. Check network or Salesforce session.');
                } else {
                    console.warn('[debug] Unexpected state:', state, response);
                }
            } catch (ex) {
                console.error('[debug] unexpected exception in callback:', ex);
            }
        });

        $A.enqueueAction(action);
        console.log('[debug] action enqueued');
    },  
      SecureBagsHelperdraft : function(component, event, helper){
        
        console.log("======== Shipment =======", component.get("v.ShipmentList"));
        let shipment = component.get("v.ShipmentList");
        var selectedBags = [];
        var checkboxes = component.find("BagPack");
        var selectedCount = 0;
       console.log('checkboxes'+ checkboxes);
        
        for (var i= 0 ; i < shipment.length ; i++){
            if(shipment[i].process == true){
               
                for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                    if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                        selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                            return currentValue
                        }));
                        

                    }else {
                        selectedBags.push(Object.values(shipment[i].BagList)[j]);
                        
                      
                    }
                }
            }
        }
    
        console.log("===== selectedBags ===",selectedBags);
        var action = component.get("c.SecureBagsList");
        action.setParams({
            "BagList": selectedBags
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              //  component.set("v.DraftBagList", response.getReturnValue().BagWrapList);
             //   console.log("success: ",component.get("v.DraftBagList"));
                 
                var result = response.getReturnValue().BranchOptions;
                var BPval = [];
                for(var key in result){
                    BPval.push({key: key, value: result[key]});
                }
                component.set("v.CityVal", BPval);
                
                
            }
        }); 
        $A.enqueueAction(action);
      },
  
    SecureBagsHelper : function(component, event, helper){
        component.set("v.pageNum", 2);
        console.log("======== Shipment =======", component.get("v.ShipmentList"));
        let shipment = component.get("v.ShipmentList");
        var selectedBags = [];
        var checkboxes = component.find("BagPack");
        var selectedCount = 0;
       console.log('checkboxes'+ checkboxes);
        
        for (var i= 0 ; i < shipment.length ; i++){
            if(shipment[i].process == true){
               
                for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                    if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                        selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                            return currentValue
                        }));
                        

                    }else {
                        selectedBags.push(Object.values(shipment[i].BagList)[j]);
                        
                      
                    }
                }
            }
        }
    
        console.log("===== selectedBags ===",selectedBags);
        var action = component.get("c.SecureBagsList");
        action.setParams({
            "BagList": selectedBags
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.BagList", response.getReturnValue().BagWrapList);
                console.log("success: ",component.get("v.BagList"));
                
                var result = response.getReturnValue().BranchOptions;
                var BPval = [];
                for(var key in result){
                    BPval.push({key: key, value: result[key]});
                }
                component.set("v.CityVal", BPval);
                
                
            }
        }); 
        $A.enqueueAction(action);
        

        
        //added by govind from line 355 to 377
        
        var action = component.get("c.SecureBagsBVCTrunkList");
        action.setParams({
            "BagList": selectedBags
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.BagList", response.getReturnValue().BagWrapList);
                console.log("success: ",component.get("v.BagList"));
                
                var result = response.getReturnValue().BranchOptions;
                var BPval = [];
                for(var key in result){
                    BPval.push({key: key, value: result[key]});
                }
                component.set("v.TrunkVals", BPval);
            }
        }); 
        $A.enqueueAction(action);
        
    },
   
    
  FilterBagDraftHelper : function(component, event, helper) {
      var dest = component.get("v.FilterDestDraft");
      var seal = component.get("v.FilterSealDraft");
      var cargo = component.get("v.FilterCargoDraft");
      console.log('destination' + dest);
      console.log('seal' + seal);
      console.log('cargo' + cargo);
      
       var action = component.get("c.getDraftBagsfiltered");
        action.setParams({
            "destination": dest,
            "seal":component.get("v.FilterSealDraft"),
            "cargo":cargo
        });
       action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.DraftBagList", response.getReturnValue());
                console.log("success: ",component.get("v.DraftBagList"));
            }
        }); 
        $A.enqueueAction(action);
      
  },
    
    FilterBagHelper : function(component, event, helper){
        //helper.SecureBagsHelper(component, event, helper);
        console.log("filter bag");
        var d = component.get("v.FilterDest");
        var s = component.get("v.FilterSeal");
        var c = component.get("v.FilterCargo");
        
        let shipment = component.get("v.ShipmentList");
        var selectedBags = [];
        
        for (var i= 0 ; i < shipment.length ; i++){
            if(shipment[i].process == true){
                for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                    if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                        selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                            return currentValue
                        }));
                    }else {
                        selectedBags.push(Object.values(shipment[i].BagList)[j]);
                    }
                }
            }
        }
        
        var action = component.get("c.FilteredBagList");
        action.setParams({
            "bags":selectedBags,
            "Dest":d,
            "SealId":s,
            "CargoType":c
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.BagList", response.getReturnValue());
                console.log("success: ",component.get("v.BagList"));
            }
        }); 
        $A.enqueueAction(action);
    },
   
    SaveHelper : function(component, event, helper){
        var isDraftContext = component.get("v.isDraftContext");
        var selectedList = [];
        console.log('drfat flag' +isDraftContext );
         if (isDraftContext) {
                selectedList = component.get("v.DraftBagList") || [];
                console.log('1Finalize called from DRAFT context. Bags:', selectedList.length);
            } else {
                selectedList = component.get("v.BagList") || [];
                console.log('2Finalize called from NORMAL context. Bags:', selectedList.length);
            }
          selectedList = selectedList.filter(b => b && b.process === true);

        if (selectedList.length === 0) {
            helper.showToast("Warning", "No bags selected for finalization.", "warning");
            return;
        }
        
        var bagJson = JSON.stringify(selectedList);
    console.log('BagWrapJson payload:', bagJson);
        
        
        var airFL = component.get("v.finalisedAirNumber");
        var originVal = component.get("v.Airport");
        var desitnationVal = component.get("v.DestAirport");
        var airlineName = component.find("arlList").get("v.value");
        var comCodeName = component.find("comCode").get("v.value");
        var flightDateTime = component.get("v.FlightDateTime");
        var ltype =component.get("v.LineHaulType");
        var filt = component.get("v.Filter");
        console.log("Filter Value is ",filt);
        var action = component.get("c.SaveProcess");
        console.log("Action of helper class ",action);
        console.log("Num: from helper "+component.get("v.finalisedNumber"));
        var fli = (component.get("v.FlightSchedule"));
        console.log("for checking fli "+fli);
        /*var veh = (component.get("v.Vehicle"));
		console.log("for checking fli "+veh);*/
        var flival = '';
        if(fli !== null && fli !==undefined)
            flival = fli.val;        
        /*var vehval = '';
        if(veh !== null && veh !==undefined)
            vehval = veh.val;  
        var vehtext = '';
        if(veh !== null && veh !==undefined)
            vehtext = veh.text;*/
        console.log('for checking Before setting parameters');
        
        
        
        if( airlineName != null && airlineName != '--Select a Value--' && airlineName != undefined ){
            
            action.setParams({
            "BagWrapJson":bagJson,
            "LHType": (component.get("v.LineHaulType")),
            "LHNumber":(component.get("v.finalisedNumber")),
            "AirLHNumber":(component.get("v.finalisedAirNumber")),
            "Flight" : flival,
            "FlightDate" : (component.get("v.FlightDateTime")),
            "Vehicle" : '',//vehval,
            "Vehicle1" : '',//veh.text,               
            "filter": filt,
            "origin" : originVal.text,
            "destination" : desitnationVal.text,
            "airline" :airlineName,
            "fltDate":flightDateTime,
            "comcode":comCodeName,
             "draft":(component.get("v.isDraftContext"))
        });
      
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            console.log("set callback response "+JSON.stringify(response));
            console.log("state: "+state);
            if (state === "SUCCESS") {
               
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(result ==="Success"){
                    $A.get('e.force:refreshView').fire();
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Added to Linehaul successfully.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }else{
                    toastEvent.setParams({
                        title: "Error!",
                        message: result,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                }
                
                toastEvent.fire();
            }
            else if(state === "ERROR") {
                console.log("set callback getError response: ",response.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: errors[0].message,
                    duration:' 10000',
                    key: 'info_alt', 
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        }); 
        $A.enqueueAction(action);

        }else{
            
               var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        title: "Error!",
                        message: "airline is mandatory",
                        duration: '5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                } else {
                   
                    alert("Error: airline is mandatory");
                }
        }
                     
        
        
       
    },
     SaveHelper1 : function(component, event, helper){
                 
                 var isDraftContext = component.get("v.isDraftContext");
                var selectedList = [];
                console.log('drfat flag' +isDraftContext );
                 if (isDraftContext) {
                        selectedList = component.get("v.DraftBagList") || [];
                        console.log('1Finalize called from DRAFT context. Bags:', selectedList.length);
                    } else {
                        selectedList = component.get("v.BagList") || [];
                        console.log('2Finalize called from NORMAL context. Bags:', selectedList.length);
                    }
                  selectedList = selectedList.filter(b => b && b.process === true);
        
                if (selectedList.length === 0) {
                    helper.showToast("Warning", "No bags selected for finalization.", "warning");
                    return;
                }
                
                var bagJson = JSON.stringify(selectedList);
            console.log('BagWrapJson payload:', bagJson);
                 
            var filt = component.get("v.Filter");
            console.log("Filter Value is ",filt);
        
            var action = component.get("c.SaveProcess");
            console.log("Action of helper class ",action);
            console.log("Num: from helper "+component.get("v.finalisedNumber"));
        
            var finalisedNumber = component.get("v.finalisedNumber"); 
            var fli = component.get("v.FlightSchedule");
            var veh = component.get("v.Vehicle");
            var exe = component.get("v.User");  
            var hb = component.get("v.Hub");
        
                 
                  if((hb === null || hb === undefined)){ 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        title: "Error!",
                        message: "Next Destination Field Is Mandatory.",
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();  
                     
                 }else{
                 
                     var flival = (fli && fli.val) ? fli.val : '';
                    var vehval = (veh && veh.val) ? veh.val : '';
                    var vehtext = (veh && veh.text) ? veh.text : '';
                    var hubval = (hb && hb.val) ? hb.val : '';
                    var hubtext = (hb && hb.text) ? hb.text : '';
                    var exetext = (exe && exe.text) ? exe.text : '';
        
            action.setParams({
               "BagWrapJson": bagJson,
               "LHType": (component.get("v.LineHaulType")),
                "LHNumber":(component.get("v.finalisedNumber")),
                "Flight" : flival,
                 "FlightDate" : (component.get("v.FlightDateTime")),
                "Vehicle" : vehval,
                "Vehicle1" : vehtext, 
                "Hub" : hubval,
                "Hub1": hubtext,
                "profileName": exetext,
                "filter": filt,
                "draft":(component.get("v.isDraftContext"))
            });
        
            action.setCallback(this, function(response) {
                var state = response.getState(); 
                console.log("set callback response "+JSON.stringify(response));
                console.log("state: "+state);
        
                var toastEvent = $A.get("e.force:showToast");
        
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result === "Success"){
                        $A.get('e.force:refreshView').fire();
                        toastEvent.setParams({
                            title: "Success!",
                            message: "Added to Linehaul successfully.",
                            duration:'5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                    } else {
                        toastEvent.setParams({
                            title: "Error!",
                            message: result,
                            duration:'5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                    }
                    toastEvent.fire();
                }
                else if(state === "ERROR") {
                    console.log("set callback getError response: ",response.getError());
                    toastEvent.setParams({
                        title: "Error!",
                        message: response.getError()[0].message,
                        duration:'10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            });
        
            $A.enqueueAction(action);
                 }
                 
        },
    //load drafted seal ids
        
        loadDraftSeals : function(component) {
        var action = component.get("c.getDraftSeals");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapResult = response.getReturnValue(); // Map<String,String>
                var arr = [];
                if (mapResult) {
                    // convert map to array of {key,value} preserving order
                    for (var k in mapResult) {
                        if (mapResult.hasOwnProperty(k)) {
                            arr.push({ key: k, value: mapResult[k] });
                        }
                    }
                }
                component.set("v.SealOptionsDraft", arr);
                // optional: if you want to default select the first non-empty option:
                // if(arr.length>1) component.set("v.FilterSealDraft", arr[1].key);
            } else {
                console.error('getDraftSeals failed', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    RemoveSelectedDraftBagsHelper: function(component, event, helper) {
        
         var allDrafts = component.get("v.DraftBagList") || [];
          console.log('[removeSelectedDraftBagsHelper] before remove count =', allDrafts.length);
          
        var remaining = allDrafts.filter(function(bag){
             return !bag.process;  // keep unselected only
           });
        
        var shipList = component.get("v.DraftBagList") || [];
        console.log('RemoveSelectedDraftBagsHelper - shipList:', JSON.stringify(shipList));
    
        var selectedCount = component.get("v.selectedCount") || 0;
        if (selectedCount === 0) {
            // Inline showToast
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    "title": "Info",
                    "message": "Please select at least one draft bag to remove.",
                    "type": "info"
                });
                toastEvent.fire();
            } else {
                alert("Info: Please select at least one draft bag to remove.");
            }
            return;
        }
    
        var action = component.get("c.RemoveDraftSelections");
        action.setParams({
            "BagWrapJson": JSON.stringify(shipList)
        });
    
        component.set("v.isLoading", true);
    
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
    
            var fireToast = function(title, message, type) {
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({ title: title, message: message, type: type });
                    toastEvent.fire();
                } else {
                    alert(title + ": " + message);
                }
            };
    
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
    
               component.set("v.DraftBagList", remaining);
            
                console.log('[removeSelectedDraftBagsHelper] after remove count =', remaining.length);
                
               var updatedCount = (ret && ret.options && ret.options.updatedCount) ? ret.options.updatedCount : null;
                var msg = 'Selected bags removed successfully.';
                if (updatedCount) msg += ' (' + updatedCount + ' updated)';
                
                fireToast("Success", msg, "success");
                component.set("v.selectedCount", 0);
            } else {
                var errors = response.getError();
                var message = (errors && errors[0] && errors[0].message) ? errors[0].message : 'Unknown error';
                fireToast("Error", message, "error");
                console.error('RemoveDraftSelections error', errors);
            }
        });
    
        $A.enqueueAction(action);
    },


    /*
    removeSelectedDraftBagsHelper : function(component) {
            console.log('[removeSelectedDraftBagsHelper] called');
        
            // Get the current list of draft bags
            var allDrafts = component.get("v.DraftBagList") || [];
            console.log('[removeSelectedDraftBagsHelper] before remove count =', allDrafts.length);
        
            // Filter out the ones that are selected (process == true)
            var remaining = allDrafts.filter(function(bag){
                return !bag.process;  // keep unselected only
            });
        
            // Update the attribute to trigger re-render
            component.set("v.DraftBagList", remaining);
        
            console.log('[removeSelectedDraftBagsHelper] after remove count =', remaining.length);
        
            // Optional: Reset selected count or show toast
            component.set("v.selectedCount", 0);
        
            // Optional: Toast confirmation
            var toast = $A.get("e.force:showToast");
            if (toast) {
                toast.setParams({
                    "title": "Removed",
                    "message": "Selected draft bags have been removed from the list.",
                    "type": "success"
                });
                toast.fire();
            }
        },
      */      
    
    DestHubChangeHelper :function(component, event, helper){
        var target = event.target;
        var searchText = target.value;
        console.log('helper= ', searchText);
        if(searchText===""){
            helper.SecureBagsHelper(component, event, helper);
        }else{
            let shipment = component.get("v.ShipmentList");
            var selectedBags = [];
            
            for (var i= 0 ; i < shipment.length ; i++){
                if(shipment[i].process == true){
                    for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                        if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                            selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                                return currentValue
                            }));
                        }else {
                            selectedBags.push(Object.values(shipment[i].BagList)[j]);
                        }
                    }
                }
            }
            
            var action = component.get("c.FilteredBagByDest");
            action.setParams({
                "bags":selectedBags,
                "SearchText":searchText
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.BagList", response.getReturnValue());
                    console.log("success: ",component.get("v.BagList"));
                }
            }); 
            $A.enqueueAction(action);
        }
        
    },
    BagChangeHelper :function(component, event, helper){
        var target = event.target;
        var searchText = target.value;
         var checkboxes = component.find("BagPack");
            var selectedCount = 1;
        console.log('helper= ', searchText);
        if(searchText===""){
            helper.SecureBagsHelper(component, event, helper);
        }else{
            let shipment = component.get("v.ShipmentList");
            var selectedBags = [];
              var searchCount = 1;
                         if (!Array.isArray(checkboxes)) {
                                        checkboxes = [checkboxes];
                                    }
                                    
                        checkboxes.forEach(function(checkbox) {
                            if (checkbox.get("v.value")) {
                              //  selectedCount++;
                               selectedCount++;
                            }
                        });
                        
                        component.set("v.SearchselectedCount", selectedCount);
                        console.log('selectedCount:'+ selectedCount);
                    //    component.set("v.SearchselectedCount", searchCount);
                    //console.log('searchCount:'+ searchCount);
                       
            
            for (var i= 0 ; i < shipment.length ; i++){
                if(shipment[i].process == true){
                    for (var j = 0; j < Object.values(shipment[i].BagList).length; j++){
                        if(Array.isArray(Object.values(shipment[i].BagList)[j])) {
                            selectedBags.push( Object.values(shipment[i].BagList)[j].reduce(function (accumulator, currentValue, array) {
                                return currentValue
                            }));
                           
                            
                        }else {
                            selectedBags.push(Object.values(shipment[i].BagList)[j]);
                            

                        }
                    }
                    
                       
                }
                
            }
            console.log('calll', JSON.stringify(component.get("v.BagList")));
            var action = component.get("c.FilteredByBagNo");
            action.setParams({
                "BagWrapJson":JSON.stringify(component.get("v.BagList")),
                "bags":selectedBags,
                "SearchText":searchText
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // added by Imran BVC
                    var responseData = response.getReturnValue();
                     component.set("v.BagList", response.getReturnValue().reverse());
                     console.log("success: ",responseData);
                    if(responseData != 0)
                    {
                        console.log("Err:");
                     component.set("v.NewBagList", response.getReturnValue());
                    }
                    if(responseData)
                    {
                        function isEmpty(str) {
                            return (!str || 0 === str.length);
                        }
                    }
                    if(responseData == 0 )
                    {
                        helper.invokeErrorMessage(component, event, helper);
                        var vals = component.get("v.NewBagList");
                       console.log("Err:1222");
                         component.set("v.BagList", vals);

                    }
                    helper.handleReset(component, event, helper, searchText);
                }
            }); 
            $A.enqueueAction(action);
        }
        
    },
    handleReset : function(component, event, helper,src)
    {
        event.target.value = "";

    },
    invokeErrorMessage: function(component,event,helper)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error!",
            message: "The Bag Identifier  is not in the list.",
            duration:' 3000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    //Imran code ends
    focusTimerStart: function(component){
        function setFocus(){
            if(component.find('laserScanner') && component.get('v.showBarcodeModal')){
                component.find('laserScanner').focus();
            }
        }
        
        //run periodically
        setInterval($A.getCallback(setFocus),1000);
    },
    
   scanSuccess: function(component,event){
        let result  = event ? event.getParam("result") : null;
        let success = event ? event.getParam("success") : null;
        let barcode = ((success && result && result[0]) ? result[0].data : null);
        this.process(component,barcode);    
    }, 
    process: function(component,barcode){
        let bags = component.get('v.BagList');
        let bagFound = false;
        let bagIndex = null;
        var selectedCount = component.get("v.selectedCount");
        var selectedBags = 0;
        var oldSelectedCount = selectedCount;
        var checkboxes = component.find("BagPack");
        
        
        for(var i=0; i<bags.length; i++){
            if(bags[i].sb.Secure_Packaging_Identifier__c == barcode){
                 var ScanCount = 0;
                bags[i].process = true;
                bagFound = true;
                bagIndex = i;
                
                 if (!Array.isArray(checkboxes)) {
                checkboxes = [checkboxes];
                }
                
                checkboxes.forEach(function(checkbox) {
                    if (checkbox.get("v.value")) {
                        selectedCount++;
                     //    ScanCount++;
                    }
                });
                console.log('selectedCount'+ selectedCount);
                component.set('v.ScanselectedCount',selectedCount);
              //    console.log('ScanCount'+ ScanCount);
              //    component.set('v.ScanselectedCount',ScanCount);
                break;
            }
        }
        if(bagFound){
            let bag = bags.splice(i,1);
            bags.unshift(bag[0]);
            component.set('v.BagList',bags);
            
            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: "The Bag Identifier "+barcode+" is not in the list.",
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
             });
            toastEvent.fire();
        }
    },
    
    AvailableAWBHelper: function(component, event,helper){
        var originVal = component.get("v.Airport");
        var desitnationVal = component.get("v.DestAirport");
        var flightDateTime = component.get("v.FlightDateTime");
        
        var availAWB = component.get("v.availAWB");
        var airlineName = component.find("arlList").get("v.value");
        var apires = component.get("v.apiResponse");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
         var action = component.get("c.getAvailableAwb");
        action.setParams({
            origin : originVal.text,
            destination : desitnationVal.text,
            flightDate : flightDateTime,
            flightscheduleId:component.get('v.flightscheduleId'),
            airlineName: airlineName
        });
        console.log('origin ',originVal.text);
        console.log('desti ',desitnationVal.text);
        console.log('Date ',flightDateTime);
        console.log('Flight ID ',component.get('v.flightscheduleId'));
        console.log('airline name ',airlineName);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length===0){
                    if(airlineName === 'Indigo'){
                        helper.makecalloutforIndigoawb(component,event,helper,originVal.text,desitnationVal.text,flightDateTime);
                    }else if(airlineName === 'Vistara'){
                        helper.makecalloutforvistaraawb(component,event,helper,originVal.text,desitnationVal.text,flightDateTime);
                    }else{
                   //      helper.makecalloutforSpiceJetawb(component,event,helper,originVal.text,desitnationVal.text,flightDateTime);
                    }
                }else{
                    var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
                }
                console.log(result);
            }
        });
        $A.enqueueAction(action);
                        
       
    },
    /*
  makecalloutforSpiceJetawb : function(component,event,helper,originVal,desitnationVal,flightDateTime){
        console.log(JSON.stringify(component.get("v.ShipmentList")));
        console.log(JSON.stringify(component.get("v.BagList")));
        var availAWB = component.get("v.availAWB");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
        var action2 = component.get("c.getAWBFromAPICalloutSpiceJet");
        action2.setParams({
            origin : originVal,
            destination : desitnationVal,
            flightDate : flightDateTime,
            shipmentList: JSON.stringify(component.get("v.ShipmentList")),
            baglist: JSON.stringify(component.get("v.BagList")),
            flightscheduleId: component.get('v.flightscheduleId'),
            commodityCode: component.get('v.selectedComCode')
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null && result.length>=0){
                      var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
            
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: result.message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
                    }
              }
        });
        $A.enqueueAction(action2);
        
    },
          */
    makecalloutforIndigoawb : function(component,event,helper,originVal,desitnationVal,flightDateTime){
         console.log('ab@@@@@@' ,JSON.stringify(component.get("v.ShipmentList")));
         console.log(JSON.stringify(component.get("v.BagList")));
         console.log('origin' + originVal);
         console.log('desitnationVal' + desitnationVal);
         console.log('flightDateTime' + flightDateTime);
         console.log('airLT' + airLT);
        var airLT = component.get("v.finalisedAirNumber");
        var availAWB = component.get("v.availAWB");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
         console.log('reach here' + availAWB);
        
        var action = component.get("c.getAWBFromAPICalloutIndigo");
        action.setParams({origin: originVal, 
                          destination: desitnationVal, 
                          flightDate: flightDateTime,
                           shipmentList:"[]",
                          baglist:"[]",
                        //  shipmentList:JSON.stringify(component.get("v.ShipmentList")),
                       //   baglist: JSON.stringify(component.get("v.BagList")),
                          commodityCode: component.get('v.selectedComCode'), 
                          airFLTNumber: airLT
                         });
        
        action.setCallback(this, function(response) {
             var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null && result.length>=0){
                      var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
                  
                
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: result.message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
                    }
            }else{
                 console.log("ERROR:", response.getError());
            }
           
        });
        $A.enqueueAction(action);
        /*
        var action2 = component.get("c.getAWBFromAPICalloutIndigo");
        action2.setParams({
            origin : originVal,
            destination : desitnationVal,
            flightDate : flightDateTime,
            shipmentList: JSON.stringify(component.get("v.ShipmentList")),
            baglist: JSON.stringify(component.get("v.BagList")),
            commodityCode: component.get('v.selectedComCode'),
            airFLTNumber :airLT
         
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null && result.length>=0){
                      var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
                  
                
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: result.message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
                    }
            }else{
                console.log('error response' + response.getState());
            }
        });
        $A.enqueueAction(action2);
        */
          
         var action3 = component.get("c.getAWBFromAPICalloutIndigo");  //getAWBFromAPICalloutIndigo
         action3.setCallback(this, function(response) {
            var state = response.getState();                        //getAWBNumberfromCallOutIndigo
            if (state === "SUCCESS") {
                var returnValue  = response.getReturnValue();  //
                component.set("v.apiResponse", returnValue);  //response.getReturnValue()
                console.log('response ++' + "v.apiResponse");
                console.log('resposne++'+response);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set("v.apiResponse", 'Error: ' + errors[0].message);
                    console.log('response ++' + "v.apiResponse");
                }
            } 
        });
        $A.enqueueAction(action3);
            
       
    },
        // vistara JS action                   
                        
 makecalloutforvistaraawb : function(component,event,helper,originVal,desitnationVal,flightDateTime){
      console.log('ab@@@@@@' ,JSON.stringify(component.get("v.ShipmentList")));
        console.log(JSON.stringify(component.get("v.BagList")));
        var airFLT = component.get("v.finalisedAirNumber");
        var availAWB = component.get("v.availAWB");
        availAWB = ["--Select a Value--"];
         component.set("v.availAWB", availAWB);
        var action2 = component.get("c.getAWBFromAPICalloutVistara");
        action2.setParams({
            origin : originVal,
            destination : desitnationVal,
            flightDate : flightDateTime,
            airFLTNumber : airFLT,
            shipmentList: JSON.stringify(component.get("v.ShipmentList")),
            
            baglist: JSON.stringify(component.get("v.BagList")),
           // flightscheduleId: component.get('v.flightscheduleId'),
            commodityCode: component.get('v.selectedComCode')
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result!=null && result.length>=0){
                      var availAWB2 = component.get("v.availAWB");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                   component.set("v.availAWB", availAWB2);
                  
                
                    }else{
                         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error!",
                message: result.message,
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
                    }
              }
        });
        $A.enqueueAction(action2);
        
     
 },                     
                     
                        getAirlines: function (component, event, helper){
                            var availAWB = component.get("v.airlineList");
                            availAWB = [{"Id":"--Select a Value--","Airline_Name__c":"--Select a Value--"}];
         component.set("v.airlineList", availAWB);
                            var action2 = component.get("c.getAirlinesDetails");
                            action2.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var result = response.getReturnValue();
                                     var availAWB2 = component.get("v.airlineList");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                                    component.set('v.airlineList',availAWB2);
                                }
                            });
                            $A.enqueueAction(action2);
                        },
                        
                        setCommodityCode :function (component, event, helper,airlineName){
                          var availAWB = component.get("v.commodityCodeList");
                            availAWB = [{"Id":"--Select a Value--","Commodity_Code__c":"--Select a Value--"}];
         component.set("v.commodityCodeList", availAWB);
                            var action2 = component.get("c.getCommodityCode");
                             action2.setParams({
                                 airlineName : airlineName});
                            action2.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var result = response.getReturnValue();
                                     var availAWB2 = component.get("v.commodityCodeList");
                    result.forEach(key=>{
                        availAWB2.push(key);
                    });
                        
                                    component.set('v.commodityCodeList',availAWB2);
                                }
                            });
                            $A.enqueueAction(action2);
                        },
                        /*,SaveDraftHelper : function(component, event, helper){
        console.log("in draft helper");
  var action = component.get("c.SaveDraftBags");
        action.setParams({
            "BagWrapJson": JSON.stringify(component.get("v.BagList"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.BagList", response.getReturnValue());
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(result ==="success"){
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Bags drafted successfully.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }else{
                    toastEvent.setParams({
                        title: "Error!",
                        message: result,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                }
                
                toastEvent.fire();                
            }
        }); 
        $A.enqueueAction(action);
    }*/
                           })