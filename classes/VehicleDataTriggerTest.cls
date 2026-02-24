@isTest
public class VehicleDataTriggerTest {
    
    @isTest
    static void testInsertWithModeStart() {
        Vehicle_Data__c vd = new Vehicle_Data__c(
            Start_KM__c = null,
            End_KM__c = null,
            Mode__c = 'Start'
        );
        
        Test.startTest();
        insert vd;
        Test.stopTest();

        Vehicle_Data__c inserted = [SELECT Start_KM__c, End_KM__c FROM Vehicle_Data__c WHERE Id = :vd.Id];
        System.assertEquals('0', inserted.Start_KM__c);
        System.assertEquals('0', inserted.End_KM__c);
    }

    @isTest
    static void testInsertModeEndValidKM() {
        Vehicle_Data__c vd = new Vehicle_Data__c(
            Start_KM__c = '100',
            End_KM__c = '150',
            Mode__c = 'End'
        );

        Test.startTest();
        insert vd;
        Test.stopTest();

        Vehicle_Data__c inserted = [SELECT Start_KM__c, End_KM__c FROM Vehicle_Data__c WHERE Id = :vd.Id];
        System.assertEquals('100', inserted.Start_KM__c);
        System.assertEquals('150', inserted.End_KM__c);
    }

    @isTest
    static void testUpdateWithValidKM() {
        Vehicle_Data__c vd = new Vehicle_Data__c(
            Start_KM__c = '50',
            End_KM__c = '80',
            Mode__c = 'End'
        );
        insert vd;

        vd.Start_KM__c = '60';
        vd.End_KM__c = '100';

        Test.startTest();
        update vd;
        Test.stopTest();

        Vehicle_Data__c updated = [SELECT Start_KM__c, End_KM__c FROM Vehicle_Data__c WHERE Id = :vd.Id];
        System.assertEquals('60', updated.Start_KM__c);
        System.assertEquals('100', updated.End_KM__c);
    }

    @isTest
    static void testUpdateStartGreaterThanEndKM() {
        Vehicle_Data__c vd = new Vehicle_Data__c(
            Start_KM__c = '100',
            End_KM__c = '150',
            Mode__c = 'End'
        );
        insert vd;

        // Invalid update
        vd.Start_KM__c = '200';
        vd.End_KM__c = '150';

        Test.startTest();
        try {
            update vd;
            System.assert(false, 'Expected error for Start KM > End KM');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Start KM Must be Less Than End KM'));
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateModeStartResetsEndKM() {
        Vehicle_Data__c vd = new Vehicle_Data__c(
            Start_KM__c = '100',
            End_KM__c = '200',
            Mode__c = 'End'
        );
        insert vd;

        vd.Mode__c = 'Start';

        Test.startTest();
        update vd;
        Test.stopTest();

        Vehicle_Data__c updated = [SELECT End_KM__c FROM Vehicle_Data__c WHERE Id = :vd.Id];
        System.assertEquals('0', updated.End_KM__c);
    }
}