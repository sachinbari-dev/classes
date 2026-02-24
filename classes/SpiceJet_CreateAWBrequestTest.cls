@isTest
public class SpiceJet_CreateAWBrequestTest {
  @isTest
    static void testSpiceJet_CreateAWBrequest(){
        string json = '{"awb_number":null,"origin":"BOM","destination":"DEL","customer":"BVCCENDO","commodity_code":"GEN","commodity_description":"GENERAL","gross_weight":"100","total_pieces":"1","shipper":{"shipper_address":"UNIT NO. 1102, SOLITAIR CORPORATE PARK, ANDHERI (EAST), MUMBAI MAHARASHT","shipper_name":"B V C LOGISTICS PRIVATE LIMITED","shipper_city":"Mahipalpur","shipper_state_code":"27","shipper_country_code":"IN","shipper_postal_code":"110037","shipper_contact_number":"7073842608","shipper_email":"xyz@gmail.com"},"consignee":{"consignee_address":"M/S LAVA INTERNATIONAL LIMITED","consignee_name":"B V C LOGISTICS PRIVATE LIMITED","consignee_city":"Banglore","consignee_state_code":"29","consignee_country_code":"IN","consignee_postal_code":"560008","consignee_contact_number":"1236547890","consignee_email":"xyz@gmail.com"},"products":[{"height_dimension":"12","length_dimension":"12","width_dimension":"12","bag_number":"1","requested_quantity":"1","weight_dimension":"100","dimension_type":"CMS","type":"KG"}],"flight_route":[{"route_type":"air","partner_type":null,"partner_code":null,"flight_destination":"DEL","flight_origin":"BOM","from":"2023-07-14 20:00:00","flight_code":"SG537"}],"mode":"BVC"}';
        SpiceJet_CreateAWBrequest.parse(json);
    
    }
}