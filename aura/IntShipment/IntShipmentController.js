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
        // Clear all the form fields
    component.set("v.ConsN", "");  
    component.set("v.Name_As_Per_PAN_Manual_Inpu", "");  
    component.set("v.PAN_Number_of_Entity", "");  
    component.set("v.link_generated_date", "");  
    component.set("v.First_Name", "");  
    component.set("v.Last_Name", "");  
    component.set("v.Primary_Customer_Email", "");  
    component.set("v.Phone", "");                     
    
    // Close the form
    component.set("v.consForm","false");
    },
    addConsignee : function(component, event, helper) {
    console.log('Inside Add Consignee');
    component.set("v.consForm","true");
},

// =================== NEW CUSTOMER CREATION STARTS===================  
ConsineeSuccessMessage : function(component, event, helper) {
    console.log('Consignee Created Successfully');        
    var ConsN = component.get("v.ConsN");
    var pid = component.get("v.pid");
    var Name_As_Per_PAN_Manual_Inpu = component.get("v.Name_As_Per_PAN_Manual_Inpu");
    var PAN_Number_of_Entity = component.get("v.PAN_Number_of_Entity");
    var ACR_consumption_link = component.get("v.ACR_consumption_link");
    var link_generated_date = component.get("v.link_generated_date");
    var First_Name = component.get("v.First_Name");
    var Last_Name = component.get("v.Last_Name");
    var Primary_Customer_Email = component.get("v.Primary_Customer_Email");
    var Phone = component.get("v.Phone");

    if(ConsN && Name_As_Per_PAN_Manual_Inpu && PAN_Number_of_Entity && First_Name && Last_Name && Primary_Customer_Email && Phone) {
        component.set("v.spinner", 'true');
        console.log('Inside Customer Creation Form');
        
        var action = component.get("c.createCustomer");
        action.setParams({
            ConsN: ConsN,
            pid: pid,
            Name_As_Per_PAN_Manual_Inpu: Name_As_Per_PAN_Manual_Inpu,
            PAN_Number_of_Entity: PAN_Number_of_Entity,
            ACR_consumption_link: ACR_consumption_link,
            link_generated_date: link_generated_date,
            First_Name: First_Name,
            Last_Name: Last_Name,
            Primary_Customer_Email: Primary_Customer_Email,
            Phone: Phone
        });

        action.setCallback(this, function(resp) {
            if (resp.getState() === 'SUCCESS') { 
                component.set("v.ConsN", "");  
                component.set("v.Name_As_Per_PAN_Manual_Inpu", "");  
                component.set("v.PAN_Number_of_Entity", "");  
                component.set("v.link_generated_date", "");  
                component.set("v.First_Name", "");  
                component.set("v.Last_Name", "");  
                component.set("v.Primary_Customer_Email", "");  
                component.set("v.Phone", "");                     
                component.set("v.consForm", "false");
                component.set("v.spinner", 'false');
                component.set("v.ConsNid", resp.getReturnValue());

                if(resp.getReturnValue() !== 'null') {
                    console.log('Inside Success123');                      
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Consignee Created successfully."
                    });
                    toastEvent.fire(); 
                } 
            } else if (resp.getState() === 'ERROR') {
                component.set("v.spinner", 'false');
                component.set("v.consForm", "true"); 

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Duplicate Shipping Customer With Same PAN."
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);             
    } else {
        component.set("v.consForm", "true"); 
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
navHome : function (component, event, helper) {
    var customerGW = component.get("v.CustomerGW");
    var nwcTotal = component.get("v.nwc_Total");

    // Ignore the comparison if customerGW is 0.00, blank, or null
    if (customerGW && customerGW !== 0 && nwcTotal > customerGW) {
        component.set("v.errorMessage", "Net weight is greater than gross weight.");
        setTimeout(function() {
            component.set("v.errorMessage", "");
        }, 4000);
    } else {
        component.set("v.errorMessage", "");
        
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": "Shipment Created successfully."
        });
        homeEvent.setParams({
            "scope": "Pickup__c"
        });
        homeEvent.fire();       
        toastEvent.fire();
    }
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
        toastEvent.setParams({
            "title": "Alert!",
            "type" :"Warning",
            "message": "Please Upload Invoice Photo."
        });
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
        
        
        if(v1!=0 && v2!=0 && c_pdes!=null && v5!='')
        {
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
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }                 
                }
            });
            $A.enqueueAction(action);             
            
        }
      //  helper.saveShipment(component,event,helper);
    },
    onChangeBVCServices: function (cmp, evt, helper) {
        //alert('cmp.find('BVCServices').get('v.value') :' + cmp.find('BVCServices').get('v.value'));
        var bvc = cmp.find('BVCServices').get('v.value');
        
       // var PD = cmp.find('ProdcutDescription').get('v.value');
        //var InsuranceBy = cmp.find('InsuranceBy').get('v.value');
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
            // component.find('S_nuom').get('v.value');
        
       // component.set("v.S_nuom",S_nuom);
        console.log('S_nuom :'+S_nuom);
    },
    onChangeS_ciso :function(component, event, helper) {
        var S_ciso = component.get("v.S_ciso");
       // component.set("v.S_ciso",S_ciso);
        console.log('S_ciso :'+S_ciso);
    },
    
    onchangeLiability_Type:function(component, event, helper) {
        var Liability_Type = component.get("v.Liability_Type");
        console.log('Liability_Type :'+Liability_Type);
    },
    
    onChangeInsuranceBy: function(component, event, helper) {
        /*var InsuranceBy = component.find('InsuranceBy').get('v.value');
        component.set("v.InsuranceBy1",InsuranceBy); 
        */
    },
    
    doInit : function(component, event, helper) { 
        console.log('Current Date = : '+new Date().toLocaleString());
        component.set("v.isBVCServicesDisabled", false);
        component.set("v.hide2",false);
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
        
        
        //Added by Rafi for fetching looged in username
        var action1 = component.get("c.getCurrentUserName");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.username", response.getReturnValue());
            } else {
                console.error("Failed to fetch user name with state: " + state);
            }
        });

        
        
        $A.enqueueAction(action);
        $A.enqueueAction(action1);        
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
        
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                function(position) {
                    component.set("v.latitude", position.coords.latitude);
                    component.set("v.longitude", position.coords.longitude);
                    
                    reader.onload = function(event) {
                        var lat = component.get("v.latitude");
                        var long = component.get("v.longitude");
                        var username = component.get("v.username");
                        console.log('lat =: '+lat);            
                        console.log('long =: '+long);
                        
                        helper.compressedImage(component, event.target.result, helper, invoiceId, lat, long, username);
                    };
        
        			reader.readAsDataURL(file);
                    
                },
                function(error) {
                    console.error("Error retrieving location: " + error.message);
                }
            );
        } else {
            console.error("Geolocation is not supported by this browser.");
        }
        
        
    },
    
    // Added By Rafi Khan for E-Scan
    ShowDigitalForm:function(component,event,helper){
        console.log('ShowDigitalForm');
        component.set("v.digiForm","true");
        component.set("v.hide2","true");
        component.set("v.startScreenButton","false")
        component.set("v.isScannedByQRCode",false);
        console.log('ShowDigitalForm :',component.get("v.digiForm"));
    },
    
    ShowEInvoice:function(component,event,helper){
        console.log('E-Scan');
        component.set("v.eScan",true);
        component.set("v.startScreenButton",false);
        component.set("v.isScannedByQRCode",true);
        //console.log('ShowDigitalForm :',component.get("v.digiForm"));
    },
    
    handleDataFromQRCodeScanner: function(component, event, helper) {
        var BuyerGstin = event.getParam('BuyerGstin');
        var PANNumber = BuyerGstin.substring(2, BuyerGstin.length - 3);
        var SellerGstin = event.getParam('SellerGstin');
        var DocNo = event.getParam('DocNo');
        component.set("v.V3",DocNo);
        var DocDt = event.getParam('DocDt');
        var TotInvVal = event.getParam('TotInvVal');
        component.set("v.V2",TotInvVal);
        var ItemCnt = event.getParam('ItemCnt');
        var MainHsnCode = event.getParam('MainHsnCode');
        //alert('MainHsnCode :'+MainHsnCode);
        component.set("v.HSNCode",MainHsnCode);
        var IrnDt = event.getParam('IrnDt');
        component.set("v.startScreenButton","true");
        component.set("v.V5","Invoice");
        if(BuyerGstin!=null && TotInvVal!=null) {
            component.set("v.spinner",'true');
            var action = component.get("c.selectCustomerViaEScan");
            action.setParams({
                ConsigneePAN :PANNumber                
            });
            action.setCallback(this,function(res){
                if (action.getState() === 'SUCCESS')
                { 
                    if(res.getReturnValue() != null)
                    {
                        component.set("v.spinner",'false');
                        component.set("v.qrCodeData",res.getReturnValue());
                        
                    } else {
                        component.set("v.spinner",'false');
                        component.set("v.shPage",false);
                        component.set("v.hide2",false);
                        component.set("v.eScan",false)
                        component.set("v.startScreenButton",true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error...!",
                            "type" :"error",
                            "message": "No matching consignee record, so re-scan or create shipment through DSN"
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
                    component.set("v.spinner",'false');
                }
            });
            
            
            var action1 = component.get("c.selectProductDescriptionViaHSNCode");
            action1.setParams({
                HSNCode :MainHsnCode                
            });
            action1.setCallback(this,function(res){
                if (action1.getState() === 'SUCCESS')
                { 
                    if(res.getReturnValue() != null)
                    {
                        component.set("v.spinner",'false');
                        component.set("v.isHSNCodeFound","true");
                        component.set("v.HSNCodeData",res.getReturnValue());
                        var ServiceCode = component.get("v.HSNCodeData.Service_Code__c");
                        var ProdDesc = component.get("v.HSNCodeData.Product_Description__c");
                        var bvcServices = component.get("v.BVCServices");
                        for (var i = 0; i < bvcServices.length; i++) {
                            if (bvcServices[i].id === ServiceCode) {
                                component.set("v.BVCServices1", bvcServices[i].value);
                                component.set("v.isBVCServicesDisabled", true);
                                break;
                            }
                        }
                        helper.updateProductDescriptions(component, ServiceCode, ProdDesc);
                        component.set("v.hide2","true");
                        component.set("v.startScreenButton","false");
                        
                        
                    } else {
                        
                        component.set("v.spinner",'false');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error...!",
                            "type" :"error",
                            "message": "Please check HSN Code..."
                        });
                        toastEvent.fire();
                        component.set("v.eScan",false);
                        component.set("v.isHSNCodeFound",false);	//Remove this comment
                        component.set("v.hide2","true");			//Remove this also
                        //component.set("v.isScannedByQRCode",false);
                        component.set("v.startScreenButton","false");
                        
                    }
                    
                    
                } else if (action1.getState() === 'ERROR'){
                    var errors = action1.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        
                        }
                    }
                    component.set("v.spinner",'false');
                }
            });
            
            $A.enqueueAction(action1);
            $A.enqueueAction(action);   
            //$A.enqueueAction(action1);
        } else {
            component.set("v.startScreenButton","true"); 
            component.set("v.spinner",'false');

        }
        
    }
    
})