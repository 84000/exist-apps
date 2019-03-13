<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <xsl:variable name="section-id" select="lower-case(m:section/@id)"/>
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold center-vertical">
                        
                        <xsl:if test="$section-id eq 'lobby'">
                            <span class="title">The Lobby</span>
                        </xsl:if>
                        
                        <span>
                            <ul class="breadcrumb">
                                
                                <xsl:if test="$section-id eq 'all-translated'">
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', /m:response/@lang)"/>
                                            <xsl:value-of select="'The Lobby'"/>
                                        </a>
                                    </li>
                                </xsl:if>
                                
                                <xsl:copy-of select="common:breadcrumb-items(m:section/m:parent | m:section/m:parent//m:parent, /m:response/@lang)"/>
                                
                            </ul>
                        </span>
                        
                        <span>
                            
                            <div class="pull-right center-vertical">
                                
                                <xsl:if test="not($section-id eq 'all-translated')">
                                    
                                    <a class="center-vertical together">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                        <span>
                                            <span class="btn-round white-red sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'View Translated Texts'"/>
                                        </span>
                                    </a>
                                    
                                </xsl:if>
                                
                                <span>
                                        
                                    <div aria-haspopup="true" aria-expanded="false">
                                        <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical together">
                                            <span>
                                                <span class="btn-round white-red sml">
                                                    <i class="fa fa-bookmark"/>
                                                    <span class="badge badge-notification">0</span>
                                                </span>
                                            </span>
                                            <span class="btn-round-text">
                                                <xsl:value-of select="'Bookmarks'"/>
                                            </span>
                                        </a>
                                    </div>
                                    
                                </span>
                                
                            </div>
                            
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <div id="title">
                            
                            <xsl:call-template name="section-title">
                                <xsl:with-param name="section" select="m:section"/>
                            </xsl:call-template>
                            
                            <xsl:call-template name="section-stats">
                                <xsl:with-param name="section" select="m:section"/>
                            </xsl:call-template>
                            
                        </div>
                        
                        <!-- 
                            Conditions for having a text tab
                            - There are texts
                            - There are texts in a sub-section (it's a grouping section)
                            - There were texts but published-only was selected
                        -->
                        <xsl:variable name="show-texts" select="(m:section/m:texts/m:text or m:section/m:sub-section/m:texts/m:text or m:section/m:texts/@published-only eq '1')"/>
                        
                        <!-- 
                            Conditions for showing tabs
                            - it's not lobby or all translated
                            - and there are texts ($show-texts)
                            - or there are sections
                            - or there's some about content
                        -->
                        <xsl:if test="not($section-id = ('lobby', 'all-translated')) and ($show-texts or m:section/m:sub-section or m:section/m:about/*)">
                            
                            <!-- Content tabs (sections/texts/summary) -->
                            <div class="tabs-container-center">
                                <ul class="nav nav-tabs" role="tablist">
                                    
                                    <xsl:if test="$show-texts">
                                        <!-- Texts tab -->
                                        <li role="presentation" class="active">
                                            <a href="#texts" aria-controls="texts" role="tab" data-toggle="tab">Texts</a>
                                        </li>
                                    </xsl:if>
                                    
                                    <xsl:if test="m:section/m:sub-section[not(@type eq 'grouping')]">
                                        <!-- Sections tab -->
                                        <li role="presentation">
                                            <xsl:attribute name="class" select="if(not($show-texts)) then 'active' else ''"/>
                                            <a href="#sections" aria-controls="sections" role="tab" data-toggle="tab">Sections</a>
                                        </li>
                                    </xsl:if>
                                    
                                    <xsl:if test="m:section/m:about/*">
                                        <!-- About tab -->
                                        <li role="presentation">
                                            <a href="#summary" aria-controls="summary" role="tab" data-toggle="tab">About</a>
                                        </li>
                                    </xsl:if>
                                    
                                </ul>
                                
                            </div>
                        </xsl:if>
        
                        <!-- Tab content -->
                        <div class="tab-content">
                            
                            <!-- Texts -->
                            <div role="tabpanel" id="texts" class="hidden">
                                
                                <xsl:if test="$show-texts">
                                    <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                </xsl:if>
                                
                                <xsl:call-template name="section-texts">
                                    <xsl:with-param name="section" select="m:section"/>
                                </xsl:call-template>
                            
                            </div>
                            
                            <!-- Sections -->
                            <div role="tabpanel" id="sections" class="hidden">
                                
                                <xsl:choose>
                                    <xsl:when test="$show-texts">
                                        <xsl:attribute name="class" select="'tab-pane fade'"/>
                                    </xsl:when>
                                    <xsl:when test="m:section/m:sub-section">
                                        <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                    </xsl:when>
                                </xsl:choose>
                                
                                <div class="row sections">
                                    
                                    <!-- Sub-sections -->
                                    <xsl:call-template name="sub-sections">
                                        <xsl:with-param name="section" select="m:section"/>
                                    </xsl:call-template>
                                </div>
                            </div>
                            
                            <!-- Summary -->
                            <div role="tabpanel" id="summary" class="hidden">
                                
                                <xsl:if test="m:section/m:about/*">
                                    <xsl:attribute name="class" select="'tab-pane fade'"/>
                                </xsl:if>
                                
                                <div class="row">
                                    <div class="col-md-offset-2 col-md-8 text-left">
                                        <xsl:apply-templates select="m:section/m:about/*"/>
                                    </div>
                                </div>
                                
                            </div>
                            
                        </div>
                        
                        <hr/>
                        
                        <div class="row">
                            <div class="col-md-offset-2 col-md-8">
                                <div class="row">
                                    <div class="col-xs-6 col-sm-4">
                                        <a class="text-success center-vertical center-aligned">
                                            <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', /m:response/@lang)"/>
                                            <span class="btn-round green sml">
                                                <i class="fa fa-search"/>
                                            </span>
                                            <span class="btn-round-text">
                                                <xsl:value-of select="'Search the Reading Room'"/>
                                            </span>
                                        </a>
                                    </div>
                                    <div class="col-xs-6 col-sm-4">
                                        <a class="text-danger center-vertical center-aligned">
                                            <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                            <span class="btn-round red sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                            <span class="btn-round-text">
                                                <xsl:value-of select="'View Translated Texts'"/>
                                            </span>
                                        </a>
                                    </div>
                                    <div class="col-xs-12 col-sm-4">
                                        <a href="http://84000.co/how-you-can-help/donate/#sap" class="center-vertical center-aligned">
                                            <xsl:copy-of select="common:override-href(/m:response/@lang, 'zh', 'http://84000.co/ch-howhelp/donate')"/>
                                            <span class="btn-round sml">
                                                <i class="fa fa-gift"/>
                                            </span>
                                            <span class="btn-round-text">
                                                <xsl:value-of select="'Sponsor Translation'"/>
                                            </span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div id="bookmarks-sidebar" class="fixed-sidebar collapse width hidden-print">
                            
                            <div class="container">
                                <div class="fix-width">
                                    <h4>Bookmarks</h4>
                                    <table id="bookmarks-list" class="contents-table">
                                        <tbody/>
                                        <tfoot/>
                                    </table>
                                </div>
                            </div>
                            
                            <div class="fixed-btn-container close-btn-container right">
                                <button type="button" class="btn-round close" aria-label="Close">
                                    <span aria-hidden="true">
                                        <i class="fa fa-times"/>
                                    </span>
                                </button>
                            </div>
                            
                        </div>
                        
                    </div>
                </div>
            </div>
            
            <div class="modal fade" tabindex="-1" role="dialog" id="ebook-help" aria-labelledby="ebook-help-label">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">
                                    <i class="fa fa-times"/>
                                </span>
                            </button>
                            <h4 class="modal-title" id="ebook-help-label">
                                <xsl:value-of select="m:app-text[@key eq 'section.ebook-help-title']"/>
                            </h4>
                        </div>
                        <div class="modal-body">
                            <xsl:copy-of select="m:app-text[@key eq 'section.ebook-help-body']/xhtml:*" copy-namespaces="no"/>
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/section/', m:section/@id, '.html')"/>
            <xsl:with-param name="page-class" select="'section'"/>
            <xsl:with-param name="page-title" select="concat('84000 Reading Room | ', m:section/m:titles/m:title[@xml:lang = 'en'])"/>
            <xsl:with-param name="page-description" select="normalize-space(m:section/m:abstract/tei:p[1]/text())"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="nav-tab" select="'#reading-room'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="section-title">
        
        <xsl:param name="section"/>
        
        <div class="row">
            <div class="col-md-offset-2 col-md-8">
                <div class="title">
                    <xsl:choose>
                        <xsl:when test="lower-case($section/@id) eq 'lobby'">
                            <div>
                                <img class="logo">
                                    <xsl:attribute name="src" select="concat($front-end-path,'/imgs/logo.png')"/>
                                </img>
                            </div>
                            <h1>
                                <xsl:value-of select="'Welcome to the Reading Room'"/>
                            </h1>
                        </xsl:when>
                        <xsl:otherwise>
                            <h1>
                                <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'en'])"/>
                            </h1>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:if test="$section/m:titles/m:title[@xml:lang = 'bo']/text() or $section/m:titles/m:title[@xml:lang = 'bo-ltn']/text()">
                        <hr/>
                        <h4>
                            <span class="text-bo">
                                <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'bo'])"/>
                            </span>
                            <xsl:if test="$section/m:titles/m:title[@xml:lang = 'bo-ltn']/text()">
                                <xsl:value-of select="' · '"/>
                                <span class="text-wy">
                                    <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'bo-ltn'])"/>
                                </span>
                            </xsl:if>
                        </h4>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:titles/m:title[@xml:lang = 'sa-ltn']/text()">
                        <hr/>
                        <h4 class="text-sa">
                            <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'sa-ltn'])"/>
                        </h4>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:abstract/*">
                        <hr/>
                        <div id="abstract">
                            <xsl:apply-templates select="$section/m:abstract/*"/>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:warning/tei:p">
                        <xsl:call-template name="tantra-warning">
                            <xsl:with-param name="id" select="'title'"/>
                            <xsl:with-param name="node" select="$section/m:warning"/>
                        </xsl:call-template>
                    </xsl:if>
                    
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="section-stats">
        <xsl:param name="section"/>
        
        <!-- Ignore in lobby -->
        <xsl:if test="not(lower-case($section/@id) = 'lobby')">
            <div class="row">
                <div class="col-xs-12 col-md-offset-2 col-md-8">
                    
                    <!-- stats -->
                    <xsl:choose>
                        
                        <xsl:when test="lower-case($section/@id) = 'all-translated'">
                            <table class="table table-stats">
                                <tbody>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="concat('Published: ', format-number(count($section/m:texts/m:text), '#,###'))"/>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <xsl:variable name="count-texts" select="$section/m:text-stats/m:stat[@type eq 'count-text-descendants']/number()"/>
                            <xsl:variable name="count-published" select="$section/m:text-stats/m:stat[@type eq 'count-published-descendants']/number()"/>
                            <xsl:variable name="count-in-progress" select="$section/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/number()"/>
                            <table class="table table-stats">
                                <tbody>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="concat('Texts: ', format-number($count-texts, '#,###'))"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="concat('Published: ', format-number($count-published, '#,###'))"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="concat('In Progress: ', format-number($count-in-progress, '#,###'))"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="concat('Not Begun: ', format-number($count-texts - ($count-published + $count-in-progress), '#,###'))"/>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="section-texts">
        <xsl:param name="section"/>
        
        <div class="text-list">
            
            <!-- Row headers -->
            <div class="row table-headers">
                <div class="hidden-xs hidden-sm col-md-1">Toh</div>
                <div class="col-md-8 col-xs-4">
                    <xsl:value-of select="'Title'"/>
                </div>
                <div class="col-md-3 col-xs-8">
                    <!-- Filter / Sort options -->
                    <xsl:choose>
                        <xsl:when test="lower-case($section/@id) eq 'all-translated'">
                            <!-- Form to sort translated -->
                            <form method="post" class="filter-form">
                                <label class="sr-only">
                                    <xsl:value-of select="'Sort translations'"/>
                                </label>
                                <select name="translations-order" class="form-control">
                                    <option value="toh">
                                        <xsl:if test="m:request/@translations-order eq 'toh'">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Sort by Tohoku number'"/>
                                    </option>
                                    <option value="latest">
                                        <xsl:if test="m:request/@translations-order eq 'latest'">
                                            <xsl:attribute name="selected" select="'latest'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Most recent publications'"/>
                                    </option>
                                </select>
                            </form>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Form to filter translated -->
                            <form method="post" class="filter-form">
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" name="published-only" value="1">
                                            <xsl:if test="m:section/m:texts/@published-only eq '1'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="'Published texts only'"/>
                                    </label>
                                </div>
                            </form>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
            
            <!-- Text rows -->
            <!-- Texts can either be direct children of the section or a sub-section which is a grouping -->
            <xsl:for-each select="$section | $section/m:sub-section">
                <xsl:sort select="number(m:texts/m:text[1]/m:toh/@number)"/>
                <div class="list-grouping">
                    
                    <!-- Change the class and add a title if they are a grouped sub-section -->
                    <xsl:if test="self::m:sub-section and m:texts/m:text">
                        <xsl:attribute name="class" select="'list-grouping border'"/>
                        <xsl:attribute name="id" select="concat('grouping-', @id)"/>
                        <xsl:call-template name="section-title">
                            <xsl:with-param name="section" select="."/>
                        </xsl:call-template>
                    </xsl:if>
                    
                    <!-- loop through the texts -->
                    <xsl:for-each select="m:texts/m:text">
                        <xsl:sort select="if(/m:response/m:request/@translations-order eq 'latest') then m:translation/m:publication-date else ''" order="descending"/>
                        <xsl:sort select="number(m:toh/@number)"/>
                        <xsl:sort select="m:toh/@letter"/>
                        <xsl:sort select="number(m:toh/@chapter-number)"/>
                        <xsl:sort select="m:toh/@chapter-letter"/>
                        <div class="row list-item">
                            
                            <xsl:attribute name="id" select="@resource-id"/>
                            
                            <!-- Toh number -->
                            <div class="col-md-1">
                                
                                <xsl:value-of select="m:toh/m:full"/>
                                
                                <xsl:for-each select="m:toh/m:duplicates/m:duplicate">
                                    <br class="hidden-xs hidden-sm"/>
                                    <xsl:value-of select="concat(' / ', m:base)"/>
                                </xsl:for-each>
                                
                                <hr class="visible-xs-block visible-sm-block"/>
                                
                            </div>
                            
                            <div class="col-md-8">
                                
                                <!-- English title -->
                                <h4 class="title-en">
                                    <xsl:choose>
                                        <xsl:when test="m:titles/m:title[@xml:lang='en'][not(@type)]/text()">
                                            <xsl:choose>
                                                <xsl:when test="@status = '1'">
                                                    <a>
                                                        <xsl:attribute name="href" select="common:internal-link(concat('/translation/', m:source/@key, '.html'), (), '', /m:response/@lang)"/>
                                                        <xsl:copy-of select="normalize-space(m:titles/m:title[@xml:lang='en'][not(@type)])"/> 
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="normalize-space(m:titles/m:title[@xml:lang='en'][not(@type)])"/> 
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <em class="text-muted">
                                                <xsl:value-of select="'Awaiting English title'"/>
                                            </em>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h4>
                                
                                <!-- Location -->
                                <xsl:if test="lower-case($section/@id) = 'all-translated'">
                                    <hr/>
                                    in
                                    <ul class="breadcrumb">
                                        <xsl:copy-of select="common:breadcrumb-items(m:parent | m:parent//m:parent, /m:response/@lang)"/>
                                    </ul>
                                </xsl:if>
                                
                                <!-- Tibetan title -->
                                <xsl:if test="m:titles/m:title[@xml:lang='bo']/text()">
                                    <hr/>
                                    <span class="text-bo">
                                        <xsl:value-of select="normalize-space(m:titles/m:title[@xml:lang='bo'])"/>
                                    </span>
                                </xsl:if>
                                
                                <!-- Wylie title -->
                                <xsl:if test="m:titles/m:title[@xml:lang='bo-ltn']/text()">
                                    <xsl:choose>
                                        <xsl:when test="normalize-space(m:titles/m:title[@xml:lang='bo'])">
                                           <xsl:value-of select="' · '"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <hr/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <span class="text-wy">
                                        <xsl:value-of select="normalize-space(m:titles/m:title[@xml:lang='bo-ltn'])"/>
                                    </span>
                                </xsl:if>
                                
                                <!-- Sanskrit title -->
                                <xsl:if test="m:titles/m:title[@xml:lang='sa-ltn']/text()">
                                    <hr/>
                                    <span class="text-sa">
                                        <xsl:value-of select="normalize-space(m:titles/m:title[@xml:lang='sa-ltn'])"/> 
                                    </span>
                                </xsl:if>
                                
                                <!-- Summary and title variants -->
                                <xsl:if test="m:summary/tei:p or m:title-variants/m:title/text()">
                                    
                                    <hr/>
                                    
                                    <a class="summary-link collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                                        <xsl:attribute name="href" select="concat('#summary-detail-', m:toh/@key)"/>
                                        <xsl:attribute name="aria-controls" select="concat('summary-detail-', m:toh/@key)"/>
                                        <i class="fa fa-chevron-down"/> Summary &amp; variant titles
                                    </a>
                                    
                                    <div class="collapse summary-detail">
                                        <xsl:attribute name="id" select="concat('summary-detail-', m:toh/@key)"/>
                                        <div class="well well-sm">
                                            
                                            <xsl:if test="m:summary/tei:p">
                                                <h4>Summary</h4>
                                                <xsl:apply-templates select="m:summary/tei:p"/>
                                            </xsl:if>
                                            
                                            <xsl:if test="m:title-variants/m:title/text()">
                                                <h4>Title variants</h4>
                                                <ul class="list-unstyled">
                                                    <xsl:attribute name="id" select="concat(m:toh/@key, '-title-variants')"/>
                                                    <xsl:for-each select="m:title-variants/m:title">
                                                        <li>
                                                            <span>
                                                                <xsl:attribute name="class" select="concat('title ', common:lang-class(@xml:lang))"/>
                                                                <xsl:value-of select="text()"/>
                                                            </span>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                            </xsl:if>
                                            
                                        </div>
                                    </div>
                                    
                                </xsl:if>
                                
                                <hr class="visible-xs-block visible-sm-block"/>
                                
                            </div>
                            
                            <!-- Download options -->
                            <div class="col-md-3 position-static">
                                
                                <div class="translation-status">
                                    <xsl:choose>
                                        <xsl:when test="@status eq '1' and m:translation/m:publication-date/text()">
                                            <span class="small text-muted">
                                                <xsl:value-of select="concat('Published ', format-date(m:translation/m:publication-date, '[FNn,*-3], [D1o] [MNn,*-3] [Y]'))"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of select="common:translation-status(@status)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </div>
                                
                                <xsl:if test="@status eq '1'">
                                    
                                    <ul class="translation-options">
                                        <li>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link(concat('/translation/', m:source/@key, '.html'), (), '', /m:response/@lang)"/>
                                                <i class="fa fa-laptop"/>
                                                <xsl:value-of select="'Read online'"/>
                                            </a>
                                        </li>
                                        <xsl:for-each select="m:downloads/m:download">
                                            <li>
                                                <a target="_blank">
                                                    <xsl:attribute name="title" select="normalize-space(text())"/>
                                                    <xsl:attribute name="href" select="@url"/>
                                                    <xsl:attribute name="download" select="@filename"/>
                                                    <xsl:attribute name="class" select="'log-click'"/>
                                                    <i>
                                                        <xsl:attribute name="class" select="concat('fa ', @fa-icon-class)"/>
                                                    </i>
                                                    <xsl:value-of select="normalize-space(text())"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                        <xsl:if test="m:downloads/m:download[@type = ('epub', 'azw3')]">
                                            <li>
                                                <a data-toggle="modal" href="#ebook-help" data-target="#ebook-help" class="text-warning">
                                                    <i class="fa fa-info-circle" aria-hidden="true"/>
                                                    <span class="small">
                                                        <xsl:value-of select="/m:response/m:app-text[@key eq 'section.ebook-help-title']"/>
                                                    </span>
                                                </a>
                                            </li>
                                        </xsl:if>
                                    </ul>
                                </xsl:if>
                                
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template name="sub-sections">
        <xsl:param name="section"/>
        
        <xsl:variable name="count-sections" select="count($section/m:sub-section)"/>
        <xsl:for-each select="$section/m:sub-section">
            <xsl:sort select="number(@sort-index)"/>
            <xsl:variable name="sub-section-id" select="@id"/>
            <div>
                
                <xsl:variable name="col-offset-2">
                    <xsl:choose>
                        <xsl:when test="($count-sections mod 2) eq 1 and (position() mod 2) eq 1 and position() &gt; ($count-sections - 2)">
                            <!-- 1 left over in rows of 2 -->
                            <xsl:value-of select="'col-sm-6 col-sm-offset-3'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'col-sm-6 col-sm-offset-0'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:variable name="col-offset-3">
                    <xsl:choose>
                        <xsl:when test="position() &gt; (floor($count-sections div 3) * 3)">
                            <!-- In the last row of rows of 3 -->
                            <xsl:choose>
                                <xsl:when test="($count-sections mod 3) eq 2">
                                    <!-- 2 left over -->
                                    <xsl:choose>
                                        <xsl:when test="(position() mod 3) eq 1">
                                            <!-- first in the row -->
                                            <xsl:value-of select="'col-md-4 col-md-offset-2'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'col-md-4 col-md-offset-0'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="($count-sections mod 3) eq 1">
                                    <!-- 1 left over -->
                                    <xsl:choose>
                                        <xsl:when test="(position() mod 3) eq 1">
                                            <!-- first in the row -->
                                            <xsl:value-of select="'col-md-4 col-md-offset-4'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'col-md-4 col-md-offset-0'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- 0 left over -->
                                    <xsl:value-of select="'col-md-4 col-md-offset-0'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Not in the last row -->
                            <xsl:value-of select="'col-md-4 col-md-offset-0'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                
                <xsl:variable name="col-offset-4">
                    <xsl:choose>
                        <xsl:when test="position() &gt; (floor($count-sections div 4) * 4)">
                            <!-- In the last row of rows of 4 -->
                            <xsl:choose>
                                <xsl:when test="($count-sections mod 4) eq 3">
                                    <!-- 3 left over -->
                                    <xsl:value-of select="'col-lg-4 col-lg-offset-0'"/>
                                </xsl:when>
                                <xsl:when test="($count-sections mod 4) eq 2">
                                    <!-- 2 left over -->
                                    <xsl:choose>
                                        <xsl:when test="(position() mod 4) eq 1">
                                            <!-- first in the row -->
                                            <xsl:value-of select="'col-lg-4 col-lg-offset-2'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'col-lg-4 col-lg-offset-0'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="($count-sections mod 4) eq 1">
                                    <!-- 1 left over -->
                                    <xsl:choose>
                                        <xsl:when test="(position() mod 4) eq 1">
                                            <!-- first in the row -->
                                            <xsl:value-of select="'col-lg-4 col-lg-offset-4'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'col-lg-4 col-lg-offset-0'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- 0 left over -->
                                    <xsl:value-of select="'col-lg-3 col-lg-offset-0'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Not in the last row -->
                            <xsl:value-of select="'col-lg-3 col-lg-offset-0'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:attribute name="class" select="normalize-space(concat($col-offset-2, ' ', $col-offset-3, ' ', $col-offset-4, ' '))"/>
                
                <div class="section-panel">
                    
                    <xsl:if test="@type eq 'pseudo-section'">
                        <xsl:attribute name="class" select="'section-panel pseudo-section'"/>
                    </xsl:if>
                    
                    <div data-match-height="outline-section" data-match-height-media=".sm,.md,.lg">
                        <a target="_self" class="block-link">
                            <xsl:attribute name="href" select="common:internal-link(concat('/section/', @id/string(), '.html'), (), '', /m:response/@lang)"/>
                            <h3>
                                <xsl:value-of select="m:titles/m:title[@xml:lang='en']/text()"/> 
                            </h3>
                            <xsl:if test="m:titles/m:title[@xml:lang='bo']/text()">
                                <p class="text-bo">
                                    <xsl:value-of select="m:titles/m:title[@xml:lang='bo']/text()"/>
                                </p>
                            </xsl:if>
                            <xsl:if test="m:titles/m:title[@xml:lang='bo-ltn']/text()">
                                <p class="text-wy">
                                    <xsl:value-of select="m:titles/m:title[@xml:lang='bo-ltn']/text()"/>
                                </p>
                            </xsl:if>
                            <xsl:if test="m:titles/m:title[@xml:lang='sa-ltn']/text()">
                                <p class="text-sa">
                                    <xsl:value-of select="m:titles/m:title[@xml:lang='sa-ltn']/text()"/>
                                </p>
                            </xsl:if>
                            <div class="notes">
                                <xsl:apply-templates select="m:abstract/*"/>
                            </div>
                        </a>
                        
                        <xsl:if test="m:warning/tei:p">
                            <xsl:call-template name="tantra-warning">
                                <xsl:with-param name="id" select="$sub-section-id"/>
                                <xsl:with-param name="node" select="m:warning"/>
                            </xsl:call-template>
                        </xsl:if>
                        
                    </div>
                    
                    <div class="footer">
                        <xsl:variable name="count-texts" select="$section/m:descendants[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-text-descendants']/number()"/>
                        <xsl:variable name="count-published" select="$section/m:descendants[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-published-descendants']/number()"/>
                        <xsl:variable name="count-in-progress" select="$section/m:descendants[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/number()"/>
                        <table class="table">
                            <tbody>
                                <tr>
                                    <th>Texts</th>
                                    <td>
                                        <xsl:value-of select="format-number($count-texts, '#,###')"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Translated</th>
                                    <td>
                                        <xsl:value-of select="format-number($count-published, '#,###')"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>In Progress</th>
                                    <td>
                                        <xsl:value-of select="format-number($count-in-progress, '#,###')"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Not begun</th>
                                    <td>
                                        <xsl:value-of select="format-number($count-texts - ($count-published + $count-in-progress), '#,###')"/>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                </div>
            </div>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="tantra-warning">
        <xsl:param name="id"/>
        <xsl:param name="node"/>
        
        <a data-toggle="modal" class="warning">
            <xsl:attribute name="href" select="concat('#tantra-warning-', $id)"/>
            <xsl:attribute name="data-target" select="concat('#tantra-warning-', $id)"/>
            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
            <xsl:value-of select="' Tantra Text Warning'"/>
        </a>
        
        <div class="modal fade warning" tabindex="-1" role="dialog">
            <xsl:attribute name="id" select="concat('tantra-warning-', $id)"/>
            <xsl:attribute name="aria-labelledby" select="concat('tantra-warning-label-', $id)"/>
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                        <h4 class="modal-title">
                            <xsl:attribute name="id" select="concat('tantra-warning-label-', $id)"/>
                            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                            <xsl:value-of select="' Tantra Text Warning'"/>
                        </h4>
                    </div>
                    <div class="modal-body">
                        <xsl:apply-templates select="$node"/>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>