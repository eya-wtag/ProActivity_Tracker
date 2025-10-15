<cfscript> s
param name="url.action" default="main";

switch (url.action) {

    case "main":
        include "view/main.cfm";
        break;

    case "signup":
        
        if (ucase(cgi.request_method) eq "POST") {
            writeOutput("<p>Processing signup...</p>");
            var controller = createObject("component", "controllers.auth");
            controller.signup();
        } 
        else {
            include "view/signup.cfm";
        }
        break; 
        
        
case "login":
    if (ucase(cgi.request_method) eq "POST") {

        var controller = createObject("component", "controllers.auth");
        controller.login();
        
    } else {
    
        include "view/login.cfm";
    }
    break;
    
    case "dashboard":
        include "view/dashboard.cfm";
        break;

    case "logout":
        include "view/main.cfm";
        break;
    case "api":
        include "api/api.cfm";
        break;
    default:
        writeOutput("Page not found.");
}
</cfscript>
