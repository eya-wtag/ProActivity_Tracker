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
            // Log the detailed error (optional but recommended)
            // log.error("Error in getTasksByUser: " & e.message & " - " & e.detail);
            
            // Re-throw a controlled, application-level error
            throw(
                type="Database.ReadError", 
                message="Failed to retrieve tasks for user ID " & arguments.userId,
                detail=e.message // Pass the underlying error message for debugging
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
    public query function searchTasks(
        required numeric userId,
        string keyword = "",
        string status = "",
        string priority = "",
        string sortBy = "due_date",
        string sortOrder = "ASC"
    ) {

        var sql = "
            SELECT *
            FROM tasks
            WHERE user_id = :userId
        ";
        var params = { userId = arguments.userId };

        // Keyword search
        if (len(trim(arguments.keyword))) {
            sql &= " AND (taskname LIKE :keyword OR description LIKE :keyword)";
            params.keyword = "%" & arguments.keyword & "%";
        }

        // Status filter
        if (len(trim(arguments.status))) {
            sql &= " AND is_completed = :status";
            params.status = arguments.status;
        }

        // Priority filter
        if (len(trim(arguments.priority))) {
            sql &= " AND priority = :priority";
            params.priority = arguments.priority;
        }

        // Sorting
        sql &= " ORDER BY " & arguments.sortBy & " " & arguments.sortOrder;

        return queryExecute(sql, params, {datasource: "todolist"});
    }

}
