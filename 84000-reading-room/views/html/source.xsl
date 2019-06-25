<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    <xsl:import href="../../xslt/lang.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <div id="popup-footer-source" class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold">
                        <span class="title">
                            <xsl:value-of select="m:back-link/m:title"/>
                        </span>
                    </div>
                    <div class="panel-body">
                        <div class="ajax-data">
                            <h3 class="title">
                                <xsl:value-of select="concat('Folio ', m:request/@folio)"/>
                            </h3>
                            <hr/>
                            <div class="container">
                                <xsl:apply-templates select="m:source[@name eq 'ekangyur']/m:language[@xml:lang eq 'bo']"/>
                            </div>
                            <hr/>
                            <div class="footer" id="source-footer">
                                <div class="container">
                                    <p>
                                        <xsl:value-of select="concat('eKangyur ', m:source[@name eq 'ekangyur']/@ekangyur-id, ', page ', m:source[@name eq 'ekangyur']/@page, '.')"/>
                                        <a href="#popover-content" class="info" role="button" data-toggle="popover" data-placement="top" data-trigger="focus" data-container="#source-footer">
                                            <i class="fa fa-info-circle"/>
                                        </a>
                                    </p>
                                </div>
                                <div id="popover-content" class="hidden">
                                    <h4 class="title">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'ekangyur-description-title'"/>
                                        </xsl:call-template>
                                    </h4>
                                    <div class="content">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'ekangyur-description-content'"/>
                                        </xsl:call-template>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="well well-sml">
                            <p class="text-center text-muted">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'backlink-label'"/>
                                </xsl:call-template>
                                <br/>
                                <a href="#">
                                    <xsl:attribute name="href" select="m:back-link/@url"/>
                                    <xsl:value-of select="m:back-link/@url"/>
                                </a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/section/', m:section/@id, '.html')"/>
            <xsl:with-param name="page-class" select="'translation'"/>
            <xsl:with-param name="page-title" select="concat('84000 Reading Room | ', m:section/m:titles/m:title[@xml:lang = 'en'])"/>
            <xsl:with-param name="page-description" select="normalize-space(m:section/m:abstract/tei:p[1]/text())"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="tei:p">
        <p class="text-bo source">
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:milestone[@unit eq 'line']">
        <xsl:if test="@n ne '1'">
            <!-- <br/> -->
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
</xsl:stylesheet>