/*Class      : UpdateAddressBookOnPincodeTypeChange 
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : MAy 2024
 */

trigger UpdateAddressBookOnPincodeTypeChange on Active_Pincode__c (after update) {
    Set<Id> activePincodeIds = new Set<Id>();
    Map<Id, String> recordTypeMap = new Map<Id, String>();
    Id userId = UserInfo.getUserId();

    for (Active_Pincode__c activePincode : Trigger.new) {
        activePincodeIds.add(activePincode.Id);
        recordTypeMap.put(activePincode.Id, activePincode.Pincode_Type__c);
    }

    if (!activePincodeIds.isEmpty()) {
        UpdateAddressBookBatch batch = new UpdateAddressBookBatch(activePincodeIds, recordTypeMap, userId);
        Database.executeBatch(batch);
    }
}