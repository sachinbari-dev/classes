public class vistaraTokenGenarationWrapper {

    public string d ;
    
    public static vistaraTokenGenarationWrapper parse(string json){
        return (vistaraTokenGenarationWrapper) System.JSON.deserialize(json, vistaraTokenGenarationWrapper.class);
    }
}