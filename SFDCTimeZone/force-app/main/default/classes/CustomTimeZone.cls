public without sharing class CustomTimeZone {
    
    @AuraEnabled
    public static string getContactTimeZoneStr(string contactId) {
        System.TimeZone tz = contactTimeZoneHelper(contactId);
        return tz.getDisplayName();
    }
    
    @AuraEnabled
    public static string getUserTimeZone() {
        System.TimeZone tz = System.UserInfo.getTimeZone();
        return tz.getDisplayName();
    }
    
    @AuraEnabled
    public static List<String> getUserHours() {
        List<String> hoursList = new List<String>{'12am','1am','2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','12pm','1pm','2pm','3pm','4pm','5pm','6pm','7pm','8pm','9pm','10pm','11pm'};
        return hoursList;
    }

    private static Decimal getGMTOffset(System.TimeZone tz) {
        String tOffset = tz.getDisplayName().substringAfter('T'). substringBefore(')');
        Integer sign = tOffset.charAt(0);
        //List<Integer> ret = new List<Integer>();
        Decimal ret;
        if (sign == 43) {
        	sign = 1; 
        } else {
            sign = -1;
        }
        // remove first char
        tOffset = tOffset.mid(1, tOffset.length());
        String[] tString = tOffset.split(':');
        System.debug('Split Time: '+ tString);
        Integer i = 0;
        Integer hour = 0;
        Integer min = 0;
        for (String num: tString) {
             if ( i == 0 || i == 1) {
             	hour += Integer.valueOf(num);
             } else {
                min += Integer.valueOf(num);
             }
        }
        hour *= sign;
        
        if (min != 0) {
            ret = Decimal.ValueOf(hour + '.' + min);
        } else {
            ret = hour;
        }
        return ret;
    }
    
    private static List<String> getTimes(Decimal offset, boolean isAdd) {
        // compute time
        Integer baseTime = 12;
        List<String> ret = new List<String>();
        Decimal newTime = 0;
        String suffix;
        Integer i;
        boolean isUpdate = false;
        if (isAdd) {
            newTime = offset;
            for (i = 0; i < 24; i++) {
                if (newTime == 12 && suffix.equals('pm')) {
                    suffix = 'am';
                }
                else if (newTime > 11 || isUpdate) {
                    // switch to pm
                    suffix = 'pm';
                } else {
                    suffix = 'am';
                }
                ret.add(String.valueOf(newTime) + suffix);
                newTime += 1;
                if (newTime == 13) {
                    newTime = 1;
                    isUpdate = isUpdate ? false : true;
                }
            }
        } else {
            newTime = baseTime - offset;
            for (i = 0; i < 24; i++) {
                if (newTime == 12 && suffix.equals('am')) {
                    suffix = 'pm';
                }
                else if (newTime > 11 || isUpdate) {
                    // switch to pm
                    suffix = 'am';
                } else {
                    suffix = 'pm';
                }
                ret.add(String.valueOf(newTime) + suffix);
                newTime += 1;
                if (newTime == 13) {
                    newTime = 1;
                    isUpdate = isUpdate ? false : true;
                }
            }
        }
        return ret;
    }
    
    private static System.TimeZone contactTimeZoneHelper(string contactId) {
        string timeZone;
        //Contact gotContact;
        Contact gotContact = [Select MailingAddress From Contact where Id=:contactId];
        if (gotContact != null) 
        {
            Address addr = gotContact.MailingAddress;
            System.debug('Got The Address: '+ addr);
            String city = addr.getCity();
            String country = addr.getCountry();
            String state = addr.getState();
            if (city != null && country != null && state != null) {
                Http http = new Http();
				HttpRequest request = new HttpRequest();
				request.setEndpoint('http://api.geonames.org/geoCodeAddressJSON');
				request.setMethod('GET');
                String body = 'q='+city + '+'+state + '+'+country+'&username=harshilonline';
                request.setBody(body);
                HttpResponse response = http.send(request);
				// Parse the JSON response
				if (response.getStatusCode() != 200) {
    				System.debug('The status code returned was not expected: ' +
        				response.getStatusCode() + ' ' + response.getStatus());
				} else {
    				System.debug(response.getBody());
                    Map<String, Object> results = 
                        (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    Map<String,Object> dataMap = (Map<String,Object>)results.get('address');

                    String lat = (String)dataMap.get('lat');
                    String lon = (String)dataMap.get('lng');
                    System.debug('Latitude'+ lat + ' Longitude' + lon);
                    request.setEndpoint('http://api.geonames.org/timezoneJSON?');
					request.setMethod('GET');
                	body = 'lat='+ lat + '&lng='+ lon + '&username=harshilonline';
                	request.setBody(body);
                    response = http.send(request);
					// Parse the JSON response
					if (response.getStatusCode() != 200) {
    					System.debug('The status code returned was not expected: ' +
        					response.getStatusCode() + ' ' + response.getStatus());
					} else {
                        System.debug(response.getBody());
                    	results = 
                        	(Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        timeZone = (String)results.get('timezoneId');
                        System.debug('Timezone:'+ timeZone);
                    }
                }
            }
        }
        return System.TimeZone.getTimeZone(timeZone);
    }
    
    @AuraEnabled
    public static List<string> getContactTimeZone(String contactId) {
        List<String> listTimes;
        System.TimeZone timeZone = contactTimeZoneHelper(contactId);
        // get Contact TimeZone
        Decimal contactTz = getGMTOffset(timeZone);
        // get Users TimeZone
        Decimal userTz = getGMTOffset(System.UserInfo.getTimeZone());
        System.debug('userTz:' + userTz);
        Decimal delta = 0;
        boolean isAdd;
        if (contactTz > userTz) {
            isAdd = true;
            delta = contactTz - userTz;
        } else {
            isAdd = false;
            delta = userTz - contactTz;
        }
        listTimes = getTimes(delta, isAdd);
       
        return listTimes;
    }
}