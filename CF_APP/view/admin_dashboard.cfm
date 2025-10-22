<cfparam name="DSN_NAME" default="todolist">
<cfparam name="session.user" default="">
<cfoutput>
    <h2>Hello, #ucase(session.user.username)#!</h2>
    <h3>Welcome to the Admin Dashboard 🧑‍💼</h3>
</cfoutput>

<hr>

<!--- ============================
     Assign Task to a User
================================= --->
<cftry>
    <!--- Load all users --->
    <cfscript>
        var userModel = new model.query(dsnName=DSN_NAME);
        var getUsers = userModel.getAllUsers(); // Should return id, username
    </cfscript>

    <h3>Assign a Task to a User</h3>
    <form action="index.cfm?action=assignTaskByAdmin" method="post">

        <label for="userId">Select User:</label>
        <select id="userId" name="userId" required>
            <option value="">-- Select User --</option>
            <cfoutput query="getUsers">
                <option value="#getUsers.id#">#getUsers.username#</option>
            </cfoutput>
        </select><br><br>

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

        <button type="submit">Assign Task</button>
    </form>

<cfcatch type="any">
    <cfoutput>Error loading user list: #cfcatch.message#</cfoutput>
</cfcatch>
</cftry>

<hr>

<!--- ============================
     Display All Assigned Tasks
================================= --->
<cftry>
    <cfscript>
        var taskModel = new model.query(dsnName=DSN_NAME);
        var allTasks = taskModel.getAllTasks(); // Should return id, taskName, user_id, username, priority, due_date, status
    </cfscript>

    <h3>All Assigned Tasks:</h3>

    <cfif allTasks.recordCount GT 0>
        <cfoutput>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>ID</th>
                    <th>User</th>
                    <th>Task</th>
                    <th>Priority</th>
                    <th>Due Date</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                <cfloop query="allTasks">
                    <tr>
                        <td>#allTasks.id#</td>
                        <td>#allTasks.username#</td>
                        <td>#allTasks.taskName#</td>
                        <td>#allTasks.priority#</td>
                        <td>
                            <cfif len(allTasks.due_date)>
                                #DateFormat(allTasks.due_date, "mm/dd/yyyy")#
                            <cfelse>
                                N/A
                            </cfif>
                        </td>
                        <td>
                            <cfif allTasks.status eq "done">✅ Done<cfelseif allTasks.status eq "pending">🕒 Pending<cfelse>❌ Deleted</cfif>
                        </td>
                        <td>
                            <a href="index.cfm?action=editTask&amp;taskId=#allTasks.id#">Edit</a> |
                            <a href="index.cfm?action=deleteTask&amp;taskId=#allTasks.id#">Delete</a>
                            
                        </td>
                    </tr>
                </cfloop>
            </table>
        </cfoutput>
    <cfelse>
        <p>No tasks assigned yet.</p>
    </cfif>

<cfcatch type="any">
    <cfoutput>Error loading tasks: #cfcatch.message#</cfoutput>
</cfcatch>
</cftry>

<hr>
<form action="index.cfm?action=logout" method="post">
    <button type="submit">Logout</button>
</form>
