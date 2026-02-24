@RestResource(urlMapping='/getUserInfo')
global with sharing class UserInfoAPIController {
    @HttpGet
    global static String getUserName() {
        return UserInfo.getUserName();
    }
}