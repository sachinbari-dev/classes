public class VistaraTrackAwbWrapperClass1 {

    public String d;
	
	public static VistaraTrackAwbWrapperClass1 parse(String json) {
		return (VistaraTrackAwbWrapperClass1) System.JSON.deserialize(json, VistaraTrackAwbWrapperClass1.class);
	}
}