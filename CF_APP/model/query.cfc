component {

    public query function getTasksByUser(required numeric userId) {
        var tasksQuery = queryExecute(
            "SELECT id, taskName, description, priority, is_completed, due_date
            FROM tasks
            WHERE user_id = :userId
            ORDER BY is_completed, due_date ASC",
            {userId: {value: arguments.userId, cfsqltype: "cf_sql_integer"}},
            {datasource: "todolist"} // This one is correct
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
            "INSERT INTO tasks (user_id, taskName, description, priority, due_date)
            VALUES (:userId, :taskName, :description, :priority, :dueDate)",
            {
                userId:      {value: arguments.userId,      cfsqltype: "cf_sql_integer"},
                taskName:    {value: arguments.taskName,    cfsqltype: "cf_sql_varchar"},
                description: {value: arguments.description, cfsqltype: "cf_sql_longvarchar"},
                priority:    {value: arguments.priority,    cfsqltype: "cf_sql_varchar"},
                dueDate:     {value: finalDueDate,          cfsqltype: "cf_sql_date"}
            },
            {datasource: "todolist"} // <-- ADD THIS LINE
        );
    }
    
    public void function updateTask(
        required numeric taskId,
        string taskName,
        string description,
        string priority,
        date dueDate,
        boolean isCompleted
    ) {
        var params = {};
        var sql = "UPDATE tasks SET ";

        if (structKeyExists(arguments, "taskName")) {
            sql &= "task_name = :taskName, ";
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
        if (structKeyExists(arguments, "isCompleted")) {
            sql &= "is_completed = :isCompleted, ";
            params.isCompleted = {value: arguments.isCompleted, cfsqltype: "cf_sql_boolean"};
        }

        sql = removeChars(sql, len(sql) - 1, 1);
        sql &= " WHERE id = :taskId";
        params.taskId = {value: arguments.taskId, cfsqltype: "cf_sql_integer"};

        queryExecute(sql, params, {datasource: "todolist"}); // <-- ADD THIS LINE
    }
    
    public void function deleteTask(required numeric taskId) {
        queryExecute(
            "DELETE FROM tasks WHERE id = :taskId",
            {taskId: {value: arguments.taskId, cfsqltype: "cf_sql_integer"}},
            {datasource: "todolist"} // <-- ADD THIS LINE
        );
    }

}