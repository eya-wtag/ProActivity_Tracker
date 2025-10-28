# 🚀 ProActivity_Tracker
---
## Overview

This is a robust, server-side rendered application designed to help users track, prioritize, and manage their daily tasks and long-term goals. Built on the ColdFusion (CFML) framework, the tracker provides a clean dashboard experience with secure user authentication managed by JSON Web Tokens (JWT).

---
### ✨ Key Features

- CRUD Operations: Seamlessly create, view, edit, and delete tasks from the dashboard.

- Priority Management: Assign low, medium, or high priority to tasks.

- Due Date Tracking: Set optional due dates, defaulting to the current date if left empty.

- Server-Side Logic: Uses full server-side processing for all actions, avoiding complex AJAX logic and ensuring compatibility.

- Secure Authentication: User sessions are secured and verified using JWTs.
---

### 🛠 Technology Stack

- Backend Framework: ColdFusion (CFML)

- Database: MaiaDB (or any database configured as todolist)

- Routing: Handled by index.cfm (Controller)

- Logic Layer: Components (model/query.cfc, model/jwt.cfc)

- Security: JSON Web Tokens (JWT)
---
### ✨Start Up the Docker Containers

Once inside the project root directory, start up the Docker containers:

```bash
docker-compose up --build
```
---

### ✨Running the Project

Enter the following address in your browser:

``http://127.0.0.1:8888/``
---
### ✨ Project Demo

![ Final Project Demo ](https://docs.google.com/videos/d/1q_0p-ldIqTn_qyQbpG62zKXcHa0RC_pSJcz_pn5QB2g/edit?usp=sharing)

---
