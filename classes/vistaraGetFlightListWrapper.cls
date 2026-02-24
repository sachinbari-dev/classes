public class vistaraGetFlightListWrapper {

     public string d;
    
    public static vistaraGetFlightListWrapper parse(String json){
		return (vistaraGetFlightListWrapper) System.JSON.deserialize(json, vistaraGetFlightListWrapper.class);
	}
}