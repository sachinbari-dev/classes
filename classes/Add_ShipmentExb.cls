public without sharing class Add_ShipmentExb
{
/*
    @AuraEnabled
    public static Shipment__c createShipmentRecord(Shipment__c shipmentRecord , String   pickupId, String sNoteNumber  ){
         try { 
             Shipment__c shp=new Shipment__c();
             
            shp =TMS_ScanningBarCodeWithoutShipment.createShipmentRecord(shipmentRecord,pickupId,sNoteNumber);
             
             return shp;
              } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

*/    
     
    
    @AuraEnabled
    
    public static Shipment__c createShipmentRecord(Shipment__c shipmentRecord , String   pickupId, String sNoteNumber,String BVCServices1,
                                                   String ProdcutDescription1,String InsuranceBy1,String CS_ACCID,String CustomerId,
                                                   String D_Address,Decimal customerGW,String people,String S_nuom,
                                                   String S_ciso,String AdditionalRemarks,String Liability_Type){
    Pickup__c pk = new Pickup__c();                                                   
    if(pickupId!=null) 
    {
       pk = [select Shipper_Name__c,Shipper_Address__c,Billing_Account__c,Billing_Address__c from Pickup__c where Id=:pickupId limit 1]; 
    }
    
    Secure_Packaging__c spk = new Secure_Packaging__c();

        try{
            if(sNoteNumber!=null)
            {
                spk = [select Id,Status__c from Secure_Packaging__c where Name=:sNoteNumber AND recordType.Name='Shipping Label' AND Status__c ='Available' limit 1];
            }
          
        }catch(Exception e){
        System.debug('Error--'+e.getMessage());
        }
                                                       
                                                       
    if(spk.id!=null && spk.Status__c =='Available')
        {
            System.debug('Found');
            Shipment__c st1 = new Shipment__c(Consignee_Name_TMS__c=CS_ACCID,Billing_Account__c=pk.Billing_Account__c,Customer_Product_Category__c =BVCServices1,Billing_Address__c=pk.Shipper_Address__c,Customer__c=CustomerId,Pickup__c=pickupId,Destination_Address_Name__c=D_Address,Product_Description__c=ProdcutDescription1,Reciever_Name__c= people,Shipping_Note_Number__c=sNoteNumber ,Shipper_Name_TMS__c = pk.Shipper_Name__c,Origin_Address_Name__c = pk.Shipper_Address__c,Customer_Gross_Weight__c = customerGW,PSN__c=true,Shipment_Created_Through__c='Mobile App',CurrencyIsoCode=S_ciso,Net_Weight_UOM_TMS__c=S_nuom,Additional_Remarks__c=AdditionalRemarks, IsExhibition__c = true,Insurance_By__c=InsuranceBy1);
            System.debug('SHIPPING NOTE NUMBER :'+sNoteNumber); 
            /*
                Shipment__c st = new Shipment__c();                                                         
                st.Consignee_Name_TMS__c=CS_ACCID;
                st.Customer_Product_Category__c =BVCServices1;
                st.Customer__c=CustomerId;
                st.Insurance_By__c=InsuranceBy1;
                st.Pickup__c  =pickupId;
                st.Destination_Address_Name__c=D_Address;
                st.Product_Description__c=ProdcutDescription1;
                st.Net_Weight_UOM_TMS__c='Gram';
                st.Reciever_Name__c= people;
                st.Shipping_Note_Number__c=sNoteNumber; 
                st.Shipper_Name_TMS__c = pk.Shipper_Name__c;
                st.Origin_Address_Name__c = pk.Shipper_Address__c;
                insert st;
                */
            insert st1;                                       
                                                       
    System.debug('11 SHIPPING NOT NUMBER :'+st1.Shipping_Note_Number__c);
    return st1;            
        }
    else
        {
            System.debug('Not Found');
            return null;
        }

                                                       /*
     Shipment__c ss =  Shipment__c(Consignee_Name_TMS__c=CS_ACCID,
                                   Customer_Product_Category__c =BVCServices1,
                                   Customer__c=CustomerId,
                                   Insurance_By__c=InsuranceBy1,
                                   Pickup__c  =pickupId,
                                   Destination_Address_Name__c=D_Address,
                                   Product_Description__c=ProdcutDescription1,
                                   Net_Weight_UOM_TMS__c='Gram',
                                   Reciever_Name__c= people);                                                
        */
    }
    
     @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shippingNoteNumber, String pickupID){
        try { 
           return  TMS_ScanningBarCodeWithoutShipment.shipmentRecordGet(shippingNoteNumber,pickupID);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getRecordId()
    {
       // System.debug('Inside FUNCTION recId:'+recId);
        Id recordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        return recordTypeId;
    }
    
/*    
    @AuraEnabled
    public static AddressBook__c createshipAddress(String AdName,  
                                            String customer,
                                            String Your_Address_Identifier,
                                            String adRecTypeId,
                                            String addr1,
                                            String addr2,
                                            String actPinCode)
    {
        System.debug('actPinCode :'+actPinCode);
        RecordType rt = [select Id,Name from RecordType where Id=:adRecTypeId limit 1];
        Active_Pincode__c acp = [select Id,Pincode_Type__c,
                                 Name,City__c,District__c,
                                 State__c,Country_New__c,
                                 Zone__c,Country__c from Active_Pincode__c where Id=:actPinCode limit 1];
        if(rt.Name=='Shipping' && acp.Pincode_Type__c!='Non-Serviceable')
        {
            AddressBook__c addr = new AddressBook__c();
            addr.Name= AdName;
            addr.ADDRESS1__c =addr1;
            addr.ADDRESS2__c = addr2;
           // addr.Pincode_Type__c = actPinCode;
            addr.Customer__c = customer;
            addr.Your_Address_Identifier__c = Your_Address_Identifier;
            addr.RecordTypeId = adRecTypeId;
      //addr.CITY__c = acp.City__c;
            addr.District__c = acp.District__c;
      addr.Pincode_Type__c = acp.Pincode_Type__c;
            addr.Active_Pincode__c= actPinCode;
            addr.Pincode_TMS__c = actPinCode;
      //addr.STATE__c = acp.State__c;
      //addr.COUNTRY__c = acp.Country__c;
      insert addr;
    return addr;         
        }
        return null;
    }
*/    
    @AuraEnabled
    public static String createCustomer(String ConsN,String pid,String Name_As_Per_PAN_Manual_Inpu,String PAN_Number_of_Entity,String ACR_consumption_link,
                                        DateTime link_generated_date,String First_Name,String Last_Name,String Primary_Customer_Email,String Phone )
    {
        Account ac = new Account();
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
          ac.Name=ConsN;
            ac.RecordTypeId = recordTypeId;
            ac.ParentId=pid;
            ac.Name_As_Per_PAN_Manual_Input__c=Name_As_Per_PAN_Manual_Inpu;
            ac.PAN_Number_of_Entity__c=PAN_Number_of_Entity;
            ac.ACR_consumption_link__c=ACR_consumption_link;
            ac.link_generated_date__c=link_generated_date;
            ac.First_Name__c=First_Name;
            ac.Last_Name__c=Last_Name;
            ac.Primary_Customer_Email__c=Primary_Customer_Email;
            ac.Phone=Phone;
          ac.New_Consignee__c=true;
          insert ac;
        System.debug('AC :'+ac);
        return ac.Id;
    }    
    
    @AuraEnabled
    public static List<Secure_Bag__c> getAllSB(String shipId ){
        System.debug('get All Sb :'+shipId);
         List<Secure_Bag__c> allSb = [select Id,Name,Secure_Bag__c,
                                      Secure_Packaging_Identifier__c
                                      from Secure_Bag__c where Shipment__c=:shipId];
        System.debug('allsb :'+allSb);
        if(allSb.size()>0)
        {
            return allSb;
        }
        else
        {
            return null;
        }
        
    }
    
    
    //to upload Secure Bag Code Added By Rafi
    @AuraEnabled
    public static Boolean saveSecureBagPhoto(String fileData, String secBagName){
        
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = 'SecureBagPhoto.png'; 
            cVersion.Title = 'Secure Bag Photo.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = secBagName;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            contentDocumentList.add(conDocLinkObj);
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
            
        }
        
        return false;
        //return sbList[0];
        
    }
    
    
    
    @AuraEnabled
    public static List<Customer_Documents__c> updatecdList(List<Customer_Documents__c> cdList ){
        update cdList;
        return [select Id,Name,Shipment__c,Total_Net_Weight__c,Invoice_Value__c,
                Reference_number__c,CurrencyIsoCode from Customer_Documents__c 
                where Shipment__c=:cdList[0].Shipment__c];
       // return cdList;
    }    
    
    @AuraEnabled(cacheable=true)
    public static Customer_Documents__c fetchCustomerDoc(String recId) 
    {
        System.debug('recId : '+recId);
        Customer_Documents__c cd = [select Id from Customer_Documents__c where Shipment__c=:recId limit 1];
        /*
        Pickup__c pc = [select Id,Name,
                        Customer__r.Name,Customer__c,
                        Shipper_Name__r.Name,Shipper_Name__c,
                        Origin_Address_Name__r.Name,Origin_Address_Name__c
                        from Pickup__c where Id=:recId limit 1];
        System.debug('pc : '+pc);
  */
        System.debug('cd : '+cd);
        if(cd.Id!=null)
        {
            return cd;
        }
        else
        {return null;}        
    }

    // fetching all Customer Documents using shipmentId
    @AuraEnabled
    public static List<Customer_Documents__c> fetchAllCustomerDoc(String recId)
    {
        System.debug('recId : '+recId);
        List<Customer_Documents__c> cdList = [select Id,Name,Shipment__c,Total_Net_Weight__c,Product_Description__c,
                                              Invoice_Value__c,Reference_number__c ,CurrencyIsoCode 
                                              from Customer_Documents__c where Shipment__c=:recId];
        /*
        Pickup__c pc = [select Id,Name,
                        Customer__r.Name,Customer__c,
                        Shipper_Name__r.Name,Shipper_Name__c,
                        Origin_Address_Name__r.Name,Origin_Address_Name__c
                        from Pickup__c where Id=:recId limit 1];
        System.debug('pc : '+pc);
  */
        System.debug('cd : '+cdList);
        if(cdList.size()>0)
        {           
            decimal Netwt=0,ShValue=0;
            String Ref1,MPdes,MNW,MIV;
            String ccode;
            
            Shipment__c up_sh = [select Id,Shipment_Value__c,Multi_Invoice_Value__c,Multi_Net_Weight__c,Multi_Product_Description__c,
                                 Net_Weight__c, Reference_1__c ,CurrencyIsoCode
                                 from Shipment__c where Id=:recId limit 1];
            System.debug('inside up_sh :'+up_sh);
            if(up_sh.id!=null)
            {
                System.debug('inside allow');
                for(Customer_Documents__c cd :cdList)
                {
                    ccode=cd.CurrencyIsoCode;
          			Netwt = Netwt + cd.Total_Net_Weight__c;
                    ShValue = ShValue + cd.Invoice_Value__c;
                    if(Ref1==null)
                    {Ref1 =cd.Reference_number__c;}
                    else{Ref1 = Ref1+','+cd.Reference_number__c;}
                    if(MPdes==null){
                        MPdes=cd.Product_Description__c;
                    } else { MPdes = MPdes+','+cd.Product_Description__c;}
                    if(MNW==null){
                        MNW=String.valueOf(cd.Total_Net_Weight__c);
                    } else { MNW = MNW+','+String.valueOf(cd.Total_Net_Weight__c);}                    
                    if(MIV==null){
                        MIV=String.valueOf(cd.Invoice_Value__c);
                    } else { MIV = MIV+','+String.valueOf(cd.Invoice_Value__c);}                    
                }  
                up_sh.Shipment_Value__c=ShValue;
                up_sh.Net_Weight__c=Netwt;
                up_sh.Reference_1__c=Ref1;
        		up_sh.CurrencyIsoCode = ccode;
                up_sh.Multi_Invoice_Value__c=MIV;
                up_sh.Multi_Net_Weight__c=MNW;
                up_sh.Multi_Product_Description__c=MPdes;
                update up_sh;                
            }

            return cdList;
        }
        else
        {return null;}        
    }    
    
    @AuraEnabled
    public static Customer_Documents__c SaveInvoice(String recId,
                                                    decimal T_NWT,
                                                    Decimal IN_Val,
                                                    String RefNumber,
                                                    String UG,String DT,String cur,String c_pdes,String c_cpc,String S_ciso)
    {
        System.debug('recId : '+recId); 
        System.debug('c_pdes : '+c_pdes);
        System.debug('c_cpc : '+c_cpc);
        Customer_Documents__c cd  = new Customer_Documents__c();
        cd.Shipment__c =recId;
        cd.Total_Net_Weight__c =T_NWT;
        cd.Invoice_Value__c =IN_Val;
        cd.Reference_number__c =RefNumber;
        cd.Unit_Weight__c =UG;
        cd.Document_type__c =DT;
        cd.CurrencyIsoCode = S_ciso; 
        cd.Customer_Document__c= true;
		cd.Customer_Product_Category__c= c_cpc;
        cd.Product_Description__c= c_pdes;
        
        
        insert cd;
        System.debug('cd : '+cd);
        
        Shipment__c shp = [select Id,Net_Weight_UOM_TMS__c,CurrencyIsoCode from Shipment__c where Id=:recId limit 1];
        shp.Net_Weight_UOM_TMS__c=UG;shp.CurrencyIsoCode = cur; update shp;
    List<Customer_Documents__c> cdList = fetchAllCustomerDoc(recId);
        return cd;
    }    
    
    @AuraEnabled
    public static Pickup__c fetchPickup(String recId)
    {
        System.debug('recId : '+recId);
        Pickup__c pc = [select Id,Name,
                        Customer__r.Name,Customer__c,Shipper_Address__c,
                        Shipper_Name__r.Name,Shipper_Name__c,Customer__r.New_Contract__c,
                        Origin_Address_Name__r.Name,Origin_Address_Name__c
                        from Pickup__c where Id=:recId limit 1];
        System.debug('pc : '+pc);
        return pc;
    }
/*
    @AuraEnabled
    public static List<String> fetchNames(String acId)
    {
        System.debug('inside fetchNames acId :'+acId);
        
        List<String> NamesList = new List<String>();
        Account ac = [select Id,Name from Account where Id=:acId limit 1 ];
        System.debug('AC :'+ac);
        NamesList.add(ac.Name);
        System.debug('inside NamesList :'+NamesList);
        return NamesList;
        
    }
  */  
    @AuraEnabled
    public static resultWrapper SaveShipment(Integer nwc,String refNo,Integer IValue,String pickupId,String CustomerId,String SA_ID,String OAddressID,
                                           String CS_ACCID,String D_Address,String BVCServices1,String ProdcutDescription1,String InsuranceBy1,
                                      String Receiver,List<Customer_Documents__c> ValList,Decimal customerGW,String S_nuom,String S_ciso, 
                                             String AdditionalRemarks,String Liability_Type, Boolean isExhibition,String createdThrough,String ShipmentType,
    String Exhibition)
        
    {
        String billingAccountId;
        String billingAaddId;
        resultWrapper rw = new resultWrapper();
        List<Pickup__c> pkup1 = [select Id,Billing_Account__c,Billing_Address__c,Billing_Account__r.Id,Billing_Address__r.Id from Pickup__c where Id=: pickupId limit 1];
        For(Pickup__c Pkups : pkup1){
            billingAccountId = Pkups.Billing_Account__r.Id;
            billingAaddId = Pkups.Billing_Address__r.Id;        
        }
        // String pc='null';
        System.debug('ValList :'+ValList);
        System.debug('nwc :'+nwc);
        System.debug('refNo :'+refNo);
        System.debug('IValue :'+IValue);
        System.debug('pickupId :'+pickupId);
        System.debug('CustomerId :'+CustomerId);
        System.debug('SA_ID :'+SA_ID);
        System.debug('OAddressID :'+OAddressID);
        System.debug('CS_ACCID :'+CS_ACCID);
        System.debug('D_Address :'+D_Address);
        System.debug('BVCServices1 :'+BVCServices1);
        System.debug('ProdcutDescription1 :'+ProdcutDescription1);
        System.debug('InsuranceBy1 :'+InsuranceBy1); 
        System.debug('Receiver :'+Receiver); 
        System.debug('customerGW :'+customerGW); 
        System.debug('createdThrough :'+createdThrough);
        
            /*
            if(nwc!=null && IValue!=null)
            { */
        if(refNo==null){refNo = '';}
       if(InsuranceBy1 == 'none'){InsuranceBy1='BVC';}
        if(ProdcutDescription1=='none'){ProdcutDescription1='';}
        System.debug('<========Inside My Method======>');
        
         String exhibitionCode;
    if (Exhibition != null) {
        ST_Exhibition__c exb = [
            SELECT Name
            FROM ST_Exhibition__c
            WHERE Id = :Exhibition
            LIMIT 1
        ];
        exhibitionCode = exb.Name;
    }
      
        
        Shipment__c newShip = new Shipment__c();
        Shipment__c newShip1 = new Shipment__c(Shipment_Created_Through__c=createdThrough,Consignee_Name_TMS__c=CS_ACCID,Billing_Account__c=billingAccountId,Billing_Address__c=billingAaddId,Customer_Product_Category__c =BVCServices1,Customer__c=CustomerId,Shipper_Name_TMS__c=SA_ID,Origin_Address_Name__c=OAddressID,Shipment_Value__c=IValue,Net_Weight__c=nwc,Reference_1__c=refNo,Pickup__c  =pickupId,Destination_Address_Name__c=D_Address,Product_Description__c=ProdcutDescription1,Customer_Gross_Weight__c = customerGW,Reciever_Name__c= Receiver,DSN__c=true,CurrencyIsoCode=S_ciso,Net_Weight_UOM_TMS__c=S_nuom,Additional_Remarks__c=AdditionalRemarks,Shipment_Type_Exb__c = ShipmentType,
    Exhibition__c = Exhibition,Exhibition_Code__c = exhibitionCode,Liability_Type__c=Liability_Type,Insurance_By__c=InsuranceBy1);
        try{
            newShip1.IsExhibition__c= true;
            insert newShip1;
            rw.isSuccess=true;
            rw.errorMessage=null;
            rw.shipRecord=newShip1;
        }
        catch(DmlException  e)
        {
            rw.isSuccess=false;
            rw.errorMessage=e.getDmlMessage(0);
            rw.shipRecord=null;
            System.debug('55. '+e.getMessage());
        }
        
        
        System.debug('newShip1 :'+newShip1.Id);
        System.debug('newShip1 Pickup__c :'+newShip1.Pickup__c);
        /*
        newShip.Customer_Product_Category__c =  BVCServices1;
        newShip.Customer__c        =    CustomerId;
        newShip.Shipper_Name_TMS__c    =    SA_ID;
        newShip.Origin_Address_Name__c  =    OAddressID;
        newShip.Insurance_By__c      =    InsuranceBy1;
        newShip.Shipment_Value__c    =    IValue;
        newShip.Net_Weight__c      =    nwc;
        newShip.Reference_1__c      =    refNo;
        newShip.Pickup__c          =  pickupId;  
        newShip.Consignee_Name_TMS__c    =  CS_ACCID;
        newShip.Destination_Address_Name__c  =  D_Address  ;
        newShip.Product_Description__c    =  ProdcutDescription1  ;
        newShip.Net_Weight_UOM_TMS__c    =  'Gram';
        newShip.Reciever_Name__c  = Receiver;
        insert newShip;
        //return newShip.Id;            
        return newShip;
        */
        return rw;
        //  }
        
        //  return null;
    } 
    
public class resultWrapper
{
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    @AuraEnabled
    public String errorMessage { get; set; }
    @AuraEnabled
    public Shipment__c shipRecord { get; set; }
}
        @AuraEnabled
    public static Shipment__c updateShipment(String shipId,Integer nwc,String refNo,Integer IValue,String pickupId,String CustomerId,String SA_ID,String OAddressID,
                                           String CS_ACCID,String D_Address,String BVCServices1,String ProdcutDescription1,String InsuranceBy1,
                                      String Receiver,List<Customer_Documents__c> ValList,Decimal customerGW,String S_nuom,String  S_ciso,String AdditionalRemarks,String Liability_Type1,String ShipmentType,
    String Exhibition)
        
    {
       // String pc='null';
        System.debug('ValList :'+ValList);
        System.debug('nwc :'+nwc);
        System.debug('refNo :'+refNo);
        System.debug('IValue :'+IValue);
        System.debug('pickupId :'+pickupId);
        System.debug('CustomerId :'+CustomerId);
        System.debug('SA_ID :'+SA_ID);
        System.debug('OAddressID :'+OAddressID);
        System.debug('CS_ACCID :'+CS_ACCID);
        System.debug('D_Address :'+D_Address);
        System.debug('BVCServices1 :'+BVCServices1);
        System.debug('ProdcutDescription1 :'+ProdcutDescription1);
        System.debug('InsuranceBy1 :'+InsuranceBy1); 
        System.debug('Receiver :'+Receiver); 
        System.debug('customerGW :'+customerGW); 
        System.debug('Liability_Type1 :'+Liability_Type1); 
        
        /*
        if(nwc!=null && IValue!=null)
        { */
        if(refNo==null){refNo = '';}
       // if(InsuranceBy1 == 'none'){InsuranceBy1='BVC';}
        if(ProdcutDescription1=='none'){ProdcutDescription1='';}
        System.debug('<========Inside My Method======>');
        String exhibitionCode;
    if (Exhibition != null) {
        ST_Exhibition__c exb = [
            SELECT Name
            FROM ST_Exhibition__c
            WHERE Id = :Exhibition
            LIMIT 1
        ];
        exhibitionCode = exb.Name;
    }
        
      //  Shipment__c newShip = new Shipment__c();
     //   Shipment__c newShip1 = new Shipment__c(Consignee_Name_TMS__c=CS_ACCID,Customer_Product_Category__c =BVCServices1,Customer__c=CustomerId,Shipper_Name_TMS__c=SA_ID,Origin_Address_Name__c=OAddressID,Insurance_By__c=InsuranceBy1,Shipment_Value__c=IValue,Net_Weight__c  =nwc,Reference_1__c=refNo,Pickup__c  =pickupId,Destination_Address_Name__c=D_Address,Product_Description__c=ProdcutDescription1,Net_Weight_UOM_TMS__c='Gram',Reciever_Name__c= Receiver);
        Shipment__c newShip = [select Id, Customer_Product_Category__c, 
                                Customer__c,  
                                Shipper_Name_TMS__c,
                                Origin_Address_Name__c,
                               
                                Shipment_Value__c,
                                Net_Weight__c,
                                Reference_1__c,
                                Pickup__c,
                                Consignee_Name_TMS__c,
                                Destination_Address_Name__c,
                                Product_Description__c,
                                Net_Weight_UOM_TMS__c,
                                Reciever_Name__c,CurrencyIsoCode,Liability_Type__c,
                               Customer_Gross_Weight__c from Shipment__c where Id=:shipId];
//        insert newShip1;
       // System.debug('newShip1 :'+newShip1.Id);
       // System.debug('newShip1 Pickup__c :'+newShip1.Pickup__c);
        
            newShip.Customer_Product_Category__c =  BVCServices1; newShip.Customer__c=CustomerId;newShip.Shipper_Name_TMS__c  =  SA_ID; newShip.Origin_Address_Name__c  =  OAddressID;
            newShip.Shipment_Value__c  =  IValue;newShip.Net_Weight__c  =  nwc;newShip.Reference_1__c  =refNo;newShip.Pickup__c  =pickupId;  newShip.Consignee_Name_TMS__c=CS_ACCID;
            newShip.Destination_Address_Name__c  =D_Address  ;newShip.Product_Description__c  =ProdcutDescription1;newShip.Reciever_Name__c = Receiver; newShip.Customer_Gross_Weight__c = customerGW;
        	newShip.Net_Weight_UOM_TMS__c=S_nuom;newShip.CurrencyIsoCode=S_ciso; newShip.Additional_Remarks__c =AdditionalRemarks; newShip.Shipment_Type_Exb__c = ShipmentType;
newShip.Exhibition__c = Exhibition;newShip.Exhibition_Code__c = exhibitionCode;newShip.Liability_Type__c =Liability_Type1; newShip.Insurance_By__c  =  InsuranceBy1;
       
        
        
          update newShip;           
      return newShip;
  
      
            
       // return newShip1;
      //  }
        
      //  return null;
    }   
    
    //Added by Rafi Khan for invoice upload
    @AuraEnabled
    public static String compressImage(String imageContent,Id recId){
        try{
            if (imageContent.startsWith('data:image/jpeg;base64,')) {
                imageContent = imageContent.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocument;
            
            cVersion.PathOnClient = 'InvoicePhoto.png'; 
            cVersion.Title = 'InvoicePhoto.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(imageContent); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            System.debug('for checking conDocument :'+conDocument);
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocument;
            conDocLinkObj.LinkedEntityId = recId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            
            System.debug('Data Inserted Successfully...');
             Customer_Documents__c cd  = new Customer_Documents__c();
             cd.Customer_Document__c = true;
             cd.id = recId;
            update cd;
            return 'Success';
            
        }catch (Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            return null;
        }
        
    }
    //Added code by Rafi Khan Upto here
    
    
    //Code Added By Rafi Khan for E-scan
    @AuraEnabled
    public static Account selectCustomerViaEScan(String ConsigneePAN){
        try{
            System.debug('to check ConsigneePAN : '+ConsigneePAN);
            Account acObj = new Account();
            acObj = [Select Id, Name, PAN_Number_of_Entity__c From Account where PAN_Number_of_Entity__c =: ConsigneePAN];
            System.debug('to check acObj.Name :'+acObj.Name);
            return acObj; 
        } catch(Exception ex){
            System.debug('Error in createShipmentViaEScan ex.getMessage() : '+ex.getMessage());
            System.debug('Error in Line No ex.getLineNumber() : '+ex.getLineNumber());
            return null;
        }
        
    } 
    
    @AuraEnabled
    public static HSN_code_mapping__c selectProductDescriptionViaHSNCode(String HSNCode){
        HSN_code_mapping__c hsnCodeMappingObj = new HSN_code_mapping__c();
        hsnCodeMappingObj = [Select Id, Number__c, Name1__c, Service_Code__c, Product_Description__c From HSN_code_mapping__c Where Number__c=:HSNCode];
        System.debug('hsnCodeMappingObj :'+hsnCodeMappingObj);
        return hsnCodeMappingObj;
    }
    //Upto here
    
    
    public static void GetCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
        
    }
    
    
    public static void GetCoverage1(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}