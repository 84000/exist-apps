<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../xslt/lang.xsl"/>
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
                    <div class="panel-heading bold center-vertical">
                        
                        <xsl:if test="$section-id eq 'lobby'">
                            <span class="title">
                                <xsl:value-of select="'The Collection'"/>
                            </span>
                        </xsl:if>
                        
                        <div>
                            <ul class="breadcrumb">
                                
                                <xsl:if test="$section-id eq 'all-translated'">
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', /m:response/@lang)"/>
                                            <xsl:value-of select="'The Collection'"/>
                                        </a>
                                    </li>
                                </xsl:if>
                                
                                <xsl:copy-of select="common:breadcrumb-items(m:section/m:parent | m:section/m:parent//m:parent, /m:response/@lang)"/>
                                
                            </ul>
                        </div>
                        
                        <div>
                            <div class="pull-right center-vertical">
                                
                                <xsl:if test="not($section-id eq 'all-translated')">
                                    <a class="center-vertical together">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'View Translated Texts'"/>
                                        </span>
                                    </a>
                                </xsl:if>
                                
                                <div>
                                    <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical together" role="button" aria-haspopup="true" aria-expanded="false">
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-bookmark"/>
                                                <span class="badge badge-notification">0</span>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Bookmarks'"/>
                                        </span>
                                    </a>
                                </div>
                                
                            </div>
                        </div>
                        
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
                        <xsl:variable name="show-texts" select="(m:section/m:texts/m:text or m:section/m:section[@type eq 'grouping']/m:texts/m:text or m:section/m:texts/@published-only eq '1')"/>
                        
                        <!-- 
                            Conditions for showing tabs
                            - it's not lobby or all translated
                            - and there are texts ($show-texts)
                            - or there are sections
                            - or there's some about content
                        -->
                        <xsl:if test="not($section-id = ('lobby', 'all-translated')) and ($show-texts or m:section/m:section or m:section/m:about/*)">
                            
                            <!-- Content tabs (sections/texts/summary) -->
                            <div class="tabs-container-center">
                                <ul class="nav nav-tabs" role="tablist">
                                    
                                    <xsl:if test="$show-texts">
                                        <!-- Texts tab -->
                                        <li role="presentation" class="active">
                                            <a href="#texts" aria-controls="texts" role="tab" data-toggle="tab">Texts</a>
                                        </li>
                                    </xsl:if>
                                    
                                    <xsl:if test="m:section/m:section[not(@type eq 'grouping')]">
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
                                    <xsl:when test="m:section/m:section[not(@type eq 'grouping')]">
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
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'ebook-help-title'"/>
                                </xsl:call-template>
                            </h4>
                        </div>
                        <div class="modal-body">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'ebook-help-body'"/>
                            </xsl:call-template>
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
            <xsl:with-param name="additional-links">
                
                <!-- Add a navigation link to start (Lobby) -->
                <!-- Don't add related link if it's this id -->
                <xsl:if test="not(lower-case(m:section/@id) eq 'lobby')">
                    <link rel="related" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/section/lobby.navigation.atom" title="The 84000 Reading Room"/>
                </xsl:if>
                
                <!-- Add a navigation link to All Translated -->
                <!-- Don't add related link if it's this id -->
                <xsl:if test="not(lower-case(m:section/@id) eq 'all-translated')">
                    <link rel="related" type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/section/all-translated.acquisition.atom" title="84000: All Translated Texts"/>
                </xsl:if>
                
                <!-- If there are texts add an acquisition entry -->
                <xsl:if test="m:section/m:text-stats/m:stat[@type eq 'count-published-children']/@value gt '0' or lower-case(m:section/@id) eq 'all-translated'">
                    <link rel="alternate" type="application/atom+xml;profile=opds-catalog;kind=acquisition">
                        <xsl:attribute name="href" select="concat('/section/', m:section/@id, '.acquisition.atom')"/>
                        <xsl:attribute name="title" select="concat('84000 : ', m:section/m:titles/m:title[@xml:lang = 'en'], ' - OPDS Catalog')"/>
                    </link>
                </xsl:if>
                
                <!-- If there are more descedant texts then add a navigation entry too -->
                <xsl:if test="m:section/m:text-stats/m:stat[@type eq 'count-published-descendants']/@value gt m:section/m:text-stats/m:stat[@type eq 'count-published-children']/@value">
                    <link rel="alternate" type="application/atom+xml;profile=opds-catalog;kind=navigation">
                        <xsl:attribute name="href" select="concat('/section/', m:section/@id, '.navigation.atom')"/>
                        <xsl:attribute name="title" select="concat('84000 : ', m:section/m:titles/m:title[@xml:lang = 'en'], ' - OPDS Catalog')"/>
                    </link>
                </xsl:if>
                
            </xsl:with-param>
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
                                    <xsl:attribute name="alt" select="'84000 logo'"/>
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
                    <xsl:variable name="count-texts" as="xs:integer" select="$section/m:text-stats/m:stat[@type eq 'count-text-descendants']/@value"/>
                    <xsl:variable name="count-published" as="xs:integer" select="$section/m:text-stats/m:stat[@type eq 'count-published-descendants']/@value"/>
                    <xsl:variable name="count-in-progress" as="xs:integer" select="$section/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/@value"/>
                    
                    <xsl:choose>
                        
                        <xsl:when test="lower-case($section/@id) = 'all-translated'">
                            <table class="table table-stats">
                                <tbody>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="concat('Published: ', format-number($count-published, '#,###'))"/>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </xsl:when>
                        
                        <xsl:otherwise>
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
                <div class="col-md-1 hidden-xs hidden-sm">
                    <xsl:value-of select="'Toh'"/>
                </div>
                <div class="col-md-7 col-lg-8 hidden-xs hidden-sm">
                    <xsl:value-of select="'Title'"/>
                </div>
                <div class="col-xs-4 visible-xs visible-sm">
                    <xsl:value-of select="'Text'"/>
                </div>
                <div class="col-md-4 col-lg-3">
                    <!-- Filter / Sort options -->
                    <xsl:choose>
                        <xsl:when test="lower-case($section/@id) eq 'all-translated'">
                            <!-- Form to sort translated -->
                            <form method="post" class="filter-form form-inline col-sm-pull-right">
                                <div class="form-group">
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
                                </div>
                                <button type="submit" class="btn btn-default hidden-scripts">Go</button>
                            </form>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Form to filter translated -->
                            <form method="post" class="filter-form col-sm-pull-right">
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
            <xsl:for-each select="$section | $section/m:section[@type eq 'grouping']">
                <xsl:sort select="number(m:texts/m:text[1]/m:toh/@number)"/>
                <div class="list-grouping">
                    
                    <!-- Change the class and add a title if they are a grouped sub-section -->
                    <xsl:if test="@nesting gt '1' and m:texts/m:text">
                        <xsl:attribute name="class" select="'list-grouping border'"/>
                        <xsl:attribute name="id" select="concat('grouping-', @id)"/>
                        <div class=" text-center bottom-margin">
                            <xsl:call-template name="section-title">
                                <xsl:with-param name="section" select="."/>
                            </xsl:call-template>
                        </div>
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
                                
                                <span class="visible-xs-inline visible-sm-inline col-sm-pull-right">
                                    <xsl:copy-of select="common:translation-status(@status-group)"/>
                                </span>
                                
                                <hr class="visible-xs-block visible-sm-block"/>
                                
                            </div>
                            
                            <div class="col-md-7 col-lg-8">
                                
                                <!-- English title -->
                                <h4 class="title-en">
                                    <xsl:choose>
                                        <xsl:when test="m:titles/m:title[@xml:lang='en'][not(@type)]/text()">
                                            <xsl:choose>
                                                <xsl:when test="@status-group = 'published'">
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
                                    <div class="text-muted small">
                                        <xsl:value-of select="'in'"/>
                                        <ul class="breadcrumb">
                                            <xsl:copy-of select="common:breadcrumb-items(m:parent | m:parent//m:parent, /m:response/@lang)"/>
                                        </ul>
                                    </div>
                                    
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
                                        <i class="fa fa-chevron-down"/>
                                        <xsl:value-of select="' Summary &amp; variant titles'"/>
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
                                
                            </div>
                            
                            <!-- Download options -->
                            <div class="col-md-4 col-lg-3">
                                
                                <xsl:choose>
                                    <xsl:when test="@status-group eq 'published'">
                                        
                                        <hr class="visible-xs visible-sm sml-margin"/>
                                        
                                        <xsl:if test="m:translation/m:publication-date/text()">
                                            <div class="small italic sml-margin bottom">
                                                <xsl:value-of select="concat('Published ', format-date(m:translation/m:publication-date, '[FNn,*-3], [D1o] [MNn,*-3] [Y]'))"/>
                                            </div>
                                        </xsl:if>
                                        
                                        <ul class="translation-options">
                                            <xsl:variable name="title-en" select="m:titles/m:title[@xml:lang='en'][not(@type)]/text()" as="xs:string"/>
                                            <xsl:for-each select="m:downloads/m:download[@type = ('html', 'pdf', 'epub', 'azw3')]">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="title">
                                                            <xsl:call-template name="download-label">
                                                                <xsl:with-param name="type" select="@type"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:choose>
                                                            <xsl:when test="@type eq 'html'">
                                                                <xsl:attribute name="href" select="common:internal-link(@url, (), '', /m:response/@lang)"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:attribute name="href" select="@url"/>
                                                                <xsl:attribute name="target" select="'_blank'"/>
                                                                <xsl:attribute name="download" select="@filename"/>
                                                                <xsl:attribute name="class" select="'log-click'"/>
                                                                <xsl:attribute name="data-download-dana" select="$title-en"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:call-template name="download-icon">
                                                            <xsl:with-param name="type" select="@type"/>
                                                        </xsl:call-template>
                                                        <xsl:call-template name="download-label">
                                                            <xsl:with-param name="type" select="@type"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                            <xsl:if test="m:downloads/m:download[@type = ('epub', 'azw3')]">
                                                <li>
                                                    <a data-toggle="modal" href="#ebook-help" data-target="#ebook-help" class="visible-scripts text-muted">
                                                        <i class="fa fa-info-circle" aria-hidden="true"/>
                                                        <span class="small">
                                                            <xsl:call-template name="local-text">
                                                                <xsl:with-param name="local-key" select="'ebook-help-title'"/>
                                                            </xsl:call-template>
                                                        </span>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                        </ul>
                                        
                                    </xsl:when>
                                    <xsl:when test="@status-group eq 'translated'">
                                        <div class="small italic sml-margin bottom text-warning visible-md visible-lg">
                                            <xsl:value-of select="'Translation in progress'"/>
                                        </div>
                                    </xsl:when>
                                    <xsl:when test="@status-group eq 'in-translation'">
                                        <div class="small italic sml-margin bottom text-warning visible-md visible-lg">
                                            <xsl:value-of select="'Translation in progress'"/>
                                        </div>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div class="small italic sml-margin bottom text-muted visible-md visible-lg">
                                            <xsl:value-of select="'Translation not Started'"/>
                                        </div>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template name="sub-sections">
        <xsl:param name="section"/>
        
        <xsl:variable name="count-sections" select="count($section/m:section[not(@type eq 'grouping')])"/>
        <xsl:for-each select="$section/m:section[not(@type eq 'grouping')]">
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
                        <xsl:variable name="count-texts" as="xs:integer" select="$section/m:section[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-text-descendants']/@value"/>
                        <xsl:variable name="count-published" as="xs:integer" select="$section/m:section[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-published-descendants']/@value"/>
                        <xsl:variable name="count-in-progress" as="xs:integer" select="$section/m:section[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/@value"/>
                        <table class="table">
                            <tbody>
                                <tr>
                                    <th>
                                        <xsl:value-of select="'Texts'"/>
                                    </th>
                                    <td>
                                        <xsl:value-of select="format-number($count-texts, '#,###')"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>
                                        <xsl:value-of select="'Translated'"/>
                                    </th>
                                    <td>
                                        <xsl:value-of select="format-number($count-published, '#,###')"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>
                                        <xsl:value-of select="'In Progress'"/>
                                    </th>
                                    <td>
                                        <xsl:value-of select="format-number($count-in-progress, '#,###')"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>
                                        <xsl:value-of select="'Not begun'"/>
                                    </th>
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