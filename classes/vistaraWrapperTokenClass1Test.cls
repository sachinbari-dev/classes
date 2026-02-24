@isTest
public class vistaraWrapperTokenClass1Test {

    @isTest
    public static void testwrapper(){
        string json = '{"d":"RESULT_START:{\\"Table\\":[{\\"TokenNumber\\":\\"CEF99B1B-B29A-484A-8583-0A12DBBC1941\\"}]}:RESULT_END"}';
        vistaraWrapperTokenClass1.parse(json);
    }
}