({
	proceeds : function(component, event, helper) 
    {
		component.set("v.h1","true");
        var adrList=[];
        var adr1 =[];
        var adrmap =[];
        var points1=[];
        var i;
        var finalString = component.get("v.finalString");
        finalString='';
        var addr = component.get("v.FAdd.text");
        var RNAME = component.get("v.rName");
        var temp = component.get("v.A_List");
       	var IdVal = component.get("v.FAdd.Idval");
        var IdList = component.get("v.Id_List");        
        console.log('RNAME :'+RNAME);
        console.log('Addr Name1 :'+addr);
        console.log('Addr IdVal :'+IdVal);
		
        if(IdList.includes(IdVal))
        {
            
        }else
        {
            IdList.push(IdVal);
        }
            
        console.log('99 Addr IdList :'+IdList);
        if(temp==null)
        {
            temp = addr;
           // adrmap.push({value:addr, key:c});
        }
        else
        {
            if(addr!=null)
            {
                temp = temp +';'+addr;
               // adrmap.push({value:addr, key:c});
            }
            
        }
		//component.set("v.adrmap",adrmap);
        component.set("v.A_List",temp);
        var temp1 = component.get("v.A_List");
        console.log('temp1 :'+temp1);
        adrList = temp1.split(";");
        console.log('adrList :'+adrList);
        let count1=0;
        for(const element of adrList)
        {
            
           console.log('element :'+element);
            console.log('count1 :'+count1);
                
           if(adr1.includes(element))
           {
               console.log('Contains Element :'+element);
           }
            else
            {               
                count1++;
                adr1.push(element);
                adrmap.push({value:element, key:'Point-'+count1});
                points1.push('Point -'+count1+' '+element);
                if(finalString==null)
                {
                    finalString ='Point-'+count1+' '+element+';';                
                }
                else
                {
                    finalString =finalString+ 'Point-'+count1+' '+element+';';                
                }
               // finalString =finalString+ 'Point-'+count1+' '+element+';';                
            }
            
        }

        component.set("v.A1_List",adr1);
        component.set("v.adrmap",adrmap);
        component.set("v.points1",adrmap);
        component.set("v.FAdd","");
        component.set("v.Id_List",IdList);
        console.log('2 IdList :'+IdList);
        console.log('3 points1 :'+points1);
        component.set("v.finalString",finalString);
        console.log('finalString :'+finalString);
    },
    createdRecord: function(component, event, helper)
    {
        var addresses = component.get("v.A_List");
        var addresses1 = component.get("v.points1");
        var finalString = component.get("v.finalString");
        console.log('Inside Create record 1111');
        var RNAME = component.get("v.rName");
        var idlist = component.get("v.Id_List");
        console.log('<===11. idlist  :'+idlist);
        console.log('RNAME :'+RNAME);
        if(RNAME==null)
        {
            console.log('Create Record null');
        }
        if(RNAME!=null && idlist!=null)
        {
            console.log('CREATE');
            var action = component.get('c.saveFleetxAddress');
            action.setParams({ 
                Name : RNAME, 
                Addresses : finalString,
                idlist:idlist
            });
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(response) {
                
                if(response.getState()=='SUCCESS'){
                    var result=response.getReturnValue();
                    console.log("Result1 :"+result);  
                    component.get("v.A_List","");
                    component.set("v.rName","");                   
                    
                    if(result!=null){
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The record has been Created  successfully."
                            
                        });
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/lightning/o/FleetX_Routes__c/list?filterName=Recent"
                        });
                        urlEvent.fire();
                        //toastEvent.fire();
                        
                    }else{
                        
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "The record has not been Upserted  successfully."
                        });
                        toastEvent.fire();
                    }
                }                
                /* 
                var responseValue = response.getReturnValue(); 
                console.log("Result :"+responseValue);  
                component.get("v.A_List","");
                component.set("v.rName","");
                */
            });
            $A.enqueueAction(action);            
            
        }        
	}
})