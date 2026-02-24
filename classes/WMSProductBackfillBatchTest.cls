@isTest
private class WMSProductBackfillBatchTest {

    @isTest
    static void testBatchBackfill() {
        
        List<WMS_Products__c> testProducts = new List<WMS_Products__c>();

        for (Integer i = 1; i <= 5; i++) {
            WMS_Products__c wp = new WMS_Products__c(
                Name = 'Test Product ' + i,
                Serial_Number__c = 'SN' + i + ',SN' + (i+10),
                Batch_Number__c = 'BATCH' + i
            );
            testProducts.add(wp);
        }

        insert testProducts;

        
        Test.startTest();
           
            Database.executeBatch(new WMSProductBackfillBatch(), testProducts.size());
        Test.stopTest();

       
        List<WMS_Products__c> updatedProducts = [
            SELECT Serial_Number__c, Serial_Number_Search__c,
                   Batch_Number__c, Batch_Number_Search__c
            FROM WMS_Products__c
            WHERE Id IN :testProducts
        ];

        for (WMS_Products__c wp : updatedProducts) {
         
            System.assertEquals(
                wp.Serial_Number__c.substring(0, Math.min(255, wp.Serial_Number__c.length())),
                wp.Serial_Number_Search__c,
                'Serial_Number_Search__c not updated correctly'
            );

           
            System.assertEquals(
                wp.Batch_Number__c.substring(0, Math.min(255, wp.Batch_Number__c.length())),
                wp.Batch_Number_Search__c,
                'Batch_Number_Search__c not updated correctly'
            );
        }
    }
}