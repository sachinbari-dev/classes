public class vistaraGetSessionIdWrapper1 {
 
   public class Table {
		public String AgentCode;
		public Object ControllingLocator;
		public String CreditController;
		public Boolean IsActive;
		public String SessionID;
		public String RetStatus;
		public String RoleName;
		public String AgentName;
		public String UserType;
		public String RoleType;
		public Double AgentBalance;
		public String AgentEmail;
		public String AgentContact;
	}

	public List<Table> Table;

	
	public static vistaraGetSessionIdWrapper1 parse(String json) {
		return (vistaraGetSessionIdWrapper1) System.JSON.deserialize(json, vistaraGetSessionIdWrapper1.class);
	}
}