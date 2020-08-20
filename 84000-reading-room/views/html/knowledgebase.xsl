<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../xslt/lang.xsl"/>
    <xsl:import href="website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render-translation/m:status/@status-id"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <xsl:if test="not(m:knowledgebase/@status-group eq 'published')">
                <div class="title-band warning">
                    <div class="container">
                        <div class="center-vertical center-aligned">
                            <div>
                                <xsl:value-of select="'This text is not yet ready for publication!'"/>
                            </div>
                        </div>                        
                    </div>
                </div>
            </xsl:if>
            
            <div class="title-band hidden-print">
                <div class="container">
                    <div class="center-vertical center-aligned text-center">
                        <div>
                            <ul class="breadcrumb">
                                <li>
                                    <xsl:value-of select="'84000 Knowledge Base'"/>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            
            <article class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                            
                            <section id="front-matter">
                                <h1 class="text-center">
                                    <xsl:apply-templates select="m:knowledgebase/m:titles/m:title[@xml:lang eq 'en'][@type eq 'mainTitle']"/>
                                </h1>
                            </section>
                            
                        </div>
                    </div>
                </div>
            </article>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="m:knowledgebase/@page-url"/>
            <xsl:with-param name="page-class" select="concat('reading-room knowledgebase ', if(m:request/@view-mode = ('editor', 'annotation')) then 'editor-mode' else '')"/>
            <xsl:with-param name="page-title" select="concat(m:knowledgebase/m:titles/m:title[@xml:lang eq 'en'][@type eq 'mainTitle']/text(), ' | 84000 Reading Room')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:knowledgebase/m:summary/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                
                <xsl:if test="m:request/@view-mode eq 'annotation'">
                    <!-- <script type="application/json" class="js-hypothesis-config">{"theme": "clean"}</script> -->
                    <script src="https://hypothes.is/embed.js" async="async"/>
                </xsl:if>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    
</xsl:stylesheet>