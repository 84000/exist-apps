<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" xmlns:pkg="http://expath.org/ns/pkg" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="common.xsl"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <xsl:template name="modal-page">
        
        <xsl:param name="page-title"/>
        <xsl:param name="content"/>
        
        <!-- Look up environment variables -->
        <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'"/>
        <xsl:variable name="environment" select="doc($environment-path)/m:environment"/>
        <xsl:variable name="app-version" select="doc('../../expath-pkg.xml')/pkg:package/@version"/>
        <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
        
        <html>
            
            <head>
                
                <meta charset="utf-8"/>
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0"/>
                
                <title>
                    84000 Reading Room | <xsl:value-of select="$page-title"/>
                </title>
                
                <!-- Styles -->
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-reading-room.css', '?v=', $app-version)"/>
                </link>
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="href" select="concat($front-end-path, '/css/ie10-viewport-bug-workaround.css')"/>
                </link>
                <!--[if lt IE 9]>
                   <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                   <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
               <![endif]-->
            </head>
            
            <body id="top" class="reading-room modal-page">
                
                <!-- Place content -->
                <xsl:copy-of select="$content"/>
                
                <!-- Foooter components -->
                <span id="media_test">
                    <span class="visible-xs"/>
                    <span class="visible-sm"/>
                    <span class="visible-md"/>
                    <span class="visible-lg"/>
                    <span class="visible-print"/>
                    <span class="visible-mobile"/>
                    <span class="visible-desktop"/>
                    <span class="event-hover"/>
                </span>
                
                <script type="text/javascript">
                    function downloadJSAtOnload() {
                    var element = document.createElement("script");
                    element.src = "<xsl:value-of select="concat($front-end-path, '/js/84000-fe.min.js', '?v=', $app-version)"/>";
                        document.body.appendChild(element);
                    }
                    if (window.addEventListener)
                        window.addEventListener("load", downloadJSAtOnload, false);
                    else if (window.attachEvent)
                        window.attachEvent("onload", downloadJSAtOnload);
                    else window.onload = downloadJSAtOnload;
                </script>
                
            </body>
        </html>
        
    </xsl:template>
</xsl:stylesheet>