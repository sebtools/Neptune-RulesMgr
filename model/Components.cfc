<cfcomponent displayname="Components" extends="com.sebtools.Records" output="no">

<cffunction name="addComponent" access="public" returntype="string" output="no" hint="I save one Component.">
	<cfargument name="ComponentName" type="string" required="yes">
	<cfargument name="ComponentPath" type="string" required="yes">
	<cfargument name="FilePath" type="string" required="yes">
	<cfargument name="DateLastUpdated" type="date" required="yes">
	
	<cfset var result = 0>
	<cfset var qFindComponent = getComponentConflicts(ArgumentCollection=Arguments)>
	<cfset var sData = 0>
	
	<!--- If more than one component exists with any combination of these criteria, then we have a problem --->
	<cfif qFindComponent.RecordCount GT 1>
		<cfthrow message="Conflicting Test Components (ComponentName=#arguments.ComponentName#,ComponentPath=#arguments.ComponentPath#,FilePath=#arguments.FilePath#)" type="RulesMgr">
	</cfif>
	
	<!--- If no components exist like this, add it --->
	<cfif NOT qFindComponent.RecordCount>
		<cfset result = saveComponent(argumentCollection=arguments)>
	</cfif>
	
	<!--- If one component exists like this, see if we need to update it --->
	<cfif qFindComponent.RecordCount EQ 1>
		<cfset qFindComponent = getComponents(fieldlist="ComponentID,DateUpdated",ComponentName=arguments.ComponentName,ComponentPath=arguments.ComponentPath,FilePath=arguments.FilePath)>
		
		<!--- Update component if either not all fields match or if file has been updated since last update --->
		<cfif qFindComponent.RecordCount EQ 0 OR arguments.DateLastUpdated GT qFindComponent.DateUpdated>
			<cfset arguments.ComponentID = qFindComponent.ComponentID>
			<cfset result = saveComponent(argumentCollection=arguments)>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getComponentConflicts" access="private" returntype="query" output="no">
	<cfargument name="ComponentName" type="string" required="yes">
	<cfargument name="ComponentPath" type="string" required="yes">
	<cfargument name="FilePath" type="string" required="yes">
	
	<cfset var qFindComponent = 0>
	<cfset var qFindComponentOldName = 0>
	
	<cfif variables.DataMgr.getDatabase() EQ "Sim">
		<cfset qFindComponent = QueryNew('ComponentID')>
	<cfelse>
		<cf_DMQuery name="qFindComponent">
		SELECT	<cf_DMSQL tablename="#variables.table#" method="getSelectSQL" fieldlist="ComponentID,DateUpdated,ComponentName,ComponentPath,FilePath">
		FROM	<cf_DMSQL tablename="#variables.table#" method="getFromSQL" fieldlist="ComponentID,ComponentName,ComponentPath,FilePath">
		WHERE	1 = 0
			OR	ComponentPath = <cf_DMParam value="#arguments.ComponentPath#" cfsqltype="CF_SQL_VARCHAR">
			OR	FilePath = <cf_DMParam value="#arguments.FilePath#" cfsqltype="CF_SQL_VARCHAR">
		</cf_DMQuery>
	</cfif>
	
	<cfif qFindComponent.RecordCount GT 1>
		<cfif NOT StructKeyExists(arguments,"retry")>
			<cfset sData = StructNew()>
			<cfset sData["NumRules"] = 0>
			<cfset sData["ComponentPath"] = arguments.ComponentPath>
			<cfset sData["FilePath"] = arguments.FilePath>
			<cfset variables.DataMgr.deleteRecords(tablename=variables.table,data=sData)>
			
			<cfset arguments.retry = 1>
			
			<cfreturn getComponentConflicts(argumentCollection=arguments)> 
		<cfelseif Arguments.retry EQ 1>
			<!--- Remove components with different names --->
			<cf_DMQuery name="qFindComponentOldName">
			SELECT	<cf_DMSQL tablename="#variables.table#" method="getSelectSQL" fieldlist="ComponentID,DateUpdated,ComponentName,ComponentPath,FilePath">
			FROM	<cf_DMSQL tablename="#variables.table#" method="getFromSQL" fieldlist="ComponentID,ComponentName,ComponentPath,FilePath">
			WHERE	1 = 1
				AND	ComponentPath = <cf_DMParam value="#arguments.ComponentPath#" cfsqltype="CF_SQL_VARCHAR">
				AND	FilePath = <cf_DMParam value="#arguments.FilePath#" cfsqltype="CF_SQL_VARCHAR">
				AND	ComponentName <> <cf_DMParam value="#arguments.ComponentName#" cfsqltype="CF_SQL_VARCHAR">
			</cf_DMQuery>
			<cfloop query="qFindComponentOldName">
				<cfset removeComponent(ComponentID)>
			</cfloop>
			
			<cfset arguments.retry = 2>
			
			<cfreturn getComponentConflicts(argumentCollection=arguments)>
		<!---<cfelse>
			<cfdump var="#Arguments#">
			<cfdump var="#qFindComponent#"><cfabort>
			<cfthrow message="Conflicting Test Components (ComponentName=#arguments.ComponentName#,ComponentPath=#arguments.ComponentPath#,FilePath=#arguments.FilePath#)" type="RulesMgr">--->
		</cfif>
	</cfif>
	
	<cfreturn qFindComponent>
</cffunction>

</cfcomponent>