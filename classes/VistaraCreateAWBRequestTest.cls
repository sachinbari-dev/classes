@isTest
public class VistaraCreateAWBRequestTest {

    @isTest
    public static void testVisataracreateAWBRequest(){
     
        string json = '{"loginName":"BVCCOKDOM","sessionId":"6353d9cd-cb64-4ec2-83c7-80f70c0ae7b1","awbPrefix":"228","origin":"COK","destination":"DEL","shippingAgentCode":"BVCCOKDOM","commodityCode":"2298","productType":"GENERAL","commodityDesc":"BREAK BULK GENERAL CARGO","pcs":"10","grossWt":"100.00","chargeableWt":"100.00","fltDate":"11/12/2023","fltNumber":"","UOM":"K","Dimensions":"10.0,10.0,10.0,10,100.0,0/","ShprAccountCode":"BVCCOKDOM","ShprCity":"MUMBAI","ShprState":"MAHARASHTRA","ShprName":"AMX LOGISTICS","ShprAdd":"G-303 GOKUL GALAXY THAKUR COMPLEX KANDIVLI EAST CITY”, CITY","ShprPincode":"400001","ShprCountryCode":"IN","ShprContactNo":"7892234577","ConsAccountCode":"AMBOMDOM","ConsCity":"BENGALURU","ConsState":"KARNATAKA","ConsName":"AMX LOGISTICS","ConsAdd":"G-303 GOKUL GALAXY THAKUR COMPLEX KANDIVLI EAST CITY","ConsPincode":"560078","ConsCountryCode":"IN","ConsContactNo":"7892239788","ScheduleID":"","ShprLat":"","ShprLong":"","ConsLat":"","ConsLong":"","ShprEmailID":"","ConsEmailID":"","Unit":"Cms","awbNumber":"","slac":"","dvCustom":"0","declaredValue":"0.0","payMode":"","packagingInfo":"","TokenNumber":"957C65CC-B18C-4706-B537-930CB4FBABD2","volume":"0.01","shcCode":"VUN","multilegRoutes":""}';
        VistaraCreateAWBRequest.parse(json);
    
    } 
}