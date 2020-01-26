public with sharing class TimeZone {
    
    @AuraEnabled
    public System.Timezone getUserTimeZone() {        
        return System.UserInfo.getTimeZone();
    }
    
    @AuraEnabled
    public Timezone getContactTimeZone() {
        Timezone contactTimeZone = new Timezone();
        
        return contactTimeZone;
    }
    
}