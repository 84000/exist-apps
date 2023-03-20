<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Template -->
    <xsl:template name="about">
        
        <xsl:param name="sub-content"/>
        <xsl:param name="side-content"/>
        <xsl:param name="page-class"/>
        
        <xsl:variable name="title-band">
            <m:title-band>
                <xsl:copy-of select="$eft-header/m:navigation[@xml:lang eq $lang]//m:item[descendant-or-self::m:item[@url eq $active-url]] | $eft-header/m:translation"/>
            </m:title-band>
        </xsl:variable>
        
        <xsl:variable name="bookmarks-sidebar">
            <m:bookmarks-sidebar>
                <xsl:copy-of select="$eft-header/m:translation"/>
            </m:bookmarks-sidebar>
        </xsl:variable>
        
        <xsl:variable name="page-title" as="xs:string">
            <xsl:choose>
                <xsl:when test="$eft-header/m:navigation[@xml:lang eq $lang]/m:item//m:item[@url eq $active-url][m:label]">
                    <xsl:value-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item//m:item[@url eq $active-url]/m:label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'page-title'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Content variable -->
        <xsl:variable name="content">
            
            <xsl:apply-templates select="$title-band"/>
            <xsl:apply-templates select="$bookmarks-sidebar"/>
            
            <xsl:variable name="page-quote">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'page-quote'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="header-img-src">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'header-img-src'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:if test="$page-quote gt '' and $header-img-src gt ''">
                <aside class="banner-band">
                    <div class="container">
                        <div class="center-vertical-md full-width">
                            <div>
                                <blockquote>
                                    <p>
                                        <xsl:value-of select="$page-quote"/>
                                    </p>
                                    <footer>
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'page-quote-author'"/>
                                        </xsl:call-template>
                                    </footer>
                                </blockquote>
                            </div>
                            <div>
                                <img>
                                    <xsl:attribute name="src" select="$header-img-src"/>
                                </img>
                            </div>
                        </div>
                    </div>
                </aside>
            </xsl:if>
            
            <div class="content-band">
                <div class="container">
                    <div class="row">
                        
                        <main class="col-md-8 col-lg-9">
                            
                            <h1>
                                <xsl:value-of select="$page-title"/>
                            </h1>
                            
                            <!-- Passed content -->
                            <xsl:copy-of select="$sub-content"/>
                            
                        </main>
                        
                        <div class="col-md-4 col-lg-3">
                            
                            <xsl:variable name="sharing-panel">
                                <m:sharing-panel>
                                    <xsl:copy-of select="$eft-header/m:sharing[@xml:lang eq $lang]/node()"/>
                                </m:sharing-panel>
                            </xsl:variable>
                            <xsl:apply-templates select="$sharing-panel"/>
                            
                            <!-- Passed content -->
                            <xsl:copy-of select="$side-content"/>
                            
                            <xsl:variable name="shopping-panel">
                                <m:shopping-panel>
                                    <xsl:copy-of select="$eft-header/m:shopping[@xml:lang eq $lang]/node()"/>
                                </m:shopping-panel>
                            </xsl:variable>
                            <xsl:apply-templates select="$shopping-panel"/>
                            
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:variable name="page-intro">
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'page-intro'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="page-description" as="xs:string">
            <xsl:choose>
                <xsl:when test="$page-intro[xhtml:p[@class eq 'page-description']]">
                    <xsl:value-of select="normalize-space($page-intro/xhtml:p[@class eq 'page-description']/data())"/>
                </xsl:when>
                <xsl:when test="$page-intro[xhtml:p]">
                    <xsl:value-of select="normalize-space($page-intro/xhtml:p[1]/data())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$page-title"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/', /m:response/@model, '.html')"/>
            <xsl:with-param name="page-class" select="if($page-class gt '') then $page-class else 'about'"/>
            <xsl:with-param name="page-title" select="concat($page-title, ' | 84000 Translating the Words of the Buddha')"/>
            <xsl:with-param name="page-description" select="$page-description"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="text-list">
        
        <xsl:param name="texts" required="yes" as="element(m:text)*"/>
        <xsl:param name="list-id" required="yes" as="xs:string"/>
        <xsl:param name="grouping" required="no" as="xs:string?"/>
        <xsl:param name="show-sponsorship" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="show-sponsorship-cost" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="show-sponsors" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="show-translation-status" required="no" as="xs:boolean" select="false()"/>
        
        <xsl:choose>
            
            <xsl:when test="count($texts)">
                <div class="text-list">
                    
                    <div class="row table-headers">
                        
                        <!-- <div class="col-sm-8 hidden-xs"> -->
                        <div class="col-sm-10 hidden-xs">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-title-label'"/>
                            </xsl:call-template>
                        </div>
                        <div class="col-sm-2 hidden-xs">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-toh-label'"/>
                            </xsl:call-template>
                        </div>
                        <!-- 
                        <div class="col-sm-2 hidden-xs">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-pages-label'"/>
                            </xsl:call-template>
                        </div> -->
                        <div class="col-xs-8 visible-xs">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-toh-label'"/>
                            </xsl:call-template>
                            <xsl:value-of select="' / '"/>
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-title-label'"/>
                            </xsl:call-template>
                        </div>
                        <xsl:if test="$show-translation-status">
                            <div class="col-xs-4 visible-xs text-right">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'column-status-label'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:if>
                    </div>
                    
                    <div class="list-section">
                        <xsl:for-each-group select="$texts" group-by="if($grouping eq 'sponsorship' and not(m:sponsorship-status/@project-id eq '')) then m:sponsorship-status/@project-id else if($grouping eq 'text') then @id else m:toh/@key">
                            
                            <xsl:sort select="number(m:toh/@number)"/>
                            <xsl:sort select="m:toh/@letter"/>
                            <xsl:sort select="number(m:toh/@chapter-number)"/>
                            <xsl:sort select="m:toh/@chapter-letter"/>
                            
                            <xsl:variable name="group-index" select="position()"/>
                            
                            <div class="row list-item">
                                
                                <xsl:attribute name="id" select="concat($list-id, '-', @id)"/>
                                
                                <xsl:variable name="toh-content">
                                    
                                    <xsl:for-each select="current-group()">
                                        
                                        <xsl:sort select="number(m:toh/@number)"/>
                                        <xsl:sort select="m:toh/@letter"/>
                                        <xsl:sort select="number(m:toh/@chapter-number)"/>
                                        <xsl:sort select="m:toh/@chapter-letter"/>
                                        
                                        <xsl:if test="position() ne 1">
                                            <br class="hidden-xs"/>
                                            <xsl:value-of select="'+ '"/>
                                        </xsl:if>
                                        
                                        <xsl:value-of select="m:toh/m:full"/>
                                        
                                        <xsl:for-each select="m:toh/m:duplicates/m:duplicate">
                                            <xsl:value-of select="concat(' / ', m:base)"/>
                                        </xsl:for-each>
                                        
                                    </xsl:for-each>
                                    
                                    <xsl:if test="$show-translation-status">
                                        
                                        <br class="hidden-xs"/>
                                        
                                        <span class="col-xs-pull-right">
                                            <xsl:sequence select="common:translation-status(@status-group)"/>
                                        </span>
                                        
                                    </xsl:if>
                                    
                                    <hr class="sml-margin visible-xs"/>
                                    
                                </xsl:variable>
                                
                                <!-- <div class="col-sm-8"> -->
                                <div class="col-sm-10">
                                    
                                    <div class="visible-xs">
                                        <xsl:sequence select="$toh-content"/>
                                    </div>
                                    
                                    <xsl:for-each-group select="current-group()" group-by="if($grouping eq 'text') then @id else m:toh/@key">
                                        
                                        <xsl:sort select="number(m:toh/@number)"/>
                                        <xsl:sort select="m:toh/@letter"/>
                                        <xsl:sort select="number(m:toh/@chapter-number)"/>
                                        <xsl:sort select="m:toh/@chapter-letter"/>
                                        
                                        <xsl:if test="position() ne 1">
                                            <hr/>
                                        </xsl:if>
                                        
                                        <xsl:call-template name="text-list-title">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <!-- Location breadcrumbs -->
                                        <hr/>
                                        <div role="navigation" aria-label="The location of this text in the collection" class="text-muted small">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                <xsl:sequence select="common:breadcrumb-items(m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                            </ul>
                                        </div>
                                        
                                        <!-- Tantric warning -->
                                        <xsl:if test="m:publication/m:tantric-restriction/tei:p">
                                            <hr/>
                                            <xsl:call-template name="tantra-warning">
                                                <xsl:with-param name="id" select="@resource-id"/>
                                                <xsl:with-param name="node" select="m:publication/m:tantric-restriction/tei:p"/>
                                            </xsl:call-template>
                                        </xsl:if>
                                        
                                        <xsl:call-template name="text-list-subtitles">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <!-- Authors -->
                                        <xsl:call-template name="source-authors">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:call-template name="expandable-summary">
                                            <xsl:with-param name="text" select="."/>
                                            <xsl:with-param name="expand-id" select="concat('summary-detail-', $group-index, '-', m:toh/@key)"/>
                                        </xsl:call-template>
                                        
                                    </xsl:for-each-group>
                                    
                                    <xsl:if test="$show-sponsorship">
                                        <xsl:call-template name="sponsorship-status">
                                            <xsl:with-param name="sponsorship-status" select="m:sponsorship-status"/>
                                            <xsl:with-param name="show-cost" select="$show-sponsorship-cost"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                    <xsl:if test="$show-sponsors">
                                        <xsl:variable name="sponsors-text" select="current-group()[m:sponsors[m:sponsor]][1]"/>
                                        <xsl:call-template name="sponsors">
                                            <xsl:with-param name="sponsor-expressions" select="$sponsors-text/m:publication/m:sponsors"/>
                                            <xsl:with-param name="sponsors" select="$sponsors-text/m:sponsors"/>
                                            <xsl:with-param name="sponsorship-status" select="$sponsors-text/m:sponsorship-status"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                </div>
                                
                                <div class="col-sm-2 nowrap hidden-xs">
                                    
                                    <xsl:sequence select="$toh-content"/>
                                    
                                </div>
                                
                            </div>
                            
                        </xsl:for-each-group>
                    </div>
                </div>
            </xsl:when>
            
            <xsl:otherwise>
                <hr class="sml-margin"/>
                <p class="text-muted">
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'no-texts-of-type'"/>
                    </xsl:call-template>
                </p>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="text-list-title">
        
        <xsl:param name="text"/>
        
        <h4 class="item-title">
            <xsl:variable name="title" as="xs:string*">
                <xsl:value-of select="string-join(($text/m:titles/m:parent/m:titles/m:title[@xml:lang eq 'en'], $text/m:titles/m:title[@xml:lang eq 'en']), ', ')"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$text/@status eq '1'">
                    <a>
                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/m:toh/@key, '.html')"/>
                        <xsl:attribute name="target" select="concat($text/@id, '.html')"/>
                        <xsl:value-of select="$title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$title"/>
                </xsl:otherwise>
            </xsl:choose>
        </h4>
        
    </xsl:template>
    
    <xsl:template name="text-list-subtitles">
        
        <xsl:param name="text"/>
        
        <xsl:if test="/m:response/@lang eq 'zh' and $text/m:title-variants/m:title[@xml:lang = 'zh']/text()">
            <hr/>
            <xsl:for-each select="$text/m:title-variants/m:title[@xml:lang = 'zh']">
                <xsl:if test="position() gt 1">
                    <xsl:value-of select="' · '"/>
                </xsl:if>
                <span class="text-zh">
                    <xsl:value-of select="text()"/> 
                </span>
            </xsl:for-each>
        </xsl:if>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang = 'bo']/text()">
            <hr/>
            <span class="text-bo">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang = 'bo']/text()"/>
            </span>
        </xsl:if>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang = 'Bo-Ltn']/text()">
            <xsl:choose>
                <xsl:when test="$text/m:titles/m:title[@xml:lang = 'bo']/text()">
                    <xsl:value-of select="' · '"/>
                </xsl:when>
                <xsl:otherwise>
                    <hr/>
                </xsl:otherwise>
            </xsl:choose>
            <span class="text-wy">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang = 'Bo-Ltn']/text()"/>
            </span>
        </xsl:if>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang = 'Sa-Ltn']/text()">
            <hr/>
            <span class="text-sa">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang = 'Sa-Ltn']/text()"/> 
            </span>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="sponsors">
        
        <xsl:param name="sponsor-expressions" required="no" as="element(m:sponsors)?"/>
        <xsl:param name="sponsors" required="no" as="element(m:sponsors)?"/>
        <xsl:param name="sponsorship-status" required="no" as="element(m:sponsorship-status)?"/>
        
        <xsl:if test="$sponsor-expressions/m:sponsor">
            <hr/>
            <xsl:variable name="sponsor-strings" as="xs:string*">
                <xsl:for-each select="$sponsor-expressions/m:sponsor">
                    <xsl:variable name="sponsor-id" select="replace(@ref, '^(eft:|sponsors\.xml#)', '', 'i')"/>
                    <xsl:choose>
                        <xsl:when test="normalize-space(text())">
                            <xsl:value-of select="normalize-space(text())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space($sponsors/m:sponsor[@xml:id eq lower-case($sponsor-id)]/m:label)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <p class="text-warning">
                <xsl:value-of select="concat('Sponsored by: ', string-join($sponsor-strings, '; '), '.')"/>
            </p>
        </xsl:if>
        
        <xsl:if test="$sponsorship-status/m:status[@id eq 'part']">
            <p class="text-muted">
                <a class="italic text-danger">
                    <xsl:attribute name="href">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'sponsor-sutras-link'"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'text-sponsorship-link-label'"/>
                    </xsl:call-template>
                </a>
            </p>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="sponsorship-status">
        
        <xsl:param name="sponsorship-status" required="no" as="element(m:sponsorship-status)?"/>
        <xsl:param name="show-cost" required="yes" as="xs:boolean"/>
        
        <xsl:if test="$sponsorship-status/m:status[@id eq 'reserved']">
            <hr/>
            <div>
                <span class="label label-warning">
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'reserved-label'"/>
                    </xsl:call-template>
                </span>
            </div>
        </xsl:if>
        
        <xsl:if test="$show-cost">
            <hr/>
            <div class="row">
                
                <!-- There are multiple parts -->
                <xsl:if test="count($sponsorship-status/m:cost/m:part) gt 1">
                    <div class="col-sm-6">
                        <div>
                            <label class="text-muted small">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'sponsor-part-label'"/>
                                </xsl:call-template>
                            </label>
                        </div>
                        <div class="center-vertical align-left">
                            <xsl:for-each-group select="$sponsorship-status/m:cost/m:part" group-by="@amount">
                                
                                <xsl:for-each select="current-group()">
                                    <span>
                                        <xsl:choose>
                                            <xsl:when test="@status eq 'sponsored'">
                                                <span class="btn-round sml gray">
                                                    <i class="fa fa-male"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span class="btn-round sml orange">
                                                    <i class="fa fa-male"/>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </span>
                                </xsl:for-each>
                                
                                <span>
                                    <xsl:value-of select="concat(count(current-group()), ' x ', 'US$',format-number(@amount, '#,###'))"/>
                                </span>
                                
                            </xsl:for-each-group>
                        </div>
                    </div>
                </xsl:if>
                
                <!-- If none of the parts are taken also offer the whole -->
                <xsl:if test="not($sponsorship-status/m:cost/m:part[@status eq 'sponsored'])">
                    <div class="col-sm-6">
                        <div>
                            <label class="text-muted small">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'sponsor-whole-label'"/>
                                </xsl:call-template>
                            </label>
                        </div>
                        <div class="center-vertical align-left">
                            <span>
                                <span class="btn-round sml orange">
                                    <i class="fa fa-male"/>
                                </span>
                            </span>
                            <span>
                                <xsl:value-of select="concat('US$',format-number($sponsorship-status/m:cost/@rounded-cost, '#,###'))"/>
                            </span>
                        </div>
                    </div>
                </xsl:if>
                
            </div>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>