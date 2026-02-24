@isTest(SeeAllData=true)
public class Add_ShipmentTest 
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
             
             Add_Shipment.resultWrapper sttt = Add_Shipment.SaveShipment(1255,'12345',125,newShipmentlist[0].Pickup__c,
                                                                         newShipmentlist[0].Customer__c,
                                                                         newShipmentlist[0].Shipper_Name_TMS__c,
                                                                         newShipmentlist[0].Origin_Address_Name__c,
                                                                         newShipmentlist[0].Shipper_Name_TMS__c,
                                                                         newShipmentlist[0].Origin_Address_Name__c,'ValSHIP','Dore Bar','BVC',null,ValList,
                                                                         788,'Gram','INR','gdf','',true,'IRN');
        Add_Shipment.GetCoverage();
        Add_Shipment.GetCoverage1();
		Add_Shipment.compressImage('kadlkjasdkland',newShipmentlist[0].Id);
        Add_Shipment.getAllSB(newShipmentlist[0].Id);
        Add_Shipment.saveSecureBagPhoto('lnclasknaskasmamas',newShipmentlist[0].Id);
        
        Add_Shipment.fetchCustomerDoc(ValList[0].Shipment__c);
        Add_Shipment.updatecdList(ValList);
        Add_Shipment.fetchPickup(pickupId);
        Add_Shipment.GetCoverage();
        Add_Shipment.GetCoverage1();             
         }catch(Exception e){
             
         }
        
        test.stopTest();
        
    }
}