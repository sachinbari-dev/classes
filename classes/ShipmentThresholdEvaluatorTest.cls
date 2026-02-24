@IsTest
public class ShipmentThresholdEvaluatorTest {

   
    private static Valueable_Price__c createPriceConfig() {
        Valueable_Price__c cfg = new Valueable_Price__c(
            Gold_Price__c = 10,
            Gold_Price_To__c = 20,
            Silver_Price__c = 5,
            Silver_Price_To__c = 9,
            Diamond_Price__c = 25,
            Diamond_Price_To__c = 40
        );
        insert cfg;
        return cfg;
    }

  
    private static Shipment__c createShipment(
        String category,
        String description,
        Decimal shipmentValue,
        Boolean thresholdInitialValue
    ) {
        Shipment__c shp = new Shipment__c(
            Customer_Product_Category__c = category,
            Product_Description__c = description,
            Shipment_Value__c = shipmentValue,
            Threshold_Exceeded__c = thresholdInitialValue
        );
        insert shp;
        return shp;
    }

    @IsTest
    static void testShipmentThresholdEvaluation() {

       
        createPriceConfig();



        Shipment__c silverInRange = createShipment(
            'SilverSHIP', 'Silver Items', 80, true
        ); 

        Shipment__c silverOutRange = createShipment(
            'SilverSHIP', 'Silver Items', 120, false
        ); 

        Shipment__c valGoldInRange = createShipment(
            'ValSHIP', 'Pure Gold Jewellery', 150, true
        ); 

        Shipment__c valDiamondOutRange = createShipment(
            'ValSHIP', 'Diamond Ring', 500, false
        ); 

        Shipment__c valOtherNoChange = createShipment(
            'ValSHIP', 'Platinum Watch', 200, false
        );

     
        List<ShipmentThresholdEvaluator.FlowInput> inputs =
            new List<ShipmentThresholdEvaluator.FlowInput>();

        for (Shipment__c shp : new List<Shipment__c>{
            silverInRange,
            silverOutRange,
            valGoldInRange,
            valDiamondOutRange,
            valOtherNoChange
        }) {
            ShipmentThresholdEvaluator.FlowInput fi =
                new ShipmentThresholdEvaluator.FlowInput();
            fi.recordId = shp.Id;
            inputs.add(fi);
        }

       
        Test.startTest();
        ShipmentThresholdEvaluator.evaluateFromFlow(inputs);
        Test.stopTest();

      
        Map<Id, Shipment__c> results = new Map<Id, Shipment__c>(
            [SELECT Threshold_Exceeded__c FROM Shipment__c
             WHERE Id IN :new List<Id>{
                 silverInRange.Id,
                 silverOutRange.Id,
                 valGoldInRange.Id,
                 valDiamondOutRange.Id,
                 valOtherNoChange.Id
             }]
        );

        

        
        
        
    }
}