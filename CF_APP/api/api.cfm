 <cfswitch expression="#CGI.REQUEST_METHOD#"> 

    <cfcase value="POST">
        <cfif structKeyExists(URL, "action") AND URL.action IS "createTask">
            <cfif structKeyExists(session, "user_id")>
                <cfset var taskModel = new model.query()>
                <cfset taskModel.createTask(
                    form.taskName,
                    form.description,
                    form.priority,
                    form.dueDate,
                    session.user_id
                )>
                <cflocation url="index.cfm" addtoken="false">
            <cfelse>
                <cflocation url="login.cfm" addtoken="false">
            </cfif>
        </cfif>
    </cfcase>

    <cfcase value="PUT">
        </cfcase>

    <cfcase value="DELETE">
        </cfcase>

    <cfcase value="GET">
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