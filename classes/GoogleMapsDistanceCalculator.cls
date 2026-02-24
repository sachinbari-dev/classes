public class GoogleMapsDistanceCalculator {
    @future(callout=true)
    public static void calculateDistance(String origin, String destination) {
        String apiKey = 'AIzaSyDLUgN5smNf8vAhbHWsW_UkQtm0MM9naX8';
        String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins='+origin +'&destinations='+destination+'&key='+apiKey;
		//String url1 = 'https://www.google.com/maps/place/682311'; //+ '&key=' + apiKey;
        String url1 = 'https://www.google.co.in/maps/dir/Elure/Jangareddygudem';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        Http http = new Http();
        try
        {
        HttpResponse response = http.send(request);
        System.debug('response1 :'+response);
        //System.debug('response :'+response.getBody());
		Decimal distanceValue;
        if (response.getStatusCode() == 200) {
			String listJson= response.getBody();
            System.debug('listJson length :'+listJson.length());
            Integer postion = listJson.indexOf('km');
            System.debug('postion :'+postion);
            System.debug('listJson :'+listJson);
            
        } else {
			System.debug('Error');
        }
            
        }
        catch(Exception e)
        {
            
        }
    }
}