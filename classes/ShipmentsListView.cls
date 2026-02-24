/*
*  @author : Imran
* Created Date : 07-08-2023
*/
public class ShipmentsListView 
{
    /*
    @auraEnabled(cacheable=true)
    public static Shipment__c getSH(String shipId)
    {        
        return [ select Id,name,Consignee_Name_TMS__c,
                                      Consignee_Name_TMS__r.Name,Product_Description__c,
                                      Shipping_Note_Number__c,Pickup__c,Customer_Product_Category__c,
                                      Destination_Address_Name__c,Destination_Address_Name__r.Name
                                      from Shipment__c where Id=: shipId];
    }
    */
    @auraEnabled(cacheable=false)
    //@auraEnabled
    public static List<Shipment__c> getShipments(String PickId)
    {
        List<Shipment__c> shipList = [select Id,name,
                                      Consignee_Name_TMS__c, Number_of_Secure_Bags__c,
                                      Consignee_Name_TMS__r.Name,Product_Description__c,
                                      Shipping_Note_Number__c,Pickup__c,Customer_Product_Category__c,
                                      Destination_Address_Name__c,Destination_Address_Name__r.Name
                                      from Shipment__c where Pickup__c=:PickId];
        
        if(shipList.size()>0)
        {
            System.debug('Ship List :'+shipList);
            return shipList;
        }
        else
        {
            return null;
        }
    }
    
    @auraEnabled(cacheable=true)
    public static List<Shipment__c> getSelectedShips(String PickId,String sText)
    {
        System.debug('sText :'+stext);
        String SearchText;
        List<Shipment__c> shipList = new List<Shipment__c>();
        if(stext!=null)
        {
            System.debug('Inside getSelectedShips');
            SearchText = '%'+sText+'%';
            System.debug('SearchText :'+SearchText);            
            shipList = [select Id,name,
                        Consignee_Name_TMS__c,
                        Consignee_Name_TMS__r.Name,
                        Shipping_Note_Number__c,
                        Destination_Address_Name__c,Destination_Address_Name__r.Name
                        from Shipment__c where Pickup__c=:PickId AND  Shipping_Note_Number__c Like:SearchText];            
        }
        if(shipList.size()>0)
        {
            return shipList;
        }
        else
        {
            return null;
        }
    }    
    
    // Created/Code added by Rafi Khan to send Email with Selected Dockets
    @AuraEnabled
    public static void sendEmails(String recId, List<Shipment__c> selectedRows) {
        
        Pickup__c pickObj = new Pickup__c();
        pickObj = [Select Id, Shipper_Email__c From Pickup__c Where Id =: recId];
        
        List<List<String>> argsList = new List<List<String>>();
        
        for (Shipment__c shipment : selectedRows) {
            List<String> args = new List<String>();
            args.add(pickObj.Shipper_Email__c);
            args.add(shipment.Id);
            argsList.add(args);
        }
        
          SendSelectedShipmentPDFViaEmail.sendPDF(argsList);  
        
    }
    //Code Added upto here
    
}