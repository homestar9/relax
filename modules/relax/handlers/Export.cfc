<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	Home Handler Section
----------------------------------------------------------------------->
<cfcomponent output="false" extends="BaseHandler">
<cfscript>

	function preHandler(event){
		var rc = event.getCollection();
		super.preHandler(argumentCollection=arguments);
		// module settings
		rc.settings = getModuleSettings("relax").settings;
		rc.dsl		= rc.settings.dsl;
		// custom css/js
		rc.jsAppendList  = "jquery.scrollTo-min,shCore,brushes/shBrushJScript,brushes/shBrushColdFusion,brushes/shBrushXml";
		rc.cssAppendList = "shCore,shThemeDefault";
		// Exit Handlers
		rc.xehResourceDocEvent  = "relax:Home.resourceDoc";
	}
	
	function api(event,rc,prc){
		prc.xehExportAPI = "relax/export/api";
		prc.jsonAPI = serializeJSON( rc.settings.dsl );
		if( event.valueExists("download") ){
			var title = getPlugin("HTMLHelper").slugify( rc.dsl.relax.title );
			event.setHTTPHeader(name="content-disposition",value='attachment; filename="#title#.json"');
			event.renderData(data=prc.jsonAPI,type="json");
		}	
		else{
			event.setView(name="export/api",layout="ajax");
		}
	}

	function html(event,rc,prc){
		var rc 					= event.getCollection();
		rc.print 				= "true";
		rc.expandedResourceDivs = true;
		
		// custom css/js
		rc.jsAppendList  = "shCore,brushes/shBrushJScript,brushes/shBrushColdFusion,brushes/shBrushXml";
		rc.cssAppendList = "shCore,shThemeDefault";
		
		event.setView(name="export/html",layout="html");
	}
	
	function pdf(event,rc,prc){
		var rc = event.getCollection();
		html(event);
		event.setLayout("pdf");
	}
	
	function mediawiki(event,rc,prc){
		wikiMarkup(event,rc,prc,"WIKIPEDIA");
	}

	function trac(event,rc,prc){
		wikiMarkup(event,rc,prc,"TRAC");	
	}

	function wikiMarkup(event,rc,prc,type){
		var rc = event.getCollection();
		var converter = getPlugin(plugin="WikiText",module="relax");
		var data = "";
		
		html(event,rc,prc);
		data = converter.toWiki(wikiTranslator=arguments.type,htmlString=renderView("export/html"));
		event.renderData(type="text",data=data);
	}

</cfscript>
</cfcomponent>