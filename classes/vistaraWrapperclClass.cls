public class vistaraWrapperclClass {
    
  public String d;
	
	public static vistaraWrapperclClass parse(String json) {
		return (vistaraWrapperclClass) System.JSON.deserialize(json, vistaraWrapperclClass.class);
	}
}