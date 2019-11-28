<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../website-page.xsl"/>
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../../xslt/lang.xsl"/>
    
    <!-- Template -->
    <xsl:template name="about">
        
        <xsl:param name="sub-content"/>
        
        <!-- Content variable -->
        <xsl:variable name="content">
            <div class="container">
                <div class="row">
                    <div class="col-md-9 col-md-merge-right">
                        <div class="panel panel-default panel-about main-panel foreground">
                            
                            <div class="panel-img-header thumbnail">
                                
                                <xsl:variable name="page-title">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'page-title'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <xsl:variable name="header-img-src">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'header-img-src'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <xsl:if test="$header-img-src gt ''">
                                    <xsl:attribute name="class" select="'panel-img-header has-img thumbnail'"/>
                                    <img class="stretch">
                                        <xsl:attribute name="src" select="concat($front-end-path, $header-img-src)"/>
                                        <xsl:attribute name="alt" select="concat($page-title, ' page header image')"/>
                                    </img>
                                </xsl:if>
                                
                                <h1>
                                    <xsl:choose>
                                        <xsl:when test="$page-title">
                                            <xsl:value-of select="$page-title"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'[Error: missing title]'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h1>
                            </div>
                            
                            <div class="panel-body">
                                
                                <xsl:variable name="page-quote">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'page-quote'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="page-quote-author">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'page-quote-author'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <xsl:if test="$page-quote gt ''">
                                    <blockquote>
                                        <xsl:value-of select="$page-quote"/>
                                        <xsl:if test="$page-quote-author">
                                            <footer>
                                                <xsl:value-of select="$page-quote-author"/>
                                            </footer>
                                        </xsl:if>
                                    </blockquote>
                                </xsl:if>
                                
                                <!-- Passed content -->
                                <div id="main-content">
                                    <xsl:copy-of select="$sub-content"/>
                                </div>
                                
                            </div>
                            
                            <!-- Social sharing -->
                            <!-- TO DO: add these urls! -->
                            <div class="panel-footer sharing">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'sharing-label'"/>
                                </xsl:call-template>
                                <a href="#" target="_blank">
                                    <i class="fa fa-facebook-square" aria-hidden="true"/>
                                </a>
                                <a href="#" target="_blank">
                                    <i class="fa fa-twitter-square" aria-hidden="true"/>
                                </a>
                                <a href="#" target="_blank">
                                    <i class="fa fa-google-plus-square" aria-hidden="true"/>
                                </a>
                            </div>
                            
                        </div>
                    </div>
                    <div class="col-md-3 col-md-merge-left col-md-pad-top">
                        
                        <!-- Summary -->
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'support-label'"/>
                                    </xsl:call-template>
                                </h3>
                            </div>
                            <div class="panel-body">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'support-description'"/>
                                </xsl:call-template>
                                <table id="translation-stats">
                                    <tbody>
                                        <tr>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'kangyur-count-before-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@count, '#,###')"/>
                                            </td>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'kangyur-count-after-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                        </tr>
                                        <tr>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'translation-count-before-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@in-translation, '#,###')"/>
                                            </td>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'translation-count-after-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                        </tr>
                                        <tr>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'published-count-before-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@published, '#,###')"/>
                                            </td>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'published-count-after-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                        </tr>
                                    </tbody>
                                </table>
                                <div class="text-center">
                                    <div>
                                        <a class="btn btn-primary">
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="local-text">
                                                    <xsl:with-param name="local-key" select="'sponsor-button-link'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="local-text">
                                                <xsl:with-param name="local-key" select="'sponsor-button-label'"/>
                                            </xsl:call-template>
                                        </a>
                                    </div>
                                    <xsl:variable name="donate-instructions-link">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'donate-instructions-link'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:if test="$donate-instructions-link">
                                        <div class="sml-margin top">
                                            <a target="_blank">
                                                <xsl:attribute name="href" select="$donate-instructions-link"/>
                                                <xsl:attribute name="title">
                                                    <xsl:call-template name="local-text">
                                                        <xsl:with-param name="local-key" select="'donate-instructions-link-title'"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                                <xsl:call-template name="local-text">
                                                    <xsl:with-param name="local-key" select="'donate-instructions-label'"/>
                                                </xsl:call-template>
                                            </a>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:variable name="page-title" as="xs:string">
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'page-title'"/>
            </xsl:call-template>
        </xsl:variable>
        
        
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/', /m:response/@model-type, '.html')"/>
            <xsl:with-param name="page-class" select="'about'"/>
            <xsl:with-param name="page-title" select="concat('84000 | ', $page-title)"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="text-list-title">
        
        <xsl:param name="text"/>
        
        <h4 class="title-en">
            <xsl:choose>
                <xsl:when test="$text/@status eq '1'">
                    <a>
                        <xsl:attribute name="href" select="concat('http://read.84000.co/translation/', $text/m:toh/@key, '.html')"/>
                        <xsl:if test="$text/m:titles/m:parent">
                            <xsl:value-of select="concat($text/m:titles/m:parent/m:title, ', ')"/>
                        </xsl:if>
                        <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$text/m:titles/m:parent">
                        <xsl:value-of select="concat($text/m:titles/m:parent/m:title, ', ')"/>
                    </xsl:if>
                    <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
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
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang = 'bo-ltn']/text()">
            <xsl:choose>
                <xsl:when test="$text/m:titles/m:title[@xml:lang = 'bo']/text()">
                    <xsl:value-of select="' · '"/>
                </xsl:when>
                <xsl:otherwise>
                    <hr/>
                </xsl:otherwise>
            </xsl:choose>
            <span class="text-wy">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang = 'bo-ltn']/text()"/>
            </span>
        </xsl:if>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang = 'sa-ltn']/text()">
            <hr/>
            <span class="text-sa">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang = 'sa-ltn']/text()"/> 
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
        
        <xsl:if test="$sponsorship-status/m:status[@id eq 'reserved']">
            <hr/>
            <p class="italic text-danger">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'reserved-label'"/>
                </xsl:call-template>
            </p>
        </xsl:if>
        
        <xsl:if test="count($sponsorship-status/m:cost/m:part) gt 1">
            <hr/>
            <div class="row">
                <div class="col-sm-6">
                    <div>
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'sponsor-part-label'"/>
                        </xsl:call-template>
                    </div>
                    <div class="center-vertical together">
                        <xsl:for-each-group select="$sponsorship-status/m:cost/m:part" group-by="@amount">
                            <xsl:for-each select="current-group()">
                                <span>
                                    <xsl:choose>
                                        <xsl:when test="@status eq 'sponsored'">
                                            <img>
                                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/orange_person.png')"/>
                                                <xsl:attribute name="alt">
                                                    <xsl:value-of select="'Icon for: '"/>
                                                    <xsl:call-template name="local-text">
                                                        <xsl:with-param name="local-key" select="'orange-person-label'"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </img>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <img>
                                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/blue_person.png')"/>
                                                <xsl:attribute name="alt">
                                                    <xsl:value-of select="'Icon for: '"/>
                                                    <xsl:call-template name="local-text">
                                                        <xsl:with-param name="local-key" select="'blue-person-label'"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </img>
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
                
                <!-- If none of the parts are taken offer the whole -->
                <xsl:if test="not($sponsorship-status/m:cost/m:part[@status eq 'sponsored'])">
                    <div class="col-sm-6">
                        <div>
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'sponsor-whole-label'"/>
                            </xsl:call-template>
                        </div>
                        <div class="center-vertical together">
                            <span>
                                <img>
                                    <xsl:attribute name="src" select="concat($front-end-path, '/imgs/blue_person.png')"/>
                                    <xsl:attribute name="alt">
                                        <xsl:value-of select="'Icon for: '"/>
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'blue-person-label'"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </img>
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