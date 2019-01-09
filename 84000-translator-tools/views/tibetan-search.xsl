<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/functions.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/text-overlay.xsl"/>
    
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    
    <xsl:template name="tibetan-search">
        
        <xsl:variable name="request-volume" select="/m:response/m:request/@volume"/>
        
        <div id="search-container">
            
            <div class="row">
                <div class="col-sm-8">
                    <form action="index.html" method="post" class="form-inline filter-form">
                        
                        <input type="hidden" name="tab" value="tibetan-search"/>
                        <input type="hidden" name="s">
                            <xsl:attribute name="value" select="/m:response/m:tm-search/m:request/text()"/>
                        </input>
                        
                        <div class="form-group">
                            <label for="volume" class="sr-only">Volume</label>
                            <select name="volume" class="form-control" id="volume">
                                <xsl:for-each select="/m:response/m:volumes/m:volume">
                                    <xsl:sort select="xs:integer(@number)"/>
                                    <option>
                                        <xsl:attribute name="value" select="@number"/>
                                        <xsl:if test="xs:integer(@number) eq xs:integer($request-volume)">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="concat('eKangyur volume ', @number, ' (', @id, ')')"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="page" class="sr-only">Page</label>
                            <select name="page" class="form-control" id="page">
                                <xsl:call-template name="page-options">
                                    <xsl:with-param name="page-number" select="1"/>
                                    <xsl:with-param name="page-count" select="/m:response/m:volumes/m:volume[xs:integer(@number) eq xs:integer($request-volume)]/@page-count/xs:integer(.)"/>
                                </xsl:call-template>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <button class="btn btn-default" type="submit">
                                <i class="fa fa-refresh"/>
                            </button>
                        </div>
                        
                        <input type="hidden" data-onload-mark="#folio-text">
                            <xsl:attribute name="value" select="/m:response/m:tm-search/m:request-bo"/>
                        </input>
                        
                    </form>
                    
                    <div class="source text-overlay">
                        <div class="text divided text-bo">
                            <xsl:call-template name="text-marked">
                                <xsl:with-param name="data" select="/m:response/m:source/m:language[@xml:lang eq 'bo']"/>
                            </xsl:call-template>
                        </div>
                        <div id="folio-text" class="text plain text-bo" data-mouseup-set-input="#search-text-bo">
                            <xsl:call-template name="text-plain">
                                <xsl:with-param name="data" select="/m:response/m:source/m:language[@xml:lang eq 'bo']//tei:p"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    
                </div>
                
                <div class="col-sm-4">
                    <form action="index.html" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="tab" value="tibetan-search"/>
                        <input type="hidden" name="lang" value="bo"/>
                        <input type="hidden" name="volume">
                            <xsl:attribute name="value" select="$request-volume"/>
                        </input>
                        <input type="hidden" name="page">
                            <xsl:attribute name="value" select="/m:response/m:request/@page/xs:integer(.)"/>
                        </input>
                        <label for="search-text-bo">
                            Select or type some Tibetan
                        </label>
                        <div class="form-group">
                            <textarea rows="2" class="form-control text-bo" name="s" id="search-text-bo">
                                <xsl:apply-templates select="/m:response/m:tm-search/m:request-bo"/>
                            </textarea>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Search Tibetan</button>
                        </div>
                    </form>
                    <form action="index.html" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="tab" value="tibetan-search"/>
                        <input type="hidden" name="lang" value="bo-ltn"/>
                        <input type="hidden" name="volume">
                            <xsl:attribute name="value" select="$request-volume"/>
                        </input>
                        <input type="hidden" name="page">
                            <xsl:attribute name="value" select="/m:response/m:request/@page/xs:integer(.)"/>
                        </input>
                        <label for="search-text-bo-ltn">
                            or type some Wylie
                        </label>
                        <div class="form-group">
                            <textarea rows="2" class="form-control text-wy" name="s" id="search-text-bo-ltn">
                                <xsl:apply-templates select="/m:response/m:tm-search/m:request-bo-ltn"/>
                            </textarea>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Search Wylie</button>
                        </div>
                    </form>
                </div>
            </div>
            
            <xsl:variable name="results" select="/m:response/m:tm-search/m:results"/>
            <xsl:choose>
                <xsl:when test="$results/m:item">
                    <div class="search-results">
                        <xsl:for-each select="$results/m:item">
                            <div class="search-result row">
                                <div>
                                    <div class="col-sm-6">
                                        <p class="text-bo">
                                            <xsl:apply-templates select="tmx:tu/tmx:tuv[@xml:lang eq 'bo']/tmx:seg"/>
                                        </p>
                                        <p class="translation">
                                            <xsl:apply-templates select="tmx:tu/tmx:tuv[@xml:lang eq 'en']/tmx:seg"/>
                                        </p>
                                    </div>
                                    <div>
                                        <div class="col-sm-6">
                                            <p class="title">
                                                <a target="reading-room">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:source/@resource-id, '.html#', common:folio-id(tmx:tu/tmx:prop[@name eq 'folio']/text()))"/>
                                                    <xsl:apply-templates select="m:source/m:title"/>
                                                </a>
                                                <br/>
                                                <span class="translators text-muted small">
                                                    Translated by 
                                                    <xsl:variable name="author-ids" select="m:source/m:translation/m:contributors/m:author[@role eq 'translatorEng']/@sameAs ! substring-after(., 'contributors.xml#')"/>
                                                    <xsl:value-of select="string-join(/m:response/m:contributor-persons/m:person[@xml:id = $author-ids]/m:label, ' · ')"/>
                                                </span>
                                                <xsl:for-each select="m:source/m:bibl">
                                                    <br/>
                                                    <span class="ancestors text-muted small">
                                                        in 
                                                        <xsl:for-each select="m:parent | m:parent//m:parent">
                                                            <xsl:sort select="@nesting" order="descending"/>
                                                            <xsl:value-of select="m:title[@xml:lang='en']/text()"/>
                                                            / 
                                                        </xsl:for-each>
                                                        <xsl:if test="m:toh/m:full">
                                                            <xsl:value-of select="m:toh/m:full"/>
                                                        </xsl:if>
                                                    </span>
                                                </xsl:for-each>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </xsl:for-each>
                    </div>
                    
                    <!-- Pagination -->
                    <xsl:copy-of select="common:pagination($results/@first-record, $results/@max-records, $results/@count-records, 'index.html?tab=tibetan-search', concat('&amp;s=', /m:response/m:tm-search/m:request/text()))"/>
                    
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
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template name="page-options">
        <xsl:param name="page-number"/>
        <xsl:param name="page-count"/>
        <xsl:if test="$page-number le $page-count">
            <option>
                <xsl:attribute name="value" select="$page-number"/>
                <xsl:if test="$page-number eq /m:response/m:request/@page/xs:integer(.)">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="concat('Page ', $page-number)"/>
            </option>
            <xsl:call-template name="page-options">
                <xsl:with-param name="page-number" select="xs:integer($page-number) + 1"/>
                <xsl:with-param name="page-count" select="$page-count"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>