<cfcomponent output="false">

<cffunction name="components" access="public" returntype="string" output="yes">
<program name="Rules">
	<components>
		<component name="RulesMgr" path="[path_component]model.RulesMgr">
			<argument name="Manager" />
			<argument name="RootPath" />
		</component> 
	</components>
</program>
</cffunction>

<cffunction name="links" access="public" returntype="string" output="yes">
</cffunction>

</cfcomponent>