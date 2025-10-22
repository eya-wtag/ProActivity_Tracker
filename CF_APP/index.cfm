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
        var controller = createObject("component", "controllers.auth");
        controller.dashboard(); // NEW: Calls the CFC method that handles role-based routing
        break;

    case "adminDashboard":
    // Ensure admin is logged in
    if (structKeyExists(session, "user") && session.user.user_role eq "admin") {

        try {
            // Load all users for the "Assign Task" dropdown
            var DSN_NAME = "todolist";
            var userModel = new model.query(dsnName=DSN_NAME);
            var getUsers = userModel.getAllUsers();

        } catch (any e) {
            writeOutput("<p style='color:red;'>Error loading users: #e.message#</p>");
        }

        // Include the admin dashboard view
        include "view/admin_dashboard.cfm";

    } else {
        // Not logged in or not admin
        location(url="index.cfm?action=login", addtoken=false);
    }

    break;
 
   case "createTask": 
    if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName")) {
        if (structKeyExists(session, "user_id")) {
            var taskModel = new model.query(dsnName="todolist"); 
            var finalDueDate = (len(trim(form.dueDate)) gt 0) ? form.dueDate : "";
            taskModel.createTask(
                userId=session.user_id,
                taskName=form.taskName,
                description=form.description,
                priority=form.priority,
                dueDate=finalDueDate
            );
            
            location(url="index.cfm?action=dashboard", addtoken=false);
        } else {
            location(url="index.cfm?action=login", addtoken=false);
        }
    } else {
        location(url="index.cfm?action=dashboard", addtoken=false);
    }
    break;

    case "editTask":
        if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName") && structKeyExists(form, "taskId")) {
            if (structKeyExists(session, "user_id")) {
                var taskModel = new model.query(dsnName="todolist"); 
                taskModel.updateTask(
                    form.taskId,
                    session.user_id,
                    form.taskName,
                    form.description,
                    form.priority,
                    form.dueDate,
                    false 
                );
                location(url="index.cfm?action=dashboard", addtoken=false);
            } else {
                location(url="index.cfm?action=login", addtoken=false);
            }
        } 
        else if (structKeyExists(url, "taskId")) {
            var taskModel = new model.query(dsnName="todolist"); 
            var taskDetails = taskModel.getTask(
                taskId = url.taskId,
                userId = session.user_id
            );
            include "view/editTask.cfm"; 
        } 
        else {
            location(url="index.cfm?action=dashboard", addtoken=false);
        }
        break;

    case "deleteTask":
        if (structKeyExists(url, "taskId") && structKeyExists(session, "user_id")) {
            
            var taskModel = new model.query(dsnName="todolist"); 
            taskModel.deleteTask(url.taskId, session.user_id); 
            location(url="index.cfm?action=dashboard", addtoken=false);
        } else {
       
            location(url="index.cfm?action=dashboard", addtoken=false);
        }
        break;
    case "markDone":
  
        var DSN_NAME = "todolist"; 
        
        if (structKeyExists(url, "taskId") && structKeyExists(session, "user_id")) {
            var taskModel = new model.query(dsnName=DSN_NAME); 

    
            taskModel.createDoneTask(
                taskId=url.taskId,
                userId=session.user_id 
            );
            

            location(url="index.cfm?action=dashboard", addtoken=false);
        } else {
     
            location(url="index.cfm?action=dashboard", addtoken=false);
        }
        break;

    case "logout":

        sessionInvalidate();
        cfcookie(
            name="auth_token",
            value="",
            expires="now",  
            path="/"
        );
        location(url="index.cfm?action=main", addtoken=false);
        break;


    case "api":
        include "api/api.cfm";
        break;

    case "no_account":
        include "view/no_account.cfm";
        break;
    
    case "assignTask":
    var DSN_NAME = "todolist";

    // Make sure form is submitted via POST and required fields exist
    if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName") && structKeyExists(form, "userId")) {

        // Ensure admin is logged in
        if (structKeyExists(session, "user") && session.user.user_role eq "admin") {

            // Safe defaults for optional fields
            cfparam(name="form.description", default="", type="string");
            cfparam(name="form.priority", default="medium", type="string");
            cfparam(name="form.dueDate", default="", type="string");

            try {
                // Initialize model
                var taskModel = new model.query(dsnName=DSN_NAME);

                // Prepare due date
                var finalDueDate = (len(trim(form.dueDate)) gt 0) ? form.dueDate : "";

                // Create task for the selected user
                taskModel.createTaskForUser(
                    userId = form.userId,
                    taskName = form.taskName,
                    description = form.description,
                    priority = form.priority,
                    dueDate = finalDueDate
                );

            } catch (any e) {
                writeOutput("<p style='color:red;'>Error assigning task: #e.message#</p>");
            }

            // Redirect back to dashboard after assigning
            location(url="index.cfm?action=dashboard", addtoken=false);

        } else {
            // Not logged in as admin
            location(url="index.cfm?action=login", addtoken=false);
        }

    } else {
        // Invalid POST or missing fields
        location(url="index.cfm?action=dashboard", addtoken=false);
    }

    break;
    case "assignTaskByAdmin":
    if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName") && structKeyExists(form, "userId")) {

        // Ensure admin is logged in
        if (structKeyExists(session, "user") && session.user.user_role eq "admin") {

            // Default optional fields
            cfparam(name="form.description", default="", type="string");
            cfparam(name="form.priority", default="medium", type="string");
            cfparam(name="form.dueDate", default="", type="string");

            try {
                var taskModel = new model.query(dsnName="todolist");

                // Convert dueDate only if not empty
                var finalDueDate = len(trim(form.dueDate)) ? form.dueDate : "";

                var result = taskModel.createTaskForUser(
                    userId=form.userId,
                    taskName=form.taskName,
                    description=form.description,
                    priority=form.priority,
                    dueDate=finalDueDate
                );

                if (result.success) {
                    location(url="index.cfm?action=adminDashboard", addtoken=false);
                } else {
                    writeOutput("<p style='color:red;'>Error: #result.error#</p>");
                }

            } catch(any e) {
                writeOutput("<p style='color:red;'>Exception: #e.message#</p>");
            }

        } else {
            location(url="index.cfm?action=login", addtoken=false);
        }

    } else {
        location(url="index.cfm?action=adminDashboard", addtoken=false);
    }
break;


    default:
        writeOutput("Page not found.");
}
</cfscript>
