@isTest
public class TMS_UpdateShipment_ShippingNoteNoTest {
    
    public static testmethod void test1(){
        try{
            
            Secure_Packaging__c securePackaging1 = new Secure_Packaging__c(
            Name = 'DS865674',
            Status__c = 'Available',
           
            Digital__c = true,
            Type_of_Packaging__c = 'Shipping Label',
            RecordTypeId = '0125g0000003dGBAAY'
                            
        );
        insert securePackaging1;
        
        Secure_Packaging__c securePackaging2 = new Secure_Packaging__c(
            Name = 'DS76456',
            Status__c = 'Available',
            
            Digital__c = true,
            Type_of_Packaging__c = 'Shipping Label',
            RecordTypeId = '0125g0000003dGBAAY'
        );
        insert securePackaging2;
        
        
        Shipment__c shipment1 = new Shipment__c();
        insert shipment1;
        
        Shipment__c shipment2 = new Shipment__c();
        insert shipment2;
            
                Shipment__c shipment3 = new Shipment__c();
        insert shipment3;
        
        Shipment__c shipment4 = new Shipment__c();
        insert shipment4;    
        
             Shipment__c shipment5 = new Shipment__c();
        insert shipment5; 
        
          
         set<id>  shipID = new set<id>();
        List<Shipment__c> shipmentList = new List<Shipment__c>{shipment1, shipment2,shipment3,shipment4,shipment5};
        
            for(shipment__c sp :  shipmentList){
                if(sp.Shipping_Note_Number__c == Null){
                    shipID.add(sp.id);
                }
            }
            
            system.debug('shipID'+ shipID);
          
        
        Test.startTest();
       // TMS_updateShippingNoteNumber.updateShippingNoteNo(shipmentList);
        TMS_UpdateShipment_ShippingNoteNo.updateShippingNoteNo(shipmentList);
      
         TMS_UpdateShipment_ShippingNoteNo.testmehod();
        Test.stopTest();
        
        }catch(Exception e){
            system.debug('Error Message' + e);
        }
        
      
    
    }
   
}