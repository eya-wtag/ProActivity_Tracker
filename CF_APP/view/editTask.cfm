<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Task - Task Manager</title>
    <link rel="stylesheet" href="view/index.css">
</head>
<body>
    <div class="edit-container">
        <h2>✏️ Edit Task</h2>

        <cfoutput>
        <form method="POST" action="index.cfm?action=editTask">
            <input type="hidden" name="taskId" value="#taskDetails.id#">

            <div class="form-group">
                <label for="taskName">Task Name:</label>
                <input 
                    type="text" 
                    id="taskName" 
                    name="taskName" 
                    value="#encodeForHtml(taskDetails.taskname)#" 
                    placeholder="Enter task name"
                    required
                >
            </div>

            <div class="form-group">
                <label for="description">Description:</label>
                <textarea 
                    id="description" 
                    name="description"
                    placeholder="Enter task description"
                >#encodeForHtml(taskDetails.description)#</textarea>
            </div>

            <div class="form-group">
                <label for="priority">Priority:</label>
                <select id="priority" name="priority">
                    <option value="Low" <cfif taskDetails.priority eq "Low">selected</cfif>>
                        🔵 Low
                    </option>
                    <option value="Medium" <cfif taskDetails.priority eq "Medium">selected</cfif>>
                        🟡 Medium
                    </option>
                    <option value="High" <cfif taskDetails.priority eq "High">selected</cfif>>
                        🔴 High
                    </option>
                </select>
            </div>

            <div class="form-group">
                <label for="dueDate">Due Date:</label>
                <input 
                    type="date" 
                    id="dueDate" 
                    name="dueDate"
                    value="#dateFormat(taskDetails.due_date, 'yyyy-mm-dd')#"
                >
            </div>

            <div class="button-group">
                <button type="submit">💾 Update Task</button>
                <a href="index.cfm?action=dashboard" class="cancel-link">Cancel</a>
            </div>
        </form>
        </cfoutput>
    </div>
</body>
</html>