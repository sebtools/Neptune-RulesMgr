<cfcomponent extends="_config.PageController" output="no">

<!--- Copy any component references to variables scope --->
<cfset loadExternalVars("Executions,Rules",".RulesMgr")>
<cfset setInherits(variables.Executions)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Executions","list")>
	
	<!--- Param URL variables --->
	<cfset default("URL.rule","numeric",0)>
	
	<!--- Set default values for vars variables --->
	<cfset vars.sExecutions = StructNew()>
	<cfset vars.qRule = 0>
	<cfset vars.Title = "Tests">
	<cfset vars.showForm = false>
	
	<cfif URL.rule GT 0>
		<cfset vars.qRule = variables.Rules.getRule(RuleID=URL.rule,fieldlist="RuleID,RuleName")>
		<cfif vars.qRule.RecordCount>
			<cfset vars.Title = "#vars.Title# for ""#vars.qRule.RuleName#""">
			<cfset vars.sExecutions["RuleID"] = URL.rule>
			<cfset vars.showForm = true>
			<cfset vars.sRuleArgs = StructNew()>
			<cfset vars.sRuleArgs["RuleID"] = URL.rule>
		</cfif>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>