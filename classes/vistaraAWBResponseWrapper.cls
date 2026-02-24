public class vistaraAWBResponseWrapper {
  @AuraEnabled
    public String d {get;set;}
  @AuraEnabled
	public static vistaraAWBResponseWrapper parse(String json) {      
		return (vistaraAWBResponseWrapper) System.JSON.deserialize(json, vistaraAWBResponseWrapper.class);
	}
}