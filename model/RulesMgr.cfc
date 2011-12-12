<cfcomponent extends="com.sebtools.ProgramManager" output="no">

<cfset variables.prefix = "test">

<cffunction name="init" access="public" returntype="any" output="no" hint="I initialize and return this object.">
	<cfargument name="Manager" type="any" required="yes">
	<cfargument name="RootPath" type="string" required="yes">
	
	<cfset initInternal(argumentCollection=arguments)>
	
	<cfset reload()>
	
	<cfreturn This>
</cffunction>

<cffunction name="getCompPath" access="public" returntype="string" output="false">
	<cfargument name="CompFilePath" type="string" required="true">
	
	<cfset var result = ReplaceNoCase(arguments.CompFilePath,variables.RootPath,"")>
	
	<cfset result = reverse(ListRest(reverse(result),"."))>
	<cfset result = ListChangeDelims(result,".","/")>
	<cfset result = ListChangeDelims(result,".","\")>
	
	<cfreturn result>
</cffunction>

<cffunction name="getTestComponents" access="public" returntype="query" output="false">
	
	<cfset var qFiles = variables.FileMgr.directoryList(directory=variables.RootPath,filter="Test*.cfc",recurse=true)>
	<cfset var qUIFiles = variables.FileMgr.directoryList(directory=variables.RootPath,filter="UITest*.cfc",recurse=true)>
	<cfset var qResults = QueryNew("Name,Directory,DateLastModified,Size,Mode,Attributes,FilePath,CompPath,DisplayName")>
	<cfset var sTestComp = 0>
	<cfset var path = "">
	
	<cfoutput query="qFiles">
		<cfset path = getCompPath(Directory & Name)>
		
		<cfset sTestComp = GetMetaData(CreateObject("component",path))>
		
		<cfif StructKeyExists(sTestComp,"DisplayName")>
			<cfset QueryAddRow(qResults)>
			<cfset QuerySetCell(qResults,"Name",Name)>
			<cfset QuerySetCell(qResults,"Directory",Directory)>
			<cfset QuerySetCell(qResults,"DateLastModified",DateLastModified)>
			<cfset QuerySetCell(qResults,"Size",Size)>
			<cfset QuerySetCell(qResults,"Mode",Mode)>
			<cfset QuerySetCell(qResults,"Attributes",Attributes)>
			<cfset QuerySetCell(qResults,"FilePath",Directory & Name)>
			<cfset QuerySetCell(qResults,"CompPath",path)>
			<cfset QuerySetCell(qResults,"DisplayName",sTestComp.DisplayName)>
		</cfif>
	</cfoutput>
	
	<cfoutput query="qUIFiles">
		<cfset path = getCompPath(Directory & Name)>
		<cfset sTestComp = GetMetaData(CreateObject("component",path))>
		
		<cfif StructKeyExists(sTestComp,"DisplayName")>
			<cfset QueryAddRow(qResults)>
			<cfset QuerySetCell(qResults,"Name",Name)>
			<cfset QuerySetCell(qResults,"Directory",Directory)>
			<cfset QuerySetCell(qResults,"DateLastModified",DateLastModified)>
			<cfset QuerySetCell(qResults,"Size",Size)>
			<cfset QuerySetCell(qResults,"Mode",Mode)>
			<cfset QuerySetCell(qResults,"Attributes",Attributes)>
			<cfset QuerySetCell(qResults,"FilePath",Directory & Name)>
			<cfset QuerySetCell(qResults,"CompPath",path)>
			<cfset QuerySetCell(qResults,"DisplayName",sTestComp.DisplayName)>
		</cfif>
	</cfoutput>
	
	<cfreturn qResults>
</cffunction>

<cffunction name="reload" access="public" returntype="void" output="false" hint="">
	
	<cfset reloadTestComponents()>
	
</cffunction>

<cffunction name="testRule" access="public" returntype="any" output="no" hint="I test one Rule.">
	<cfargument name="RuleID" type="string" required="yes">
	
	<cfset var qRule = variables.Rules.getRule(arguments.RuleID)>
	<cfset var qComponent = variables.Components.getComponent(qRule.ComponentID)>
	<cfset var oComponent = CreateObject("component",qComponent.ComponentPath)>
	<cfset var oTestSuite = CreateObject("component","mxunit.framework.TestSuite").TestSuite()>
	<cfset var oResults = 0>
	<cfset var aResults = 0>
	
	<cfset oTestSuite.add(qComponent.ComponentPath,qRule.Method,oComponent)>
	<cfset oResults = oTestSuite.run()>
	<cfset aResults = oResults.getResults()>
	
	<cfinvoke component="#variables.Executions#" method="saveExecution">
		<cfinvokeargument name="RuleID" value="#arguments.RuleID#">
		<cfinvokeargument name="Status" value="#aResults[1].TestStatus#">
		<cfinvokeargument name="RunTime" value="#aResults[1].Time#">
		<cfif StructKeyExists(aResults[1],"Error") AND NOT isSimpleValue(aResults[1].Error) AND StructKeyExists(aResults[1].Error,"Message")>
			<cfinvokeargument name="Message" value="#aResults[1].Error.Message#">
		</cfif>
		<cfinvokeargument name="Data" value="#aResults[1]#">
	</cfinvoke>
	
</cffunction>

<cffunction name="testRules" access="public" returntype="void" output="no" hint="I test one Rule.">
	
	<cfset var qRules = variables.Rules.getRules(argumentCollection=arguments)>
	
	<cfloop query="qRules">
		<cfset testRule(RuleID)>
	</cfloop>
	
</cffunction>

<cffunction name="getCompTestMethods" access="private" returntype="array" output="false">
	<cfargument name="CompFilePath" type="string" required="true">
	
	<cfset var pathto = getCompPath(arguments.CompFilePath)>
	<cfset var oTestComp = CreateObject("component",pathto)>
	<cfset var sTestMeta = getMetaData(oTestComp)>
	<cfset var aMethods = sTestMeta.Functions>
	<cfset var ii = 0>
	<cfset var aResults = ArrayNew(1)>
	
	<cfloop index="ii" from="1" to="#ArrayLen(aMethods)#" step="1">
		<cfif isTestMethod(aMethods[ii])>
			<cfset ArrayAppend(aResults,aMethods[ii])>
		</cfif>
	</cfloop>
	
	<cfreturn aResults>
</cffunction>

<cffunction name="getCompTests" access="private" returntype="query" output="false">
	<cfargument name="CompFilePath" type="string" required="true">
	
	<cfset var aTestMethods = getTestMethods(arguments.CompFilePath)>
	<cfset var ii = 0>
	<cfset var qResults = QueryNew("method,rule")>
	
	<cfloop index="ii" from="1" to="#ArrayLen(aTestMethods)#" step="1">
		<cfset QueryAddRow(qResults)>
		<cfset QuerySetCell(qResults,"method",aTestMethods[ii].name)>
		<cfset QuerySetCell(qResults,"rule",aTestMethods[ii].hint)>
	</cfloop>
	
	<cfreturn qResults>
</cffunction>

<cffunction name="getTestMethods" access="private" returntype="array" output="false">
	<cfargument name="CompFilePath" type="string" required="false">
	
	<cfset var qTestComponents = 0>
	<cfset var aTestMethods = 0>
	<cfset var ii = 0>
	<cfset var aResults = ArrayNew(1)>
	<cfset var oTestComponent = 0>
	<cfset var sTestComponent = 0>
	
	<cfif StructKeyExists(arguments,"CompFilePath")>
		<cfreturn getCompTestMethods(arguments.CompFilePath)>
	</cfif>
	
	<cfset qTestComponents = getTestComponents()>
	<cfoutput query="qTestComponents">
		<cfset aTestMethods = getCompTestMethods(directory & name)>
		<cfif ArrayLen(aTestMethods)>
			<cfset oTestComponent = CreateObject("component",getCompPath(directory & name))>
			<cfset sTestComponent = getMetaData(oTestComponent)>
			<cfloop index="ii" from="1" to="#ArrayLen(aTestMethods)#" step="1">
				<cfset ArrayAppend(aResults,aTestMethods[ii])>
				<cfset aResults[ArrayLen(aResults)]["component"] = oTestComponent>
				<cfset aResults[ArrayLen(aResults)]["compname"] = sTestComponent.DisplayName>
			</cfloop>
		</cfif>
	</cfoutput>
	
	<cfreturn aResults>
</cffunction>

<cffunction name="getTests" access="private" returntype="query" output="false">
	<cfargument name="CompFilePath" type="string" required="false">
	
	<cfset var aTestMethods = 0>
	<cfset var ii = 0>
	<cfset var qResults = 0>
	
	<cfif StructKeyExists(arguments,"CompFilePath")>
		<cfreturn getCompTests(arguments.CompFilePath)>
	</cfif>
	
	<cfset aTestMethods = getTestMethods()>
	<cfset qResults = QueryNew("method,rule,component,compname")>
	
	<cfloop index="ii" from="1" to="#ArrayLen(aTestMethods)#" step="1">
		<cfset QueryAddRow(qResults)>
		<cfset QuerySetCell(qResults,"method",aTestMethods[ii].name)>
		<cfset QuerySetCell(qResults,"rule",aTestMethods[ii].hint)>
		<cfset QuerySetCell(qResults,"component",aTestMethods[ii].component)>
		<cfset QuerySetCell(qResults,"compname",aTestMethods[ii].compname)>
	</cfloop>
	
	<cfreturn qResults>
</cffunction>

<cffunction name="isTestMethod" access="private" returntype="boolean" output="false">
	<cfargument name="method" type="struct" required="true">
	
	<cfset var result = false>
	<cfset var sMethod = arguments.method>
	
	<!---
	A valid test method will meet the following conditions:
	-Have a method name
	-Have a hint
	-Have no arguments
	-Not be private
	--->
	
	<cfif
			( StructKeyExists(sMethod,"name") AND Len(Trim(sMethod.name)) )
		AND	( StructKeyExists(sMethod,"hint") AND Len(Trim(sMethod.hint)) )
		AND	NOT ( StructKeyExists(sMethod,"test") AND sMethod.test IS false )
		AND	NOT ( StructKeyExists(sMethod,"Parameters") AND ArrayLen(sMethod.Parameters) )
		AND	NOT ( StructKeyExists(sMethod,"Access") AND sMethod.Access EQ "private" )
	>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="reloadTestComponents" access="private" returntype="void" output="false" hint="">
	
	<cfset var qTestComponents = getTestComponents()>
	<cfset var compid = 0>
	<cfset var qComponents = 0>
	
	<!--- Add/Modify Components --->
	<cfloop query="qTestComponents">
		<cfset compid = variables.Components.addComponent(ComponentName=DisplayName,ComponentPath=CompPath,FilePath=FilePath,DateLastUpdated=DateLastModified)>
		<cfif compid GT 0>
			<cfset reloadMethods(compid,FilePath)>
		</cfif>
	</cfloop>
	
	<!--- Ditch components with no methods --->
	<cfset qComponents = variables.Components.getComponents(HasRules=0)>
	
	<cfloop query="qComponents">
		<cfset variables.Components.removeComponent(ComponentID)>
	</cfloop>
	
</cffunction>

<cffunction name="reloadMethods" access="private" returntype="void" output="false" hint="">
	<cfargument name="ComponentID" type="numeric" required="true">
	<cfargument name="FilePath" type="string" required="true">
	
	<cfset var qTests  = getTests(arguments.FilePath)>
	<cfset var qRules = 0>
	
	<cfif variables.DataMgr.getDatabase() NEQ "Sim">
		<!--- Delete non-existent rules --->
		<cfset qRules = variables.Rules.getRules(ComponentID=arguments.ComponentID)>
	
		<cfloop query="qRules">
			<cfif NOT ListFindNoCase(ValueList(qTests.Method),Method)>
				<cfset variables.Rules.removeRule(RuleID)>
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- Add/Modify rules --->
	<cfloop query="qTests">
		<cfset variables.Rules.addRule(ComponentID,Rule,Method)>
	</cfloop>
	
</cffunction>

<!---<cffunction name="loadComponents" access="private" returntype="void" output="false" hint="">
	
	<cfset var comps = "Components,Executions,Rules">
	<cfset var comp = "">
	
	<cfloop list="#comps#" index="comp">
		<cfset loadComponent(comp)>
	</cfloop>
	
</cffunction>--->

<cffunction name="xml" access="public" output="yes">
<tables prefix="#variables.prefix#">
	<table entity="Component" Specials="CreationDate,LastUpdatedDate">
		<field name="ComponentPath" Label="Path" type="text" Length="200" required="true" />
		<field name="FilePath" Label="File Path" type="text" Length="250" required="true" />
	</table>
	<table entity="Execution" labelField="DateTested">
		<field fentity="Rule" />
		<field name="DateTested" Label="Date Tested" type="CreationDate" />
		<field name="Status" Label="Status" type="text" Length="80" />
		<field name="Message" Label="Message" type="text" Length="250" />
		<field name="RunTime" Label="Time" type="integer" />
		<field name="wData" Label="Data" type="memo" />
		<field name="dData" Label="Data" type="memo" />
	</table>
	<table entity="Rule" Specials="CreationDate,LastUpdatedDate,DeletionDate">
		<field fentity="Component" />
		<field name="Method" Label="Method" type="text" Length="180" required="true" />
		<field name="DateLastTested" Label="Last Tested" type="relation">
			<relation
				type="max"
				entity="Execution"
				field="DateTested"
				join-field-local="RuleID"
				join-field-remote="RuleID"
			/>
		</field>
		<field name="Status" Label="Status" type="relation">
			<relation
				type="label"
				entity="Execution"
				field="Status"
				join-field-local="RuleID"
				join-field-remote="RuleID"
				sort-field="DateTested"
				sort-dir="DESC"
			/>
		</field>
	</table>
</tables>
</cffunction>

<cffunction name="loadComponent" access="private" returntype="any" output="no" hint="I load a component into memory in this component.">
	<cfargument name="name" type="string" required="yes">
	
	<cfif NOT StructKeyExists(arguments,"path")>
		<cfset arguments.path = arguments.name>
	</cfif>
	
	<cfif StructCount(arguments) EQ 2>
		<cfset This[arguments.name] = CreateObject("component",arguments.path).init(Manager=variables.Manager,RulesMgr=This,Parent=This)>
	<cfelse>
		<cfset arguments["Manager"] = variables.Manager>
		<cfset arguments["RulesMgr"] = This>
		<cfset arguments["Parent"] = This>
		<cfinvoke component="#arguments.path#" method="init" returnvariable="this.#name#" argumentCollection="#arguments#"></cfinvoke>
	</cfif>
	<cfset variables[arguments.name] = This[arguments.name]>
	
</cffunction>

</cfcomponent>