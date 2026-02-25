/**
 * @description       : 
 * @author            : Imran
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-11-2023   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
({
    /*
    shipEdit:function(component, event, helper) {
        component.set("v.hide1","false");
        component.set("v.editShip","true");
    },
    
    SuccessMessage1 :function(component, event, helper) {
                var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" :"success",
            "message": "Shipment Updated successfully."
        });
        toastEvent.fire(); 
        component.set("v.hide1","true");
        component.set("v.editShip","false");        
    },  
    */
    UpdateShip: function(component, event, helper) {
        console.log('Inside Update Shipment UpdateShip');
        helper.UpdateShip1(component, event, helper);
        
    },
     onChangeAdditionalRemarks : function(component, event, helper) {
        console.log('AdditionalRemarks :'+component.get("v.AdditionalRemarks"));
       // component.set("v.AdditionalRemarks", null); // Set the value to null to clear it
    },   
    closeWindoiw: function(component, event, helper) {
        console.log('closeWindoiw Successfully');
        component.set("v.editPage","true");
        component.set("v.shPage","true");
    },    
    closeDAForm : function(component, event, helper) {
        console.log('DAForm Form Closed Successfullt');
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
                }), 5000   );             
        }
    },
    
    // =================== NEW DESTINATION ADDRESS CREATION STARTS===================  
    DAFormSuccessMessage :function(component, event, helper) {
        console.log('DAForm Saved Successfullt');
        var AdName	= component.get("v.AdName");
        var customer = component.get("v.SelHub.val");
        var Your_Address_Identifier =component.get("v.Your_Address_Identifier");
        var adRecTypeId =component.get("v.adRecTypeId");
        var addr1=component.get("v.addr1");
        var addr2=component.get("v.addr2");
        var actPinCode=component.get("v.actPinCode");    
        if(actPinCode!=null && addr1!=null && Your_Address_Identifier!=null && AdName!=null)
        {
            /*
            
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
               component.set("v.DAForm","false");
            }), 5000
        );
			*/	            
            
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
        console.log('Consinee Created Successfullt');        
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
                    component.set("v.consForm","false");
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
        else
        {
            component.set("v.consForm","true");  
        }
        
        // ====================== NEW CUSTOMER CREATION ENDS  ========================         
    },
    handleDataFromLWC: function(component, event, helper) {
        var eventData = event.getParam("data");
        component.set("v.bt100",eventData); 
    },    
    
    handleSNNFromLWC: function(component, event, helper){
        var eventData = event.getParam("data");
        component.set("v.shippingNoteNumberManualValue",eventData);
    },
    
    closeFileWindow:function(component, event, helper) {
        component.set("v.addFile","false");  
        
    },
    clearValue : function(component, event, helper) {
        component.set("v.V1", null); // Set the value to null to clear it
    },
    clearValue1 : function(component, event, helper) {
        component.set("v.V2", null); // Set the value to null to clear it
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
     //Added By Sanket for net weight validation
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
        console.log('invoke Method');
        component.set("v.spinner",'false');
        helper.saveShipment(component,event,helper);              
    },
    saveInvoice : function(component,event,helper){
        console.log('INSIDE SAVE INVOICE123');
        console.log('Inside saveInvoice 12345');
        helper.saveInvoice12(component,event,helper);
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
        console.log('Values are')
        console.log("V1 :"+v1);
        console.log("V2 :"+v2);
        console.log("V3 :"+v3);
        console.log("V4 :"+v4);
        console.log("V5 :"+v5);  
        var c_cpc = component.get("v.c_cpc");
        var c_pdes = component.get("v.c_pdes");
        var S_nuom = component.get("v.S_nuom");	// V4
		var S_ciso = component.get("v.S_ciso"); // V6 
        
        if(v1!=0 && v2!=0)
        {
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
                        console.log('Inside Success123');
                        var re = resp.getReturnValue();
                        console.log('Record Id :'+re.Id);
                        component.set("v.Inv_Id1",re.Id);
                        component.set("v.addFile","true");
                        component.set("v.c_pdes","None");
                        //var toastEvent = $A.get("e.force:showToast");
                       // toastEvent.setParams({
                           // "title": "Success!",
                            //"type" :"success",
                           // "message": "Invoice Created successfully."
                       // });
                       // toastEvent.fire(); 
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
        // alert(cmp.find('BVCServices').get('v.value') + ' pie is good.');
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
       // var InsuranceBy = component.find('InsuranceBy').get('v.value');
        //component.set("v.InsuranceBy1",InsuranceBy); 
    },
    doInit : function(component, event, helper) {   
        console.log('MODIFICATIONS DONE 5566');
        helper.addRow(component, event, helper);
        helper.setOptions(component, event, helper);
        console.log('Do Init Starts');
        //  helper.doInitHelper(component, event, helper);        
        console.log('Do doInitHelper Ends');
        var x = 'a2n0T000000MdvEQAS';
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
        $A.enqueueAction(action);        
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
    onChangeShipmentRecordGet:function(component,event,helper){
        var pickup=component.get("v.Pickup");
        var shippingNoteNumberManualValue=component.get("v.shippingNoteNumberManualValue");
        //alert(shippingNoteNumberManualValue+ pickup.Id);
        var action = component.get('c.shipmentRecordGet');
        action.setParams({
            shippingNoteNumber:shippingNoteNumberManualValue,
            pickupID:pickup.Id
        });
        
        action.setCallback(this,function(resp){
            debugger;
            if (action.getState() === 'SUCCESS')
            {   
                var r =resp.getReturnValue();  
                if(r!=null && r.Id != ''){
                    component.set("v.shipmentCreationflage", false);
                    //component.set("v.shipmentRecordGet",'');
                    //window.alert('Shipping note number not found.')
                }
                else{
                    component.set("v.shipmentCreationflage",true);
                    
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
    }
})