({
	proceeds : function(component, event, type) 
    {
        console.log('TEST DONE');
		component.set("v.h1","true");
        var adrList=[];
        var adr1 =[];
        var adrmap =[];
        var points1=[];
        var i;        var finalString,test=0;
        finalString='';
        var addr,RNAME,temp,IdVal,IdList;        
        if(type=='FleetXDriver' && component.get("v.FAdd.text")!=null)
        {
        var finalString = component.get("v.finalString");
        finalString='';
        addr = component.get("v.FAdd.text");
        RNAME = component.get("v.rName");
        temp = component.get("v.D_List");
       	IdVal = component.get("v.FAdd.Idval");
        IdList = component.get("v.Id_List"); 
            test=1;
        }
        if(type=='FleetXGunMen' && component.get("v.gmFAdd.text")!=null)
        {
        var finalString = component.get("v.finalString");
        finalString='';
        addr = component.get("v.gmFAdd.text");
        RNAME = component.get("v.rName");
        temp = component.get("v.GM_List");
       	IdVal = component.get("v.gmFAdd.Idval");
        IdList = component.get("v.gmId_List");  
            test=1;
        }
        if(type=='FleetX_Escorter' && component.get("v.esFAdd.text")!=null)
        {
        var finalString = component.get("v.finalString");
        finalString='';
        addr = component.get("v.esFAdd.text");
        RNAME = component.get("v.rName");
        temp = component.get("v.ES_List");
       	IdVal = component.get("v.esFAdd.Idval");
        IdList = component.get("v.esId_List");  
            test=1;
        }        
		console.log('test :'+test);
		if(test!=0)
        {
        console.log('RNAME :'+RNAME);
        console.log('Addr Name1 :'+addr);
        console.log('Addr IdVal :'+IdVal);
        console.log('<=== TYPE ===> :'+type); 
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
        var temp1 = temp;
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
                adrmap.push({value:element, key:type+'-'+count1});
                points1.push(type+' -'+count1+' '+element);
                if(finalString==null)
                {
                    finalString =type+'-'+count1+' '+element+';';                
                }
                else
                {
                    finalString =finalString+ type+'-'+count1+' '+element+';';                
                }
               // finalString =finalString+ 'Point-'+count1+' '+element+';';                
            }
            
        }

        if(type=='FleetXDriver')
        {
           // component.set("v.A1_List",adr1);
            component.set("v.adrmap",adrmap);
           // component.set("v.points1",adrmap);
            component.set("v.FAdd","");
            component.set("v.Id_List",IdList);
            console.log('2 IdList :'+IdList);
           // console.log('3 points1 :'+points1);
            component.set("v.finalString",finalString);
            console.log('finalString :'+finalString);
			component.set("v.D_List",temp);            
        }
        if(type=='FleetXGunMen')
        {
            // component.set("v.A1_List",adr1);
            component.set("v.gmmap",adrmap);
          //  component.set("v.gmpoints1",adrmap);
            component.set("v.gmFAdd","");
            component.set("v.gmId_List",IdList);
            console.log('2 IdList :'+IdList);
           // console.log('3 points1 :'+points1);
            component.set("v.gmfinalString",finalString);
            console.log('finalString :'+finalString);
            component.set("v.GM_List",temp);
        }
        if(type=='FleetX_Escorter')
        {
           // component.set("v.A1_List",adr1);
            component.set("v.esmap",adrmap);
           // component.set("v.espoints1",adrmap);
            component.set("v.esFAdd","");
            component.set("v.esId_List",IdList);
            console.log('2 IdList :'+IdList);
           // console.log('3 points1 :'+points1);
            component.set("v.esfinalString",finalString);
            console.log('finalString :'+finalString); 
			component.set("v.ES_List",temp);            
        }        
          test=0;  
        }

    },
})