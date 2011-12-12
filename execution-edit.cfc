<cfcomponent extends="_config.PageController" output="no">

<!--- Copy any component references to variables scope --->
<cfset loadExternalVars("Executions",".RulesMgr")>
<cfset setInherits(variables.Executions)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Execution","edit")>
	
	<cfset default("URL.rule","numeric",0)>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>