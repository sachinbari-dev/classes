public class hyperTrackAccessTokenWrapper {
   
    public String access_token { get; set; }
    public String token_type { get; set; }
    public Integer expires_in { get; set; }
    
    
    
	public static hyperTrackAccessTokenWrapper parse(String json) {
		return (hyperTrackAccessTokenWrapper) System.JSON.deserialize(json, hyperTrackAccessTokenWrapper.class);
	}
}