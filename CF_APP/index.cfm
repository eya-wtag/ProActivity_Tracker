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
        controller.dashboard(); 
        break;

    case "adminDashboard":
    if (structKeyExists(session, "user") && session.user.user_role eq "admin") {

        try {
            var DSN_NAME = "todolist";
            var userModel = new model.query(dsnName=DSN_NAME);
            var getUsers = userModel.getAllUsers();

        } catch (any e) {
            writeOutput("<p style='color:red;'>Error loading users: #e.message#</p>");
        }

        include "view/admin_dashboard.cfm";

    } else {
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
    

    case "assignTaskByAdmin":

        if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName")) {

            if (structKeyExists(session, "user") && session.user.user_role eq "admin") {

                // Set defaults for optional fields, ensuring they exist for the model call
                cfparam(name="form.description", default="", type="string");
                cfparam(name="form.priority", default="medium", type="string");
                cfparam(name="form.dueDate", default="", type="string");
                cfparam(name="form.userId", default="", type="string"); // Ensure userId exists

                try {
                    // Get userId safely (Handle array case defensively, though less necessary now)
                    var rawUserId = structKeyExists(form, "userId") ? form.userId : "";
                    if (isArray(rawUserId)) rawUserId = rawUserId[1];


                    // Create task (Model handles ALL data processing and status logic)
                    var taskModel = new model.query(dsnName="todolist");
                    
                    // Pass the raw form values directly to the model
                    var result = taskModel.createTaskForUser(
                        userId = rawUserId, // <--- PASSING RAW VALUE
                        taskName = form.taskName,
                        description = form.description,
                        priority = form.priority,
                        dueDate = form.dueDate // Model handles null/date formatting
                    );

                    if (result.success) {
                        location(url="index.cfm?action=adminDashboard", addtoken=false);
                    } else {
                        writeOutput("<p style='color:red;'>Error: #result.error#</p>");
                    }

                } catch(any e) {
                    // Note: The model should handle most errors, this catches instantiation/call errors
                    writeOutput("<p style='color:red;'>Exception: #e.message#</p>");
                }

            } else {
                location(url="index.cfm?action=login", addtoken=false);
            }

        } else {
            location(url="index.cfm?action=adminDashboard", addtoken=false);
        }

    break;
    
    case "claimTask":
    if (structKeyExists(url, "taskId") AND structKeyExists(session, "user_id")) {
        var taskModel = createObject("component", "model.query").init(dsnName="todolist");
        var result = taskModel.claimOpenTask(url.taskId, session.user_id);
        
        if (result.success) {
            location(url="index.cfm?action=dashboard&message=Task claimed successfully!", addtoken=false);
        } else {
            location(url="index.cfm?action=dashboard&error=" & result.error, addtoken=false);
        }
    } else {
        location(url="index.cfm?action=dashboard", addtoken=false);
    }
    break;

    default:
        writeOutput("Page not found.");

}
</cfscript>
