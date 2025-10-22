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




