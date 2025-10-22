<cfswitch expression="#CGI.REQUEST_METHOD#"> 

    <cfcase value="POST">
        
        
        <cfif structKeyExists(session, "user_id")>
            <cfset var taskModel = new model.query()>
         
            <cfif StructKeyExists(URL, "action")>
  
                <cfif URL.action IS "createTask">
                    <cfscript>
                        taskModel.createTask(
                            session.user_id,
                            form.taskName,
                            form.description,
                            form.priority,
                            form.dueDate
                        );
                    </cfscript>
                    <cflocation url="index.cfm?action=dashboard" addtoken="false">

                <cfelseif URL.action IS "deleteTask">
                    <cfif structKeyExists(form, "taskId")>
                        <cfscript>
                            taskModel.deleteTask(form.taskId);
                        </cfscript>
                    </cfif>
                    <cflocation url="index.cfm?action=dashboard" addtoken="false">

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
                <cflocation url="index.cfm?action=dashboard" addtoken="false">
            </cfif>
        <cfelse>

            <cflocation url="login.cfm" addtoken="false">
        </cfif>
    </cfcase>

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




