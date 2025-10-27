<cfscript>
param name="url.action" default="main";

switch (url.action) {

    case "main":
        include "view/main.cfm";
        break;

    case "signup":
        if (ucase(cgi.request_method) eq "POST") {
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
        var controller = createObject("component", "controllers.auth");
        
        // Verify authentication using JWT
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
        // Verify admin role
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
            location(url="index.cfm?action=dashboard&error=access_denied", addtoken=false);
        }
        break;
 
    case "createTask": 
        // Verify authentication
        var controller = createObject("component", "controllers.auth");
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
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
                location(url="index.cfm?action=main", addtoken=false);
            }
        } else {
            location(url="index.cfm?action=dashboard", addtoken=false);
        }
        break;

    case "editTask":
        // Verify authentication
        var controller = createObject("component", "controllers.auth");
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
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
                location(url="index.cfm?action=main", addtoken=false);
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
        // Verify authentication
        var controller = createObject("component", "controllers.auth");
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
        if (structKeyExists(url, "taskId") && structKeyExists(session, "user_id")) {
            var taskModel = new model.query(dsnName="todolist"); 
            taskModel.deleteTask(url.taskId, session.user_id); 
            location(url="index.cfm?action=dashboard", addtoken=false);
        } else {
            location(url="index.cfm?action=dashboard", addtoken=false);
        }
        break;
        
    case "markDone":
        // Verify authentication
        var controller = createObject("component", "controllers.auth");
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
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
        var controller = createObject("component", "controllers.auth");
        controller.logout();
        break;

    case "api":
        include "api/api.cfm";
        break;

    case "no_account":
        include "view/no_account.cfm";
        break;

    case "assignTaskByAdmin":
        // Verify authentication
        var controller = createObject("component", "controllers.auth");
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
        if (ucase(cgi.request_method) eq "POST" && structKeyExists(form, "taskName")) {
            if (structKeyExists(session, "user") && session.user.user_role eq "admin") {
                // Set defaults for optional fields
                cfparam(name="form.description", default="", type="string");
                cfparam(name="form.priority", default="medium", type="string");
                cfparam(name="form.dueDate", default="", type="string");
                cfparam(name="form.userId", default="", type="string");

                try {
                    // Get userId safely
                    var rawUserId = structKeyExists(form, "userId") ? form.userId : "";
                    if (isArray(rawUserId)) rawUserId = rawUserId[1];

                    // Create task
                    var taskModel = new model.query(dsnName="todolist");
                    var result = taskModel.createTaskForUser(
                        userId = rawUserId,
                        taskName = form.taskName,
                        description = form.description,
                        priority = form.priority,
                        dueDate = form.dueDate
                    );

                    if (result.success) {
                        location(url="index.cfm?action=adminDashboard&message=Task assigned successfully", addtoken=false);
                    } else {
                        writeOutput("<p style='color:red;'>Error: #result.error#</p>");
                    }

                } catch(any e) {
                    writeOutput("<p style='color:red;'>Exception: #e.message#</p>");
                }

            } else {
                location(url="index.cfm?action=dashboard&error=access_denied", addtoken=false);
            }

        } else {
            location(url="index.cfm?action=adminDashboard", addtoken=false);
        }
        break;
    
    case "claimTask":
        // Verify authentication
        var controller = createObject("component", "controllers.auth");
        if (!controller.isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            break;
        }
        
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
    
    case "refreshToken":
        // Refresh JWT token to extend session
        var controller = createObject("component", "controllers.auth");
        var result = controller.refreshToken();
        
        if (result.success) {
            writeOutput(serializeJSON({
                success: true,
                message: "Token refreshed successfully"
            }));
        } else {
            writeOutput(serializeJSON({
                success: false,
                error: result.error
            }));
        }
        break;

    default:
        writeOutput("<h1>Page not found</h1>");
        writeOutput("<p>The page you are looking for does not exist.</p>");
        writeOutput("<a href='index.cfm?action=main'>Go to Home</a>");
}
</cfscript>