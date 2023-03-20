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
                        <xsl:with-param name="entry-label" select="$request-entity-data/m:label[@type eq 'primary']"/>
                    </xsl:call-template>
                    
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
                                                
                                                <div>
                                                    <ul class="list-inline inline-dots">
                                                        <xsl:for-each select="$request-entity-data/m:term[@xml:lang eq 'bo']">
                                                            
                                                            <xsl:sort select="string-join(tokenize(text(), '\s+') ! normalize-unicode(.), ' ')"/>
                                                            
                                                            <li>
                                                                <xsl:choose>
                                                                    <xsl:when test="position() eq 1">
                                                                        <h2 class="no-bottom-margin">
                                                                            <span>
                                                                                <xsl:call-template name="class-attribute">
                                                                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                                                                </xsl:call-template>
                                                                                <xsl:apply-templates select="text()"/>
                                                                            </span>
                                                                        </h2>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <span class="h2">
                                                                            <span>
                                                                                <xsl:call-template name="class-attribute">
                                                                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                                                                </xsl:call-template>
                                                                                <xsl:apply-templates select="text()"/>
                                                                            </span>
                                                                        </span>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </li>
                                                            
                                                        </xsl:for-each>
                                                    </ul>
                                                </div>
                                                
                                                <xsl:for-each select="('Bo-Ltn','Sa-Ltn')">
                                                    <xsl:variable name="title-lang" select="."/>
                                                    <xsl:variable name="title-terms-lang" select="$request-entity-data/m:term[@xml:lang eq $title-lang]"/>
                                                    <div>
                                                        <ul class="list-inline inline-dots sml-margin top">
                                                            <xsl:for-each select="$title-terms-lang">
                                                                <li>
                                                                    <span class="{ common:lang-class($title-lang) }">
                                                                        <xsl:value-of select="."/>
                                                                    </span>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </div>
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
                                        </xsl:call-template>
                                        
                                        <div class="entity-detail collapse in persist" id="{ concat($item-id, '-detail') }">
                                            
                                            <div class="top-margin">
                                                
                                                <!-- Entity definition -->
                                                <xsl:if test="$request-entity/m:content[@type eq 'glossary-definition'][node()]">
                                                    <blockquote>
                                                        <xsl:for-each select="$request-entity/m:content[@type eq 'glossary-definition']">
                                                            <p class="definition">
                                                                <xsl:apply-templates select="node()"/>
                                                            </p>
                                                        </xsl:for-each>
                                                    </blockquote>
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
                                                                <xsl:with-param name="title">
                                                                    <div class="center-vertical align-left">
                                                                        
                                                                        <span>
                                                                            <span class="badge badge-notification">
                                                                                <xsl:value-of select="count(current-group())"/>
                                                                            </span>
                                                                        </span>
                                                                        
                                                                        <span>
                                                                            <h3>
                                                                                <xsl:value-of select="m:term[@xml:lang eq 'en'][1] ! functx:capitalize-first(.)"/>
                                                                            </h3>
                                                                        </span>
                                                                        
                                                                        <xsl:if test="$tei-editor">
                                                                            <span>
                                                                                <ul class="list-inline inline-dots inline-pad-first">
                                                                                    
                                                                                    <xsl:variable name="term-group-instances" select="$request-entity/m:instance[@id = $term-group/@id]"/>
                                                                                    <xsl:variable name="term-group-instances-flagged" select="$term-group-instances[m:flag]"/>
                                                                                    <xsl:variable name="term-group-related-entries" select="key('related-entries', $term-group-instances/@id, $root)"/>
                                                                                    <xsl:variable name="term-group-related-entries-excluded" select="$term-group-related-entries[parent::m:text/@glossary-status eq 'excluded']"/>
                                                                                    <xsl:variable name="term-group-related-entries-no-definition" select="$term-group-related-entries[not(m:definition[node()])]"/>
                                                                                    <xsl:variable name="entity-definition" select="$request-entity/m:content[@type eq 'glossary-definition'][node()]"/>
                                                                                    <xsl:variable name="term-group-instances-use-definition" select="if($entity-definition) then $term-group-instances[@use-definition = ('both','append','prepend','override')] | $term-group-instances[@id = $term-group-related-entries-no-definition/@id] else ()"/>
                                                                                    
                                                                                    <li>
                                                                                        <span class="small text-muted">
                                                                                            <xsl:if test="$term-group-instances-use-definition">
                                                                                                <xsl:attribute name="class" select="'small text-warning'"/>
                                                                                            </xsl:if>
                                                                                            <xsl:value-of select="count($term-group-instances-use-definition)"/>
                                                                                            <xsl:value-of select="if (count($term-group-instances-use-definition) eq 1) then ' entry displays entity definition' else ' entries display entity definition'"/>
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
                                                                            </span>
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
                                                
                                                <!-- Related pages -->
                                                <xsl:if test="$related-entity-pages and $environment/m:enable[@type eq 'knowledgebase']">
                                                    
                                                    <div class="entity-detail-related">
                                                        
                                                        <div>
                                                            <span class="badge badge-notification badge-muted">
                                                                <xsl:value-of select="count($related-entity-pages)"/>
                                                            </span>
                                                            <span class="badge-text">
                                                                <xsl:value-of select="' Related content from the 84000 Knowledge Base:'"/>
                                                            </span>
                                                        </div>
                                                        
                                                        <xsl:for-each select="$related-entity-pages">
                                                            
                                                            <xsl:variable name="main-title" select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                                                            
                                                            <a class="entity-list-item block-link">
                                                                <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                                <span>
                                                                    <xsl:attribute name="class">
                                                                        <xsl:value-of select="string-join(('results-list-item-heading', common:lang-class($main-title/@xml:lang)),' ')"/>
                                                                    </xsl:attribute>
                                                                    <xsl:value-of select="normalize-space($main-title/text())"/>
                                                                </span>
                                                            </a>
                                                            
                                                        </xsl:for-each>
                                                        
                                                    </div>
                                                    
                                                </xsl:if>
                                                
                                                <!-- Related entries -->
                                                <xsl:if test="$related-entity-entries">
                                                    
                                                    <xsl:variable name="related-entries-entities" select="/m:response/m:entities/m:related/m:entity[m:instance/@id = $related-entity-entries/@id]"/>
                                                    
                                                    <div class="entity-detail-related">
                                                        
                                                        <div>
                                                            <span class="badge badge-notification badge-muted">
                                                                <xsl:value-of select="count($related-entries-entities)"/>
                                                            </span>
                                                            <span class="badge-text">
                                                                <xsl:value-of select="' Related content from the 84000 Glossary of Terms:'"/>
                                                            </span>
                                                        </div>
                                                        
                                                        <xsl:for-each select="$related-entries-entities">
                                                            
                                                            <xsl:variable name="related-entity" select="."/>
                                                            <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                                <xsl:call-template name="entity-data">
                                                                    <xsl:with-param name="entity" select="$related-entity"/>
                                                                </xsl:call-template>
                                                            </xsl:variable>
                                                            
                                                            <a class="entity-list-item block-link">
                                                                
                                                                <!-- Link to the glossary, checking if it's already included in this page -->
                                                                <xsl:attribute name="href" select="concat('/glossary/', $related-entity/@xml:id, '.html', '#', $related-entity/@xml:id)"/>
                                                                <xsl:attribute name="data-href-override" select="concat('#', $related-entity/@xml:id)"/>
                                                                <xsl:attribute name="data-postscroll-mark" select="concat('#', $related-entity/@xml:id)"/>
                                                                
                                                                <h4 class="{ common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang) }">
                                                                    <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/text())"/>
                                                                </h4>
                                                                
                                                                <xsl:for-each select="('Sa-Ltn','en')[not(. = $entity-data/m:label[@type eq 'primary']/@xml:lang)]">
                                                                    
                                                                    <xsl:variable name="additional-terms-lang" select="."/>
                                                                    <xsl:variable name="additional-terms" select="$entity-data/m:term[@xml:lang eq $additional-terms-lang]"/>
                                                                    
                                                                    <xsl:if test="$additional-terms">
                                                                        <div>
                                                                            <ul class="list-inline inline-dots">
                                                                                <xsl:for-each select="$additional-terms">
                                                                                    <xsl:sort select="@normalized-string"/>
                                                                                    <li>
                                                                                        <span class="{ common:lang-class(@xml:lang) }">
                                                                                            <xsl:value-of select="text() ! normalize-space(.)"/>
                                                                                        </span>
                                                                                    </li>
                                                                                </xsl:for-each>
                                                                            </ul>
                                                                        </div>
                                                                    </xsl:if>
                                                                    
                                                                </xsl:for-each>
                                                                
                                                            </a>
                                                            
                                                        </xsl:for-each>
                                                        
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
    
    <xsl:template name="glossary-entry">
        
        <xsl:param name="entity-data" as="element(m:entity-data)"/>
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="text" as="element(m:text)"/>
        <xsl:param name="instance" as="element(m:instance)"/>
        
        <xsl:variable name="glossary-status" select="$text/@glossary-status"/>
        <xsl:variable name="href" select="concat($reading-room-path, '/', $text/@type, '/', $text/m:bibl[1]/m:toh[1]/@key, '.html#', @id)"/>
        <xsl:variable name="target" select="concat($text/@id, '.html')"/>
        <xsl:variable name="dom-id" select="concat('glossary-entry-', $entry/@id)"/>
        
        <div class="entity-list-item">
            
            <xsl:attribute name="id" select="$dom-id"/>
            
            <xsl:if test="$tei-editor and ($glossary-status eq 'excluded' or $instance[m:flag/@type eq 'requires-attention'])">
                <xsl:attribute name="class" select="'entity-list-item excluded'"/>
            </xsl:if>
            
            <!-- Title -->
            <div>
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
            
            <!-- Tantric restriction warning -->
            <!--<xsl:variable name="tantric-restriction" select="$text[@type eq 'translation']/m:publication/m:tantric-restriction"/>
            <xsl:if test="$tantric-restriction/tei:p">
                <xsl:call-template name="tantra-warning">
                    <xsl:with-param name="id" select="$entry/@id"/>
                    <xsl:with-param name="node" select="$tantric-restriction"/>
                </xsl:call-template>
            </xsl:if>-->
            
            <!-- Location -->
            <xsl:for-each select="$text/m:bibl">
                <nav role="navigation" aria-label="Breadcrumbs" class="text-muted">
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
                <div class="text-muted">
                    <xsl:value-of select="'Translation by '"/>
                    <xsl:value-of select="string-join($translators ! normalize-space(data()), ' · ')"/>
                </div>
            </xsl:if>
            
            <!-- Output terms grouped and ordered by language -->
            <xsl:for-each select="('en','bo','Bo-Ltn','Sa-Ltn','zh')">
                
                <xsl:variable name="term-lang" select="."/>
                <xsl:variable name="term-lang-terms" select="$entry/m:term[@xml:lang eq $term-lang][text()]"/>

                <!--<xsl:if test="$term-lang-terms[text()[not(normalize-space(.) = $entity-data/m:label[@xml:lang eq $term-lang]/text())]]">-->
                <xsl:if test="$term-lang-terms[text()]">
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
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$term-lang eq 'en'">
                                                        <xsl:value-of select="text() ! functx:capitalize-first(.)"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="text()"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
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
            
            <!-- Definition -->
            <xsl:variable name="entry-definition" select="$entry/m:definition[descendant::text()]"/>
            <xsl:variable name="entry-definition-html">
                <xsl:for-each select="$entry-definition">
                    <p>
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="entity-definition" select="$instance/parent::m:entity/m:content[@type eq 'glossary-definition'][descendant::text()]"/>
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
                <xsl:when test="$tei-editor and $entity-definition and (not($entry-definition) or $instance[@use-definition = ('both','append','prepend','override')])">
                    
                    <div class="well well-sm top-margin bottom-margin">
                        
                        <h4 class="no-top-margin">
                            <xsl:value-of select="'Text displays entity definition: '"/>
                            <span class="label label-info">
                                <xsl:value-of select="($instance/@use-definition[not(. eq '')], 'No entry definition')[1]"/>
                            </span>
                        </h4>
                        
                        <!-- Entry definition as prologue -->
                        <xsl:if test="($entry-definition and not($entity-definition)) or ($entry-definition and $instance[not(@use-definition = ('override','both','prepend'))])">
                            <xsl:sequence select="$entry-definition-html"/>
                        </xsl:if>
                        
                        <!-- Entity definition -->
                        <xsl:if test="($entity-definition and not($entry-definition)) or ($entity-definition and $instance[@use-definition = ('both','append','prepend','override')])">
                            <div>
                                <header class="text-muted italic">
                                    <xsl:value-of select="'Definition from the 84000 Glossary of Terms:'"/>
                                </header>
                                <xsl:sequence select="$entity-definition-html"/>
                            </div>
                        </xsl:if>
                        
                        <!-- Entry definition as epilogue -->
                        <xsl:if test="($entry-definition and $entity-definition and $instance[@use-definition = ('both','prepend')])">
                            <div>
                                <header class="text-muted italic">
                                    <xsl:value-of select="'In this text:'"/>
                                </header>
                                <xsl:sequence select="$entry-definition-html"/>
                            </div>
                        </xsl:if>
                        
                    </div>
                    
                </xsl:when>
                <xsl:when test="($entry-definition and not($entity-definition)) or ($entry-definition and $instance[not(@use-definition eq 'override')])">
                    
                    <div class="top-margin">
                        <header class="text-muted italic">
                            <xsl:value-of select="'Defined in this text:'"/>
                        </header>
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
                
                <div>
                    <ul class="list-inline inline-dots">
                        
                        <li class="small">
                            <a target="84000-glossary-tool" class="editor">
                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/data(), '/edit-glossary.html?resource-id=', $text/@id, '&amp;glossary-id=', @id, '&amp;resource-type=', $text/@type, '&amp;max-records=1')"/>
                                <xsl:value-of select="'Glossary editor'"/>
                            </a>
                        </li>
                        
                        <xsl:for-each select="/m:response/m:entity-flags/m:flag[not(@type eq 'computed')]">
                            <li>
                                
                                <xsl:variable name="config-flag" select="."/>
                                <xsl:variable name="entity-flag" select="$instance/m:flag[@type eq $config-flag/@id][1]"/>
                                
                                <form action="/edit-entity.html" method="post" data-ajax-target="#ajax-source" class="form-inline inline-block">
                                    
                                    <xsl:attribute name="data-ajax-target-callbackurl" select="$page-url || m:view-mode-parameter('editor','?') ||  concat('#', $dom-id)"/>
                                    
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