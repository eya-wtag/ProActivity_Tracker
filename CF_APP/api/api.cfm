<cfoutput>
    hello bangladesh
</cfoutput>
<cfcomponent rest="true"  >

    <cffunction name="getItems" access="remote" returntype="any" httpmethod="GET" >
        <cfset items = {
            item1 = {name="Laptop", price=1000},
            item2 = {name="Mouse", price=25.5},
            item3 = {name="Keyboard", price=75}
        }>
        <cfreturn serializeJSON(items)>
    </cffunction>

</cfcomponent>
