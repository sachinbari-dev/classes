/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TMS_DeliveryListView { //3he7f4j57k

    @AuraEnabled
    public static boolean calculateDelivery(String recId)
    {
        Boolean res=false;
        	Delivery_Address_Stop__c das = [select Id,(select Id,Number_of_Packages__c,Number_of_Shipments__c,
                                                       (select Id,Number_of_Packagess__c from Delivery_Lines__r) from Deliveries__r ),
                                            Number_of_Packages__c,Number_of_Shipments__c
                                            from Delivery_Address_Stop__c where Id=:recId limit 1];
        System.debug('');
        	if(das!=null)
            {
                if(das.Deliveries__r!=null)
                {
                    List<Delivery__c> delList2Update = new List<Delivery__c>();
                    for(Delivery__c d:das.Deliveries__r)
                    {
                        Delivery__c DD = bulkProcess(d);
                        if(DD.Number_of_Packages__c!=d.Number_of_Packages__c || DD.Number_of_Shipments__c!=d.Number_of_Shipments__c)
                        {
                           delList2Update.add(DD);
                        }
                    }
                    if(delList2Update.size()>0)
                    {
                        update delList2Update;
                    }
                    Decimal NP = das.Number_of_Packages__c;
            		Decimal NS = das.Number_of_Shipments__c;
                    das.Number_of_Packages__c=0;
                    das.Number_of_Shipments__c = 0;
                    for(Delivery__c d:das.Deliveries__r)
                    {
                        das.Number_of_Packages__c = das.Number_of_Packages__c + d.Number_of_Packages__c;
                        das.Number_of_Shipments__c = das.Number_of_Shipments__c + d.Number_of_Shipments__c;
                    }
                    
                    if(NP!=das.Number_of_Packages__c || NS!=das.Number_of_Shipments__c)
                    {
                        update das;
                        res = true;
                    }
                }
            }
        return res;
    }
    
    public static Delivery__c bulkProcess(Delivery__c D)
    {
        System.debug('Del :'+D); /*
         Delivery__c D = [select Id,Name,Number_of_Packages__c,Number_of_Shipments__c,
                                     (select Id,Number_of_Packagess__c from Delivery_Lines__r) 
                                     from Delivery__c where Id=:Del.Id limit 1]; */
            Decimal NP = D.Number_of_Packages__c;
            Decimal NS = D.Number_of_Shipments__c;
            if(D.Delivery_Lines__r.size()>0)
            {
                D.Number_of_Packages__c=0;
                for(Delivery_Line__c dr :D.Delivery_Lines__r)
                {
                   D.Number_of_Packages__c = D.Number_of_Packages__c + dr.Number_of_Packagess__c;
                }
                D.Number_of_Shipments__c = D.Delivery_Lines__r.size();
            }          
        return D;
    }
    @AuraEnabled
    public static boolean calculateDas(String recordId)
    {
        Boolean res=false;
        Delivery__c D = [select Id,Name,Number_of_Packages__c,Number_of_Shipments__c,
                                     (select Id,Number_of_Packagess__c from Delivery_Lines__r) 
                                     from Delivery__c where Id=:recordId limit 1];
        
        if(D!=null)
        {
            Decimal NP = D.Number_of_Packages__c;
            Decimal NS = D.Number_of_Shipments__c;
            if(D.Delivery_Lines__r.size()>0)
            {
                D.Number_of_Packages__c=0;
                for(Delivery_Line__c dr :D.Delivery_Lines__r)
                {
                   D.Number_of_Packages__c = D.Number_of_Packages__c + dr.Number_of_Packagess__c;
                }
                D.Number_of_Shipments__c = D.Delivery_Lines__r.size();
            }
            if(NP!=D.Number_of_Packages__c || NS!=D.Number_of_Shipments__c)
            {
                update D;
                res = true;
            }            
        }
        return res;
    }
    @AuraEnabled(cacheable=true)
    public static List<Shipment__c> getIncopletedShipments()
    {
        return [select Id,Name,Shipping_Note_Number__c,Destination_Address_Name__c,Destination_Address_Name__r.Name,Delivery_Reject_Reasons__c,
                Reciever_Name__c,Reciever_Name__r.Name from Shipment__c where Tracking_Status__c='Undelivered' and Delivery_Route_Assigned_To__c=:userInfo.getUserId() ];
        // return null;
    }
        @AuraEnabled
    public static String completeDeliveries(List<Secure_Bag__c> secureBagList,Map<String,String> shipmentsMap,String designation)
    {
        System.debug('13 secureBagList :'+secureBagList);
        System.debug('13 shipmentsMap :'+shipmentsMap);
        String result='fail'; 

        Set<String> shipIdList = new Set<String>();
        Set<String> delIdList = new Set<String>();
        List<Shipment_Tracking__c> shiTrackList = new List<Shipment_Tracking__c>();
        List<Secure_Bag__c> secureBagList2Update = new List<Secure_Bag__c>();
        List<Shipment__c> shipList = new List<Shipment__c>();
        List<Delivery__c> delList = new List<Delivery__c>();
        
        Set<String> particalDelIds = new Set<String>();
        if(secureBagList!=null || shipmentsMap!=null)
        {    
            try
            {
                if(secureBagList!=null)
                {
                    for(Secure_Bag__c sb : secureBagList)
                    {
                        sb.Current_Scan_Loction__c ='Delivered';
                        if(sb.Shipment__c!=null) 
                        {
                            shipIdList.add(sb.Shipment__c);
                        }
                    }
                    System.debug('33 shipIdList :'+shipIdList);
                    shipList = [select Id,Tracking_Status__c,Delivery_Attempts__c,Delivery_Reject_Reasons__c from Shipment__c where Id IN : shipIdList];
                    for(Shipment__c sh : shipList)
                    {
                        Shipment_Tracking__c track =  new Shipment_Tracking__c();
                        sh.Tracking_Status__c='Delivered';
                        track.Location__c = 'Delivered';
                        if(sh.Delivery_Reject_Reasons__c != null || sh.Delivery_Reject_Reasons__c == ''){
                            track.Remarks__c = 'Attempt '+sh.Delivery_Attempts__c+' failed due to :: '+sh.Delivery_Reject_Reasons__c;
                        }
                        track.Shipment__c = sh.Id;
                        track.Scan_Time__c = System.now();
                        shiTrackList.add(track);                            
                    }
                    System.debug('44 shipList :'+shipList);
                    System.debug('45 shiTrackList :'+shiTrackList);
                    List<Delivery_Line__c> DL_List = [select Id,Name,Shipment__c,Consignee_Designation__c,Status__c, Delivery__c from Delivery_Line__c where Shipment__c IN : shipIdList];
                    List<Delivery_Line__c> DL_List2Update  = new List<Delivery_Line__c>();
                    for(Delivery_Line__c dl :DL_List)
                    {
                        if(dl.Delivery__c!=null){
                            delIdList.add(dl.Delivery__c);
                            dl.Status__c ='Delivered';
                            DL_List2Update.add(dl);
                            dl.Consignee_Designation__c = designation;
                        }
                    }
                    System.debug('51 DL_List :'+DL_List);
                    System.debug('52 delIdList :'+delIdList);
                    if(delIdList!=null)
                    {
                        delList = [select Id,Status__c from Delivery__c where Id IN :delIdList];
                        for(Delivery__c d : delList)
                        {
                            d.Status__c ='Delivered';
                        }
                    } 
                    
                    List<Secure_Bag__c> sbList2Update = [select Id,Current_Scan_Loction__c from Secure_Bag__c where Shipment__c IN : shipIdList];
                    if(sbList2Update!=null)
                    {
                        for(Secure_Bag__c sbb:sbList2Update)
                        {
                            sbb.Current_Scan_Loction__c = 'Delivered';
                        }
                        update sbList2Update;
                    }
                    // shipIdList
                   // update secureBagList;
                    if(shipList!=null){update shipList; insert shiTrackList;}
                    if(delList!=null){
                        update delList;
                        update DL_List2Update;
                    }
                    result = 'success';
                }            
                // shipmentsMap Contains Rejected Shipments with Reason
                if(shipmentsMap!=null)
                {
                    List<Shipment__c> shipL = [select Id,Tracking_Status__c,Delivery_Reject_Reasons__c 
                                               from Shipment__c where Id IN : shipmentsMap.keySet()];
                    for(Shipment__c s : shipL)
                    {
                        String reason = shipmentsMap.get(s.Id);
                        s.Delivery_Reject_Reasons__c = reason;
                        s.Tracking_Status__c = 'Undelivered';
                    }
                    if(shipL!=null)
                    {
                        update shipL;
                        List<Delivery_Line__c> DL_List2Unlink = [select Id,Status__c,Name,Shipment__c, Delivery__c from Delivery_Line__c where Shipment__c IN : shipmentsMap.keySet()];
                        for(Delivery_Line__c dl:DL_List2Unlink)
                        {
                          // dl.Shipment__c=null; 
                          dl.Status__c ='Undelivered';
                          particalDelIds.add(dl.Delivery__c);
                        }
                        update DL_List2Unlink;
                    }
                } 
                if(particalDelIds!=null)
                {
                   List<Delivery__c> parDelList = [select Id,Status__c from Delivery__c where Id IN :particalDelIds]; 
                    if(parDelList!=null)
                    {
                        for(Delivery__c d:parDelList)
                        {
                            d.Status__c ='Partially Delivered';
                        }
                        update parDelList;
                    }
                }
                System.debug('766666666666 :');
                result = 'success';
            }catch(exception e)
            {
                System.debug('79 getMessage() :'+e.getMessage());
               result+=e.getMessage(); 
            }
        } 
        return result;
    }
	// new method need to Implement Delivery Cancell
  /*  public static void DeliveryUpdate(Map<String,String> DelMap)
    {
        try
        {
        List<Delivery__c> DeliveryList = [select Id,Status__c,(select Id from Delivery_Lines__r where Shipment__c!=null) from Delivery__c where Id IN : DelMap.keySet()];
        List<Delivery__c> DeliveryList2Update = new List<Delivery__c>();
        for(Delivery__c d:DeliveryList)
        {
            if(d.Delivery_Lines__r.size()==0){
                d.Status__c ='Cancelled'; DeliveryList2Update.add(d);
            }            
        }
        if(DeliveryList2Update.size()>0){update DeliveryList2Update;}
        }catch(exception e){}
    }
    */
    @AuraEnabled
    public static List<Shipment__c> getShipments(String delId)
    {
        List<String> ShipmentId = new List<String>(); 
        List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
        List<Delivery_Line__c> DLList = [select Id,Shipment__c,Delivery__c from Delivery_Line__c where 
                                         Delivery__c =: delId];
        for(Delivery_Line__c dli: DLList)
        {
            ShipmentId.add(dli.Shipment__c);   
        }

        List<Shipment__c> shipList = [select Id,Name,Tracking_Status__c,Shipping_Note_Number__c,Delivery_Reject_Reasons__c,
                                      (SELECT Id, Name, Shipment__c,Scanning_Status__c,Current_Scan_Loction__c,
                                       Shipping_Note_Number__c,Secure_Packaging_Identifier__c FROM SecureBags__r) 
                                      from Shipment__c where Id IN : ShipmentId];
        
        return shipList;
    }
    @AuraEnabled
    public static List<Secure_Bag__c> getSB_ByDelivery(String delId)
    {
     List<String> ShipmentId = new List<String>(); 
        List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
        List<Delivery_Line__c> DLList = [select Id,Shipment__c,Delivery__c from Delivery_Line__c where 
            Delivery__c =: delId];
            for(Delivery_Line__c dli: DLList)
            {
                 ShipmentId.add(dli.Shipment__c);   
            }

            System.debug('ShipmentId.size() '+ShipmentId.size());
            if(ShipmentId.size() > 0){
                secureBagList = [
                    SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, 
                    Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                    FROM Secure_Bag__c WHERE  Shipment__c IN: ShipmentId ]; 

            }         
       return secureBagList;
    }
    @AuraEnabled
    public static List<Delivery__c> getAcceptedDeliveries()
    {
        List<Delivery__c> delList = [select Id,Name,Status__c,Address__c,Address__r.Name,Shipper_Address__c,OTP__c,Address__r.BulkDelivery__c,
                                     Delivery_Address_Stop__c,Delivery_Address_Stop__r.Name,CreatedDate,Consignee_Account__c,Consignee_Account__r.OTP_Required__c,
                                     Shipper_Email__c,Shipper_Contact__c,OwnerId,Owner.Name,Consignee_Email__c,Consignee_Contact__c,Consignee_Contact_Person__c,
                                     Shipper_Address__r.Name,(select Id,Shipment__c,Shipment__r.Shipper_Name_TMS__c,Shipment__r.Shipper_Name_TMS__r.Name from Delivery_Lines__r where Shipment__c!=null and Status__c!='Delivered' and Status__c!='Undelivered') 
                                     from Delivery__c where OwnerId =: UserInfo.getUserId () and Status__c='Accepted'  and
                                    Id IN (SELECT Delivery__c FROM Delivery_Line__c where Shipment__c!=null) and Delivery_Address_Stop__c!=null ORDER BY CreatedDate DESC];
        
        return delList;
    }
        @AuraEnabled
    public static List<Delivery_Line__c> viewAllDeliveryLines(){
        return [select Id,Name,Shipment__c, Customer_Name__c,Shipping_Note_Number__c from Delivery_Line__c 
                where OwnerId =: UserInfo.getUserId () and Delivery__c=null 
                and Shipment__c!=null and Shipment__r.Number_of_Secure_Bags__c>0 and Status__c!='Delivered' and Status__c!='Undelivered'];
    } 

    @AuraEnabled
    public static List<Secure_Bag__c> getSecureBags(List<Delivery_Line__c> deliveryLinesList){
        System.debug('62 deliveryLinesList :'+deliveryLinesList);
        List<Secure_Bag__c> secureBagList  = new List<Secure_Bag__c>();
        if(deliveryLinesList.size()>0)
        {
            List<String> shipIdList = new List<String>();
            for(Delivery_Line__c dl :deliveryLinesList)
            {
                if(dl.Shipment__c!=null)
                {
                   shipIdList.add(dl.Shipment__c);
                }
            }
            System.debug('62 shipIdList :'+shipIdList);
            if(shipIdList.size() > 0){
                secureBagList = [
                    SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, 
                    Secure_Packaging_Identifier__c , Current_Scan_Loction__c
                    FROM Secure_Bag__c 
                    WHERE Current_Scan_Loction__c != 'Delivered' AND Current_Scan_Loction__c != 'Out for Delivery' AND
                    Shipment__c IN: shipIdList
                ]; 
            }
        }
        System.debug('62 secureBagList :'+secureBagList);
        return secureBagList;
    }

    @AuraEnabled
    public static ShipmetWrap bagBySecureBagId(String bagId){        
        try { 
            System.debug('93 bagId :'+bagId);
            ShipmetWrap ShipmetWrapData = new ShipmetWrap();            
            Map<String,Secure_Bag__c> shipmentRecord = new Map<String,Secure_Bag__c>();
            
            if(bagId != null && bagId != ''){
                for(Secure_Bag__c secureBag : [
                    SELECT Id, Name , Shipment__c,Shipment__r.Tracking_Status__c, Shipping_Note_Number__c, 
                    Secure_Packaging_Identifier__c,Shipment__r.Delivery_Route_Assigned_To__c, Current_Scan_Loction__c,
                    Secure_Bag__r.Name, Current_Scan_Date_and_Time__c, Scanning_Status__c
                    FROM Secure_Bag__c 
                    WHERE Secure_Bag__r.Name =: bagId LIMIT 1
                ]){ 
            		System.debug('93 secureBag :'+secureBag);        
                    if(secureBag.Shipment__r.Delivery_Route_Assigned_To__c != UserInfo.getUserId() && secureBag.Current_Scan_Loction__c == 'Delivered'){
                        
                        System.debug('Insufficient access rights on '+bagId);
                        
                    }else{
                        shipmentRecord.put(secureBag.Secure_Bag__r.Name, secureBag);
                        System.debug('for checking shipmentRecord.values() :'+shipmentRecord.values());
                    }
                }
            }
            System.debug('93 shipmentRecord :'+shipmentRecord);
            if(!shipmentRecord.isEmpty()){
                
                ShipmetWrapData.shipmentRecordMap = shipmentRecord; 
                    
                    Secure_Bag__c bag = new Secure_Bag__c();
                    if(shipmentRecord.containsKey(bagId)){
                        bag.Id = shipmentRecord.get(bagId).Id;
                        bag.Scanning_Status__c = 'Scanned'; 
                        bag.Current_Scan_Date_and_Time__c = DateTime.now();
                        bag.vaults__c = null;
                        Database.Update(Bag);
                        System.debug('93 Bag :'+Bag);
                    } 
            }else{
                //errorData = 'This bag is not associated with shipment';
                throw new AuraHandledException('This bag is not associated with shipment');
                
            }
            System.debug('Data return successfully'+ShipmetWrapData);
            return ShipmetWrapData;
            
        } catch (Exception ex) {
            //throw new AuraHandledException('Error Message : '+ex.getMessage());
            System.debug('exception cought message '+ex.getMessage());
            System.debug('exception cought in line number '+ex.getLineNumber());
            return null;

        }
    }

  @AuraEnabled
    public static Delivery__c updateContactDetails(String shipId, String DelId){
        Shipment__c sh = new Shipment__c();
         Contact con = new Contact();
        Delivery__c d = new Delivery__c();
        try
        {
           sh = [select Id,Reciever_Name__c,Reciever_Name__r.Name from Shipment__c where Id=:shipId limit 1];
            if(sh!=null)
            {
                con = [select Id,MobilePhone,Email,Name from Contact where Id =: sh.Reciever_Name__c limit 1];
                d = [select Id,Consignee_Contact_Person__c,Consignee_Contact__c,Consignee_Email__c,OTP__c
                                 from Delivery__c where Id=:DelId limit 1];
                d.Consignee_Contact_Person__c = con.Name;
                d.Consignee_Contact__c = con.MobilePhone;
                d.Consignee_Email__c = con.Email;
                update d;
                List<String> deliveryIdList = new List<String>();
                deliveryIdList.add(d.Id);
                d.OTP__c = resendOtp(deliveryIdList);
                 
            } 
        }catch(exception e)
        {
            System.debug('254 e'+e.getMessage());
        }
        
        return d;
    }
    // new method added by imran
    @AuraEnabled
    public static String resendOtp(List<String> deliveryIdList){
        System.debug('329 deliveryIdList :'+deliveryIdList);
        String result;
        try
        {
            List<OTPGenerator.AcceptDeliveryWrapper> objList = new List<OTPGenerator.AcceptDeliveryWrapper>();
            for(String s:deliveryIdList)
            {
                OTPGenerator.AcceptDeliveryWrapper obj1 = new OTPGenerator.AcceptDeliveryWrapper();
                obj1.deliveryId = s; 
                objList.add(obj1);
            }
            System.debug('340 objList :'+objList);
            if(objList.size()>0)
            {
                OTPGenerator.otpGenerator(objList); 
                Delivery__c del = [select Id,Name,OTP__c,Consignee_Email__c,Consignee_Contact__c,
                                   OwnerId,Owner.Name
                                   from Delivery__c where Id=:deliveryIdList[0] limit 1];
                result=del.OTP__c;
                User u = [ SELECT Id, Name, Employee_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
                String jsonBody = '{' +
                '"deliveryId":"'+del.Name+'",' +
                '"PhoneNo":"'+del.Consignee_Contact__c+'",' +
                '"emailID":"'+del.Consignee_Email__c+'",' +
                '"OTP":"'+del.OTP__c+'",' +
                '"EscorterName":"'+del.Owner.Name+'",' +
                '"EscorterNumber":"'+u.Employee_Code__c+'"' + '}';
                System.debug('jsonBody :'+jsonBody);
                SendOutBoundOtp.resendOTP(jsonBody);
                
            }           
        }catch(exception e)
        {
            System.debug('348 e.getMessage() :'+e.getMessage());
            result ='Fail '+e.getMessage();
        }
        return result;
    }
// new method added by imran
    @AuraEnabled
    public static String acceptDeliveryRecordsUpdated(List<String> delIds){
        System.debug('#### 149 delIds '+delIds);
        String resultStatus='';
        List<String> deliveryIdList = new List<String>();        
        List<Delivery__c> delList = new List<Delivery__c>();
        List<Delivery__c> delListToUpdate = new List<Delivery__c>();
        try{
		List<Delivery_Line__c> DL_List = [select Id,Name,Shipment__c, Customer_Name__c,Shipping_Note_Number__c,
                                          Shipment__r.Consignee_Name_TMS__r.Name,
                                          Shipment__r.Destination_Address_Name__r.Name,
                                          Shipment__r.Reciever_Name__c,Shipment__r.Reciever_Name__r.Name,
                                          Shipment__r.Destination_Address_Name__c,
                                          Shipment__r.Consignee_Name_TMS__c,
                                          Shipment__r.Destination_Address_PhoneNo__c,
                                          Shipment__r.Destination_Address_Email1__c,
                                          Shipment__r.Estimated_Delivery_Datetime__c,
                                          Shipment__r.Delivery_Route_Assigned_To__c,
                                          Shipment__r.Origin_Address_Name__c,
                                          Shipment__r.Origin_Address_PhoneNo__c,
                                          Shipment__r.Origin_Address_Email1__c,
                                          Shipment__r.Shipping_Note_Number__c
                                          from Delivery_Line__c where Id IN : delIds];
         System.debug('#### 149 DL_List '+DL_List);
            if(DL_List!=null)
            {
                List<Delivery__c> delList2Create = new List<Delivery__c>();
              List<Delivery_Line__c> DList = new List<Delivery_Line__c>();
              List<String> shipIdList = new List<String>();
              Map<String,List<Delivery_Line__c>> delMap = new Map<String,List<Delivery_Line__c>>();
              for(Delivery_Line__c dl :DL_List)  
              {
                  String mapKey = dl.Shipment__r.Consignee_Name_TMS__c+'_'+dl.Shipment__r.Destination_Address_Name__c+'_'+dl.Shipment__r.Reciever_Name__c;
                  System.debug('#### 149 mapKey '+mapKey);
                  if(delMap==null)
                  {
                      DList.add(dl);
                      delMap.put(mapKey,DList);
                  }
                  else
                  {
                      if(delMap.containsKey(mapKey))
                      {
                    	List<Delivery_Line__c> DLL = delMap.get(mapKey);
                        DLL.add(dl);
                      }
                      else
                      {
                          List<Delivery_Line__c> NewDlist = new List<Delivery_Line__c>();
                          NewDlist.add(dl);
                          delMap.put(mapKey,NewDlist);
                      }					
                  }
                  shipIdList.add(dl.Shipment__c);
              }
               if(delMap.size()>0)
               {
                   List<Delivery_Line__c> DList2Udate = new List<Delivery_Line__c>();
                  for(String skey:delMap.keySet()) 
                  {
                      List<Delivery_Line__c> InnerDList = delMap.get(skey);
                      integer i=1;
                      Delivery__c singleDL = new Delivery__c();
                      for(Delivery_Line__c dline:InnerDList)
                      {       
                          System.debug('#### 149 dline '+dline);
						if(i==1)                
                        {                                
                            singleDL.Address__c=dline.Shipment__r.Destination_Address_Name__c;
                            singleDL.Consignee_Account__c = dline.Shipment__r.Consignee_Name_TMS__c;
                            singleDL.Consignee_Contact__c = dline.Shipment__r.Destination_Address_PhoneNo__c;
                            singleDL.Consignee_Email__c = dline.Shipment__r.Destination_Address_Email1__c;
                            singleDL.Estimated_Delivery_Datetime__c = dline.Shipment__r.Estimated_Delivery_Datetime__c;
                            singleDL.OwnerId = dline.Shipment__r.Delivery_Route_Assigned_To__c;
                            singleDL.Shipper_Address__c = dline.Shipment__r.Origin_Address_Name__c;
                            singleDL.Shipper_Contact__c = dline.Shipment__r.Origin_Address_PhoneNo__c;                  
                            singleDL.Shipper_Email__c = dline.Shipment__r.Origin_Address_Email1__c;
                            singleDL.Shipping_Note_Numbers__c = dline.Shipping_Note_Number__c;
                            singleDL.Status__c = 'Accepted'; 
                            singleDL.Reciever_Name__c = dline.Shipment__r.Reciever_Name__c;
                            singleDl.Consignee_Contact_Person__c = dline.Shipment__r.Reciever_Name__r.Name;
                            
                            singleDl.OwnerId = UserInfo.getUserId();
                            System.debug('#### 149 singleDl '+singleDl);
                        }
                          else{
                              singleDL.Shipping_Note_Numbers__c = singleDL.Shipping_Note_Numbers__c+';'+dline.Shipping_Note_Number__c;
                          }
                          i=i+1;
                      }
                      System.debug('#### 149 AA singleDl '+singleDl);
                      if(singleDL!=null)
                      {
                          System.debug('#### 149 delList2Create '+delList2Create);
                          delList2Create.add(singleDL);
                      }
                      
                  }
                   if(delList2Create.size()>0)
                   {
                       System.debug('341111111111 delList2Create:'+delList2Create[0].OwnerId);
                       insert delList2Create;
                       System.debug('341111111111');
                       TMS_DeliveryListViewHelper.CreateDeliveryStop(delList2Create); 
                       List<Delivery_Line__c> deliveryList2Update = new List<Delivery_Line__c>();
                       for(Delivery__c d:delList2Create)
                       {
                           String getKey = d.Consignee_Account__c+'_'+d.Address__c+'_'+d.Reciever_Name__c;
                           List<Delivery_Line__c> deliveryList = delMap.get(getKey);
                           for(Delivery_Line__c dline : deliveryList)
                           {
                              dline.Delivery__c = d.Id;
                              deliveryList2Update.add(dline);
                           }
                           deliveryIdList.add(d.Id);
                       }
                       update deliveryList2Update; 
                       resultStatus = 'Success';
                   }
               }
               List<Shipment__c> shipList = [select Id,Name,Tracking_Status__c,Delivery_Attempts__c from Shipment__c where Id IN : shipIdList]; 

                    System.debug('215 shipList :'+shipList);
                    if(shipList.size()>0)
                    {
                        List<Shipment_Tracking__c> shiTrack = new List<Shipment_Tracking__c>();
                        for(Shipment__c sh : shipList)
                        {
                            if(sh.Delivery_Attempts__c==null){
                                sh.Delivery_Attempts__c = 0;
                            }
                            Shipment_Tracking__c track =  new Shipment_Tracking__c();
                            sh.Tracking_Status__c='Out for Delivery';
                            sh.Delivery_Attempts__c = sh.Delivery_Attempts__c + 1;
                            track.Location__c = 'Out for Delivery';
                            track.Shipment__c = sh.Id;
                            track.Scan_Time__c = System.now();
                            shiTrack.add(track);                            
                        }
                        update shipList;
                        insert shiTrack;
                    }
                
               List<Secure_Bag__c> sbList = [select Id,Current_Scan_Loction__c from Secure_Bag__c where Shipment__c IN : shipIdList];
                    System.debug('215 sbList :'+sbList);
                    if(sbList.size()>0)
                    {
                        for(Secure_Bag__c sb:sbList)
                        {
                            sb.Current_Scan_Loction__c='Out for Delivery';
                        }
                        update sbList;
                    }
                
                List<OTPGenerator.AcceptDeliveryWrapper> objList = new List<OTPGenerator.AcceptDeliveryWrapper>();
                for(String s:deliveryIdList)
                {
                    OTPGenerator.AcceptDeliveryWrapper obj1 = new OTPGenerator.AcceptDeliveryWrapper();
                    obj1.deliveryId = s; 
                    objList.add(obj1);
                }
                System.debug('215 objList :'+objList);
                if(objList.size()>0)
                {
                    OTPGenerator.otpGenerator(objList); 
                }
                
            }
         
        }catch(Exception ex){
            System.debug('Error message in accepting deliveries '+ex.getMessage());
            System.debug('Error Line Number in accepting deliveries '+ex.getLineNumber());
            resultStatus = 'Error :'+ex.getMessage();
 
        } 
        return resultStatus;
    }

    
    @AuraEnabled
    public static List<Delivery__c> acceptDeliveryRecords(List<String> snnListFormJS){
        System.debug('#### snnListFormJS '+snnListFormJS);
        List<Delivery__c> delList = new List<Delivery__c>();
        List<Delivery__c> delListToUpdate = new List<Delivery__c>();
        try{

        delList = [Select Id,Name,Status__c,Shipping_Note_Number__c From Delivery__c Where Shipping_Note_Number__c IN : snnListFormJS];
        System.debug('#### delList in Accept Deliveries '+delList);		
        for(Delivery__c dObj : delList){
            Delivery__c delObj = new Delivery__c();
            delObj.Id = dObj.Id;
            delObj.Status__c = 'Accepted';
            delListToUpdate.add(delObj);
        }
        System.debug('#### delListToUpdate.size() in Accept Deliveries '+delListToUpdate.size());
        if(delListToUpdate.size()>0){
            System.debug('#### delListToUpdate in Accept Deliveries '+delListToUpdate);
            Database.update(delListToUpdate);
        }
        return delListToUpdate;
        }catch(Exception ex){
            System.debug('Error message in accepting deliveries '+ex.getMessage());
            System.debug('Error Line Number in accepting deliveries '+ex.getLineNumber());
            return null;
        }
    }

    @testVisible class ShipmetWrap{
        
        @AuraEnabled
        public Map<String,Secure_Bag__c> shipmentRecordMap {get;set;}
        
    } 
// SIGNATURE STORE
    @AuraEnabled
    public static String saveSignatureFile(Id parentId, String base64Data,List<String> shipList) {
        String result='Error';
        try
        {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Signature';
            cv.PathOnClient = 'Signature.png';
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            insert cv;
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            for(String shipId : shipList)
            {                
                ContentDocumentLink cdl = new ContentDocumentLink();
                // cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ].ContentDocumentId;
                cdl.ContentDocumentId = conDocId;
                cdl.LinkedEntityId = shipId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                cdList.add(cdl);
            }
            // insert cdl;   
            if(cdList!=null) { insert cdList;}
            result ='success';
        }catch(exception e)
        {
           result =e.getMessage(); 
        }
        
        return result;
    }
    
    // upload POD
    
    @AuraEnabled
    public static Boolean savePODPhoto(String sbId, String fileData){
        Boolean isWindow = false;
        System.debug('5244444 shipList :'+sbId);
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'POD photo ID.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'POD photo ID.png';
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            
            Insert cVersion;    
            System.debug('646 cVersion :'+cVersion);
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            if(sbId!=null){
                updateSBPhoto(conDocId, sbId); 
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
            return false;
        }               
    }
    public static void updateSBPhoto(String contentDocId, String sbId){
        try{
            List<Shipment__c> updateShipmentList = new List<Shipment__c>();
            System.debug('666 ww sbId :'+sbId);
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();             
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = sbId; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);               
                
            System.debug('5244444 ww contentDocumentList :'+contentDocumentList);
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
            } 
        }catch(Exception ex){
            System.debug('680. Error occure Line Number '+ex.getLineNumber());
            System.debug('681. Error occure Message '+ex.getMessage());
        }
    }
    
    //to upload Receiver Photo on Shipments
    @AuraEnabled
    public static Boolean saveReceiverIdPhoto(List<String> shipList, String fileData){
        Boolean isWindow = false;
        System.debug('5244444 shipList :'+shipList);
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'Receiver photo ID.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'Receiver photo ID.png';
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            
            Insert cVersion;    
            System.debug('5244444 cVersion :'+cVersion);
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            if(shipList.size()>0){
                updateReceiverIdPhoto(conDocId, shipList, false); 
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
            return false;
        }               
    }    
    
    public static void updateReceiverIdPhoto(String contentDocId, List<String> shipList, Boolean isWindow){
        try{
            List<Shipment__c> updateShipmentList = new List<Shipment__c>();
            set<String> shipmentId = new Set<String>();
            System.debug('5244444 ww shipList :'+shipList);
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(String shipmentObj : shipList){
                shipmentId.add(shipmentObj);
            } 
            
            for(Id linkedEntity : shipmentId){
                System.debug('5244444 ww linkedEntity :'+linkedEntity);
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink);
                
                Shipment__c shipObj = new Shipment__c();
                shipObj.Id = linkedEntity; 
                shipObj.RecieverIDPhoto__c=true;
                updateShipmentList.add(shipObj);
                
            }
            System.debug('5244444 ww contentDocumentList :'+contentDocumentList);
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
                if(updateShipmentList.size() > 0 ){
                   //  Update updateShipmentList;
                }
            } 
            
            
        }catch(Exception ex){
            System.debug('1111. Error occure Line Number '+ex.getLineNumber());
            System.debug('2222. Error occure Message '+ex.getMessage());
        }
    }
// Save Images on Delivery Lines

        @AuraEnabled
    public static Boolean saveDeliveryLinesPhoto(List<String> shipList, String fileData){
        System.debug('602 saveDeliveryLinesPhoto shipList:'+shipList);
        Boolean isWindow = false;
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.ContentLocation = 'S';  
            cVersion.PathOnClient = 'POD photo.png'; 
            cVersion.Origin = 'H';  
            cVersion.Title = 'POD photo.png';
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            
            Insert cVersion;    
            System.debug('602 saveDeliveryLinesPhoto cVersion:'+cVersion);
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            if(shipList.size()>0){
                updateDeliveryLinesPhoto(conDocId, shipList, false); 
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
            
            return false;
        }               
    }    
    
    public static void updateDeliveryLinesPhoto(String contentDocId, List<String> shipList, Boolean isWindow){
        try{
            List<Shipment__c> updateShipmentList = new List<Shipment__c>();
            set<String> shipmentId = new Set<String>();
            String shipId;
            String dlId;
            List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
            for(String shipmentObj : shipList){
                shipmentId.add(shipmentObj);
                shipId = shipmentObj;
            } 
            
            List<Delivery_Line__c> dllList = [select Id from Delivery_Line__c where Shipment__c IN : shipmentId ];
            
            for(Delivery_Line__c linkedEntity : dllList){
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = contentDocId; 
                cDocLink.LinkedEntityId = linkedEntity.Id; 
                cDocLink.ShareType = 'V'; 
                cDocLink.Visibility = 'AllUsers';
                contentDocumentList.add(cDocLink); 
                dlId= linkedEntity.Id; 
            }
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                mapLinks(shipId,dlId,contentDocId);
            } 
            
            
        }catch(Exception ex){
            System.debug('1111. Error occure Line Number '+ex.getLineNumber());
            System.debug('2222. Error occure Message '+ex.getMessage());
        }
    }
    
    public static void mapLinks(String shipId,String dlId,String contentDocId)
    {
        // ContentVersion cv = [select Id,ContentDownloadUrl from ContentVersion where ContentDocumentId =: contentDocId limit 1];
        try
        {
            ContentDistribution cd = [select Id,ContentDownloadUrl from ContentDistribution where ContentDocumentId=:contentDocId limit 1];
            Shipment__c ship  = [select Id,POD_Link_Url__c,POD__c from Shipment__c where Id=:shipId limit 1];
            Delivery_Line__c DlRecord = [select Id,POD_Link_Url__c from Delivery_Line__c where Id=:dlId limit 1];
            ship.POD_Link_Url__c = cd.ContentDownloadUrl;
            if(ship.POD__c!=true){ship.POD__c=true;}
            DlRecord.POD_Link_Url__c = cd.ContentDownloadUrl;
            update DlRecord;
            update ship;
        }catch(exception e)
        {
            
        }        
    }

@AuraEnabled
    public static void saveSBImage( String base64Data, String fileName, Id linkedId ) {
        Blob imageBlob = EncodingUtil.base64Decode(base64Data);

        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = imageBlob;
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ].ContentDocumentId;
        cdl.LinkedEntityId = linkedId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    

    //Added by Rafi Khan to get loggedIn user Name to save on receiverId.
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
	//upto here

}