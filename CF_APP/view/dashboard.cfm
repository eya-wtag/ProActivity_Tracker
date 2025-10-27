<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager Dashboard</title>
    
    <style>
        /* ======================================
           GLOBAL STYLES
           ====================================== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        /* ======================================
           CONTAINER STYLES
           ====================================== */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
        }

        /* ======================================
           ANIMATIONS
           ====================================== */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        /* ======================================
           HEADER STYLES
           ====================================== */
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 40px;
            text-align: center;
        }

        .header h2 {
            font-size: 2em;
            margin-bottom: 10px;
        }

        .header h3 {
            font-size: 1.2em;
            font-weight: 300;
            opacity: 0.9;
        }

        /* ======================================
           TAB NAVIGATION
           ====================================== */
        .tab-buttons {
            display: flex;
            gap: 10px;
            margin: 20px 40px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .tab-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            font-size: 14px;
            font-weight: 500;
        }

        .tab-button:hover {
            background-color: #0056b3;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 123, 255, 0.3);
        }

        .tab-button.active {
            background-color: #0056b3;
            font-weight: bold;
            box-shadow: 0 4px 12px rgba(0, 86, 179, 0.4);
        }

        /* ======================================
           CONTENT AREA
           ====================================== */
        .content {
            padding: 40px;
        }

        .section {
            display: none;
            margin-bottom: 40px;
        }

        .section.active {
            display: block;
            animation: fadeIn 0.3s ease-in-out;
        }

        .section-title {
            font-size: 1.5em;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
            display: inline-block;
        }

        /* ======================================
           FORM STYLES
           ====================================== */
        .form-container {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 600;
            font-size: 0.95em;
        }

        input[type="text"],
        input[type="date"],
        textarea,
        select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 1em;
            transition: all 0.3s ease;
            font-family: inherit;
        }

        input[type="text"]:focus,
        input[type="date"]:focus,
        textarea:focus,
        select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        textarea {
            resize: vertical;
            min-height: 100px;
        }

        /* ======================================
           BUTTON STYLES
           ====================================== */
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
        }

        button:active {
            transform: translateY(0);
        }

        .logout-btn {
            background: #dc3545 !important;
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.4) !important;
        }

        .logout-btn:hover {
            background: #b52a38 !important;
            box-shadow: 0 6px 20px rgba(220, 53, 69, 0.6) !important;
        }

        /* ======================================
           TASK LIST STYLES
           ====================================== */
        .task-list {
            list-style: none;
        }

        .task-item {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .task-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 5px;
            background: #667eea;
        }

        .task-item.done {
            background: #f0f9ff;
            border-color: #4ade80;
        }

        .task-item.done::before {
            background: #4ade80;
        }

        .task-item.deleted {
            background: #fff1f2;
            border-color: #fca5a5;
            opacity: 0.7;
        }

        .task-item.deleted::before {
            background: #ef4444;
        }

        .task-item:hover {
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
        }

        .task-item strong {
            color: #333;
            font-size: 1.1em;
            display: block;
            margin-bottom: 8px;
        }

        .task-priority {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            margin-left: 10px;
        }

        .priority-high {
            background: #fee2e2;
            color: #dc2626;
        }

        .priority-medium {
            background: #fef3c7;
            color: #d97706;
        }

        .priority-low {
            background: #dbeafe;
            color: #2563eb;
        }

        .task-date {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
            display: block;
        }

        .task-actions {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e0e0e0;
        }

        .task-actions a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            margin-right: 15px;
            font-size: 0.9em;
            transition: color 0.3s ease;
        }

        .task-actions a:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        /* ======================================
           OPEN TASKS & CLAIM BUTTON
           ====================================== */
        .open-task {
            background: #fef3c7;
            border-color: #fbbf24;
        }

        .open-task::before {
            background: #fbbf24;
        }

        .claim-btn {
            display: inline-block;
            padding: 10px 20px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.95em;
            transition: all 0.3s ease;
            box-shadow: 0 2px 10px rgba(16, 185, 129, 0.3);
            margin-top: 10px;
        }

        .claim-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.5);
        }

        .claim-btn:active {
            transform: translateY(0);
        }

        /* ======================================
           EMPTY STATE
           ====================================== */
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 1.1em;
        }

        .empty-state span {
            font-size: 2em;
            display: block;
            margin-bottom: 10px;
        }

        /* ======================================
           LOGOUT CONTAINER
           ====================================== */
        .logout-container {
            text-align: center;
            padding: 20px 0;
            margin-top: 40px;
            border-top: 2px solid #e9ecef;
        }

        /* ======================================
           RESPONSIVE DESIGN
           ====================================== */
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .content {
                padding: 20px;
            }

            .header {
                padding: 20px;
            }

            .header h2 {
                font-size: 1.5em;
            }

            .form-container {
                padding: 20px;
            }

            .tab-buttons {
                flex-direction: column;
                align-items: stretch;
                margin: 20px;
            }
            
            .tab-button {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <cfoutput>
        <div class="header">
            <h2>Hello, #ucase(session.user.username)#!</h2>
            <h3>Welcome to the Dashboard!</h3>
        </div>
        </cfoutput>

        <!-- Tab Buttons -->
        <div class="tab-buttons">
            <button class="tab-button active" data-target="addTask">➕ Add Task</button>
            <button class="tab-button" data-target="openTasks">📂 Open Tasks</button>
            <button class="tab-button" data-target="pendingTasks">⏳ Pending</button>
            <button class="tab-button" data-target="completedTasks">✅ Completed</button>
            <button class="tab-button" data-target="deletedTasks">🗑️ Deleted</button>
        </div>

        <div class="content">
            <!-- Add Task Section -->
            <div id="addTask" class="section active">
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

                        <button type="submit">Add Task</button>
                    </form>
                </div>
            </div>

            <!-- Open Tasks -->
            <div id="openTasks" class="section">
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
                                    <li class="task-item open-task">
                                        <strong>#openTasks.taskName#</strong>
                                        <span class="task-priority priority-#lcase(openTasks.priority)#">#ucase(openTasks.priority)#</span>
                                        <span class="task-date">Due: #DateFormat(openTasks.due_date, "mm/dd/yyyy")#</span>
                                        <cfif len(openTasks.description)>
                                            <p>#openTasks.description#</p>
                                        </cfif>
                                        <a href="index.cfm?action=claimTask&amp;taskId=#openTasks.id#"
                                            class="claim-btn"
                                            onclick="return confirm('Do you want to claim this task?');">
                                            ✋ Claim This Task
                                        </a>
                                    </li>
                                </cfloop>
                            </ul>
                        </cfoutput>
                    <cfelse>
                        <div class="empty-state">
                            <span>📂</span>
                            <p>No open tasks available.</p>
                        </div>
                    </cfif>
                </cfif>
            </div>

            <!-- Pending -->
            <div id="pendingTasks" class="section">
                <h3 class="section-title">Your Pending Tasks</h3>
                <cfif structKeyExists(session, "user_id")>
                    <cfscript>
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
                            <p>No pending tasks.</p>
                        </div>
                    </cfif>
                </cfif>
            </div>

            <!-- Completed -->
            <div id="completedTasks" class="section">
                <h3 class="section-title">Your Completed Tasks</h3>
                <cfif structKeyExists(session, "user_id")>
                    <cfscript>
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
                            <p>No completed tasks yet.</p>
                        </div>
                    </cfif>
                </cfif>
            </div>

            <!-- Deleted -->
            <div id="deletedTasks" class="section">
                <h3 class="section-title">Deleted/Archived Tasks</h3>
                <cfif structKeyExists(session, "user_id")>
                    <cfscript>
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
                            <p>No deleted tasks.</p>
                        </div>
                    </cfif>
                </cfif>
            </div>

            <!-- Logout -->
            <div class="logout-container">
                <form action="index.cfm?action=logout" method="post">
                    <button type="submit" class="logout-btn">Logout</button>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Priority-based due date updater
        (function() {
            const prioritySelect = document.getElementById("priority");
            const dueDateInput = document.getElementById("dueDate");

            if (prioritySelect && dueDateInput) {
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

                    dueDateInput.value = year + "-" + month + "-" + day;
                }

                // Run on page load and when priority changes
                updateDueDate();
                prioritySelect.addEventListener("change", updateDueDate);
            }
        })();

        // Tab switching functionality
        document.addEventListener('DOMContentLoaded', function() {
            const buttons = document.querySelectorAll(".tab-button");
            const sections = document.querySelectorAll(".section");

            buttons.forEach(function(btn) {
                btn.addEventListener("click", function() {
                    // Remove active class from all buttons
                    buttons.forEach(function(b) {
                        b.classList.remove("active");
                    });
                    
                    // Remove active class from all sections
                    sections.forEach(function(s) {
                        s.classList.remove("active");
                    });

                    // Add active class to clicked button
                    btn.classList.add("active");
                    
                    // Show the target section
                    const targetId = btn.getAttribute('data-target');
                    const target = document.getElementById(targetId);
                    
                    if (target) {
                        target.classList.add("active");
                    }
                });
            });
        });
    </script>
</body>
</html>