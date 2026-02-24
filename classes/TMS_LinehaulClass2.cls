/**
 * @description       : Pickup creation via Aura
 * @author            : Imran
 * @last modified     : Updated for cutoff error handling
**/
public without sharing class TMS_LinehaulClass2 {

    @AuraEnabled
    public Map<String, String> options;

    @AuraEnabled
    public Map<String, String> BranchOptions;

    @AuraEnabled
    public static List<String> SavePickup(String bill_Ac,
                                          String bill_Add,
                                          String CAId,
                                          String SAId,
                                          String SAddId,
                                          String Remarks,
                                          DateTime P_date,
                                          Boolean stg,
                                          String Receiver)
    {
        List<String> res = new List<String>();
        String status = 'FAIL';

        try {

            if (String.isBlank(CAId) || String.isBlank(SAId) || String.isBlank(SAddId)) {
                throw new AuraHandledException('Customer, Shipper Name and Shipper Address are required.');
            }

            // Prevent duplicate pickup created today
            Date today = System.today();
            DateTime startOfDay = DateTime.newInstance(today.year(), today.month(), today.day());

            List<Pickup__c> existingPickups = [
                SELECT Id, Name
                FROM Pickup__c
                WHERE Customer__c = :CAId
                AND Shipper_Name__c = :SAId
                AND Shipper_Address__c = :SAddId
                AND CreatedDate >= :startOfDay
                LIMIT 1
            ];

            if (!existingPickups.isEmpty() && stg == false) {
                res.add(status);
                res.add(existingPickups[0].Name);
                return res;
            }

         
            Pickup__c pu = new Pickup__c();
            pu.Customer__c = CAId;
            pu.Shipper_Name__c = SAId;
            pu.Shipper_Address__c = SAddId;
            pu.Pickup_Created_Through__c = 'CD Form';
            pu.Remarks__c = Remarks;

            if (P_date != null) {
                pu.Pickup_Date_and_Time__c = P_date;
            }

            pu.RecordTypeId = Schema.SObjectType.Pickup__c
                .getRecordTypeInfosByName()
                .get('Pickup Form')
                .getRecordTypeId();

            if (!String.isBlank(bill_Ac)) {
                pu.Billing_Account__c = bill_Ac;
            }

            if (!String.isBlank(bill_Add)) {
                pu.Billing_Address__c = bill_Add;
            }

     
            insert pu;

       
            Pickup__c insertedPickup = [
                SELECT Id, Name FROM Pickup__c WHERE Id = :pu.Id LIMIT 1
            ];

            status = 'SUCCESS';
            res.add(status);
            res.add(insertedPickup.Name);

            return res;

        } catch (DmlException ex) {

          
            String errorMsg = ex.getDmlMessage(0);
            throw new AuraHandledException(errorMsg);

        } catch (Exception ex) {

            throw new AuraHandledException(ex.getMessage());
        }
    }
}