public class BVC_EshipShipmentOrderHelperButton {
    
    @InvocableMethod
    public static void callEshipOrderGeneratorBatch(){
        
        BVC_EshipShipmentOrderHelper bc = new BVC_EshipShipmentOrderHelper();
        id JobId =  Database.executeBatch(bc,50);
        
    }
}