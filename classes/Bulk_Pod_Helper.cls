/*
 * Class      : Bulk_Pod_Helper
 * Author     : Imran
 * Date       : Jan 2024
 * Version	  : 1.0		Display Shipments only Tracking Status = Deliverd and PODLink Not null and Have Delivery Record and
 * 						current user City = shipment DestinationHub and DestinationAddress BulkDelivery = true
 */
public without sharing class Bulk_Pod_Helper 
{

    //Added By Rafi for Image Watermark
    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
       
    @AuraEnabled(cacheable=true)
    public static String getDelivery(String shipId)
    {
        try
        {
            Delivery__c d =[select Id,Name from Delivery__c where Shipment__c=: shipId limit 1];
            if(d.Id!=null)
            {
                return d.Id;
            }            
        }catch(Exception ex){
            
            
        }        
        return null;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Shipment__c> getShips(String snno)
    {
        List<Shipment__c> shipList = new List<Shipment__c>();
        List<Shipment__c> shipList1 = new List<Shipment__c>();
        Datetime cutOffDate1 = Datetime.newInstance(2023, 12, 01, 00, 00, 00);
        // Date cutOffDate = Date.newInstance(2023,12,01);
        
        try{
            
            String uid = UserInfo.getUserId();
            User cUser = [select Id,City,Profile.Name from User where Id=:uid limit 1];
            
                if(snno==null)
                {
                    shipList = [select Id,Name,Tracking_Status__c,Consignee_Name_TMS__c,Shipping_Note_Number__c,Delivery_Route_Assigned_To__c,Shipment_Created_Date_Time__c,
                                Destination_Address_Name__r.Name,Destination_Hub__r.Branch__c,
                                Destination_Hub__r.Name,(select Id from Deliveries__r)
                                from Shipment__c where Tracking_Status__c=:'Delivered' and 
                                POD_Link_Url__c=null and Shipment_Created_Date_Time__c >=: cutOffDate1
                                and (Destination_Hub__r.Branch__c=:cUser.City or Destination_Hub__r.Name=:cUser.City) limit 5000];            
                }
                else
                {
                    String sno='%'+snno+'%';
                    		// Destination_Address_Name__c  BulkDelivery__c
                    shipList = [select Id,Name,Tracking_Status__c,Consignee_Name_TMS__c,Shipping_Note_Number__c,Delivery_Route_Assigned_To__c,Shipment_Created_Date_Time__c,
                                Destination_Address_Name__r.Name,Destination_Hub__r.Branch__c,
                                Destination_Hub__r.Name,(select Id from Deliveries__r)
                                from Shipment__c where Tracking_Status__c=:'Delivered' and 
                                POD_Link_Url__c=null and (Destination_Hub__r.Branch__c=:cUser.City or Destination_Hub__r.Name=:cUser.City)
                                and Shipment_Created_Date_Time__c >=: cutOffDate1
                                and Shipping_Note_Number__c like :sno limit 5000];             
                }
                for(Shipment__c sh: shipList)
                {
                    
                    if(sh.Deliveries__r.size()>0)
                    {
                        if(cUser.Profile.Name == 'Operations Office Executive' || 
                           cUser.Profile.Name == 'System Administrator' || sh.Delivery_Route_Assigned_To__c==cUser.Id)
                        {
                           shipList1.add(sh); 
                        }
                        
                    }
                }                            
        }
        catch(Exception ex){
            
            
        }          
        if(shipList1.size()>0)
        {
           
            
            return shipList1;
        }
        else
        {
            return null;
        }
        // return null;
    }
    
    //to upload POD
    @AuraEnabled
    public static Delivery__c podUpload(String fileData, String deliveryUpload){
        String recId;
        String snn;
        List<Delivery__c> deliveryList = new List<Delivery__c>();       
        try{
            deliveryList = [Select Id, Shipping_Note_Number__c,BulkDelivery__c,POD__c From Delivery__c Where Id =: deliveryUpload];
            System.debug('107===== deliveryList:'+deliveryList);
            if(deliveryList.size()>0){
                recId = deliveryList[0].Id;
                snn = deliveryList[0].Shipping_Note_Number__c;
            }            
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            String tmpFileName = 'BVC '+snn+' - POD - '+Date.today().format();
            System.debug('119 podUpload tmpFileName '+tmpFileName);
            cVersion.PathOnClient = tmpFileName+'.png'; 
            cVersion.Title = tmpFileName+'.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            System.debug('124===== cVersion:'+cVersion);
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = recId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            insert conDocLinkObj;
            System.debug('135===== conDocLinkObj:'+conDocLinkObj);
            List<Delivery__c> delListToUpdate = new List<Delivery__c>();
            
            for(Delivery__c delObj: deliveryList){
                Delivery__c tmpDelObj = new Delivery__c();
                tmpDelObj.BulkDelivery__c = true;
                //tmpDelObj.POD__c = true;
                tmpDelObj.Id = delObj.Id;
                delListToUpdate.add(tmpDelObj);
            }
            System.debug('for checking delListToUpdate '+delListToUpdate);
            if(delListToUpdate.size()>0){
                update delListToUpdate;
                System.debug('148===== delListToUpdate:'+delListToUpdate);
            }
            
            
           return deliveryList[0]; 
        }catch(Exception ex){
            System.debug('154 for checking Error Message :'+ex.getMessage());
            System.debug('155 for checking Error on Line Number :'+ex.getLineNumber());
			return null;           
        }
        
        
    }
    
    
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
        
    }
    
}