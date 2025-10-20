
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




<h3>Your Tasks:</h3>

<cfif structKeyExists(session, "user_id")>
    <cfscript>
        // 1. DATA RETRIEVAL: Do this in CFScript
        var taskModel = new model.query();
        var myTasks = taskModel.getTasksByUser(session.user_id);
    </cfscript>

    <cfif myTasks.recordCount GT 0>
        <cfoutput>
            <cfloop query="myTasks">
                <div class="task-item">
                    <strong>#myTasks.taskName#</strong><br>
                    Priority: #myTasks.priority# - Due: #DateFormat(myTasks.due_date, "mm/dd/yyyy")#
                    <a href="index.cfm?action=editTask&amp;taskId=#myTasks.id#">Edit</a>
                    <a href="index.cfm?action=deleteTask&amp;taskId=#myTasks.id#">Delete</a>
                </div>
            </cfloop>
        </cfoutput>
    <cfelse>
        <p>You have no tasks assigned at this time. 🎉</p>
    </cfif>
</cfif>



<form action="index.cfm?action=logout" method="post">
    <button type="submit">Logout</button>
</form>

<!---
  <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <!-- Load Tailwind CSS for modern styling -->
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .task-list-container { max-height: 60vh; overflow-y: auto; }
        .modal { transition: opacity 0.25s ease; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen p-8 font-sans">

<div class="max-w-4xl mx-auto bg-white p-6 md:p-10 rounded-xl shadow-2xl">

    <cfoutput>
        <h2 class="text-4xl font-bold text-gray-900">Hello, #ucase(session.user.username)# !</h2>
        <h3 class="text-xl text-indigo-600 mt-2 mb-8">Welcome to the Dashboard! </h3>
    </cfoutput>

    <!-- Task Creation Form (Now submitted via AJAX) -->
    <h3 class="text-2xl font-semibold text-gray-700 border-b pb-2 mb-6">Add a New Task</h3> 
    <form id="createTaskForm" class="grid grid-cols-1 md:grid-cols-2 gap-4 bg-gray-50 p-6 rounded-lg shadow-inner">
        
        <div class="col-span-1">
            <label for="taskName" class="block text-sm font-medium text-gray-700">Task Name:</label>
            <input type="text" id="taskName" name="taskName" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2 focus:ring-indigo-500 focus:border-indigo-500">
        </div>

        <div class="col-span-1">
            <label for="priority" class="block text-sm font-medium text-gray-700">Priority:</label>
            <select id="priority" name="priority" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2 focus:ring-indigo-500 focus:border-indigo-500">
                <option value="low">Low</option>
                <option value="medium" selected>Medium</option>
                <option value="high">High</option>
            </select>
        </div>

        <div class="col-span-2">
            <label for="description" class="block text-sm font-medium text-gray-700">Description:</label>
            <textarea id="description" name="description" rows="2" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2 focus:ring-indigo-500 focus:border-indigo-500"></textarea>
        </div>
        
        <div class="col-span-1">
            <label for="dueDate" class="block text-sm font-medium text-gray-700">Due Date (Optional):</label>
            <input type="date" id="dueDate" name="dueDate" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2 focus:ring-indigo-500 focus:border-indigo-500">
        </div>
        
        <div class="col-span-2 flex justify-end items-end">
            <button type="submit" class="w-full md:w-auto px-6 py-2 bg-indigo-600 text-white font-medium rounded-md shadow-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 transition duration-150">
                Add Task
            </button>
        </div>
    </form>

    <div id="statusMessage" class="mt-4 p-3 rounded text-center text-white font-medium hidden"></div>

    <hr class="my-8">

    <!-- Task List Container -->
    <h3 class="text-2xl font-semibold text-gray-700 border-b pb-2 mb-6">Your Tasks:</h3>
    <div id="taskList" class="task-list-container space-y-3">
        <!-- Tasks will be injected here by JavaScript -->
        <p class="text-gray-500 mt-4 text-center">Loading tasks...</p>
    </div>
    
    <hr class="my-8">

    <form action="index.cfm?action=logout" method="post">
        <button type="submit" class="px-4 py-2 bg-red-500 text-white font-medium rounded-md hover:bg-red-600 transition duration-150">Logout</button>
    </form>
</div>

<!-- Edit Task Modal Structure -->
<div id="editModal" class="modal fixed inset-0 bg-gray-600 bg-opacity-75 flex items-center justify-center opacity-0 pointer-events-none z-50">
    <div class="modal-content bg-white p-8 rounded-xl shadow-2xl w-full max-w-lg transform transition-all scale-95">
        <h4 class="text-2xl font-bold mb-4">Edit Task</h4>
        <form id="editTaskForm">
            <input type="hidden" id="editTaskId" name="taskId">
            
            <label class="block mb-2 text-sm font-medium text-gray-700" for="editTaskName">Task Name:</label>
            <input type="text" id="editTaskName" name="taskName" required class="w-full mb-4 p-2 border rounded-md">

            <label class="block mb-2 text-sm font-medium text-gray-700" for="editDescription">Description:</label>
            <textarea id="editDescription" name="description" rows="2" class="w-full mb-4 p-2 border rounded-md"></textarea>

            <label class="block mb-2 text-sm font-medium text-gray-700" for="editPriority">Priority:</label>
            <select id="editPriority" name="priority" class="w-full mb-4 p-2 border rounded-md">
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
            </select>
            
            <label class="block mb-2 text-sm font-medium text-gray-700" for="editDueDate">Due Date:</label>
            <input type="date" id="editDueDate" name="dueDate" class="w-full mb-4 p-2 border rounded-md">

            <div class="flex items-center space-x-2 mb-4">
                <input type="checkbox" id="editIsCompleted" name="isCompleted" class="rounded text-indigo-600 focus:ring-indigo-500">
                <label for="editIsCompleted" class="text-sm font-medium text-gray-700">Completed</label>
            </div>

            <div class="flex justify-end space-x-3">
                <button type="button" onclick="closeModal()" class="px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-100 transition duration-150">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition duration-150">Save Changes</button>
            </div>
        </form>
    </div>
</div>


<script>
    const taskListEl = document.getElementById('taskList');
    const statusMessageEl = document.getElementById('statusMessage');
    const createTaskForm = document.getElementById('createTaskForm');
    const editTaskForm = document.getElementById('editTaskForm');
    const editModal = document.getElementById('editModal');
    
    const apiEndpoint = 'api/tasks.cfm';

    // --- Utility Functions ---

    function showStatus(message, type = 'success') {
        statusMessageEl.innerText = message;
        statusMessageEl.classList.remove('hidden', 'bg-red-500', 'bg-green-500');
        statusMessageEl.classList.add(type === 'success' ? 'bg-green-500' : 'bg-red-500');
        setTimeout(() => {
            statusMessageEl.classList.add('hidden');
        }, 3000);
    }

    function formatDate(dateString) {
        if (!dateString) return 'N/A';
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', { year: 'numeric', month: '2-digit', day: '2-digit' });
        } catch (e) {
            return dateString; // Return original if parsing fails
        }
    }

    // --- Modal Functions ---

    function closeModal() {
        editModal.classList.add('opacity-0', 'pointer-events-none');
        editModal.classList.remove('opacity-100');
    }

    function showModal(taskId, task) {
        document.getElementById('editTaskId').value = taskId;
        document.getElementById('editTaskName').value = task.TASK_NAME || '';
        document.getElementById('editDescription').value = task.DESCRIPTION || '';
        document.getElementById('editPriority').value = task.PRIORITY || 'medium';
        // Format date string to YYYY-MM-DD for the input[type=date]
        const datePart = task.DUE_DATE && task.DUE_DATE.length >= 10 ? task.DUE_DATE.substring(0, 10) : '';
        document.getElementById('editDueDate').value = datePart;
        document.getElementById('editIsCompleted').checked = task.IS_COMPLETED || false;

        editModal.classList.remove('opacity-0', 'pointer-events-none');
        editModal.classList.add('opacity-100');
    }

    // --- CRUD Handlers ---

    async function loadTasks() {
        taskListEl.innerHTML = '<p class="text-gray-500 mt-4 text-center">Loading tasks...</p>';

        try {
            const response = await fetch(apiEndpoint, { method: 'GET' });
            const data = await response.json();

            if (data.success && data.data.ROWCOUNT > 0) {
                renderTasks(data.data.DATA);
            } else {
                taskListEl.innerHTML = '<p class="text-gray-500 mt-4 text-center">You have no tasks assigned at this time. 🎉</p>';
            }
        } catch (error) {
            taskListEl.innerHTML = '<p class="text-red-500 mt-4 text-center">Failed to load tasks. Check API connection.</p>';
            console.error('Error loading tasks:', error);
        }
    }

    async function handleCreateTask(event) {
        event.preventDefault();
        
        const form = event.target;
        const formData = new FormData(form);

        try {
            // Note: We use a traditional POST here for simplicity with CF's form scope
            const response = await fetch(apiEndpoint, {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (data.success) {
                showStatus(data.message);
                form.reset();
                loadTasks(); // Reload the task list
            } else {
                showStatus(data.message, 'error');
            }
        } catch (error) {
            showStatus('An unexpected error occurred during task creation.', 'error');
            console.error('Create Task Error:', error);
        }
    }

    async function deleteTask(taskId) {
        if (!confirm('Are you sure you want to delete this task?')) {
            return;
        }

        try {
            const response = await fetch(`${apiEndpoint}?taskId=${taskId}`, {
                method: 'DELETE'
            });
            
            const data = await response.json();

            if (data.success) {
                showStatus(data.message);
                loadTasks(); // Reload the task list
            } else {
                showStatus(data.message, 'error');
            }
        } catch (error) {
            showStatus('An unexpected error occurred during task deletion.', 'error');
            console.error('Delete Task Error:', error);
        }
    }
    
    function initiateEdit(taskId, taskData) {
        // Find the specific task data using the taskId
        const task = {
            ID: taskId,
            TASK_NAME: taskData.TASK_NAME[0],
            DESCRIPTION: taskData.DESCRIPTION[0],
            PRIORITY: taskData.PRIORITY[0],
            DUE_DATE: taskData.DUE_DATE[0],
            IS_COMPLETED: taskData.IS_COMPLETED[0] === true || taskData.IS_COMPLETED[0] === 1,
        };
        showModal(taskId, task);
    }

    async function handleUpdateTask(event) {
        event.preventDefault();
        closeModal();
        
        const form = event.target;
        const taskId = form.taskId.value;
        
        const payload = {
            taskId: taskId,
            taskName: form.taskName.value,
            description: form.description.value,
            priority: form.priority.value,
            dueDate: form.dueDate.value,
            // Checkbox value needs explicit handling
            isCompleted: form.isCompleted.checked,
        };

        try {
            const response = await fetch(apiEndpoint, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            const data = await response.json();

            if (data.success) {
                showStatus(data.message);
                loadTasks(); // Reload the task list
            } else {
                showStatus(data.message, 'error');
            }
        } catch (error) {
            showStatus('An unexpected error occurred during task update.', 'error');
            console.error('Update Task Error:', error);
        }
    }

    // --- Rendering ---

    function renderTasks(taskData) {
        let html = '';
        if (taskData.ID && taskData.ID.length > 0) {
            for (let i = 0; i < taskData.ID.length; i++) {
                
                const taskId = taskData.ID[i];
                const taskName = taskData.TASK_NAME[i];
                const priority = taskData.PRIORITY[i];
                const dueDate = formatDate(taskData.DUE_DATE[i]);
                const isCompleted = taskData.IS_COMPLETED[i];
                
                const priorityClasses = {
                    'high': 'text-red-600',
                    'medium': 'text-yellow-600',
                    'low': 'text-green-600'
                };
                
                const cardClasses = isCompleted ? 'bg-green-50 opacity-75 line-through' : 'bg-white';

                html += `
                <div class="task-item border p-4 rounded-lg shadow-md flex justify-between items-center ${cardClasses}">
                    <div class="flex-1 min-w-0">
                        <strong class="text-lg text-gray-800">${taskName}</strong><br>
                        <span class="text-sm text-gray-600">Priority: 
                            <span class="font-semibold ${priorityClasses[priority]}">${priority}</span>
                             - Due: ${dueDate}
                        </span>
                    </div>
                    
                    <div class="space-x-2 flex items-center flex-shrink-0">
                        <button onclick='initiateEdit(${taskId}, ${JSON.stringify(taskData)})' 
                                class="px-3 py-1 bg-blue-500 text-white text-sm font-medium rounded-md hover:bg-blue-600 transition duration-150">
                            Edit
                        </button>
                        
                        <button onclick="deleteTask(${taskId})" 
                                class="px-3 py-1 bg-red-500 text-white text-sm font-medium rounded-md hover:bg-red-600 transition duration-150">
                            Delete
                        </button>
                    </div>
                </div>`;
            }
            taskListEl.innerHTML = html;
        } else {
            taskListEl.innerHTML = '<p class="text-gray-500 mt-4 text-center">You have no tasks assigned at this time. 🎉</p>';
        }
    }
    
    // --- Event Listeners and Initialization ---

    document.addEventListener('DOMContentLoaded', loadTasks);
    createTaskForm.addEventListener('submit', handleCreateTask);
    editTaskForm.addEventListener('submit', handleUpdateTask);
</script>
</body>
</html>

  --->
