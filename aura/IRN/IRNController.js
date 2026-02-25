/**
 * @description       : 
 * @author            : Imran
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : n
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-11-2023   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
({

    UpdateShip: function(component, event, helper) {
        console.log('Inside Update Shipment UpdateShip');
        helper.UpdateShip2(component, event, helper);

    },
    UpdateShipAllValues: function(component, event, helper) {
        console.log('Inside Update Shipment UpdateShip');
        helper.UpdateShip1(component, event, helper);

    },
    closeWindoiw: function(component, event, helper) {
        console.log('closeWindoiw Successfully');
        component.set("v.editPage","true");
        component.set("v.shPage","true");
    },    
    closeDAForm : function(component, event, helper) {
        console.log('DAForm Form Closed Successfully');
        component.set("v.DAForm","false");
    },
    closeContForm :function(component, event, helper) {
        console.log('ConForm Form Closed Successfullt');
        component.set("v.ConForm","false");
    },
    
    addContForm :function(component, event, helper) {
        console.log('ConForm Form Closed Successfullt');
        component.set("v.ConForm","true");
    },
    
 ConFormSuccessMessage :function(component, event, helper) {
        console.log('ConFormSuccessMessage123'); 
         var ContactName = component.get("v.ContactName");
         var ConMobile = component.get("v.ConMobile");
         var CustName = component.get("v.SelHub.val"); 
         var ABook = component.get("v.SelHub1.val"); 
         var ConEmail = component.get("v.ConEmail");
        console.log('ContactName :'+ContactName);
        console.log('ConMobile :'+ConMobile);
        console.log('CustName :'+CustName);
        console.log('ABook :'+ABook);
        if(ABook!=null && ContactName != null && ConMobile != null && CustName != null)
        {
            component.set("v.spinner",'true');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type" :"success",
                "message": "Person Added Successfully."
            });
            
            toastEvent.fire();
            window.setTimeout(
                $A.getCallback(function() {
                    console.log('Processed');
                    component.set("v.ConForm","false");
                    component.set("v.ContactName","");
                    component.set("v.ConMobile","");
                    component.set("v.ConEmail","");
                    component.set("v.spinner",'false');
                    
                }), 5000   );             
        }
    },

    handleSubmit :function(component, event, helper) {
        component.set("v.spinner",'true');
    },
    handleError : function(component, event, helper) {
        component.set("v.spinner",'false');
    },
    handleSuccess : function(component, event, helper) {
        component.set("v.spinner",'false'); 
        console.log('Inside Handle Success 81');
        var payload = event.getParams().response;
        console.log(payload.id);

        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
        console.log('onsuccess: ', updatedRecord.id);        
        // console.log('JSON.stringify(event.getParams()): ', JSON.stringify(event.getParams().response.fields));
        var Name = event.getParams().response.fields.Name.value;
        console.log('onsuccess: ', Name); 
        
        if(payload!=null)
        {
            console.log('payload  not null : '); 
            var abook = {text:Name,val:payload.id,objName:'AddressBook__c'};
            console.log('abook :'+abook);
            console.log('Stringify abook :'+JSON.stringify(abook));
            component.set("v.SelHub1",abook);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type" :"success",
                "message": "Address Created successfully."
            });
            toastEvent.fire();
            window.setTimeout(
                $A.getCallback(function() {
                    console.log('Processed');
                    console.log('Back to Invoice table');
                    component.set("v.spinner",'false');
                    component.set("v.DAForm","false");
                }), 2000
            ); 
        }
    },    
    // =================== NEW DESTINATION ADDRESS CREATION STARTS===================  
    DAFormSuccessMessage :function(component, event, helper) {
        console.log('DAForm Saved Successfullt Testing1');
        var AdName	= component.get("v.AdName");
        var customer = component.get("v.SelHub.val");
        var Your_Address_Identifier =component.get("v.Your_Address_Identifier");
        var adRecTypeId =component.get("v.adRecTypeId");
        var addr1=component.get("v.addr1");
        var addr2=component.get("v.addr2");
        var actPinCode=component.get("v.actPinCode");    
        if(actPinCode!=null && addr1!=null && Your_Address_Identifier!=null && AdName!=null)
        {
            
           component.set("v.spinner",'true'); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" :"success",
                            "message": "Address Created successfully."
                        });
                        toastEvent.fire();
                    window.setTimeout(
            $A.getCallback(function() {
                console.log('Processed');
                console.log('Back to Invoice table');
               component.set("v.spinner",'false');
               component.set("v.DAForm","false");
                /*
               component.set("v.AdName","");
                component.set("v.Your_Address_Identifier","");
                component.set("v.addr1","");
                component.set("v.addr2","");
                component.set("v.actPinCode","");
                */
            }), 5000
        );
			            
         /*   
		var action = component.get("c.createshipAddress");
            action.setParams({
                AdName :AdName,	
                customer:customer,
                Your_Address_Identifier:Your_Address_Identifier,
                adRecTypeId:adRecTypeId,
                addr1:addr1,
                addr2:addr2,
                actPinCode : actPinCode
            });
            action.setCallback(this,function(resp){
                console.log("ABCD12345");
                if (action.getState() === 'SUCCESS')
                { 
                    CONSOLE.LOG('GOT SUCCESS');
                     component.set("v.DAForm","false");                    
                    console.log('Res :'+resp.getReturnValue());
                    if(resp.getReturnValue() != null)
                    {                        
                        var obj = resp.getReturnValue();
                        console.log('Inside Success123');                      
                        console.log('Add Name :'+obj.Name);
                        console.log('Add Id :'+obj.Id);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" :"success",
                            "message": "Address Created successfully."
                        });
                        toastEvent.fire(); 
                    } 
                    else
                    {
                        component.set("v.DAForm","true");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Failed!",
                            "type" :"error",
                            "message": "Unable to Save Address with Non-Serviceble."
                        });
                        toastEvent.fire();
                        
                        
                    }
                    
                } else if (action.getState() === 'ERROR'){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }                 
                }
            });
            $A.enqueueAction(action);  
            */
        }
    }, 
// =================== NEW DESTINATION ADDRESS CREATION ENDS===================    
     addDAForm : function(component, event, helper) {
        console.log('Inside Add DAForm123ABC123');
            var action = component.get("c.getRecordId");
         /*
            action.setParams({
                recId	:''
            }); */
            action.setCallback(this,function(resp){
                console.log("1123");
                if (action.getState() === 'SUCCESS')
                { 
                    console.log('Res :'+resp.getReturnValue()); 
                    component.set("v.adRecTypeId",resp.getReturnValue());
                    
                } else if (action.getState() === 'ERROR'){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }                 
                }
            });
            $A.enqueueAction(action);             
         
        component.set("v.DAForm","true");
    }, 
    
    closeConForm : function(component, event, helper) {
        console.log('Consinee Form Closed Successfullt');
        component.set("v.consForm","false");
    },
    addConsignee : function(component, event, helper) {
        console.log('Inside Add Consignee');
        component.set("v.consForm","true");
    },
    // =================== NEW CUSTOMER CREATION STARTS===================  
    ConsineeSuccessMessage : function(component, event, helper) {
        console.log('Consinee Created Successfully');        
        console.log(' ConsN :'+component.get("v.ConsN"));
        console.log(' pid :'+component.get("v.pid"));
        console.log(' Name_As_Per_PAN_Manual_Input :'+component.get("v.Name_As_Per_PAN_Manual_Inpu"));
        console.log(' PAN_Number_of_Entity :'+component.get("v.PAN_Number_of_Entity"));
        console.log(' ACR_consumption_link :'+component.get("v.ACR_consumption_link"));
        console.log(' link_generated_date :'+component.get("v.link_generated_date"));
        console.log(' First_Name :'+component.get("v.First_Name"));
        console.log(' Last_Name :'+component.get("v.Last_Name"));
        console.log(' Primary_Customer_Email :'+component.get("v.Primary_Customer_Email"));
        console.log(' Phone :'+component.get("v.Phone"));
// =================== NEW CUSTOMER CREATION STARTS===================        
        var ConsN	= component.get("v.ConsN");
        var pid = component.get("v.pid");
        var Name_As_Per_PAN_Manual_Inpu =component.get("v.Name_As_Per_PAN_Manual_Inpu");
        var PAN_Number_of_Entity =component.get("v.PAN_Number_of_Entity");
        var ACR_consumption_link=component.get("v.ACR_consumption_link");
        var link_generated_date=component.get("v.link_generated_date");
        var First_Name=component.get("v.First_Name");
        var Last_Name=component.get("v.Last_Name");
        var Primary_Customer_Email=component.get("v.Primary_Customer_Email");
        var Phone=component.get("v.Phone");
        if(ConsN!=null && Name_As_Per_PAN_Manual_Inpu!=null && PAN_Number_of_Entity!=null && First_Name!=null && Last_Name!=null && Primary_Customer_Email!=null && Phone!=null)
        {
            component.set("v.spinner",'true');
            console.log('Inside Customer Creation Form');
            var action = component.get("c.createCustomer");
            action.setParams({
                ConsN	:ConsN,
                pid :pid,
                Name_As_Per_PAN_Manual_Inpu :Name_As_Per_PAN_Manual_Inpu,
                PAN_Number_of_Entity :PAN_Number_of_Entity,
                ACR_consumption_link :ACR_consumption_link,
                link_generated_date :link_generated_date,
                First_Name : First_Name,
                Last_Name : Last_Name,
                Primary_Customer_Email : Primary_Customer_Email,
                Phone :Phone
            });
            action.setCallback(this,function(resp){
                console.log("1123");
                if (action.getState() === 'SUCCESS')
                { 
                    component.set("v.ConsN","");  
                    component.set("v.Name_As_Per_PAN_Manual_Inpu","");  
                    component.set("v.PAN_Number_of_Entity","");  
                    component.set("v.link_generated_date","");  
                    component.set("v.First_Name","");  
                    component.set("v.Last_Name","");  
                    component.set("v.Primary_Customer_Email","");  
                    component.set("v.Phone","");                     
					component.set("v.consForm","false");
                    component.set("v.spinner",'false');
                    component.set("v.ConsNid",resp.getReturnValue());
                    console.log('Res :'+resp.getReturnValue());
                    if(resp.getReturnValue() != 'null')
                    {
                        console.log('Inside Success123');                      
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" :"success",
                            "message": "Consignee Created successfully."
                        });
                        toastEvent.fire(); 
                    } 
                    
                } else if (action.getState() === 'ERROR'){
                    component.set("v.spinner",'False');
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" :"Error",
                            "message": "Duplicate Shipping Customer With Same PAN."
                        });
                        toastEvent.fire(); 
                  //  var errors = action.getError();
                  //  if (errors) {
                     //   if (errors[0] && errors[0].message) {
                        //    alert(errors[0].message);
                       // }
                   // }                 
                }
            });
            $A.enqueueAction(action);             
        }
        else
        {
          component.set("v.consForm","true"); 
          alert('Fill Missing Mandatory fields');
        }
 
// ====================== NEW CUSTOMER CREATION ENDS  ========================         
    },
    handleDataFromLWC: function(component, event, helper) {
        var eventData = event.getParam("data");
		 component.set("v.bt100",eventData); 
    },    
closeFileWindow:function(component, event, helper) {
    component.set("v.addFile","false");  
    
},
    closeFileWindow1:function(component, event, helper) {
        console.log('Close Invoice Window 1');
    	component.set("v.hide1","false");
        component.set("v.addFile","false"); 
        
},

    closeFileWindow2:function(component, event, helper) {
        console.log('<==> Inside closeFileWindow2');         
		helper.saveInvoice12(component,event,helper);        
        //component.set("v.addFile","false");
        
},  
   //Validation  for Net weight
/*navHome : function (component, event, helper) {
    var customerGW = component.get("v.CustomerGW");
    var nwcTotal = component.get("v.nwc_Total");

    // Ignore the comparison if customerGW is 0.00, blank, or null
    if (customerGW && customerGW !== 0 && nwcTotal > customerGW) {
        component.set("v.errorMessage", "Net weight is greater than gross weight.");
        setTimeout(function() {
            component.set("v.errorMessage", "");
        }, 4000);
    } else {
        
        
   // var customerGrossWeight = component.get("v.CustomerGW");
    var shipId = component.get("v.Shipment.Id");

 
    console.log('Shipment Id:', shipId);

    component.set("v.spinner", true);

    var action = component.get('c.updateGrossWeight');
    action.setParams({
        shipId     : shipId,
        customerGW : customerGW
    });

    action.setCallback(this, function(resp) {
        var state = resp.getState();

        if (state === 'SUCCESS') {

            var result = resp.getReturnValue();
            console.log('Updated Shipment:', result);

            if (result) {
                component.set("v.Shipment", result);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    type: "success",
                    message: "Shipment Created successfully And Customer Gross Weight updated."
                });
                toastEvent.fire();
            }
            
              var homeEvent = $A.get("e.force:navigateToObjectHome");
    //    var toastEvent = $A.get("e.force:showToast");
       // toastEvent.setParams({
         //   "title": "Success!",
//            "type" : "success",
        //   "message": "Shipment Created successfully."
       // });
        homeEvent.setParams({
            "scope": "Pickup__c"
        });
        homeEvent.fire();       
        //toastEvent.fire();

        } else if (state === 'ERROR') {

            var errors = resp.getError();
            if (errors && errors[0] && errors[0].message) {
                alert(errors[0].message);
            }
            
        }

        component.set("v.spinner", false);
    });

    $A.enqueueAction(action);        
        
        component.set("v.errorMessage", "");
        
      
    }
},*/
    
    navHome2 : function (component, event, helper) {

    var customerGW = component.get("v.CustomerGW");
    var nwcTotal   = component.get("v.nwc_Total");

    // Validation: Net weight should not exceed Gross weight
    if (customerGW && customerGW !== 0 && nwcTotal > customerGW) {

        component.set("v.errorMessage", "Net weight is greater than gross weight.");

        setTimeout(function () {
            component.set("v.errorMessage", "");
        }, 4000);

        return;
    }

    var shipId = component.get("v.Shipment.Id");
    console.log('Shipment Id:', shipId);

    component.set("v.spinner", true);

    var action = component.get('c.updateGrossWeight');
    action.setParams({
        shipId: shipId,
        customerGW: customerGW
    });

    action.setCallback(this, function (resp) {

        var state = resp.getState();

        if (state === 'SUCCESS') {

            var result = resp.getReturnValue();
            console.log('Updated Shipment:', result);

            if (result) {
                component.set("v.Shipment", result);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    type: "success",
                    message: "Shipment created successfully and Customer Gross Weight updated.",
                    duration: 4000
                });
                toastEvent.fire();
            }

          
            setTimeout(function () {
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    scope: "Pickup__c"
                });
                homeEvent.fire();
            }, 4000);

        } else if (state === 'ERROR') {

            var errors = resp.getError();
            if (errors && errors[0] && errors[0].message) {
                alert(errors[0].message);
            }
        }

        component.set("v.spinner", false);
        component.set("v.errorMessage", "");
    });

    $A.enqueueAction(action);
},

//Sanket Redirect.

navHome : function (component, event, helper) {

    var customerGW = component.get("v.CustomerGW");
    var nwcTotal   = component.get("v.nwc_Total");

    if (customerGW && customerGW !== 0 && nwcTotal > customerGW) {
        component.set("v.errorMessage", "Net weight is greater than gross weight.");
        setTimeout(function () {
            component.set("v.errorMessage", "");
        }, 4000);
        return;
    }

    var shipId = component.get("v.Shipment.Id");
    component.set("v.spinner", true);

    var action = component.get("c.updateGrossWeight");
    action.setParams({
        shipId     : shipId,
        customerGW : customerGW
    });

    action.setCallback(this, function (resp) {

        component.set("v.spinner", false);

        if (resp.getState() === "SUCCESS") {

            component.set("v.Shipment", resp.getReturnValue());

        
            $A.get("e.force:showToast").setParams({
                title   : "Success!",
                message : "Shipment created successfully and Customer Gross Weight updated.",
                type    : "success",
                mode    : "dismissible",
                duration: 3000
            }).fire();

            
            setTimeout(function () {
                $A.get("e.force:navigateToObjectHome").setParams({
                    scope: "Pickup__c"
                }).fire();
            }, 3000); // matches toast duration
        }
        else {

            var errors = resp.getError();
            var msg = (errors && errors[0] && errors[0].message)
                ? errors[0].message
                : "Unexpected error occurred";

            $A.get("e.force:showToast").setParams({
                title   : "Error",
                message : msg,
                type    : "error"
            }).fire();
        }
    });

    $A.enqueueAction(action);
},




    
	
    //Added By Sanket
    SuccessMessage :function(component, event, helper) {
     
         var v7 = component.get("v.V7");
        
        if(v7!=null && v7!=""){
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" :"success",
            "message": "Invoice Updated successfully."
        });
            component.set("v.V7","");
        toastEvent.fire(); 
              window.setTimeout(
            $A.getCallback(function() {
                console.log('Processed');
                console.log('Back to Invoice table');
                helper.saveInvoice12(component,event,helper);
                component.set("v.show_edit_Invoice","false");
                component.set("v.hide1","false");
                component.set("v.addFile","false");
                component.set("v.sb","true");                
            }), 2000
        ); 
            
        }
        else{
         var toastEvent = $A.get("e.force:showToast");
      // toastEvent.setParams({
          //  "title": "Alert!",
           // "type" :"Warning",
          //  "message": "Please Upload Invoice Photo."
      //  });
        toastEvent.fire();   
                  window.setTimeout(
            $A.getCallback(function() {
                console.log('Processed');
                console.log('Back to Invoice table');
                helper.saveInvoice12(component,event,helper);
                component.set("v.show_edit_Invoice","false");
                component.set("v.hide1","false");        
                component.set("v.sb","true");                
            }), 2000
        ); 
        }
//up to this
    },
       handleSelect: function(component, event, helper) {  
        console.log('inside handleSelect');
        var Idd = event.target.dataset.id;
        console.log('inv id :'+Idd);
        component.set("v.inv_Id",Idd);
       
        component.set("v.show_edit_Invoice","true");
        component.set("v.sb","false");           
   },
    Back2InvoiceTable :function(component,event,helper){
        
        console.log('Back to Invoice table');
        helper.saveInvoice12(component,event,helper);
        component.set("v.show_edit_Invoice","false");
        component.set("v.hide1","false");        
        component.set("v.sb","true");
        
    },
    handleSaveEdition:function(component,event,helper){
        console.log('Edit Invoice1234');
      
       
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        var action = component.get("c.updatecdList");
        action.setParams({"cdList" : draftValues});
        action.setCallback(this, function(response) {          
            var state = response.getState();           
            $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);          
    },
    EditInvoice :function(component,event,helper){
        console.log('Edit Invoice New');
        var Idd = event.target.dataset.id;
        console.log('inv id :'+Idd);
        component.set("v.inv_Id",Idd);
       
        component.set("v.show_edit_Invoice","true");
        component.set("v.sb","false");        
    },
    Back2Invoice :function(component,event,helper){
        console.log('Back to Add Invoice');        
        component.set("v.hide1","true");        
        component.set("v.sb","false");
        component.set("v.show_edit_Invoice","false");  
        var count = component.get("v.invoiceCount");
    count++;
    component.set("v.invoiceCount", count);
        if (count > 10) {
        component.set("v.isButtonVisible", false);
    }
       // helper.saveInvoice12(component,event,helper);
    },

    Back2Invoice1 :function(component,event,helper){
        console.log('Back to Add Invoice');        
        component.set("v.hide1","true");        
        component.set("v.sb","false");
        component.set("v.show_edit_Invoice","false");    
        helper.saveInvoice12(component,event,helper);
    },    
   // Added By sanket for net weight validation
AddSB : function(component, event, helper) {
    console.log('add SB');
    
    var customerGW = component.get("v.CustomerGW");
    var nwcTotal = component.get("v.nwc_Total");

    // Ignore the comparison if customerGW is 0.00, blank, or null
    if (customerGW && customerGW !== 0.00 && nwcTotal > customerGW) {
        component.set("v.errorMessage", "Net weight is greater than gross weight.");
        setTimeout(function() {
            component.set("v.errorMessage", "");
        }, 4000);
    } else {
        component.set("v.errorMessage", "");
        component.set("v.sbwindow", "true");
        component.set("v.bt100", "true");
        component.set("v.sb", "false");
        console.log('add SB :', component.get("v.sbwindow"));
    }
},

    // uploading files for Invoices
    handleUploadFinished : function(component,event,helper){
                // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
        component.set("v.addFile","false");
    },
    saveShip: function(component,event,helper){        
        helper.saveShipment(component,event,helper);              
    },
    saveInvoice : function(component,event,helper){
        console.log('INSIDE SAVE INVOICE123');
        console.log('Inside saveInvoice 12345');
        helper.saveInvoice12(component,event,helper);
    },
   
    clearValue : function(component, event, helper) {
        component.set("v.V1", null); // Set the value to null to clear it
    },
    clearValue1 : function(component, event, helper) {
        component.set("v.V2", null); // Set the value to null to clear it
    },
    clearValue2 : function(component, event, helper) {
        component.set("v.CustomerGW", null); // Set the value to null to clear it
    },
    onChangeAdditionalRemarks : function(component, event, helper) {
        console.log('AdditionalRemarks :'+component.get("v.AdditionalRemarks"));
       // component.set("v.AdditionalRemarks", null); // Set the value to null to clear it
    },
    saveanInvoice : function(component,event,helper){        
        console.log('Inside saveanInvoice 55665566');
        
        var v1 = component.get("v.V1");
        var v2 = component.get("v.V2");
        var v3 = component.get("v.V3");
        var v4 = component.get("v.V4");
        var v5 = component.get("v.V5");  
        var v7 = component.get("v.V7");
        var shipId = component.get("v.Shipment.Id");  
        
        var c_cpc = component.get("v.c_cpc");
        var c_pdes = component.get("v.c_pdes");
        
        if(!helper.isValidProductDescription(c_cpc, c_pdes)) {
            window.alert("Please select Product Description as per BVC Service.");
            return;
        }
		
		var S_nuom = component.get("v.S_nuom");	// V4
		var S_ciso = component.get("v.S_ciso"); // V6       
        
        console.log('Values are')
        console.log("V1 :"+v1);
        console.log("V2 :"+v2);
        console.log("V3 :"+v3);
        console.log("V4 :"+v4);
        console.log("V5 :"+v5);  
        if(v5=='')
        {
            window.alert('Please Select Document Type');
        }
        
      if(v1 == null || v1=='')
      {
          window.alert('Please Add Net Weight');
      }
        if(v1!=0 && v2!=0 && c_pdes!=null && v5!='')
        {
            //alert('Juming in Apex');
          component.set("v.spinner",'true');
            var action = component.get("c.SaveInvoice");
            action.setParams({
                recId : shipId,
                T_NWT:v1,
                IN_Val:v2,
                RefNumber:v3,
                UG :S_nuom,
                DT:v5,
                c_cpc:c_cpc,
                c_pdes :c_pdes,
                S_ciso:S_ciso
            });
            action.setCallback(this,function(resp){
                //alert('action.getState() ='+action.getState());
                console.log("1");
                if (action.getState() === 'SUCCESS')
                { 
                    component.set("v.V1",0);
                    component.set("v.V2",0);
                    component.set("v.V3","");                
                    console.log('Values are111')
                    console.log("V1 :"+v1);
                    console.log("V2 :"+v2);
                    console.log("V3 :"+v3);                
                    console.log('Inside Success');
                    console.log('Res :'+resp.getReturnValue());
                    component.set("v.spinner",'false');
                    if(resp.getReturnValue() != 'null')
                    {
                        component.set("v.spinner",'false');
                        console.log('Inside Success123');
                        var re = resp.getReturnValue();
                        console.log('Record Id :'+re.Id);
                        component.set("v.Inv_Id1",re.Id);
                        component.set("v.addFile","true");
						component.set("v.c_pdes","None");
                    } 
                    helper.saveInvoice12(component,event,helper);
                    
                } else if (action.getState() === 'ERROR'){
                    //alert('action.getError() ='+action.getError());
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    } 
                    component.set("v.spinner",'false');
                }
            });
            $A.enqueueAction(action);             
            
        }
      //  helper.saveShipment(component,event,helper);
    },
    onChangeBVCServices: function (cmp, evt, helper) {
        // alert(cmp.find('BVCServices').get('v.value') + ' pie is good.');
         var selectedValue = evt.getSource().get("v.value");
        console.log('selectedValue : '+selectedValue);
       // var bvc = cmp.find('BVCServices').get('v.value');
        var bvc = evt.getSource().get("v.value");
       // var PD = cmp.find('ProdcutDescription').get('v.value');
        // var InsuranceBy = cmp.find('InsuranceBy').get('v.value');
        console.log('bvc : '+bvc);
        if(bvc=='ValSHIP')
        {helper.ValSHIP(cmp,event,helper);cmp.set("v.B1","ture");}
        else if(bvc=='GoldSHIP')
        { helper.GoldSHIP(cmp,event,helper);cmp.set("v.B1","ture");}
        else if(bvc=='SilverSHIP')
        { helper.SilverSHIP(cmp,event,helper);cmp.set("v.B1","ture");}
        else if(bvc=='GenSHIP')
        { helper.GenSHIP(cmp,event,helper); cmp.set("v.B1","ture"); }
            else {
                cmp.set("v.B1","false");
                console.log('inside 88');
                helper.setNone(cmp,event,helper);
            }
         cmp.set("v.BVCServices1",bvc);  
        //cmp.set("v.InsuranceBy",InsuranceBy); 
    },
    onChangeProdcutDescription: function (cmp, evt, helper) {
        // alert(cmp.find('PD').get('v.value') + ' pie is good.');
        var pd = cmp.find('PD').get('v.value');
        cmp.set("v.ProdcutDescription1",pd); 
        console.log('pd : '+pd);
    }, 
    onchangeS_nuom :function(component, event, helper) {      
        var S_nuom = component.get("v.S_nuom");
        console.log('S_nuom :'+S_nuom);
    },
    onChangeisExhibition :function(component, event, helper) {      
        var isExhibition = component.get("v.isExhibition");
        console.log('isExhibition :'+isExhibition);
    },    
    onChangeS_ciso :function(component, event, helper) {
        var S_ciso = component.get("v.S_ciso");
        console.log('S_ciso :'+S_ciso);
    },
    onchangeLiability_Type:function(component, event, helper) {
        var Liability_Type = component.get("v.Liability_Type");
        console.log('Liability_Type :'+Liability_Type);
    },
    onChangeInsuranceBy: function(component, event, helper) {
        /*
         var InsuranceBy = component.find('InsuranceBy').get('v.value');
        component.set("v.InsuranceBy1",InsuranceBy); 
        */
    },
    doInit : function(component, event, helper) {       
        helper.addRow(component, event, helper);
        helper.setOptions(component, event, helper);
        console.log('Do Init Starts 2');
        //  helper.doInitHelper(component, event, helper);        
        console.log('Do doInitHelper Ends AB200A');
       // var x = 'a2n0T000000MdvEQAS';
        var custName;
        var action = component.get('c.fetchPickup');
         action.setParams({recId:component.get("v.recordId")});
       // action.setParams({recId:x});
        action.setCallback(this,function(resp){
            if (action.getState() === 'SUCCESS')
            {                
                console.log('RES :'+resp.getReturnValue());
                component.set("v.Pickup",resp.getReturnValue());
                var r =resp.getReturnValue();
                component.set("v.pickupId",r.Id);
                component.set("v.CustomerId",r.Customer__c);
                component.set("v.SA_ID",r.Shipper_Name__c);
                component.set("v.OAddressID",r.Origin_Address_Name__c);
                console.log('custName123 :'+r.Customer__c);
                custName = r.Customer__c;
                console.log('custName124 :'+custName);
                console.log("==== Name :"+r.Name);
                console.log("==== Origin_Address_Name__c :"+r.Origin_Address_Name__c);
                console.log("==== Customer Id :"+r.Customer__c);
                console.log("==== Customer__r.New_Contract__c :"+r.Customer__r.New_Contract__c);  
                
                console.log("==== Shipper_Name__c :"+r.Shipper_Name__c);  
				component.set("v.showLiability_Type",r.Customer__r.New_Contract__c);
            } else if (action.getState() === 'ERROR'){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                } 
                
            }
        });
        $A.enqueueAction(action);  
        
        window.setTimeout($A.getCallback(function() {
            let lwcCmp = component.find("qrScanner");
            if (lwcCmp && lwcCmp.startScanningFromAura) {
                lwcCmp.startScanningFromAura();
            }
        }), 50); // 100ms delay
        
    },
    
    editClicked:function(cmp,event,helper){
        console.log('Clicked')
        cmp.set("v.editPage",'false');
    },
    updatedDetails:function(component,event,helper){
                console.log('Clicked update')
        component.set("v.editPage",'true');
    },
    handleBackPress:function(component,event,helper){
    component.set("v.sb",'false');
    component.set("v.shPage",'true');
	},
    
    //Added By Rafi Khan
    handleInvoiceImageUpload: function(component, event, helper) {
        let file = event.getSource().get("v.files")[0];
        var reader = new FileReader();
        var invoiceId = component.get('v.Inv_Id1');
        
        reader.onload = function(event) {
            helper.compressedImage(component, event.target.result, helper, invoiceId);
        };
        
        reader.readAsDataURL(file);
    },
    
    // Added By Rafi Khan for E-Scan
    ShowDigitalForm:function(component,event,helper){
        console.log('ShowDigitalForm');
        component.set("v.digiForm","true");
        component.set("v.hide2","true");
        component.set("v.startScreenButton","false")
        console.log('ShowDigitalForm :',component.get("v.digiForm"));
    },
    
    ShowEInvoice:function(component,event,helper){
        console.log('E-Scan');
        component.set("v.eScan","true");
        component.set("v.startScreenButton","false");
        component.set("v.isScannedByQRCode","true");
        console.log('ShowDigitalForm :',component.get("v.digiForm"));
    },
    
    handleDataFromQRCodeScanner: function(component, event, helper) {
        var BuyerGstin = event.getParam('BuyerGstin');
        // alert('BuyerGstin received from LWC - QR Code Scanner: ' + JSON.stringify(BuyerGstin));
        var PANNumber = BuyerGstin.substring(2, BuyerGstin.length - 3);
        // alert('Extracted PAN Number: ' + PANNumber);
        var SellerGstin = event.getParam('SellerGstin');
        //alert('SellerGstin received from LWC - QR Code Scanner: ' + JSON.stringify(SellerGstin));
        var DocNo = event.getParam('DocNo');
        component.set("v.V3",DocNo);
        //alert('DocNo received from LWC - QR Code Scanner: ' + JSON.stringify(DocNo));
        var DocDt = event.getParam('DocDt');
        //alert('DocDt received from LWC - QR Code Scanner: ' + JSON.stringify(DocDt));
        var TotInvVal = event.getParam('TotInvVal');
        component.set("v.V2",TotInvVal);
        //alert('TotInvVal received from LWC - QR Code Scanner: ' + JSON.stringify(TotInvVal));
        var ItemCnt = event.getParam('ItemCnt');
        //alert('ItemCnt received from LWC - QR Code Scanner: ' + JSON.stringify(ItemCnt));
        var MainHsnCode = event.getParam('MainHsnCode');
        component.set("v.HSNCode",MainHsnCode);
        //alert('v.HSNCode: ' + JSON.stringify(component.get("v.HSNCode")));
        var IrnDt = event.getParam('IrnDt');
        //alert('IrnDt received from LWC - QR Code Scanner: ' + JSON.stringify(IrnDt));
        //component.set("v.qrCodeData",JSON.stringify(data));
        component.set("v.startScreenButton","true");
        component.set("v.hide3","true");
        component.set("v.qrCodeDataTestScreen","true");
        component.set("v.V5","Invoice");
        if(BuyerGstin!=null && TotInvVal!=null) {
            component.set("v.spinner",'true');
            //alert('Inside Shipment Creation through E-Scan');
            var action = component.get("c.selectCustomerViaEScan");
            action.setParams({
                ConsigneePAN :PANNumber                
            });
            action.setCallback(this,function(res){
                //alert("response getting from createShipmentViaEScan");
                if (action.getState() === 'SUCCESS')
                { 
                    
                    //alert('Consignee Name Details : '+res.getReturnValue());
                    if(res.getReturnValue() != null)
                    {
                        component.set("v.qrCodeData",res.getReturnValue());
                        //component.set("v.qrCodeDataTestScreen","true");
                        //component.set("v.hide3","true");
                        //component.set("v.startScreenButton","false");
                        
                        //alert('Success');                      
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success...!",
                            "type" :"success",
                            "message": "Consignee Automatically Selected Successfully..."
                        });
                        toastEvent.fire();*/
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "error!",
                            "type" :"error",
                            "message": ' Consignee Not Found. Please Select An Existing consignee Or Add a New One.'
                        });
                        toastEvent.fire();
                    }
                    component.set("v.spinner",'false');
                    
                } else if (action.getState() === 'ERROR'){
                    /*var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        
                        }
                    }
                    */
                    
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type" :"error",
                        "message": 'Consignee does not exist.'
                    });
                    toastEvent.fire();
                    
                    component.set("v.spinner",'false');
                }
            });
            
            
            var action1 = component.get("c.selectProductDescriptionViaHSNCode");
            action1.setParams({
                HSNCode :MainHsnCode                
            });
            action1.setCallback(this,function(res){
                //alert("response getting from createShipmentViaEScan");
                //alert('action1.getState() ==='+action1.getState());
                if (action1.getState() === 'SUCCESS')
                { 
                    
                    //alert('HSN Code related details : '+res.getReturnValue());
                    if(res.getReturnValue() != null)
                    {
                        component.set("v.HSNCodeData",res.getReturnValue());
                        var ServiceCode = component.get("v.HSNCodeData.Service_Code__c");
                        //alert('ServiceCode :' +ServiceCode);
                        var ProdDesc = component.get("v.HSNCodeData.Product_Description__c");
                        //alert('ProdDesc :' +ProdDesc);
                        var bvcServices = component.get("v.BVCServices");
                        //alert('JSON.stringify(bvcServices) '+JSON.stringify(bvcServices));
                        //alert('bvcServices.length '+bvcServices.length);
                        var cleanServiceCode = (ServiceCode || '').trim();
                        //alert('cleanServiceCode = '+cleanServiceCode);
                        for (var i = 0; i < bvcServices.length; i++) {
                            //alert('bvcServices[i].id '+bvcServices[i].id);
                            var item = bvcServices[i].id || '';
                            //alert('in for item ==='+ item +'...');
                            //if (productDescriptions[i].id === ProdDesc) {
                            if (item.indexOf(cleanServiceCode) !== -1) {
                                //if (bvcServices[i].id === ServiceCode) {
                                //alert('bvcServices[i].id '+bvcServices[i].id);
                                component.set("v.BVCServices1", item);
                                //alert('component.get("v.BVCServices1") :'+component.get("v.BVCServices1"));
                                break;
                            }
                        }
                        helper.updateProductDescriptions(component, ServiceCode, ProdDesc);
                        //component.set("v.ProdDescViaHSNCode",JSON.stringify(component.get("v.HSNCodeData.Product_Description__c")));
                        //alert('JSON.stringify(component.get("v.HSNCodeData.Product_Description__c")) :'+JSON.stringify(component.get("v.HSNCodeData.Product_Description__c")));
                        //component.set("v.c_pdes",component.get("v.ProdDescViaHSNCode"));
                        //alert('component.get("v.ProdDescViaHSNCode") : '+component.get("v.ProdDescViaHSNCode"));
                        component.set("v.qrCodeDataTestScreen","true");
                        component.set("v.hide3","true");
                        component.set("v.startScreenButton","false");
                        
                        //alert('Success');                      
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success...!",
                            "type" :"success",
                            "message": "Product Description Selected By HSN Code Successfully..."
                        });
                        toastEvent.fire();*/
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "error!",
                            "type" :"error",
                            "message": 'HSN Code is not available, Select BVC Service Manually to Proceed.'
                        });
                        toastEvent.fire();
                        
                    }
                    component.set("v.spinner",'false');
                    
                } else if (action1.getState() === 'ERROR'){
                    /*var errors = action1.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        
                        }
                    }
                    */
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type" :"error",
                        "message": 'HSN Code is not Found.'
                    });
                    toastEvent.fire();
                    
                    component.set("v.spinner",'false');
                }
            });
            
            
            
            $A.enqueueAction(action);   
            $A.enqueueAction(action1);
        } else {
            component.set("v.startScreenButton","true"); 
            component.set("v.spinner",'false');

        }
        
        
    },
    
    saveEScanShip: function(component,event,helper){        
        helper.saveEScanShipment(component,event,helper);              
    },
    
    /////IRn Sanket
    
    openIRNScanner : function(component, event, helper) {
        //component.set("v.showIRNScanner", true);
        
        window.setTimeout($A.getCallback(function() {
            let lwcCmp = component.find("nextqrScanner");
            if (lwcCmp && lwcCmp.startScanningFromAura) {
                lwcCmp.startScanningFromAura();
            }
        }), 50); 
    },

    closeIRNScanner : function(component, event, helper) {
        component.set("v.showIRNScanner", false);
    },

    handleQRScanData2 : function(component, event, helper) {
        var BuyerGstin = event.getParam('BuyerGstin');
        //alert('BuyerGstin received from LWC - QR Code Scanner: ' + JSON.stringify(BuyerGstin));
        var PANNumber = BuyerGstin.substring(2, BuyerGstin.length - 3);
        //alert('Extracted PAN Number: ' + PANNumber);
        var SellerGstin = event.getParam('SellerGstin');
        //alert('SellerGstin received from LWC - QR Code Scanner: ' + JSON.stringify(SellerGstin));
        var DocNo = event.getParam('DocNo');
        component.set("v.V3",DocNo);
        //alert('DocNo received from LWC - QR Code Scanner: ' + JSON.stringify(DocNo));
        var DocDt = event.getParam('DocDt');
        //alert('DocDt received from LWC - QR Code Scanner: ' + JSON.stringify(DocDt));
        var TotInvVal = event.getParam('TotInvVal');
        component.set("v.V2",TotInvVal);
        //alert('TotInvVal received from LWC - QR Code Scanner: ' + JSON.stringify(TotInvVal));
        var ItemCnt = event.getParam('ItemCnt');
        //alert('ItemCnt received from LWC - QR Code Scanner: ' + JSON.stringify(ItemCnt));
        var MainHsnCode = event.getParam('MainHsnCode');
        component.set("v.HSNCode",MainHsnCode);
        //alert('v.HSNCode: ' + JSON.stringify(component.get("v.HSNCode")));
        var IrnDt = event.getParam('IrnDt');
        //alert('IrnDt received from LWC - QR Code Scanner: ' + JSON.stringify(IrnDt));
        //component.set("v.qrCodeData",JSON.stringify(data));
        //component.set("v.startScreenButton","true");
        //component.set("v.hide3","true");
        //component.set("v.qrCodeDataTestScreen","true");
        
        var shipId = component.get("v.Shipment.Id");
        
        component.set("v.V5","Invoice");
        /*
        component.set("v.hide1","true");        
        component.set("v.sb","false");
        component.set("v.show_edit_Invoice","false");  
        var count = component.get("v.invoiceCount");
        count++;
        component.set("v.invoiceCount", count);
        if (count > 10) {
            component.set("v.isButtonVisible", false);
        }
        */
        
        if(BuyerGstin!=null && TotInvVal!=null) {
            component.set("v.spinner",'true');
            //alert('Inside Multiple Invoice Creation through E-Scan');
            
            var action = component.get("c.selectCustomerViaEScan");
            action.setParams({
                ConsigneePAN :PANNumber                
            });
            action.setCallback(this,function(res){
                if (action.getState() === 'SUCCESS')
                { 
                    
                    if(res.getReturnValue() != null)
                    {
                        //alert('Consignee Data = '+res.getReturnValue());
                        component.set("v.qrCodeData",res.getReturnValue());
                        
                    } 
                    component.set("v.spinner",'false');
                    
                } else if (action.getState() === 'ERROR'){
                    component.set("v.spinner",'false');
                }
            });
                        $A.enqueueAction(action);   

            
            var consigneeName = component.get("v.qrCodeData.Name");
            //alert('PANNumber : '+PANNumber);
            //alert('shipId : '+shipId);
            //alert('consigneeName : '+consigneeName);
            var action2 = component.get("c.checkConsigneeDetailsForNextInvoices");
            action2.setParams({
                ConsigneePAN :PANNumber,
                shipId : shipId,
                ConsineeName : consigneeName,
                DocNo: DocNo
            });
            //Sanket Comment 19-01-2026
         /*   action2.setCallback(this,function(res){
                if (action.getState() === 'SUCCESS')
                { 
                    
                    if(res.getReturnValue() != null)
                    {
                        //component.set("v.qrCodeData",res.getReturnValue());
                        
                        component.set("v.hide1","true");        
                        component.set("v.sb","false");
                        component.set("v.show_edit_Invoice","false");  
                        var count = component.get("v.invoiceCount");
                        count++;
                        component.set("v.invoiceCount", count);
                        if (count > 10) {
                            component.set("v.isButtonVisible", false);
                        }
                        
                        component.set("v.startScreenButton","false");
                        
                        
                    } 
                    component.set("v.spinner",'false');
                    
                } else if (action.getState() === 'ERROR'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type" :"error",
                        "message": 'Consignee is not same hence unable to upload this Invoice details...'
                    });
                    toastEvent.fire();
                    
                    component.set("v.spinner",'false');
                }
            });  */ 
            
            //Sanket Block Irn Error
            action2.setCallback(this, function(res) {
                var state = res.getState();
                component.set("v.spinner", "false");
                
                if (state === "SUCCESS") {
                    var result = res.getReturnValue();
                    
                    if (result == null) {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            type: "error",
                            message: "Value Does Not Match with Scanned Shipment Consinee Name Or Consinee Refrence."
                        });
                        toastEvent.fire();
                        return;
                    }
                    
                    
                    component.set("v.hide1", "true");
                    component.set("v.sb", "false");
                    component.set("v.show_edit_Invoice", "false");
                    
                    var count = component.get("v.invoiceCount");
                    count++;
                    component.set("v.invoiceCount", count);
                    
                    if (count > 10) {
                        component.set("v.isButtonVisible", false);
                    }
                    
                    component.set("v.startScreenButton", "false");
                    
                } else if (state === "ERROR") {
                    var errors = res.getError();
                    var message = "Unknown error";
                    
                    if (errors && errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        type: "error",
                        message: message
                    });
                    toastEvent.fire();
                }
            });
            
            
            
            //alert('MainHsnCode before calling apex = '+MainHsnCode);
            var action1 = component.get("c.selectProductDescriptionViaHSNCode");
            action1.setParams({
                HSNCode :MainHsnCode                
            });
            action1.setCallback(this,function(res){
                //alert("response getting from createShipmentViaEScan");
                if (action1.getState() === 'SUCCESS')
                { 
                    
                    //alert('HSN Code related details : '+res.getReturnValue());
                    if(res.getReturnValue() != null)
                    {
                        component.set("v.HSNCodeData",res.getReturnValue());
                        var ServiceCode = component.get("v.HSNCodeData.Service_Code__c");
                        //alert('ServiceCode :' +ServiceCode);
                        var ProdDesc = component.get("v.HSNCodeData.Product_Description__c");
                        //alert('ProdDesc :' +ProdDesc);
                        var bvcServices = component.get("v.BVCServices");
                        //alert('JSON.stringify(bvcServices) '+JSON.stringify(bvcServices));
                        //alert('bvcServices.length '+bvcServices.length);
                        var cleanServiceCode = (ServiceCode || '').trim();
                        //alert('cleanServiceCode = '+cleanServiceCode);
                        for (var i = 0; i < bvcServices.length; i++) {
                            //alert('bvcServices[i].id '+bvcServices[i].id);
                            var item = bvcServices[i].id || '';
                            //alert('in for item ==='+ item +'...');
                            //if (productDescriptions[i].id === ProdDesc) {
                            if (item.indexOf(cleanServiceCode) !== -1) {
                                //if (bvcServices[i].id === ServiceCode) {
                                //alert('bvcServices[i].id '+bvcServices[i].id);
                                component.set("v.BVCServices1", item);
                                //alert('component.get("v.BVCServices1") :'+component.get("v.BVCServices1"));
                                break;
                            }
                        }
                        
                        helper.updateProductDescriptions(component, ServiceCode, ProdDesc);
                        //component.set("v.ProdDescViaHSNCode",JSON.stringify(component.get("v.HSNCodeData.Product_Description__c")));
                        //alert('JSON.stringify(component.get("v.HSNCodeData.Product_Description__c")) :'+JSON.stringify(component.get("v.HSNCodeData.Product_Description__c")));
                        //component.set("v.c_pdes",component.get("v.ProdDescViaHSNCode"));
                        //alert('component.get("v.ProdDescViaHSNCode") : '+component.get("v.ProdDescViaHSNCode"));
                        //component.set("v.qrCodeDataTestScreen","true");
                        
                        alert('Old BVC Service component.get("v.c_cpc") == '+component.get("v.c_cpc"));
                        alert('New BVC Service component.get("v.BVCServices1") == '+component.get("v.BVCServices1"));
                        
                        if(component.get("v.BVCServices1") != component.get("v.cpc")){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "type" :"error",
                                "message": "BVC Service does not match."
                            });
                            toastEvent.fire();
                            
                            //component.set("v.hide1", "false");
                            return;
                        }
                        
                        
                        
                    } 
                    component.set("v.spinner",'false');
                    
                } else if (action1.getState() === 'ERROR'){
                    /*var errors = action1.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        
                        }
                    }
                    */
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type" :"error",
                        "message": 'HSN Code is not available.'
                    });
                    toastEvent.fire();
                    
                    component.set("v.spinner",'false');
                }
            });
            
            
            
            
            $A.enqueueAction(action2);
			$A.enqueueAction(action1);
        } else {
            //component.set("v.startScreenButton","true"); 
            component.set("v.spinner",'false');

        }
        
        
    },
    
    
    handleQRScanData : function(component, event, helper) {
        
        var BuyerGstin  = event.getParam('BuyerGstin');
        var DocNo       = event.getParam('DocNo');
        var TotInvVal   = event.getParam('TotInvVal');
        var MainHsnCode = event.getParam('MainHsnCode');
        
        if (!BuyerGstin || !TotInvVal) {
            return;
        }
        
        component.set("v.spinner", true);
        
        var PANNumber = BuyerGstin.substring(2, BuyerGstin.length - 3);
        var shipId = component.get("v.Shipment.Id");
        
        component.set("v.V3", DocNo);
        component.set("v.V2", TotInvVal);
        component.set("v.V5", "Invoice");
        
        var consigneeName = component.get("v.qrCodeData.Name");
            
        /* =================================================
       1️⃣ CONSIGNEE + REFERENCE CHECK (FIRST GATE)
    ================================================= */
        var action2 = component.get("c.checkConsigneeDetailsForNextInvoices");
        action2.setParams({
            ConsigneePAN : PANNumber,
            shipId       : shipId,
            ConsineeName : consigneeName,
            DocNo        : DocNo
        });
        
        action2.setCallback(this, function(res) {
            
            component.set("v.spinner", false);
            
            // ❌ CONSIGNEE / REF MISMATCH
            /*if (res.getState() !== "SUCCESS" || !res.getReturnValue()) {
                
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    type: "error",
                    message: "This IRN already Scanned for this Shipment."
                }).fire();
                
                return; // ⛔ STOP HERE — BVC WILL NOT RUN
            }*/
            
            if (res.getState() === "ERROR") {
                var errors = res.getError();
                var message = "Unknown error";
                
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    type: "error",
                    message: message
                });
                toastEvent.fire();
                
                return;
            }
            
            /* =================================================
           2️⃣ ONLY IF ABOVE PASSES → BVC CHECK
        ================================================= */
        component.set("v.spinner", true);
        
        var action1 = component.get("c.selectProductDescriptionViaHSNCode");
        action1.setParams({
            HSNCode : MainHsnCode
        });
        
        action1.setCallback(this, function(res1) {
            
            component.set("v.spinner", false);
            
            if (res1.getState() !== "SUCCESS" || !res1.getReturnValue()) {
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    type: "error",
                    message: "HSN Code not found."
                }).fire();
                return;
            }
            
            component.set("v.HSNCodeData", res1.getReturnValue());
            
            var serviceCode = (res1.getReturnValue().Service_Code__c || '').trim();
            var prodDesc = (res1.getReturnValue().Product_Description__c || '').trim();
            var bvcServices = component.get("v.BVCServices");
            var matchedService = null;
            
            for (var i = 0; i < bvcServices.length; i++) {
                if ((bvcServices[i].id || '').indexOf(serviceCode) !== -1) {
                    matchedService = bvcServices[i].id;
                    break;
                }
            }
            
            component.set("v.BVCServices1", matchedService);
            
            //alert('Old BVC Service component.get("v.c_cpc") == '+component.get("v.c_cpc"));
            //alert('New BVC Service matchedService == '+matchedService);
                        
            // ❌ BVC MISMATCH (NOW VALID)
            
            if (matchedService !== component.get("v.c_cpc")) {
                
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    type: "error",
                    message: "BVC Service does not match with existing shipment."
                }).fire();
                
                return;
            } else {
                helper.updateProductDescriptions(component, serviceCode, prodDesc);
            }
            
            /* ======================================
               ✅ ALL VALIDATIONS PASSED
            ====================================== */
            component.set("v.hide1", true);
            component.set("v.sb", false);
            component.set("v.show_edit_Invoice", false);
            component.set("v.startScreenButton", false);
            
            var count = component.get("v.invoiceCount") + 1;
            component.set("v.invoiceCount", count);
            
            if (count > 10) {
                component.set("v.isButtonVisible", false);
            }
        });
        
        $A.enqueueAction(action1);
    });
        
        $A.enqueueAction(action2);
    }

 
  
    
})