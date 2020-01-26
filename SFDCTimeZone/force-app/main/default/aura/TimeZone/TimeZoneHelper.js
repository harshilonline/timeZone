({
getHours: function(component) {
        var action = component.get('c.getContactTimeZone');
        var contactId = component.get('v.recordId');
        action.setParams({  contactId : contactId  });
        var self = this;
        
        var newAction = component.get('c.getUserHours');
        newAction.setCallback(this, function(actionNewResult) {
            //console.log('Ret val' + actionNewResult.getReturnValue());
            component.set('v.userList', actionNewResult.getReturnValue());
        });
        $A.enqueueAction(newAction);
    
        var userTime = component.get('c.getUserTimeZone');
        userTime.setCallback(this, function(userTimeResult) {
            //console.log('Ret val' + userTimeResult.getReturnValue());
            component.set('v.userTimeStr', userTimeResult.getReturnValue());
        });
        $A.enqueueAction(userTime);
    
       var contactTime = component.get('c.getContactTimeZoneStr');
       contactTime.setParams({  contactId : contactId  });
       contactTime.setCallback(this, function(contactTimeResult) {
            //console.log('Ret val' + contactTimeResult.getReturnValue());
            component.set('v.contactTimeStr', contactTimeResult.getReturnValue());
        });
        $A.enqueueAction(contactTime);
        action.setCallback(this, function(actionResult) {
            console.log('Ret val' + actionResult.getReturnValue());
            //component.set('v.hoursList', actionResult.getReturnValue());
            //color coding
             var hours = actionResult.getReturnValue();
      		 var table = document.getElementById("table");
             var i;
            console.log('HOURS:' + hours.length);
            var workingHours = ['8am', '9am', '10am', '11am' , '12pm', '1pm', '2pm', '3pm', '4pm', '5pm'];
      	    for(i=0; i < hours.length; i++){
                var row = table.insertRow(i);
                console.log('==> CAME HERE'+ hours[i]);
                var cell = row.insertCell(0);
                        row.id = i;
                        cell.innerHTML = hours[i];
           				if(workingHours.indexOf(hours[i]) != -1){
                        	var element = document.getElementById(i);
                			element.style.backgroundColor = "#B3D9FF";
                    	}else if(hours[i] < hours[8] && hours[i] <= hours[18]){
                        	var element = document.getElementById(i);
                			element.style.backgroundColor = "#66B3FF";
                    	}else{
                        	var element = document.getElementById(i);
                			element.style.backgroundColor = "#0066CC";
                    	}
           			}
      			});
    	$A.enqueueAction(action);
    }
});