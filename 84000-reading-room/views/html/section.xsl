<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    <xsl:include href="website-page.xsl"/>
    
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
                                        <a href="/section/lobby.html">
                                            The Lobby
                                        </a>
                                    </li>
                                </xsl:if>
                                
                                <xsl:for-each select="m:section/m:parent | m:section/m:parent//m:parent">
                                    <xsl:sort select="@nesting" order="descending"/>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat('/section/', @id/string(), '.html')"/>
                                            <xsl:value-of select="m:title[@xml:lang='en']/text()"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </span>
                        
                        <span>
                            
                            <div class="pull-right center-vertical">
                                
                                <xsl:if test="not($section-id eq 'all-translated')">
                                    
                                    <a href="/section/all-translated.html" class="center-vertical together">
                                        <span>
                                            <span class="btn-round white-red sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            View Translated Texts
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
                                                Bookmarks
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
                            
                            <div class="row">
                                <div class="col-xs-12 col-md-offset-2 col-md-8">
                                    
                                    <!-- stats -->
                                    <xsl:if test="not($section-id = ('lobby', 'all-translated'))">
                                        <xsl:variable name="count-texts" select="m:section/m:text-stats/m:stat[@type eq 'count-text-descendants']/number()"/>
                                        <xsl:variable name="count-published" select="m:section/m:text-stats/m:stat[@type eq 'count-published-descendants']/number()"/>
                                        <xsl:variable name="count-in-progress" select="m:section/m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/number()"/>
                                        <table class="table table-stats">
                                            <tbody>
                                                <tr>
                                                    <td>
                                                        Texts: <xsl:value-of select="format-number($count-texts, '#,###')"/>
                                                    </td>
                                                    <td>
                                                        Translated: <xsl:value-of select="format-number($count-published, '#,###')"/>
                                                    </td>
                                                    <td>
                                                        In Progress: <xsl:value-of select="format-number($count-in-progress, '#,###')"/>
                                                    </td>
                                                    <td>
                                                        Not Begun: <xsl:value-of select="format-number($count-texts - ($count-published + $count-in-progress), '#,###')"/>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </xsl:if>
                                    
                                    <xsl:if test="$section-id = 'all-translated'">
                                        <table class="table table-stats">
                                            <tbody>
                                                <tr>
                                                    <td>
                                                        Translated: <xsl:value-of select="format-number(count(m:section/m:texts/m:text), '#,###')"/>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </xsl:if>
                                    
                                </div>
                            </div>
                            
                        </div>
                        
                        <xsl:variable name="show-texts" select="(m:section/m:texts/m:text or m:section/m:sections/m:section/m:texts/m:text or m:section/m:texts/@published-only eq '1')"/>
                        
                        <!-- Content tabs (sections/texts/summary) -->
                        <xsl:if test="not($section-id = ('lobby', 'all-translated')) and (m:section/m:texts/m:text or m:section/m:texts/@published-only eq '1' or m:section/m:sections/m:section or m:section/m:summary/text())">
                            <div class="tabs-container-center">
                                <ul class="nav nav-tabs" role="tablist">
                                    
                                    <xsl:if test="$show-texts">
                                        <li role="presentation" class="active">
                                            <a href="#texts" aria-controls="texts" role="tab" data-toggle="tab">Texts</a>
                                        </li>
                                    </xsl:if>
                                    
                                    <xsl:if test="m:section/m:sections/m:section">
                                        <li role="presentation">
                                            <xsl:attribute name="class" select="if(not($show-texts)) then 'active' else ''"/>
                                            <a href="#sections" aria-controls="sections" role="tab" data-toggle="tab">Sections</a>
                                        </li>
                                    </xsl:if>
                                    
                                    <xsl:if test="m:section/m:about/*">
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
                            <div role="tabpanel" id="texts">
                                
                                <xsl:variable name="texts-class">
                                    <xsl:choose>
                                        <xsl:when test="$show-texts">
                                            tab-pane fade in active
                                        </xsl:when>
                                        <xsl:otherwise>
                                            hidden
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:attribute name="class" select="normalize-space($texts-class)"/>
                                
                                <div class="text-list">
                                    
                                    <div class="row table-headers">
                                        
                                        <div class="col-sm-1 hidden-xs">Toh</div>
                                        <div class="col-sm-7 col-md-8">Title</div>
                                        <div class="col-xs-12 col-sm-4 col-md-3">
                                            
                                            <!-- Filter translated -->
                                            <form action="" method="post" class="filter-form">
                                                
                                                <xsl:if test="$section-id eq 'all-translated'">
                                                    <xsl:attribute name="class" select="'filter-form hidden'"/>
                                                </xsl:if>
                                                
                                                <div class="checkbox">
                                                    <label>
                                                        <input type="checkbox" name="published-only" value="1">
                                                            <xsl:if test="m:section/m:texts/@published-only eq '1'">
                                                                <xsl:attribute name="checked" select="'checked'"/>
                                                            </xsl:if>
                                                        </input>
                                                        Translated texts only
                                                    </label>
                                                </div>
                                                
                                            </form>
                                        
                                        </div>
                                        
                                    </div>
                                    
                                    <xsl:for-each select="m:section | m:section/m:sections/m:section">
                                        <xsl:sort select="number(m:texts/m:text[1]/m:toh/@number)"/>
                                        <div class="list-section">
                                            
                                            <xsl:if test="parent::m:sections and m:texts/m:text">
                                                <xsl:attribute name="class" select="'list-section border'"/>
                                                
                                                <xsl:call-template name="section-title">
                                                    <xsl:with-param name="section" select="."/>
                                                </xsl:call-template>
                                                
                                            </xsl:if>
                                            
                                            <xsl:for-each select="m:texts/m:text">
                                                <xsl:sort select="number(m:toh/@number)"/>
                                                <xsl:sort select="m:toh/@letter"/>
                                                <xsl:sort select="number(m:toh/@chapter-number)"/>
                                                <xsl:sort select="m:toh/@chapter-letter"/>
                                                <div class="row list-item">
                                                    
                                                    <div class="col-sm-1">
                                                        
                                                        <span class="visible-xs-inline">Toh </span>
                                                        
                                                        <xsl:value-of select="m:toh/m:full"/>
                                                        
                                                        <hr class="visible-xs-block"/>
                                                        
                                                    </div>
                                                    
                                                    <div class="col-sm-7 col-md-8">
                                                        
                                                        <h4 class="title-en">
                                                            <xsl:choose>
                                                                <xsl:when test="m:titles/m:title[@xml:lang='en'][not(@type)]/text()">
                                                                    <xsl:choose>
                                                                        <xsl:when test="@status = '1'">
                                                                            <a>
                                                                                <xsl:attribute name="href" select="concat('/translation/', m:source/@key, '.html')"/> 
                                                                                <xsl:copy-of select="m:titles/m:title[@xml:lang='en'][not(@type)]/text()"/> 
                                                                            </a>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:copy-of select="m:titles/m:title[@xml:lang='en'][not(@type)]/text()"/> 
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <em class="text-muted">
                                                                        Awaiting English title
                                                                    </em>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </h4>
                                                        
                                                        <xsl:if test="$section-id = 'all-translated'">
                                                            <hr/>
                                                            in
                                                            <ul class="breadcrumb">
                                                                <xsl:for-each select="m:parent | m:parent//m:parent">
                                                                    <xsl:sort select="@nesting" order="descending"/>
                                                                    <li>
                                                                        <a>
                                                                            <xsl:attribute name="href" select="concat('/section/', @id/string(), '.html')"/>
                                                                            <xsl:value-of select="m:title[@xml:lang='en']/text()"/>
                                                                        </a>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="m:titles/m:title[@xml:lang='bo']/text()">
                                                            <hr/>
                                                            <span class="text-bo">
                                                                <xsl:value-of select="m:titles/m:title[@xml:lang='bo']/text()"/>
                                                            </span>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="m:titles/m:title[@xml:lang='bo-ltn']/text()">
                                                            <xsl:choose>
                                                                <xsl:when test="m:titles/m:title[@xml:lang='bo']/text()">
                                                                    · 
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <hr/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            <span class="text-wy">
                                                                <xsl:value-of select="m:titles/m:title[@xml:lang='bo-ltn']/text()"/>
                                                            </span>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="m:titles/m:title[@xml:lang='sa-ltn']/text()">
                                                            <hr/>
                                                            <span class="text-sa">
                                                                <xsl:value-of select="m:titles/m:title[@xml:lang='sa-ltn']/text()"/> 
                                                            </span>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="m:summary/tei:p or m:title-variants/m:title/text()">
                                                            
                                                            <hr/>
                                                            
                                                            <a class="summary-link collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                                                                <xsl:attribute name="href" select="concat('#summary-detail-', position())"/>
                                                                <xsl:attribute name="aria-controls" select="concat('summary-detail-', position())"/>
                                                                <i class="fa fa-chevron-down"/> Summary &amp; variant titles
                                                            </a>
                                                            
                                                            <div class="collapse summary-detail">
                                                                
                                                                <xsl:attribute name="id" select="concat('summary-detail-', position())"/>
                                                                
                                                                <div class="well well-sm">
                                                                    
                                                                    <xsl:if test="m:summary/tei:p">
                                                                        <h4>Summary</h4>
                                                                        <xsl:apply-templates select="m:summary/tei:p"/>
                                                                    </xsl:if>
                                                                    
                                                                    <xsl:if test="m:title-variants/m:title/text()">
                                                                        <h4>Title variants</h4>
                                                                        <ul class="list-unstyled">
                                                                            <xsl:for-each select="m:title-variants/m:title">
                                                                                <li>
                                                                                    <xsl:attribute name="class" select="common:lang-class(@xml:lang)"/>
                                                                                    <xsl:value-of select="text()"/>
                                                                                </li>
                                                                            </xsl:for-each>
                                                                        </ul>
                                                                    </xsl:if>
                                                                    
                                                                </div>
                                                            </div>
                                                            
                                                        </xsl:if>
                                                        
                                                        <hr class="visible-xs-block"/>
                                                        
                                                    </div>
                                                    
                                                    <div class="col-sm-4 col-md-3 position-static">
                                                        
                                                        <xsl:if test="$section-id ne 'all-translated'">
                                                            <div class="translation-status">
                                                                <xsl:choose>
                                                                    <xsl:when test="@status eq '1'">
                                                                        <div class="label label-success visible-xs-inline">
                                                                            Translated
                                                                        </div>
                                                                    </xsl:when>
                                                                    <xsl:when test="@status gt ''">
                                                                        <div class="label label-warning">
                                                                            In progress
                                                                        </div>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <div class="label label-default">
                                                                            Not Started
                                                                        </div>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="@status eq '1'">
                                                            <ul class="translation-options">
                                                                <li>
                                                                    <a>
                                                                        <xsl:attribute name="href" select="concat('/translation/', m:source/@key, '.html')"/>
                                                                        <i class="fa fa-laptop"/>
                                                                        Read online
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
                            
                            </div>
                            
                            <!-- Sections -->
                            <div role="tabpanel" id="sections">
                                
                                <xsl:variable name="sections-class">
                                    <xsl:choose>
                                        <xsl:when test="$show-texts">tab-pane fade</xsl:when>
                                        <xsl:when test="m:section/m:sections/m:section">tab-pane fade in active</xsl:when>
                                        <xsl:otherwise>hidden</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:attribute name="class" select="normalize-space($sections-class)"/>
                                
                                <div class="row sections">
                                    
                                    <!-- Sub-sections -->
                                    <xsl:variable name="count-sections" select="count(m:section/m:sections/m:section)"/>
                                    <xsl:for-each select="m:section/m:sections/m:section">
                                        <xsl:sort select="number(@sort-index)"/>
                                        <xsl:variable name="child-id" select="@id"/>
                                        <div>
                                            
                                            <xsl:variable name="col-offset-2">
                                                <xsl:choose>
                                                    <xsl:when test="($count-sections mod 2) eq 1 and (position() mod 2) eq 1 and position() &gt; ($count-sections - 2)">
                                                        <!-- 1 left over in rows of 2 -->
                                                        col-sm-6 col-sm-offset-3
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        col-sm-6 col-sm-offset-0
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
                                                                        col-md-4 col-md-offset-2
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        col-md-4 col-md-offset-0
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                            <xsl:when test="($count-sections mod 3) eq 1">
                                                                <!-- 1 left over -->
                                                                <xsl:choose>
                                                                    <xsl:when test="(position() mod 3) eq 1">
                                                                        <!-- first in the row -->
                                                                        col-md-4 col-md-offset-4
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        col-md-4 col-md-offset-0
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <!-- 0 left over -->
                                                                col-md-4 col-md-offset-0
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <!-- Not in the last row -->
                                                        col-md-4 col-md-offset-0
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
                                                                col-lg-4 col-lg-offset-0
                                                            </xsl:when>
                                                            <xsl:when test="($count-sections mod 4) eq 2">
                                                                <!-- 2 left over -->
                                                                <xsl:choose>
                                                                    <xsl:when test="(position() mod 4) eq 1">
                                                                        <!-- first in the row -->
                                                                        col-lg-4 col-lg-offset-2
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        col-lg-4 col-lg-offset-0
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                            <xsl:when test="($count-sections mod 4) eq 1">
                                                                <!-- 1 left over -->
                                                                <xsl:choose>
                                                                    <xsl:when test="(position() mod 4) eq 1">
                                                                        <!-- first in the row -->
                                                                        col-lg-4 col-lg-offset-4
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        col-lg-4 col-lg-offset-0
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <!-- 0 left over -->
                                                                col-lg-3 col-lg-offset-0
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <!-- Not in the last row -->
                                                        col-lg-3 col-lg-offset-0
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            
                                            <xsl:attribute name="class" select="normalize-space(concat($col-offset-2, ' ', $col-offset-3, ' ', $col-offset-4, ' '))"/>
                                            
                                            <div class="section-panel">
                                                
                                                <xsl:variable name="panel-class">
                                                    <xsl:choose>
                                                        <xsl:when test="@type eq 'pseudo-section'">
                                                            section-panel pseudo-section
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            section-panel
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                
                                                <xsl:attribute name="class" select="normalize-space($panel-class)"/>
                                                
                                                <div data-match-height="outline-section">
                                                    <a target="_self" class="block-link">
                                                        <xsl:attribute name="href" select="concat('/section/', @id/string(), '.html')"/> 
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
                                                        <p class="notes">
                                                            <a data-toggle="modal" class="warning">
                                                                <xsl:attribute name="href" select="concat('#tantra-warning-', $child-id)"/>
                                                                <xsl:attribute name="data-target" select="concat('#tantra-warning-', $child-id)"/>
                                                                <i class="fa fa-info-circle" aria-hidden="true"/>
                                                                Tantra Text Warning
                                                            </a>
                                                        </p>
                                                        <div class="modal fade" tabindex="-1" role="dialog">
                                                            <xsl:attribute name="id" select="concat('tantra-warning-', $child-id)"/>
                                                            <xsl:attribute name="aria-labelledby" select="concat('tantra-warning-label-', $child-id)"/>
                                                            <div class="modal-dialog" role="document">
                                                                <div class="modal-content">
                                                                    <div class="modal-header">
                                                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                            <span aria-hidden="true">
                                                                                <i class="fa fa-times"/>
                                                                            </span>
                                                                        </button>
                                                                        <h4 class="modal-title">
                                                                            <xsl:attribute name="id" select="concat('tantra-warning-label-', $child-id)"/>
                                                                            Tantra Text Warning
                                                                        </h4>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <xsl:apply-templates select="m:warning"/>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </xsl:if>
                                                    
                                                </div>
                                                
                                                <div class="footer">
                                                    <xsl:variable name="count-texts" select="m:text-stats/m:stat[@type eq 'count-text-descendants']/number()"/>
                                                    <xsl:variable name="count-published" select="m:text-stats/m:stat[@type eq 'count-published-descendants']/number()"/>
                                                    <xsl:variable name="count-in-progress" select="m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/number()"/>
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
                                </div>
                            </div>
                            
                            <!-- Summary -->
                            <div role="tabpanel" id="summary">
                                
                                <xsl:variable name="summary-class">
                                    <xsl:choose>
                                        <xsl:when test="m:section/m:about/*">tab-pane fade</xsl:when>
                                        <xsl:otherwise>hidden</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:attribute name="class" select="normalize-space($summary-class)"/>
                                
                                <div class="row">
                                    <div class="col-sm-offset-2 col-sm-8 text-left">
                                        <xsl:apply-templates select="m:section/m:about/*"/>
                                    </div>
                                </div>
                                
                            </div>
                            
                        </div>
                        
                        <hr/>
                        
                        <div class="row">
                            <div class="col-sm-offset-2 col-sm-8 text-center">
                                <ul class="list-inline">
                                    <li>
                                        <a href="/section/all-translated.html" class="text-danger">
                                            <span class="btn-round red sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                            View Translated Texts
                                        </a>
                                    </li>
                                    <li>
                                        <a href="http://84000.co/how-you-can-help/donate/#sap">
                                            <span class="btn-round sml">
                                                <i class="fa fa-gift"/>
                                            </span>
                                            Sponsor translation
                                        </a>
                                    </li>
                                </ul>
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
                            <xsl:copy-of select="m:app-text[@key eq 'section.ebook-help-body']/*"/>
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/section/', m:section/@id, '.html')"/>
            <xsl:with-param name="page-class" select="'section'"/>
            <xsl:with-param name="page-title" select="m:section/m:titles/m:title[@xml:lang = 'en']"/>
            <xsl:with-param name="page-description" select="normalize-space(m:section/m:abstract/tei:p[1]/text())"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="nav-tab" select="'reading-room'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="section-title">
        
        <xsl:param name="section"/>
        
        <div class="row">
            <div class="col-sm-offset-2 col-sm-8">
                <div class="title">
                    <xsl:choose>
                        <xsl:when test="lower-case($section/@id) eq 'lobby'">
                            <div>
                                <img class="logo">
                                    <xsl:attribute name="src" select="concat($front-end-path,'/imgs/logo.png')"/>
                                </img>
                            </div>
                            <h1>
                                Welcome to the Reading Room
                            </h1>
                        </xsl:when>
                        <xsl:otherwise>
                            <h1>
                                <xsl:value-of select="$section/m:titles/m:title[@xml:lang = 'en']"/>
                            </h1>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:if test="$section/m:titles/m:title[@xml:lang = 'bo']/text() or $section/m:titles/m:title[@xml:lang = 'bo-ltn']/text()">
                        <hr/>
                        <h4>
                            <span class="text-bo">
                                <xsl:value-of select="$section/m:titles/m:title[@xml:lang = 'bo']/text()"/>
                            </span>
                            <xsl:if test="$section/m:titles/m:title[@xml:lang = 'bo-ltn']/text()">
                                · 
                                <span class="text-wy">
                                    <xsl:value-of select="$section/m:titles/m:title[@xml:lang = 'bo-ltn']/text()"/>
                                </span>
                            </xsl:if>
                        </h4>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:titles/m:title[@xml:lang = 'sa-ltn']/text()">
                        <hr/>
                        <h4 class="text-sa">
                            <xsl:value-of select="$section/m:titles/m:title[@xml:lang = 'sa-ltn']/text()"/>
                        </h4>
                    </xsl:if>
                    
                    <xsl:if test="$section/m:abstract/*">
                        <hr/>
                        <xsl:apply-templates select="$section/m:abstract/*"/>
                    </xsl:if>
                    
                </div>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>