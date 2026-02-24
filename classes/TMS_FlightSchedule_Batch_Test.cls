@isTest(SeeAllData=true)
public class TMS_FlightSchedule_Batch_Test {
    
    @isTest 
    public static void generateToken_TestUnit() {
        Test.setMock(HttpCalloutMock.class, new TMS_FlightSchedule_Batch_Mock()); 
       String response = TMS_FlightScheduleBatch_Helper.generateToken();
        String response1 ='{"status":"success","code":200,"message":"Login Successfully!","result":{"access_token":"BearereyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vcWEudGhlc3BpY2V0YWcuY29tL2FkbWluL2FwaS9sb2dpbiIsImlhdCI6MTY1OTY4Mjk3MSwiZXhwIjoxNjU5NjkwMTcxLCJuYmYiOjE2NTk2ODI5NzEsImp0aSI6IkQyTTUzR3VkMFJveVpNV3UiLCJzdWIiOiIyNDA1IiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.MyOubc2fhajqvg2P7XIbeXwiJfXFTjSJum4D9m3mNKY","token_type":"bearer","expires_in":7200,"user_data":{"name":"B V C LOGISTICS PRIVATE LIMITED","email":null,"contact_number":null,"user_address":"UNIT NO. 1102, SOLITAIR CORPORATE PARK, 167, GURU HARGOVINDJI MARG, ANDHERI (EAST), MUMBAI MAHARASHT","code":"BVCCENDO","country":"IN","city":"BOM","created_at":"2019-05-23T01:15:25.000000Z","role_id":2,"warehouse_code":"BOM","image_path":null,"is_active":"1","organization_name":"B V C LOGISTICS PRIVATE LIMITED","customer_station":null,"participation_type":"A","latitude":null,"longitude":null,"state":"27","postal_code":"000000","airport_code":"BOM","type":"A2A","default_password":"1","parent_id":0,"default_station":null,"validate_credit":false,"users_profile_image":null},"user_role":{"role_name":"customer","system_type":"CUSTOM_ROLE"}}}';
        string flightlist ='{"result":[{"id":1223,"flight_id":"2687816","departure_date":"2021-04-08","flight_no":"SG8723","registration_no":"VT-SLJ","aircraft_type":"737-800","source":"DEL","destination":"BOM","operational_status":"Operational","dep_bay_no":"D37L","arr_bay_no":"V15 N","atd":"2021-04-08 08:35:00","ata":"2021-04-08 10:40:00","etd":"2021-07-18 20:05:00","eta":"2021-07-18 20:05:00","std":"2021-07-18 20:05:00","sta":"2021-07-18 22:05:00","manufacturer":"BOEING 737","delay_code":"","delay_reason":"","dep_delay":"","is_active":1,"cms_value":"PAX","created_at":"2021-07-15T07:31:16.000000Z","updated_at":"2021-07-15T07:31:16.000000Z"}]}';
        string originFlightCode='BOM';
        string endpoint='https://qa.thespicetag.com/admin/api/freighter/list';
        AirLine1__c airline= new AirLine1__c();
        airline.Airline_Name__c= 'SpiceJet';
       
        try{
        List<Flight_Schedule__c> response2= TMS_FlightScheduleBatch_Helper.getFlightDetails(flightlist, originFlightCode, endpoint,airline.Id);        
         Database.executeBatch(new TMS_FlightSchedule_Batch(),200);
        }catch(exception e){
            system.debug(e);
        }
       
    }
     
}