component {

    property name="dsn" type="string"; 

    public function init(required string dsnName) {
        this.dsn = arguments.dsnName;
        return this;
    }

    // --- Error Handling Added ---
    public query function getTasksByUser(required numeric userId, string statusFilter = "pending") {
        var tasksQuery = queryNew(""); // Initialize to an empty query

        try {
            var params = {
                userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"},
                statusFilter: {value: arguments.statusFilter, cfsqltype: "cf_sql_varchar"}
            };
            
            tasksQuery = queryExecute(
                "SELECT id, taskName, description, priority, due_date, status, created_at 
                FROM tasks
                WHERE user_id = :userId
                AND status = :statusFilter
                AND status <> 'delete' 
                ORDER BY due_date ASC",
                params,
                {datasource: this.dsn} 
            );
            
        } catch (any e) {
   
            throw(
                type="Database.ReadError", 
                message="Failed to retrieve tasks for user ID " & arguments.userId,
                detail=e.message 
            );
        }
        
        return tasksQuery;
    }

    // --- Error Handling Added & cfsqltype completed ---
    public void function createTask(
        required numeric userId,
        required string taskName,
        string description = '',
        string priority = 'medium',
        any dueDate = ''
    ) {
        var finalDueDate = arguments.dueDate;

        if (len(trim(finalDueDate)) eq 0) {
            finalDueDate = now();
        }
        
        try {
            queryExecute(
                "INSERT INTO tasks (user_id, taskName, description, priority, due_date, status)
                VALUES (:userId, :taskName, :description, :priority, :dueDate, 'pending')", 
                {
                    userId:      {value: arguments.userId,      cfsqltype: "cf_sql_integer"},
                    taskName:    {value: arguments.taskName,    cfsqltype: "cf_sql_varchar"},
                    description: {value: arguments.description, cfsqltype: "cf_sql_longvarchar"},
                    priority:    {value: arguments.priority,    cfsqltype: "cf_sql_varchar"},
                    dueDate:     {value: finalDueDate,          cfsqltype: "cf_sql_date"}
                },
                {datasource: this.dsn} 
            );
        } catch (any e) {
            throw(
                type="Database.WriteError", 
                message="Failed to create task for user ID " & arguments.userId,
                detail=e.message
            );
        }
    }

    // --- Error Handling Added & cfsqltype completed ---
    public void function updateTask(
        required numeric taskId,
        required numeric userId, 
        string taskName,
        string description,
        string priority,
        date dueDate
    ) {
        try {
            var params = {};
            var sql = "UPDATE tasks SET ";

            if (structKeyExists(arguments, "taskName")) {
                sql &= "taskName = :taskName, ";
                params.taskName = {value: arguments.taskName, cfsqltype: "cf_sql_varchar"};
            }
            if (structKeyExists(arguments, "description")) {
                sql &= "description = :description, ";
                params.description = {value: arguments.description, cfsqltype: "cf_sql_longvarchar"};
            }
            if (structKeyExists(arguments, "priority")) {
                sql &= "priority = :priority, ";
                params.priority = {value: arguments.priority, cfsqltype: "cf_sql_varchar"};
            }
            if (structKeyExists(arguments, "dueDate")) {
                sql &= "due_date = :dueDate, ";
                params.dueDate = {value: arguments.dueDate, cfsqltype: "cf_sql_date"};
            }

            // Remove the trailing comma and space
            sql = removeChars(sql, len(sql) - 1, 1);
            
            sql &= " WHERE id = :taskId AND user_id = :userId"; 
            params.taskId = {value: arguments.taskId, cfsqltype: "cf_sql_integer"};
            params.userId = {value: arguments.userId, cfsqltype: "cf_sql_integer"};
            
            queryExecute(sql, params, {datasource: this.dsn}); 
        } catch (any e) {
            throw(
                type="Database.UpdateError", 
                message="Failed to update task ID " & arguments.taskId,
                detail=e.message
            );
        }
    }

    // --- Error Handling Added & cfsqltype completed ---
    public void function deleteTask(required numeric taskId, required numeric userId) { 
        try {
            queryExecute(
                "UPDATE tasks SET status = 'delete' WHERE id = :taskId AND user_id = :userId",
                {
                    taskId: {value: arguments.taskId, cfsqltype: "cf_sql_integer"},
                    userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"}
                },
                {datasource: this.dsn} 
            );
        } catch (any e) {
            throw(
                type="Database.DeleteError", 
                message="Failed to soft-delete task ID " & arguments.taskId,
                detail=e.message
            );
        }
    }

    // --- Error Handling Added & cfsqltype completed ---
    public boolean function createDoneTask(
        required numeric taskId,
        required numeric userId 
    ) {
        try {
            var params = {
                taskId: {value: arguments.taskId, cfsqltype: "cf_sql_integer"},
                userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"},
                completedAt: {value: now(), cfsqltype: "cf_sql_timestamp"}
            };

            var qResult = queryExecute(
                "UPDATE tasks 
                SET status = 'done',
                created_at = :completedAt 
                WHERE id = :taskId 
                AND user_id = :userId",
                params, 
                { datasource: this.dsn }
            );
            
            return qResult.recordCount GT 0;
        } catch (any e) {
             throw(
                type="Database.UpdateError", 
                message="Failed to mark task ID " & arguments.taskId & " as done.",
                detail=e.message
            );
        }
    }

    // --- Error Handling Added & cfsqltype completed ---
    public struct function getTask(
        required numeric taskId,
        required numeric userId 
    ) {
        var q = queryNew(""); // Initialize to an empty query
        
        try {
            q = queryExecute(
                "SELECT * FROM tasks 
                 WHERE id = :taskId 
                   AND user_id = :userId",
                { 
                    taskId: { value: arguments.taskId, cfsqltype: "cf_sql_integer" },
                    userId: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
                },
                { datasource = this.dsn } 
            );
        } catch (any e) {
             throw(
                type="Database.ReadError", 
                message="Failed to retrieve single task ID " & arguments.taskId,
                detail=e.message
            );
        }

        if (q.recordCount > 0) {
            return q.getRow(1);
        } else {
            return {};
        }
    }
    
    // --- Error Handling Added & cfsqltype completed ---
    public query function getDeletedTasksByUser(required numeric userId) {
        var tasksQuery = queryNew(""); // Initialize to an empty query

        try {
            var params = {
                userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"}
            };
            
            tasksQuery = queryExecute(
                "SELECT id, taskName, description, priority, due_date, status, created_at 
                FROM tasks
                WHERE user_id = :userId
                AND status = 'delete' 
                ORDER BY due_date ASC",
                params,
                {datasource: this.dsn} 
            );
        } catch (any e) {
            throw(
                type="Database.ReadError", 
                message="Failed to retrieve deleted tasks for user ID " & arguments.userId,
                detail=e.message
            );
        }
        
        return tasksQuery;
    }
    public query function getAllTasks() {
    try {
        var sql = "
            SELECT 
                t.id,
                t.user_id,
                t.taskName,
                t.description,
                t.priority,
                t.due_date,
                t.status,
                t.created_at,
                u.username
            FROM tasks t
            LEFT JOIN users u ON t.user_id = u.id
            ORDER BY t.created_at DESC
        ";

        var result = queryExecute(
            sql,
            {},
            { datasource = this.dsn }
        );

        return result;

    } catch (any e) {
        throw(
            type = "Database.QueryError",
            message = "Error in getAllTasks: " & e.message
        );
    }
}
public struct function createTaskByAdmin(
    required numeric userId,
    required string taskName,
    string description = "",
    string priority = "medium",
    string dueDate = ""
) {
    var response = {success=false};

    try {
        // If dueDate is empty, pass CFML null
        var dbDueDate = (len(trim(dueDate)) eq 0) ? null : dateFormat(dueDate, "yyyy-mm-dd");

        queryExecute(
            "INSERT INTO tasks (user_id, taskName, description, priority, due_date, status, created_at)
             VALUES (:userId, :taskName, :description, :priority, :dueDate, 0, NOW())",
            {
                userId: { value=userId, cfsqltype="cf_sql_integer" },
                taskName: { value=taskName, cfsqltype="cf_sql_varchar" },
                description: { value=description, cfsqltype="cf_sql_varchar" },
                priority: { value=priority, cfsqltype="cf_sql_varchar" },
                dueDate: { value=dbDueDate, cfsqltype="cf_sql_date" }  <!--- null if no date --->
            },
            { datasource=this.dsn }
        );

        response.success = true;
    } catch (any e) {
        response.success = false;
        response.error = e.message;
    }
    
    return response;
}


    property name="dsn" type="string";

    // Initialize component with DSN
    public any function init(required string dsnName) {
        this.dsn = dsnName;
        return this;
    }

    // Create a task for a specific user
    public struct function createTaskForUser(
        required numeric userId,
        required string taskName,
        string description = "",
        string priority = "medium",
        string dueDate = ""
    ) {
        var response = {success=false};
        try {
            var sql = "
                INSERT INTO tasks
                (user_id, taskName, description, priority, due_date, status, created_at)
                VALUES
                (:userId, :taskName, :description, :priority, :dueDate, 'pending', NOW())
            ";

            var params = {
                userId: { value=arguments.userId, cfsqltype="cf_sql_integer" },
                taskName: { value=arguments.taskName, cfsqltype="cf_sql_varchar" },
                description: { value=arguments.description, cfsqltype="cf_sql_varchar" },
                priority: { value=arguments.priority, cfsqltype="cf_sql_varchar" },
                dueDate: { value=(len(arguments.dueDate) ? arguments.dueDate : null), cfsqltype="cf_sql_date" }
            };

            queryExecute(sql, params, {datasource=this.dsn});
            response.success = true;

        } catch(any e) {
            response.success = false;
            response.error = e.message;
        }

        return response;
    }

    // Get all users
    public query function getAllUsers() {
        return queryExecute(
            "SELECT id, username FROM users where user_role='user' ORDER BY username",
            {},
            {datasource=this.dsn}
        );
    }

    // Get all tasks with username
    public query function getAllTasks() {
        return queryExecute(
            "
            SELECT t.id, t.user_id, t.taskName, t.description, t.priority, t.due_date, t.status, u.username
            FROM tasks t
            LEFT JOIN users u ON t.user_id = u.id
            ORDER BY t.created_at DESC
            ",
            {},
            {datasource=this.dsn}
        );
    }
    

public struct function createTaskForUser(
        required numeric userId,
        required string taskName,
        string description = "",
        string priority = "medium",
        string dueDate = ""
    ) {
        var response = {success=false};
        try {
            var sql = "
                INSERT INTO tasks
                (user_id, taskName, description, priority, due_date, status, created_at)
                VALUES
                (:userId, :taskName, :description, :priority, :dueDate, 'pending', NOW())
            ";

            var params = {
                userId: { value=arguments.userId, cfsqltype="cf_sql_integer" },
                taskName: { value=arguments.taskName, cfsqltype="cf_sql_varchar" },
                description: { value=arguments.description, cfsqltype="cf_sql_varchar" },
                priority: { value=arguments.priority, cfsqltype="cf_sql_varchar" },
                dueDate: { value=(len(arguments.dueDate) ? arguments.dueDate : null), cfsqltype="cf_sql_date" }
            };

            queryExecute(sql, params, {datasource=this.dsn});
            response.success = true;

        } catch(any e) {
            response.success = false;
            response.error = e.message;
        }

        return response;
    }

}
