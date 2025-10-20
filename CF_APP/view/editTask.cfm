<cfoutput>
<h2>Edit Task</h2>

<form method="POST" action="index.cfm?action=editTask">
    <!-- Hidden field for task ID -->
    <input type="hidden" name="taskId" value="#taskDetails.id#">

    <div>
        <label for="taskName">Task Name:</label><br>
        <input 
            type="text" 
            id="taskName" 
            name="taskName" 
            value="#encodeForHtml(taskDetails.taskname)#" 
            required
        >
    </div>

    <div>
        <label for="description">Description:</label><br>
        <textarea 
            id="description" 
            name="description"
            rows="4" 
            cols="40"
        >#encodeForHtml(taskDetails.description)#</textarea>
    </div>

    <div>
        <label for="priority">Priority:</label><br>
        <select id="priority" name="priority">
            <option value="Low"     <cfif taskDetails.priority eq "Low">selected</cfif>>Low</option>
            <option value="Medium"  <cfif taskDetails.priority eq "Medium">selected</cfif>>Medium</option>
            <option value="High"    <cfif taskDetails.priority eq "High">selected</cfif>>High</option>
        </select>
    </div>

    <div>
        <label for="dueDate">Due Date:</label><br>
        <input 
            type="date" 
            id="dueDate" 
            name="dueDate"
            value="#dateFormat(taskDetails.due_date, 'yyyy-mm-dd')#"
        >
    </div>

    <div style="margin-top: 10px;">
        <button type="submit">💾 Update Task</button>
        <a href="index.cfm?action=dashboard" style="margin-left:10px;">Cancel</a>
    </div>
</form>
</cfoutput>
