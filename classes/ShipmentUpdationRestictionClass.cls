public class ShipmentUpdationRestictionClass {

    
    public static void prepareForValidation(List<Shipment__c> newList, Map<Id, Shipment__c> oldMap) {
        If(!ShipmentTriggerRunControl.isLockRunBeforeUpdate){
                Set<String> allowedProfiles = new Set<String>{
                    'System Administrator',
                        'Billing User',
                        'BVC Billing User',
                        'Operations Admin'
                        };
                            
                            String currentProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
                
                System.debug('@@@for checking currentProfileName = '+currentProfileName);
                
                for (Shipment__c shipment : newList) {
                    Shipment__c oldShipment = oldMap.get(shipment.Id);
                    System.debug('@@@for checking shipment.Is_Delivered__c = '+shipment.Is_Delivered__c);
                    System.debug('@@@for checking allowedProfiles.contains(currentProfileName) = '+allowedProfiles.contains(currentProfileName));
                    if (
                        shipment.Is_Delivered__c 
                        && !allowedProfiles.contains(currentProfileName)
                        //&& !ShipmentTriggerRunControl.isLockRun 
                    ) {
                        shipment.addError('This Shipment record is locked after delivery and cannot be edited.');
                        //ShipmentTriggerRunControl.isLockRunBeforeUpdate = true;
                    }
                }
                
                
            }
            
    }

    
}