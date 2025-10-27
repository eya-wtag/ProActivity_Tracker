component {

    this.name = "My Awesome App ToDoList";
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0); // 2 hours
    this.setClientCookies = true;
    this.sessionCookie.httpOnly = true;
    this.sessionCookie.secure = false; // Set to true in production with HTTPS
    
    // Datasource configuration
    this.datasources["todolist"] = {
        class: "com.mysql.cj.jdbc.Driver", 
        bundleName: "com.mysql.cj", 
        bundleVersion: "9.3.0",
        connectionString: "jdbc:mysql://host.docker.internal:3306/TodoList?characterEncoding=UTF-8&serverTimezone=Etc/UTC&maxReconnects=3",
        username: "yasi",
        password: "encrypted:eb19967fea8cd005ee1ba7ae1ae1dcea8af85eb5f0bf37a177d9f43a999d26f6",
        
        connectionLimit: -1,
        liveTimeout: 15,
        alwaysSetTimeout: true,
        validate: false
    };
    
    // REST settings
    this.restsettings = {
        mapping = "/api",     
        path = expandPath("/var/www/api") 
    };
    
    /**
     * Application startup
     */
    public boolean function onApplicationStart() {
        application.startTime = now();
        application.name = this.name;
        
        writeLog(
            type="information",
            file="application",
            text="Application started: #this.name#"
        );
        
        return true;
    }
    
    /**
     * Session initialization
     */
    public void function onSessionStart() {
        session.sessionStarted = now();
        
        writeLog(
            type="information",
            file="session",
            text="New session started: #session.sessionId#"
        );
    }
    
    /**
     * Request start - JWT authentication check
     */
    public boolean function onRequestStart(string targetPage) {
        // Allow application reload with URL parameter
        if (structKeyExists(url, "reload") && url.reload == "true") {
            onApplicationStart();
        }
        
        // Define public pages that don't require authentication
        var publicActions = [
            "main",
            "login", 
            "signup",
            "showLoginForm",
            "showSignupForm",
            "no_account"
        ];
        
        // Get current action
        var currentAction = structKeyExists(url, "action") ? url.action : "main";
        
        // Check if current action requires authentication
        var requiresAuth = true;
        for (var action in publicActions) {
            if (currentAction == action) {
                requiresAuth = false;
                break;
            }
        }
        
        // If authentication required, verify JWT token
        if (requiresAuth) {
            var authController = createObject("component", "controllers.auth");
            
            if (!authController.isUserAuthenticated()) {
                // User not authenticated, redirect to login
                location(
                    url="index.cfm?action=main&error=session_expired", 
                    addtoken=false
                );
                return false;
            }
            
            // Check for session timeout (additional security layer)
            if (structKeyExists(session, "last_activity")) {
                var minutesSinceActivity = dateDiff("n", session.last_activity, now());
                
                // If inactive for more than 30 minutes, force re-authentication
                if (minutesSinceActivity > 30) {
                    writeLog(
                        type="information",
                        file="session",
                        text="Session timeout for user: #session.user.username#"
                    );
                    
                    sessionInvalidate();
                    cfcookie(name="auth_token", value="", expires="now", path="/");
                    
                    location(
                        url="index.cfm?action=main&error=session_timeout", 
                        addtoken=false
                    );
                    return false;
                }
            }
            
            // Update last activity timestamp
            session.last_activity = now();
        }
        
        return true;
    }
    
    /**
     * Request processing
     */
    public void function onRequest(string targetPage) {
        include "/index.cfm";
    }
    
    /**
     * Session end
     */
    public void function onSessionEnd(struct sessionScope, struct applicationScope) {
        if (structKeyExists(arguments.sessionScope, "user")) {
            writeLog(
                type="information",
                file="session",
                text="Session ended for user: #arguments.sessionScope.user.username#"
            );
        }
    }
    
    /**
     * Application end
     */
    public void function onApplicationEnd(struct applicationScope) {
        writeLog(
            type="information",
            file="application",
            text="Application ended: #arguments.applicationScope.name#"
        );
    }
    
    /**
     * Error handling
     */
    public void function onError(any exception, string eventName) {
        writeLog(
            type="error",
            file="application_errors",
            text="Error in #arguments.eventName#: #arguments.exception.message# | Detail: #arguments.exception.detail#"
        );
        
        // In production, show friendly error page
        // In development, you might want to see the full error
        if (structKeyExists(arguments.exception, "rootCause")) {
            writeLog(
                type="error",
                file="application_errors",
                text="Root cause: #arguments.exception.rootCause.message#"
            );
        }
        
        // Redirect to error page or show generic error
        location(url="index.cfm?action=main&error=server_error", addtoken=false);
    }
    
}