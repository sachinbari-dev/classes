public class BVCExGrosWtOnInvValCtrl {

    public static void checkInvValueVsGrossWeight(List<Shipment__c> shipList){
        System.debug('for checking Inside checkInvValueVsGrossWeight');

        Valueable_Price__c vpObj = [SELECT Gold_Price__c, Silver_Price__c, Diamond_Price__c FROM Valueable_Price__c LIMIT 1];
        List<Shipment__c> updateShipList = new List<Shipment__c>();

        for (Shipment__c shipObj : shipList) {
            Shipment__c tmpShipObj = new Shipment__c();
            Boolean shouldUpdate = false;

            if (shipObj.Product_Description__c == 'GOLD JEWELLERY' || 
                shipObj.Product_Description__c == 'GOLD BAR' || 
                shipObj.Product_Description__c == 'Gold Coin') {
                Decimal threshold = (vpObj.Gold_Price__c * shipObj.Gross_Weight__c) * 0.8;
                if (shipObj.Shipment_Value__c < threshold) {
                    shouldUpdate = true;
                }
            } 
            else if (shipObj.Product_Description__c == 'Silver Bar' || 
                     shipObj.Product_Description__c == 'Silver Coin' || 
                     shipObj.Product_Description__c == 'SILVER JEWELLERY' || 
                     shipObj.Product_Description__c == 'SILVER ARTICLE' || 
                     shipObj.Product_Description__c == 'Silver Granules') {
                Decimal threshold = (vpObj.Silver_Price__c * shipObj.Gross_Weight__c) * 0.8;
                if (shipObj.Shipment_Value__c < threshold) {
                    shouldUpdate = true;
                }
            } 
            else if (shipObj.Product_Description__c == 'DIAMOND JEWELLERY' || 
                     shipObj.Product_Description__c == 'Cut & Polished Diamonds' || 
                     shipObj.Product_Description__c == 'ROUGH DIAMOND') {
                Decimal threshold = (vpObj.Diamond_Price__c * shipObj.Gross_Weight__c) * 0.8;
                if (shipObj.Shipment_Value__c < threshold) {
                    shouldUpdate = true;
                }
            }

            if (shouldUpdate) {
                tmpShipObj.Id = shipObj.Id;
                tmpShipObj.Shipment_Value_Mismatched__c = true;
                updateShipList.add(tmpShipObj);
            } else {
                tmpShipObj.Id = shipObj.Id;
                tmpShipObj.Shipment_Value_Mismatched__c = false;
                updateShipList.add(tmpShipObj);
            }
        }

        if (!updateShipList.isEmpty()) {
            update updateShipList;
        }
    }
}