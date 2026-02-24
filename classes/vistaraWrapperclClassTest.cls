@isTest
public class vistaraWrapperclClassTest {

    @isTest
    public static void testWrapper(){
        string json = '{"d":"RESULT_START:{\\"Table\\":[{\\"TokenNumber\\":\\"CEF99B1B-B29A-484A-8583-0A12DBBC1941\\"}]}:RESULT_END"}';
        vistaraWrapperclClass.parse(json);
    }
}