<cfcomponent displayname="Executions" extends="com.sebtools.Records" output="no">

<cffunction name="saveExecution" access="public" returntype="string" output="no" hint="I save one Execution.">
	
	<cfif StructKeyExists(arguments,"Data")>
		<cfif NOT StructKeyExists(arguments,"wData")>
			<cftry>
				<cfwddx action="CFML2WDDX" input="#arguments.Data#" output="arguments.wData">
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT StructKeyExists(arguments,"dData")>
			<cfsavecontent variable="arguments.dData"><cfdump var="#arguments.Data#"></cfsavecontent>
		</cfif>
	</cfif>
	
	<cfreturn variables.DataMgr.insertRecord(tablename=variables.table,data=arguments,truncate=true)>
</cffunction>

</cfcomponent>