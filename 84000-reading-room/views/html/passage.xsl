<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>

    <!-- Look up environment variables -->
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="app-path" select="$environment/m:url[@id eq 'app']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render/m:status[@type eq 'translation']/@status-id"/>
    
    <xsl:variable name="page-title" as="node()*">
        <xsl:sequence select="/m:response/m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        <xsl:sequence select="/m:response/m:translation//m:part[@prefix][@content-status eq 'complete'][1]/tei:head[@type eq parent::m:part/@type]"/>
    </xsl:variable>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <!-- Un-published alert -->
            <xsl:if test="not(m:translation/@status-group eq 'published')">
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
            
            <!-- Breadcrumbs -->
            <xsl:if test="m:translation[m:parent]">
                <div class="title-band hidden-print">
                    <div class="container">
                        <div class="center-vertical center-aligned text-center">
                            <nav role="navigation" aria-label="Breadcrumbs">
                                <ul id="outline" class="breadcrumb">
                                    <xsl:sequence select="common:breadcrumb-items(m:translation/m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </xsl:if>
            
            <!-- Main article -->
            <main class="content-band">
                
                <div id="ajax-source" class="ajax-target bottom-margin">
                    
                    <div class="container">
                        
                        <h1 class="title text-center">
                            <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                        </h1>
                        
                        <hr/>
                        
                        <div class="row">
                            <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override ">
                                
                                <xsl:for-each select="(m:translation/m:part[@type eq 'translation']/m:part | m:translation/m:part[not(@type eq 'translation')])[descendant-or-self::*/@content-status = ('passage','complete','preview')]">
                                    <xsl:choose>
                                        
                                        <xsl:when test="@type eq 'end-notes'">
                                            
                                            <section class="tei-parser part-type-end-notes">
                                                <xsl:call-template name="end-notes"/>
                                            </section>
                                            
                                        </xsl:when>
                                        
                                        <xsl:when test="@type eq 'glossary'">
                                            
                                            <section class="tei-parser part-type-glossary">
                                                <xsl:call-template name="glossary"/>
                                            </section>
                                            
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <section class="text tei-parser part-type-{ @type }">
                                                <xsl:apply-templates select="."/>
                                            </section>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                </xsl:for-each>
                                
                                
                            </div>
                        </div>
                    </div>
                    
                    <!-- TODO: link to this location in the text -->
                    
                </div>
            </main>
            
        </xsl:variable>
 
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            
            <xsl:with-param name="page-url" select="(m:translation/@canonical-html, '')[1]"/>
            <xsl:with-param name="page-class">
                <xsl:value-of select="'reading-room'"/>
                <xsl:value-of select="' translation'"/>
                <xsl:value-of select="concat(' ', $part-status)"/>
                <xsl:if test="$part-status eq 'part' and $requested-part gt ''">
                    <xsl:value-of select="concat(' part-', $requested-part)"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="page-title" select="string-join(($page-title/data(), '84000 Reading Room'), ' | ')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:translation/m:part[@type eq 'summary']/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>

        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>