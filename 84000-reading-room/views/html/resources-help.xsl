<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <xsl:template match="/m:response">
        <!-- Pass the content to the page -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'reading-room source'"/>
            <xsl:with-param name="page-title" select="'Resource not found'"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content">
                <div class="title-band hidden-print">
                    <div class="container">
                        <div class="center-vertical-sm full-width">
                            <div>
                                <nav role="navigation" aria-label="Breadcrumbs">
                                    <ul class="breadcrumb">
                                        <li>
                                            <xsl:value-of select="'84000 Resources'"/>
                                        </li>
                                        
                                        <li>
                                            <xsl:value-of select="'Resources not found'"/>
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="content-band">
                    <div class="container">
                        <div class="row">
                            
                            <main class="col-md-8 col-lg-9">
                                
                                <h1 id="title">
                                    <xsl:value-of select="'No resources found for this url'"/>
                                </h1>
                                
                                <p>
                                    <xsl:value-of select="'Please contact the tech team to set up a folder for sharing resources for this text.'"/>
                                    <br/>
                                    <a target="translation-tech-helpdesk" href="https://84000-translate.slack.com/channels/translation-tech-helpdesk">
                                        <xsl:value-of select="'Send a message to the technology team on Slack'"/>
                                    </a>
                                </p>
                                
                            </main>
                            
                            <!--
                            <aside class="col-lg-12">
                                <script type="text/javascript">
                                    function resizeIframe() {
                                    try {
                                    var iframe = document.getElementById('eft_glossary_embedded');
                                    iframe.height = iframe.contentWindow.document.body.scrollHeight + "px";
                                    }
                                    catch {}
                                    }
                                </script>
                                <iframe src="{ concat('/source/', /m:response/m:request/@resource-id, '.html') }" onload="resizeIframe()" style="border:0px;" id="eft_glossary_embedded" name="eft_glossary_embedded" scrolling="yes" frameborder="1" marginheight="0px" marginwidth="0px" height="400px" width="100%" allowfullscreen=""></iframe>
                            </aside>-->
                            
                        </div>
                    </div>
                </div>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>