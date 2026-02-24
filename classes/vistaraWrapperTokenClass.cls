public class vistaraWrapperTokenClass {

     public class Table {
		public String TokenNumber;
	}

	public List<Table> Table;

	
	public static vistaraWrapperTokenClass parse(String json) {
		return (vistaraWrapperTokenClass) System.JSON.deserialize(json, vistaraWrapperTokenClass.class);
	}
}