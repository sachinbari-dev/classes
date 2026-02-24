public class EmployeeDataWrapper{

	public Integer status;
	public String message;
	public List<Employee_data> employee_data;

	public class Employee_data {
		public String first_name;
		public String last_name;
		public String employee_id;
		public String personal_email_id;
		public String company_email_id;
		public String sub_department;
		public String designation;
		public String direct_manager;
		public String direct_manager_email;
		public String l2_manager;
		public String l2_manager_email;
		public String designation_name;
	}

	
	public static EmployeeDataWrapper parse(String json) {
		return (EmployeeDataWrapper) System.JSON.deserialize(json, EmployeeDataWrapper.class);
	}
}