<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Task Manager</title>
    <link rel="stylesheet" href="view/index.css">
</head>
<body>
    <cfparam name="DSN_NAME" default="todolist">
    <cfparam name="session.user" default="">
    
    <div class="admin-container">
        <cfoutput>
        <div class="header">
            <h2>Hello, #ucase(session.user.username)#!</h2>
            <h3>Welcome to the Admin Dashboard 🧑‍💼</h3>
        </div>
        </cfoutput>

        <div class="content">
            <!-- Assign Task Section -->
            <div class="section">
                <h3 class="section-title">Assign a Task to a User</h3>
                
                <cftry>
                    <cfscript>
                        var userModel = new model.query(dsnName=DSN_NAME);
                        var getUsers = userModel.getAllUsers();
                    </cfscript>

                    <div class="form-container">
                        <form action="index.cfm?action=assignTaskByAdmin" method="post">
                            <div class="form-group">
                                <label for="userId">Select User:</label>
                                <select id="userId" name="userId" required>
                                    <option value="">-- Select User --</option>
                                    <cfoutput query="getUsers">
                                        <option value="#getUsers.id#">#getUsers.username#</option>
                                    </cfoutput>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="taskName">Task Name:</label>
                                <input type="text" id="taskName" name="taskName" required>
                            </div>

                            <div class="form-group">
                                <label for="description">Description:</label>
                                <textarea id="description" name="description"></textarea>
                            </div>

                            <div class="form-group">
                                <label for="priority">Priority:</label>
                                <select id="priority" name="priority">
                                    <option value="low">Low</option>
                                    <option value="medium" selected>Medium</option>
                                    <option value="high">High</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="dueDate">Due Date:</label>
                                <input type="date" id="dueDate" name="dueDate" value="<cfoutput>#dateFormat(now(), 'yyyy-mm-dd')#</cfoutput>">
                            </div>

                            <button type="submit">Assign Task</button>
                        </form>
                    </div>

                <cfcatch type="any">
                    <div class="error-message">
                        <cfoutput>Error loading user list: #cfcatch.message#</cfoutput>
                    </div>
                </cfcatch>
                </cftry>
            </div>

            <div class="divider"></div>

            <!-- All Tasks Section -->
            <div class="section">
                <h3 class="section-title">All Assigned Tasks</h3>

                <cftry>
                    <cfscript>
                        var taskModel = new model.query(dsnName=DSN_NAME);
                        var allTasks = taskModel.getAllTasks();
                    </cfscript>

                    <cfif allTasks.recordCount GT 0>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>User</th>
                                        <th>Task</th>
                                        <th>Priority</th>
                                        <th>Due Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput>
                                    <cfloop query="allTasks">
                                        <tr>
                                            <td class="task-id">#allTasks.id#</td>
                                            <td class="user-name">#allTasks.username#</td>
                                            <td>#allTasks.taskName#</td>
                                            <td>
                                                <span class="priority-badge priority-#lcase(allTasks.priority)#">
                                                    #ucase(allTasks.priority)#
                                                </span>
                                            </td>
                                            <td>
                                                <cfif len(allTasks.due_date)>
                                                    #DateFormat(allTasks.due_date, "mm/dd/yyyy")#
                                                <cfelse>
                                                    N/A
                                                </cfif>
                                            </td>
                                            <td>
                                                <cfif allTasks.status eq "done">
                                                    <span class="status-badge status-done">✅ Done</span>
                                                <cfelseif allTasks.status eq "pending">
                                                    <span class="status-badge status-pending">🕒 Pending</span>
                                                <cfelse>
                                                    <span class="status-badge status-deleted">❌ Deleted</span>
                                                </cfif>
                                            </td>
                                            <td class="action-links">
                                                <a href="index.cfm?action=editTask&amp;taskId=#allTasks.id#">Edit</a>
                                                <a href="index.cfm?action=deleteTask&amp;taskId=#allTasks.id#">Delete</a>
                                            </td>
                                        </tr>
                                    </cfloop>
                                    </cfoutput>
                                </tbody>
                            </table>
                        </div>
                    <cfelse>
                        <div class="empty-state">
                            <span>📋</span>
                            <p>No tasks assigned yet.</p>
                        </div>
                    </cfif>

                <cfcatch type="any">
                    <div class="error-message">
                        <cfoutput>Error loading tasks: #cfcatch.message#</cfoutput>
                    </div>
                </cfcatch>
                </cftry>
            </div>

            <div class="divider"></div>

            <!-- Logout -->
            <div class="logout-container">
                <form action="index.cfm?action=logout" method="post">
                    <button type="submit" class="logout-btn">Logout</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>