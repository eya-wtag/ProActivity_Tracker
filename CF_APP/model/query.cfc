
<cfoutput>
    <h2>Hello from dashboard!</h2>
</cfoutput>

<cffunction name="getAssignedTasks" access="remote" returntype="query">
    <cfargument name="userId" type="numeric" required="true">

    <cfset var tasksQuery = "">

    <cfquery name="tasksQuery" datasource="your_datasource_name">
        SELECT 
            id,
            task_name,
            priority,
            is_completed,
            due_date
        FROM 
            WorkList
        WHERE 
            user_id = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
        ORDER BY
            is_completed,
            due_date
    </cfquery>

    <cfreturn tasksQuery>
</cffunction>