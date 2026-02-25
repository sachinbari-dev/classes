({
    saveShipment : function(component,event,helper) {
        var nwc = component.get("v.nwc");
        var refNo = component.get("v.refNo");
        var IValue = component.get("v.IValue");
        
        var AdditionalRemarks = component.get("v.AdditionalRemarks");
        
        var pickupId = component.get("v.pickupId");
        var CustomerId = component.get("v.CustomerId");
        var SA_ID = component.get("v.SA_ID");
        var OAddressID = component.get("v.OAddressID");
        /*
        var CS_ACCID = component.get("v.CS_ACCID");
        var D_Address = component.get("v.D_Address");
        */
        var CS_ACCID = component.get("v.SelHub.val");
        var D_Address = component.get("v.SelHub1.val");
        
        var BVCServices1 = component.get("v.BVCServices1");
        var ProdcutDescription1 = component.get("v.ProdcutDescription1");
        var InsuranceBy1 = component.get("v.InsuranceBy1");
		var people = component.get("v.peopl.val");
        
        var S_nuom = component.get("v.S_nuom");
		var S_ciso = component.get("v.S_ciso");
        
        var customerGrossWeight = component.get("v.CustomerGW");
        console.log('1. customerGrossWeight :'+customerGrossWeight); 

        
        
        if(nwc==0 || nwc==null){console.log('ZEROOOOOO');}
        if(IValue==0 || IValue==null){console.log('++++ZEROOOOOO+++++++');}
        if(CS_ACCID == null){ window.alert('Select Consignee Account');
            component.set("v.sac",false);}else{component.set("v.sac",true);}
        if(D_Address == null){window.alert('Select Destination Address');component.set("v.sad",false);}else{component.set("v.sad",true);}
        
       // var nwc = component.get("v.nwc");
        console.log('Inside Helper saveShipment');
        console.log('nwc :'+nwc);        
        console.log('refNo :'+refNo); 
        console.log('IValue :'+IValue); 
        
        console.log('pickupId :'+pickupId);
        console.log('CustomerId :'+CustomerId);
        console.log('SA_ID :'+SA_ID);
        console.log('OAddressID :'+OAddressID);
        
        console.log('CS_ACCID :'+CS_ACCID); 
        console.log('D_Address :'+D_Address); 
        
        console.log('BVCServices1 :'+BVCServices1);
        console.log('ProdcutDescription1 :'+ProdcutDescription1);
        // setting Total Net weight
        if(ProdcutDescription1 =='Cut & Polished Diamonds' || ProdcutDescription1 =='DIAMOND JEWELLERY' || ProdcutDescription1 =='ROUGH DIAMOND')
        {
			component.set("v.V4","Carat");           
        }
        else
        {
            component.set("v.V4","Gram"); 
        }
/*
        if(customerGrossWeight == 0 || customerGrossWeight == Null){
            console.log('Customer Weight is Zero or Empty');
            window.alert('Customer Gross Weight canot be Zero or EMPTY');
        }
        
        if(customerGrossWeight==0)
        {
           window.alert('Enter Customer Gross Weight'); 
        } */
        
        var Liability_Type = component.get("v.Liability_Type");
        var showLiability_Type = component.get("v.showLiability_Type");        
        console.log('13. customerGrossWeight :'+customerGrossWeight); 
        
        console.log('76 InsuranceBy1 :'+InsuranceBy1);
        console.log('77 showLiability_Type :'+showLiability_Type);
        console.log('78 Liability_Type :'+Liability_Type);         
		var stopSaving=false;
        if(showLiability_Type==true&& InsuranceBy1=='BVC' && Liability_Type=='')
        {
            stopSaving=true;
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",
                    "type" :"error",
                    "message": 'Fill Liability_Type'
                });
                toastEvent.fire();
        }
        if(InsuranceBy1=='None' || InsuranceBy1 =='' )
        {
           console.log('InsuranceBy :'+InsuranceBy1);
            stopSaving=true;
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",
                    "type" :"error",
                    "message": 'Insurance By Value Cannot Be None.'
                });
                toastEvent.fire();
        } 
        
        if(stopSaving!=true && CS_ACCID != null && D_Address != null && InsuranceBy1!='None' && customerGrossWeight>=0 && ((BVCServices1!='None' && ProdcutDescription1!='None') || 
           ((BVCServices1 == 'eSHIP' ||BVCServices1 == 'BATH' || BVCServices1 == 'LuxeSHIP') && ProdcutDescription1=='None'))){
            component.set("v.spinner",'true');
		var action = component.get('c.SaveShipment');
         action.setParams({
             nwc : nwc,
             refNo : refNo,
             IValue : IValue,
             pickupId : pickupId,
             CustomerId : CustomerId,
             SA_ID : SA_ID,
             OAddressID : OAddressID,
             CS_ACCID : CS_ACCID,
             D_Address : D_Address,
             BVCServices1 : BVCServices1,
             ProdcutDescription1 : ProdcutDescription1,
             InsuranceBy1 : InsuranceBy1,
             Receiver : people,
             customerGW : customerGrossWeight,
             S_nuom : S_nuom,
             S_ciso : S_ciso,
             AdditionalRemarks:AdditionalRemarks,
             Liability_Type:Liability_Type,
             isExhibition : component.get("v.isExhibition"),
             createdThrough: 'Mobile App'
         });
        action.setCallback(this,function(resp){
            console.log('11 RES :'+resp.getReturnValue());
            var res1 =resp.getReturnValue();
            console.log('11 RES isSuccess :'+res1.isSuccess);
            console.log('11 RES errorMessage :'+res1.errorMessage);
            
            // if (action.getState() === 'SUCCESS')
            if (res1.isSuccess==true)
            {                
                console.log('11 RES shipRecord :'+res1.shipRecord.Id);
                console.log('RES :'+resp.getReturnValue());
                if(res1.isSuccess==true)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" :"success",
                        "message": "Shipment Saved successfully."
                    });
                    toastEvent.fire(); 
                   // var r = resp.getReturnValue();
                    var r = res1.shipRecord;
                    //component.set("v.ShipId",resp.getReturnValue());
                    console.log('Values :'+r.Id);
                    console.log('Customer__c :'+r.Customer__c);
                    console.log('Shipping_Note_Number__c :'+r.Shipping_Note_Number__c);
                    component.set("v.Shipment",res1.shipRecord);
                    component.set("v.c_cpc",r.Customer_Product_Category__c); // added by imran on 14-03-2024
                    console.log('Shipment :'+component.get("v.Shipment"));
                   // component.set("v.sb","true");
                   component.set("v.shPage","true");
                   // component.set("v.hide1","true");
                    component.set("v.hide2","false");
                }
            } else {
                var errors = action.getError();
                console.log('22 errors :'+errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",
                    "type" :"error",
                    "message": res1.errorMessage
                });
                toastEvent.fire();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                } 
                
            }
            component.set("v.spinner",'false');
        });
        $A.enqueueAction(action);
        }
    },
    // ADDED FUNCTIONALITY FOR UPDATE SHIPMENT

    UpdateShip1 : function(component,event,helper) {
        var nwc = component.get("v.nwc");
        var refNo = component.get("v.refNo");
        var IValue = component.get("v.IValue");
        
        var pickupId = component.get("v.pickupId");
        var CustomerId = component.get("v.CustomerId");
        var SA_ID = component.get("v.SA_ID");
        var OAddressID = component.get("v.OAddressID");
        /*
        var CS_ACCID = component.get("v.CS_ACCID");
        var D_Address = component.get("v.D_Address");
        */
        var CS_ACCID = component.get("v.SelHub.val");
        var D_Address = component.get("v.SelHub1.val");
        
        var BVCServices1 = component.get("v.BVCServices1");
        var ProdcutDescription1 = component.get("v.ProdcutDescription1");
        var InsuranceBy1 = component.get("v.InsuranceBy1");
		var people = component.get("v.peopl.val");
        var customerGrossWeight = component.get("v.CustomerGW");
        var S_nuom = component.get("v.S_nuom");
        var S_ciso = component.get("v.S_ciso");
        console.log('200. customerGrossWeight :'+customerGrossWeight); 
		var AdditionalRemarks = component.get("v.AdditionalRemarks");
        if(nwc==0 || nwc==null){console.log('ZEROOOOOO');}
        if(IValue==0 || IValue==null){console.log('++++ZEROOOOOO+++++++');}
        if(CS_ACCID == null){ window.alert('Select Consignee Account');
            component.set("v.sac",false);}else{component.set("v.sac",true);}
        if(D_Address == null){window.alert('Select Destination Address');component.set("v.sad",false);}else{component.set("v.sad",true);}
        
        
       // var nwc = component.get("v.nwc");
        console.log('Inside Helper saveShipment');
        console.log('nwc :'+nwc);        
        console.log('refNo :'+refNo); 
        console.log('IValue :'+IValue); 
        
        console.log('pickupId :'+pickupId);
        console.log('CustomerId :'+CustomerId);
        console.log('SA_ID :'+SA_ID);
        console.log('OAddressID :'+OAddressID);
        
        console.log('CS_ACCID :'+CS_ACCID); 
        console.log('D_Address :'+D_Address); 
        var Liability_Type1 = component.get("v.Liability_Type1");
        console.log('BVCServices1 :'+BVCServices1);
        console.log('11. ProdcutDescription1 :'+ProdcutDescription1);
        // setting Total Net weight
        if(ProdcutDescription1 =='Cut & Polished Diamonds' || ProdcutDescription1 =='DIAMOND JEWELLERY' || ProdcutDescription1 =='ROUGH DIAMOND')
        {
			component.set("v.V4","Carat");           
        }
        else
        {
            component.set("v.V4","gram"); 
        }
        
        console.log('InsuranceBy1 :'+InsuranceBy1);
        if(CS_ACCID != null && D_Address != null && InsuranceBy1!='None' && 
           customerGrossWeight>0 && ((BVCServices1!='None' && ProdcutDescription1!='None') || 
           ((BVCServices1 == 'eSHIP' ||BVCServices1 == 'BATH' || BVCServices1 == 'LuxeSHIP') && 
            ProdcutDescription1=='None')))
        {
            console.log('219 Update :');
            component.set("v.spinner",'true');
            Liability_Type1 =InsuranceBy1!='BVC'?'None':Liability_Type1;
		var action = component.get('c.updateShipment');
         action.setParams({
             shipId :component.get("v.Shipment.Id"),
             nwc : nwc,
             refNo : refNo,
             IValue : IValue,
             pickupId : pickupId,
             CustomerId : CustomerId,
             SA_ID : SA_ID,
             OAddressID : OAddressID,
             CS_ACCID : CS_ACCID,
             D_Address : D_Address,
             BVCServices1 : BVCServices1,
             ProdcutDescription1 : ProdcutDescription1,
             InsuranceBy1 : InsuranceBy1,
             Receiver : people,
             customerGW : customerGrossWeight,
             S_nuom:S_nuom,
             S_ciso:S_ciso,
             AdditionalRemarks:AdditionalRemarks,
             Liability_Type1:Liability_Type1
         });
        action.setCallback(this,function(resp){
            if (action.getState() === 'SUCCESS')
            {                
                console.log('RES :'+resp.getReturnValue());
               
                
                if(resp.getReturnValue() != 'null')
                {
                    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" :"success",
            "message": "Shipment Saved successfully."
        });
        toastEvent.fire(); 
                    var r = resp.getReturnValue();
                    //component.set("v.ShipId",resp.getReturnValue());
                    console.log('Values :'+r.Id);
                    console.log('Customer__c :'+r.Customer__c);
                    console.log('Shipping_Note_Number__c :'+r.Shipping_Note_Number__c);
                    component.set("v.Shipment",resp.getReturnValue());
                   // component.set("v.c_cpc",r.Customer_Product_Category__c); // added by imran on 14-03-2024
                    console.log('Shipment :'+component.get("v.Shipment"));
                    console.log('Receiver Id :'+r.Reciever_Name__c);
                    component.set("v.recvId",r.Reciever_Name__c);
                    
                    component.set("v.consnName",r.Customer__c);
                    component.set("v.recdestAdd",r.Destination_Address_Name__c);
                   // component.set("v.cpc",r.Customer_Product_Category__c);
                    component.set("v.iby",r.Insurance_By__c);
                    //component.set("v.pdes",r.Product_Description__c);
                   
                    
                   // component.set("v.sb","true");
                 //  component.set("v.shPage","true");
                    component.set("v.editPage","true");
                   // component.set("v.hide1","true");
                    component.set("v.hide2","false");
                }
            } else if (action.getState() === 'ERROR'){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                } 
                
            }
            component.set("v.spinner",'false');
        });
        $A.enqueueAction(action);
        }
    },
    

    // UPDATED SHIPMENT FUNCTIONALITY ENDS HERE 
    addRow : function(component,event,helper) {
        var rowValue = component.get("v.ValList");
        rowValue.push({
            "NetWeightCarat":0,
            "ReferenceNumber":"",
            "InvoiceValue":0
        })
        component.set("v.ValList",rowValue);
    },
    setOptions : function(component,event,helper)
    {
        var BVCServices =  [
            { id: 'None', label: 'None', value:'None',selected: true},
            { id: 'ValSHIP', label: 'ValSHIP', value:'ValSHIP' },
            { id: 'GoldSHIP', label: 'GoldSHIP'},
            { id: 'SilverSHIP', label: 'SilverSHIP' },
            { id: 'LuxeSHIP', label: 'LuxeSHIP' },
            { id: 'GenSHIP', label: 'GenSHIP' },
            { id: 'BATH', label: 'BATH' },
            { id: 'eSHIP', label: 'eSHIP'}
        ];
        component.set("v.BVCServices",BVCServices);  
        var InsuranceBy =  [
             { id: 'None', label: 'None',selected: true},
            { id: 'BVC', label: 'BVC' },
            { id: 'Customer', label: 'Customer'}
        ];
        component.set("v.InsuranceBy",InsuranceBy);        
        
        var ProdcutDescription =  [
            { id: 'None', label: 'None',selected: true }
        ];
        component.set("v.ProdcutDescription",ProdcutDescription);         
    },
    
    ValSHIP : function(component,event,helper)
    {
        var ProdcutDescription =  [
            { id: 'None', label: 'None',selected: true },
            { id: 'Cut & Polished Diamonds', label: 'Cut & Polished Diamonds' },
            { id: 'DIAMOND JEWELLERY', label: 'DIAMOND JEWELLERY' },
            { id: 'Dore Bar', label:'Dore Bar' },
            { id: 'GOLD BAR', label:'GOLD BAR' },
            { id: 'Gold Coin', label: 'Gold Coin' },
            { id: 'GOLD JEWELLERY', label: 'GOLD JEWELLERY' },
            { id: 'Platinum Jewellery', label: 'Platinum Jewellery' },
            { id: 'Diamond Powder', label: 'Diamond Powder	' },
            { id: 'ROUGH DIAMOND',label: 'ROUGH DIAMOND' },
            { id: 'Precious Stones',label: 'Precious Stones' },
            { id: '⁠⁠Jewellery Related Products',label: '⁠⁠Jewellery Related Products' },
            { id: 'Multiple Fine Jewellery Products',label: 'Multiple Fine Jewellery Products' }
        ];
        component.set("v.ProdcutDescription",ProdcutDescription);          
    },
    setNone : function(component,event,helper)
    {
        console.log('inside helper 999');
         var ProdcutDescription =  [
            { id: 'none', label: 'None' }
        ];
        component.set("v.ProdcutDescription",ProdcutDescription);  
        console.log('values changed8989');
        component.set("v.ProdcutDescription1",'None');
},
    GoldSHIP : function(component,event,helper)
    {
        var ProdcutDescription =  [
            { id: 'None', label: 'None',selected: true },
            { id: 'Dore Bar', label:'Dore Bar' },
            { id: 'GOLD BAR', label:'GOLD BAR' },
            { id: 'Gold Coin', label: 'Gold Coin' }
        ];
        component.set("v.ProdcutDescription",ProdcutDescription);          
    },
    SilverSHIP : function(component,event,helper)
    {
        var ProdcutDescription =  [
            { id: 'None', label: 'None',selected: true },
			{ id: 'Coloured & Gem Stones', label: 'Coloured & Gem Stones' },            
            { id: 'Imitation Jewellery', label: 'Imitation Jewellery' },
            { id: 'Silver Bar', label: 'Silver Bar' },
            { id: 'Silver Coin', label: 'Silver Coin' },
            { id: 'SILVER JEWELLERY', label: 'SILVER JEWELLERY' },
            { id: 'Jewellery Related Products', label: 'Jewellery Related Products' },
            { id: 'Silver Granules', label: 'Silver Granules' }
        ];
        component.set("v.ProdcutDescription",ProdcutDescription);          
    },
    GenSHIP : function(component,event,helper)
    {
        var ProdcutDescription =  [
            { id: 'None', label: 'None',selected: true },
            { id: 'Machinery', label: 'Machinery' },
            { id: 'Packing Material', label: 'Packing Material' },
            { id: 'Gift Articles', label: 'Gift Articles' }

        ];
        component.set("v.ProdcutDescription",ProdcutDescription);          
    },
    saveInvoice12 : function(component,event,helper){
        console.log('INSIDE SAVE INVOICE');
        console.log('Inside saveInvoice 12345');
        /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" :"success",
            "message": "Invoice Created successfully."
        });
        toastEvent.fire();    */
        var shipId = component.get("v.Shipment.Id");   
        console.log('Getting values ShipID:'+shipId);
        component.set("v.hide1","false");        
        component.set("v.shPage","false");
         component.set("v.sbwindow","false");
        component.set("v.bt100","false");
        component.set("v.sb","true");  
        var action = component.get("c.fetchAllCustomerDoc");        
        action.setParams({
            recId : shipId
        });
        action.setCallback(this,function(resp){
            console.log("1");
            if (action.getState() === 'SUCCESS')
            {          
                console.log('Inside CD Success');
                console.log('Res :'+resp.getReturnValue());
                if(resp.getReturnValue() != null)
                {
                    console.log('Got all CD List');
                    component.set("v.C_Doc_List",resp.getReturnValue());
                    var re = resp.getReturnValue();
                    var nwc_Total=0,IValue_Total=0;
                    for(let v=0;v<re.length;v++)
                    {
                        nwc_Total = nwc_Total+re[v].Total_Net_Weight__c;
                        IValue_Total = IValue_Total + re[v].Invoice_Value__c;

                    }
                    component.set("v.nwc_Total",nwc_Total);
                    component.set("v.IValue_Total",IValue_Total);
                    console.log('IValue_Total :'+IValue_Total);
                    console.log('nwc_Total :'+nwc_Total);
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

        
        
       // helper.saveShipment(component,event,helper);
    },
    
    //Rafi Khan code for compress Invoice Image Upload
    compressedImage: function(component, dataUrl, helper, invoiceId) {
        this.showSpinner(component);
        var img = new Image();
        img.src = dataUrl;
        img.onload = () => {
            var maxWidth = 800;
            let width = img.width;
            let height = img.height;
            
            if (width > maxWidth) {
            	height = (height * maxWidth) / width;
            	width = maxWidth;
        	}
        
            var canvas = document.createElement('canvas');
            canvas.width = width;
            canvas.height = height;
            
            var ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0, width, height);
            
            var resizedImage = canvas.toDataURL('image/jpeg', 0.8);
            
            var action = component.get('c.compressImage'); 
            
            action.setParams({
                "imageContent" : resizedImage,
                "recId" : invoiceId            
            });
            action.setCallback(this, function(a){
                var state = a.getState(); 
                if(state == 'SUCCESS') {
                    this.hideSpinner(component);
                    
                    component.set("v.V7",a.getReturnValue());
                  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Invoice Uploaded Successfully',
                        duration:' 2000',
                        type: 'success'
                    });
                    toastEvent.fire();
                }else{
                    this.hideSpinner(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Invoice not uploaded',
                        duration:' 2000',
                        type: 'alert'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
            
    	};
    
	},
 
 	showSpinner: function (component){
    	let spinner = component.find("mySpinner");
    	$A.util.removeClass(spinner, "slds-hide");
	},
    
    hideSpinner: function (component){
        let spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
	//Added upto here
    
})