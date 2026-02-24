@isTest
public class EmployeeDataWrapperTest {
    static testMethod void testParse() {
		String json = '{'+
		'    \"status\": 1,'+
		'    \"message\": \"Successfully loaded all employees data\",'+
		'    \"employee_data\": ['+
		'        {'+
		'            \"first_name\": \"Darwinbox\",'+
		'            \"last_name\": \"Admin\",'+
		'            \"employee_id\": \"DB_AD\",'+
		'            \"personal_email_id\": \"\",'+
		'            \"company_email_id\": \"peoplebvcadmin@bvclogistics.com\",'+
		'            \"sub_department\": \"Leadership (BVCB_SP_FI_LD)\",'+
		'            \"designation\": \"AVP (BVCB_SP_FI_LD_AVP)\",'+
		'            \"direct_manager\": \"Himani Khemka (BVCL1852)\",'+
		'            \"direct_manager_email\": \"himani.khemka@bvclogistics.com\",'+
		'            \"l2_manager\": \"Pradipkumar  Adhao (BVCL2164)\",'+
		'            \"l2_manager_email\": \"pradip.adhao@bvclogistics.com\",'+
		'            \"designation_name\": \"AVP\"'+
		'        }'+
		'	]'+
		'}';
		EmployeeDataWrapper obj = EmployeeDataWrapper.parse(json);
		System.assert(obj != null);
	}

}