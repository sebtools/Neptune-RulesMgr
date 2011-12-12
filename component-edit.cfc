<cfcomponent extends="_config.PageController" output="no">

<!--- Copy any component references to variables scope --->
<cfset loadExternalVars("Components",".RulesMgr")>
<cfset setInherits(variables.Components)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<!--- local variables: local for internal data, vars will be returned as variables scope on the page --->
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Component","edit")>
	
	<!--- Set default values for vars variables --->
	<cfset vars.sRules = StructNew()>
	
	<cfif vars.Action EQ "Edit">
		<cfset vars.sRules.ComponentID = URL.id>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>