<cfcomponent output="false">

<cffunction name="components" access="public" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result">
	<program name="Rules">
		<components>
			<component name="RulesMgr" path="[path_component]model.RulesMgr">
				<argument name="Manager" />
				<argument name="RootPath" />
			</component> 
		</components>
	</program>
	</cfsavecontent>
	
	<cfreturn result>
</cffunction>

<cffunction name="links" access="public" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result"><?xml version="1.0"?>
	<program>
		<link label="Components" url="component-list.cfm" />
		<link label="Executions" url="execution-list.cfm" />
		<link label="Rules" url="rule-list.cfm" />
	</program>
	</cfsavecontent>
	
	<cfreturn result>
</cffunction>

</cfcomponent>