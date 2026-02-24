@isTest
public class vistaraAWBResponseWrapperTest {
   
 @isTest
    public static void testWrapper(){
        vistaraAWBResponseWrapper  vs = new vistaraAWBResponseWrapper();
        string json = '{"d":"RESULT_START:{\\"Table\\":[{\\"TokenNumber\\":\\"CEF99B1B-B29A-484A-8583-0A12DBBC1941\\"}]}:RESULT_END"}'; 
         vs.d = json;
        vistaraAWBResponseWrapper.parse(json);  
       
        vistaraAWBResponseWrapper1.parse(json);
        
    }
}