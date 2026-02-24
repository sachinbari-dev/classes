public without sharing class shipment_Scanner_Helper1 {

    @AuraEnabled
    public static Shipment__c CheckHavePickup(String shippingNoteNumber)
    {
        return [select Id,Name,Shipping_Note_Number__c,Pickup__c,Pickup__r.Name from Shipment__c where Shipping_Note_Number__c=:shippingNoteNumber limit 1];
    }
    
    @AuraEnabled
    public static Shipment__c shipmentRecordGet(String shippingNoteNumber, String pickupID){
        System.debug('11 shippingNoteNumber:'+shippingNoteNumber+' pickupID:'+pickupID);
        Shipment__c shp = new Shipment__c();
        try {
            Pickup__c pk = [select Id,Shipper_Name__c,Customer__c,Origin_Address_Pincode__c,Pickup_Assigned_To__c,Billing_Account__c from Pickup__c where Id=:pickupID limit 1];
            System.debug('Pickup : '+pk);
            if(pk.Pickup_Assigned_To__c==UserInfo.getUserId()){
                Secure_Packaging__c sepk = [select Id,name,Shipment__c,Shipment__r.Shipper_Name_TMS__c,Shipment__r.Customer__c,
                                            Shipment__r.Origin_Address_Pincode__c,Shipment__r.Billing_Account__c
                                            from Secure_Packaging__c where Name=:shippingNoteNumber and 
                                            Shipment__c!=null limit 1];
                
                System.debug('sepk :'+sepk);
                if(pk!=null && sepk!=null){ 
                    System.debug(' pk: '+pk+'\n sepk :'+sepk);
                    if(pk.Shipper_Name__c == sepk.Shipment__r.Shipper_Name_TMS__c && 
                       pk.Origin_Address_Pincode__c == sepk.Shipment__r.Origin_Address_Pincode__c && 
                       pk.Customer__c == sepk.Shipment__r.Customer__c &&
                      sepk.Shipment__r.Billing_Account__c==pk.Billing_Account__c)
                        {
                            shp =  [select Id,Name,Pickup__c,
                                    Customer_Product_Category__c, 
                                    Customer__c,	
                                    Shipper_Name_TMS__c,
                                    Origin_Address_Name__c,
                                    Insurance_By__c,
                                    Shipment_Value__c,
                                    Net_Weight__c,
                                    Reference_1__c,
                                    Consignee_Name_TMS__c,
                                    Cancel_Shipment__c,
                                    RTO__c,
                                    Destination_Address_Name__c,
                                    Product_Description__c,
                                    Net_Weight_UOM_TMS__c,Tracking_Status__c,
                                    Reciever_Name__c,Shipment_Created_Through__c,
                                    Customer_Gross_Weight__c,Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c
                                    from Shipment__c where Id=:sepk.Shipment__c and CreatedDate >= LAST_N_DAYS:7 and Pickup__c !=null limit 1];
    							System.debug('<== Shipment :'+shp);
                            if((shp.Pickup__c==null|| shp.Pickup__c=='') && (shp.Tracking_Status__c!='Picked Up')){
                                //shp.Pickup__c=pickupID;
                                shp.Created_Through_Scan_Shipment__c=true;                            
                                update shp;
                            }
                            
                            String UserId = UserInfo.getUserId();
                            try
                            {
                                Shipment__Share shipshare =[select Id from Shipment__Share where UserOrGroupId=:UserId and ParentId=:shp.Id limit 1];
                            }
                            catch(Exception e)
                            {                           
                                System.debug('Shipment Sharing By');                            
                                Shipment__Share newSh = new Shipment__Share(); 
                                newSh.UserOrGroupId=UserId; newSh.AccessLevel='Edit'; newSh.ParentId=shp.Id; newSh.RowCause='Manual';
                                insert newSh;  
                                System.debug('After Shipment Sharing By');
                            }                                        
                        }
                    else {return null;}
                }                
            }
            else { return null; }
            
        }
        catch(Exception e)   
        { }
        System.debug('shp : '+shp);        
        return shp!=null?shp:null;        
    }
    @AuraEnabled
    public static boolean  checkRecordAccess(String recId)
    {
        boolean  access;
        if(recId!=null)
        {
            UserRecordAccess rec = [ SELECT RecordId, HasReadAccess 
                                    FROM UserRecordAccess 
                                    WHERE UserId =:UserInfo.getUserId() AND RecordId =: recId limit 1];
            access = rec.HasReadAccess==true?true:false;            
        }        
        return access;
    }    
}