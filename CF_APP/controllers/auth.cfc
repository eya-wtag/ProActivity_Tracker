component displayname="AuthController" {

    property name="cgi" type="struct";
    
    variables.DSN_NAME = "todolist";

    public void function setCGI(required struct cgi) {
        variables.cgi = arguments.cgi;
    }

    public void function showLoginForm() {
        include "/view/main.cfm";
    }

    public void function showSignupForm() {
        include "/view/signup.cfm";
    }
    
    /**
     * Handle user signup with JWT
     */
    public void function signup() {
        var username = form.username;
        var email = form.email;
        var password = form.password;

        // Validate username
        if (!reFind("^[A-Za-z0-9_]{4,15}$", username)) {
            location(url="index.cfm?action=signup&error=Invalid username. Use only letters, numbers, or underscores.", addtoken=false);
            return;
        }

        // Validate email
        if (!isValid("email", email)) {
            location(url="index.cfm?action=signup&error=Please enter a valid email address.", addtoken=false);
            return;
        }

        try {
            // Check if user already exists
            var checkSql = "SELECT id FROM users WHERE username = ? OR email = ?";
            var checkParams = [username, email];
            var existingUser = queryExecute(checkSql, checkParams, {datasource: variables.DSN_NAME});

            if (existingUser.recordCount > 0) {
                location(url="index.cfm?action=signup&error=That username or email is already taken.", addtoken=false);
                return;
            }

            // Hash password
            var hashedPassword = hash(password, "SHA-256");

            // Insert new user
            var sql = "
                INSERT INTO users (username, email, password_hash, user_role, created_at)
                VALUES (?, ?, ?, 'user', NOW())
            ";
            var params = [username, email, hashedPassword];
            queryExecute(sql, params, {datasource: variables.DSN_NAME});
            
            // Get newly created user
            var newUser = queryExecute(
                "SELECT * FROM users WHERE username = ?", 
                [username], 
                {datasource: variables.DSN_NAME}
            );
            
            if (newUser.recordCount > 0) {
                // Create JWT session for auto-login
                createUserSession(newUser);
                location(url="index.cfm?action=dashboard&message=Account created successfully!", addtoken=false);
            } else {
                location(url="index.cfm?action=main&success=true", addtoken=false);
            }
            
        } catch (any e) {
            writeLog(type="error", file="auth_errors", text="Signup error: " & e.message);
            location(url="index.cfm?action=signup&error=A server error occurred. Please try again.", addtoken=false);
        }
    }
    
    /**
     * Handle user login with JWT
     */
    public void function login() {
        var username = form.username;
        var password = form.password;

        var result = this.authenticateUser(username, password);

        if (result.success) {
            // Create JWT session
            createUserSession(result.user);
            
            // Redirect based on role
            if (result.user.user_role == "admin") {
                location(url="index.cfm?action=adminDashboard", addtoken=false);
            } else {
                location(url="index.cfm?action=dashboard", addtoken=false);
            }
        } else {
            location(url="index.cfm?action=no_account", addtoken=false);
        }
    }

    /**
     * Authenticate user credentials
     */
    private struct function authenticateUser(required string username, required string password) {
        var response = {
            success = false,
            user = {}
        };

        try {
            var sql = "SELECT * FROM users WHERE username = ?";
            var userQuery = queryExecute(sql, [arguments.username], {datasource: variables.DSN_NAME});

            if (userQuery.recordCount == 1) {
                var storedHash = userQuery.password_hash[1];
                var submittedHash = hash(arguments.password, "SHA-256");

                if (storedHash == submittedHash) {
                    response.success = true;
                    response.user = userQuery;
                }
            }
        } catch (any e) {
            writeLog(type="error", file="auth_errors", text="Authentication error: " & e.message);
        }

        return response;
    }
    
    /**
     * Create user session with JWT token
     */
    private void function createUserSession(required query user) {
        // Create JWT token
        var jwtUtil = createObject("component", "model.jwtUtil");
        var payload = {
            user_id = user.id,
            username = user.username,
            email = user.email,
            user_role = user.user_role
        };
        
        var token = jwtUtil.generateToken(payload);
        
        // Rotate session for security
        sessionRotate();
        
        // Store in session
        session.user_id = user.id;
        session.user = {
            id = user.id,
            username = user.username,
            email = user.email,
            user_role = user.user_role
        };
        session.user_role = user.user_role;
        session.jwt_token = token;
        session.last_activity = now();
        
        // Store in secure HTTP-only cookie
        cfcookie(
            name="auth_token",
            value=token,
            expires=1, // 1 day
            httponly=true,
            secure=false, // Set to true in production with HTTPS
            path="/"
        );
        
        // Log successful authentication
        writeLog(
            type="information",
            file="auth_log",
            text="User logged in: #user.username# (ID: #user.id#, Role: #user.user_role#)"
        );
    }
    
    /**
     * Check if user is authenticated via JWT
     */
    public boolean function isUserAuthenticated() {
        var jwtUtil = createObject("component", "model.jwtUtil");
        
        // Check session token first
        if (structKeyExists(session, "jwt_token") && len(trim(session.jwt_token)) > 0) {
            var verification = jwtUtil.verifyToken(session.jwt_token);
            
            if (verification.valid) {
                // Update last activity
                session.last_activity = now();
                return true;
            } else {
                // Token expired or invalid, clear session
                clearUserSession();
            }
        }
        
        // Check cookie token
        if (structKeyExists(cookie, "auth_token") && len(trim(cookie.auth_token)) > 0) {
            var verification = jwtUtil.verifyToken(cookie.auth_token);
            
            if (verification.valid) {
                // Restore session from token
                restoreSessionFromToken(verification.payload);
                return true;
            } else {
                // Invalid cookie token, clear it
                cfcookie(name="auth_token", value="", expires="now", path="/");
            }
        }
        
        return false;
    }
    
    /**
     * Restore session from JWT payload
     */
    private void function restoreSessionFromToken(required struct payload) {
        sessionRotate();
        
        session.user_id = payload.user_id;
        session.user = {
            id = payload.user_id,
            username = payload.username,
            email = payload.email,
            user_role = payload.user_role
        };
        session.user_role = payload.user_role;
        session.jwt_token = cookie.auth_token;
        session.last_activity = now();
        
        writeLog(
            type="information",
            file="auth_log",
            text="Session restored from JWT: #payload.username# (ID: #payload.user_id#)"
        );
    }
    
    /**
     * Clear user session
     */
    private void function clearUserSession() {
        structDelete(session, "user_id");
        structDelete(session, "user");
        structDelete(session, "user_role");
        structDelete(session, "jwt_token");
        structDelete(session, "last_activity");
    }

    /**
     * Display user dashboard
     */
    public void function dashboard() {
        // Verify authentication
        if (!isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            return;
        }
        
        // Check role and redirect if needed
        if (session.user_role == "admin") {
            location(url="index.cfm?action=adminDashboard", addtoken=false);
            return;
        }

        include "/view/dashboard.cfm";
    }
    
    /**
     * Display admin dashboard
     */
    public void function adminDashboard() {
        // Verify authentication
        if (!isUserAuthenticated()) {
            location(url="index.cfm?action=main&error=session_expired", addtoken=false);
            return;
        }
        
        // Verify admin role
        if (session.user_role != "admin") {
            location(url="index.cfm?action=dashboard&error=access_denied", addtoken=false);
            return;
        }

        include "/view/admin_dashboard.cfm";
    }
    
    /**
     * Logout user
     */
    public void function logout() {
        // Log the logout
        if (structKeyExists(session, "user")) {
            writeLog(
                type="information",
                file="auth_log",
                text="User logged out: #session.user.username# (ID: #session.user.id#)"
            );
        }
        
        // Clear session
        sessionInvalidate();
        
        // Clear cookie
        cfcookie(
            name="auth_token",
            value="",
            expires="now",
            httponly=true,
            path="/"
        );
        
        location(url="index.cfm?action=main&message=You have logged out successfully", addtoken=false);
    }
    
    /**
     * Refresh JWT token
     */
    public struct function refreshToken() {
        var result = {success = false, token = ""};
        
        if (!isUserAuthenticated()) {
            result.error = "User not authenticated";
            return result;
        }
        
        try {
            var jwtUtil = createObject("component", "model.jwtUtil");
            var payload = {
                user_id = session.user.id,
                username = session.user.username,
                email = session.user.email,
                user_role = session.user.user_role
            };
            
            var newToken = jwtUtil.generateToken(payload);
            
            // Update session and cookie
            session.jwt_token = newToken;
            cfcookie(
                name="auth_token",
                value=newToken,
                expires=1,
                httponly=true,
                secure=false,
                path="/"
            );
            
            result.success = true;
            result.token = newToken;
            
        } catch (any e) {
            result.error = e.message;
            writeLog(type="error", file="auth_errors", text="Token refresh error: " & e.message);
        }
        
        return result;
    }

}