<cf_PageController>

<cf_Template showTitle="true">

<cf_sebForm>
	<cf_sebField name="RuleName">
	<cf_sebField name="ComponentID" defaultValue="#URL.component#">
	<cf_sebField name="Method">
	<cf_sebField type="Submit/Cancel/Delete">
</cf_sebForm>

<cfif Action IS "Edit">
	<cf_layout include="execution-list.cfm" style="margin-top:30px;">
</cfif>

</cf_Template>