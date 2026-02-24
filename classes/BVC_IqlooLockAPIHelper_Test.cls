@isTest
public class BVC_IqlooLockAPIHelper_Test {

    @isTest
    public static void testMethodSuccessResponse(){
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock1());
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X18720632',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            variance__c = 3,
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';
       
        
        update p2;
        
        shipment__c s = new shipment__c();
        s.LOCK_ID__c ='SP2X18720632';
        s.variance__c = 3;
        
        insert s;
        List<id>  idList = new List<id>();
        idList.add(s.id);
        
        Shield_Lock_Audit_Log__c t = new Shield_Lock_Audit_Log__c();
        t.Access_Token__c= 'eyJraWQiOiJMNGhScm1BbzEya2lVa3BvVlM1Tkg0KytGWUhXb0FmZU0zXC90RTViMkRmUT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MW05MnAxYjdpbXVpa2xrcWpoYmx1bDYxbyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiaWdsb29ob21lYXBpXC9jcmVhdGUtcGluLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL3VubG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLW9uZXRpbWUgaWdsb29ob21lYXBpXC9hbGdvcGluLWRhaWx5IGlnbG9vaG9tZWFwaVwvbG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9nZXQtZGV2aWNlcyBpZ2xvb2hvbWVhcGlcL2dldC1kZXZpY2Utc3RhdHVzLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL2FsZ29waW4tcGVybWFuZW50IGlnbG9vaG9tZWFwaVwvZ2V0LWpvYi1zdGF0dXMgaWdsb29ob21lYXBpXC9nZXQtYWN0aXZpdHktbG9ncy1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLWhvdXJseSBpZ2xvb2hvbWVhcGlcL2RlbGV0ZS1waW4tYnJpZGdlLXByb3hpZWQtam9iIGlnbG9vaG9tZWFwaVwvZ2V0LWJhdHRlcnktbGV2ZWwtYnJpZGdlLXByb3hpZWQtam9iIiwiYXV0aF90aW1lIjoxNzQ0NTQ5NjI3LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV83NTB0enc3ZVUiLCJleHAiOjE3NDQ2MzYwMjcsImlhdCI6MTc0NDU0OTYyNywidmVyc2lvbiI6MiwianRpIjoiY2RkZDJkNGQtMzNiZS00NzM0LTg3YjctN2M1YjhhODIzZDFlIiwiY2xpZW50X2lkIjoiNTFtOTJwMWI3aW11aWtsa3FqaGJsdWw2MW8ifQ.Kr8R6AanZhLlF4eU3ipIvtS1Drrug1quMbREQZ2PNS10MRvLeWYVZzEV13XnAQvajm_uNcmSNGguGZiZAdRiFcM69ZMcEnva9rn-U_suLOtCRoLknOHiPdldmoD7M4vNfwOcU5k2I0i_pSpn3LAiW0VyEzmEROvREwEVmlVDGUOy1_XLy4PoO0gUXCvKoeAReA8XoqGMeKd5y15eVxSjc-5Q-c3d6OMTIXs3jOFDVqTInbQm71JDWcMb4WZmtniQTUf-Tud7vAJtxexqH4obZqOyCW-4wam7JFvf58VwdxgkR4_I3mseyKKCiqxpji0LV95aQ_0ume-_dLxnrJKICw';
        
        insert t;
        
        Test.startTest();
        BVC_IqlooLockAPIHelper.generateAccessToken();
      
        BVC_IqlooLockAPIHelper.updateOTP(p.id, '743842',(integer)p.variance__c);
         BVC_IqlooLockAPIHelper.updateOTP(s.id, '743842', (integer)s.variance__c);
        BVC_IqlooLockAPIHelper.callIqlooSinglePinMethod(idList);
        BVC_IqlooLockAPIHelper.updateMasterPIN(s.id, '4546456');
        BVC_IqlooAccessTokenSchedulerHelper.accesTokenGenerator();
        Test.stopTest();
    }
    @isTest
    public static void testMethodErrorResponse(){
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock2());
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X18720632',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            variance__c = 3,
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';
        
        
        update p2;
        
        shipment__c s = new shipment__c();
        s.LOCK_ID__c ='SP2X18720632';
        s.variance__c = 4;
        
        insert s;
        
        Test.startTest();
        BVC_IqlooLockAPIHelper.generateAccessToken();
      
        BVC_IqlooLockAPIHelper.updateOTP(p.id, '743842',(integer)p.variance__c);
         BVC_IqlooLockAPIHelper.updateOTP(s.id, '743842',(integer)s.variance__c);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodSuccessResponseSinglePin(){
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock1());
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X18720632',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            variance__c = 4,
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';

        
        update p2;

               Shield_Lock_Audit_Log__c t = new Shield_Lock_Audit_Log__c();
        t.Access_Token__c= 'eyJraWQiOiJMNGhScm1BbzEya2lVa3BvVlM1Tkg0KytGWUhXb0FmZU0zXC90RTViMkRmUT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MW05MnAxYjdpbXVpa2xrcWpoYmx1bDYxbyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiaWdsb29ob21lYXBpXC9jcmVhdGUtcGluLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL3VubG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLW9uZXRpbWUgaWdsb29ob21lYXBpXC9hbGdvcGluLWRhaWx5IGlnbG9vaG9tZWFwaVwvbG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9nZXQtZGV2aWNlcyBpZ2xvb2hvbWVhcGlcL2dldC1kZXZpY2Utc3RhdHVzLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL2FsZ29waW4tcGVybWFuZW50IGlnbG9vaG9tZWFwaVwvZ2V0LWpvYi1zdGF0dXMgaWdsb29ob21lYXBpXC9nZXQtYWN0aXZpdHktbG9ncy1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLWhvdXJseSBpZ2xvb2hvbWVhcGlcL2RlbGV0ZS1waW4tYnJpZGdlLXByb3hpZWQtam9iIGlnbG9vaG9tZWFwaVwvZ2V0LWJhdHRlcnktbGV2ZWwtYnJpZGdlLXByb3hpZWQtam9iIiwiYXV0aF90aW1lIjoxNzQ0NTQ5NjI3LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV83NTB0enc3ZVUiLCJleHAiOjE3NDQ2MzYwMjcsImlhdCI6MTc0NDU0OTYyNywidmVyc2lvbiI6MiwianRpIjoiY2RkZDJkNGQtMzNiZS00NzM0LTg3YjctN2M1YjhhODIzZDFlIiwiY2xpZW50X2lkIjoiNTFtOTJwMWI3aW11aWtsa3FqaGJsdWw2MW8ifQ.Kr8R6AanZhLlF4eU3ipIvtS1Drrug1quMbREQZ2PNS10MRvLeWYVZzEV13XnAQvajm_uNcmSNGguGZiZAdRiFcM69ZMcEnva9rn-U_suLOtCRoLknOHiPdldmoD7M4vNfwOcU5k2I0i_pSpn3LAiW0VyEzmEROvREwEVmlVDGUOy1_XLy4PoO0gUXCvKoeAReA8XoqGMeKd5y15eVxSjc-5Q-c3d6OMTIXs3jOFDVqTInbQm71JDWcMb4WZmtniQTUf-Tud7vAJtxexqH4obZqOyCW-4wam7JFvf58VwdxgkR4_I3mseyKKCiqxpji0LV95aQ_0ume-_dLxnrJKICw';
        
        insert t;
        
        Test.startTest();
       
        BVC_IqlooLockAPIHelper.getIqlooSinglePin(p2.Lock_ID__r.name, p.Id);
       
        Test.stopTest();
    }
 @isTest
    public static void testMethodErrorResponseSinglePin(){
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock2());
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X18720632',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            variance__c = 4,
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';

        
        update p2;

               Shield_Lock_Audit_Log__c t = new Shield_Lock_Audit_Log__c();
        t.Access_Token__c= 'eyJraWQiOiJMNGhScm1BbzEya2lVa3BvVlM1Tkg0KytGWUhXb0FmZU0zXC90RTViMkRmUT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MW05MnAxYjdpbXVpa2xrcWpoYmx1bDYxbyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiaWdsb29ob21lYXBpXC9jcmVhdGUtcGluLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL3VubG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLW9uZXRpbWUgaWdsb29ob21lYXBpXC9hbGdvcGluLWRhaWx5IGlnbG9vaG9tZWFwaVwvbG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9nZXQtZGV2aWNlcyBpZ2xvb2hvbWVhcGlcL2dldC1kZXZpY2Utc3RhdHVzLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL2FsZ29waW4tcGVybWFuZW50IGlnbG9vaG9tZWFwaVwvZ2V0LWpvYi1zdGF0dXMgaWdsb29ob21lYXBpXC9nZXQtYWN0aXZpdHktbG9ncy1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLWhvdXJseSBpZ2xvb2hvbWVhcGlcL2RlbGV0ZS1waW4tYnJpZGdlLXByb3hpZWQtam9iIGlnbG9vaG9tZWFwaVwvZ2V0LWJhdHRlcnktbGV2ZWwtYnJpZGdlLXByb3hpZWQtam9iIiwiYXV0aF90aW1lIjoxNzQ0NTQ5NjI3LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV83NTB0enc3ZVUiLCJleHAiOjE3NDQ2MzYwMjcsImlhdCI6MTc0NDU0OTYyNywidmVyc2lvbiI6MiwianRpIjoiY2RkZDJkNGQtMzNiZS00NzM0LTg3YjctN2M1YjhhODIzZDFlIiwiY2xpZW50X2lkIjoiNTFtOTJwMWI3aW11aWtsa3FqaGJsdWw2MW8ifQ.Kr8R6AanZhLlF4eU3ipIvtS1Drrug1quMbREQZ2PNS10MRvLeWYVZzEV13XnAQvajm_uNcmSNGguGZiZAdRiFcM69ZMcEnva9rn-U_suLOtCRoLknOHiPdldmoD7M4vNfwOcU5k2I0i_pSpn3LAiW0VyEzmEROvREwEVmlVDGUOy1_XLy4PoO0gUXCvKoeAReA8XoqGMeKd5y15eVxSjc-5Q-c3d6OMTIXs3jOFDVqTInbQm71JDWcMb4WZmtniQTUf-Tud7vAJtxexqH4obZqOyCW-4wam7JFvf58VwdxgkR4_I3mseyKKCiqxpji0LV95aQ_0ume-_dLxnrJKICw';
        
        insert t;
        
        Test.startTest();
       
        BVC_IqlooLockAPIHelper.getIqlooSinglePin(p2.Lock_ID__r.name, p.Id);
       
        Test.stopTest();
    }    
    
       @isTest
    public static void testMethodSuccessResponsemasterPin(){
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock1());
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X18720632',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';
        
        update p2;
        
                Shield_Lock_Audit_Log__c t = new Shield_Lock_Audit_Log__c();
        t.Access_Token__c= 'eyJraWQiOiJMNGhScm1BbzEya2lVa3BvVlM1Tkg0KytGWUhXb0FmZU0zXC90RTViMkRmUT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MW05MnAxYjdpbXVpa2xrcWpoYmx1bDYxbyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiaWdsb29ob21lYXBpXC9jcmVhdGUtcGluLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL3VubG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLW9uZXRpbWUgaWdsb29ob21lYXBpXC9hbGdvcGluLWRhaWx5IGlnbG9vaG9tZWFwaVwvbG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9nZXQtZGV2aWNlcyBpZ2xvb2hvbWVhcGlcL2dldC1kZXZpY2Utc3RhdHVzLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL2FsZ29waW4tcGVybWFuZW50IGlnbG9vaG9tZWFwaVwvZ2V0LWpvYi1zdGF0dXMgaWdsb29ob21lYXBpXC9nZXQtYWN0aXZpdHktbG9ncy1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLWhvdXJseSBpZ2xvb2hvbWVhcGlcL2RlbGV0ZS1waW4tYnJpZGdlLXByb3hpZWQtam9iIGlnbG9vaG9tZWFwaVwvZ2V0LWJhdHRlcnktbGV2ZWwtYnJpZGdlLXByb3hpZWQtam9iIiwiYXV0aF90aW1lIjoxNzQ0NTQ5NjI3LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV83NTB0enc3ZVUiLCJleHAiOjE3NDQ2MzYwMjcsImlhdCI6MTc0NDU0OTYyNywidmVyc2lvbiI6MiwianRpIjoiY2RkZDJkNGQtMzNiZS00NzM0LTg3YjctN2M1YjhhODIzZDFlIiwiY2xpZW50X2lkIjoiNTFtOTJwMWI3aW11aWtsa3FqaGJsdWw2MW8ifQ.Kr8R6AanZhLlF4eU3ipIvtS1Drrug1quMbREQZ2PNS10MRvLeWYVZzEV13XnAQvajm_uNcmSNGguGZiZAdRiFcM69ZMcEnva9rn-U_suLOtCRoLknOHiPdldmoD7M4vNfwOcU5k2I0i_pSpn3LAiW0VyEzmEROvREwEVmlVDGUOy1_XLy4PoO0gUXCvKoeAReA8XoqGMeKd5y15eVxSjc-5Q-c3d6OMTIXs3jOFDVqTInbQm71JDWcMb4WZmtniQTUf-Tud7vAJtxexqH4obZqOyCW-4wam7JFvf58VwdxgkR4_I3mseyKKCiqxpji0LV95aQ_0ume-_dLxnrJKICw';
        
        insert t;
        
        Test.startTest();
       
        BVC_IqlooLockAPIHelper.getIqlooMasterPIN(p2.id,p2.Lock_ID__r.name);
       
        Test.stopTest();
    }
        @isTest
    public static void testMethodErrorResponsemasterPin(){
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock2());
        
         Id userId=UserInfo.getUserId();
          secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X18720632',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Created',
            
            Lock_ID__c = sp.Id
        );
        insert p;
        
        Pickup__c  p2 = [select id, Pickup_Assigned_To__c,Lock_ID__c,Lock_ID__r.name,pickup_Status__c from Pickup__c where  id=: p.id];
        p2.Pickup_Assigned_To__c = userId;
        p2.Pickup_Status__c = 'Assigned';
        
        update p2;
        
                Shield_Lock_Audit_Log__c t = new Shield_Lock_Audit_Log__c();
        t.Access_Token__c= 'eyJraWQiOiJMNGhScm1BbzEya2lVa3BvVlM1Tkg0KytGWUhXb0FmZU0zXC90RTViMkRmUT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MW05MnAxYjdpbXVpa2xrcWpoYmx1bDYxbyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiaWdsb29ob21lYXBpXC9jcmVhdGUtcGluLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL3VubG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLW9uZXRpbWUgaWdsb29ob21lYXBpXC9hbGdvcGluLWRhaWx5IGlnbG9vaG9tZWFwaVwvbG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9nZXQtZGV2aWNlcyBpZ2xvb2hvbWVhcGlcL2dldC1kZXZpY2Utc3RhdHVzLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL2FsZ29waW4tcGVybWFuZW50IGlnbG9vaG9tZWFwaVwvZ2V0LWpvYi1zdGF0dXMgaWdsb29ob21lYXBpXC9nZXQtYWN0aXZpdHktbG9ncy1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLWhvdXJseSBpZ2xvb2hvbWVhcGlcL2RlbGV0ZS1waW4tYnJpZGdlLXByb3hpZWQtam9iIGlnbG9vaG9tZWFwaVwvZ2V0LWJhdHRlcnktbGV2ZWwtYnJpZGdlLXByb3hpZWQtam9iIiwiYXV0aF90aW1lIjoxNzQ0NTQ5NjI3LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV83NTB0enc3ZVUiLCJleHAiOjE3NDQ2MzYwMjcsImlhdCI6MTc0NDU0OTYyNywidmVyc2lvbiI6MiwianRpIjoiY2RkZDJkNGQtMzNiZS00NzM0LTg3YjctN2M1YjhhODIzZDFlIiwiY2xpZW50X2lkIjoiNTFtOTJwMWI3aW11aWtsa3FqaGJsdWw2MW8ifQ.Kr8R6AanZhLlF4eU3ipIvtS1Drrug1quMbREQZ2PNS10MRvLeWYVZzEV13XnAQvajm_uNcmSNGguGZiZAdRiFcM69ZMcEnva9rn-U_suLOtCRoLknOHiPdldmoD7M4vNfwOcU5k2I0i_pSpn3LAiW0VyEzmEROvREwEVmlVDGUOy1_XLy4PoO0gUXCvKoeAReA8XoqGMeKd5y15eVxSjc-5Q-c3d6OMTIXs3jOFDVqTInbQm71JDWcMb4WZmtniQTUf-Tud7vAJtxexqH4obZqOyCW-4wam7JFvf58VwdxgkR4_I3mseyKKCiqxpji0LV95aQ_0ume-_dLxnrJKICw';
        
        insert t;
        
        Test.startTest();
       
        BVC_IqlooLockAPIHelper.getIqlooMasterPIN(p2.id,p2.Lock_ID__r.name);
       
        Test.stopTest();
    }
    
    
}