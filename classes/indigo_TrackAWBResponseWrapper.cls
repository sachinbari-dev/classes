public class indigo_TrackAWBResponseWrapper {

    public String d;

	
	public static indigo_TrackAWBResponseWrapper parse(String json) {
		return (indigo_TrackAWBResponseWrapper) System.JSON.deserialize(json, indigo_TrackAWBResponseWrapper.class);
	}
}