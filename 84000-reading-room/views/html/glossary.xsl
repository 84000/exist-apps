<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Set template variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>
    <xsl:variable name="selected-type" select="/m:response/m:request/m:entity-types/m:type[@selected eq 'selected']" as="element(m:type)*"/>
    <xsl:variable name="selected-term-lang" select="/m:response/m:request/m:term-langs/m:lang[@selected eq 'selected']" as="element(m:lang)?"/>
    <xsl:variable name="search-text" select="/m:response/m:request/@search" as="xs:string?"/>
    <xsl:variable name="flagged" select="/m:response/m:request/@flagged" as="xs:string?"/>
    
    <!-- Process entities data -->
    <xsl:variable name="entities-data" as="element(m:entity-data)*">
        <xsl:for-each select="$entities">
            <xsl:call-template name="entity-data">
                <xsl:with-param name="entity" select="."/>
                <xsl:with-param name="search-text" select="$search-text"/>
                <xsl:with-param name="selected-term-lang" select="$selected-term-lang/@id"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="entities-data-sorted" as="element(m:entity-data)*">
        <xsl:perform-sort select="$entities-data">
            <xsl:sort select="if(string-length($search-text) gt 1) then min(m:term[@matches]/@word-count ! xs:integer(.)) else 1"/>
            <xsl:sort select="if(string-length($search-text) gt 1) then min(m:term[@matches]/@letter-count ! xs:integer(.)) else 1"/>
            <xsl:sort select="m:term[@matches][1]/data() ! lower-case(.) ! common:standardized-sa(.) ! common:alphanumeric(.)"/>
        </xsl:perform-sort>
    </xsl:variable>
    
    <xsl:variable name="request-entity" as="element(m:entity)?" select="$entities[@xml:id eq /m:response/m:request/@entity-id]"/>
    
    <xsl:variable name="request-entity-data" as="element(m:entity-data)?" select="$entities-data[@ref eq $request-entity/@xml:id]"/>
    
    <xsl:variable name="active-tab" as="xs:string?">
        <xsl:choose>
            <xsl:when test="$request-entity-data">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$tei-editor and /m:response/m:entity-flags/m:flag[@id eq $flagged]">
                <xsl:value-of select="$flagged"/>
            </xsl:when>
            <xsl:when test="$root/m:response/m:request[@downloads eq 'downloads']">
                <xsl:value-of select="'downloads'"/>
            </xsl:when>
            <xsl:when test="string-length($search-text) eq 1">
                <xsl:value-of select="upper-case(normalize-space($search-text))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'search'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="page-title" as="xs:string">
        <xsl:choose>
            <xsl:when test="$request-entity-data">
                <xsl:value-of select="concat(normalize-space($request-entity-data/m:label[@type eq 'primary']/text()), ' - Glossary Entry')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Glossary filtered for: ', string-join(($selected-type/m:label[@type eq 'plural']/text(), $selected-term-lang/text(), $search-text ! concat('&#34;', ., '&#34;')), '; '))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="page-url" as="xs:string">
        <xsl:choose>
            <xsl:when test="$request-entity-data">
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('entity-id=', $request-entity/@xml:id)), '&amp;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('term-type[]=', string-join($selected-type/@id, ',')),concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text)), '&amp;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        
                        <nav role="navigation" aria-label="Breadcrumbs">
                            <ul class="breadcrumb">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', /m:response/@lang)"/>
                                        <xsl:value-of select="'The Collection'"/>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('glossary.html', (), '', /m:response/@lang)"/>
                                        <xsl:value-of select="'Glossary'"/>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                        
                        <div>
                            <div class="center-vertical pull-right">
                                
                                <div>
                                    <a class="center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Published Translations'"/>
                                        </span>
                                    </a>
                                </div>
                                
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
            
            <main id="combined-glossary" class="content-band">
                <div class="container">
                    
                    <!-- Page title -->
                    <div class="section-title row">
                        <div class="col-sm-offset-2 col-sm-8">
                            <div class="h1 title main-title">
                                <xsl:value-of select="'84000 Glossary of Terms'"/>
                            </div>
                            <hr/>
                            <p class="no-bottom-margin">
                                <xsl:value-of select="'Our trilingual glossary combining entries from all of our publications into one useful resource, giving translations and definitions of thousands of terms, people, places, and texts from the Buddhist canon.'"/>
                            </p>
                        </div>
                    </div>
                    
                    <!-- Title -->
                    <h1 class="sr-only">
                        <xsl:value-of select="$page-title"/>
                    </h1>
                    
                    <!-- Tabs -->
                    <div class="tabs-container-center">
                        <ul class="nav nav-tabs" role="tablist">
                            
                            <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ’'"/>
                            <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', /m:response/m:request/@term-lang), concat('term-type[]=', ($selected-type[1]/@id, /m:response/m:request/m:entity-types/m:type[1]/@id)[1]), m:view-mode-parameter((),()))"/>
                            
                            <!-- Search tab -->
                            <li role="presentation" class="icon">
                                <xsl:if test="$active-tab eq 'search'">
                                    <xsl:attribute name="class" select="'icon active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/glossary.html?search=', $internal-link-attrs, '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Search'"/>
                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                    <i class="fa fa-search"/>
                                    <xsl:if test="$active-tab eq 'search'">
                                        <xsl:value-of select="' Search'"/>
                                    </xsl:if>
                                </a>
                            </li>
                            
                            <!-- Downloads tab -->
                            <li role="presentation" class="icon">
                                <xsl:if test="$active-tab eq 'downloads'">
                                    <xsl:attribute name="class" select="'icon active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/glossary.html?downloads=downloads', $internal-link-attrs, '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Downloads'"/>
                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                    <i class="fa fa-cloud-download"/>
                                </a>
                            </li>
                            
                            <!-- Letter tabs -->
                            <xsl:for-each select="1 to string-length($alphabet)">
                                <xsl:variable name="letter" select="substring($alphabet, ., 1)"/>
                                <li role="presentation" class="letter">
                                    <xsl:if test="$letter eq $active-tab">
                                        <xsl:attribute name="class" select="'active letter'"/>
                                    </xsl:if>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?search=', $letter), $internal-link-attrs, '', $root/m:response/@lang)"/>
                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                        <xsl:value-of select="$letter"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                            
                            <!-- Flag tabs -->
                            <xsl:if test="$tei-editor">
                                <xsl:for-each select="m:entity-flags/m:flag">
                                    <li role="presentation" class="icon">
                                        <xsl:if test="@id eq $active-tab">
                                            <xsl:attribute name="class" select="'active icon'"/>
                                        </xsl:if>
                                        <a class="editor">
                                            <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?flagged=', @id), (m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                            <xsl:attribute name="data-loading" select="'Loading...'"/>
                                            <xsl:value-of select="m:label"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </xsl:if>
                            
                        </ul>
                    </div>
                    
                    <!-- Results summary -->
                    <xsl:variable name="results-summary">
                        <span class="badge badge-notification">
                            <xsl:value-of select="format-number(count($entities), '#,###')"/>
                        </span>
                        <span class="badge-text">
                            <xsl:choose>
                                <xsl:when test="count($entities) eq 1">
                                    <xsl:value-of select="'match'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'matches'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </xsl:variable>
                    
                    <!-- Editor link -->
                    <xsl:variable name="editor-link">
                        <xsl:if test="$tei-editor or $tei-editor-off">
                            <a>
                                <xsl:choose>
                                    <xsl:when test="$tei-editor-off">
                                        <xsl:attribute name="href" select="$page-url || m:view-mode-parameter('editor')"/>
                                        <xsl:attribute name="class" select="'editor'"/>
                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                        <xsl:value-of select="'Show Editor'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="href" select="$page-url"/>
                                        <xsl:attribute name="class" select="'editor'"/>
                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                        <xsl:value-of select="'Hide Editor'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </a>
                        </xsl:if>
                    </xsl:variable>
                    
                    <!-- Type/Lang controls -->
                    <xsl:choose>
                        
                        <!-- Requested entity -->
                        <xsl:when test="$request-entity-data">
                            <!-- No options -->
                        </xsl:when>
                        
                        <!-- Flagged instances -->
                        <xsl:when test="$active-tab eq $flagged">
                            
                            <p class="text-center text-muted small">
                                <xsl:value-of select="'This view is only available to editors'"/>
                            </p>
                            
                            <!-- Type tabs -->
                            <div class="center-vertical-md align-center bottom-margin">
                                
                                <div>
                                    <ul class="nav nav-pills">
                                        
                                        <xsl:for-each select="m:request/m:entity-types/m:type[@glossary-type]">
                                            
                                            <li role="presentation">
                                                <xsl:if test="@selected eq 'selected'">
                                                    <xsl:attribute name="class" select="'active'"/>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?term-type[]=', @id), (concat('flagged=', $flagged), m:view-mode-parameter((),())), '', /m:response/@lang)"/>
                                                    <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                        <xsl:if test="$results-summary">
                                            <li role="presentation">
                                                <label>
                                                    <xsl:sequence select="$results-summary"/>
                                                </label>
                                            </li>
                                        </xsl:if>
                                        
                                        <xsl:if test="$editor-link">
                                            <li role="presentation">
                                                <xsl:sequence select="$editor-link"/>
                                            </li>
                                        </xsl:if>
                                        
                                    </ul>
                                </div>
                                
                            </div>
                        
                        </xsl:when>
                        
                        <!-- Search form -->
                        <xsl:when test="$active-tab eq 'search'">
                            <form action="/glossary.html" method="get" role="search" class="form-inline" data-loading="Searching...">
                                
                                <xsl:if test="$view-mode[@id eq 'editor']">
                                    <input type="hidden" name="view-mode" value="editor"/>
                                </xsl:if>
                                
                                <div class="align-center bottom-margin">
                                    
                                    <div class="form-group">
                                        <input type="text" name="search" class="form-control" placeholder="Search..." size="40">
                                            <xsl:if test="string-length($search-text) gt 1">
                                                <xsl:attribute name="value" select="$search-text"/>
                                            </xsl:if>
                                        </input>
                                    </div>
                                    
                                    <div class="form-group">
                                        <select name="term-lang" class="form-control">
                                            <xsl:for-each select="m:request/m:term-langs/m:lang">
                                                
                                                <option>
                                                    <xsl:attribute name="value" select="@id"/>
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="text()"/>
                                                </option>
                                                
                                            </xsl:for-each>
                                        </select>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fa fa-search"/>
                                    </button>
                                    
                                </div>
                                
                                <div class="center-vertical align-center bottom-margin">
                                    
                                    <div class="form-group">
                                        <xsl:for-each select="m:request/m:entity-types/m:type[@glossary-type]">
                                            <div class="checkbox-inline">
                                                <label>
                                                    <input type="checkbox" name="term-type[]">
                                                        <xsl:attribute name="value" select="@id"/>
                                                        <xsl:if test="@selected eq 'selected'">
                                                            <xsl:attribute name="checked" select="'checked'"/>
                                                        </xsl:if>
                                                    </input>
                                                    <xsl:value-of select="' ' || m:label[@type eq 'plural']"/>
                                                </label>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                    
                                    <xsl:if test="$results-summary">
                                        <div>
                                            <xsl:sequence select="$results-summary"/>
                                        </div>
                                    </xsl:if>
                                    
                                    <xsl:if test="$editor-link">
                                        <div>
                                            <xsl:sequence select="$editor-link"/>
                                        </div>
                                    </xsl:if>
                                    
                                </div>
                            </form>
                        </xsl:when>
                        
                        <!-- Downloads -->
                        <xsl:when test="$active-tab eq 'downloads'">
                            
                            <div class="text-center">
                                <h2>
                                    <xsl:value-of select="'Downloads'"/>
                                </h2>
                                <p class="text-muted small">
                                    <xsl:value-of select="'The 84000 combined glossary is available for download in the following formats.'"/>
                                    <br/>
                                    <xsl:value-of select="'Note: the data is continuously revised and subject to change. Please check back regularly for updates.'"/>
                                </p>
                            </div>
                            
                        </xsl:when>
                        
                        <!-- Type/Lang controls -->
                        <xsl:otherwise>
                            
                            <div class="center-vertical-md align-center bottom-margin">
                                
                                <!-- Type tabs -->
                                <div>
                                    <ul class="nav nav-pills">
                                        
                                        <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text), m:view-mode-parameter((),()))"/>
                                        
                                        <xsl:for-each select="m:request/m:entity-types/m:type[@glossary-type]">
                                            
                                            <li role="presentation">
                                                <xsl:if test="@selected eq 'selected'">
                                                    <xsl:attribute name="class" select="'active'"/>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?term-type[]=', @id), $internal-link-attrs, '', /m:response/@lang)"/>
                                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                    <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                    </ul>
                                </div>
                                
                                <!-- Language tabs -->
                                <div>
                                    <ul class="nav nav-pills">
                                        
                                        <xsl:variable name="internal-link-attrs" select="(concat('term-type[]=', string-join($selected-type[1]/@id, ',')), concat('search=', $search-text), m:view-mode-parameter((),()))"/>
                                        
                                        <xsl:for-each select="m:request/m:term-langs/m:lang[@filter eq 'true']">
                                            
                                            <li role="presentation">
                                                <xsl:if test="@selected eq 'selected'">
                                                    <xsl:attribute name="class" select="'active'"/>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?term-lang=', @id), $internal-link-attrs, '', /m:response/@lang)"/>
                                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                    <xsl:value-of select="text()"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                    </ul>
                                </div>
                                
                                <xsl:if test="$editor-link | $results-summary">
                                    <div>
                                        <ul class="nav nav-pills">
                                            
                                            <xsl:if test="$results-summary">
                                                <li role="presentation">
                                                    <label>
                                                        <xsl:sequence select="$results-summary"/>
                                                    </label>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:if test="$editor-link">
                                                <li role="presentation">
                                                    <xsl:sequence select="$editor-link"/>
                                                </li>
                                            </xsl:if>
                                            
                                        </ul>
                                    </div>
                                </xsl:if>
                                
                            </div>
                             
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <xsl:choose>
                        
                        <!-- Downloads -->
                        <xsl:when test="$active-tab eq 'downloads'">
                            
                            <div class="row">
                                <div class="col-md-10 col-md-offset-1">
                                    <table class="table no-border top-margin bottom-margin">
                                        <!--<thead>
                                            <tr>
                                                <th>
                                                    <xsl:value-of select="'Description'"/>
                                                </th>
                                                <th>
                                                    <xsl:value-of select="'Download'"/>
                                                </th>
                                                <th>
                                                    <xsl:value-of select="'Generated'"/>
                                                </th>
                                            </tr>
                                        </thead>-->
                                        <tbody>
                                            <xsl:for-each select="$root/m:response/m:downloads/m:download">
                                                <tr>
                                                    <td>
                                                        <xsl:value-of select="text()"/>
                                                    </td>
                                                    <td>
                                                        <a>
                                                            <xsl:attribute name="href" select="@download-url"/>
                                                            <xsl:attribute name="download" select="@filename"/>
                                                            <xsl:attribute name="class" select="'log-click'"/>
                                                            <xsl:value-of select="@filename"/>
                                                        </a>
                                                    </td>
                                                    <td class="text-muted small">
                                                        <xsl:if test="@last-modified gt ''">
                                                            <xsl:value-of select="format-dateTime(@last-modified, '[FNn,*-3], [D1o] [MNn,*-3] [Y01]')"/>
                                                        </xsl:if>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <hr class="sml-margin"/>
                            
                        </xsl:when>
                        
                        <!-- Requested entity -->
                        <xsl:when test="$request-entity-data">
                            
                            <div id="entity-requested">
                                
                                <xsl:variable name="related-entries" select="key('related-entries', $request-entity/m:instance/@id, $root)"/>
                                <xsl:variable name="related-entity-pages" select="key('related-pages', $request-entity/m:instance/@id | /m:response/m:entities/m:related/m:entity[@xml:id = $request-entity/m:relation/@id]/m:instance/@id, $root)" as="element(m:page)*"/>
                                <xsl:variable name="related-entity-entries" select="key('related-entries', /m:response/m:entities/m:related/m:entity[@xml:id = $request-entity/m:relation/@id]/m:instance/@id, $root)" as="element(m:entry)*"/>
                                
                                <div>
                                    
                                    <xsl:attribute name="id" select="concat($request-entity/@xml:id, '-detail')"/>
                                    
                                    <!-- Header -->
                                    <div class="entity-detail-title">
                                        
                                        <xsl:call-template name="entity-detail-title">
                                            <xsl:with-param name="entity-data" select="$request-entity-data"/>
                                        </xsl:call-template>
                                        
                                    </div>
                                    
                                    <div class="entity-detail-body ajax-target">
                                        
                                        <xsl:attribute name="id" select="concat($request-entity/@xml:id, '-body')"/>
                                        
                                        <!-- Entity editor -->
                                        <xsl:if test="$tei-editor">
                                            <div>
                                                <a target="84000-operations" class="editor">
                                                    <xsl:attribute name="href" select="concat('/edit-entity.html?entity-id=', $request-entity/@xml:id, '#ajax-source')"/>
                                                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                    <xsl:value-of select="'Entity editor'"/>
                                                </a>
                                            </div>
                                        </xsl:if>
                                        
                                        <!-- Entity definition -->
                                        <xsl:for-each select="$request-entity/m:content[@type eq 'glossary-definition']">
                                            <p>
                                                <xsl:apply-templates select="node()"/>
                                            </p>
                                        </xsl:for-each>
                                        
                                        <!-- Glossary entries: group by translation -->
                                        <xsl:if test="$related-entries">
                                            
                                            <label>
                                                <xsl:value-of select="'Translated as:'"/>
                                            </label>
                                            
                                            <ul class="nav nav-pills" role="tablist">
                                                <xsl:for-each-group select="$related-entries" group-by="m:sort-term">
                                                    
                                                    <xsl:sort select="m:sort-term"/>
                                                    <xsl:variable name="term-group" select="current-group()"/>
                                                    
                                                    <li role="presentation">
                                                        <xsl:if test="position() eq 1">
                                                            <xsl:attribute name="class" select="'active'"/>
                                                        </xsl:if>
                                                        <a role="tab" data-toggle="tab">
                                                            <xsl:attribute name="href" select="concat('#tab-term-', $request-entity/@xml:id, '-', position())"/>
                                                            <xsl:attribute name="aria-controls" select="concat('tab-term-', $request-entity/@xml:id, '-', position())"/>
                                                            <xsl:value-of select="m:term[@xml:lang eq 'en'][1]"/>
                                                            <xsl:value-of select="' '"/>
                                                            <span class="badge">
                                                                <xsl:if test="$tei-editor and ($request-entity/m:instance[@id = $term-group/@id][m:flag] or $term-group[parent::m:text/@glossary-status eq 'excluded'])">
                                                                    <xsl:attribute name="class" select="'badge badge-danger'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="count(current-group())"/>
                                                            </span>
                                                        </a>
                                                    </li>
                                                    
                                                </xsl:for-each-group>
                                            </ul>
                                            
                                            <div class="tab-content bottom-margin">
                                                
                                                <xsl:for-each-group select="$related-entries" group-by="m:sort-term">
                                                    
                                                    <xsl:sort select="m:sort-term"/>
                                                    <xsl:variable name="term-group-index" select="position()"/>
                                                    <xsl:variable name="term-group" select="current-group()"/>
                                                    
                                                    <div role="tabpanel" class="translation-result tab-pane fade">
                                                        
                                                        <xsl:attribute name="id" select="concat('tab-term-', $request-entity/@xml:id, '-', position())"/>
                                                        
                                                        <xsl:if test="position() eq 1">
                                                            <xsl:attribute name="class" select="'translation-result tab-pane fade active in'"/>
                                                        </xsl:if>
                                                        
                                                        <!-- Group by type (translation/knowledgebase) -->
                                                        <xsl:for-each-group select="$term-group" group-by="parent::m:text/@type">
                                                            
                                                            <xsl:variable name="text-type" select="parent::m:text/@type"/>
                                                            <xsl:variable name="text-type-entries" select="current-group()"/>
                                                            <xsl:variable name="text-type-related-texts" select="/m:response/m:entities/m:related/m:text[m:entry/@id = $text-type-entries/@id]"/>
                                                            
                                                            <div>
                                                                <span class="badge badge-notification">
                                                                    <xsl:if test="$tei-editor and ($request-entity/m:instance[@id = $text-type-entries/@id][m:flag] or $text-type-entries[parent::m:text/@glossary-status eq 'excluded'])">
                                                                        <xsl:attribute name="class" select="'badge badge-notification badge-danger'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="count($text-type-entries)"/>
                                                                </span>
                                                                <span class="badge-text">
                                                                    <xsl:choose>
                                                                        <xsl:when test="$text-type eq 'knowledgebase'">
                                                                            <xsl:value-of select="if(count($text-type-entries) eq 1) then 'knowledge base page' else 'knowledge base pages'"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="if(count($text-type-entries) eq 1) then 'publication' else 'publications'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </span>
                                                            </div>
                                                            
                                                            <div>
                                                                <xsl:for-each select="$text-type-related-texts">
                                                                    
                                                                    <!-- Order by Toh numerically needs improving -->
                                                                    <xsl:sort select="m:bibl[1]/m:toh[1]/@number ! xs:integer(.)"/>
                                                                    <xsl:variable name="related-text" select="."/>
                                                                    
                                                                    <xsl:for-each select="$related-text/m:entry[@id = $text-type-entries/@id]">
                                                                        <xsl:variable name="related-text-entry" select="."/>
                                                                        <xsl:call-template name="glossary-entry">
                                                                            <xsl:with-param name="entity-data" select="$request-entity-data"/>
                                                                            <xsl:with-param name="entry" select="$related-text-entry"/>
                                                                            <xsl:with-param name="text" select="$related-text"/>
                                                                            <xsl:with-param name="instance" select="$request-entity/m:instance[@id eq $related-text-entry/@id]"/>
                                                                        </xsl:call-template>
                                                                    </xsl:for-each>
                                                                    
                                                                </xsl:for-each>
                                                            </div>
                                                            
                                                        </xsl:for-each-group>
                                                        
                                                    </div>
                                                
                                                </xsl:for-each-group>
                                                
                                            </div>
                                            
                                        </xsl:if>
                                        
                                        <!-- Related entities -->
                                        <xsl:if test="$related-entity-pages">
                                            <label>
                                                <xsl:value-of select="'Related content from the 84000 Knowledge Base:'"/>
                                            </label>
                                            <ul>
                                                <xsl:for-each select="$related-entity-pages">
                                                    <li>
                                                        
                                                        <xsl:variable name="main-title" select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                                                        
                                                        <a class="no-underline">
                                                            <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                            <span>
                                                                <xsl:attribute name="class">
                                                                    <xsl:value-of select="string-join(('results-list-item-heading', common:lang-class($main-title/@xml:lang)),' ')"/>
                                                                </xsl:attribute>
                                                                <xsl:value-of select="normalize-space($main-title/text())"/>
                                                            </span>
                                                        </a>
                                                        
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </xsl:if>
                                        
                                        <xsl:if test="$related-entity-entries">
                                            
                                            <label>
                                                <xsl:value-of select="'Related content from the 84000 Glossary of Terms:'"/>
                                            </label>
                                            
                                            <ul>
                                                <xsl:for-each select="/m:response/m:entities/m:related/m:entity[m:instance/@id = $related-entity-entries/@id]">
                                                    
                                                    <xsl:variable name="related-entity" select="."/>
                                                    <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                        <xsl:call-template name="entity-data">
                                                            <xsl:with-param name="entity" select="$related-entity"/>
                                                            <xsl:with-param name="search-text" select="$search-text"/>
                                                            <xsl:with-param name="selected-term-lang" select="$selected-term-lang/@id"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    
                                                    <li>
                                                        
                                                        <a class="no-underline">
                                                            
                                                            <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?entity-id=', $related-entity/@xml:id), (m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                                            
                                                            <span>
                                                                <xsl:attribute name="class">
                                                                    <xsl:value-of select="string-join(('results-list-item-heading', common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang)),' ')"/>
                                                                </xsl:attribute>
                                                                <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/text())"/>
                                                            </span>
                                                            
                                                            <xsl:if test="$entity-data[m:label[@type eq 'secondary']]">
                                                                <br/>
                                                                <span>
                                                                    <xsl:attribute name="class">
                                                                        <xsl:value-of select="string-join(('text-muted',common:lang-class($entity-data/m:label[@type eq 'secondary']/@xml:lang)),' ')"/>
                                                                    </xsl:attribute>
                                                                    <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'secondary']/text())"/>
                                                                </span>
                                                            </xsl:if>
                                                            
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                            
                                        </xsl:if>
                                        
                                    </div>
                                    
                                </div>
                                
                            </div>
                        
                        </xsl:when>
                        
                        <!-- Entities list -->
                        <xsl:when test="$entities">
                            
                            <nav role="navigation" id="entity-list">
                                <xsl:for-each select="$entities-data-sorted">
                                    
                                    <xsl:variable name="entity-data" select="."/>
                                    <xsl:variable name="entity" select="$entities[@xml:id eq $entity-data/@ref]"/>
                                    
                                    <xsl:if test="$entity[@xml:id] and $entity-data[@related-entries ! xs:integer(.) gt 0]">
                                        
                                        <xsl:variable name="item-id" select="concat('item-', $entity/@xml:id)"/>
                                        
                                        <div class="list-item">
                                            
                                            <xsl:attribute name="id" select="$item-id"/>
                                            
                                            <!-- Entity title -->
                                            <a class="block-link log-click">
                                                
                                                <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?entity-id=', $entity/@xml:id), (if($tei-editor and $flagged gt '') then concat('flagged=', $flagged) else (), m:view-mode-parameter((),())), concat('#', $entity/@xml:id, '-body'), $root/m:response/@lang)"/>
                                                <xsl:attribute name="data-ajax-target" select="concat('#', $item-id, '-detail', ' .ajax-target')"/>
                                                <xsl:attribute name="data-toggle-active" select="concat('#', $item-id)"/>
                                                <xsl:attribute name="data-ajax-loading" select="'Loading detail...'"/>
                                                
                                                <xsl:call-template name="entity-detail-title">
                                                    <xsl:with-param name="entity-data" select="$entity-data"/>
                                                </xsl:call-template>
                                                
                                                <ul class="list-inline inline-dots">
                                                    <xsl:variable name="entity-term-matches" select="if( $entity-data/m:term[@matches]) then $entity-data/m:term[@matches] else $entity-data/m:term"/>
                                                    <xsl:for-each select="$entity-term-matches">
                                                        <li>
                                                            <span>
                                                                <xsl:call-template name="class-attribute">
                                                                    <xsl:with-param name="base-classes" select="'small'"/>
                                                                    <xsl:with-param name="html-classes" as="xs:string*">
                                                                        <xsl:if test="@matches">
                                                                            <xsl:value-of select="'mark'"/>
                                                                        </xsl:if>
                                                                        <xsl:if test="@flagged">
                                                                            <xsl:value-of select="'interpolation'"/>
                                                                        </xsl:if>
                                                                    </xsl:with-param>
                                                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                                                </xsl:call-template>
                                                                <xsl:value-of select="text()"/>
                                                            </span>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                                
                                            </a>
                                            
                                            <div class="collapse persist">
                                                <xsl:attribute name="id" select="concat($item-id, '-detail')"/>
                                                <!-- Ajax data here -->
                                                <div class="ajax-target"/>
                                            </div>
                                            
                                        </div>
                                        
                                    
                                    </xsl:if>
                                    
                                </xsl:for-each>
                            </nav>
                            
                        </xsl:when>
                        
                        <!-- No results -->
                        <xsl:otherwise>
                            <hr/>
                            <div class="text-center text-muted">
                                <xsl:choose>
                                    <xsl:when test="m:request[@request-is-search eq 'true']">
                                        
                                        <p class="italic">
                                            <xsl:value-of select="'Try a different search'"/>
                                        </p>
                                        
                                        <ul class="list-inline inline-dots">
                                            <xsl:for-each select="/m:response/m:request/m:term-langs/m:lang[not(@selected)]">
                                                <li>
                                                    <a class="text-muted underline">
                                                        <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?search=', $search-text), (concat('term-lang=', @id), $selected-type ! concat('term-type[]=', ./@id), m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                        <xsl:value-of select="text()"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                            <xsl:if test="/m:response/m:request/m:entity-types/m:type[not(@selected)]">
                                                <li>
                                                    <a class="text-muted underline">
                                                        <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?search=', $search-text), (concat('term-lang=', $selected-term-lang/@id), m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                                        <xsl:attribute name="title" select="'Search'"/>
                                                        <xsl:value-of select="'All types'"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                        </ul>
                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        
                                        <p class="italic">
                                            <xsl:value-of select="'~ No matches for this query ~'"/>
                                        </p>
                                        
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </div>
            </main>
            
            <!-- Pop-up for tei-editor -->
            <xsl:if test="$tei-editor">
                <div id="popup-footer-editor" class="fixed-footer collapse hidden-print">
                    <div class="fix-height">
                        <div class="container">
                            <div class="data-container">
                                <!-- Ajax data here -->
                            </div>
                        </div>
                    </div>
                    <div class="fixed-btn-container close-btn-container">
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
            <xsl:with-param name="page-url" select="$page-url"/>
            <xsl:with-param name="page-class" select="'reading-room section'"/>
            <xsl:with-param name="page-title" select="$page-title || ' | 84000 Reading Room'"/>
            <xsl:with-param name="page-description" select="$page-title"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="entity-detail-title">
        
        <xsl:param name="entity-data" as="element(m:entity-data)"/>
        
        <xsl:variable name="entity" select="$entities[@xml:id eq $entity-data/@ref]"/>
        <xsl:variable name="instances-flagged" select="$entity/m:instance[m:flag]"/>
        <xsl:variable name="related-entries" select="key('related-entries', $entity/m:instance/@id, $root)"/>
        <xsl:variable name="related-entries-excluded" select="$related-entries[parent::m:text/@glossary-status eq 'excluded']"/>
        
        <div class="center-vertical full-width">
            
            <div>
                <div class="center-vertical align-left">
                    
                    <h2>
                        <span>
                            <xsl:attribute name="class">
                                <xsl:value-of select="common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang)"/>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/data())"/>
                        </span>
                    </h2>
                    
                    <xsl:if test="$entity-data[m:label[@type eq 'secondary']]">
                        
                        <div class="text-muted">
                            <xsl:value-of select="' ('"/>
                            <span>
                                <xsl:attribute name="class">
                                    <xsl:value-of select="common:lang-class($entity-data/m:label[@type eq 'secondary']/@xml:lang)"/>
                                </xsl:attribute>
                                <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'secondary']/data())"/>
                            </span>
                            <xsl:value-of select="')'"/>
                        </div>
                        
                    </xsl:if>
                    
                </div>
            </div>
            
            <div>
                <ul class="list-inline list-dots pull-right">
                    <xsl:for-each-group select="$entity/m:type" group-by="@type">
                        <xsl:variable name="type" select="."/>
                        <li>
                            <span class="label label-info">
                                <xsl:value-of select="/m:response/m:request/m:entity-types/m:type[@id eq $type[1]/@type]/m:label[@type eq 'singular']"/>
                            </span>
                        </li>
                    </xsl:for-each-group>
                </ul>
            </div>
            
        </div>
        
        <xsl:if test="$tei-editor and ($entity/m:content[@type eq 'glossary-notes'] or $instances-flagged or $related-entries-excluded)">
            <div class="clearfix sml-margin bottom">
                <div class="center-vertical align-left">
                    
                    <xsl:if test="$entity/m:content[@type eq 'glossary-notes']">
                        <span>
                            <span class="badge badge-notification">
                                <xsl:value-of select="count($entity/m:content[@type eq 'glossary-notes'])"/>
                            </span>
                            <span class="badge-text">
                                <xsl:value-of select="' notes'"/>
                            </span>
                        </span>
                    </xsl:if>
                    
                    <xsl:if test="$related-entries-excluded">
                        <span>
                            <span class="badge badge-notification">
                                <xsl:value-of select="count($related-entries-excluded)"/>
                            </span>
                            <span class="badge-text">
                                <xsl:value-of select="if (count($related-entries-excluded) eq 1) then 'entry in an excluded text' else 'entries in excluded texts'"/>
                            </span>
                        </span>
                    </xsl:if>
                    
                    <xsl:if test="$instances-flagged">
                        <span>
                            <span class="badge badge-notification">
                                <xsl:value-of select="count($instances-flagged)"/>
                            </span>
                            <span class="badge-text">
                                
                                <xsl:choose>
                                    <xsl:when test="count($entity/m:instance[@type eq 'glossary-item']) eq count($entity/m:instance[@type eq 'glossary-item'][m:flag])">
                                        <xsl:value-of select="'all entries are flagged, this entity is EXCLUDED from the public Glossary of Terms'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="if (count($instances-flagged) eq 1) then 'entry flagged' else 'entries flagged'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </span>
                    </xsl:if>
                    
                </div>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="glossary-entry">
        
        <xsl:param name="entity-data" as="element(m:entity-data)"/>
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="text" as="element(m:text)"/>
        <xsl:param name="instance" as="element(m:instance)"/>
        
        <xsl:variable name="glossary-status" select="$text/@glossary-status"/>
        <xsl:variable name="href" select="concat($reading-room-path, '/', $text/@type, '/', $text/m:bibl[1]/m:toh[1]/@key, '.html#', @id)"/>
        <xsl:variable name="target" select="concat($text/@id, '.html')"/>
        
        <div class="entry-result">
            
            <xsl:attribute name="id" select="concat('glossary-entry-', $entry/@id)"/>
            
            <xsl:if test="$tei-editor and ($glossary-status eq 'excluded' or $instance[m:flag/@type eq 'requires-attention'])">
                <xsl:attribute name="class" select="'entry-result excluded'"/>
            </xsl:if>
            
            <!-- Title -->
            <h4>
                <a>
                    <xsl:attribute name="href" select="$href"/>
                    <xsl:attribute name="target" select="$target"/>
                    <xsl:apply-templates select="($text/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], $text/m:titles/m:title[@type eq 'mainTitle'])[1]/text()"/>
                </a>
                <xsl:if test="$tei-editor and ($glossary-status eq 'excluded')">
                    <xsl:value-of select="' '"/>
                    <span class="label label-danger">
                        <xsl:value-of select="'glossary excluded'"/>
                    </span>
                </xsl:if>
            </h4>
            
            <!-- Location -->
            <xsl:for-each select="$text/m:bibl">
                <nav role="navigation" aria-label="Breadcrumbs" class="small text-muted">
                    <xsl:value-of select="'in '"/>
                    <ul class="breadcrumb">
                        
                        <xsl:sequence select="common:breadcrumb-items(m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                        
                        <xsl:if test="m:toh/m:full">
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/', $text/@type, '/', m:toh/@key, '.html')"/>
                                    <xsl:attribute name="target" select="$target"/>
                                    <xsl:apply-templates select="m:toh/m:full"/>
                                </a>
                            </li>
                        </xsl:if>
                        
                    </ul>
                </nav>
            </xsl:for-each>
            
            <!-- Translators -->
            <xsl:variable name="translators" select="$text/m:publication/m:contributors/m:author[normalize-space(text())]"/>
            <xsl:if test="$translators">
                <div class="text-muted small">
                    <xsl:value-of select="'Translation by '"/>
                    <xsl:value-of select="string-join($translators ! normalize-space(data()), ' · ')"/>
                </div>
            </xsl:if>
            
            <!-- Tantric restriction -->
            <xsl:variable name="tantric-restriction" select="$text[@type eq 'translation']/m:publication/m:tantric-restriction"/>
            <xsl:if test="$tantric-restriction/tei:p">
                <div class="row">
                    <div class="col-sm-12">
                        
                        <a data-toggle="modal" class="warning">
                            <xsl:attribute name="href" select="concat('#tantra-warning-', $text/@id)"/>
                            <xsl:attribute name="data-target" select="concat('#tantra-warning-', $text/@id)"/>
                            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                            <xsl:value-of select="' Tantra Text Warning'"/>
                        </a>
                        
                        <div class="modal fade warning" tabindex="-1" role="dialog">
                            <xsl:attribute name="id" select="concat('tantra-warning-', $text/@id)"/>
                            <xsl:attribute name="aria-labelledby" select="concat('tantra-warning-label-', $text/@id)"/>
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">
                                                <i class="fa fa-times"/>
                                            </span>
                                        </button>
                                        <h4 class="modal-title">
                                            <xsl:attribute name="id" select="concat('tantra-warning-label-', $text/@id)"/>
                                            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                            <xsl:value-of select="' Tantra Text Warning'"/>
                                        </h4>
                                    </div>
                                    <div class="modal-body">
                                        <xsl:for-each select="$tantric-restriction/tei:p">
                                            <p>
                                                <xsl:apply-templates select="node()"/>
                                            </p>
                                        </xsl:for-each>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </xsl:if>
            
            <!-- Output terms grouped and ordered by language -->
            <xsl:for-each select="('bo','Bo-Ltn','Sa-Ltn','zh')">
                
                <xsl:variable name="term-lang" select="."/>
                <xsl:variable name="term-lang-terms" select="$entry/m:term[@xml:lang eq $term-lang][text()]"/>

                <xsl:if test="$term-lang-terms[text()[not(normalize-space(.) = $entity-data/m:label[@xml:lang eq $term-lang]/text())]]">
                    <div>
                        <ul class="list-inline inline-dots inline-pad-first">
                            <xsl:choose>
                                <xsl:when test="$term-lang-terms">
                                    <xsl:for-each select="$term-lang-terms">
                                        <li>
                                            
                                            <span>
                                                
                                                <xsl:call-template name="class-attribute">
                                                    <xsl:with-param name="base-classes" as="xs:string*">
                                                        <xsl:value-of select="'term'"/>
                                                        <xsl:if test="@type = ('reconstruction', 'semanticReconstruction','transliterationReconstruction')">
                                                            <xsl:value-of select="'reconstructed'"/>
                                                        </xsl:if>
                                                    </xsl:with-param>
                                                    <xsl:with-param name="lang" select="$term-lang"/>
                                                </xsl:call-template>
                                                
                                                <xsl:value-of select="text()"/>
                                                
                                            </span>
                                            
                                            <xsl:if test="$tei-editor and @status eq 'verified'">
                                                <xsl:value-of select="' '"/>
                                                <span class="alternative">
                                                    <xsl:value-of select="'Verified'"/>
                                                </span>
                                            </xsl:if>
                                            
                                        </li>
                                    </xsl:for-each>
                                </xsl:when>
                            </xsl:choose>
                        </ul>
                    </div>
                </xsl:if>
                
            </xsl:for-each>
            
            <!-- Alternatives -->
            <xsl:variable name="alternative-terms" select="$entry/m:alternative"/>
            <xsl:if test="$tei-editor and $alternative-terms">
                <div>
                    <ul class="list-inline inline-dots inline-pad-first">
                        <xsl:for-each select="$alternative-terms">
                            <li>
                                <span>
                                    <xsl:call-template name="class-attribute">
                                        <xsl:with-param name="base-classes" as="xs:string*">
                                            <xsl:value-of select="'term'"/>
                                            <xsl:value-of select="'alternative'"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="lang" select="@xml:lang"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="normalize-space(data())"/>
                                </span>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>
            
            <!-- Glossary definition -->
            <xsl:variable name="entry-definition" select="$entry/m:definition"/>
            <xsl:for-each select="$entry-definition">
                <p>
                    <xsl:attribute name="class" select="'definition'"/>
                    <xsl:apply-templates select="."/>
                </p>
            </xsl:for-each>
            
            <!-- Entity definition -->
            <xsl:variable name="entity-definition" select="$instance/parent::m:entity/m:content[@type eq 'glossary-definition']"/>
            <xsl:if test="$tei-editor and $entity-definition and $entry-definition and $instance[@use-definition  eq 'both']">
                <div class="well well-sm">
                    
                    <h6 class="sml-margin top bottom">
                        <xsl:value-of select="'Text also includes entity definition:'"/>
                    </h6>
                    <xsl:for-each select="$entity-definition">
                        <p>
                            <xsl:attribute name="class" select="'definition'"/>
                            <xsl:apply-templates select="node()"/>
                        </p>
                    </xsl:for-each>
                    
                </div>
            </xsl:if>
            
            <!-- Count of references -->
            <xsl:variable name="count-entry-locations" select="count($text/m:glossary-cache/m:gloss[@id eq $entry/@id]/m:location)"/>
            <div>
                <a class="small underline">
                    <xsl:attribute name="href" select="$href"/>
                    <xsl:attribute name="target" select="$target"/>
                    <xsl:choose>
                        <xsl:when test="$count-entry-locations gt 1">
                            <xsl:value-of select="concat(format-number($count-entry-locations, '#,###'), ' passages contain this term')"/>
                        </xsl:when>
                        <xsl:when test="$count-entry-locations eq 1">
                            <xsl:value-of select="'1 passage contains this term'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'No locations for this term'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
            
            <!-- Editor options -->
            <xsl:if test="$tei-editor">
                
                <div>
                    <ul class="list-inline inline-dots">
                        
                        <li class="small">
                            <a target="84000-glossary-tool" class="editor">
                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/data(), '/edit-glossary.html?resource-id=', $text/@id, '&amp;glossary-id=', @id, '&amp;resource-type=', $text/@type, '&amp;max-records=1')"/>
                                <xsl:value-of select="'Glossary editor'"/>
                            </a>
                        </li>
                        
                        <xsl:for-each select="/m:response/m:entity-flags/m:flag">
                            <li>
                                
                                <xsl:variable name="config-flag" select="."/>
                                <xsl:variable name="entity-flag" select="$instance/m:flag[@type eq $config-flag/@id][1]"/>
                                
                                <form action="/edit-entity.html" method="post" data-ajax-target="#ajax-source" class="form-inline inline-block">
                                    
                                    <xsl:attribute name="data-ajax-target-callbackurl" select="$page-url || '&amp;' || concat('flagged=', $flagged) || m:view-mode-parameter('editor') ||  concat('#glossary-entry-', $entry/@id)"/>
                                    <input type="hidden" name="instance-id" value="{ $instance/@id }"/>
                                    <input type="hidden" name="entity-flag" value="{ $config-flag/@id }"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="$entity-flag">
                                            
                                            <!-- Option to clear flag -->
                                            <input type="hidden" name="form-action" value="instance-clear-flag"/>
                                            
                                            <span class="label label-danger">
                                                <xsl:value-of select="$config-flag/m:label[1]"/>
                                            </span>
                                            
                                            <span class="small">
                                                <xsl:value-of select="' '"/>
                                                <span class="alternative">
                                                    <xsl:value-of select="common:date-user-string('Flag set', $entity-flag/@timestamp, $entity-flag/@user)"/>
                                                </span>
                                                <xsl:value-of select="' '"/>
                                                <button type="submit" data-loading="Clearing flag..." class="btn-link editor">
                                                    <xsl:value-of select="'Clear flag'"/>
                                                </button>
                                            </span>
                                            
                                        </xsl:when>
                                        <xsl:otherwise>
                                            
                                            <!-- Option to set flag -->
                                            <input type="hidden" name="form-action" value="instance-set-flag"/>
                                            
                                            <button type="submit" data-loading="Setting flag..." class="btn-link editor small">
                                                <xsl:value-of select="'Flag as ' || $config-flag/m:label"/>
                                            </button>
                                            
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </form>
                                
                            </li>
                        </xsl:for-each>
                        
                    </ul>
                </div>
                
            </xsl:if>
            
        </div>
    
    </xsl:template>
    
</xsl:stylesheet>