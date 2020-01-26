@isTest
public class TestTimeZone {
     
     @testSetup static void setup() {
		// insert some contacts
        insertContacts();
     }

    @isTest static void testGetUserTimeZone() {
        System.assertEquals('(GMT-08:00) Pacific Standard Time (America/Los_Angeles)', CustomTimeZone.getUserTimeZone());
    }
    
    @isTest static void testGetUserTimeZoneHours() {
        List<String> hoursList = new List<String>{'12am','1am','2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','12pm','1pm','2pm','3pm','4pm','5pm','6pm','7pm','8pm','9pm','10pm','11pm'};
        System.assertEquals(hoursList, CustomTimeZone.getUserHours());
    }

    static void insertContacts() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact ( FirstName = 'John', LastName ='Doe', 
                                  MailingCity='Houston', MailingState='Texas', MailingCountry='USA'));
        contacts.add(new Contact ( FirstName = 'Chuck', LastName ='Norris', 
                                  MailingCity='Hangzhou', MailingState='Zhejiang', MailingCountry='China'));
        contacts.add(new Contact ( FirstName = 'Marry', LastName ='Popins', 
                                  MailingCity='Melbourne', MailingState='Victoria', MailingCountry='Australia'));
       
        insert contacts;
    }

    static List<Contact> getContacts() {

        List<Contact> results =
            [SELECT Id 
             FROM Contact 
             ];

        return results;
    }
    
    static testMethod void testGetContactTimeZone() {
        Test.startTest();
        	List<Contact> contacts = getContacts();
        Test.stopTest();
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        for(Contact contact: contacts) {
            List<string> contactHours = CustomTimeZone.getContactTimeZone(contact.Id);
        }
    }
    
    static testMethod void testGetContactTimeZoneStr() {
        Test.startTest();
        	List<Contact> contacts = getContacts();
        Test.stopTest();
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock());
        for(Contact contact: contacts) {
            System.assertEquals('(GMT-06:00) Central Standard Time (America/Chicago)', CustomTimeZone.getContactTimeZoneStr(contact.Id));
        }
    }
    
    private static void colorTimes() {
        // Get tab set describes for each app
		List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
		// Iterate through each tab set describe for each app and display the info
		for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
    		// Display tab info for the Sales app
    		if (tsr.getLabel() == 'Sales') {
       			// Get color information for the first tab
        		List<Schema.DescribeColorResult> colorDesc = tsr.getTabs()[0].getColors();
        		// Display the icon color of the first color returned
        		System.debug('Color: ' + colorDesc[0].getColor());
   		 	}
		}
    }
}