@istest
public class vistaraGetSessionIdWrapperTest {
 
    @isTest
    public static void testSessionId(){
        string json = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\"Table\":[{\"AgentCode\":\"BVCCOKDOM\",\"ControllingLocator\":null,\"CreditController\":\"BVCCENDOM\",\"IsActive\":true,\"SessionID\":\"03ee9988-7a69-4c39-8d83-40990c13174a\",\"RetStatus\":\"Success\",\"RoleName\":\"Agent\",\"AgentName\":\"B V C LOGISTICS PVT LTD\",\"UserType\":\"\",\"RoleType\":\"AGTEXEC\",\"AgentBalance\":708274.20,\"AgentEmail\":\"\",\"AgentContact\":\"\"}]}:RESULT_END"}';
        try{
             vistaraGetSessionIdWrapper.parse(json);
        }catch(exception e){
            system.debug('error:' + e);
        }
       
    }
     
}