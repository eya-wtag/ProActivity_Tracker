<cfscript>
component displayname="AuthController" {

    property name="cgi" type="struct";

    public void function setCGI(required struct cgi) {
        variables.cgi = arguments.cgi;
    }

    public void function showLoginForm() {
        include "/views/main.cfm";
    }

    public void function showSignupForm() {
        include "/view/signup.cfm";
    }
    public void function signup() {

    var username = form.username;
    var email    = form.email;
    var password = form.password; 


        if (!reFind("^[A-Za-z0-9_]{4,15}$", username)) {
    
            location(url="index.cfm?action=signup&error=Invalid username. Use only letters, numbers, or underscores.");
            return;
        }


        if (!isValid("email", email)) {
            location(url="index.cfm?action=signup&error=Please enter a valid email address.");
            return;
        }

        try {
        
            var checkSql = "SELECT id FROM users WHERE username = ? OR email = ?";
            var checkParams = [username, email];
            var existingUser = queryExecute(checkSql, checkParams, {datasource: "todolist"});

            if (existingUser.recordCount > 0) {
                location(url="index.cfm?action=signup&error=That username or email is already taken.");
                return;
            }

            var hashedPassword = hash(password, "SHA-256");

            var sql = "
                INSERT INTO users (username, email, password_hash)
                VALUES (?, ?, ?)
            ";
            var params = [username, email, hashedPassword];
            
            queryExecute(sql, params, {datasource: "todolist"});
            
            location(url="index.cfm?action=main&success=true");
            
        } catch (any e) {
            location(url="index.cfm?action=signup&error=A server error occurred. Please try again.");
        }
    }
    
  
  public void function login() {
    
        var username = form.username;
        var password = form.password;

        var result = this.authenticateUser(username, password);

        if (result.success) {

            sessionRotate();
            session.user = result.user;
            session.user_id = result.user.id;

            location(url="index.cfm?action=dashboard");

        } else {
            location(url="index.cfm?action=no_account");
        }
    }

    private struct function authenticateUser(required string username, required string password) {
        
        var response = {
            success = false,
            user = {}
        };

        var sql = "SELECT * FROM users WHERE username = ?";
        var userQuery = queryExecute(sql, [arguments.username], {datasource: "todolist"});

        if (userQuery.recordCount == 1) {
            var storedHash = userQuery.password_hash[1];
            var submittedHash = hash(arguments.password, "SHA-256");

            if (storedHash == submittedHash) {
                response.success = true;
                response.user = userQuery;
            }
        }

        return response;
    }

    public void function dashboard() {
       
        if (!session.keyExists("user")) {
            location(url="index.cfm?action=auth.showLoginForm");
        }
        include "/views/user/dashboard.cfm";
    }


    // public void function createTask(
    //     required string taskName,
    //     string description = '',
    //     string priority = 'medium',
    //     date dueDate
    // ) {
    //     var taskModel = new models.TaskModel();

    //     // The 'arguments' scope is automatically available in script-based functions
    //     arguments.userId = session.user_id;

    //     taskModel.createTask(argumentCollection = arguments);

    //     location(url="index.cfm?action=dashboard", addtoken="false");
    // }
    
    // public void function deleteTask(required numeric taskId) {
    //     var taskModel = new models.TaskModel();

    //     taskModel.deleteTask(arguments.taskId);

    //     location(url="index.cfm?action=dashboard", addtoken="false");
    // }
    
    // </cfcomponent>


}
</cfscript>