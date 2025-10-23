<cfoutput>
    <h2>Hello, #ucase(session.user.username)# !</h2>
    <h3>Welcome to the Dashboard! </h3>
</cfoutput>

<h3>Add a New Task</h3> 
<form action="index.cfm?action=createTask" method="post">
    <label for="taskName">Task Name:</label>
    <input type="text" id="taskName" name="taskName" required><br><br>

    <label for="description">Description:</label>
    <textarea id="description" name="description"></textarea><br><br>

    <label for="priority">Priority:</label>
    <select id="priority" name="priority">
        <option value="low">Low</option>
        <option value="medium" selected>Medium</option>
        <option value="high">High</option>
    </select><br><br>

    <label for="dueDate">Due Date:</label>
    <input type="date" id="dueDate" name="dueDate"><br><br>

    <button type="submit">Add Task</button>
</form>

<hr>

<br>

<h3>Your Pending Tasks:</h3>

<cfif structKeyExists(session, "user_id")>
    <cfscript>

        var DSN_NAME = "todolist"; 
        
        // Data retrieval for PENDING tasks
        var taskModel = new model.query(dsnName=DSN_NAME);
        var pendingTasks = taskModel.getTasksByUser(session.user_id, "pending");
    </cfscript>

    <cfif pendingTasks.recordCount GT 0>
        <cfoutput>
            <ul>
            <cfloop query="pendingTasks">
                <div class="task-item">
                    <li><strong>#pendingTasks.taskName#</strong> (Priority: #pendingTasks.priority#) <br>
                    Due: #DateFormat(pendingTasks.due_date, "mm/dd/yyyy")#
                    </li>
                    <div style="margin-top: 5px;">
                        <a href="index.cfm?action=editTask&amp;taskId=#pendingTasks.id#">Edit</a>
                        | <a href="index.cfm?action=markDone&amp;taskId=#pendingTasks.id#">Mark Done</a> 
                        | <a href="index.cfm?action=deleteTask&amp;taskId=#pendingTasks.id#">Delete</a>
                    </div>
                </div>
            </cfloop>
            </ul>
        </cfoutput>
    <cfelse>
        <p>You have no pending tasks. 🎉</p>
    </cfif>
</cfif>

<hr>

<h3>Your Completed Tasks:</h3>

<cfif structKeyExists(session, "user_id")>
    <cfscript>
        // Data retrieval for DONE tasks
        var taskModel = new model.query(dsnName=DSN_NAME);
        var doneTasks = taskModel.getTasksByUser(session.user_id, "done");
    </cfscript>

    <cfif doneTasks.recordCount GT 0>
        <cfoutput>
            <ul>
            <cfloop query="doneTasks">
                <div class="task-item done">
                    <li><strong>#doneTasks.taskName#</strong> (Priority: #doneTasks.priority#) <br>
                    Completed (Created At): #DateFormat(doneTasks.created_at, "mm/dd/yyyy")#
                    </li>
                    <div style="margin-top: 5px;">
                        <a href="index.cfm?action=deleteTask&amp;taskId=#doneTasks.id#">Delete Permanently</a>
                    </div>
                </div>
            </cfloop>
            </ul>
        </cfoutput>
    <cfelse>
        <p>No tasks completed yet. ✅</p>
    </cfif>
</cfif>

<hr>

 <h3>Deleted/Archived Tasks:</h3>

<cfif structKeyExists(session, "user_id")>
    <cfscript>
        // You need a new model function or modify getTasksByUser to handle 'delete' status
        var taskModel = new model.query(dsnName=DSN_NAME);
        var deletedTasks = taskModel.getDeletedTasksByUser(session.user_id); 
    </cfscript>

    <cfif deletedTasks.recordCount GT 0>
        <cfoutput>
            <ul>
            <cfloop query="deletedTasks">
             
                <div class="task-item deleted">
                    <li><strong>#deletedTasks.taskName#</strong> (Priority: #deletedTasks.priority#)
                    Deleted (Status): #deletedTasks.status# 
                    </li>
                   
                </div>
            </cfloop>
            </ul>
        </cfoutput>
    <cfelse>
        <p>No tasks currently deleted. 🗑️</p>
    </cfif>
</cfif>

<hr>

<form action="index.cfm?action=logout" method="post">
    <button type="submit">Logout</button>
</form>

