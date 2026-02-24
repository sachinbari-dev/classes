@isTest
global class BVC_IqlooLockAPIHelperMock1 implements HttpCalloutMock{

     global HTTPResponse respond(HTTPRequest request) {
         
          HttpResponse response = new HttpResponse();
           response.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
           String body = '';
         
         if(request.getEndpoint().endswith('https://auth.igloohome.co/oauth2/token')){
              body = '{"access_token":"eyJraWQiOiJMNGhScm1BbzEya2lVa3BvVlM1Tkg0KytGWUhXb0FmZU0zXC90RTViMkRmUT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MW05MnAxYjdpbXVpa2xrcWpoYmx1bDYxbyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiaWdsb29ob21lYXBpXC9jcmVhdGUtcGluLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL3VubG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLW9uZXRpbWUgaWdsb29ob21lYXBpXC9hbGdvcGluLWRhaWx5IGlnbG9vaG9tZWFwaVwvbG9jay1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9nZXQtZGV2aWNlcyBpZ2xvb2hvbWVhcGlcL2dldC1kZXZpY2Utc3RhdHVzLWJyaWRnZS1wcm94aWVkLWpvYiBpZ2xvb2hvbWVhcGlcL2FsZ29waW4tcGVybWFuZW50IGlnbG9vaG9tZWFwaVwvZ2V0LWpvYi1zdGF0dXMgaWdsb29ob21lYXBpXC9nZXQtYWN0aXZpdHktbG9ncy1icmlkZ2UtcHJveGllZC1qb2IgaWdsb29ob21lYXBpXC9hbGdvcGluLWhvdXJseSBpZ2xvb2hvbWVhcGlcL2RlbGV0ZS1waW4tYnJpZGdlLXByb3hpZWQtam9iIGlnbG9vaG9tZWFwaVwvZ2V0LWJhdHRlcnktbGV2ZWwtYnJpZGdlLXByb3hpZWQtam9iIiwiYXV0aF90aW1lIjoxNzQ3ODEyODAwLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV83NTB0enc3ZVUiLCJleHAiOjE3NDc4OTkyMDAsImlhdCI6MTc0NzgxMjgwMCwidmVyc2lvbiI6MiwianRpIjoiNzQyNGRlNTMtNWVlOC00ZjA3LTgxMWQtNDk4MGZlZmI0MDRlIiwiY2xpZW50X2lkIjoiNTFtOTJwMWI3aW11aWtsa3FqaGJsdWw2MW8ifQ.UF9dXcF7mGc21XAKaQIYsTtFB2YCuNoCdm3xsGT-3IibcNemBeOJtpZ28GiPyBbnJDv_zIOrwwJr_zEytfNoat52OFAeV6jFdJ2ffxSLHSX5nQ4i5bB-mZ1M3KZ-Nw-psb8CbUwe6RCAS4LOxNaJ0RNOz4NgMjnl9jrrVaQB9FUVLtrwAlsRpT_oK1Dkla3XP5KxIbGoTuYvOOlDvP-fNAMq-IFPBPeZ5wqNwAc6c5gqzeXop--A99tP3iH4aMTgHctO7o7jSudrnQdUfi1oX_PKWaHunb5s01WGOVLzMPVznZJiF1jx729SUzRxZDsxT_VTbtVWKxR9SSI0PAWlPg","expires_in":86400,"token_type":"Bearer"}';
                  }
         if(request.getEndpoint().endswith('https://api.igloodeveloper.co/igloohome/devices/SP2X18720632/algopin/onetime')){
             body = '{"pin":"4550789","pinId":"680f272685306f61860175ce"}';
         }
         if(request.getEndpoint().endswith('https://api.igloodeveloper.co/igloohome/devices/SP2X18720632/masterpin')){
             body = '{"pin":"49667198"}';
         }
            response.setBody(body);
            response.setStatusCode(200);
            return response;
         }
        
}