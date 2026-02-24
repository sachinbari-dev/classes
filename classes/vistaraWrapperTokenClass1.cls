public class vistaraWrapperTokenClass1 {
 public class Table {
		public String TokenNumber;
	}

	public List<Table> Table;

	
	public static vistaraWrapperTokenClass1 parse(String json) {
		return (vistaraWrapperTokenClass1) System.JSON.deserialize(json, vistaraWrapperTokenClass1.class);
	}
}