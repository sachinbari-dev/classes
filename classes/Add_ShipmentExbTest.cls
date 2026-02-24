@isTest(SeeAllData=true)
public class Add_ShipmentExbTest 
{
    Public static testMethod void ShipmentsListViewTestMethod()
    {
        test.startTest();  
      
        List<Shipment__c> newShipmentlist = [select Id,Shipment_Created_Through__c,Consignee_Name_TMS__c,Billing_Account__c,Billing_Address__c,
                                             Customer_Product_Category__c,Customer__c,Shipper_Name_TMS__c,Origin_Address_Name__c,
                                             Insurance_By__c,Shipment_Value__c,Net_Weight__c,Reference_1__c,Pickup__c,Destination_Address_Name__c,
                                             Product_Description__c,Customer_Gross_Weight__c,Reciever_Name__c,DSN__c,Net_Weight_UOM_TMS__c,
                                             Additional_Remarks__c,Liability_Type__c  from Shipment__c limit 100];
        List<Customer_Documents__c> ValList = [select Id,Shipment__c from Customer_Documents__c where Shipment__c!=null limit 10];
        String shipId;
        
        if (!ValList.isEmpty() && ValList[0].Shipment__c != null) {
            shipId = String.valueOf(ValList[0].Shipment__c);
        }
        
        String pickupId;
        
        if (!newShipmentlist.isEmpty() && newShipmentlist[0].Pickup__c != null) {
            pickupId = String.valueOf(newShipmentlist[0].Pickup__c);
        }
        
        try
         {
             
             Add_ShipmentExb.resultWrapper sttt = Add_ShipmentExb.SaveShipment(1255,'12345',125,newShipmentlist[0].Pickup__c,
                                                                         newShipmentlist[0].Customer__c,
                                                                         newShipmentlist[0].Shipper_Name_TMS__c,
                                                                         newShipmentlist[0].Origin_Address_Name__c,
                                                                         newShipmentlist[0].Shipper_Name_TMS__c,
                                                                         newShipmentlist[0].Origin_Address_Name__c,'ValSHIP','Dore Bar','BVC',null,ValList,
                                                                         788,'Gram','INR','gdf','',true,'IRN','To Exhibition',newShipmentlist[0].Exhibition__c);
         }catch(Exception e){
             
         }
		Add_ShipmentExb.compressImage('kadlkjasdkland',newShipmentlist[0].Id);
        Add_ShipmentExb.getAllSB(newShipmentlist[0].Id);
        Add_ShipmentExb.saveSecureBagPhoto('lnclasknaskasmamas',newShipmentlist[0].Id);
        
        Add_ShipmentExb.fetchCustomerDoc(ValList[0].Shipment__c);
        Add_ShipmentExb.updatecdList(ValList);
        //Add_Shipment.fetchAllCustomerDoc(ValList[0].Shipment__c);
        Add_ShipmentExb.fetchPickup(pickupId);
     // Shipment__c AcccNamee = Add_Shipment.createShipmentRecord(newShipmentlist[0],pc.Id,'testss',sp.Name,'teesst','ttest','ttesstt','testtt','ueutu',878,'teststst');		
       // Add_Shipment.saveSecureBagPhoto(bagData,secObj.Name);
       // Add_Shipment.compressImage('bagData',cd.Id);
       Add_ShipmentExb.GetCoverage();
        Add_ShipmentExb.GetCoverage1();
        
        test.stopTest();
        
    }
}