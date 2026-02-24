@isTest
public class Indigo_CreateAWBrequestTest {
    
     @isTest
    static void testCreateAWBRequestIndigo1(){
        string json = '{"loginName":"BVCLBOM","sessionId":"3ff4d13a-d895-459d-a8b1-311d6ab0b169","awbPrefix":"312","origin":"BOM","destination":"HYD","shippingAgentCode":"BVCLBOMDOM","commodityCode":"GEN","productType":"General","commodityDesc":"GENERAL","pcs":"1","grossWt":"1000.00","chargeableWt":"1000.00","fltDate":"06/22/2023","fltNumber":"","UOM":"K","Dimensions":"","ShprAccountCode":"BOMBVC","ShprCity":"MUMBAI","ShprState":"Delhi","ShprName":"Ravindra & Co - Shipping ARUPA9695A","ShprAdd":"Test Street, Mumbai, Delhi, India, 100210","ShprPincode":"100210","ShprCountryCode":"India","ShprContactNo":"8588007113","ConsAccountCode":"DELBVC","ConsCity":"DELHI","ConsState":"Mumbai","ConsName":"Krishna - Shipping ARUPA9695D - Shipping ARUPA9695","ConsAdd":"Test Street 2, Delhi, Mumbai, India, 110057","ConsPincode":"111111","ConsCountryCode":"India","ConsContactNo":"8588007113","ScheduleID":"","ShprLat":"","ShprLong":"","ConsLat":"","ConsLong":"","ShprEmailID":"ahireravindra84@gmail.com","ConsEmailID":"test@gmail.com","Unit":"CMS","awbNumber":"","slac":"","dvCustom":"0.00","declaredValue":"0.00","payMode":"","packagingInfo":"","TokenNumber":"96F1622C-3F4B-4AF6-905A-A9C2AB7B4EFD","volume":"0.01","shcCode":"GEN","multilegRoutes":""}';          Indigo_CreateAWBrequest.parse(json);
            Indigo_CreateAWBrequest.parse(json);
    } 
}