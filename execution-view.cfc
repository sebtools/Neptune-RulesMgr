<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("Executions,Rules",".RulesMgr")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = StructNew()>
	
	<!--- Param URL variables --->
	<cfset require("URL.id","numeric","index.cfm")>
	
	<!--- Set default values for vars variables --->
	<cfset vars.Title = "Test Details">
	<cfset vars.qExecution = Variables.Executions.getExecution(URL.id)>	
	
	<cfset vars.sRuleArgs = StructNew()>
	<cfset vars.sRuleArgs["RuleID"] = vars.qExecution.RuleID>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>