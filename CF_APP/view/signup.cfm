<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Your Account - Task Manager</title>
    <link rel="stylesheet" href="view/index.css">
</head>
<body class="auth-page">
    <div class="landing-box">
        <h2>Create Your Account</h2>
        <p class="subtitle">Join us and start managing your tasks efficiently</p>
        
        <form action="index.cfm?action=signup" method="POST">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="Choose a username" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="your.email@example.com" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Create a strong password" required>
            </div>
            
            <button type="submit" class="signup-btn">Sign Up</button>
        </form>
        
        <p class="login-link">
            Already have an account? <a href="index.cfm?action=main">Log In</a>
        </p>
    </div>

    <cfoutput>
        <!--- <cfset writedump(cgi)> --->
    </cfoutput>
</body>
</html>