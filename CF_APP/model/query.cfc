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
    // Get all users
    public query function getAllUsers() {
        return queryExecute(
            "SELECT id, username FROM users where user_role='user' ORDER BY username",
            {},
            {datasource=this.dsn}
        );
    }

   
public struct function createTaskForUser(
    required string taskName,
    any userId = "",
    string description = "",
    string priority = "medium",
    string dueDate = "",
    string status = ""  <!--- optional explicit status --->
) {
    var response = {
        success = false,
        error = ""
    };

    try {
        // --- Validate userId ---
        var finalUserId = "";
        var hasValidUser = false;
        
        if (!isNull(arguments.userId) && len(trim(arguments.userId)) > 0) {
            var userIdValue = isArray(arguments.userId) ? arguments.userId[1] : arguments.userId;
            if (isNumeric(userIdValue)) {
                finalUserId = val(userIdValue);
                hasValidUser = true;
            }
        }

        // --- Determine task status ---
        var taskStatus = hasValidUser ? "pending" : "open"; // default logic

        // If explicit status provided, validate against enum
        if (len(trim(arguments.status))) {
            var statusValue = lcase(trim(arguments.status));
            if (listFindNoCase("open,pending,done,delete", statusValue)) {
                taskStatus = statusValue;
            }
        }

        // --- Ensure taskStatus is never blank ---
        if (!len(taskStatus)) {
            taskStatus = hasValidUser ? "pending" : "open";
        }

        // --- Process due date ---
        var hasDueDate = len(trim(arguments.dueDate)) > 0;
        
        // --- SQL Query ---
        var sql = "
            INSERT INTO tasks
            (user_id, taskName, description, priority, due_date, status, created_at)
            VALUES
            (:userId, :taskName, :description, :priority, :dueDate, :status, NOW())
        ";
        
        // --- Query Parameters ---
        var params = {
            userId = {
                value = finalUserId,
                cfsqltype = "cf_sql_integer",
                null = !hasValidUser
            },
            taskName = {
                value = trim(arguments.taskName),
                cfsqltype = "cf_sql_varchar"
            },
            description = {
                value = trim(arguments.description),
                cfsqltype = "cf_sql_varchar"
            },
            priority = {
                value = lcase(trim(arguments.priority)),
                cfsqltype = "cf_sql_varchar"
            },
            dueDate = {
                value = arguments.dueDate,
                cfsqltype = "cf_sql_date",
                null = !hasDueDate
            },
            status = {
                value = taskStatus,
                cfsqltype = "cf_sql_varchar",
                null = false  // prevent DB default 'delete'
            }
        };
        
        // --- Execute Query ---
        queryExecute(sql, params, {datasource = this.dsn});
        response.success = true;

    } catch (any e) {
        response.success = false;
        response.error = "Error creating task: " & e.message;
        
        // Optional logging
        writeLog(
            type = "error",
            file = "task_errors",
            text = "createTaskForUser failed: " & e.message & " | Detail: " & e.detail
        );
    }

    return response;
}

public query function getOpenTasks() {
    var sql = "
        SELECT 
            id,
            taskName,
            description,
            priority,
            due_date,
            created_at
        FROM tasks
        WHERE status = 'open' 
        AND user_id IS NULL
        ORDER BY 
            CASE priority
                WHEN 'high' THEN 1
                WHEN 'medium' THEN 2
                WHEN 'low' THEN 3
            END,
            due_date ASC
    ";
    
    return queryExecute(sql, {}, {datasource = this.dsn});
}

public struct function claimOpenTask(required numeric taskId, required numeric userId) {
    var response = {success = false, error = ""};
    
    try {
        var sql = "
            UPDATE tasks 
            SET user_id = :userId, status = 'pending'
            WHERE id = :taskId 
            AND status = 'open' 
            AND user_id IS NULL
        ";
        
        var params = {
            userId = {value = arguments.userId, cfsqltype = "cf_sql_integer"},
            taskId = {value = arguments.taskId, cfsqltype = "cf_sql_integer"}
        };
        
        var result = queryExecute(sql, params, {datasource = this.dsn});
        
        if (result.recordCount > 0) {
            response.success = true;
        } else {
            response.error = "Task not available or already claimed.";
        }
        
    } catch (any e) {
        response.error = "Error claiming task: " & e.message;
    }
    
    return response;
}


}
