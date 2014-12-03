<cf_PageController>

<cf_Template showTitle="true">

<p>These are business rules that may not be immediately obvious from the visuals of the site. If a needed behaviour isn't listed here, let us know. You can test any of the behaviours to ensure that they are still working correctly.</p>

<div style="float:right">
<cfchart chartheight="300" chartwidth="400">
	<cfchartseries type="pie" query="qStatuses" itemcolumn="status" valuecolumn="NumRules" colorlist="#ValueList(qStatuses.color)#">
</cfchart>
<p><b>Percent Passed:</b> <cfoutput>#PercentPassed#%</cfoutput></p>
</div>

<cf_sebForm sendForward="false" method="get">
	<cf_sebField type="select" name="component" subquery="qComponents" subvalues="ComponentID" subdisplays="ComponentName">
	<cf_sebField type="submit" label="Search">
</cf_sebForm>

<cfif Val(URL.component)>
	<cf_sebForm CFC_Component="#Application.RulesMgr#" CFC_Method="reloadMethods">
		<cf_sebField type="hidden" name="ComponentID" setValue="#URL.component#">
		<cf_sebField type="yesno" name="WithRemove" label="Remove All Tests First?" defaultValue="false" hint="not recommended">
		<cf_sebField type="submit" label="Reload Test Methods">
	</cf_sebForm>
<cfelse>
	<cf_sebForm CFC_Component="#Application.RulesMgr#" CFC_Method="reloadTestComponents" skin="plain">
		<cf_sebField type="submit" label="Reload All Test Components">
	</cf_sebForm>
</cfif>


<div style="clear:right"></div>
<cf_sebTable isAddable="false" isEditable="false" isDeletable="false">
	<cf_sebColumn dbfield="ComponentID">
	<cf_sebColumn dbfield="RuleName">
	<cf_sebColumn dbfield="Status" link="execution-list.cfm?rule=">
	<cf_sebColumn dbfield="DateLastTested" type="datetime">
	<cf_sebColumn type="submit" CFC_Method="testRule" label="Run Test">
</cf_sebTable>

<cf_sebForm CFC_Component="#Application.RulesMgr#" CFC_Method="testRules" sendback="false" skin="plain">
	<cfif URL.component>
		<cf_sebField name="ComponentID" type="hidden" setValue="#URL.component#">
	</cfif>
	<cf_sebField type="submit" label="Test All Rules">
</cf_sebForm>

</cf_Template>