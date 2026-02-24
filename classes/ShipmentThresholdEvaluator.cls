public class ShipmentThresholdEvaluator {

    public class FlowInput {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    @InvocableMethod(
        label='Evaluate Shipment Threshold'
        description='Sets Threshold_Exceeded__c based on predefined Valuable_Price__c ranges'
    )
    public static void evaluateFromFlow(List<FlowInput> inputs) {

        Set<Id> shipmentIds = new Set<Id>();
        for (FlowInput input : inputs) {
            if (input.recordId != null) {
                shipmentIds.add(input.recordId);
            }
        }
        if (shipmentIds.isEmpty()) {
            return;
        }

        Valueable_Price__c priceConfig = [
            SELECT Gold_Price__c,
                   Gold_Price_To__c,
                   Silver_Price__c,
                   Silver_Price_To__c,
                   Diamond_Price__c,
                   Diamond_Price_To__c
            FROM Valueable_Price__c
            WHERE Gold_Price__c != null
              AND Gold_Price_To__c != null
              AND Silver_Price__c != null
              AND Silver_Price_To__c != null
              AND Diamond_Price__c != null
              AND Diamond_Price_To__c != null
            LIMIT 1
        ];

        List<Shipment__c> shipments = [
            SELECT Id,
                   Customer_Product_Category__c,
                   Product_Description__c,
                   Shipment_Value__c,
                   Net_weight_in_Gram__c,
                   Threshold_Exceeded__c
            FROM Shipment__c
            WHERE Id IN :shipmentIds
        ];

        for (Shipment__c shp : shipments) {

            if (
                shp.Shipment_Value__c == null ||
                shp.Net_weight_in_Gram__c == null ||
                shp.Net_weight_in_Gram__c <= 0
            ) {
                continue;
            }

            Decimal ratio = shp.Shipment_Value__c / shp.Net_weight_in_Gram__c;

            String productDesc = shp.Product_Description__c != null
                ? shp.Product_Description__c.toLowerCase()
                : '';

          
            if (shp.Customer_Product_Category__c == 'SilverSHIP') {

                shp.Threshold_Exceeded__c = !(
                    ratio >= priceConfig.Silver_Price__c &&
                    ratio <= priceConfig.Silver_Price_To__c
                );
            }

          
            else if (shp.Customer_Product_Category__c == 'ValSHIP') {

                if (productDesc.contains('diamond')) {

                    shp.Threshold_Exceeded__c = !(
                        ratio >= priceConfig.Diamond_Price__c &&
                        ratio <= priceConfig.Diamond_Price_To__c
                    );
                }
                else if (productDesc.contains('gold')) {

                    shp.Threshold_Exceeded__c = !(
                        ratio >= priceConfig.Gold_Price__c &&
                        ratio <= priceConfig.Gold_Price_To__c
                    );
                }
               
            }
        }

        if (!shipments.isEmpty()) {
            update shipments;
        }
    }
}