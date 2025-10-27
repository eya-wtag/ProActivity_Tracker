<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Failed - Task Manager</title>
    <link rel="stylesheet" href="view/index.css">
</head>
<body class="auth-page">
    <div class="error-container">
        <div class="error-icon">🔒</div>
        
        <cfoutput>
            <h2>Wrong Username or Password!</h2>
            <h4>Please try again!</h4>
        </cfoutput>

        <div class="error-message">
            <strong>Authentication Failed</strong><br>
            The username or password you entered is incorrect. Please check your credentials and try again.
        </div>

        <form action="index.cfm?action=main" method="post">
            <button type="submit">Back to Login Page</button>
        </form>

        <div class="helper-text">
            <strong>Tip:</strong> Make sure your Caps Lock is off and check for any typing errors.
        </div>
    </div>
</body>
</html>