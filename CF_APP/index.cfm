<cfscript>
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
            } else {
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
            
        case "createTask":
            // Check if the form was submitted via a POST request
            if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName")) {
                // Verify the user is logged in
                if (structKeyExists(session, "user_id")) {
                    // Instantiate the model and call the method to create the task
                    var taskModel = new model.query();
                    var finalDueDate = (len(trim(form.dueDate)) gt 0) ? form.dueDate : ""
                    taskModel.createTask(
                        session.user_id,
                        form.taskName,
                        form.description,
                        form.priority,
                        form.dueDate
                    );
                    
                    // Redirect to the dashboard after a successful save
                    location(url="index.cfm?action=dashboard", addtoken=false);
                } else {
                    // If not logged in, redirect to the login page
                    location(url="login.cfm", addtoken=false);
                }
            } else {
                // If not a valid POST request, redirect back to the dashboard
                location(url="index.cfm?action=dashboard", addtoken=false);
            }
            break;

        case "logout":
            // You may want to add a logout controller method here
            // For now, it just includes the main view
            include "view/main.cfm";
            break;
        case "api":
            include "api/api.cfm";
            break;
        case "no_account":
            include "view/no_account.cfm";
            break;
        default:
            writeOutput("Page not found.");
    }
</cfscript>