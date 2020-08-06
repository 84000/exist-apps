<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../website-page.xsl"/>
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../../xslt/lang.xsl"/>
    
    <!-- Template -->
    <xsl:template name="about">
        
        <xsl:param name="sub-content"/>
        <xsl:param name="side-content"/>
        <xsl:param name="page-class"/>
        
        <xsl:variable name="title-band">
            <m:title-band>
                <xsl:copy-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item/m:item[@url eq $active-url or m:item[@url eq $active-url]] | $eft-header/m:navigation[@xml:lang eq $lang]/m:label"/>
            </m:title-band>
        </xsl:variable>
        
        <xsl:variable name="page-title">
            <!--<xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'page-title'"/>
            </xsl:call-template>-->
            <xsl:value-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item//m:item[@url eq $active-url]/m:label"/>
        </xsl:variable>
        
        <!-- Content variable -->
        <xsl:variable name="content">
            
            
            <xsl:apply-templates select="$title-band"/>
            
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
                        <div class="center-vertical-md">
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
                        <div class="col-md-8 col-lg-9">
                            
                            <article>
                                
                                <h1 class="sr-only">
                                    <xsl:value-of select="$page-title"/>
                                </h1>
                                
                                <!-- Passed content -->
                                <xsl:copy-of select="$sub-content"/>
                                
                            </article>
                            
                        </div>
                        
                        <aside class="col-md-4 col-lg-3">
                            
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
                            
                        </aside>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/', /m:response/@model-type, '.html')"/>
            <xsl:with-param name="page-class" select="$page-class"/>
            <xsl:with-param name="page-title" select="concat($page-title, ' | 84000 Translating the Words of the Buddha')"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="text-list-title">
        
        <xsl:param name="text"/>
        
        <h4 class="title-en">
            <xsl:variable name="title" as="xs:string*">
                <xsl:if test="$text/m:titles/m:parent">
                    <xsl:value-of select="concat($text/m:titles/m:parent/m:titles/m:title[@xml:lang eq 'en'], ', ')"/>
                </xsl:if>
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$text/@status eq '1'">
                    <a>
                        <xsl:attribute name="href" select="$text/@page-url"/>
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
    
    <xsl:template name="status-label">
        <xsl:param name="status-group" as="xs:string" required="yes"/>
        <xsl:choose>
            <xsl:when test="$status-group eq 'published'">
                <label class="label label-success">
                    <xsl:value-of select="'Published'"/>
                </label>
            </xsl:when>
            <xsl:when test="$status-group = ('translated', 'in-translation')">
                <label class="label label-warning">
                    <xsl:value-of select="'In-progress'"/>
                </label>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="expandable-summary">
        
        <xsl:param name="text"/>
        
        <xsl:if test="$text/m:summary/tei:p">
            <hr/>
            <a class="summary-link collapsed" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseExample">
                <xsl:attribute name="href" select="concat('#summary-detail-', $text/m:toh/@key)"/>
                <i class="fa fa-chevron-down"/>
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'summary-label'"/>
                </xsl:call-template>
            </a>
            
            <div class="collapse summary-detail">
                
                <xsl:attribute name="id" select="concat('summary-detail-', $text/m:toh/@key)"/>
                
                <div class="well well-sm">
                    
                    <xsl:if test="$text/m:summary/tei:p">
                        <xsl:apply-templates select="$text/m:summary/tei:p"/>
                    </xsl:if>
                    
                </div>
            </div>
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="expand-item">
        
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:param name="title" required="yes" as="xs:string"/>
        <xsl:param name="show-count" required="no" as="xs:integer?"/>
        <xsl:param name="content" required="no" as="node()*"/>
        
        <div class="list-group-item">
            
            <div role="tab">
                
                <xsl:attribute name="id" select="concat($id, '-heading')"/>
                
                <a class="center-vertical full-width collapsed" role="button" data-toggle="collapse" data-parent="#accordion" aria-expanded="false">
                    
                    <xsl:attribute name="href" select="concat('#', $id, '-detail')"/>
                    <xsl:attribute name="aria-controls" select="concat($id, '-detail')"/>
                    
                    <span>
                        <span class="h4 list-group-item-heading">
                            <xsl:value-of select="concat($title, ' ')"/>
                            <xsl:if test="$show-count">
                                <span class="badge badge-notification">
                                    <xsl:value-of select="$show-count"/>
                                </span>
                            </xsl:if>
                        </span>
                    </span>
                    
                    <span class="text-right">
                        <i class="fa fa-plus collapsed-show"/>
                        <i class="fa fa-minus collapsed-hide"/>
                    </span>
                    
                </a>
            </div>
            
            <div class="panel-collapse collapse" role="tabpanel" aria-expanded="false">
                
                <xsl:attribute name="id" select="concat($id, '-detail')"/>
                <xsl:attribute name="aria-labelledby" select="concat($id, '-heading')"/>
                
                <div class="panel-body no-padding">
                    <xsl:copy-of select="$content"/>
                </div>
                
            </div>
            
        </div>
    </xsl:template>
    
    <xsl:template name="text-list">
        
        <xsl:param name="texts" required="yes" as="element()*"/>
        <xsl:param name="grouping" required="no" as="xs:string?"/>
        <xsl:param name="show-sponsorship" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="show-sponsorship-cost" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="show-sponsors" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="show-translation-status" required="no" as="xs:boolean" select="false()"/>
        
        <xsl:choose>
            <xsl:when test="count($texts)">
                <div class="text-list">
                    <div class="row table-headers">
                        <div class="col-sm-2 hidden-xs">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-toh-label'"/>
                            </xsl:call-template>
                        </div>
                        <!-- <div class="col-sm-8 hidden-xs"> -->
                        <div class="col-sm-10 hidden-xs">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-title-label'"/>
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
                        <div class="col-xs-4 visible-xs text-right">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'column-status-label'"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    <div class="list-section">
                        <xsl:for-each-group select="$texts" group-by="if($grouping eq 'sponsorship' and not(m:sponsorship-status/@project-id eq '')) then m:sponsorship-status/@project-id else if($grouping eq 'text') then @id else m:toh/@key">
                            
                            <xsl:sort select="number(m:toh/@number)"/>
                            <xsl:sort select="m:toh/@letter"/>
                            <xsl:sort select="number(m:toh/@chapter-number)"/>
                            <xsl:sort select="m:toh/@chapter-letter"/>
                            
                            <div class="row list-item">
                                
                                <xsl:attribute name="id" select="@id"/>
                                
                                <div class="col-sm-2 nowrap">
                                    
                                    <xsl:for-each select="current-group()">
                                        
                                        <xsl:sort select="number(m:toh/@number)"/>
                                        <xsl:sort select="m:toh/@letter"/>
                                        <xsl:sort select="number(m:toh/@chapter-number)"/>
                                        <xsl:sort select="m:toh/@chapter-letter"/>
                                        
                                        <xsl:if test="position() ne 1">
                                            <br class="hidden-xs"/>
                                            <xsl:value-of select="'+'"/>
                                        </xsl:if>
                                        <xsl:value-of select="m:toh/m:full"/>
                                    </xsl:for-each>
                                    
                                    <xsl:if test="$show-translation-status">
                                        
                                        <br class="hidden-xs"/>
                                        
                                        <span class="col-xs-pull-right">
                                            <xsl:call-template name="status-label">
                                                <xsl:with-param name="status-group" select="@status-group"/>
                                            </xsl:call-template>
                                        </span>
                                        
                                    </xsl:if>
                                    
                                    <hr class="visible-xs sml-margin"/>
                                    
                                </div>
                                
                                <!-- <div class="col-sm-8"> -->
                                <div class="col-sm-10">
                                        
                                    <xsl:for-each select="current-group()">
                                        
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
                                        
                                        <xsl:call-template name="text-list-subtitles">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:call-template name="expandable-summary">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                    </xsl:for-each>
                                    
                                    <xsl:if test="$show-sponsorship">
                                        <xsl:call-template name="sponsorship-status">
                                            <xsl:with-param name="sponsorship-status" select="m:sponsorship-status"/>
                                            <xsl:with-param name="show-cost" select="$show-sponsorship-cost"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                    <xsl:if test="$show-sponsors">
                                        <xsl:call-template name="sponsors">
                                            <xsl:with-param name="sponsor-expressions" select="m:translation/m:sponsors"/>
                                            <xsl:with-param name="sponsors" select="m:sponsors"/>
                                            <xsl:with-param name="sponsorship-status" select="m:sponsorship-status"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                </div>
                                <!-- 
                                <div class="col-sm-2">
                                    
                                    <hr class="sml-margin visible-xs"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="$show-sponsorship">
                                            <xsl:value-of select="format-number(sum(m:sponsorship-status/m:cost/@pages), '#,###')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="format-number(sum(m:location/@count-pages), '#,###')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                    <span class="visible-xs-inline">
                                        <xsl:value-of select="' '"/>
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'pages-label'"/>
                                        </xsl:call-template>
                                    </span>
                                    
                                </div> -->
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
    
    <xsl:template name="sponsors">
        <xsl:param name="sponsor-expressions" required="no" as="element(m:sponsors)?"/>
        <xsl:param name="sponsors" required="no" as="element(m:sponsors)?"/>
        <xsl:param name="sponsorship-status" required="no" as="element(m:sponsorship-status)?"/>
        
        <xsl:if test="$sponsor-expressions/m:sponsor">
            <hr/>
            <xsl:variable name="sponsor-strings" as="xs:string*">
                <xsl:for-each select="$sponsor-expressions/m:sponsor">
                    <xsl:variable name="sponsor-id" select="substring-after(@ref, 'sponsors.xml#')"/>
                    <xsl:choose>
                        <xsl:when test="normalize-space(text())">
                            <xsl:value-of select="normalize-space(text())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space($sponsors/m:sponsor[@xml:id eq $sponsor-id]/m:label)"/>
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
            <p class="italic text-danger">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'reserved-label'"/>
                </xsl:call-template>
            </p>
        </xsl:if>
        
        <xsl:if test="$show-cost">
            <hr/>
            <div class="row">
                
                <!-- There are multiple parts -->
                <xsl:if test="count($sponsorship-status/m:cost/m:part) gt 1">
                    <div class="col-sm-6">
                        <div>
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'sponsor-part-label'"/>
                            </xsl:call-template>
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
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'sponsor-whole-label'"/>
                            </xsl:call-template>
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