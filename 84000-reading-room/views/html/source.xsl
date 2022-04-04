<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="work" select="m:source/@work"/>
        
        <xsl:variable name="content">
            
            <xsl:variable name="work-string" as="xs:string">
                <xsl:choose>
                    <xsl:when test="$work eq 'UT23703'">
                        <xsl:value-of select="'Tengyur'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'Kangyur'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical center-aligned text-center">
                    
                        <nav role="navigation" aria-label="Breadcrumbs">
                            <ul class="breadcrumb">
                                
                                <xsl:sequence select="common:breadcrumb-items(m:translation/m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link(concat('/translation/', m:translation/m:toh/@key, '.html'), (), '', /m:response/@lang)"/>
                                        <xsl:attribute name="target" select="concat(m:translation/@id, '.html')"/>
                                        <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                                    </a>
                                </li>
                                
                            </ul>
                        </nav>
                        
                    </div>
                </div>
            </div>
            
            <div class="content-band">
                <main class="container">
                    <div id="ajax-source" class="ajax-target">
                        
                        <xsl:for-each select="m:source/m:page">
                            <div>
                                
                                <xsl:variable name="first-folio" select="(/m:response/m:translation/m:folio-content/tei:ref[@xml:id][@cRef][@type eq 'folio'][@key eq /m:response/m:translation/m:toh/@key], /m:response/m:translation/m:folio-content/tei:ref[@xml:id][@cRef][@type eq 'folio'][not(@key)])[1]" as="element(tei:ref)?"/>
                                
                                <xsl:variable name="folio-string" as="xs:string">
                                    <xsl:choose>
                                        <xsl:when test="$first-folio">
                                            <xsl:value-of select="$first-folio/@cRef"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('folio ', @folio-in-etext)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <h1 class="title text-center">
                                    <xsl:value-of select="concat('Degé ', $work-string, ' volume ', @volume, ', ', $folio-string)"/>
                                </h1>
                                
                                <div class="container top-margin">
                                    <xsl:apply-templates select="m:language[@xml:lang eq 'bo']"/>
                                </div>
                                
                                <hr/>
                                
                                <div class="container footer" id="source-footer">
                                    
                                    <div class="container">
                                        <p class="text-center text-muted ">
                                            <xsl:value-of select="concat(if($work eq 'UT23703') then 'eTengyur' else 'eKangyur', ', ', @etext-id, ', page ', @page-in-volume, ' (', @folio-in-etext, ').')"/>
                                            <br/>
                                            <a href="#etext-description-{ position() }" role="button" data-toggle="collapse" class="small text-muted">
                                                <i class="fa fa-info-circle"/>
                                                <xsl:value-of select="' '"/>
                                                <xsl:call-template name="local-text">
                                                    <xsl:with-param name="local-key" select="if($work eq 'UT23703') then 'etengyur-description-title' else 'ekangyur-description-title'"/>
                                                </xsl:call-template>
                                            </a>
                                        </p>
                                    </div>
                                    
                                    <div id="etext-description-{ position() }" class="well well-sml collapse text-center">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="if($work eq 'UT23703') then 'etengyur-description-content' else 'ekangyur-description-content'"/>
                                        </xsl:call-template>
                                    </div>
                                    
                                </div>
                                
                            </div>
                        </xsl:for-each>
                        
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
                                <a>
                                    <xsl:attribute name="href" select="m:back-link/@url"/>
                                    <xsl:attribute name="target" select="concat(m:translation/@id, '.html')"/>
                                    <xsl:value-of select="m:back-link/@url"/>
                                </a>
                            </p>
                        </div>
                    </xsl:if>
                    
                </main>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="(m:source/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room source'"/>
            <xsl:with-param name="page-title" select="string-join((concat(m:translation/m:toh/m:full, ' Vol.', m:source/m:page[1]/@volume, ' F.', m:source/m:page[1]/@folio-in-volume), 'Tibetan Source', '84000 Reading Room'), ' | ')"/>
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