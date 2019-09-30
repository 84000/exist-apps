<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    <xsl:import href="../../xslt/lang.xsl"/>
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold text-center">
                        <span class="title">
                            <xsl:value-of select="m:back-link/m:title"/>
                        </span>
                    </div>
                    <div class="panel-body">
                        <div id="ekangyur-description" class="well well-sml collapse">
                            <h4 class="no-top-margin">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'ekangyur-description-title'"/>
                                </xsl:call-template>
                            </h4>
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'ekangyur-description-content'"/>
                            </xsl:call-template>
                        </div>
                        <div class="ajax-data">
                            <xsl:variable name="work-string" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="m:source[@work eq 'UT4CZ5369']">
                                        <xsl:value-of select="'Kangyur'"/>
                                    </xsl:when>
                                    <xsl:when test="m:source[@work eq 'UT23703']">
                                        <xsl:value-of select="'Tengyur'"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="folio-string" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="m:translation/m:folio-content/tei:ref[@type eq 'folio'][@cRef]">
                                        <xsl:value-of select="m:translation/m:folio-content/tei:ref[@type eq 'folio'][1]/@cRef"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('folio ', m:source/m:page/@folio-in-etext)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <h3 class="title text-center no-margin">
                                <xsl:value-of select="concat($work-string, ' volume ', m:source/m:page/@volume, ', ', $folio-string)"/>
                            </h3>
                            <div class="container top-margin bottom-margin">
                                <xsl:apply-templates select="m:source/m:page/m:language[@xml:lang eq 'bo']"/>
                            </div>
                            <hr class="no-margin"/>
                            <div class="footer" id="source-footer">
                                <div class="container top-margin bottom-margin">
                                    <p class="text-center small text-muted ">
                                        <xsl:value-of select="concat('e', $work-string, ' ', m:source/m:page/@etext-id, ', page ', m:source/m:page/@page-in-volume, ' (folio ', m:source/m:page/@folio-in-etext, ').')"/>
                                        <a href="#ekangyur-description" class="info-icon" role="button" data-toggle="collapse">
                                            <i class="fa fa-info-circle"/>
                                        </a>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <hr class="no-margin"/>
                        <div class="top-margin bottom-margin">
                            <p class="text-center">
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
            <xsl:with-param name="page-class" select="''"/>
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