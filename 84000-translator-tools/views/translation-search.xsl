<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <xsl:template name="translation-search">
        
        <div id="translation-search">
            
            <form action="translator-tools.html" method="post" id="search-translation" class="form-inline filter-form">
                <xsl:variable name="request-volume" select="m:translation-search/m:request/@volume-number"/>
                <input type="hidden" name="tab" value="translation-search"/>
                <input type="hidden" name="search" data-onload-highlight="#source">
                    <xsl:attribute name="value" select="m:translation-search/m:request/text()"/>
                </input>
                <div class="form-group">
                    <label for="volume" class="sr-only">Volume</label>
                    <select name="volume" class="form-control" id="volume">
                        <xsl:for-each select="m:translation-search/m:volumes/m:volume">
                            <option>
                                <xsl:attribute name="value" select="@number"/>
                                <xsl:if test="xs:integer(@number) eq xs:integer($request-volume)">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:value-of select="concat('Volume ', @number, ' (', @id, ')')"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="form-group">
                    <label for="page" class="sr-only">Page</label>
                    <select name="page" class="form-control" id="page">
                        <xsl:call-template name="page-options">
                            <xsl:with-param name="page-number" select="xs:integer(1)"/>
                            <xsl:with-param name="page-count" select="m:translation-search/m:volumes/m:volume[xs:integer(@number) eq xs:integer($request-volume)]/@page-count/xs:integer(.)"/>
                        </xsl:call-template>
                    </select>
                </div>
                <div class="form-group">
                    <label for="results-mode" class="sr-only">Results</label>
                    <select name="results-mode" class="form-control">
                        <option value="all">
                            <xsl:if test="m:translation-search/m:results/@mode eq 'all'">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            All matches
                        </option>
                        <option value="translations">
                            <xsl:if test="m:translation-search/m:results/@mode eq 'translations'">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            Matches with translations
                        </option>
                    </select>
                </div>
                <div class="form-group text-muted">
                    Select some tibetan to search for translations.
                </div>
            </form>
            <div id="source" class="source well" data-mouseup-set-input="input[name='search']" data-mouseup-submit="#search-translation">
                <p class="text-bo">
                    <xsl:for-each select="m:translation-search/m:source/m:language[@xml:lang eq 'bo']/tei:p">
                        <xsl:apply-templates select="text()"/>
                    </xsl:for-each>
                </p>
            </div>
            <xsl:choose>
                <xsl:when test="m:translation-search/m:results/m:item">
                    
                    <xsl:for-each select="m:translation-search/m:results/m:item">
                        <div class="search-result">
                            <p class="title">
                                Volume <xsl:value-of select="m:source/@volume-number"/>
                                (<xsl:value-of select="m:source/@ekangyur-id"/>), 
                                Page <xsl:value-of select="m:source/@ekangyur-page"/>
                            </p>
                            <p class="text-bo">
                                <xsl:copy-of select="m:text[@xml:lang eq 'bo']/node()"/>
                            </p>
                            <p>
                                Translation <xsl:value-of select="concat(m:translation/@translation-id, '-*')"/>, 
                                <xsl:value-of select="m:text[@xml:lang eq 'en']/@folio"/>
                            </p>
                            <div class="translation">
                                <div class="text">
                                    <xsl:copy-of select="m:text[@xml:lang eq 'en']/node()"/>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        No search results
                    </p>
                </xsl:otherwise>
            </xsl:choose>
            
        </div>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:if test="normalize-space(.)">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:milestone">
        <xsl:if test="not(xs:integer(@n) eq 1)">
            <br/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="page-options">
        <xsl:param name="page-number"/>
        <xsl:param name="page-count"/>
        <xsl:if test="$page-number &lt;= $page-count">
            <option>
                <xsl:attribute name="value" select="$page-number"/>
                <xsl:if test="$page-number eq m:translation-search/m:request/@page-number/xs:integer(.)">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:variable name="end-page" select="if($page-number &lt; $page-count) then concat(' + ', xs:string($page-number + 1)) else '' "/>
                <xsl:value-of select="concat('Page ', $page-number, $end-page)"/>
            </option>
            <xsl:call-template name="page-options">
                <xsl:with-param name="page-number" select="xs:integer($page-number) + 1"/>
                <xsl:with-param name="page-count" select="$page-count"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>