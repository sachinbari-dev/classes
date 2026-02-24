public without sharing class UserHelper 
{
    @AuraEnabled(cacheable=true)
    public static User getCuruserDetails()
    {
        user u = [select Id,Name,Profile.Name from User where id=: UserInfo.getUserId() limit 1 ];
        System.debug('Name :'+u.Name);
        System.debug('Profile Name :'+u.Profile.Name);
        return u;
    }
    @AuraEnabled(cacheable=true)
    public static Pickup__c getPickup(String pid)
    {
         Pickup__c pk  = [select Id,name,OTP_Verified__c,OTP__c,Pickup_Assigned_To__c,Customer__r.Name,Customer__r.OTP_Required__c,Customer_Product_Category__c,Shipper_Name__r.OTP_Required__c	 from Pickup__c where Id=:pid limit 1];
        System.debug('Name :'+pk.Name);
        System.debug('OTP__c  :'+pk.OTP__c);
        return pk;
    } 

    @AuraEnabled
    public static Pickup__c updatePickupwithoutOTP(String pid)
    {
        Pickup__c pk  = [select Id,name,Continue_Without_OTP__c from Pickup__c where Id=:pid limit 1];
        if(pk!=null)
        {
            pk.Continue_Without_OTP__c=true;
            update pk;
        }
        return pk;
    }
    
    @AuraEnabled(Cacheable=false)
    public static boolean updatePickup(String pid)
    {
        List<Pickup__c> pk  = [select Id,name,OTP_Verified__c,OTP__c,Pickup_Assigned_To__c,Customer__r.Name from Pickup__c where Id=:pid limit 1];
        System.debug('Name :'+pk[0].Name);
        System.debug('OTP__c  :'+pk[0].OTP__c); 
        System.debug('OTP_Verified__c  :'+pk[0].OTP_Verified__c);
        if(pk[0].OTP_Verified__c==false)
        {
          pk[0].OTP_Verified__c=true;
          //update pk;
          Database.update(pk,false);
        }

        System.debug('<=== PICKUP UPDATED SUCCESSFULLY ===>');
     return true;   
    }

    
    //Added By Rafi Khan for resend pickup OTP
    @AuraEnabled
    public static Map<String, Object> resendPickupOtp(Id pid) {
        System.debug('Inside resendPickupOTP');

        Pickup__c pk = [SELECT Id, Name, Shipper_Mobile__c, Shipper_Email__c FROM Pickup__c WHERE Id = :pid LIMIT 1];

        String newOtp = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 10000)).leftPad(4,'0');

        // 🔥 Prepare Callout First
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://Staging.bvclogistics.com/Notification_CS/rest/ResendOTP/PickupOTP');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        User u = [
    SELECT Id, Name,Employee_Code__c
    FROM User
    WHERE Id = :UserInfo.getUserId()
];

        Map<String,Object> body = new Map<String,Object>{
            'PickupID' => pk.Name,
            'PhoneNumber' => pk.Shipper_Mobile__c,
            'Email' => pk.Shipper_Email__c,
            'OTP' => newOtp,
            'EscorterName' => u.Name,
            'EscorterID' => u.Employee_Code__c
        };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('Response Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());

        if(res.getStatusCode() == 200) {
            // ✅ Only update if callout successful
            pk.OTP__c = newOtp;
            update pk;

            return new Map<String,Object>{'newOtp' => newOtp};
        } else {
            throw new AuraHandledException('Universe API Failed');
        }
    }
    


}