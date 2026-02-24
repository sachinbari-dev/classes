@isTest
public class vistaraGetSessionIdWrapper1Test {

    @isTest
    public static void testGetSessionWrapper(){
             
       string json = '{"d":"RESPONSE_START:SUCCESS:RESPONSE_ENDRESULT_START:{\"Table\":[{\"AgentCode\":\"BVCCOKDOM\",\"ControllingLocator\":null,\"CreditController\":\"BVCCENDOM\",\"IsActive\":true,\"SessionID\":\"05376d77-9e2b-47c1-9d34-2ef84a58655d\",\"RetStatus\":\"Success\",\"RoleName\":\"Agent\",\"AgentName\":\"B V C LOGISTICS PVT LTD\",\"UserType\":\"\",\"RoleType\":\"AGTEXEC\",\"AgentBalance\":708274.20,\"AgentEmail\":\"\",\"AgentContact\":\"\"}]}:RESULT_END"}';
        try{
            vistaraGetSessionIdWrapper1.parse(json);
        }catch(Exception e){
            system.debug('error:'+ e);
        }
    
    }
}