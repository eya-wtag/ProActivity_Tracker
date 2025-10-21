component {

    // Properties MUST be declared for 'this.dsn' to work
    // Ensure you have an init function to set this property when the component is created
    property name="dsn" type="string"; 

    // Constructor (REQUIRED for 'this.dsn' to be set)
    public function init(required string dsnName) {
        this.dsn = arguments.dsnName;
        return this;
    }


    public query function getTasksByUser(required numeric userId, string statusFilter = "pending") {
        var params = {
            userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"},
            statusFilter: {value: arguments.statusFilter, cfsqltype: "cf_sql_varchar"}
        };
        
        var tasksQuery = queryExecute(
            "SELECT id, taskName, description, priority, due_date, status, created_at 
            FROM tasks
            WHERE user_id = :userId
            AND status = :statusFilter
            AND status <> 'delete' /* Exclude soft-deleted tasks */
            ORDER BY due_date ASC",
            params,
            {datasource: this.dsn} // Use this.dsn
        );
        
        return tasksQuery;
    }


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

        queryExecute(
            "INSERT INTO tasks (user_id, taskName, description, priority, due_date, status)
            VALUES (:userId, :taskName, :description, :priority, :dueDate, 'pending')", // Added status
            {
                userId:      {value: arguments.userId,      cfsqltype: "cf_sql_integer"},
                taskName:    {value: arguments.taskName,    cfsqltype: "cf_sql_varchar"},
                description: {value: arguments.description, cfsqltype: "cf_sql_longvarchar"},
                priority:    {value: arguments.priority,    cfsqltype: "cf_sql_varchar"},
                dueDate:     {value: finalDueDate,          cfsqltype: "cf_sql_date"}
            },
            {datasource: this.dsn} // Use this.dsn
        );
    }


    public void function updateTask(
        required numeric taskId,
        required numeric userId, // <--- ADDED: Security
        string taskName,
        string description,
        string priority,
        date dueDate
    ) {
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
        // isCompleted logic removed

        sql = removeChars(sql, len(sql) - 1, 1);
        sql &= " WHERE id = :taskId AND user_id = :userId"; // Added user_id security
        params.taskId = {value: arguments.taskId, cfsqltype: "cf_sql_integer"};
        params.userId = {value: arguments.userId, cfsqltype: "cf_sql_integer"}; // Added user_id param

        queryExecute(sql, params, {datasource: this.dsn}); // Use this.dsn
    }


    public void function deleteTask(required numeric taskId, required numeric userId) { // Added userId
        queryExecute(
            "UPDATE tasks SET status = 'delete' WHERE id = :taskId AND user_id = :userId",
            {
                taskId: {value: arguments.taskId, cfsqltype: "cf_sql_integer"},
                userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"}
            },
            {datasource: this.dsn} // Use this.dsn
        );
    }


    public boolean function createDoneTask(
        required numeric taskId,
        required numeric userId 
    ) {
        // FIX: Declare 'params' using the 'var' keyword to put it in the local function scope.
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
            // The variable is now correctly scoped:
            params, 
            { datasource: this.dsn }
        );
        
        return qResult.recordCount GT 0;
    }


    public struct function getTask(
        required numeric taskId,
        required numeric userId // <--- REQUIRED for security
    ) {
        var q = queryExecute(
            "SELECT * FROM tasks 
             WHERE id = :taskId 
               AND user_id = :userId",
            { 
                taskId: { value: arguments.taskId, cfsqltype: "cf_sql_integer" },
                userId: { value: arguments.userId, cfsqltype: "cf_sql_integer" }
            },
            { datasource = this.dsn } // Use this.dsn
        );

        if (q.recordCount > 0) {
            return q.getRow(1);
        } else {
            return {};
        }
    }
    public query function getDeletedTasksByUser(required numeric userId) {
    var params = {
        userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"}
    };
    
    var tasksQuery = queryExecute(
        "SELECT id, taskName, description, priority, due_date, status, created_at 
        FROM tasks
        WHERE user_id = :userId
        AND status = 'delete' /* Filter specifically for deleted status */
        ORDER BY due_date ASC",
        params,
        {datasource: this.dsn} // Use this.dsn
    );
    
    return tasksQuery;
}
}
