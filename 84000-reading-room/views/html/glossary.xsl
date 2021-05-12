<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>
    <xsl:variable name="entities" select="/m:response/m:browse-entities/m:entity"/>
    <xsl:variable name="show-entity" select="/m:response/m:show-entity/m:entity[1]"/>
    <xsl:variable name="selected-type" select="/m:response/m:request/m:glossary-types/m:type[@selected eq 'selected']"/>
    <xsl:variable name="selected-term-lang" select="/m:response/m:request/m:term-langs/m:lang[@selected eq 'selected']"/>
    <xsl:variable name="search-text" select="/m:response/m:request/m:search"/>
    <xsl:variable name="page-title">
        <xsl:choose>
            <xsl:when test="count($entities) le 1 and $show-entity">
                <xsl:value-of select="concat('Glossary entry for: ', $show-entity/m:label[@primary eq 'true']/data())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Glossary filtered for: ', string-join(($selected-type/m:label[@type eq 'plural']/text(), $selected-term-lang/text(), $search-text/text() ! concat('&#34;', ., '&#34;')), '; '))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="page-url">
        <xsl:choose>
            <xsl:when test="count($entities) le 1 and $show-entity">
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('entity-id=', $show-entity/@xml:id)), '&amp;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('type=', $selected-type/@id),concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text/text())), '&amp;')"/>
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
                                <xsl:if test="m:search/m:request[text()]">
                                    <li>
                                        <xsl:value-of select="m:search/m:request/text()"/>
                                    </li>
                                </xsl:if>
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
            
            <main class="content-band">
                <div class="container">
                    
                    <!-- Page title -->
                    <div class="section-title row">
                        <div class="col-sm-offset-2 col-sm-8">
                            <div class="h1 title main-title">
                                <xsl:value-of select="'84000 Glossary'"/>
                            </div>
                            <hr/>
                            <p>
                                <xsl:value-of select="'Our combined glossary of terms, people, places and texts.'"/>
                            </p>
                            <hr/>
                        </div>
                    </div>
                    
                    <!-- Filter options -->
                    <form action="/glossary.html" method="post" role="search" class="form-horizontal">
                        <div class="row">
                            
                            <!-- Search form -->
                            <div class="col-md-4 col-lg-3">
                                <div id="search-controls" class="input-group full-width">
                                    <input type="text" name="search" class="form-control" placeholder="Search...">
                                        <xsl:if test="string-length($search-text) gt 1">
                                            <xsl:attribute name="value" select="$search-text"/>
                                        </xsl:if>
                                    </input>
                                    <span class="input-group-btn">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa fa-search"/>
                                        </button>
                                    </span>
                                </div>
                            </div>
                            
                            <!-- Nav pills -->
                            <div class="col-md-8 col-lg-9">
                                <div class="center-vertical-md full-width">
                                    
                                    <!-- Type tabs -->
                                    <div>
                                        
                                        <ul class="nav nav-pills visible-lg-block">
                                            
                                            <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text))"/>
                                            
                                            <xsl:for-each select="m:request/m:glossary-types/m:type">
                                                
                                                <li role="presentation">
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="class" select="'active'"/>
                                                    </xsl:if>
                                                    <a>
                                                        <xsl:attribute name="href" select="common:internal-link('/glossary.html', (concat('type=', @id), $internal-link-attrs) , '', /m:response/@lang)"/>
                                                        <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                    </a>
                                                </li>
                                                
                                            </xsl:for-each>
                                            
                                            <li role="presentation">
                                                <xsl:if test="not($selected-type)">
                                                    <xsl:attribute name="class" select="'active'"/>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href" select="common:internal-link('/glossary.html', (concat('type=', ''), $internal-link-attrs), '', /m:response/@lang)"/>
                                                    <xsl:value-of select="'All types'"/>
                                                </a>
                                            </li>
                                            
                                        </ul>
                                        
                                        <select name="type" class="form-control hidden-lg">
                                            <xsl:for-each select="m:request/m:glossary-types/m:type">
                                                
                                                <option>
                                                    <xsl:attribute name="value" select="@id"/>
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                </option>
                                                
                                            </xsl:for-each>
                                            
                                            <option>
                                                <xsl:attribute name="value" select="''"/>
                                                <xsl:if test="not($selected-type)">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'All types'"/>
                                            </option>
                                            
                                        </select>
                                        
                                    </div>
                                    
                                    <!-- Language tabs -->
                                    <div>
                                        
                                        <ul class="nav nav-pills visible-lg-block">
                                            
                                            <xsl:variable name="internal-link-attrs" select="(concat('type=', $selected-type/@id), concat('search=', $search-text))"/>
                                            
                                            <xsl:for-each select="m:request/m:term-langs/m:lang">
                                                
                                                <li role="presentation">
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="class" select="'active'"/>
                                                    </xsl:if>
                                                    <a>
                                                        <xsl:attribute name="href" select="common:internal-link('/glossary.html', (concat('term-lang=', @id), $internal-link-attrs) , '', /m:response/@lang)"/>
                                                        <xsl:value-of select="text()"/>
                                                    </a>
                                                </li>
                                                
                                            </xsl:for-each>
                                            
                                        </ul>
                                        
                                        <select name="term-lang" class="form-control hidden-lg">
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
                                    
                                </div>
                            </div>
                            
                        </div>
                    </form>
                    
                    <!-- Letter tabs -->
                    <ul class="nav nav-tabs sml-tabs top-margin hidden-xs hidden-sm" role="tablist">
                        <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
                        <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', /m:response/m:request/@term-lang), concat('type=', /m:response/m:request/@type))"/>
                        <xsl:for-each select="1 to string-length($alphabet)">
                            <xsl:variable name="letter" select="substring($alphabet, ., 1)"/>
                            <li role="presentation">
                                <xsl:if test="$letter eq upper-case($root/m:response/m:request/m:search)">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?search=', $letter), $internal-link-attrs, '', $root/m:response/@lang)"/>
                                    <xsl:value-of select="$letter"/>
                                </a>
                            </li>
                        </xsl:for-each>
                    </ul>
                    
                    <!-- Title -->
                    <h1 class="sr-only">
                        <xsl:value-of select="$page-title"/>
                    </h1>
                    
                    <!-- Results -->
                    <div id="glossary-results" class="row">
                        <xsl:choose>
                            <xsl:when test="$show-entity | $entities">
                                
                                <!-- Entity list -->
                                <div id="entity-list" class="col-md-4 col-lg-3">
                                    <xsl:if test="$entities">
                                        
                                        <div class="results-summary">
                                            <span>
                                                <span class="badge badge-notification">
                                                    <xsl:value-of select="count($entities)"/>
                                                </span>
                                            </span>
                                            <span class="btn-round-text">
                                                <xsl:choose>
                                                    <xsl:when test="count($entities) eq 1">
                                                        <xsl:value-of select="' match'"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="' matches'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </span>
                                        </div>
                                        
                                        <nav role="navigation">
                                            <div class="results-list">
                                                <xsl:for-each select="$entities">
                                                    
                                                    <xsl:variable name="entity" select="."/>
                                                    <xsl:variable name="primary-label" select="($entity/m:label[@primary eq 'true'], $entity/m:label[1])[1]"/>
                                                    <xsl:variable name="primary-transliterated" select="$entity/m:label[@primary-transliterated eq 'true']"/>
                                                    <xsl:variable name="active-item" select="(position() eq 1)" as="xs:boolean"/>
                                                    
                                                    <a class="results-list-item">
                                                        
                                                        <xsl:if test="$active-item">
                                                            <xsl:attribute name="class" select="'results-list-item active'"/>
                                                        </xsl:if>
                                                        <xsl:attribute name="href" select="concat('glossary.html?entity-id=', @xml:id, '#', @xml:id, '-detail')"/>
                                                        <xsl:attribute name="data-ajax-target" select="'#entity-detail .entity-detail-container'"/>
                                                        <xsl:attribute name="data-toggle-active" select="'_self'"/>
                                                        
                                                        <h3>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="string-join(('results-list-item-heading', common:lang-class($primary-label/@xml:lang)),' ')"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="normalize-space($primary-label/text())"/>
                                                        </h3>
                                                        
                                                        <xsl:if test="$primary-transliterated">
                                                            <p>
                                                                <xsl:attribute name="class">
                                                                    <xsl:value-of select="string-join(('text-muted small', common:lang-class($primary-transliterated/@xml:lang)),' ')"/>
                                                                </xsl:attribute>
                                                                <xsl:value-of select="normalize-space($primary-transliterated/text())"/>
                                                            </p>
                                                        </xsl:if>
                                                        
                                                        <ul class="list-unstyled">
                                                            <xsl:for-each-group select="$entity/m:instance/m:item/m:term[@xml:lang eq $selected-term-lang/@id]" group-by="common:standardized-sa(text())">
                                                                <li class="small">
                                                                    <xsl:choose>
                                                                        <xsl:when test="matches(common:standardized-sa(data()), concat('(^|\s+)', string-join(tokenize($search-text, '\s+') ! common:standardized-sa(.) ! common:escape-for-regex(.), '.*\s+'), ''), 'i')">
                                                                            <mark>
                                                                                <xsl:value-of select="text()"/>
                                                                            </mark>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="text()"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </li>
                                                            </xsl:for-each-group>
                                                        </ul>
                                                        
                                                    </a>
                                                </xsl:for-each>
                                            </div>
                                        </nav>    
                                        
                                    </xsl:if>
                                </div>
                                
                                <!-- Selected entity -->
                                <div id="entity-selected" class="col-md-8 col-lg-9">
                                    <xsl:if test="$show-entity">
                                        <div id="entity-detail">
                                            
                                            <xsl:attribute name="class" select="'search-result collapse in persist'"/>
                                            
                                            <!-- Show first record by default -->
                                            <xsl:variable name="primary-label" select="($show-entity/m:label[@primary eq 'true'], $show-entity/m:label[1])[1]"/>
                                            <xsl:variable name="primary-transliterated" select="$show-entity/m:label[@primary-transliterated eq 'true']"/>
                                            
                                            <div class="entity-detail-container replace">
                                                <xsl:attribute name="id" select="concat($show-entity/@xml:id, '-detail')"/>
                                                
                                                <div class="entity-detail-header">
                                                    <h2>
                                                        
                                                        <span>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="string-join(((), common:lang-class($primary-label/@xml:lang)),' ')"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="normalize-space($primary-label/text())"/>
                                                        </span>
                                                        
                                                        <xsl:for-each-group select="$show-entity/m:instance/m:item" group-by="@type">
                                                            <xsl:variable name="item" select="."/>
                                                            <xsl:value-of select="' '"/>
                                                            <span class="label label-info">
                                                                <xsl:value-of select="/m:response/m:request/m:glossary-types/m:type[@id eq $item[1]/@type]/m:label[@type eq 'singular']"/>
                                                            </span>
                                                        </xsl:for-each-group>
                                                        
                                                    </h2>
                                                    
                                                    <xsl:if test="$primary-transliterated">
                                                        <p>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="string-join(('text-muted', common:lang-class($primary-transliterated/@xml:lang)),' ')"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="normalize-space($primary-transliterated/text())"/>
                                                        </p>
                                                    </xsl:if>
                                                    
                                                    <!-- Entity definition -->
                                                    <xsl:if test="$show-entity[m:content[@type eq 'glossary-definition']]">
                                                        <xsl:for-each select="$show-entity/m:content[@type eq 'glossary-definition']">
                                                            <p>                                                              
                                                                <xsl:apply-templates select="node()"/>
                                                            </p>
                                                        </xsl:for-each>
                                                    </xsl:if>
                                                </div>
                                                
                                                
                                                <div>
                                                    
                                                    <div class="sml-margin bottom">
                                                        <span class="badge badge-notification">
                                                            <xsl:value-of select="count($show-entity/m:instance/m:item)"/>
                                                        </span>
                                                        <span class="badge-text">
                                                            <xsl:choose>
                                                                <xsl:when test="count($show-entity/m:instance/m:item) eq 1">
                                                                    <xsl:value-of select="' translation'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="' translations'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </span>
                                                    </div>
                                                    
                                                    <xsl:for-each select="$show-entity/m:instance/m:item">
                                                        
                                                        <xsl:variable name="item" select="."/>
                                                        <xsl:variable name="item-text" select="$item/m:text"/>
                                                        
                                                        <div class="translation scrolling">
                                                            
                                                            <!-- Text -->
                                                            <div class="rw">
                                                                <div class="gtr">
                                                                    <a>
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $item-text/@id, '.html')"/>
                                                                        <xsl:attribute name="target" select="$item-text/@id"/>
                                                                        <xsl:apply-templates select="$item-text/m:toh/text()"/>
                                                                    </a>
                                                                </div>
                                                                <div class="text-muted">
                                                                    
                                                                    <xsl:apply-templates select="$item-text/m:title/text()"/>
                                                                    
                                                                    <xsl:if test="/m:response/m:request[@view-mode eq 'editor'] and $environment/m:url[@id eq 'operations']">
                                                                        <xsl:value-of select="' / '"/>
                                                                        <a target="84000-glossary-tool" class="underline small">
                                                                            <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/data(), '/glossary.html?resource-id=', $item-text/@id, '&amp;glossary-id=', $item/@id, '&amp;max-records=1')"/>
                                                                            <xsl:value-of select="'glossary editor'"/>
                                                                        </a>
                                                                    </xsl:if>
                                                                    
                                                                </div>
                                                            </div>
                                                            
                                                            <!-- HTML snippet -->
                                                            <xsl:apply-templates select="$item/xhtml:section"/>
                                                            
                                                        </div>   
                                                        
                                                    </xsl:for-each>
                                                    
                                                </div>
                                                
                                            </div>
                                            
                                        </div>
                                    </xsl:if>
                                </div>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <div class="col-sm-12">
                                    <p class="text-muted text-center italic">
                                        <xsl:value-of select="'No results found for this selection'"/>
                                    </p>    
                                </div>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </div>
                
                </div>
            </main>
            
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
    
    <!-- Localise links in html -->
    <xsl:template match="xhtml:*">
        <xsl:element name="{node-name(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="xhtml:a">
        
        <xsl:variable name="link" select="."/>
        
        <xsl:element name="a">
            
            <xsl:copy-of select="@*[not(name(.) = ('href', 'data-bookmark'))]"/>
            
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$link[@data-href-relative]">
                        <xsl:value-of select="concat($reading-room-path, $link/@data-href-relative)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$link/@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:sequence select="node()"/>
            
        </xsl:element>
        
    </xsl:template>
    
    
</xsl:stylesheet>