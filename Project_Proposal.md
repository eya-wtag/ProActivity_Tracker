# Project Proposal: Daily ProActivity Tracker
---
## Project Description
The Daily Productivity Tracker is a web-based application designed to help users manage their daily tasks efficiently. Users can create, update, and delete tasks while keeping track of their progress. The project leverages ColdFusion (Lucee) for server-side logic, MariaDB for database management, and modern tools like Docker and DBGate for development and deployment. This application aims to improve personal productivity by providing a simple, user-friendly interface for task management.
---
## Functionality
### User Authentication:


- Signup: Users can create a new account by providing a username, email, and password. Passwords are securely stored in the database.


- Login: Registered users can log in using their credentials to access their personal task list.


### Session Management: Keeps users logged in across pages while maintaining security.


### Task Management (CRUD Operations):


- Create Tasks: Users can add new tasks with a title, description, due date, and priority level.


- Read/View Tasks: Users can view all their tasks in a structured daily overview or filter by status (e.g., pending, completed).


- Update Tasks: Users can edit task details or mark tasks as completed.


- Delete Tasks: Users can remove tasks that are no longer needed.


###  Daily Overview & Organization:


- Tasks are displayed in a clear, easy-to-read list grouped by date or priority.


- Users can quickly see pending and completed tasks at a glance.


###  Search and Filter:


- Users can search tasks by keywords.


- Filter options allow users to sort tasks by date, status, or priority for efficient management.


### Persistent Storage:


- All user data, tasks, and authentication information are stored securely in a MariaDB database, ensuring data is preserved between sessions. This platform will consider mounting volumes to persist storage in case of application/docker restart.


### User friendly Design:


- The application works seamlessly on the desktop allowing users to manage tasks. Users will be able to easily understand and use this platform to do their work in time.

---

## Concepts Used
- User Authentication & Security – User authentication is managed using JWT (JSON Web Tokens), which validates users both through sessions and API requests. The JWT implementation is designed with CSRF protection in mind to prevent cross-site request forgery attacks, ensuring secure and reliable authentication throughout the application.

- ColdFusion Components (CFCs) – Organize code into reusable, modular components for maintainability.


- Object-Oriented Programming (OOP) – Apply principles like encapsulation, properties, methods, inheritance, and interfaces to structure code efficiently.


- CRUD Operations with MariaDB – Create, read, update, and delete tasks, with secure database interactions.


- User Authentication & Session Management – Implement login/signup functionality and maintain secure user sessions.


- Form Handling and URL Parameters – Capture, validate, and process user input securely from forms and URLs. Form input sanitization will be done through a Java library like JSoup.


- Docker – Containerize the application for consistent development, testing, and deployment environments.

- Routing – Manage request flow efficiently using a structured routing system with remote functions. Follow the MVC pattern to separate models, controllers, and views, ensuring maintainable, scalable, and predictable navigation throughout the app.


- Responsive Web Design – Ensure the application is accessible and user-friendly on desktops and mobile devices.


- Error Handling & Validation – Implement proper checks and exception handling to prevent invalid data and application crashes. Use a simple logging system that writes to specific files for different functionalities—for example, auth.log for authentication, tasks.log for task-related actions, and user.log for user activity—organizing logs in separate folders or files for clarity and maintainability.


