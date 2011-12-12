<cf_PageController>

<cf_Template showTitle="true">

<cfif showForm>
	<cf_sebForm skin="plain" CFC_Component="#Application.RulesMgr.rules#" CFC_Method="testRule" CFC_MethodArgs="#sRuleArgs#" Message_Completion="Rule Tested">
		<cf_sebField type="submit" label="Run Test">
	</cf_sebForm>
</cfif>

<cf_sebTable isAddable="false" isEditable="false" isDeletable="false" CFC_GetArgs="#sExecutions#">
	<cf_sebColumn dbfield="RuleID">
	<cf_sebColumn dbfield="DateTested" type="datetime" defaultSort="DESC">
	<cf_sebColumn dbfield="Status" link="execution-view.cfm?id=">
	<cf_sebColumn dbfield="Message">
</cf_sebTable>

</cf_Template>