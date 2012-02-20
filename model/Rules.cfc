<cfcomponent displayname="Rules" extends="com.sebtools.Records" output="no">

<cffunction name="addRule" access="public" returntype="string" output="no" hint="I save one Component.">
	<cfargument name="ComponentID" type="numeric" required="yes">
	<cfargument name="RuleName" type="string" required="yes">
	<cfargument name="Method" type="string" required="yes">
	
	<cfset var result = 0>
	<cfset var qFindRule = 0>
	
	<cfif NOT Len(variables.datasource)>
		<cfreturn 0>
	</cfif>
	
	<cfquery name="qFindRule" datasource="#variables.datasource#">
	SELECT	RuleID
	FROM	#variables.table#
	WHERE	ComponentID = <cfqueryparam value="#arguments.ComponentID#" cfsqltype="CF_SQL_INTEGER">
		AND	WhenDeleted IS NULL
		AND	(
					1 = 0
				OR	RuleName = <cfqueryparam value="#arguments.RuleName#" cfsqltype="CF_SQL_VARCHAR">
				OR	Method = <cfqueryparam value="#arguments.Method#" cfsqltype="CF_SQL_VARCHAR">
			)
	</cfquery>
	
	<!--- If more than one test exists with any combination of these criteria, then we have a problem --->
	<cfif qFindRule.RecordCount GT 1>
		<cfquery name="qFindRule" datasource="#variables.datasource#">
		DELETE
		FROM	#variables.table#
		WHERE	ComponentID = <cfqueryparam value="#arguments.ComponentID#" cfsqltype="CF_SQL_INTEGER">
			AND	WhenDeleted IS NULL
			AND	(
						1 = 0
					OR	RuleName = <cfqueryparam value="#arguments.RuleName#" cfsqltype="CF_SQL_VARCHAR">
					OR	Method = <cfqueryparam value="#arguments.Method#" cfsqltype="CF_SQL_VARCHAR">
				)
		</cfquery>
		<cfreturn addRule(argumentCollection=arguments)>
		<!---<cfthrow message="Conflicting Tests." detail="Rule=#arguments.RuleName#, Method=#arguments.Method#" type="RulesMgr">--->
	</cfif>
	
	<!--- If no components exist like this, add it --->
	<cfif NOT qFindRule.RecordCount>
		<cftry>
			<cfset arguments.truncate = true>
			<cfset result = saveRule(argumentCollection=arguments)>
		<cfcatch>
			<cfdump var="#arguments#">
			<cfabort>
		</cfcatch>
		</cftry>
	</cfif>
	
	<!--- If one component exists like this, see if we need to update it --->
	<cfif qFindRule.RecordCount EQ 1>
		<cfquery name="qFindRule" datasource="#variables.datasource#">
		SELECT	RuleID
		FROM	#variables.table#
		WHERE	1 = 1
			AND	WhenDeleted IS NULL
			AND	ComponentID = <cfqueryparam value="#arguments.ComponentID#" cfsqltype="CF_SQL_INTEGER">
			AND	RuleName = <cfqueryparam value="#arguments.RuleName#" cfsqltype="CF_SQL_VARCHAR">
			AND	Method = <cfqueryparam value="#arguments.Method#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Update rule if not all fields match --->
		<cfif qFindRule.RecordCount EQ 0>
			<cfset arguments.RuleID = qFindRule.RuleID>
			<cfset arguments.truncate = true>
			<cfset result = saveRule(argumentCollection=arguments)>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="testRule" access="public" returntype="any" output="no" hint="I save one Rule.">
	<cfargument name="RuleID" type="string" required="yes">
	
	<cfreturn variables.RulesMgr.testRule(argumentCollection=arguments)>
</cffunction>

</cfcomponent>