<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/glossary.xsl"/>
    
    <!-- Set template variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>
    <xsl:variable name="selected-type" select="/m:response/m:request/m:entity-types/m:type[@glossary-type][@selected eq 'selected']" as="element(m:type)*"/>
    <xsl:variable name="selected-term-lang" select="/m:response/m:request/m:term-langs/m:lang[@selected eq 'selected'][1]" as="element(m:lang)?"/>
    <xsl:variable name="selected-letter" select="/m:response/m:request/m:alphabet/m:letter[@selected eq 'selected'][1]" as="element(m:letter)?"/>
    <xsl:variable name="search-text" select="/m:response/m:request/m:search/data()" as="xs:string?"/>
    <xsl:variable name="search-text-bo" select="/m:response/m:request/m:search-bo/data()" as="xs:string?"/>
    <xsl:variable name="flagged" select="/m:response/m:request/@flagged" as="xs:string?"/>
    
    <!-- Process entities data -->
    <xsl:variable name="entities-data" as="element(m:entity-data)*">
        <xsl:for-each select="$entities">
            <xsl:call-template name="entity-data">
                <xsl:with-param name="entity" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="active-tab" as="xs:string?">
        <xsl:choose>
            <xsl:when test="$tei-editor and /m:response/m:entity-flags/m:flag[@id eq $flagged]">
                <xsl:value-of select="$flagged"/>
            </xsl:when>
            <xsl:when test="/m:response/m:request[@resource-id eq 'downloads']">
                <xsl:value-of select="'downloads'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="(/m:response/m:request/m:term-langs/m:lang[@selected eq 'selected'], /m:response/m:request/m:term-langs/m:lang[1])[1]/@id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="page-title" as="xs:string">
        <xsl:choose>
            <xsl:when test="$selected-letter">
                <xsl:value-of select="concat('Filter: ', string-join(($selected-term-lang/text(), $selected-type/m:label[@type eq 'plural']/text(), $selected-letter ! concat('&#34;', ., '&#34;')), '; '), '| Glossary of Terms')"/>
            </xsl:when>
            <xsl:when test="$search-text gt ''">
                <xsl:value-of select="concat('Search: ', string-join(($selected-term-lang/text(), $selected-type/m:label[@type eq 'plural']/text(), $search-text ! concat('&#34;', ., '&#34;')), '; '), '| Glossary of Terms')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Glossary of Terms'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="page-url" select="concat($reading-room-path, '/glossary/', if($active-tab eq 'downloads') then 'downloads' else 'search', '.html?') || string-join(($selected-term-lang ! concat('term-lang=', @id), $selected-type ! concat('term-type[]=', @id), $selected-letter ! concat('letter=', @index), concat('search=', $search-text)), '&amp;')" as="xs:string"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <!-- Title band -->
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
                                        <xsl:attribute name="href" select="common:internal-link('/glossary/search.html', (), '', /m:response/@lang)"/>
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
                    <xsl:call-template name="glossary-tabs">
                        <xsl:with-param name="page-url" select="$page-url"/>
                        <xsl:with-param name="term-langs" select="m:request/m:term-langs"/>
                        <xsl:with-param name="entity-flags" select="m:entity-flags"/>
                        <xsl:with-param name="selected-type" select="$selected-type"/>
                        <xsl:with-param name="active-tab" select="$active-tab"/>
                        <xsl:with-param name="search-text" select="$search-text"/>
                    </xsl:call-template>
                    
                    <!-- Main content -->
                    <xsl:choose>
                        
                        <!-- Downloads -->
                        <xsl:when test="$active-tab eq 'downloads'">
                            
                            <div class="text-center">
                                <p class="text-muted small">
                                    <xsl:value-of select="'The 84000 combined glossary is available for download in the following formats.'"/>
                                    <br/>
                                    <xsl:value-of select="'Note: the data is continuously revised and subject to change. Please check back regularly for updates.'"/>
                                </p>
                            </div>
                            
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
                            
                        </xsl:when>
                        
                        <!-- Search -->
                        <xsl:otherwise>
                            
                            <xsl:if test="$active-tab eq $flagged">
                                <p class="text-center text-muted small">
                                    <xsl:value-of select="'This view is only available to editors'"/>
                                </p>
                            </xsl:if>
                            
                            <!-- Alphabet pills / search pill -->
                            <xsl:if test="m:request/m:term-langs/m:lang[@id eq $active-tab]">
                                
                                <div class="row">
                                    <div>
                                        
                                        <xsl:choose>
                                            <xsl:when test="$selected-term-lang/@id eq 'Sa-Ltn'">
                                                <xsl:attribute name="class" select="'col-md-offset-2 col-md-8'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="class" select="'col-sm-12'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        <div class="tabs-container-center">
                                            <ul class="nav nav-pills" role="tablist" id="nav-letters">
                                                
                                                <xsl:variable name="alphabet" select="m:request/m:alphabet"/>
                                                <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', $selected-term-lang/@id), $selected-type ! concat('term-type[]=', ./@id), m:view-mode-parameter((),()))"/>
                                                
                                                <!-- Letter options -->
                                                <xsl:for-each select="$alphabet/m:letter">
                                                    
                                                    <li role="presentation" class="letter">
                                                        
                                                        <xsl:if test="@selected">
                                                            <xsl:attribute name="class" select="'active letter'"/>
                                                        </xsl:if>
                                                        
                                                        <a>
                                                            
                                                            <xsl:attribute name="href" select="common:internal-link(concat('/glossary/search.html?letter=', @index), $internal-link-attrs, '', $root/m:response/@lang)"/>
                                                            <xsl:attribute name="title" select="concat('Filter by ', text())"/>
                                                            <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                            
                                                            <div>
                                                                <xsl:call-template name="class-attribute">
                                                                    <xsl:with-param name="lang" select="$alphabet/@xml:lang"/>
                                                                    <xsl:with-param name="html-classes">
                                                                        <xsl:if test="$alphabet/@xml:lang eq 'en'">
                                                                            <xsl:value-of select="'uppercase'"/>
                                                                        </xsl:if>
                                                                    </xsl:with-param>
                                                                </xsl:call-template>
                                                                <xsl:value-of select="text()"/>
                                                            </div>
                                                            
                                                            <xsl:if test="@wylie ! normalize-space(.)">
                                                                <br/>
                                                                <div class="small text-muted">
                                                                    <xsl:value-of select="normalize-space(@wylie)"/>
                                                                </div>
                                                            </xsl:if>
                                                            
                                                        </a>
                                                    </li>
                                                    
                                                </xsl:for-each>
                                                
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                                
                            </xsl:if>
                            
                            <!-- Search form -->
                            <form action="/glossary/search.html" method="get" role="search" class="form-inline" data-loading="Searching...">
                                
                                <input type="hidden" name="term-lang" value="{ $selected-term-lang/@id }"/>
                                <input type="hidden" name="letter" value="{ $selected-letter/@index }"/>
                                
                                <xsl:if test="$view-mode[@id eq 'editor']">
                                    <input type="hidden" name="view-mode" value="editor"/>
                                </xsl:if>
                                
                                <!-- Type checkboxes -->
                                <div class="center-vertical-sm align-center bottom-margin">
                                    
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
                                    
                                    <!-- Results summary -->
                                    <div>
                                        <div class="center-vertical align-center">
                                            <span>
                                                <span class="badge">
                                                    <xsl:value-of select="m:entities/@count-entities ! format-number(xs:integer(.), '#,###')"/>
                                                </span>
                                                <span class="badge-text">
                                                    <xsl:choose>
                                                        <xsl:when test="m:entities/@count-entities ! xs:integer(.) eq 1">
                                                            <xsl:value-of select="'match'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'matches'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                            </span>
                                            <xsl:if test="$selected-term-lang/@id eq 'bo'">
                                                <span>
                                                    <a data-toggle="modal" href="#tibetan-search-info" data-target="#tibetan-search-info" class="visible-scripts help-icon" title="'Information about the Tibetan search'">
                                                        <i class="fa fa-info-circle" aria-hidden="true"/>
                                                    </a>
                                                </span>
                                            </xsl:if>
                                        </div>
                                    </div>
                                    
                                </div>
                                
                                <xsl:if test="$selected-term-lang/@id eq 'bo'">
                                    <div class="modal fade warning" tabindex="-1" role="dialog">
                                        <xsl:attribute name="id" select="'tibetan-search-info'"/>
                                        <xsl:attribute name="aria-labelledby" select="'tibetan-search-info-label'"/>
                                        <div class="modal-dialog" role="document">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                        <span aria-hidden="true">
                                                            <i class="fa fa-times"/>
                                                        </span>
                                                    </button>
                                                    <h4 class="modal-title" id="tibetan-search-info-label">
                                                        <xsl:value-of select="'About the Tibetan search'"/>
                                                    </h4>
                                                </div>
                                                <div class="modal-body">
                                                    <xsl:call-template name="tibetan-search-disclaimer"/>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </xsl:if>
                                
                                <!-- Search box -->
                                <div class="align-center bottom-margin">
                                    
                                    <div class="input-group">
                                        
                                        <input type="text" name="search" class="form-control" placeholder="Search..." size="60">
                                            <xsl:attribute name="value" select="$search-text"/>
                                        </input>
                                        
                                        <div class="input-group-btn">
                                            <button type="submit" class="btn btn-primary" title="Search">
                                                <i class="fa fa-search"/>
                                                <xsl:value-of select="' Search'"/>
                                            </button>
                                        </div>
                                        
                                    </div>
                                    
                                </div>
                                
                            </form>
                            
                            <xsl:choose>
                                <xsl:when test="$entities">
                                    
                                    <nav role="navigation" id="entity-list">
                                        <xsl:for-each select="$entities">
                                            
                                            <xsl:variable name="entity" select="."/>
                                            <xsl:variable name="entity-data" select="$entities-data[@ref eq $entity/@xml:id]"/>
                                            <xsl:variable name="related-entries" select="key('related-entries', $entity/m:instance/@id, $root)" as="element(m:entry)*"/>
                                            
                                            <xsl:if test="$entity[@xml:id] and $entity-data[@related-entries ! xs:integer(.) gt 0]">
                                                
                                                <xsl:variable name="item-id" select="$entity/@xml:id"/>
                                                
                                                <div class="list-item" id="{ $item-id }">
                                                    
                                                    <!-- Entity title -->
                                                    <a class="entity-title block-link opener-link log-click">
                                                        
                                                        <xsl:attribute name="href" select="common:internal-link(concat('/glossary/', $entity/@xml:id, '.html'), (if($tei-editor and $flagged gt '') then concat('flagged=', $flagged) else (), m:view-mode-parameter((),())), concat('#', $item-id, '-detail'), $root/m:response/@lang)"/>
                                                        <xsl:attribute name="data-ajax-target" select="concat('#', $item-id, '-detail')"/>
                                                        <xsl:attribute name="data-toggle-active" select="concat('#', $item-id)"/>
                                                        <xsl:attribute name="data-ajax-loading" select="'Loading detail...'"/>
                                                        
                                                        <div class="search-matches top-vertical-sm full-width">
                                                            <div>
                                                                
                                                                <div>
                                                                    
                                                                    <label class="sr-only">
                                                                        <xsl:value-of select="'Matches:'"/>
                                                                    </label>
                                                                    
                                                                    <ul class="list-inline inline-dots">
                                                                        <xsl:for-each select="$entity-data/m:term[@xml:lang eq $selected-term-lang/@id][m:search-match(text())]">
                                                                            
                                                                            <xsl:sort>
                                                                                <xsl:choose>
                                                                                    <xsl:when test="@xml:lang eq 'en'">
                                                                                        <xsl:value-of select="string-join(tokenize(text(), '\s+') ! lower-case(.) ! normalize-unicode(.) ! common:standardized-sa(.) ! replace(., '^\s*(The\s+|A\s+|An\s+)', '', 'i'), ' ')"/>
                                                                                    </xsl:when>
                                                                                    <xsl:when test="@xml:lang eq 'Sa-Ltn'">
                                                                                        <xsl:value-of select="string-join(tokenize(text(), '\s+') ! lower-case(.) ! normalize-unicode(.), ' ')"/>
                                                                                    </xsl:when>
                                                                                    <xsl:when test="@xml:lang eq 'Bo-Ltn'">
                                                                                        <xsl:value-of select="string-join(tokenize(text(), '\s+') ! lower-case(.), ' ')"/>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <xsl:value-of select="string-join(tokenize(text(), '\s+') ! normalize-unicode(.), ' ')"/>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </xsl:sort>
                                                                            
                                                                            <li>
                                                                                
                                                                                <xsl:choose>
                                                                                    <xsl:when test="position() eq 1">
                                                                                        <h2 class="no-bottom-margin">
                                                                                            <xsl:call-template name="glossary-term">
                                                                                                <xsl:with-param name="term-text" select="text()"/>
                                                                                                <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                                                <xsl:with-param name="term-type" select="@type"/>
                                                                                                <xsl:with-param name="term-status" select="@status"/>
                                                                                                <xsl:with-param name="glossary-type" select="@type"/>
                                                                                                <xsl:with-param name="interpolation" select="@flagged"/>
                                                                                            </xsl:call-template>
                                                                                        </h2>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <span class="h2">
                                                                                            <xsl:call-template name="glossary-term">
                                                                                                <xsl:with-param name="term-text" select="text()"/>
                                                                                                <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                                                <xsl:with-param name="term-type" select="@type"/>
                                                                                                <xsl:with-param name="term-status" select="@status"/>
                                                                                                <xsl:with-param name="glossary-type" select="@type"/>
                                                                                                <xsl:with-param name="interpolation" select="@flagged"/>
                                                                                            </xsl:call-template>
                                                                                        </span>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                                
                                                                            </li>
                                                                            
                                                                        </xsl:for-each>
                                                                    </ul>
                                                                    
                                                                </div>
                                                                
                                                                <xsl:for-each select="('bo','Sa-Ltn')[not(. = $selected-term-lang/@id)]">
                                                                    <xsl:variable name="title-lang" select="."/>
                                                                    <xsl:variable name="title-terms-lang" select="$entity-data/m:term[@xml:lang eq $title-lang]"/>
                                                                    <div>
                                                                        <ul class="list-inline inline-dots row-margin">
                                                                            <xsl:choose>
                                                                                <xsl:when test="$title-terms-lang">
                                                                                    <xsl:for-each select="$title-terms-lang">
                                                                                        <li>
                                                                                            <xsl:call-template name="glossary-term">
                                                                                                <xsl:with-param name="term-text" select="text()"/>
                                                                                                <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                                                <xsl:with-param name="term-type" select="@type"/>
                                                                                                <xsl:with-param name="term-status" select="@status"/>
                                                                                                <xsl:with-param name="glossary-type" select="@type"/>
                                                                                                <xsl:with-param name="interpolation" select="@flagged"/>
                                                                                            </xsl:call-template>
                                                                                        </li>
                                                                                    </xsl:for-each>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <li>
                                                                                        <xsl:call-template name="text">
                                                                                            <xsl:with-param name="global-key" select="'glossary.term-empty-' || lower-case($title-lang)"/>
                                                                                        </xsl:call-template>
                                                                                    </li>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </ul>
                                                                    </div>
                                                                </xsl:for-each>
                                                                
                                                            </div>
                                                            
                                                            
                                                            <div class="text-right-sm">
                                                                
                                                                <!-- Types -->
                                                                <div>
                                                                    <xsl:call-template name="entity-types-list">
                                                                        <xsl:with-param name="entity" select="$entity"/>
                                                                    </xsl:call-template>
                                                                </div>
                                                                
                                                                <!-- Publication count -->
                                                                <div class="row-margin">
                                                                    <span class="nowrap">
                                                                        <span class="badge-text">
                                                                            <xsl:value-of select="'Publications: '"/>
                                                                        </span>
                                                                        <span class="badge badge-notification">
                                                                            <xsl:value-of select="$entity-data/@related-entries"/>
                                                                        </span>
                                                                    </span>
                                                                </div>
                                                                
                                                            </div>
                                                            
                                                        </div>
                                                        
                                                        
                                                    </a>
                                                    
                                                    <!-- Entity body -->
                                                    <div id="{ concat($item-id, '-body') }">
                                                        
                                                        <xsl:call-template name="editor-summary">
                                                            <xsl:with-param name="entity" select="$entity"/>
                                                        </xsl:call-template>
                                                        
                                                        <!-- Ajax data here -->
                                                        <div class="entity-detail collapse persist" id="{ concat($item-id, '-detail') }"/>
                                                        
                                                    </div>
                                                    
                                                </div>
                                                
                                            </xsl:if>
                                            
                                        </xsl:for-each>
                                    </nav>
                                    
                                    <!-- Pagination -->
                                    <xsl:copy-of select="common:pagination(m:request/@first-record, m:request/@records-per-page, m:entities/@count-entities, $page-url)"/>
                                    
                                </xsl:when>
                                
                                <!-- No results -->
                                <xsl:otherwise>
                                    <div class="text-center text-muted">
                                        <xsl:choose>
                                            
                                            <!-- Nothing found -->
                                            <xsl:when test="$search-text gt ''">
                                                
                                                <p class="italic">
                                                    <xsl:value-of select="'Try a different search'"/>
                                                </p>
                                                
                                                <ul class="list-inline inline-dots">
                                                    <xsl:for-each select="/m:response/m:request/m:term-langs/m:lang[not(@selected)]">
                                                        <li>
                                                            <a class="underline">
                                                                <xsl:attribute name="href" select="common:internal-link(concat('/glossary/search.html?search=', $search-text), (concat('term-lang=', @id), $selected-type ! concat('term-type[]=', @id), m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                                                <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                                <xsl:value-of select="text()"/>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                    <xsl:if test="/m:response/m:request/m:entity-types/m:type[@glossary-type][not(@selected)]">
                                                        <li>
                                                            <a class="underline">
                                                                <xsl:attribute name="href" select="common:internal-link(concat('/glossary/search.html?search=', $search-text), (concat('term-lang=', $selected-term-lang/@id), m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                                                <xsl:attribute name="title" select="'Search'"/>
                                                                <xsl:value-of select="'All types'"/>
                                                            </a>
                                                        </li>
                                                    </xsl:if>
                                                </ul>
                                                
                                            </xsl:when>
                                            
                                            <!-- Nothing selected -->
                                            <xsl:when test="not($selected-letter)">
                                                
                                                <p class="italic">
                                                    <xsl:value-of select="'~ Enter some search criteria ~'"/>
                                                </p>
                                                
                                            </xsl:when>
                                            
                                            <!-- No matches -->
                                            <xsl:otherwise>
                                                
                                                <p class="italic">
                                                    <xsl:value-of select="'~ No matches for this query ~'"/>
                                                </p>
                                                
                                            </xsl:otherwise>
                                            
                                        </xsl:choose>
                                    </div>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </div>
            </main>
            
            <xsl:call-template name="attestation-types-footer"/>
            
            <xsl:call-template name="tei-editor-footer"/>
            
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
    
    <xsl:function name="m:search-match" as="xs:boolean">
        
        <xsl:param name="term" as="xs:string*"/>
        
        <!-- Sanitise the term -->
        <xsl:variable name="match-term" as="xs:string">
            <xsl:choose>
                <xsl:when test="$selected-term-lang/@id eq 'en'">
                    <xsl:value-of select="string-join(tokenize($term, '\s+') ! lower-case(.) ! normalize-unicode(.) ! common:standardized-sa(.) ! replace(., '^\s*(The\s+|A\s+|An\s+)', '', 'i'), ' ')"/>
                </xsl:when>
                <xsl:when test="$selected-term-lang/@id eq 'Sa-Ltn'">
                    <xsl:choose>
                        <xsl:when test="$selected-letter">
                            <xsl:value-of select="string-join(tokenize($term, '\s+') ! lower-case(.) ! normalize-unicode(.), ' ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string-join(tokenize($term, '\s+') ! lower-case(.) ! normalize-unicode(.) ! common:standardized-sa(.) ! replace(., '­',''), ' ')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$selected-term-lang/@id eq 'Bo-Ltn'">
                    <xsl:value-of select="string-join(tokenize($term, '\s+') ! lower-case(.), ' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string-join(tokenize($term, '\s+') ! normalize-unicode(.), ' ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="match-regex" as="xs:string">
            <xsl:choose>
                <xsl:when test="$selected-letter">
                    <xsl:value-of select="$selected-letter/@regex"/>
                </xsl:when>
                <xsl:when test="$selected-term-lang/@id eq 'bo' and $search-text-bo">
                    <xsl:value-of select="concat('(^|\s*)(', string-join(tokenize($search-text-bo, '\s+') ! common:escape-for-regex(.), '|'), ')')"/>
                </xsl:when>
                <xsl:when test="$selected-term-lang/@id eq 'en'">
                    <xsl:value-of select="concat('(^|\s*)(', string-join(tokenize($search-text, '\s+') ! lower-case(.) ! normalize-unicode(.) ! common:standardized-sa(.) ! common:escape-for-regex(.), '|'), ')')"/>
                </xsl:when>
                <xsl:when test="$selected-term-lang/@id eq 'Sa-Ltn'">
                    <xsl:value-of select="concat('(^|\s*)(', string-join(tokenize($search-text, '\s+') ! lower-case(.) ! normalize-unicode(.) ! common:standardized-sa(.) ! replace(., '­','') ! common:escape-for-regex(.), '|'), ')')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('(^|\s*)(', string-join(tokenize($search-text, '\s+') ! common:escape-for-regex(.), '|'), ')')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="matches($match-term, $match-regex, 'i')"/>
        
    </xsl:function>
    
    <xsl:template name="tibetan-search-disclaimer">
        <p>
            <xsl:value-of select="'The sorting of Tibetan terms conforms to how they are spelled out in Tibetan, rather than the traditional arrangement based on the root letter. '"/>
            <xsl:value-of select="'Therefore a term like '"/>
            <span class="text-bo">
                <xsl:value-of select="'མདོ།'"/>
            </span>
            <xsl:value-of select="'  (spelled: '"/>
            <span class="text-bo">
                <xsl:value-of select="'མ་'"/>
            </span>
            <xsl:value-of select="' + '"/>
            <span class="text-bo">
                <xsl:value-of select="'ད་'"/>
            </span>
            <xsl:value-of select="' + '"/>
            <span class="text-bo">
                <xsl:value-of select="'ོ'"/>
            </span>
            <xsl:value-of select="') will be found under '"/>
            <span class="text-bo">
                <xsl:value-of select="'མ་'"/>
            </span>
            <xsl:value-of select="'. '"/>
            <xsl:value-of select="'The same applies to superscribed letters, like '"/>
            <xsl:value-of select="'རྡོ།'"/>
            <xsl:value-of select="' which will be listed as if spelled '"/>
            <span class="text-bo">
                <xsl:value-of select="'ར་'"/>
            </span>
            <xsl:value-of select="' + '"/>
            <span class="text-bo">
                <xsl:value-of select="'ད་'"/>
            </span>
            <xsl:value-of select="' + '"/>
            <span class="text-bo">
                <xsl:value-of select="'ོ'"/>
            </span>
            <xsl:value-of select="'.'"/>
        </p>
    </xsl:template>
    
</xsl:stylesheet>