
<cfoutput>
    <h2>Hello, #ucase(session.user.username)# !</h2>
    <h3>Welcome to the Dashboard! </h3>
</cfoutput>

<form action="index.cfm?action=logout" method="post">
    <button type="submit">Logout</button>
</form>