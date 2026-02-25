({
    doinit : function(component, event, helper) {       
        var navigate = component.get("v.navigateFlow");
       // navigate(event.getParam("action"));
       
        helper.addRow(component, event, helper);
    },
    onAdd : function(component,event,helper)    {
        let nwc=0;
        var refNo='';
        let IValue=0;
        let count=0;
        var ValList = component.get("v.ValList");
        console.log('ValList :'+ValList); 
        var listLength = ValList.length;
        console.log('listLength :'+listLength);
        for (var i=0; i < listLength; i++) {            
            console.log('ValList['+i+'].NetWeightCarat: ' + ValList[i].NetWeightCarat);
            console.log('ValList['+i+'].ReferenceNumber: ' + ValList[i].ReferenceNumber);
            console.log('ValList['+i+'].InvoiceValue: ' + ValList[i].InvoiceValue);
            if(ValList[i].NetWeightCarat!='' && ValList[i].InvoiceValue!='')
            {
                count=count+1;
                if(nwc==0){
                    nwc=parseInt(ValList[i].NetWeightCarat);
                }else{
                    nwc=nwc+ parseInt(ValList[i].NetWeightCarat);
                }
            }
            if(ValList[i].NetWeightCarat!='' && ValList[i].InvoiceValue!='' && ValList[i].ReferenceNumber!='')
            {
                if(refNo==0){
                    refNo=ValList[i].ReferenceNumber;
                }else{
                    refNo=refNo+','+ ValList[i].ReferenceNumber;
                }
            }
            if(ValList[i].NetWeightCarat!='' && ValList[i].InvoiceValue!='')
            {
                if(IValue==0){
                    IValue=parseInt(ValList[i].InvoiceValue);
                }else{
                    IValue=IValue+ parseInt(ValList[i].InvoiceValue);
                }
            }             
        }
        console.log('nwc :' + nwc);
        console.log('refNo : ' + refNo);
        console.log('IValue: ' + IValue); 
        component.set("v.nwc",nwc);
        component.set("v.refNo",refNo);
        component.set("v.IValue",IValue);
        if(count==listLength){
            helper.addRow(component, event, helper);
        }
        var flow = component.find("invTable");    
           var inputVariables = [
               					{ name : 'refNo', type : 'Text', value :'Sample'},
               					{ name : 'IValue', type : 'Number', value :50},
               					{ name : 'nwc', type : 'Number', value :20}
           						];  
			flow.startFlow("Add_Shipment_on_pickup_using_mobile_App",inputVariables);         
    },
    onDelete : function(component,event,helper)    {
        var index = event.getSource().get('v.name');
        var ValList = component.get("v.ValList");
        ValList.splice(index,1);
        component.set("v.ValList",ValList);

        let nwc=0;
        let refNo=0;
        let IValue=0;
        let count=0;
        var ValList = component.get("v.ValList");
        console.log('ValList :'+ValList); 
        var listLength = ValList.length;
        console.log('listLength :'+listLength);
        for (var i=0; i < listLength; i++) {            
            console.log('ValList['+i+'].NetWeightCarat: ' + ValList[i].NetWeightCarat);
            console.log('ValList['+i+'].ReferenceNumber: ' + ValList[i].ReferenceNumber);
            console.log('ValList['+i+'].InvoiceValue: ' + ValList[i].InvoiceValue);
            if(ValList[i].NetWeightCarat!='' && ValList[i].InvoiceValue!='')
            {
                count=count+1;
                if(nwc==0){
                    nwc=parseInt(ValList[i].NetWeightCarat);
                }else{
                    nwc=nwc+ parseInt(ValList[i].NetWeightCarat);
                }
            }
            if(ValList[i].NetWeightCarat!='' && ValList[i].InvoiceValue!='' && ValList[i].ReferenceNumber!='')
            {
                if(refNo==0){
                    refNo=ValList[i].ReferenceNumber;
                }else{
                    refNo=refNo+','+ ValList[i].ReferenceNumber;
                }
            }
            if(ValList[i].NetWeightCarat!='' && ValList[i].InvoiceValue!='')
            {
                if(IValue==0){
                    IValue=parseInt(ValList[i].InvoiceValue);
                }else{
                    IValue=IValue+ parseInt(ValList[i].InvoiceValue);
                }
            }             
        }
        
        
        component.set("v.refNo",nwc);
        console.log('nwc :' + nwc);
        console.log('refNo : ' + refNo);
        console.log('IValue: ' + IValue); 
        component.set("v.nwc",nwc);
        component.set("v.refNo",refNo);
        component.set("v.IValue",IValue);
        
        
    },

})