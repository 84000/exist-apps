<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <xsl:variable name="section-id" select="lower-case(m:section/@id)"/>
            
            <!-- Filters -->
            <xsl:variable name="filters" select="m:section/m:filters/tei:div[@type eq 'filter']"/>
            <xsl:variable name="selected-filter" select="$filters[@xml:id eq /m:response/m:request/@filter-id]"/>
            <xsl:variable name="carousel-filters" select="$filters[m:display[@key eq 'carousel']]"/>
            <xsl:variable name="sidebar-filters" select="$filters[m:display[@key eq 'sidebar']]"/>
            
            <div class="title-band hidden-print">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        
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
                                
                                <li>
                                    <h1>
                                        <xsl:value-of select="m:section/m:titles/m:title[@xml:lang = 'en']"/>
                                    </h1>
                                </li>
                                
                            </ul>
                        </div>
                        
                        <div>
                            <div class="center-vertical pull-right">
                                
                                <xsl:if test="not($section-id eq 'all-translated')">
                                    <div>
                                        <a class="center-vertical">
                                            <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                            <span>
                                                <span class="btn-round sml">
                                                    <i class="fa fa-list"/>
                                                </span>
                                            </span>
                                            <span class="btn-round-text">
                                                <xsl:value-of select="'All Published Translations'"/>
                                            </span>
                                        </a>
                                    </div>
                                </xsl:if>
                                
                                <div>
                                    <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical" role="button" aria-haspopup="true" aria-expanded="false">
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
                </div>
            </div>
            
            <!-- Include the bookmarks sidebar -->
            <xsl:variable name="bookmarks-sidebar">
                <m:bookmarks-sidebar>
                    <xsl:copy-of select="$eft-header/m:translation"/>
                </m:bookmarks-sidebar>
            </xsl:variable>
            <xsl:apply-templates select="$bookmarks-sidebar"/>
            
            <div id="section-content" class="content-band">
                <div class="container">
                    
                    <div id="title">
                        
                        <xsl:call-template name="section-title">
                            <xsl:with-param name="section" select="m:section"/>
                        </xsl:call-template>
                        
                        <xsl:choose>
                            
                            <xsl:when test="$section-id eq 'lobby'">
                                <!-- Do nothing -->
                            </xsl:when>
                            
                            <xsl:when test="$section-id eq 'all-translated'">
                                
                                <div class="row">
                                    <div class="col-xs-12 col-md-offset-2 col-md-8">
                                        
                                        <table class="table table-stats">
                                            <tbody>
                                                <tr>
                                                    <td>
                                                        <xsl:value-of select="concat('Publications: ', format-number(count(m:section/m:texts/m:text), '#,###'))"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="concat('Total Pages: ', format-number(sum(m:section/m:texts/m:text/m:source/m:location/@count-pages ! xs:integer(.)), '#,###'))"/>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <div class="row">
                                    <div class="col-xs-12 col-md-offset-2 col-md-8">
                                        
                                        <!-- stats -->
                                        <xsl:variable name="count-texts" as="xs:integer?" select="m:section/m:text-stats/m:stat[@type eq 'count-text-descendants']/@value"/>
                                        <xsl:variable name="count-published" as="xs:integer?" select="m:section/m:text-stats/m:stat[@type eq 'count-published-descendants']/@value"/>
                                        <xsl:variable name="count-in-progress" as="xs:integer?" select="m:section/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/@value"/>
                                        <xsl:variable name="sum-published-pages" as="xs:integer?" select="m:section/m:text-stats/m:stat[@type eq 'sum-pages-published-descendants']/@value"/>
                                        
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
                                        
                                    </div>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </div>
                    
                    <!-- Conditions for having a text tab
                        - There are texts
                        - There are texts in a sub-section (it's a grouping section)
                        - There were texts but published-only was selected
                    -->
                    <xsl:variable name="show-texts" select="(m:section/m:texts/m:text or m:section/m:section[@type eq 'grouping']/m:texts/m:text or m:section/m:texts[@published-only eq '1'])"/>
                   
                    <!-- Content tabs (sections/texts/summary) -->
                    <xsl:if test="not($section-id = ('lobby', 'all-translated')) and ($show-texts or m:section/m:section[not(@type eq 'grouping')] or m:section/m:about/*)">
                        <div class="tabs-container-center hidden-print">
                            <ul class="nav nav-tabs" role="tablist">
                                
                                <!-- Texts tab -->
                                <xsl:if test="$show-texts">
                                    <li role="presentation" class="active">
                                        <a href="#texts" aria-controls="texts" role="tab" data-toggle="tab">
                                            <xsl:value-of select="'Texts'"/>
                                        </a>
                                    </li>
                                </xsl:if>
                                
                                <!-- Sub-sections tab -->
                                <xsl:if test="m:section/m:section[not(@type eq 'grouping')]">
                                    <li role="presentation">
                                        <xsl:attribute name="class" select="if(not($show-texts)) then 'active' else ''"/>
                                        <a href="#sections" aria-controls="sections" role="tab" data-toggle="tab">
                                            <xsl:value-of select="'Sections'"/>
                                        </a>
                                    </li>
                                </xsl:if>
                                
                                <!-- About tab -->
                                <xsl:if test="m:section/m:about[*]">
                                    <li role="presentation">
                                        <a href="#summary" aria-controls="summary" role="tab" data-toggle="tab">
                                            <xsl:value-of select="'About'"/>
                                        </a>
                                    </li>
                                </xsl:if>
                                
                            </ul>
                        </div>
                        
                    </xsl:if>
                    
                    <!-- Filters Carousel -->
                    <xsl:if test="$carousel-filters">
                        <div id="filters-carousel" class="not-ready hidden-print">
                            
                            <div class="viewport">
                                <ul class="list-unstyled slider">
                                    
                                    <li class="col-filter">
                                        
                                        <xsl:variable name="item-id" select="concat('carousel-filter-', 'all')"/>
                                        <xsl:attribute name="id" select="$item-id"/>
                                        
                                        <xsl:if test="/m:response/m:request[@filter-id eq ''] and not(/m:response/m:section/m:texts[m:filter])">
                                            <xsl:attribute name="class" select="'col-filter active'"/>
                                        </xsl:if>
                                        
                                        <a class="filter-panel" data-match-height="carousel-filters">
                                            <xsl:attribute name="href" select="concat(lower-case(m:section/@id), '.html', '#section-content')"/>
                                            <xsl:attribute name="data-ajax-target" select="'#section-content'"/>
                                            <h3>
                                                <xsl:value-of select="'All Publications'"/>
                                            </h3>
                                            <p class="small">
                                                <xsl:value-of select="'All the texts we have published so far.'"/>
                                            </p>
                                        </a>
                                        
                                    </li>
                                    
                                    <xsl:for-each select="($carousel-filters, if(not($carousel-filters[@xml:id = $selected-filter/@xml:id])) then $selected-filter else ())">
                                        
                                        <xsl:variable name="filter" select="."/>
                                        
                                        <li class="col-filter">
                                            
                                            <xsl:variable name="item-id" select="concat('carousel-filter-', $filter/@xml:id)"/>
                                            <xsl:attribute name="id" select="$item-id"/>
                                            
                                            <xsl:if test="/m:response/m:request[@filter-id eq $filter/@xml:id]">
                                                <xsl:attribute name="class" select="'col-filter active'"/>
                                            </xsl:if>
                                            
                                            <a class="filter-panel" data-match-height="carousel-filters">
                                                <xsl:attribute name="href" select="concat(lower-case(/m:response/m:section/@id), '.html', '?filter-id=', @xml:id, '#section-content')"/>
                                                <xsl:attribute name="data-ajax-target" select="'#section-content'"/>
                                                <h3>
                                                    <xsl:value-of select="tei:head[@type eq 'filter']"/>
                                                </h3>
                                                <div class="small">
                                                    <xsl:apply-templates select="$filter/tei:p"/>
                                                </div>
                                            </a>
                                            
                                        </li>
                                    </xsl:for-each>
                                    
                                </ul>
                            </div>
                            
                            <a class="carousel-control left" href="#filters" role="button" data-slide="prev">
                                <i class="fa fa-chevron-left" aria-hidden="true"/>
                                <span class="sr-only">
                                    <xsl:value-of select="'Previous'"/>
                                </span>
                            </a>
                            
                            <a class="carousel-control right" href="#filters" role="button" data-slide="next">
                                <i class="fa fa-chevron-right" aria-hidden="true"/>
                                <span class="sr-only">
                                    <xsl:value-of select="'Next'"/>
                                </span>
                            </a>
                            
                        </div>
                    </xsl:if>
                    
                    <!-- Advanced filters button -->
                    <xsl:if test="$filters">
                        <div class="row">
                            <div class="col-sm-6 col-sm-offset-3">
                                
                                <a role="button" aria-haspopup="true" aria-expanded="false" class="show-sidebar no-underline">
                                    <xsl:attribute name="href" select="'#filters-sidebar'"/>
                                    <xsl:attribute name="aria-controls" select="'filters-sidebar'"/>
                                    
                                    <div class="panel panel-default">
                                        <div class="panel-body text-center">
                                            
                                            <h3 class="no-top-margin no-bottom-margin">
                                                <xsl:value-of select="'Advanced Filters...'"/>
                                            </h3>
                                            
                                            <xsl:choose>
                                                <xsl:when test="m:section/m:texts[m:filter[@max-pages or @section-id]]">
                                                    
                                                    <xsl:variable name="count-section-filters" select="count(m:section/m:texts/m:filter[@section-id])"/>
                                                    
                                                    <p class="text-muted small">
                                                        <xsl:value-of select="'Currently showing texts'"/>
                                                        <xsl:if test="m:section/m:texts/m:filter[@max-pages]">
                                                            <xsl:value-of select="concat(' up to ', m:section/m:texts/m:filter[@max-pages][1]/@max-pages, ' pages')"/>
                                                        </xsl:if>
                                                        <xsl:if test="$count-section-filters gt 0">
                                                            <xsl:value-of select="concat(' from ', $count-section-filters, ' selected section', if($count-section-filters gt 1) then 's' else '')"/>
                                                        </xsl:if>
                                                    </p>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <p class="text-muted small">
                                                        <xsl:value-of select="'Further options for filtering the published translations'"/>
                                                    </p>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                    </div>
                                </a>
                                
                            </div>
                        </div>
                    </xsl:if>
                    
                    <!-- Tab content -->
                    <div class="tab-content">
                        
                        <!-- Sections -->
                        <xsl:if test="not($section-id = ('all-translated'))">
                            <div role="tabpanel" id="sections">
                                
                                <xsl:variable name="css-class" as="xs:string*">
                                    <xsl:value-of select="'tab-pane fade'"/>
                                    <xsl:if test="m:section/m:section[not(@type eq 'grouping')]">
                                        <xsl:value-of select="'in active'"/>
                                    </xsl:if>
                                    <xsl:if test="not(m:section/m:section[not(@type eq 'grouping')])">
                                        <xsl:value-of select="'hidden'"/>
                                    </xsl:if>
                                    <xsl:value-of select="'print-collapse-override'"/>
                                </xsl:variable>
                                
                                <xsl:attribute name="class" select="string-join($css-class, ' ')"/>
                                
                                <xsl:call-template name="sub-sections">
                                    <xsl:with-param name="section" select="m:section"/>
                                </xsl:call-template>
                                
                            </div>
                        </xsl:if>
                        
                        <!-- Summary -->
                        <xsl:if test="m:section/m:about[*]">
                            <div role="tabpanel" id="summary">
                                
                                <xsl:variable name="css-class" as="xs:string*">
                                    <xsl:value-of select="'tab-pane fade'"/>
                                    <xsl:value-of select="'print-collapse-override'"/>
                                </xsl:variable>
                                
                                <xsl:attribute name="class" select="string-join($css-class, ' ')"/>
                                
                                <div class="row">
                                    <div class="col-md-offset-2 col-md-8 text-left">
                                        <xsl:apply-templates select="m:section/m:about/*"/>
                                    </div>
                                </div>
                                
                            </div>
                        </xsl:if>
                        
                        <!-- All texts -->
                        <div role="tabpanel" id="texts">
                            
                            <xsl:variable name="css-class" as="xs:string*">
                                <xsl:value-of select="'tab-pane fade'"/>
                                <xsl:if test="$show-texts">
                                    <xsl:value-of select="'in active'"/>
                                </xsl:if>
                                <xsl:if test="not($show-texts)">
                                    <xsl:value-of select="'hidden'"/>
                                </xsl:if>
                                <xsl:value-of select="'print-collapse-override'"/>
                            </xsl:variable>
                            
                            <xsl:attribute name="class" select="string-join($css-class, ' ')"/>
                            
                            <xsl:call-template name="section-texts">
                                <xsl:with-param name="section" select="m:section"/>
                                <xsl:with-param name="filter" select="$selected-filter"/>
                            </xsl:call-template>
                            
                        </div>
                        
                        <!-- Print footer -->
                        <div class="visible-print-block">
                            <div class="small italic text-center">
                                <xsl:value-of select="concat('~ ', common:date-user-string('Page generated', current-dateTime(), /m:response/@user-name), ' ~')"/>
                            </div>
                        </div>
                        
                    </div>
                    
                    <hr class="hidden-print"/>
                    
                    <!-- Footer options -->
                    <div class="row hidden-print">
                        <div class="col-md-offset-2 col-md-8">
                            <div class="row">
                                <div class="col-sm-4 bottom-margin-xs">
                                    <a class="text-success center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', /m:response/@lang)"/>
                                        <span class="btn-round green sml">
                                            <i class="fa fa-search"/>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Search the Reading Room'"/>
                                        </span>
                                    </a>
                                </div>
                                <div class="col-sm-4 bottom-margin-xs">
                                    <a class="text-danger center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                        <span class="btn-round red sml">
                                            <i class="fa fa-list"/>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'All Published Translations'"/>
                                        </span>
                                    </a>
                                </div>
                                <div class="col-sm-4 bottom-margin-xs">
                                    <a href="http://84000.co/how-you-can-help/donate/#sap" class="center-vertical">
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
                    
                </div>
            </div>
            
            <!-- Ebook help modal -->
            <div class="modal fade hidden-print" tabindex="-1" role="dialog" id="ebook-help" aria-labelledby="ebook-help-label">
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
            
            <!-- Filters sidebar -->
            <xsl:if test="$filters">
                <div id="filters-sidebar" class="fixed-sidebar collapse width hidden-print">
                    
                    <div class="fix-width">
                        
                        <div class="sidebar-content">
                            
                            <xsl:if test="$sidebar-filters">
                                
                                <h5>
                                    <xsl:value-of select="'Pre-configured filters'"/>
                                </h5>
                                
                                <div class="filter-panel">
                                    
                                    <div class="center-vertical full-width">
                                        
                                        <a>
                                            <xsl:attribute name="href" select="concat(lower-case(m:section/@id), '.html', '#section-content')"/>
                                            <xsl:attribute name="data-ajax-target" select="'#section-content'"/>
                                            <xsl:attribute name="id" select="concat(m:section/@id, '-filter-label')"/>
                                            <xsl:value-of select="'All Published Translations (no filter)'"/>
                                        </a>
                                        
                                    </div>
                                </div>
                        
                                <xsl:for-each select="$sidebar-filters">
                                    <xsl:variable name="filter" select="."/>
                                    
                                    <div class="filter-panel">
                                        
                                        <xsl:if test="/m:response/m:request[@filter-id eq $filter/@xml:id]">
                                            <xsl:attribute name="class" select="'filter-panel active'"/>
                                        </xsl:if>
                                        
                                        <div class="center-vertical full-width">
                                            
                                            <a>
                                                <xsl:attribute name="href" select="concat(lower-case(/m:response/m:section/@id), '.html', '?filter-id=', $filter/@xml:id, '#section-content')"/>
                                                <xsl:attribute name="data-ajax-target" select="'#section-content'"/>
                                                <xsl:attribute name="id" select="concat($filter/@xml:id, '-filter-label')"/>
                                                <xsl:value-of select="$filter/tei:head[@type eq 'filter']"/>
                                            </a>
                                            
                                            <xsl:if test="$filter[tei:p]">
                                                <span class="text-right">
                                                    <a role="button" data-toggle="collapse" data-parent="#accordion" aria-expanded="false">
                                                        
                                                        <xsl:attribute name="href" select="concat('#', $filter/@xml:id, '-filter-abstract')"/>
                                                        <xsl:attribute name="aria-controls" select="concat($filter/@xml:id, '-filter-abstract')"/>
                                                        
                                                        <i class="fa fa-plus collapsed-show"/>
                                                        <i class="fa fa-minus collapsed-hide"/>
                                                    </a>
                                                </span>
                                            </xsl:if>
                                            
                                        </div>
                                        
                                        <xsl:if test="$filter[tei:p]">
                                            <div class="collapse" role="tabpanel" aria-expanded="false">
                                                <xsl:attribute name="id" select="concat($filter/@xml:id, '-filter-abstract')"/>
                                                <xsl:attribute name="aria-labelledby" select="concat($filter/@xml:id, '-filter-label')"/>
                                                <div class="small text-muted sml-margin top bottom">
                                                    <xsl:apply-templates select="$filter/tei:p"/>
                                                </div>
                                            </div>
                                        </xsl:if>
                                        
                                    </div>
                                </xsl:for-each>
                                
                            </xsl:if>
                            
                            <form method="get" class="form-horizontal top-margin bottom-margin" data-ajax-target="#section-content">
                                
                                <xsl:attribute name="action" select="concat(lower-case(m:section/@id), '.html')"/>
                                
                                <input type="hidden" name="translations-order">
                                    <xsl:attribute name="value" select="/m:response/m:request/@translations-order"/>
                                </input>
                                
                                <h5>
                                    <xsl:value-of select="'Sections with Published Translations'"/>
                                </h5>
                                
                                <div class="bottom-margin">
                                    
                                    <div id="section-checkbox" class="loading">
                                        <!-- Project Progress, get from ajax -->
                                        <xsl:attribute name="data-onload-replace">
                                            <xsl:choose>
                                                <xsl:when test="$lang eq 'zh'">
                                                    <xsl:value-of select="concat('{&#34;#section-checkbox&#34;:&#34;', $reading-room-path,'/widget/section-checkbox.html?lang=', $lang ,'#section-checkbox&#34;}')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat('{&#34;#section-checkbox&#34;:&#34;', $reading-room-path,'/widget/section-checkbox.html#section-checkbox&#34;}')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                    </div>
                                    
                                </div>
                                
                                <h5>
                                    <xsl:value-of select="'Filter by number of pages'"/>
                                </h5>
                                
                                <div class="form-group">
                                    <label for="filter-max-pages" class="col-sm-3 control-label text-left">
                                        <xsl:value-of select="'Max. pages'"/>
                                    </label>
                                    <div class="col-sm-3">
                                        <input type="number" name="filter-max-pages" class="form-control" id="filter-max-pages">
                                            <xsl:attribute name="value" select="m:request/m:filter[@max-pages][1]/@max-pages"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-6">
                                        <button type="submit" class="btn btn-primary pull-right">
                                            <xsl:value-of select="'Apply'"/>
                                        </button>
                                    </div>
                                </div>
                            </form>
                            
                        </div>
                    </div>
                    
                    <div class="fixed-btn-container close-btn-container right">
                        <button type="button" class="btn-round close close-collapse" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                    </div>
                    
                </div>
            </xsl:if>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('https://read.84000.co/section/', m:section/@id, '.html')"/>
            <xsl:with-param name="page-class" select="'reading-room section'"/>
            <xsl:with-param name="page-title" select="concat(m:section/m:titles/m:title[@xml:lang = 'en'], ' | 84000 Reading Room')"/>
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
                    
                    <xsl:if test="$section/m:titles/m:title[@xml:lang = 'bo']/text() or $section/m:titles/m:title[@xml:lang = 'Bo-Ltn']/text()">
                        <hr/>
                        <h4>
                            <span class="text-bo">
                                <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'bo'])"/>
                            </span>
                            <xsl:if test="$section/m:titles/m:title[@xml:lang = 'Bo-Ltn']/text()">
                                <xsl:value-of select="' · '"/>
                                <span class="text-wy">
                                    <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'Bo-Ltn'])"/>
                                </span>
                            </xsl:if>
                        </h4>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:titles/m:title[@xml:lang = 'Sa-Ltn']/text()">
                        <hr/>
                        <h4 class="text-sa">
                            <xsl:value-of select="normalize-space($section/m:titles/m:title[@xml:lang = 'Sa-Ltn'])"/>
                        </h4>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:abstract/*">
                        <hr/>
                        <div id="abstract">
                            <xsl:apply-templates select="$section/m:abstract/*"/>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:warning/tei:p">
                        <div class="top-margin">
                            <xsl:call-template name="tantra-warning">
                                <xsl:with-param name="id" select="'title'"/>
                                <xsl:with-param name="node" select="$section/m:warning"/>
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                    
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="section-texts">
        
        <xsl:param name="section"/>
        <xsl:param name="filter" as="element(tei:div)*"/>
        
        <div class="text-list">
            
            <!-- Row headers -->
            <div class="row table-headers hidden-print">
                
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
                    <form method="get" class="filter-form col-sm-pull-right hidden-print" data-ajax-target="#section-content">
                        
                        <xsl:attribute name="action" select="concat(lower-case($section/@id), '.html')"/>
                        
                        <xsl:if test="$filter">
                            <input type="hidden" name="filter-id">
                                <xsl:attribute name="value" select="$filter/@xml:id"/>
                            </input>
                        </xsl:if>
                        
                        <xsl:for-each select="$section/m:texts/m:filter[@section-id]">
                            <input type="hidden" name="filter-section-id[]">
                                <xsl:attribute name="value" select="@section-id"/>
                            </input>
                        </xsl:for-each>
                        
                        <xsl:if test="$section/m:texts/m:filter[@max-pages]">
                            <input type="hidden" name="filter-max-pages">
                                <xsl:attribute name="value" select="$section/m:texts/m:filter[@max-pages][1]/@max-pages"/>
                            </input>
                        </xsl:if>
                        
                        <xsl:choose>
                            <xsl:when test="lower-case($section/@id) eq 'all-translated'">
                                
                                <!-- Form to sort translated -->
                                <div class="form-group no-bottom-margin">
                                    <label class="sr-only">
                                        <xsl:value-of select="'Sort translations'"/>
                                    </label>
                                    <select name="translations-order" class="form-control">
                                        <option value="toh">
                                            <xsl:if test="/m:response/m:request/@translations-order eq 'toh'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Sort by Tohoku number'"/>
                                        </option>
                                        <option value="latest">
                                            <xsl:if test="/m:response/m:request/@translations-order eq 'latest'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Most recent publications'"/>
                                        </option>
                                        <option value="shortest">
                                            <xsl:if test="/m:response/m:request/@translations-order eq 'shortest'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Shortest first'"/>
                                        </option>
                                        <option value="longest">
                                            <xsl:if test="/m:response/m:request/@translations-order eq 'longest'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Longest first'"/>
                                        </option>
                                    </select>
                                </div>
                                
                            </xsl:when>
                            <xsl:otherwise>
                                
                                <!-- Form to filter translated -->
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" name="published-only" value="1">
                                            <xsl:if test="m:section/m:texts/@published-only eq '1'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="'Published translations only'"/>
                                    </label>
                                </div>
                                
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </form>
                
                </div>
            </div>
            
            <!-- Print title -->
            <xsl:if test="$section/m:texts[m:text]">
                <div class="visible-print-block">
                    <xsl:choose>
                        <xsl:when test="$filter">
                            <div class="well">
                                <h4 class="underline no-top-margin">
                                    <xsl:value-of select="'Filter:'"/>
                                </h4>
                                <h2>
                                    <xsl:value-of select="tei:head[@type eq 'filter']"/>
                                </h2>
                                <xsl:apply-templates select="$filter"/>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <h2>
                                <xsl:value-of select="'Texts in this Section'"/>
                            </h2>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:if>
            
            <!-- Print header -->
            <xsl:choose>
                <xsl:when test="lower-case($section/@id) eq 'all-translated'">
                    <div class="visible-print-block text-italic">
                        <xsl:choose>
                            <xsl:when test="/m:response/m:request/@translations-order eq 'latest'">
                                <xsl:value-of select="'Sorted by most recent publications'"/>
                            </xsl:when>
                            <xsl:when test="/m:response/m:request/@translations-order eq 'shortest'">
                                <xsl:value-of select="'Sorted by shortest first'"/>
                            </xsl:when>
                            <xsl:when test="/m:response/m:request/@translations-order eq 'longest'">
                                <xsl:value-of select="'Sorted by longest first'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'Sorted by Tohoku number'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="visible-print-block italic">
                        <xsl:choose>
                            <xsl:when test="m:section/m:texts/@published-only eq '1'">
                                <xsl:value-of select="'Listing published translations only'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'Listing all texts'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Text rows -->
            <!-- Texts can either be direct children of the section or a sub-section which is a grouping -->
            <xsl:for-each select="$section | $section/m:section[@type eq 'grouping']">
                
                <xsl:sort select="number(m:texts/m:text[1]/m:toh/@number)"/>
                
                <xsl:variable name="texts" select="m:texts/m:text"/>
                
                <div class="list-grouping">
                    
                    <!-- Change the class and add a title if they are a grouped sub-section -->
                    <xsl:if test="@nesting gt '1' and $texts">
                        <xsl:attribute name="class" select="'list-grouping border'"/>
                        <xsl:attribute name="id" select="concat('grouping-', @id)"/>
                        <div class=" text-center bottom-margin">
                            <xsl:call-template name="section-title">
                                <xsl:with-param name="section" select="."/>
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                    
                    <!-- loop through the texts -->
                    <xsl:for-each select="$texts">
                        
                        <xsl:sort select="if(/m:response/m:request/@translations-order eq 'latest' and m:publication/m:publication-date) then xs:date(m:publication/m:publication-date) else ''" order="descending"/>
                        <xsl:sort select="if(/m:response/m:request/@translations-order eq 'shortest' and m:source/m:location/@count-pages) then xs:integer(m:source/m:location/@count-pages) else ''" order="ascending"/>
                        <xsl:sort select="if(/m:response/m:request/@translations-order eq 'longest' and m:source/m:location/@count-pages) then xs:integer(m:source/m:location/@count-pages) else ''" order="descending"/>
                        <xsl:sort select="number(m:toh/@number)"/>
                        <xsl:sort select="m:toh/@letter"/>
                        <xsl:sort select="number(m:toh/@chapter-number)"/>
                        <xsl:sort select="m:toh/@chapter-letter"/>
                        
                        <xsl:variable name="text" select="."/>
                        <xsl:variable name="toh-key" select="$text/m:toh/@key"/>
                        
                        <div class="row list-item">
                            
                            <xsl:attribute name="id" select="@resource-id"/>
                            
                            <!-- Toh number -->
                            <div class="col-md-1">
                                
                                <xsl:value-of select="$text/m:toh/m:full"/>
                                
                                <xsl:for-each select="$text/m:toh/m:duplicates/m:duplicate">
                                    <br class="hidden-xs hidden-sm"/>
                                    <xsl:value-of select="concat(' / ', m:base)"/>
                                </xsl:for-each>
                                
                                <span class="visible-xs-inline visible-sm-inline col-sm-pull-right italic small">
                                    <xsl:choose>
                                        <xsl:when test="@status-group eq 'published'">
                                            <xsl:choose>
                                                <xsl:when test="$text/m:publication/m:publication-date/text()">
                                                    <xsl:value-of select="concat(' Published ', format-date($text/m:publication/m:publication-date, '[FNn,*-3], [D1o] [MNn,*-3] [Y]'))"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="' Published'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="@status-group eq 'translated'">
                                            <xsl:value-of select="' Translation in progress'"/>
                                        </xsl:when>
                                        <xsl:when test="@status-group eq 'in-translation'">
                                             <xsl:value-of select="' Translation in progress'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="' Translation not Started'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                                
                                <hr class="visible-xs-block visible-sm-block"/>
                                
                            </div>
                            
                            <div class="col-md-7 col-lg-8">
                                
                                <!-- English title -->
                                <h4 class="title-en">
                                    <xsl:choose>
                                        <xsl:when test="$text/m:titles/m:title[@xml:lang='en'][not(@type)]/text()">
                                            <xsl:choose>
                                                <xsl:when test="@status-group = 'published'">
                                                    <a>
                                                        <xsl:attribute name="href" select="common:internal-link(concat('/translation/', $text/m:source/@key, '.html'), (), '', /m:response/@lang)"/>
                                                        <xsl:copy-of select="normalize-space($text/m:titles/m:title[@xml:lang='en'][not(@type)])"/> 
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="normalize-space($text/m:titles/m:title[@xml:lang='en'][not(@type)])"/> 
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
                                
                                <xsl:if test="lower-case($section/@id) = 'all-translated'">
                                    
                                    <!-- Location breadcrumbs -->
                                    <xsl:variable name="parent-section" select="//m:section[@id eq $text/m:source/@parent-id]"/>
                                    <xsl:if test="$parent-section">
                                        <hr/>
                                        <div class="text-muted small">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                <xsl:if test="$parent-section">
                                                    <xsl:call-template name="section-breadcumbs">
                                                        <xsl:with-param name="section" select="$parent-section"/>
                                                    </xsl:call-template>
                                                </xsl:if>
                                            </ul>
                                        </div>
                                    </xsl:if>
                                    
                                    <!-- Tantric warning -->
                                    <xsl:if test="$text/m:publication/m:tantric-restriction/tei:p">
                                        <hr/>
                                        <xsl:call-template name="tantra-warning">
                                            <xsl:with-param name="id" select="@resource-id"/>
                                            <xsl:with-param name="node" select="$text/m:publication/m:tantric-restriction/tei:p"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                </xsl:if>
                                
                                <!-- Tibetan title -->
                                <xsl:if test="$text/m:titles/m:title[@xml:lang = 'bo']/text()">
                                    <hr/>
                                    <span class="text-bo">
                                        <xsl:value-of select="normalize-space($text/m:titles/m:title[@xml:lang = 'bo'])"/>
                                    </span>
                                </xsl:if>
                                
                                <!-- Wylie title -->
                                <xsl:if test="$text/m:titles/m:title[@xml:lang = 'Bo-Ltn'][text()]">
                                    <xsl:choose>
                                        <xsl:when test="normalize-space($text/m:titles/m:title[@xml:lang = 'bo'])">
                                           <xsl:value-of select="' · '"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <hr/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <span class="text-wy">
                                        <xsl:value-of select="normalize-space($text/m:titles/m:title[@xml:lang = 'Bo-Ltn'])"/>
                                    </span>
                                </xsl:if>
                                
                                <!-- Sanskrit title -->
                                <xsl:if test="$text/m:titles/m:title[@xml:lang = 'Sa-Ltn'][text()]">
                                    <hr/>
                                    <span class="text-sa">
                                        <xsl:value-of select="normalize-space($text/m:titles/m:title[@xml:lang = 'Sa-Ltn'])"/> 
                                    </span>
                                </xsl:if>
                                
                                <!-- Summary and title variants -->
                                <xsl:if test="$text/m:section[@type eq 'summary'][tei:p] or $text/m:title-variants/m:title[text()]">
                                    
                                    <hr class="hidden-print"/>
                                    
                                    <a class="summary-link collapsed hidden-print" role="button" data-toggle="collapse" aria-expanded="false">
                                        <xsl:attribute name="href" select="concat('#summary-detail-', $toh-key)"/>
                                        <xsl:attribute name="aria-controls" select="concat('summary-detail-', $toh-key)"/>
                                        <i class="fa fa-chevron-down"/>
                                        <xsl:value-of select="' Summary &amp; variant titles'"/>
                                    </a>
                                    
                                    <div class="collapse summary-detail print-collapse-override">
                                        <xsl:attribute name="id" select="concat('summary-detail-', $toh-key)"/>
                                        <div class="well well-sm">
                                            
                                            <xsl:if test="$text/m:section[@type eq 'summary'][tei:p]">
                                                <h4>
                                                    <xsl:value-of select="'Summary'"/>
                                                </h4>
                                                <xsl:apply-templates select="$text/m:section[@type eq 'summary']/tei:p"/>
                                            </xsl:if>
                                            
                                            <xsl:if test="$text/m:title-variants/m:title[text()]">
                                                <h4>
                                                    <xsl:value-of select="'Title variants'"/>
                                                </h4>
                                                <ul class="list-unstyled">
                                                    <xsl:attribute name="id" select="concat($toh-key, '-title-variants')"/>
                                                    <xsl:for-each select="$text/m:title-variants/m:title">
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
                            <div class="col-md-4 col-lg-3 hidden-print">
                                
                                <hr class="visible-xs visible-sm sml-margin"/>
                                
                                <div class="small text-warning sml-margin bottom">
                                    <xsl:call-template name="text-page-count"/>
                                </div>
                                
                                <xsl:choose>
                                    <xsl:when test="@status-group eq 'published'">
                                        
                                        <xsl:if test="m:publication/m:publication-date[text()]">
                                            <div class="hidden-xs hidden-sm text-success small italic sml-margin bottom">
                                                <xsl:value-of select="concat('Published ', format-date(m:publication/m:publication-date, '[FNn,*-3], [D1o] [MNn,*-3] [Y]'))"/>
                                            </div>
                                        </xsl:if>
                                        
                                        <hr class="visible-xs visible-sm sml-margin"/>
                                        
                                        <ul class="translation-links">
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
                                                                <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $toh-key), '#dana-description', /m:response/@lang)"/>
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
                                                <li class="hidden-print">
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
                
                    <!-- No texts -->
                    <xsl:if test="not($texts)">
                        <p class="top-margin text-center text-muted italic">
                            <xsl:value-of select="'No published translations found with this filter'"/>
                        </p>
                    </xsl:if>
                </div>
            
            </xsl:for-each>
        
        </div>
    
    </xsl:template>
    
    <xsl:template name="sub-sections">
        <xsl:param name="section"/>
        
        <xsl:variable name="count-sections" select="count($section/m:section[not(@type eq 'grouping')])"/>
        
        <div class="row sections">
            
            <xsl:if test="m:section/m:section[not(@type eq 'grouping')]">
                <h2 class="visible-print-block">
                    <xsl:value-of select="'Sub-sections'"/>
                </h2>
            </xsl:if>
            
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
                        
                        <xsl:attribute name="class" select="normalize-space(string-join(($col-offset-2, $col-offset-3, $col-offset-4, 'print-centered-margins'), ' '))"/>
                        
                        <div class="section-panel">
                            
                            <xsl:if test="@type eq 'pseudo-section'">
                                <xsl:attribute name="class" select="'section-panel pseudo-section'"/>
                            </xsl:if>
                            
                            <div data-match-height="outline-section" data-match-height-media=".sm,.md,.lg">
                                
                                <a target="_self" class="block-link printable">
                                    <xsl:attribute name="href" select="common:internal-link(concat('/section/', @id/string(), '.html'), (), '', /m:response/@lang)"/>
                                    <h3>
                                        <xsl:value-of select="m:titles/m:title[@xml:lang='en']/text()"/> 
                                    </h3>
                                    <xsl:if test="m:titles/m:title[@xml:lang='bo']/text()">
                                        <h4 class="text-bo">
                                            <xsl:value-of select="m:titles/m:title[@xml:lang='bo']/text()"/>
                                        </h4>
                                    </xsl:if>
                                    <xsl:if test="m:titles/m:title[@xml:lang='Bo-Ltn']/text()">
                                        <h4 class="text-wy">
                                            <xsl:value-of select="m:titles/m:title[@xml:lang='Bo-Ltn']/text()"/>
                                        </h4>
                                    </xsl:if>
                                    <xsl:if test="m:titles/m:title[@xml:lang='Sa-Ltn']/text()">
                                        <h4 class="text-sa">
                                            <xsl:value-of select="m:titles/m:title[@xml:lang='Sa-Ltn']/text()"/>
                                        </h4>
                                    </xsl:if>
                                </a>
                                
                                <div class="notes">
                                    <xsl:apply-templates select="m:abstract/*"/>
                                </div>
                                
                                <xsl:if test="m:warning/tei:p">
                                    <div class="sml-margin top">
                                        <xsl:call-template name="tantra-warning">
                                            <xsl:with-param name="id" select="$sub-section-id"/>
                                            <xsl:with-param name="node" select="m:warning"/>
                                        </xsl:call-template>
                                    </div>
                                </xsl:if>
                                
                            </div>
                            
                            <div class="footer">
                                <xsl:variable name="count-texts" as="xs:integer" select="$section/m:section[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-text-descendants']/@value"/>
                                <xsl:variable name="count-published" as="xs:integer" select="$section/m:section[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-published-descendants']/@value"/>
                                <xsl:variable name="count-in-progress" as="xs:integer" select="$section/m:section[@id eq $sub-section-id]/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/@value"/>
                                <table class="table print-centered-margins">
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
        </div>
    </xsl:template>
    
    <xsl:template name="tantra-warning">
        <xsl:param name="id"/>
        <xsl:param name="node"/>
        
        <div class="hidden-print">
            
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
            
        </div>
        
        <div class="visible-print-block small">
            <xsl:apply-templates select="$node"/>
        </div>
        
    </xsl:template>
    
    <xsl:template name="text-page-count">
        <xsl:value-of select="format-number(m:source/m:location/@count-pages, '#,###')"/>
        <xsl:choose>
            <xsl:when test="m:source/m:location/@work eq 'UT4CZ5369'">
                <xsl:value-of select="' pages of the Degé Kangyur'"/>
            </xsl:when>
            <xsl:when test="m:source/m:location/@work eq 'UT23703'">
                <xsl:value-of select="' pages of the Degé Tengyur'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="section-breadcumbs">
        
        <xsl:param name="section"/>
        
        <xsl:variable name="parent-section" select="$section/parent::m:section"/>
        
        <xsl:if test="$parent-section and not($parent-section[@id eq 'ALL-TRANSLATED'])">
            <xsl:call-template name="section-breadcumbs">
                <xsl:with-param name="section" select="$parent-section"/>
            </xsl:call-template>
        </xsl:if>
        
        <li>
            <a class="printable">
                <xsl:choose>
                    <xsl:when test="@type eq 'grouping'">
                        <xsl:attribute name="href" select="common:internal-link(concat('/section/', $section/@id, '.html'), (), concat('#grouping-', @id), /m:response/@lang)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href" select="common:internal-link(concat('/section/', $section/@id, '.html'), (), '', /m:response/@lang)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="$section/m:titles/m:title[@xml:lang='en']/text()"/>
            </a>
        </li>
    </xsl:template>
    
</xsl:stylesheet>