<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <!-- Ajax content -->
            <div id="ajax-source" class="data-container replace">
                
                <!-- Title -->
                <h2>
                    <xsl:value-of select="'Editing entity: ' || m:entity/@xml:id"/>
                </h2>
                
                <hr/>
                
                <!-- Forms -->
                <form action="/edit-entity.html" method="post" data-ajax-target="#ajax-source" class="form-horizontal">
                    
                    <xsl:attribute name="data-ajax-target-callbackurl" select="concat($reading-room-path, '/glossary.html?entity-id=', m:entity/@xml:id, '&amp;view-mode=editor&amp;timestamp=', current-dateTime())"/>
                    
                    <input type="hidden" name="form-action" value="update-entity"/>
                    
                    <xsl:call-template name="entity-form-input">
                        <xsl:with-param name="entity" select="m:entity"/>
                        <xsl:with-param name="entity-types" select="m:entity-types/m:type"/>
                        <xsl:with-param name="context-id" select="'edit-entity-form'"/>
                        <xsl:with-param name="default-entity-type" select="m:entity-types/m:type[1]/@id"/>
                    </xsl:call-template>
                    
                </form>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Entity Editor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 Entity Editor'"/>
            <xsl:with-param name="content">
                
                <div class="title-band hidden-print">
                    <div class="container">
                        <div class="center-vertical full-width">
                            <span class="logo">
                                <img alt="84000 logo">
                                    <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                                </img>
                            </span>
                            <span>
                                <h1 class="title">
                                    <xsl:value-of select="'Entity Editor'"/>
                                </h1>
                            </span>
                        </div>
                    </div>
                </div>
                
                <main class="content-band">
                    <div class="container">
                        <xsl:sequence select="$content"/>
                    </div>
                </main>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>