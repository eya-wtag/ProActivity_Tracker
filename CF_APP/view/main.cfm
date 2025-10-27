<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - Task Manager</title>
    <link rel="stylesheet" href="view/index.css">
</head>
<body class="auth-page">
    <div class="landing-box">
        <div class="welcome-icon">📋</div>
        <h1>Welcome to Task Manager</h1>
        <p class="subtitle">Stay organized and boost your productivity</p>

        <cfif structKeyExists(URL, "message")>
            <p class="message"><cfoutput>#URL.message#</cfoutput></p>
        <cfelseif structKeyExists(URL, "error")>
            <p class="message-error">Login Failed. Please try again.</p>
        </cfif>

        <div class="form-container">
            <form method="post" action="index.cfm?action=login">
                <input type="text" name="username" placeholder="Username" required>
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit" class="option-button login-btn">Log In</button>
            </form>
        </div>

        <div class="divider">
            <span>OR</span>
        </div>
        <p class="login-link">
            Don't have an account? 
            <a href="index.cfm?action=signup">Sign Up</a>
        </p>

    </div>
</body>
</html>