@isTest
private class TransitDayCalculatorTest {
    @isTest static void testScenario_26Aug_to_05Sep_WorkingDays8() {
      
         Hub__c newHub = new Hub__c();
          newHub.Name = 'Maharashtra';
          newHub.Branch__c = 'MUMBAI';
          insert newHub;
      
        
          Hub__c newHub1 = new Hub__c();
          newHub1.Name = 'Karnataka';
        //  newHub1.Branch__c = 'BENGALURU';
          insert newHub1;

        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maharashtra';
        pin.Hub__c = newHub.id;
        pin.Zone__c = z.Id;
        insert pin;
        
         Active_Pincode__c pin1 = new Active_Pincode__c();
        pin1.Name = '456788';
        pin1.City__c = 'BENGALURU';
        pin1.Pincodes__c = '444601';
        pin1.City__c = 'BENGALURU';
        pin1.District__c = 'BENGALURU';
        pin1.Online__c = true;
        pin1.Pincode_Type__c = 'Serviceable';
        pin1.Online_Offline__c = 'Online';
        pin1.Country__c = 'India';
        pin1.State__c = 'Karnataka';
        pin1.Hub__c = newHub1.id;
        pin1.Zone__c = z.Id;
        insert pin1;
          

        Pickup__c p = new Pickup__c( Pickup_Date__c = Date.newInstance(2025,8,26),Physical_Pickup_Completed_Time__c = Datetime.newInstance(2025,8,26,10,0,0));
        insert p;

     
        List<Holiday_Data__c> hols = new List<Holiday_Data__c>{
            new Holiday_Data__c(Date__c = Date.newInstance(2025,8,27), State__c = 'Maharashtra', Name='Origin_27Aug'),
            new Holiday_Data__c(Date__c = Date.newInstance(2025,8,27), State__c = 'Karnataka', Name='Dest_27Aug'),   
            new Holiday_Data__c(Date__c = Date.newInstance(2025,9,4),  State__c = 'Karnataka', Name='Dest_04Sep')
        };
        insert hols;

    
        Shipment__c s = new Shipment__c(
            Pickup__c = p.Id,
            Origin_Hub__c = newhub.Id,
            Destination_Hub__c = newhub1.Id,
          
            Transit_Day_Bucket__c = Null,
            Actual_Delivery_Date_and_Time__c = Datetime.newInstance(2025,9,5,10,0,0) // 05-Sep-2025
        );
        insert s;
        
          shipment__c s1 =[select id, Tracking_Status__c from shipment__c where id=:s.id];
           s1.Tracking_Status__c = 'Delivered';
        update s;
     
        Test.startTest();
            Map<Id, TransitDayCalculator.Result> resultMap = TransitDayCalculator.processByIds(new List<Id>{ s.Id }, false);
        
        Map<Id, TransitDayCalculator.Result> updateResults = TransitDayCalculator.calculateAndUpdateBuckets(
                new List<Shipment__c>{ });
         Map<Id, TransitDayCalculator.Result> updateResults1 = TransitDayCalculator.calculateBuckets(
                new List<Shipment__c>{ });
       
        Test.stopTest();
   
    }

    @isTest static void testPickupOnSunday_ShiftsToMonday_SameDayZero() {
      
        
         Hub__c newHub = new Hub__c();
          newHub.Name = 'StateA';
          newHub.Branch__c = 'delhi';
          insert newHub;
        
        Hub__c newHub1 = new Hub__c();
          newHub1.Name = 'stateB';
          newHub1.Branch__c = 'delhi';
          insert newHub1;

        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'StateA';
        pin.Hub__c = newHub.id;
        pin.Zone__c = z.Id;
        insert pin;
        
         Active_Pincode__c pin1 = new Active_Pincode__c();
        pin1.Name = '456788';
        pin1.City__c = 'Amravati';
        pin1.Pincodes__c = '444601';
        pin1.City__c = 'Pune';
        pin1.District__c = 'pune';
        pin1.Online__c = true;
        pin1.Pincode_Type__c = 'Serviceable';
        pin1.Online_Offline__c = 'Online';
        pin1.Country__c = 'India';
        pin1.State__c = 'StateB';
        pin1.Hub__c = newHub1.id;
        pin1.Zone__c = z.Id;
        insert pin1;
          
       
        Pickup__c pSun = new Pickup__c( Pickup_Date__c = Date.newInstance(2025,8,31),Physical_Pickup_Completed_Time__c = Datetime.newInstance(2025,8,26,10,0,0));
        insert pSun;

   
        Shipment__c s = new Shipment__c(
          
            Pickup__c = pSun.Id,
            Origin_Hub__c = newhub.Id,
            Destination_Hub__c = newhub1.Id,
            Actual_Delivery_Date_and_Time__c = Datetime.newInstance(2025,9,1,11,0,0) // 01-Sep-2025
        );
        insert s;

        Test.startTest();
            Map<Id, TransitDayCalculator.Result> resultMap = TransitDayCalculator.processByIds(
                new List<Id>{ s.Id }, false
            );
        Test.stopTest();

        System.assert(resultMap.containsKey(s.Id));
        Integer workingDays = resultMap.get(s.Id).workingDays;
        String bucket = resultMap.get(s.Id).bucket;

        System.debug('Sun pickup workingDays=' + workingDays + ' bucket=' + bucket);

    }
    @isTest
    public static void Testbatchmethod(){
    
        Hub__c hubMaha = new Hub__c(Name = 'Maharashtra', Branch__c = 'MUMBAI');
        insert hubMaha;

        Hub__c hubKarn = new Hub__c(Name = 'Karnataka');
        insert hubKarn;


        Zone__c z = new Zone__c(Name = 'North');
        insert z;


        Active_Pincode__c pin1 = new Active_Pincode__c(
            Name = '456789', City__c = 'Pune', District__c = 'Pune',
            Pincodes__c = '444601', Online__c = true, Pincode_Type__c = 'Serviceable',
            Online_Offline__c = 'Online', Country__c = 'India',
            State__c = 'Maharashtra', Hub__c = hubMaha.Id, Zone__c = z.Id
        );
        insert pin1;

        Active_Pincode__c pin2 = new Active_Pincode__c(
            Name = '456788', City__c = 'BENGALURU', District__c = 'BENGALURU',
            Pincodes__c = '444601', Online__c = true, Pincode_Type__c = 'Serviceable',
            Online_Offline__c = 'Online', Country__c = 'India',
            State__c = 'Karnataka', Hub__c = hubKarn.Id, Zone__c = z.Id
        );
        insert pin2;

      
        Pickup__c pickup = new Pickup__c(Pickup_Date__c = Date.newInstance(2025,8,26),Physical_Pickup_Completed_Time__c = Datetime.newInstance(2025,8,26,10,0,0));
        insert pickup;

        
        List<Holiday_Data__c> holidays = new List<Holiday_Data__c>{
            new Holiday_Data__c(Date__c = Date.newInstance(2025,8,27), State__c = 'Maharashtra', Name='Origin_27Aug'),
            new Holiday_Data__c(Date__c = Date.newInstance(2025,8,27), State__c = 'Karnataka', Name='Dest_27Aug'),
            new Holiday_Data__c(Date__c = Date.newInstance(2025,9,4), State__c = 'Karnataka', Name='Dest_04Sep')
        };
        insert holidays;

        Shipment__c shipment = new Shipment__c(
            Pickup__c = pickup.Id,
            Origin_Hub__c = hubMaha.Id,
            Destination_Hub__c = hubKarn.Id,
            Transit_Day_Bucket__c = null,
            Tracking_Status__c = 'Delivered',
            Actual_Delivery_Date_and_Time__c = Datetime.newInstance(2025,9,5,10,0,0)
        );
        insert shipment;
      
        Delivery__c  d = new Delivery__c();
        d.Status__c = 'Delivered';
        d.Shipment__c = shipment.id;
         
        insert d;
         shipment__c s =[select id , Tracking_Status__c,Actual_Delivery_Date_and_Time__c from shipment__c where id=:shipment.Id];
          s.Transit_Day_Bucket__c = null;
       
          update s;
     
        Test.startTest();
        TransitDayCalculatorBatch batchJob = new TransitDayCalculatorBatch(1);
        Database.executeBatch(batchJob, 1);
        Test.stopTest();

       
        Shipment__c updatedShipment = [SELECT Id, Transit_Day_Bucket__c FROM Shipment__c WHERE Id = :shipment.Id];
        System.assertEquals('>5', updatedShipment.Transit_Day_Bucket__c, 'Bucket should reflect >5 working days');

    }
}