trigger pickupTrigger on Pickup__c (before insert,after update) {
    
    if(trigger.isBefore){
        if(Trigger.isInsert){
            
                 System.debug('PICKUP Trigger');
                List<Pickup__c> pkList = new List<Pickup__c>();
                // List<String> ids = new List<String>();
                List<Pickup__c> todayList = [select Id,Name,Customer__c,Shipper_Name__c,Shipper_Address__c,
                                             Customer__r.Name,Shipper_Name__r.Name,Shipper_Address__r.Name,Pickup_Status__c
                                             from Pickup__c where createdDate>= TODAY limit 1000];
                Map<String,Pickup__c> list1 = new Map<String,Pickup__c>();
                for(Pickup__c pk : todayList)
                {
                    list1.put(pk.Customer__c,pk);
                }
                for(Pickup__c pk : trigger.new)
                {
                    if(list1.containsKey(pk.Customer__c))
                    {
                      Pickup__c p = list1.get(pk.Customer__c);
                        System.debug('Pickup : '+pk.Name);
                        System.debug('Pickup Status : '+pk.Pickup_Status__c);            
                        if(p.Shipper_Name__c==pk.Shipper_Name__c && p.Shipper_Address__c == pk.Shipper_Address__c && (p.Pickup_Status__c=='Created'||p.Pickup_Status__c=='Assigned')) {
                            // pk.addError('Duplicate Pickup Error \n Pickup Already Exists '+p.Name);
                            Date toDayDate = System.today();
                            pk.Created_Date_Text__c= toDayDate.format();
                            pk.Shipper_Address_Text__c =p.Shipper_Address__r.Name;
                            System.debug('11. pk.Shipper_Address_Text__c :'+pk.Shipper_Address_Text__c);
                            System.debug('11. pk.Created_Date_Text__c :'+pk.Created_Date_Text__c);
                        }
                    }
                }
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            
            for(Pickup__c p : Trigger.new){
                Pickup__c oldMap = trigger.oldMap.get(p.id);
                
                if(oldmap.Status__c !='Assigned' && P.Status__c  =='Assigned'){
                    string LockOtp = BVC_IqlooLockAPIHelper.getIqlooSinglePin(p.Lock_ID__r.Name);
                 
                    P.OTP__c = LockOtp;
                 
                }
            }
        }
    }
   
}