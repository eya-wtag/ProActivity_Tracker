<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager Dashboard</title>
    <link rel="stylesheet" href="view/index.css">
</head>
<body>
    <div class="container">
        <cfoutput>
        <div class="header">
            <h2>Hello, #ucase(session.user.username)#!</h2>
            <h3>Welcome to the Dashboard!</h3>
        </div>
        </cfoutput>

        <div class="content">
            <!-- Add Task Form -->
            <div class="section">
                <h3 class="section-title">Add a New Task</h3>
                <div class="form-container">
                    <form action="index.cfm?action=createTask" method="post">
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
                                <input 
                                    type="date" 
                                    id="dueDate" 
                                    name="dueDate" 
                                    value="<cfoutput>#dateFormat(now(), 'yyyy-mm-dd')#</cfoutput>"
                                    readonly
                                >
                            </div>

                            <script>
                            document.addEventListener("DOMContentLoaded", function() {
                                const prioritySelect = document.getElementById("priority");
                                const dueDateInput = document.getElementById("dueDate");

                                function updateDueDate() {
                                    let daysToAdd = 0;
                                    switch(prioritySelect.value) {
                                        case "low": daysToAdd = 1; break;
                                        case "medium": daysToAdd = 2; break;
                                        case "high": daysToAdd = 5; break;
                                    }

                                    const today = new Date();
                                    today.setDate(today.getDate() + daysToAdd);

                                    const year = today.getFullYear();
                                    const month = ("0" + (today.getMonth() + 1)).slice(-2);
                                    const day = ("0" + today.getDate()).slice(-2);

                                    dueDateInput.value = `${year}-${month}-${day}`;
                                }

                                // Run on page load and when priority changes
                                updateDueDate();
                                prioritySelect.addEventListener("change", updateDueDate);
                            });
                            </script>


                        <button type="submit">Add Task</button>
                    </form>
                </div>
            </div>
<div class="divider"></div>

<div class="section">
    <h3 class="section-title">Available Open Tasks</h3>

    <cfif structKeyExists(session, "user_id")>
        <cfscript>
            var DSN_NAME = "todolist"; 
            var taskModel = new model.query(dsnName=DSN_NAME);
            var openTasks = taskModel.getOpenTasks();
        </cfscript>

        <cfif openTasks.recordCount GT 0>
            <cfoutput>
                <ul class="task-list">
                <cfloop query="openTasks">
                    <div class="task-item open-task">
                        <li>
                            <strong>#openTasks.taskName#</strong>
                            <span class="task-priority priority-#lcase(openTasks.priority)#">#ucase(openTasks.priority)#</span>
                            <span class="task-date">Due: #DateFormat(openTasks.due_date, "mm/dd/yyyy")#</span>
                            
                            <cfif len(openTasks.description)>
                                <p style="color: ##666; margin-top: 10px; font-size: 0.95em;">#openTasks.description#</p>
                            </cfif>
                            
                            <div style="margin-top: 15px;">
                                <a href="index.cfm?action=claimTask&amp;taskId=#openTasks.id#" 
                                   class="claim-btn"
                                   onclick="return confirm('Do you want to claim this task?');">
                                    ✋ Claim This Task
                                </a>
                            </div>
                        </li>
                    </div>
                </cfloop>
                </ul>
            </cfoutput>
        <cfelse>
            <div class="empty-state">
                <span>📭</span>
                <p>No open tasks available at the moment.</p>
            </div>
        </cfif>
    </cfif>
</div>
            <div class="divider"></div>

            <!-- Pending Tasks -->
            <div class="section">
                <h3 class="section-title">Your Pending Tasks</h3>

                <cfif structKeyExists(session, "user_id")>
                    <cfscript>
                        var DSN_NAME = "todolist"; 
                        var taskModel = new model.query(dsnName=DSN_NAME);
                        var pendingTasks = taskModel.getTasksByUser(session.user_id, "pending");
                    </cfscript>

                    <cfif pendingTasks.recordCount GT 0>
                        <cfoutput>
                            <ul class="task-list">
                            <cfloop query="pendingTasks">
                                <li class="task-item">
                                    <strong>#pendingTasks.taskName#</strong>
                                    <span class="task-priority priority-#lcase(pendingTasks.priority)#">#ucase(pendingTasks.priority)#</span>
                                    <span class="task-date">Due: #DateFormat(pendingTasks.due_date, "mm/dd/yyyy")#</span>
                                    <div class="task-actions">
                                        <a href="index.cfm?action=editTask&amp;taskId=#pendingTasks.id#">Edit</a>
                                        <a href="index.cfm?action=markDone&amp;taskId=#pendingTasks.id#">Mark Done</a>
                                        <a href="index.cfm?action=deleteTask&amp;taskId=#pendingTasks.id#">Delete</a>
                                    </div>
                                </li>
                            </cfloop>
                            </ul>
                        </cfoutput>
                    <cfelse>
                        <div class="empty-state">
                            <span>🎉</span>
                            <p>You have no pending tasks.</p>
                        </div>
                    </cfif>
                </cfif>
            </div>

            <div class="divider"></div>

            <!-- Completed Tasks -->
            <div class="section">
                <h3 class="section-title">Your Completed Tasks</h3>

                <cfif structKeyExists(session, "user_id")>
                    <cfscript>
                        var taskModel = new model.query(dsnName=DSN_NAME);
                        var doneTasks = taskModel.getTasksByUser(session.user_id, "done");
                    </cfscript>

                    <cfif doneTasks.recordCount GT 0>
                        <cfoutput>
                            <ul class="task-list">
                            <cfloop query="doneTasks">
                                <li class="task-item done">
                                    <strong>#doneTasks.taskName#</strong>
                                    <span class="task-priority priority-#lcase(doneTasks.priority)#">#ucase(doneTasks.priority)#</span>
                                    <span class="task-date">Completed: #DateFormat(doneTasks.created_at, "mm/dd/yyyy")#</span>
                                    <div class="task-actions">
                                        <a href="index.cfm?action=deleteTask&amp;taskId=#doneTasks.id#">Delete Permanently</a>
                                    </div>
                                </li>
                            </cfloop>
                            </ul>
                        </cfoutput>
                    <cfelse>
                        <div class="empty-state">
                            <span>✅</span>
                            <p>No tasks completed yet.</p>
                        </div>
                    </cfif>
                </cfif>
            </div>

            <div class="divider"></div>

            <!-- Deleted/Archived Tasks -->
            <div class="section">
                <h3 class="section-title">Deleted/Archived Tasks</h3>

                <cfif structKeyExists(session, "user_id")>
                    <cfscript>
                        var taskModel = new model.query(dsnName=DSN_NAME);
                        var deletedTasks = taskModel.getDeletedTasksByUser(session.user_id); 
                    </cfscript>

                    <cfif deletedTasks.recordCount GT 0>
                        <cfoutput>
                            <ul class="task-list">
                            <cfloop query="deletedTasks">
                                <li class="task-item deleted">
                                    <strong>#deletedTasks.taskName#</strong>
                                    <span class="task-priority priority-#lcase(deletedTasks.priority)#">#ucase(deletedTasks.priority)#</span>
                                    <span class="task-date">Status: #deletedTasks.status#</span>
                                </li>
                            </cfloop>
                            </ul>
                        </cfoutput>
                    <cfelse>
                        <div class="empty-state">
                            <span>🗑️</span>
                            <p>No tasks currently deleted.</p>
                        </div>
                    </cfif>
                </cfif>
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