public class BVC_ZohogetDocumentButton {

     @InvocableMethod
    public static void getDocument(){
        
        database.executeBatch(new BVC_zohoSignGetDocumentHelperBatch(),2);
    }
}