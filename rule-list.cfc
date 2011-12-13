<cfcomponent extends="_config.PageController" output="no">

<!--- Copy any component references to variables scope --->
<cfset loadExternalVars("Rules,Components",".RulesMgr")>
<cfset setInherits(variables.Rules)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Rules","list")>
	
	<!--- Param URL variables --->
	<cfset default("URL.component","numeric",0)>
	
	<!--- Set default values for vars variables --->
	<cfset vars.sRules = StructNew()>
	<cfset vars.qComponents = variables.Components.getComponents()>
	<cfset vars.qComponent = 0>
	<cfset vars.Title = "Business Rules">
	
	<cfif URL.component GT 0>
		<cfset vars.qComponent = variables.Components.getComponent(URL.component)>
		<cfif vars.qComponent.RecordCount>
			<cfset vars.Title = "#vars.Title# for ""#vars.qComponent.ComponentName#""">
			<cfset vars.sRules["ComponentID"] = URL.component>
		</cfif>
	</cfif>
	
	<cfset vars.qRules = Variables.Rules.getRules(ArgumentCollection=vars.sRules)>
	<cfset vars.qStatuses = getStatuses(vars.qRules)>
	<cfset vars.PercentPassed = getPercentPassed(vars.qStatuses)>
	
	<cfset vars.SebTableAttributes.isAddable = false>
	<cfset vars.SebTableAttributes.isEditable = false>
	<cfset vars.SebTableAttributes.CFC_GetArgs = vars.sRules>
	<cfset vars.SebTableAttributes.query = "qRules">
	<cfset vars.SebTableAttributes.editpage = "rule-edit.cfm?&component=#URL.component#">
	
	<cfreturn vars>
</cffunction>

<cffunction name="getPercentPassed" access="public" returntype="numeric" output="no">
	<cfargument name="qStatuses" type="query" required="yes">
	
	<cfset var result = 0>
	<cfset var sValues = StructNew()>
	<cfset var total = 0>
	
	<cfif Arguments.qStatuses.RecordCount AND ListFindNoCase(ValueList(qStatuses.status),"Passed")>
		<cfoutput query="qStatuses">
			<cfset sValues[status] = NumRules>
			<cfset total = total + NumRules>
		</cfoutput>
		<cfif total>
			<cfset result = Round((Val(sValues["Passed"]) / total) * 100)>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getStatuses" access="public" returntype="query" output="no">
	<cfargument name="qRules" type="query" required="yes">
	
	<cfset var qStatuses = 0>
	<cfset var statcolor = "">
	
	<cfquery name="qStatuses" dbtype="query">
	SELECT		status, count(RuleID) AS NumRules, '' AS color
	FROM		qRules
	GROUP BY	status, color
	ORDER BY	NumRules DESC
	</cfquery>
	
	<cfoutput query="qStatuses">
		<cfif status EQ "">
			<cfset QuerySetCell(qStatuses,"status","Untested",CurrentRow)>
		</cfif>
		<cfswitch expression="#status#">
		<cfcase value="Passed">
			<cfset statcolor = "green">
		</cfcase>
		<cfcase value="Failed">
			<cfset statcolor = "##FF9900">
		</cfcase>
		<cfcase value="Error">
			<cfset statcolor = "Red">
		</cfcase>
		<cfdefaultcase>
			<cfset statcolor = "gray">
		</cfdefaultcase>
		</cfswitch>
		<cfset QuerySetCell(qStatuses,"color",statcolor,CurrentRow)>
	</cfoutput>
	
	<cfreturn qStatuses>
</cffunction>
</cfcomponent>