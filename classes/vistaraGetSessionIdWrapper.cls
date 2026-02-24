public class vistaraGetSessionIdWrapper {
   public String d;	
    
    public static vistaraGetSessionIdWrapper parse(String json){
		return (vistaraGetSessionIdWrapper) System.JSON.deserialize(json, vistaraGetSessionIdWrapper.class);
	}
}