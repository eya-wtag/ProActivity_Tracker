<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Your Account</title>
    <style>
        /* Add your CSS here or link to an external stylesheet in /assets/ */
        body { font-family: sans-serif; display: grid; place-content: center; height: 100vh; margin: 0; background-color: #f4f4f9; }
        .container { background: #fff; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 350px; }
        h2 { text-align: center; color: #333; }
        .form-group { margin-bottom: 1rem; }
        label { display: block; margin-bottom: 0.5rem; color: #555; }
        input { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 0.75rem; border: none; border-radius: 4px; background-color: #007bff; color: white; font-size: 1rem; cursor: pointer; }
        button:hover { background-color: #0056b3; }
        .error { color: #d93025; text-align: center; margin-top: 1rem; }
    </style>
</head>
<body>
   <div class="container">
    <h2>Create Your Account</h2>
    <form action="index.cfm?action=signup" method="POST">
        <div class="form-group">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" required>

            
        </div>
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required>
        </div>
        <button type="submit" class="signup-btn">Sign Up</button>
    </form>
    <p>Already have an account? <a href="index.cfm?action=main">Log In</a></p>
</div>


</body>
<cfoutput>


<!---  <cfset writedump(cgi)> --->

</cfoutput>
</html>
