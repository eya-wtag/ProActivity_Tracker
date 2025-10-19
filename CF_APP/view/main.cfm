<html>
<head>
    <title>Welcome - WorkList App</title>
    <style>
        body { font-family: sans-serif; background-color: #f4f4f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .landing-box { 
            background: #fff; 
            padding: 40px; 
            border-radius: 12px; 
            box-shadow: 0 10px 20px rgba(0,0,0,0.15); 
            width: 100%; 
            max-width: 400px; 
            text-align: center; 
        }
        h1 { 
            color: #0056b3; 
            margin-bottom: 30px; 
            font-size: 2em; 
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
        }
        .option-button {
            display: block;
            width: 100%; /* Keeps the width consistent */
            height: 50px; /* Example: set a fixed height */
            padding: 15px;
            margin-top: 15px;
            border: none;
            border-radius: 8px;
            font-size: 1.1em;
            text-decoration: none;
            font-weight: bold;
            box-sizing: border-box; /* This is crucial! It ensures padding and border are included in the element's total width and height. */
            transition: background-color 0.2s, box-shadow 0.2s;
}
        .login-btn {
            background-color: #28a745;
            color: white;
        }
        .login-btn:hover {
            background-color: #1e8745;
        }
        .signup-btn {
            background-color: #1e80eaf2;
            color: white;
        }
        .signup-btn:hover {
            background-color: #0056b3;
        }
        .message { margin-top: 20px; color: green; font-weight: bold; }
        .message-error { margin-top: 20px; color: red; font-weight: bold; }
    </style>
</head>
<body>

    <div class="landing-box">
        <h1>Welcome to your Daily ProActivity</h1>
 
        <cfif structKeyExists(URL, "message")>
            <p class="message"><cfoutput>#URL.message#</cfoutput></p>
        <cfelseif structKeyExists(URL, "error")>
            <p class="message-error">Login Failed. Please try again.</p>
        </cfif>

        <p>Please provide your username and password:</p>

    
        <form method="post" action="index.cfm?action=login">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit" class="option-button login-btn">Log In</button>
        </form>


        <a href="index.cfm?action=signup" class="option-button signup-btn">Sign Up</a>
        
    </div>

</body>
</html>
