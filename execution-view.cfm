<cf_PageController>

<cf_Template>

<cf_sebForm skin="plain" CFC_Component="#Application.RulesMgr.rules#" CFC_Method="testRule" CFC_MethodArgs="#sRuleArgs#" Message_Completion="Rule Tested" sendBack="true">
	<cf_sebField type="submit" label="Run Test">
</cf_sebForm>

<cfif Len(qExecution.wData) and isWddx(qExecution.wData)>
	<cfdump var="#qExecution.wData#">
<cfelseif Len(qExecution.dData)>
	<cfoutput>#qExecution.dData#</cfoutput>
</cfif>

</cf_Template>
