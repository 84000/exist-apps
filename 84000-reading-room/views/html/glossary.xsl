<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>
    <xsl:variable name="selected-type" select="/m:response/m:request/m:entity-types/m:type[@selected eq 'selected']" as="element(m:type)*"/>
    <xsl:variable name="selected-term-lang" select="/m:response/m:request/m:term-langs/m:lang[@selected eq 'selected']" as="element(m:lang)?"/>
    <xsl:variable name="search-text" select="/m:response/m:request/@search" as="xs:string?"/>
    <xsl:variable name="flagged" select="/m:response/m:request/@flagged" as="xs:string?"/>
    <xsl:variable name="active-tab" as="xs:string">
        <xsl:choose>
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
    
    <xsl:variable name="show-entity" as="element(m:entity)?">
        <xsl:choose>
            <xsl:when test="/m:response/m:show-entity[m:entity]">
                <xsl:sequence select="/m:response/m:show-entity/m:entity[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$entities[@xml:id eq $entities-data-sorted[1]/@ref]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="page-title" as="xs:string">
        <xsl:choose>
            <xsl:when test="$show-entity[@xml:id eq /m:response/m:request/@entity-id] and $entities-data[@ref eq $show-entity/@xml:id]">
                <xsl:value-of select="concat(normalize-space($entities-data[@ref eq $show-entity/@xml:id]/m:label[@type eq 'primary']/text()), ' - Glossary Entry')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Glossary filtered for: ', string-join(($selected-type/m:label[@type eq 'plural']/text(), $selected-term-lang/text(), $search-text ! concat('&#34;', ., '&#34;')), '; '))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="page-url" as="xs:string">
        <xsl:choose>
            <xsl:when test="$show-entity[@xml:id eq /m:response/m:request/@entity-id] and $entities-data[@ref eq $show-entity/@xml:id]">
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('entity-id=', $show-entity/@xml:id)), '&amp;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('type[]=', string-join($selected-type/@id, ',')),concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text)), '&amp;')"/>
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
            
            <main class="content-band">
                <div class="container">
                    
                    <!-- Page title -->
                    <div class="section-title row">
                        <div class="col-sm-offset-2 col-sm-8">
                            <div class="h1 title main-title">
                                <xsl:value-of select="'84000 Glossary of Terms'"/>
                            </div>
                            <hr/>
                            <p>
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
                            
                            <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
                            <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', /m:response/m:request/@term-lang), concat('type[]=', ($selected-type[1]/@id, /m:response/m:request/m:entity-types/m:type[1]/@id)[1]), m:view-mode-parameter((),()))"/>
                            
                            <!-- Search tab -->
                            <li role="presentation" class="icon">
                                <xsl:if test="$active-tab eq 'search'">
                                    <xsl:attribute name="class" select="'icon active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/glossary.html?search=', $internal-link-attrs, '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Search'"/>
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
                                            <xsl:value-of select="m:label"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </xsl:if>
                            
                        </ul>
                    </div>
                    
                    <!-- Type/Lang controls -->
                    <xsl:choose>
                        
                        <xsl:when test="$tei-editor and m:entity-flags/m:flag[@id eq $flagged]">
                            
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
                                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?type[]=', @id), (concat('flagged=', $flagged), m:view-mode-parameter((),())), '', /m:response/@lang)"/>
                                                    <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                    </ul>
                                </div>
                                
                            </div>
                        </xsl:when>
                        
                        <!-- Search box -->
                        <xsl:when test="$active-tab eq 'search'">
                            <form action="/glossary.html" method="post" role="search" class="form-inline">
                                
                                <xsl:if test="$view-mode[@id eq 'editor']">
                                    <input type="hidden" name="view-mode" value="editor"/>
                                </xsl:if>
                                
                                <div class="align-center bottom-margin">
                                    <div class="form-group">
                                        
                                        <xsl:for-each select="m:request/m:entity-types/m:type[@glossary-type]">
                                            <div class="checkbox-inline">
                                                <label>
                                                    <input type="checkbox" name="type[]">
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
                                </div>
                                
                                <div class="align-center bottom-margin">
                                    
                                    <div class="form-group">
                                        <input type="text" name="search" class="form-control" placeholder="Search...">
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
                                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?type[]=', @id), $internal-link-attrs, '', /m:response/@lang)"/>
                                                    <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                    </ul>
                                </div>
                                
                                <!-- Language tabs -->
                                <div>
                                    <ul class="nav nav-pills">
                                        
                                        <xsl:variable name="internal-link-attrs" select="(concat('type[]=', string-join($selected-type[1]/@id, ',')), concat('search=', $search-text), m:view-mode-parameter((),()))"/>
                                        
                                        <xsl:for-each select="m:request/m:term-langs/m:lang">
                                            
                                            <li role="presentation">
                                                <xsl:if test="@selected eq 'selected'">
                                                    <xsl:attribute name="class" select="'active'"/>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?term-lang=', @id), $internal-link-attrs, '', /m:response/@lang)"/>
                                                    <xsl:value-of select="text()"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                    </ul>
                                </div>
                                
                            </div>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <!-- Results -->
                    <div id="glossary-results">
                        
                        <xsl:choose>
                            
                            <!-- Result -->
                            <xsl:when test="$show-entity or $entities">
                                
                                <div class="row">
                                    
                                    <!-- Selected entity -->
                                    <div id="entity-selected" class="col-md-8 col-lg-9">
                                       
                                       <div id="entity-detail">
                                           
                                           <xsl:if test="$show-entity">
                                               
                                               <xsl:attribute name="class" select="'search-result collapse in persist'"/>
                                               
                                               <xsl:variable name="entity-data" select="$entities-data[@ref eq $show-entity/@xml:id]"/>
                                               <xsl:variable name="related-entries" select="key('related-entries', $show-entity/m:instance/@id, $root)"/>
                                               <xsl:variable name="related-entity-pages" select="key('related-pages', $show-entity/m:instance/@id | /m:response/m:entities/m:related/m:entity[@xml:id = $show-entity/m:relation/@id]/m:instance/@id, $root)" as="element(m:page)*"/>
                                               <xsl:variable name="related-entity-entries" select="key('related-entries', /m:response/m:entities/m:related/m:entity[@xml:id = $show-entity/m:relation/@id]/m:instance/@id, $root)" as="element(m:entry)*"/>
                                               <xsl:variable name="instances-flagged" select="$show-entity/m:instance[m:flag]"/>
                                               <xsl:variable name="related-entries-excluded" select="$related-entries[parent::m:text/@glossary-status eq 'excluded']"/>
                                               
                                               <div class="entity-detail-container replace" id="term-translations">
                                                   
                                                   <xsl:attribute name="id" select="concat($show-entity/@xml:id, '-detail')"/>
                                                   
                                                   <!-- Header -->
                                                   <div class="entity-detail-header">
                                                       
                                                       <h2>
                                                           
                                                           <span>
                                                               <xsl:attribute name="class">
                                                                   <xsl:value-of select="string-join(((), common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang)),' ')"/>
                                                               </xsl:attribute>
                                                               <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/text())"/>
                                                           </span>
                                                           
                                                           <xsl:for-each-group select="$show-entity/m:type" group-by="@type">
                                                               <xsl:variable name="type" select="."/>
                                                               <xsl:value-of select="' '"/>
                                                               <span class="label label-info">
                                                                   <xsl:value-of select="/m:response/m:request/m:entity-types/m:type[@id eq $type[1]/@type]/m:label[@type eq 'singular']"/>
                                                               </span>
                                                           </xsl:for-each-group>
                                                           
                                                           <xsl:if test="$tei-editor">
                                                               <xsl:value-of select="' '"/>
                                                               <a target="84000-operations" class="editor">
                                                                   <xsl:attribute name="href" select="concat('/edit-entity.html?entity-id=', $show-entity/@xml:id, '#ajax-source')"/>
                                                                   <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                                   <xsl:value-of select="'Edit entity'"/>
                                                               </a>
                                                           </xsl:if>
                                                           
                                                       </h2>
                                                       
                                                       <xsl:if test="$entity-data[m:label[@type eq 'secondary']]">
                                                           <p>
                                                               <xsl:attribute name="class">
                                                                   <xsl:value-of select="string-join(('text-muted', common:lang-class($entity-data/m:label[@type eq 'secondary']/@xml:lang)),' ')"/>
                                                               </xsl:attribute>
                                                               <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'secondary']/text())"/>
                                                           </p>
                                                       </xsl:if>
                                                       
                                                       <!-- Entity definition -->
                                                       <xsl:for-each select="$show-entity/m:content[@type eq 'glossary-definition']">
                                                           <p>
                                                               <xsl:apply-templates select="node()"/>
                                                           </p>
                                                       </xsl:for-each>
                                                       
                                                   </div>
                                                   
                                                   <!-- Notes -->
                                                   <xsl:if test="$tei-editor and ($show-entity/m:content[@type eq 'glossary-notes'] or $instances-flagged or $related-entries-excluded)">
                                                       <div class="well well-sm">
                                                           
                                                           <h4 class="no-top-margin no-bottom-margin">
                                                               <xsl:value-of select="'Notes (internal):'"/>
                                                           </h4>
                                                           
                                                           <xsl:for-each select="$show-entity/m:content[@type eq 'glossary-notes']">
                                                               <p class="small">
                                                                   <xsl:apply-templates select="node()"/>
                                                               </p>
                                                           </xsl:for-each>
                                                           
                                                           <xsl:if test="$related-entries-excluded">
                                                               <div class="sml-margin top">
                                                                   <span class="badge badge-notification">
                                                                       <xsl:value-of select="count($related-entries-excluded)"/>
                                                                   </span>
                                                                   <span class="badge-text">
                                                                       <xsl:value-of select="if (count($related-entries-excluded) eq 1) then 'entry in an excluded text' else 'entries in excluded texts'"/>
                                                                   </span>
                                                               </div>
                                                           </xsl:if>
                                                           
                                                           <xsl:if test="$instances-flagged">
                                                               <div class="sml-margin top">
                                                                   <span class="badge badge-notification">
                                                                       <xsl:value-of select="count($instances-flagged)"/>
                                                                   </span>
                                                                   <span class="badge-text">
                                                                       <xsl:value-of select="if (count($instances-flagged) eq 1) then 'entry flagged' else 'entries flagged'"/>
                                                                   </span>
                                                               </div>
                                                           </xsl:if>
                                                           
                                                           <xsl:if test="count($show-entity/m:instance[@type eq 'glossary-item']) eq count($show-entity/m:instance[@type eq 'glossary-item'][m:flag])">
                                                               <p class="italic text-danger sml-margin top">
                                                                   <xsl:value-of select="'All entries are flagged! This entity is NOT included in the public Glossary of Terms'"/>
                                                               </p>
                                                           </xsl:if>
                                                           
                                                       </div>
                                                   </xsl:if>
                                                   
                                                   <!-- Glossary entries: group by translation -->
                                                   <xsl:for-each-group select="$related-entries" group-by="m:sort-term">
                                                       
                                                       <xsl:sort select="m:sort-term"/>
                                                       <xsl:variable name="term-group-index" select="position()"/>
                                                       <xsl:variable name="term-group" select="current-group()"/>
                                                       
                                                       <h3 class="term">
                                                           <xsl:value-of select="m:term[@xml:lang eq 'en'][1]"/>
                                                       </h3>
                                                       
                                                       <!-- Group by type (translation/knowledgebase) -->
                                                       <xsl:for-each-group select="$term-group" group-by="parent::m:text/@type">
                                                           
                                                           <xsl:variable name="text-type" select="parent::m:text/@type"/>
                                                           <xsl:variable name="text-type-entries" select="current-group()"/>
                                                           <xsl:variable name="text-type-related-texts" select="/m:response/m:entities/m:related/m:text[m:entry/@id = $text-type-entries/@id]"/>
                                                           
                                                           <xsl:call-template name="expand-item">
                                                               
                                                               <xsl:with-param name="id" select="concat('expand-', $term-group-index, '-', $text-type)"/>
                                                               <xsl:with-param name="accordion-selector" select="'no-accordion'"/>
                                                               <xsl:with-param name="active" select="$tei-editor"/>
                                                               
                                                               <xsl:with-param name="title">
                                                                   
                                                                   <div class="center-vertical align-left">
                                                                       
                                                                       <div>
                                                                           <span class="badge badge-notification">
                                                                               <xsl:if test="$tei-editor and ($show-entity/m:instance[@id = $text-type-entries/@id][m:flag] or $text-type-entries[parent::m:text/@glossary-status eq 'excluded'])">
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
                                                                       
                                                                   </div>
                                                                   
                                                               </xsl:with-param>
                                                               
                                                               <xsl:with-param name="content">
                                                                   
                                                                   <div class="sml-margin top">
                                                                       <xsl:for-each select="$text-type-related-texts">
                                                                           
                                                                           <!-- Order by Toh numerically needs improving -->
                                                                           <xsl:sort select="m:toh[1]/@number ! xs:integer(.)"/>
                                                                           <xsl:variable name="related-text" select="."/>
                                                                           
                                                                           <xsl:for-each select="$related-text/m:entry[@id = $text-type-entries/@id]">
                                                                               <xsl:variable name="related-text-entry" select="."/>
                                                                               <xsl:call-template name="glossary-entry">
                                                                                   <xsl:with-param name="entry" select="$related-text-entry"/>
                                                                                   <xsl:with-param name="text" select="$related-text"/>
                                                                                   <xsl:with-param name="instance" select="$show-entity/m:instance[@id eq $related-text-entry/@id]"/>
                                                                               </xsl:call-template>
                                                                           </xsl:for-each>
                                                                           
                                                                       </xsl:for-each>
                                                                   </div>
                                                                   
                                                               </xsl:with-param>
                                                               
                                                           </xsl:call-template>
                                                           
                                                       </xsl:for-each-group>
                                                       
                                                   </xsl:for-each-group>
                                                   
                                                   <!-- Related entities -->
                                                   <xsl:if test="$related-entity-pages">
                                                       <h4 class="text-muted top-margin">
                                                           <xsl:value-of select="'Related content from the 84000 Knowledge Base'"/>
                                                       </h4>
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
                                                       
                                                       <h4 class="text-muted top-margin">
                                                           <xsl:value-of select="'Related content from the 84000 Glossary of Terms'"/>
                                                       </h4>
                                                       
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
                                               
                                           </xsl:if>
                                       
                                       </div>
                                       
                                   </div>
                                    
                                    <!-- Entity list -->
                                    <div id="entity-list" class="col-md-4 col-lg-3">
                                        
                                        <xsl:if test="$entities">
                                            
                                            <div class="form-group top-margin">
                                                
                                                <span>
                                                    <xsl:value-of select="format-number(count($entities), '#,###')"/>
                                                    <xsl:choose>
                                                        <xsl:when test="count($entities) eq 1">
                                                            <xsl:value-of select="' match'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="' matches'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                
                                                <xsl:if test="$tei-editor or $tei-editor-off">
                                                    
                                                    <span>
                                                        <xsl:value-of select="' / '"/>
                                                        <a>
                                                            <xsl:choose>
                                                                <xsl:when test="$tei-editor-off">
                                                                    <xsl:attribute name="href" select="$page-url || m:view-mode-parameter('editor')"/>
                                                                    <xsl:attribute name="class" select="'editor'"/>
                                                                    <xsl:value-of select="'Show Editor'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="href" select="$page-url"/>
                                                                    <xsl:attribute name="class" select="'editor'"/>
                                                                    <xsl:value-of select="'Hide Editor'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </a>
                                                    </span>
                                                    
                                                </xsl:if>
                                                
                                            </div>
                                            
                                            <nav role="navigation">
                                                <div class="results-list">
                                                    <xsl:for-each select="$entities-data-sorted">
                                                        
                                                        <xsl:variable name="entity-data" select="."/>
                                                        <xsl:variable name="entity" select="$entities[@xml:id eq $entity-data/@ref]"/>
                                                        
                                                        <xsl:if test="$entity-data[@related-entries ! xs:integer(.) gt 0]">
                                                            <a class="results-list-item">
                                                                
                                                                <xsl:if test="$entity/@xml:id eq $show-entity/@xml:id">
                                                                    <xsl:attribute name="class" select="'results-list-item active'"/>
                                                                </xsl:if>
                                                                
                                                                <xsl:variable name="href" select="common:internal-link(concat('/glossary.html?entity-id=', $entity/@xml:id), (if($tei-editor and $flagged gt '') then concat('flagged=', $flagged) else (), m:view-mode-parameter((),())), concat('#', $entity/@xml:id, '-detail'), $root/m:response/@lang)"/>
                                                                <xsl:variable name="ajax-target" select="'#entity-detail .entity-detail-container'"/>
                                                                
                                                                <xsl:attribute name="href" select="$href"/>
                                                                <xsl:attribute name="data-ajax-target" select="$ajax-target"/>
                                                                <xsl:attribute name="data-toggle-active" select="'_self'"/>
                                                                
                                                                <h4>
                                                                    <xsl:attribute name="class">
                                                                        <xsl:value-of select="string-join(('results-list-item-heading', common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang)),' ')"/>
                                                                    </xsl:attribute>
                                                                    <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/data())"/>
                                                                </h4>
                                                                
                                                                <xsl:if test="$entity-data[m:label[@type eq 'secondary']] and $selected-term-lang[not(@id eq 'Bo-Ltn')]">
                                                                    <div>
                                                                        <xsl:attribute name="class">
                                                                            <xsl:value-of select="string-join(('text-muted small', common:lang-class($entity-data/m:label[@type eq 'secondary']/@xml:lang)),' ')"/>
                                                                        </xsl:attribute>
                                                                        <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'secondary']/data())"/>
                                                                    </div>
                                                                </xsl:if>
                                                                
                                                                <ul class="list-unstyled">
                                                                    <xsl:for-each select="$entity-data/m:term">
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
                                                        </xsl:if>
                                                        
                                                    </xsl:for-each>
                                                </div>
                                            </nav>    
                                            
                                        </xsl:if>
                                        
                                   </div>

                                </div>
                                
                            </xsl:when>
                            
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
                            
                            <!-- No result -->
                            <xsl:otherwise>
                                <div class="top-margin">
                                    <p class="text-center text-muted italic">
                                        <xsl:value-of select="'- No results for this query -'"/>
                                    </p>
                                </div>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </div>
                    
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
        
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="text" as="element(m:text)"/>
        <xsl:param name="instance" as="element(m:instance)"/>
        
        <xsl:variable name="glossary-status" select="$text/@glossary-status"/>
        
        <div class="result">
            
            <xsl:attribute name="id" select="concat('glossary-entry-', $entry/@id)"/>
            
            <xsl:if test="$tei-editor and ($glossary-status eq 'excluded' or $instance[m:flag/@type eq 'requires-attention'])">
                <xsl:attribute name="class" select="'result excluded'"/>
            </xsl:if>
            
            <!-- Title -->
            <h4>
                
                <a>
                    <xsl:attribute name="href" select="concat($reading-room-path, '/', $text/@type, '/', $text/@id, '.html#', @id)"/>
                    <xsl:attribute name="target" select="concat($text/@id, '.html')"/>
                    <xsl:apply-templates select="($text/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], $text/m:titles/m:title[@type eq 'mainTitle'])[1]/text()"/>
                </a>
                
                <xsl:if test="$text[m:toh]">
                    <small>
                        <xsl:value-of select="' / '"/>
                        <xsl:value-of select="$text/m:toh/m:full/text()"/>
                    </small>
                </xsl:if>
                
            </h4>
            
            <!-- Editor options -->
            <xsl:if test="$tei-editor">
                
                <div>
                    <ul class="list-inline inline-dots">
                        
                        <xsl:if test="$glossary-status">
                            <li>
                                <span class="label label-danger">
                                    
                                    <xsl:value-of select="$text/m:toh/m:full/text()"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="$glossary-status eq 'excluded'">
                                            <xsl:value-of select="' glossary excluded'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="' ' || $glossary-status"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </span>
                            </li>
                        </xsl:if>
                        
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
            
            <!-- Translators -->
            <xsl:variable name="translators" select="$text/m:publication/m:contributors/m:author[normalize-space(text())]"/>
            <xsl:if test="$translators">
                <div class="text-muted small">
                    <xsl:value-of select="'Translation by '"/>
                    <xsl:value-of select="string-join($translators ! normalize-space(data()), ' · ')"/>
                </div>
            </xsl:if>
            
            <!-- Output terms grouped and ordered by language -->
            <xsl:for-each select="('bo','Bo-Ltn','Sa-Ltn','zh')">
                
                <xsl:variable name="term-lang" select="."/>
                <xsl:variable name="term-lang-terms" select="$entry/m:term[@xml:lang eq $term-lang][text()]"/>
                <xsl:variable name="term-empty-text">
                    <xsl:call-template name="text">
                        <xsl:with-param name="global-key" select="concat('glossary.term-empty-', lower-case($term-lang))"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:if test="$term-lang-terms or $term-empty-text gt ''">
                    <div>
                        <ul class="list-inline inline-dots">
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
                                                    <xsl:when test="normalize-space(text())">
                                                        <xsl:value-of select="normalize-space(text())"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="$term-empty-text"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                            </span>
                                            
                                            <xsl:if test="$tei-editor and @status eq 'verified'">
                                                <xsl:value-of select="' '"/>
                                                <span class="text-warning small">
                                                    <xsl:value-of select="'[Verified]'"/>
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
            <xsl:variable name="entry-definition" select="$entry/m:definition"/>
            <xsl:for-each select="m:definition">
                <p>
                    <xsl:attribute name="class" select="'definition small'"/>
                    <xsl:apply-templates select="."/>
                </p>
            </xsl:for-each>
            
            <!-- Entity definition -->
            <xsl:variable name="entity-definition" select="$instance/parent::m:entity/m:content[@type eq 'glossary-definition']"/>
            <xsl:if test="$tei-editor and $entity-definition and m:definition and $instance[@use-definition  eq 'both']">
                <div class="well well-sm">
                    
                    <xsl:if test="$entity-definition and m:definition">
                        <h6 class="sml-margin top bottom">
                            <xsl:value-of select="'Text also includes entity definition:'"/>
                        </h6>
                        <xsl:for-each select="$entity-definition">
                            <p>
                                <xsl:attribute name="class" select="'definition small'"/>
                                <xsl:apply-templates select="node()"/>
                            </p>
                        </xsl:for-each>
                    </xsl:if>
                    
                </div>
            </xsl:if>
            
        </div>
    
    </xsl:template>
    
</xsl:stylesheet>