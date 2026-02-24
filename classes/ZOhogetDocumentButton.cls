public class ZOhogetDocumentButton {

    @InvocableMethod
    public static void getDocument(){
        
        database.executeBatch(new zohoSignGetDocumentAPIHelperBatch(),2);
    }
}