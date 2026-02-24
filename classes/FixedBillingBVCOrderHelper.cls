public class FixedBillingBVCOrderHelper {

    public static void createOrderShipment(
        List<Shipment__c> shipmentListForOrderCreation, 
        Map<Id, Decimal> perShipmentValueMap, 
        Map<Id, Map<Id, Decimal>> perShipmentRateMap
    ) {

        if (shipmentListForOrderCreation.isEmpty()) return;

        // Step 1: Collect Ids
        Set<Id> shipmentIds = new Set<Id>();
        Set<Id> billToAddressIds = new Set<Id>();
        Set<Id> hubIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(Shipment__c s : shipmentListForOrderCreation){
            shipmentIds.add(s.Id);
            if(s.BillTo_Party_Address__c != null) billToAddressIds.add(s.BillTo_Party_Address__c);
            if(s.Origin_Hub__c != null) hubIds.add(s.Origin_Hub__c);
            if(s.Bill_To_Account__c != null) accountIds.add(s.Bill_To_Account__c);
        }

        // Step 2: Query related objects in bulk
        Map<Id, AddressBook__c> addressMap = new Map<Id, AddressBook__c>(
            [SELECT Id, CITY__c, STATE__c, COUNTRY__c, TRADE_NAME__c FROM AddressBook__c WHERE Id IN :billToAddressIds]
        );

        Map<Id, Hub__c> hubMap = new Map<Id, Hub__c>(
            [SELECT Id, BVC_LegalEntity__c, BVC_Entity__c FROM Hub__c WHERE Id IN :hubIds]
        );

        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, Billing_Frequency__c, ST_Pricing_Type__c, Customer_Category__c, BVC_Invoice_Run_Fixed_Billing__c FROM Account WHERE Id IN :accountIds]
        );

        // Step 3: Prepare Orders
        List<BVCOrder__c> ordersToInsert = new List<BVCOrder__c>();
        Map<Id, Id> shipmentToOrderMap = new Map<Id, Id>();

        for(Shipment__c s : shipmentListForOrderCreation){
            BVCOrder__c o = new BVCOrder__c();
            o.Account__c = s.Bill_To_Account__c;
            o.Shipment__c = s.Id;
            o.Shipment_Number__c = s.Shipping_Note_Number__c;
            o.Shipment_Date__c = s.Shipment_Date__c;
            o.Status__c = 'Draft';
            o.Order_Type__c = 'New';
            o.BillingAccount__c = s.Billing_Account__c;
            o.Origin_Address__c = s.Origin_Address_Name__c;
            o.Destination_Address__c = s.Destination_Address_Name__c;
            o.Shipment_Value__c = s.Shipment_Value__c;
            o.Shipment_Type__c = s.Shipment_Type__c;

            if(s.Origin_Hub__c != null && hubMap.containsKey(s.Origin_Hub__c)){
                o.BVC_Branch__c = s.Origin_Hub__c;
                o.BVC_LegalEntity__c = hubMap.get(s.Origin_Hub__c).BVC_LegalEntity__c;
                o.BVC_Entity__c = hubMap.get(s.Origin_Hub__c).BVC_Entity__c;
            }

            if(s.BillTo_Party_Address__c != null && addressMap.containsKey(s.BillTo_Party_Address__c)){
                o.Billing_Address__c = s.BillTo_Party_Address__c;
            }

            ordersToInsert.add(o);
        }

        // Step 4: Insert Orders
        if(!ordersToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(ordersToInsert, false);
            for(Integer i = 0; i < srList.size(); i++){
                if(srList[i].isSuccess()){
                    shipmentToOrderMap.put(shipmentListForOrderCreation[i].Id, srList[i].getId());
                }
            }
        }

        // Step 5: Prepare Order Products
        List<BVC_Order_Product__c> orderProducts = new List<BVC_Order_Product__c>();
        for(Shipment__c s : shipmentListForOrderCreation){
            if(!shipmentToOrderMap.containsKey(s.Id)) continue;

            BVC_Order_Product__c oi = new BVC_Order_Product__c();
            oi.BVCOrder__c = shipmentToOrderMap.get(s.Id);
            oi.Shipment__c = s.Id;
            oi.Shipment_Number__c = s.Shipping_Note_Number__c;
            oi.Shipment_Date__c = s.Shipment_Date__c;
            oi.Quantity__c = 1;
          //  oi.Activation_Status__c = 'Activated';
            oi.Activated__c = true;

            // Compute rate
            Decimal rate;
            if(perShipmentRateMap != null && perShipmentRateMap.containsKey(s.Id)){
                //rate = perShipmentRateMap.get(s.Id);
            } else if(perShipmentValueMap != null && perShipmentValueMap.containsKey(s.Fixed_Billing_Daily__c)){
                //rate = perShipmentValueMap.get(s.Fixed_Billing_Daily__c);
            }
            oi.Freight_Charges__c = rate;
            oi.Total_Charges__c = rate;
            oi.Billable_Unit_Price__c = rate;

            orderProducts.add(oi);
        }

        if(!orderProducts.isEmpty()){
            Database.SaveResult[] srOiList = Database.insert(orderProducts, false);
        }

        // Step 6: Update Shipments
        List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
        for(BVC_Order_Product__c oi : orderProducts){
            if(oi.Shipment__c != null){
                shipmentsToUpdate.add(new Shipment__c(
                    Id = oi.Shipment__c,
                    BVCOrder__c = oi.BVCOrder__c,
                    Verified_for_Billing__c = true
                ));
            }
        }
        if(!shipmentsToUpdate.isEmpty()) update shipmentsToUpdate;
    }
}