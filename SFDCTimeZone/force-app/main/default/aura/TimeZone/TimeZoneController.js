({ 
    doInit: function(component, event, helper) { 
        component.get("v.recordId");
        helper.getHours(component);
    }
})