<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.ifHasName" default="">
<cfparam name="attributes.ifNotHasName" default="">
<cfparam name="attributes.ifEmpty" default="">
<cfparam name="attributes.ifNotEmpty" default="">
<cfparam name="attributes.defaultValue" default="">
<cfparam name="attributes.format" default="default">
<!---
<cfparam name="attributes.ifValueEQ" type="string" default="">
<cfparam name="attributes.ifValueNEQ" type="string" default="">
--->
<cfparam name="attributes.type" default="string">

<cfif thisTag.executionmode is 'start'>
    <cfscript>function ParagraphFormat2(str) {
//first make Windows style into Unix style
        str = replace(str,chr(13)&chr(10),chr(10),"ALL");
//now make Macintosh style into Unix style
        str = replace(str,chr(13),chr(10),"ALL");
//now fix tabs
        str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
//now return the text formatted in HTML
        return replace(str,chr(10),"<br>","ALL");
    }</cfscript>

    <cfif attributes.format EQ "default">
        <cfset attributes.format = 'escapedHtml' />
    </cfif>

    <cfset ancestorlist = listdeleteat(getbasetaglist(),1) />
    <cfset currentSetting = { 'index' = 1 } />

    <cfif listfindnocase( ancestorlist,"cf_blocktemplate" )>
        <cfset templatedata = GetBaseTagData("cf_blocktemplate")/>
        <cfset structAppend( currentSetting, templatedata.currentSetting )>
    </cfif>

<!--- this is an iteration of array property --->
    <cfif listfindnocase( ancestorlist,"cf_blocktemplateproperty" )>
        <cfset data = getBaseTagData("cf_blocktemplateproperty", 1 )/>
        <cfset currentSetting = data.currentSetting >
        <cfif data.attributes.type EQ 'array'>
            <cfset currentSetting.index = data.counter />
        </cfif>
    </cfif>

    <cfset property = "" />

    <cfif len(attributes.ifHasName)>
        <cfif NOT structkeyexists( currentSetting, attributes.ifHasName)>
            <cfsetting enablecfoutputonly="false"><cfexit method="exittag">
        </cfif>
    </cfif>

    <cfif len(attributes.ifNotHasName)>
        <cfif structkeyexists( currentSetting, attributes.ifNotHasName)>
            <cfsetting enablecfoutputonly="false"><cfexit method="exittag">
        </cfif>
    </cfif>

    <cfif len( attributes.ifEmpty )>
        <cfif structkeyexists( currentSetting, attributes.name ) AND currentSetting[ attributes.name ] NEQ "">
            <cfsetting enablecfoutputonly="false"><cfexit method="exittag">
        </cfif>
    </cfif>

    <cfif len(attributes.ifNotEmpty)>
        <cfif NOT structkeyexists( currentSetting, attributes.name ) OR currentSetting[ attributes.name ] EQ "">
            <cfsetting enablecfoutputonly="false"><cfexit method="exittag">
        </cfif>
    </cfif>

    <cfif structKeyExists( attributes, 'ifValueEQ' ) AND (
    ( len(attributes.name) AND ( NOT structkeyexists(currentSetting, attributes.name ) OR currentSetting[attributes.name] NEQ attributes.ifValueEQ ))
    OR ( len(attributes.ifHasName) AND currentSetting[attributes.ifHasName] NEQ attributes.ifValueEQ )
    OR ( len(attributes.ifNotHasName) AND currentSetting[attributes.ifNotHasName] NEQ attributes.ifValueEQ )
    )
            >
        <cfsetting enablecfoutputonly="false"><cfexit method="exittag">
    </cfif>

    <cfif structKeyExists( attributes, 'ifValueNEQ' ) AND (
    ( len(attributes.name) AND
        ( structkeyexists(currentSetting, attributes.name ) AND currentSetting[attributes.name] EQ attributes.ifValueNEQ )))>
            >
        <cfsetting enablecfoutputonly="false"><cfexit method="exittag">
    </cfif>

    <cfif len(attributes.name)>
        <cfif structkeyexists(currentSetting, attributes.name)>
            <cfset property = currentSetting[attributes.name] />
            <cfelseif len(attributes.defaultValue)>
            <cfset property = attributes.defaultValue />
        </cfif>
    </cfif>

    <cfif attributes.type EQ "string">
        <cfif attributes.format EQ "paragraph">
            <cfset property = ParagraphFormat2(property) />
            <cfelseif attributes.format EQ "xml">
            <cfset property = xmlformat(property) />
            <cfelseif attributes.format EQ "escapedHtml">
            <cfset property = htmleditformat(property)>
        </cfif>
        <cfoutput>#property#</cfoutput>
    <cfelseif attributes.type EQ "array">

        <cfif isarray( property )>
            <cfset count = arraylen( property ) />
            <cfelseif NOT isarray( property )>
            <cfset count = 0 />
        </cfif>

        <cfset counter = 1 />
        <cfif counter LTE count AND counter LTE arraylen( property )>
            <cfset currentSetting = property[ counter ] />
        <cfelse>
            <cfsetting enablecfoutputonly="false"><cfexit>
        </cfif>
    <cfelse><!--- type holder or variable --->
        <cfif attributes.format EQ "paragraph">
            <cfset property = ParagraphFormat2(property) />
            <cfelseif attributes.format EQ "xml">
            <cfset property = xmlformat(property) />
            <cfelseif attributes.format EQ "escapedHtml">
            <cfset property = htmleditformat(property)>
        </cfif>
        <cfif attributes.type EQ "variable">
            <cfset caller.blockproperty[ attributes.name ] = property />
        </cfif>
    </cfif>
</cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end" and attributes.type EQ 'array'>
    <cfset counter = counter + 1>
    <cfif counter LTE count AND counter LTE arraylen( property )>
        <cfset currentSetting = property[ counter ] /><cfsetting enablecfoutputonly="false"><cfexit method="loop">
    </cfif>
</cfif>
<cfsetting enablecfoutputonly="false">