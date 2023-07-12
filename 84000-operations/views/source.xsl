<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="text" select="/m:response/m:text[1]"/>
    <xsl:variable name="main-title" select="$text/m:titles/m:title[@xml:lang eq 'en'][1]"/>
    <xsl:variable name="toh-number" select="$text/m:toh/@key ! replace(., '^toh', '')"/>
    <xsl:variable name="page-number" select="/m:response/m:request/@first-record" as="xs:integer?"/>
    <xsl:variable name="search" select="/m:response/m:request/m:search" as="xs:string?"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
            
                    <!-- Text title -->
                    <header>
                        
                        <xsl:variable name="main-title-limited" select="common:limit-str($main-title, 80)"/>
                        <a>
                            <xsl:if test="$text[m:toh]">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/m:toh[1]/@key, '.html?view-mode=editor')"/>
                                <xsl:attribute name="target" select="$text/@id || '.html'"/>
                                <xsl:value-of select="$text/m:toh[1]/m:full/data()"/>
                                <xsl:value-of select="' / '"/>
                            </xsl:if>
                            <xsl:value-of select="$main-title-limited"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a class="small underline">
                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/@id, '.html?view-mode=editor')"/>
                            <xsl:attribute name="target" select="$text/@id || '.html'"/>
                            <xsl:value-of select="common:limit-str($text/@id, 100 - string-length($main-title-limited))"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a target="_self" class="small underline" data-loading="Loading...">
                            <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $text/@id)"/>
                            <xsl:value-of select="'Edit headers'"/>
                        </a>
                        
                        <div class="pull-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </header>
                    
                    <hr class="sml-margin"/>
                    
                    <div>
                        
                        <xsl:variable name="work" select="m:source/@work"/>
                        
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
                        
                        <xsl:variable name="volume" select="m:source/m:page/@volume" as="xs:string"/>
                        
                        <xsl:variable name="folio-string" select="m:source/m:page/@folio-in-volume" as="xs:string"/>
                        
                        <div class="center-vertical full-width">
                            
                            <!-- Title -->
                            <div>
                                <h1 class="title">
                                    <xsl:value-of select="concat('Degé ', $work-string, ' volume ', $volume, ', Folio ', $folio-string, ' ')"/>
                                </h1>
                            </div>
                            
                            <!-- Pagination -->
                            <div class="text-right">
                                <xsl:sequence select="common:pagination($page-number, 1, $text/m:location/@count-pages, concat('/source.html?text-id=', $text/@id))"/>
                            </div>
                            
                        </div>
                        
                        <!-- Folio content -->
                        <div class="container relative" data-mouseup-set-input="#search-form [name='search']">
                            <xsl:apply-templates select="m:source/m:page/m:language[@xml:lang eq 'bo']"/>
                        </div>
                        
                        <div class="row">
                            <div class="col-sm-8 col-sm-offset-2">
                                
                                <form action="/source.html" id="search-form" class="filter-form form-horizontal text-center top-margin bottom-margin" data-loading="Searching...">
                                    <input type="hidden" name="text-id" value="{ $text/@id }"/>
                                    <input type="hidden" name="first-record" value="{ $page-number }"/>
                                    <div class="input-group">
                                        <input type="text" name="search" value="{ $search }" class="form-control text-bo"/>
                                        <div class="input-group-btn">
                                            <button type="submit" class="btn btn-primary">
                                                <xsl:value-of select="'search'"/>
                                            </button>
                                        </div>
                                    </div>
                                </form>
                                
                            </div>
                        </div>
                        
                        <div class="text-center bottom-margin text-muted italic">
                            <xsl:value-of select="'Select some Tibetan to scan the collection for related content'"/>
                        </div>
                        
                    </div>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Source Text | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'The Tibetan source text annotated with content'"/>
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
        <!-- Ignore not selected -->
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="common:normalize-bo(.)"/>
    </xsl:template>
    
</xsl:stylesheet>