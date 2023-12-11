<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/glossary.xsl"/>
    
    <xsl:variable name="request-entity" select="$entities[@xml:id eq /m:response/m:request/@resource-id]" as="element(m:entity)?"/>
    
    <xsl:variable name="request-entity-data" as="element(m:entity-data)?">
        <xsl:call-template name="entity-data">
            <xsl:with-param name="entity" select="$request-entity"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="page-title" select="concat(normalize-space($request-entity-data/m:label[@type eq 'primary']/text()), ' | Glossary of Terms')" as="xs:string"/>
    
    <xsl:variable name="page-url" select="concat($reading-room-path, '/glossary/', $request-entity/@xml:id, '.html')" as="xs:string"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <!-- Title band -->
            <div class="title-band hidden-iframe">
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
                    <div class="section-title row hidden-iframe">
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
                    <div class="hidden-iframe">
                        <xsl:call-template name="glossary-tabs">
                            <xsl:with-param name="page-url" select="$page-url"/>
                            <xsl:with-param name="term-langs" select="m:request/m:term-langs"/>
                            <xsl:with-param name="entity-flags" select="m:entity-flags"/>
                            <xsl:with-param name="entry-label" select="$request-entity-data/m:label[@type eq 'primary']"/>
                        </xsl:call-template>
                    </div>
                    
                    <xsl:choose>
                        <xsl:when test="$request-entity">
                            
                            <div id="entity-requested">
                                
                                <xsl:variable name="related-entries" select="key('related-entries', $request-entity/m:instance/@id, $root)"/>
                                <xsl:variable name="related-instances" select="/m:response/m:entities/m:related/m:entity[@xml:id = $request-entity/m:relation/@id or m:relation/@id = $request-entity/@xml:id]/m:instance"/>
                                <xsl:variable name="related-entity-pages" select="key('related-pages', $request-entity/m:instance/@id | $related-instances/@id, $root)" as="element(m:page)*"/>
                                <xsl:variable name="related-entity-entries" select="key('related-entries', $related-instances/@id, $root)" as="element(m:entry)*"/>
                                <xsl:variable name="item-id" select="$request-entity/@xml:id"/>
                                
                                <div id="{ $item-id }">
                                    
                                    <!-- Header -->
                                    <div class="entity-title">
                                        <div class="top-vertical full-width">
                                            
                                            <!-- Title -->
                                            <div>
                                                
                                                <ul class="list-inline inline-dots term-list">
                                                    <xsl:for-each select="$request-entity-data/m:term[@xml:lang eq 'bo']">
                                                        
                                                        <xsl:sort select="string-join(tokenize(text(), '\s+') ! normalize-unicode(.), ' ')"/>
                                                        
                                                        <li>
                                                            <xsl:choose>
                                                                <xsl:when test="position() eq 1">
                                                                    <h2 class="no-bottom-margin inline-block">
                                                                        <xsl:call-template name="glossary-term">
                                                                            <xsl:with-param name="term-text" select="text()"/>
                                                                            <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                            <!--<xsl:with-param name="term-type" select="@type"/>-->
                                                                            <xsl:with-param name="term-status" select="@status"/>
                                                                            <xsl:with-param name="glossary-type" select="@glossary-type"/>
                                                                            <xsl:with-param name="interpolation" select="@flagged"/>
                                                                        </xsl:call-template>
                                                                    </h2>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <span class="h2">
                                                                        <xsl:call-template name="glossary-term">
                                                                            <xsl:with-param name="term-text" select="text()"/>
                                                                            <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                            <!--<xsl:with-param name="term-type" select="@type"/>-->
                                                                            <xsl:with-param name="term-status" select="@status"/>
                                                                            <xsl:with-param name="glossary-type" select="@glossary-type"/>
                                                                            <xsl:with-param name="interpolation" select="@flagged"/>
                                                                        </xsl:call-template>
                                                                    </span>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </li>
                                                        
                                                    </xsl:for-each>
                                                </ul>
                                                
                                                <xsl:for-each select="('Bo-Ltn','Sa-Ltn')">
                                                    <xsl:variable name="title-lang" select="."/>
                                                    <xsl:variable name="title-terms-lang" select="$request-entity-data/m:term[@xml:lang eq $title-lang]"/>
                                                    <xsl:if test="$title-terms-lang">
                                                        <ul class="list-inline inline-dots term-list">
                                                            <xsl:for-each select="$title-terms-lang">
                                                                <li>
                                                                    <xsl:call-template name="glossary-term">
                                                                        <xsl:with-param name="term-text" select="text()"/>
                                                                        <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                        <!--<xsl:with-param name="term-type" select="@type"/>-->
                                                                        <xsl:with-param name="term-status" select="@status"/>
                                                                        <xsl:with-param name="glossary-type" select="@glossary-type"/>
                                                                        <xsl:with-param name="interpolation" select="@flagged"/>
                                                                    </xsl:call-template>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </xsl:if>
                                                </xsl:for-each>
                                                
                                            </div>
                                            
                                            <!-- Types -->
                                            <div class="text-right">
                                                
                                                <div class="sml-margin bottom">
                                                    <xsl:call-template name="entity-types-list">
                                                        <xsl:with-param name="entity" select="$request-entity"/>
                                                    </xsl:call-template>
                                                </div>
                                                
                                                <div>
                                                    <span class="nowrap">
                                                        <span class="badge-text">
                                                            <xsl:value-of select="'Publications: '"/>
                                                        </span>
                                                        <span class="badge badge-notification">
                                                            <xsl:value-of select="$request-entity-data/@related-entries"/>
                                                        </span>
                                                    </span>
                                                </div>
                                                
                                            </div>
                                            
                                        </div>
                                    </div>
                                    
                                    <div class="entity-body" id="{ concat($item-id, '-body') }">
                                        
                                        <xsl:call-template name="editor-summary">
                                            <xsl:with-param name="entity" select="$request-entity"/>
                                            <xsl:with-param name="page-url" select="$page-url"/>
                                        </xsl:call-template>
                                        
                                        <div class="entity-detail collapse in persist" id="{ concat($item-id, '-detail') }">
                                            
                                            <div>
                                                
                                                <!-- Entity definition -->
                                                <xsl:if test="$request-entity/m:content[@type eq 'glossary-definition'][node()]">
                                                    <xsl:for-each select="$request-entity/m:content[@type eq 'glossary-definition']">
                                                        <p class="definition">
                                                            <xsl:apply-templates select="node()"/>
                                                        </p>
                                                    </xsl:for-each>
                                                </xsl:if>
                                                
                                                <!-- Glossary entries: grouped by translation -->
                                                <label class="sml-margin bottom">
                                                    <xsl:value-of select="'Translated as:'"/>
                                                </label>
                                                <div id="{ concat($item-id, '-translations') }" class="entity-detail-accordion">
                                                    
                                                    <xsl:if test="$related-entries">
                                                        
                                                        <xsl:for-each-group select="$related-entries" group-by="m:sort-term">
                                                            
                                                            <xsl:sort select="count(current-group())" order="descending"/>
                                                            <xsl:sort select="m:sort-term"/>
                                                            
                                                            <xsl:variable name="term-group-index" select="position()"/>
                                                            <xsl:variable name="term-group" select="current-group()"/>
                                                            <xsl:variable name="term-group-id" select="concat('term-group-', $request-entity/@xml:id, '-', $term-group-index)"/>
                                                            
                                                            <xsl:call-template name="expand-item">
                                                                <xsl:with-param name="accordion-selector" select="concat('#', $item-id, '-translations')"/>
                                                                <xsl:with-param name="id" select="$term-group-id"/>
                                                                <xsl:with-param name="title-opener" select="true()"/>
                                                                <xsl:with-param name="active" select="if(count($related-entries) eq count($term-group)) then true() else false()"/>
                                                                <!--<xsl:with-param name="persist" select="true()"/>-->
                                                                <xsl:with-param name="title">
                                                                    <div class="center-vertical align-left">
                                                                        
                                                                        <div>
                                                                            <span class="badge badge-notification">
                                                                                <xsl:value-of select="count(current-group())"/>
                                                                            </span>
                                                                        </div>
                                                                        
                                                                        <div>
                                                                            <h3>
                                                                                <xsl:variable name="translation-term" select="m:term[@xml:lang eq 'en'][1]"/>
                                                                                <xsl:call-template name="glossary-term">
                                                                                    <xsl:with-param name="term-text" select="$translation-term/text()"/>
                                                                                    <xsl:with-param name="term-lang" select="$translation-term/@xml:lang"/>
                                                                                    <xsl:with-param name="term-type" select="$translation-term/@type"/>
                                                                                    <xsl:with-param name="term-status" select="$translation-term/@status"/>
                                                                                    <xsl:with-param name="glossary-type" select="@type"/>
                                                                                </xsl:call-template>
                                                                            </h3>
                                                                        </div>
                                                                        
                                                                        <!-- Summary for content editors -->
                                                                        <xsl:if test="$tei-editor">
                                                                            <div>
                                                                                <ul class="list-inline inline-dots">
                                                                                    
                                                                                    <xsl:variable name="term-group-instances" select="$request-entity/m:instance[@id = $term-group/@id]"/>
                                                                                    <xsl:variable name="term-group-instances-flagged" select="$term-group-instances[m:flag]"/>
                                                                                    <xsl:variable name="term-group-related-entries" select="key('related-entries', $term-group-instances/@id, $root)"/>
                                                                                    <xsl:variable name="term-group-related-entries-excluded" select="$term-group-related-entries[parent::m:text/@glossary-status eq 'excluded']"/>
                                                                                    <xsl:variable name="term-group-related-entries-no-definition" select="$term-group-related-entries[not(m:definition[descendant::text()[normalize-space()]])]"/>
                                                                                    <xsl:variable name="entity-definition" select="$request-entity/m:content[@type eq 'glossary-definition'][node()]"/>
                                                                                    <xsl:variable name="term-group-related-entries-use-definition" select="if($entity-definition) then $term-group-related-entries[m:definition/@use-definition = ('both','append','prepend','override')] | $term-group-related-entries-no-definition else ()"/>
                                                                                    
                                                                                    <li>
                                                                                        <span class="small text-muted">
                                                                                            <xsl:if test="$term-group-related-entries-use-definition">
                                                                                                <xsl:attribute name="class" select="'small text-warning'"/>
                                                                                            </xsl:if>
                                                                                            <xsl:value-of select="count($term-group-related-entries-use-definition)"/>
                                                                                            <xsl:value-of select="if (count($term-group-related-entries-use-definition) eq 1) then ' entry displays entity definition' else ' entries display entity definition'"/>
                                                                                        </span>
                                                                                    </li>
                                                                                    
                                                                                    <li>
                                                                                        <span class="small text-muted">
                                                                                            <xsl:if test="$term-group-related-entries-excluded">
                                                                                                <xsl:attribute name="class" select="'small text-warning'"/>
                                                                                            </xsl:if>
                                                                                            <xsl:value-of select="count($term-group-related-entries-excluded)"/>
                                                                                            <xsl:value-of select="if (count($term-group-related-entries-excluded) eq 1) then ' entry in an excluded text' else ' entries in excluded texts'"/>
                                                                                        </span>
                                                                                    </li>
                                                                                    
                                                                                    <li>
                                                                                        <span class="small text-muted">
                                                                                            <xsl:if test="$term-group-instances-flagged">
                                                                                                <xsl:attribute name="class" select="'small text-warning'"/>
                                                                                            </xsl:if>
                                                                                            <xsl:value-of select="count($term-group-instances-flagged)"/>
                                                                                            <xsl:value-of select="if (count($term-group-instances-flagged) eq 1) then ' entry flagged' else ' entries flagged'"/>
                                                                                        </span>
                                                                                    </li>
                                                                                    
                                                                                </ul>
                                                                            </div>
                                                                        </xsl:if>
                                                                        
                                                                    </div>
                                                                </xsl:with-param>
                                                                <xsl:with-param name="content">
                                                                    <div class="translation-result">
                                                                        
                                                                        <!-- Group by type (translation/knowledgebase) -->
                                                                        <xsl:for-each-group select="$term-group" group-by="parent::m:text/@type">
                                                                            
                                                                            <xsl:variable name="text-type" select="parent::m:text/@type"/>
                                                                            <xsl:variable name="text-type-entries" select="current-group()"/>
                                                                            <xsl:variable name="text-type-related-texts" select="/m:response/m:entities/m:related/m:text[m:entry/@id = $text-type-entries/@id]"/>
                                                                            
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
                                                                            
                                                                        </xsl:for-each-group>
                                                                        
                                                                    </div>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                            
                                                        </xsl:for-each-group>
                                                        
                                                    </xsl:if>
                                                    
                                                </div>
                                                
                                                <!-- Related pages and entries -->
                                                <xsl:if test="$related-entity-entries or $related-entity-pages">
                                                    
                                                    <div class="entity-detail-related">
                                                        
                                                        <!-- Related pages -->
                                                        <xsl:if test="$related-entity-pages">
                                                            <div>
                                                                <span class="badge badge-notification badge-muted">
                                                                    <xsl:value-of select="count($related-entity-pages)"/>
                                                                </span>
                                                                <span class="badge-text">
                                                                    <xsl:value-of select="'Related knowledge base articles: '"/>
                                                                </span>
                                                            </div>
                                                            
                                                            <xsl:for-each select="$related-entity-pages">
                                                                
                                                                <xsl:variable name="kb-page" select="."/>
                                                                <xsl:variable name="main-title" select="$kb-page/m:titles ! (m:title[@type eq 'articleTitle'], m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], m:title[@type eq 'mainTitle'])[1]"/>
                                                                
                                                                <div class="entity-list-item">
                                                                    <h4>
                                                                        <a target="_self">
                                                                            <xsl:attribute name="href" select="concat('/knowledgebase/', $kb-page/@kb-id, '.html')"/>
                                                                            <xsl:value-of select="normalize-space($main-title/text())"/>
                                                                        </a>
                                                                    </h4>
                                                                </div>
                                                                
                                                            </xsl:for-each>
                                                                
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="$related-entity-entries">
                                                            
                                                            <xsl:variable name="related-entries-entities" select="/m:response/m:entities/m:related/m:entity[m:instance/@id = $related-entity-entries/@id]"/>
                                                            
                                                            <div>
                                                                <span class="badge badge-notification badge-muted">
                                                                    <xsl:value-of select="count($related-entries-entities)"/>
                                                                </span>
                                                                <span class="badge-text">
                                                                    <xsl:value-of select="' Related glossary entries:'"/>
                                                                </span>
                                                            </div>
                                                            
                                                            <xsl:for-each select="$related-entries-entities">
                                                                
                                                                <xsl:variable name="related-entity" select="."/>
                                                                <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                                    <xsl:call-template name="entity-data">
                                                                        <xsl:with-param name="entity" select="$related-entity"/>
                                                                    </xsl:call-template>
                                                                </xsl:variable>
                                                                
                                                                <div class="entity-list-item">
                                                                    
                                                                    <h4 class="{ common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang) }">
                                                                        <a>
                                                                            
                                                                            <!-- Link to the glossary, checking if it's already included in this page -->
                                                                            <xsl:attribute name="href" select="concat('/glossary/', $related-entity/@xml:id, '.html', '#', $related-entity/@xml:id)"/>
                                                                            <xsl:attribute name="data-href-override" select="concat('#', $related-entity/@xml:id)"/>
                                                                            <xsl:attribute name="data-postscroll-mark" select="concat('#', $related-entity/@xml:id)"/>
                                                                            
                                                                            <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/text())"/>
                                                                            
                                                                        </a>
                                                                    </h4>
                                                                    
                                                                    <xsl:for-each select="('Sa-Ltn','en')[not(. = $entity-data/m:label[@type eq 'primary']/@xml:lang)]">
                                                                        
                                                                        <xsl:variable name="additional-terms-lang" select="."/>
                                                                        <xsl:variable name="additional-terms" select="$entity-data/m:term[@xml:lang eq $additional-terms-lang]"/>
                                                                        
                                                                        <xsl:if test="$additional-terms">
                                                                            <div class="tei-parser">
                                                                                <ul class="list-inline inline-dots">
                                                                                    <xsl:for-each select="$additional-terms">
                                                                                        <xsl:sort select="@normalized-string"/>
                                                                                        <li>
                                                                                            <xsl:call-template name="glossary-term">
                                                                                                <xsl:with-param name="term-text" select="text()"/>
                                                                                                <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                                                                <!--<xsl:with-param name="term-type" select="@type"/>-->
                                                                                                <xsl:with-param name="glossary-type" select="@glossary-type"/>
                                                                                            </xsl:call-template>
                                                                                        </li>
                                                                                    </xsl:for-each>
                                                                                </ul>
                                                                            </div>
                                                                        </xsl:if>
                                                                        
                                                                    </xsl:for-each>
                                                                    
                                                                </div>
                                                                
                                                            </xsl:for-each>
                                                        
                                                        </xsl:if>
                                                        
                                                    </div>
                                                </xsl:if>
                                                
                                            </div>
                                            
                                        </div>
                                        
                                    </div>
                                    
                                </div>
                                
                            </div>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <div id="entity-requested">
                                
                                <div id="{ /m:response/m:request/@resource-id }" class="text-center">
                                    <h2>
                                        <xsl:value-of select="'Entry not found'"/>
                                    </h2>
                                    <p>
                                        <xsl:value-of select="'Unfortunately we were unable to locate this entry in the glossary.'"/>
                                    </p>
                                </div>
                                
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </div>
            </main>
            
            <xsl:call-template name="glossary-pop-up-footers"/>
            
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
    
    <xsl:template name="glossary-entry">
        
        <xsl:param name="entity-data" as="element(m:entity-data)"/>
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="text" as="element(m:text)"/>
        <xsl:param name="instance" as="element(m:instance)"/>
        
        <xsl:variable name="glossary-status" select="$text/@glossary-status"/>
        <xsl:variable name="href" select="concat($reading-room-path, '/', $text/@type, '/', $text/m:bibl[1]/m:toh[1]/@key, '.html#', $entry/@id)"/>
        <xsl:variable name="target" select="concat($text/@id, '.html')"/>
        <xsl:variable name="dom-id" select="concat('glossary-entry-', $entry/@id)"/>
        
        <div class="entity-list-item">
            
            <!-- id -->
            <xsl:attribute name="id" select="$dom-id"/>
            
            <!-- css classes -->
            <xsl:if test="$tei-editor and ($glossary-status eq 'excluded' or $instance[m:flag/@type eq 'requires-attention'])">
                <xsl:attribute name="class" select="'entity-list-item excluded'"/>
            </xsl:if>
            
            <!-- Title -->
            <div>
                
                <div class="sml-margin bottom">
                    <a class="text-bold">
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
                </div>
                
                <!-- Location -->
                <xsl:for-each select="$text/m:bibl">
                    <nav role="navigation" aria-label="Breadcrumbs" class="text-muted small">
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
                
            </div>
            
            <!-- Tantric restriction warning
            <xsl:if test="$text[@type eq 'translation']/m:publication/m:tantric-restriction[tei:p]">
                <xsl:call-template name="tantra-warning">
                    <xsl:with-param name="id" select="$entry/@id"/>
                </xsl:call-template>
            </xsl:if> -->
            
            <!-- Output terms grouped and ordered by language -->
            <div class="tei-parser">
                <xsl:for-each select="('en','bo','Bo-Ltn','Sa-Ltn','zh', 'Pi-Ltn')">
                    
                    <xsl:variable name="term-lang" select="."/>
                    <xsl:variable name="term-lang-terms" select="$entry/m:term[@xml:lang eq $term-lang][text()]"/>
                    
                    <!--<xsl:if test="$term-lang-terms[text()[not(normalize-space(.) = $entity-data/m:label[@xml:lang eq $term-lang]/text())]]">-->
                    <xsl:if test="$term-lang-terms[text()]">
                        <div class="term-list">
                            
                            <xsl:choose>
                                <xsl:when test="$term-lang eq 'Pi-Ltn'">
                                    <span>
                                        <xsl:value-of select="'Pali: '"/>
                                    </span>
                                </xsl:when>
                            </xsl:choose>
                            
                            <ul class="list-inline inline-dots">
                                <xsl:choose>
                                    <xsl:when test="$term-lang-terms">
                                        <xsl:for-each select="$term-lang-terms">
                                            <li>
                                                
                                                <xsl:call-template name="glossary-term">
                                                    <xsl:with-param name="term-text" select="text()"/>
                                                    <xsl:with-param name="term-lang" select="@xml:lang"/>
                                                    <xsl:with-param name="term-type" select="@type"/>
                                                    <xsl:with-param name="term-status" select="@status"/>
                                                    <xsl:with-param name="glossary-type" select="$entry/@type"/>
                                                </xsl:call-template>
                                                
                                            </li>
                                        </xsl:for-each>
                                    </xsl:when>
                                </xsl:choose>
                            </ul>
                            
                        </div>
                    </xsl:if>
                    
                </xsl:for-each>
            </div>
            
            <!-- Alternatives -->
            <xsl:variable name="alternative-terms" select="$entry/m:alternative"/>
            <xsl:if test="$tei-editor and $alternative-terms">
                <div>
                    <ul class="list-inline inline-dots">
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
            
            <!-- Definitions -->
            <xsl:variable name="entry-definition" select="$entry/m:definition[descendant::text()[normalize-space()]]"/>
            <xsl:variable name="entry-definition-html">
                <xsl:for-each select="$entry-definition/tei:p[descendant::text()[normalize-space()]]">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="entity-definition" select="$instance/parent::m:entity/m:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]"/>
            <xsl:variable name="entity-definition-html">
                <xsl:for-each select="$entity-definition">
                    <p>
                        <xsl:attribute name="class" select="'definition'"/>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Entry definition -->
            <xsl:choose>
                
                <!-- Editor mode -->
                <xsl:when test="$tei-editor and $entity-definition and (not($entry-definition) or $entry-definition[@use-definition = ('both','append','prepend','override','incompatible')])">
                    
                    <div class="well well-sm">
                        
                        <h4 class="no-top-margin">
                            
                            <xsl:choose>
                                <xsl:when test="$entry-definition[@use-definition = ('incompatible')]">
                                    <xsl:value-of select="'Glossary hides entity definition: '"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Text displays entity definition: '"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <span class="label label-info">
                                <xsl:value-of select="($entry-definition/@use-definition[not(. eq '')], 'No entry definition')[1]"/>
                            </span>
                            
                        </h4>
                        
                        <!-- Entry definition as prologue -->
                        <xsl:if test="($entry-definition and not($entity-definition)) or ($entry-definition and $entry-definition[not(@use-definition = ('override','both','prepend','incompatible'))])">
                            <xsl:sequence select="$entry-definition-html"/>
                        </xsl:if>
                        
                        <!-- Entity definition -->
                        <xsl:if test="($entity-definition and not($entry-definition)) or ($entity-definition and $entry-definition[@use-definition = ('both','append','prepend','override')])">
                            <div>
                                <header class="text-muted small">
                                    <xsl:value-of select="'Definition from the 84000 Glossary:'"/>
                                </header>
                                <xsl:sequence select="$entity-definition-html"/>
                            </div>
                        </xsl:if>
                        
                        <!-- Entry definition as epilogue -->
                        <xsl:if test="($entry-definition and $entity-definition and $entry-definition[@use-definition = ('both','prepend','override','incompatible')])">
                            <div>
                                <header class="text-muted small">
                                    <xsl:value-of select="'Definition in this text: '"/>
                                    <xsl:if test="$entry-definition[@use-definition = ('override','incompatible')]">
                                        <xsl:value-of select="'(Not shown in the cumulative glossary)'"/>
                                    </xsl:if>
                                </header>
                                <div>
                                    <xsl:if test="$entry-definition[@use-definition = ('override','incompatible')]">
                                        <xsl:attribute name="class" select="'line-through'"/>
                                    </xsl:if>
                                    <xsl:sequence select="$entry-definition-html"/>
                                </div>
                            </div>
                        </xsl:if>
                        
                    </div>
                    
                </xsl:when>
                
                <!-- Other -->
                <xsl:when test="($entry-definition and not($entity-definition)) or ($entry-definition and $entry-definition[not(@use-definition = ('override','incompatible'))])">
                    
                    <div>
                        
                        <xsl:choose>
                            <xsl:when test="$entity-definition and $entry-definition[@use-definition = ('both','append','prepend')]">
                                <header class="text-muted italic small">
                                    <xsl:value-of select="'This is an addendum to the general definition from the 84000 Glossary:'"/>
                                </header>
                            </xsl:when>
                            <xsl:otherwise>
                                <header class="text-muted italic small">
                                    <xsl:value-of select="'Definition in this text: '"/>
                                </header>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <xsl:sequence select="$entry-definition-html"/>
                        
                    </div>
                    
                </xsl:when>
            
            </xsl:choose>
            
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
                
                <div class="well well-sm">
                    
                    <!-- Publication date -->
                    <xsl:if test="$text/m:publication/m:publication-date">
                        <p class="sml-margin bottom small">
                            <xsl:value-of select="$text/m:publication/m:publication-date ! concat('First published ', format-date(., '[D1o] [MNn,*-3] [Y]'))"/>
                        </p>
                    </xsl:if>
                    
                    <!-- Translators -->
                    <div class="sml-margin bottom small">
                        <xsl:value-of select="'Translation by: '"/>
                        <ul class="list-inline inline-dots">
                            <xsl:for-each select="$text/m:publication/m:contributors/m:author[normalize-space(text())]">
                                <li>
                                    <xsl:value-of select="."/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    
                    <div>
                        <ul class="list-inline inline-dots">
                            
                            <li class="small">
                                <a target="84000-glossary-tool" class="editor">
                                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations'],'/edit-glossary.html?resource-id=', $text/@id, '&amp;glossary-id=', $entry/@id, '&amp;resource-type=', $text/@type, '&amp;max-records=1&amp;filter=check-all')"/>
                                    <!-- Pop-up window variant
                                <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $text/@id, '&amp;glossary-id=', $entry/@id, '&amp;resource-type=', $text/@type, '&amp;max-records=1&amp;filter=check-none#glossary-form-', $entry/@id)"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                <xsl:attribute name="data-editor-callbackurl" select="concat($page-url, m:view-mode-parameter('editor','?'), '#', $dom-id)"/>-->
                                    <xsl:value-of select="'Glossary editor'"/>
                                </a>
                            </li>
                            
                            <xsl:for-each select="/m:response/m:entity-flags/m:flag[not(@type eq 'computed')]">
                                <li>
                                    
                                    <xsl:variable name="config-flag" select="."/>
                                    <xsl:variable name="entity-flag" select="$instance/m:flag[@type eq $config-flag/@id][1]"/>
                                    
                                    <form action="/edit-entity.html" method="post" class="form-inline inline-block">
                                        
                                        <xsl:attribute name="data-ajax-target" select="concat('#glossary-entry-', $entry/@id)"/>
                                        <xsl:attribute name="data-ajax-target-callbackurl" select="concat($page-url, m:view-mode-parameter('editor','?'), '#glossary-entry-', $entry/@id)"/>
                                        
                                        <input type="hidden" name="entity-id" value="{ $entity-data/@ref }"/>
                                        <input type="hidden" name="entity-flag" value="{ $config-flag/@id }"/>
                                        <input type="hidden" name="instance-id" value="{ $instance/@id }"/>
                                        <input type="hidden" name="return" value="none"/>
                                        
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
                            
                            <xsl:if test="$entity-definition and $entry-definition[@use-definition = ('override', 'incompatible')]">
                                <li>
                                    
                                    <form action="/edit-glossary.html" method="post" class="form-inline inline-block">
                                        
                                        <xsl:attribute name="data-ajax-target" select="concat('#glossary-entry-', $entry/@id)"/>
                                        <xsl:attribute name="data-ajax-target-callbackurl" select="concat($page-url, m:view-mode-parameter('editor','?'), '#glossary-entry-', $entry/@id)"/>
                                        
                                        <input type="hidden" name="form-action" value="glossary-definition-use"/>
                                        <input type="hidden" name="use-definition" value=""/>
                                        <input type="hidden" name="resource-id" value="{ $text/@id }"/>
                                        <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
                                        <input type="hidden" name="return" value="none"/>
                                        
                                        <span class="small">
                                            <button type="submit" data-loading="Updating definition use..." class="btn-link editor">
                                                <xsl:value-of select="'Text definition preferred'"/>
                                            </button>
                                        </span>
                                        
                                    </form>
                                </li>
                            </xsl:if>
                            
                            <xsl:if test="$entity-definition and $entry-definition and not($entry-definition[@use-definition eq 'override'])">
                                <li>
                                    <form action="/edit-glossary.html" method="post" class="form-inline inline-block">
                                        
                                        <xsl:attribute name="data-ajax-target" select="concat('#glossary-entry-', $entry/@id)"/>
                                        <xsl:attribute name="data-ajax-target-callbackurl" select="concat($page-url, m:view-mode-parameter('editor','?'), '#glossary-entry-', $entry/@id)"/>
                                        
                                        <input type="hidden" name="form-action" value="glossary-definition-use"/>
                                        <input type="hidden" name="use-definition" value="override"/>
                                        <input type="hidden" name="resource-id" value="{ $text/@id }"/>
                                        <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
                                        <input type="hidden" name="return" value="none"/>
                                        
                                        <span class="small">
                                            <button type="submit" data-loading="Updating definition use..." class="btn-link editor">
                                                <xsl:value-of select="'Entity definition preferred'"/>
                                            </button>
                                        </span>
                                        
                                    </form>
                                </li>
                            </xsl:if>
                            
                            <xsl:if test="$entity-definition and $entry-definition[not(@use-definition)]">
                                <li>
                                    
                                    <form action="/edit-glossary.html" method="post" class="form-inline inline-block">
                                        
                                        <xsl:attribute name="data-ajax-target" select="concat('#glossary-entry-', $entry/@id)"/>
                                        <xsl:attribute name="data-ajax-target-callbackurl" select="concat($page-url, m:view-mode-parameter('editor','?'), '#glossary-entry-', $entry/@id)"/>
                                        
                                        <input type="hidden" name="form-action" value="glossary-definition-use"/>
                                        <input type="hidden" name="use-definition" value="incompatible"/>
                                        <input type="hidden" name="resource-id" value="{ $text/@id }"/>
                                        <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
                                        <input type="hidden" name="return" value="none"/>
                                        
                                        <span class="small">
                                            <button type="submit" data-loading="Updating definition use..." class="btn-link editor">
                                                <xsl:value-of select="'Incompatible - hide text definition here'"/>
                                            </button>
                                        </span>
                                        
                                    </form>
                                </li>
                            </xsl:if>
                            
                        </ul>
                    </div>
                    
                </div>
                
            </xsl:if>
            
        </div>
    
    </xsl:template>
    
</xsl:stylesheet>