<cfswitch expression="#CGI.REQUEST_METHOD#"> 

    <cfcase value="POST">
        <!--- All form submissions (Create, Delete, Update) are POST requests --->
        
        <cfif structKeyExists(session, "user_id")>
            <cfset var taskModel = new model.query()>
            
            <!--- Check the action requested via the URL parameter --->
            <cfif StructKeyExists(URL, "action")>
                
                <!--- --- Handle Task Creation (from 'Add Task' form) --- --->
                <cfif URL.action IS "createTask">
                    <cfscript>
                        // Parameters match the model/query.cfc signature
                        taskModel.createTask(
                            session.user_id,
                            form.taskName,
                            form.description,
                            form.priority,
                            form.dueDate
                        );
                    </cfscript>
                    <cflocation url="index.cfm?action=dashboard" addtoken="false">

                <!--- --- Handle Task Deletion (from dashboard 'Delete' button form) --- --->
                <cfelseif URL.action IS "deleteTask">
                    <cfif structKeyExists(form, "taskId")>
                        <cfscript>
                            // Delete function only needs the ID
                            taskModel.deleteTask(form.taskId);
                        </cfscript>
                    </cfif>
                    <cflocation url="index.cfm?action=dashboard" addtoken="false">

                <!--- --- Handle Task Update (from the eventual 'Edit' form) --- --->
                <cfelseif URL.action IS "updateTask">
                    <cfif structKeyExists(form, "taskId")>
                         <cfscript>
                            taskModel.updateTask(
                                form.taskId,
                                form.taskName,
                                form.description,
                                form.priority,
                                form.dueDate,
                                StructKeyExists(form, "isCompleted")
                            );
                        </cfscript>
                        <cflocation url="index.cfm?action=dashboard" addtoken="false">
                    </cfif>

                </cfif>
            <cfelse>
                <!--- If POST request has no action, redirect to safety --->
                <cflocation url="index.cfm?action=dashboard" addtoken="false">
            </cfif>
        <cfelse>
            <!--- Redirect if user is not logged in --->
            <cflocation url="login.cfm" addtoken="false">
        </cfif>
    </cfcase>

    <!--- GET, PUT, and DELETE methods are not used in this server-side model for CRUD --->
    <cfcase value="GET">
        <cfcontent type="text/plain">
        <cfoutput>GET method not defined for direct API actions.</cfoutput>
    </cfcase>
    
    <cfcase value="PUT">
        <cfcontent type="text/plain">
        <cfoutput>Method PUT not supported.</cfoutput>
    </cfcase>

    <cfcase value="DELETE">
        <cfcontent type="text/plain">
        <cfoutput>Method DELETE not supported.</cfoutput>
    </cfcase>

    <cfdefaultcase>
        <cfcontent type="text/plain">
        <cfoutput>Error: The requested HTTP method is not supported.</cfoutput>
    </cfdefaultcase>

</cfswitch>




<!--- Set headers to indicate JSON response and prevent caching 
<cfheader name="Content-Type" value="application/json">
<cfsetting showdebugoutput="false">

<cfscript>
    // Initialize response structure
    var response = {success: false, message: ""};
    
    // Check authentication first (Essential for all API calls)
    if (!StructKeyExists(session, "user_id")) {
        response.message = "Authentication required.";
        response.statusCode = 401;
        cfreturn;
    }

    var taskModel = new model.query();
    var userId = session.user_id;

    switch (CGI.REQUEST_METHOD) {
        
        // --- GET: Retrieve Tasks ---
        case "GET":
            try {
                // Task retrieval is now done by the client-side script
                var myTasks = taskModel.getTasksByUser(userId);
                
                response.success = true;
                response.message = "Tasks retrieved successfully.";
                response.data = myTasks; // Returns CF query object
                response.statusCode = 200;
            } catch (any e) {
                response.message = "Error retrieving tasks: " & e.message;
                response.statusCode = 500;
            }
            break;

        // --- POST: Create a Task ---
        case "POST":
            try {
                // Note: The form scope is used for traditional POSTs. 
                // In modern AJAX, you often read raw body data, but since the 
                // dashboard form still submits conventionally, we stick to the form scope.
                
                taskModel.createTask(
                    userId,
                    form.taskName,
                    form.description,
                    form.priority,
                    form.dueDate
                );
                
                response.success = true;
                response.message = "Task created successfully.";
                response.statusCode = 201;
            } catch (any e) {
                response.message = "Error creating task: " & e.message;
                response.statusCode = 500;
            }
            break;

        // --- PUT/PATCH: Update a Task ---
        case "PUT":
        case "PATCH":
            try {
                // For PUT/PATCH via AJAX, data is usually passed in the request body (JSON).
                // We'll assume the client is sending a JSON body with task details.
                var requestData = deserializeJSON(ToString(GetHttpRequestData().content));
                
                // Assuming taskId is required for updates
                if (StructKeyExists(requestData, "taskId")) {
                    taskModel.updateTask(
                        requestData.taskId,
                        requestData.taskName,
                        requestData.description,
                        requestData.priority,
                        requestData.dueDate,
                        requestData.isCompleted
                    );
                    
                    response.success = true;
                    response.message = "Task updated successfully.";
                    response.statusCode = 200;
                } else {
                    response.message = "Task ID is required for update.";
                    response.statusCode = 400;
                }

            } catch (any e) {
                response.message = "Error updating task: " & e.message & " Data: " & ToString(GetHttpRequestData().content);
                response.statusCode = 500;
            }
            break;

        // --- DELETE: Delete a Task ---
        case "DELETE":
            try {
                // Task ID is passed as a URL parameter
                if (StructKeyExists(URL, "taskId")) {
                    taskModel.deleteTask(URL.taskId);
                    
                    response.success = true;
                    response.message = "Task deleted successfully.";
                    response.statusCode = 200;
                } else {
                    response.message = "Task ID is missing.";
                    response.statusCode = 400;
                }
            } catch (any e) {
                response.message = "Error deleting task: " & e.message;
                response.statusCode = 500;
            }
            break;

        default:
            response.message = "Method not allowed.";
            response.statusCode = 405;
    }
</cfscript>

<!--- Output the final JSON response --->
<cfcontent reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
--->