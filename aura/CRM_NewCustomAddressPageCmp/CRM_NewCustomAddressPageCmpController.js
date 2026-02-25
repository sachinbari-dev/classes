({
    save: function(component, event, helper) {
        event.preventDefault();

        var isValidCustomer = component.get("v.isCustomerValidForAddress");
        if (!isValidCustomer) {
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                title: "Error",
                message: "Cannot save. Customer record type does not match Address type.",
                type: "error",
                mode: "pester"
            });
            toast.fire();
            return; // Stop save
        }

        helper.validate(component, event, helper);
    },

    doInit: function(component, event, helper) {
        helper.getCustomerId(component, event, helper);

        var url_string = window.location.href;
        var recordtypeids = url_string.substring(
            url_string.indexOf("recordTypeId") + 13,
            url_string.indexOf("recordTypeId") + 28
        );

        console.log("Record Type Id: " + recordtypeids);
        var recTypeField = component.find("RecordTypeId");
        if (recTypeField) {
            recTypeField.set("v.value", recordtypeids);
        }

        helper.getRecordTypeId(component, event, helper);
    },

    handleOnSuccess: function(component, event, helper) {
        component.set("v.isLoading", false);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success",
            message: "Address Created Successfully",
            duration: 5000,
            key: "info_alt",
            type: "success",
            mode: "pester"
        });
        toastEvent.fire();

        var payload = event.getParams().response;
        console.log("Created Record Id:", payload.id);

        if (component.get("v.isCommunity")) {
            window.open("/s/settings-addresses", "_self");
        } else {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                recordId: payload.id,
                slideDevName: "related"
            });
            navEvt.fire();
        }
    },

    cancelDialog: function(component, event, helper) {
        helper.cancel(component, event, helper);
    },

    /* 🔥 Updated CustChanged */
    CustChanged: function(component, event, helper) {
        var accValue = component.find("Customer").get("v.value");

        if (accValue) {
            var action = component.get("c.getCustomerRecordTypeName");
            action.setParams({ accId: accValue });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    var customerRT = response.getReturnValue();          // Customer Record Type
                    var addressRT = component.get("v.recName");          // Selected Address Record Type

                    console.log("Customer RT => " + customerRT);
                    console.log("Address RT => " + addressRT);

                    // ❌ Prevent mismatch
                    if ((addressRT === 'Shipping' && customerRT === 'Billing') ||
                        (addressRT === 'Billing' && customerRT === 'Shipping')) {

                        component.find("Customer").set("v.value", null);
                        component.set("v.isCustomerValidForAddress", false);

                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            title: "Error",
                            message: "Please Select the Customer of Same Record type.",
                            type: "error",
                            mode: "pester"
                        });
                        toast.fire();

                        return;
                    } else {
                        component.set("v.isCustomerValidForAddress", true);
                    }

                    // 🔁 Continue existing GST logic
                    var gstField = component.find("GST_Registered_Status__c");
                    if (gstField) {
                        var gstAction = component.get("c.gstStatus");
                        gstAction.setParams({ AccId: accValue });

                        gstAction.setCallback(this, function(gstResponse) {
                            if (gstResponse.getState() === "SUCCESS") {
                                gstField.set("v.value",
                                    gstResponse.getReturnValue() === true ? "Registered" : "Unregistered"
                                );
                            } else {
                                gstField.set("v.value", null);
                            }
                        });
                        $A.enqueueAction(gstAction);
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            var gstField = component.find("GST_Registered_Status__c");
            if (gstField) gstField.set("v.value", null);
            component.set("v.isCustomerValidForAddress", true);
        }
    },

    GstStatusChanged: function(component, event, helper) {
        var gstValue = component.find("GST_Registered_Status__c").get("v.value");
        var dealerTypeField = component.find("Dealer_Type__c");
        if (dealerTypeField) {
            dealerTypeField.set("v.value", gstValue === "Unregistered" ? "Unregistered" : null);
        }
    },

    PincodeChanged: function(component, event, helper) {
        var PincodeValue = component.find("ActivePincode").get("v.value");
        console.log("Entered Pincode:", PincodeValue);

        if (PincodeValue) {
            var action = component.get("c.findCountryStateAndCityBasedOnPin");
            action.setParams({ Pincode: PincodeValue });

            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                console.log("Pincode Apex Response:", res);

                if (state === "SUCCESS" && res.Status === "PINCODERECEIVED") {
                    if (component.find("City")) component.find("City").set("v.value", res.City);
                    if (component.find("District")) component.find("District").set("v.value", res.District);
                    if (component.find("State")) component.find("State").set("v.value", res.State);
                    if (component.find("Country")) component.find("Country").set("v.value", res.Country);
                    if (component.find("Pincode_Type__c")) component.find("Pincode_Type__c").set("v.value", res.PincodeType);

                    component.set("v.Pin_C_Type", res.PincodeType);
                } else {
                    ["City", "District", "State", "Country", "Pincode_Type__c"].forEach(function(id) {
                        var field = component.find(id);
                        if (field) field.set("v.value", "");
                    });
                }
            });
            $A.enqueueAction(action);
        } else {
            ["District", "State", "Country", "City"].forEach(function(id) {
                var field = component.find(id);
                if (field) field.set("v.value", "");
            });
        }
    },

    onError: function(component, event, helper) {
        component.set("v.isLoading", false);

        var errMsg = event.getParam("detail");
        if (errMsg) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: errMsg,
                duration: 5000,
                key: "info_alt",
                type: "error",
                mode: "pester"
            });
            toastEvent.fire();
        }
        console.error("Error Event Params:", JSON.stringify(event.getParams()));
    }
});