<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    <xsl:import href="../../xslt/lang.xsl"/>
    <xsl:import href="../../xslt/functions.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <h1 class="text-center">
                        <xsl:value-of select="m:back-link/m:title"/>
                    </h1>
                </div>
            </div>
            
            <div class="content-band">
                <div class="container">
                    <div id="ajax-content">
                        
                        <xsl:variable name="work-string" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="m:source[@work eq 'UT23703']">
                                    <xsl:value-of select="'Tengyur'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Kangyur'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:for-each select="m:source/m:page">
                            <xsl:variable name="folio-string" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="m:translation/m:folio-content/tei:ref[@type eq 'folio'][@cRef]">
                                        <xsl:value-of select="m:translation/m:folio-content/tei:ref[@type eq 'folio'][1]/@cRef"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('folio ', @folio-in-etext)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <h3 class="title text-center no-margin">
                                <xsl:value-of select="concat($work-string, ' volume ', @volume, ', ', $folio-string)"/>
                            </h3>
                            <div class="container top-margin bottom-margin">
                                <xsl:apply-templates select="m:language[@xml:lang eq 'bo']"/>
                            </div>
                            <hr class="no-margin"/>
                            <div class="container footer" id="source-footer">
                                <div class="container top-margin bottom-margin">
                                    <p class="text-center text-muted ">
                                        <xsl:value-of select="concat('e', $work-string, ' ', @etext-id, ', page ', @page-in-volume, ' (', @folio-in-etext, ').')"/>
                                    </p>
                                </div>
                            </div>
                        </xsl:for-each>
                        
                        <div class="container bottom-margin">
                            
                            <div class="text-center">
                                <a href="#ekangyur-description" class="vertical-align" role="button" data-toggle="collapse">
                                    <span>
                                        <i class="fa fa-info-circle"/>
                                    </span>
                                    <span>
                                        <xsl:value-of select="' '"/>
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'ekangyur-description-title'"/>
                                        </xsl:call-template>
                                    </span>
                                </a>
                            </div>
                            
                            <div id="ekangyur-description" class="well well-sml collapse text-center top-margin">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'ekangyur-description-content'"/>
                                </xsl:call-template>
                            </div>
                            
                        </div>
                        
                    </div>
                    
                    <!-- Keep outside of ajax data -->
                    <xsl:if test="m:back-link/@url">
                        <hr class="no-margin"/>
                        <div class="container top-margin bottom-margin">
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
                    </xsl:if>
                </div>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/section/', m:section/@id, '.html')"/>
            <xsl:with-param name="page-class" select="'reading-room source'"/>
            <xsl:with-param name="page-title" select="concat('Tibetan Source | ', m:back-link/m:title, ' Vol.', m:source/m:page[1]/@volume, ' F.', m:source/m:page[1]/@folio-in-volume, ' | 84000 Reading Room')"/>
            <xsl:with-param name="page-description" select="normalize-space(m:section/m:abstract/tei:p[1]/text())"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="tei:p[@class eq 'selected']">
        <xsl:variable name="preceding-word" select="tokenize(preceding-sibling::tei:p/text()[last()], '\s+')[last()]"/>
        <xsl:variable name="last-word" select="tokenize(text()[last()], '\s+')[last()]"/>
        <xsl:variable name="following-word" select="tokenize(following-sibling::tei:p/text()[1], '\s+')[1]"/>
        <p class="text-bo source">
            <xsl:if test="not(ends-with($preceding-word, '།'))">
                <span class="text-muted">
                    <xsl:value-of select="$preceding-word"/>
                </span>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
            <xsl:if test="not(ends-with($last-word, '།')) and $following-word">
                <span class="text-muted">
                    <xsl:value-of select="$following-word"/>
                </span>
            </xsl:if>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <!-- Ignore non-selected <p/>s -->
    </xsl:template>
    
    <xsl:template match="tei:milestone[@unit eq 'line']">
        <xsl:if test="@n ne '1'">
            <!-- <br/> -->
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="common:normalize-bo(.)"/>
    </xsl:template>
    
</xsl:stylesheet>