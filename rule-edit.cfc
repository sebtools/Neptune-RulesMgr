<cfcomponent extends="_config.PageController" output="no">

<!--- Copy any component references to variables scope --->
<cfset loadExternalVars("Rules",".RulesMgr")>
<cfset setInherits(variables.Rules)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Rule","edit")>
	
	<!--- Param URL variables --->
	<cfset param("URL.component","numeric",0)>
	
	<!--- Set default values for vars variables --->
	<cfset vars.sExecutions = StructNew()>
	
	<cfif vars.Action EQ "Edit">
		<cfset vars.sExecutions.RuleID = URL.id>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>