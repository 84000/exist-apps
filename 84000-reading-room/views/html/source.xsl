<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <!-- TO DO: Using the $toh/@number is a temporary solution until new markers are added to the source -->
    <xsl:variable name="toh-number" select="/m:response/m:translation/m:toh/@number"/>
    
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
            
            <xhtml:div class="content-band">
                <main>
                    <xhtml:div>
                        
                        <xsl:for-each select="m:source/m:page">
                            <xhtml:div>
                                
                                <xsl:variable name="folio-string" as="xs:string">
                                    <xsl:choose>
                                        <xsl:when test="/m:response/m:translation/m:folio-content[@start-ref gt '']">
                                            <xsl:value-of select="/m:response/m:translation/m:folio-content/@start-ref"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('folio ', @folio-in-etext)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <h1 class="title text-center" id="popup-title">
                                    <xsl:value-of select="concat('Degé ', $work-string, ' volume ', @volume, ', ', $folio-string)"/>
                                </h1>
                                
                                <xhtml:div class="container relative">
                                    
                                    <xsl:apply-templates select="m:language[@xml:lang eq 'bo']"/>
                                    
                                    <xsl:variable name="current-ref-index" select="/m:response/m:translation/m:folio-content/@ref-index" as="xs:integer"/>
                                    <xsl:variable name="last-ref-index" select="/m:response/m:translation/m:folio-content/@count-refs" as="xs:integer"/>
                                    
                                    <xsl:if test="$current-ref-index gt 1">
                                        
                                        <a class="carousel-control left" title="Pevious" data-loading="Loading previous...">
                                            
                                            <xsl:attribute name="href" select="concat('?ref-index=', $current-ref-index - 1)"/>
                                            
                                            <i class="fa fa-chevron-left" aria-hidden="true"/>
                                            <span class="sr-only">
                                                <xsl:value-of select="'Previous'"/>
                                            </span>
                                        
                                        </a>
                                        
                                    </xsl:if>
                                    
                                    <xsl:if test="$current-ref-index lt $last-ref-index">
                                    
                                       <a class="carousel-control right" title="Next" data-loading="Loading next...">
                                           
                                           <xsl:attribute name="href" select="concat('?ref-index=', $current-ref-index + 1)"/>
                                           
                                           <i class="fa fa-chevron-right" aria-hidden="true"/>
                                           <span class="sr-only">
                                               <xsl:value-of select="'Next'"/>
                                           </span>
                                           
                                       </a>
                                    
                                    </xsl:if>
                                    
                                </xhtml:div>
                                
                                <hr/>
                                
                                <xhtml:div class="container footer" id="source-footer">
                                    
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
                                    
                                    <xhtml:div id="etext-description-{ position() }" class="well well-sml collapse text-center">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="if($work eq 'UT23703') then 'etengyur-description-content' else 'ekangyur-description-content'"/>
                                        </xsl:call-template>
                                    </xhtml:div>
                                    
                                </xhtml:div>
                                
                            </xhtml:div>
                        </xsl:for-each>
                        
                    </xhtml:div>
                    
                    <!-- Keep outside of ajax data -->
                    <xsl:if test="m:back-link/@url">
                        <xhtml:div class="hidden-iframe">
                            <hr class="no-margin"/>
                            <xhtml:div class="container top-margin bottom-margin">
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
                            </xhtml:div>
                        </xhtml:div>
                    </xsl:if>
                    
                </main>
            </xhtml:div>
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
            
            <!-- To avoid part sentences, include the last partial sentence from the preceding paragraph -->
            <xsl:if test="not(ends-with($preceding-word, '།'))">
                <span class="text-muted">
                    <xsl:value-of select="$preceding-word"/>
                </span>
            </xsl:if>
            
            <!-- Indicate text that is from the preceding text -->
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="$toh-number and following-sibling::tei:milestone[@unit eq 'text'][@toh eq $toh-number]">
                        <span class="text-muted">
                            <xsl:apply-templates select="."/>
                        </span>
                    </xsl:when>
                    <xsl:when test="$toh-number and preceding-sibling::tei:milestone[@unit eq 'text'][1][@toh ne $toh-number]">
                        <span class="text-muted">
                            <xsl:apply-templates select="."/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
            <!-- To avoid part sentences, include the first partial sentence from the following paragraph -->
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