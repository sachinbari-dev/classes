public class ZohoSignGetAccessTokenWrapper {
    
    public String access_token;
	public String scope;
	public String api_domain;
	public String token_type;
	public Integer expires_in;

	
	public static ZohoSignGetAccessTokenWrapper parse(String json) {
		return (ZohoSignGetAccessTokenWrapper) System.JSON.deserialize(json, ZohoSignGetAccessTokenWrapper.class);
	}
}