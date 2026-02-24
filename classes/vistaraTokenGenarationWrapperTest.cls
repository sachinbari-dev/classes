@isTest
public class vistaraTokenGenarationWrapperTest {

    @isTest
    public static void tesTokenGenerationMethod(){
          
     string json = '{"d":"RESULT_START:{\"Table\":[{\"TokenNumber\":\"EB5F43ED-EED8-45C7-B045-D6839CAFD2B2\"}]}:RESULT_END"}';  
   
       try{
           
            vistaraTokenGenarationWrapper.parse(json);
        }catch(exception e){
            system.debug('error:' + e);
        }

      }
}