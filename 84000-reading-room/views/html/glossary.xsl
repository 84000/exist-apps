<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>
    <xsl:variable name="entities" select="/m:response/m:browse-entities/m:entity"/>
    <xsl:variable name="show-entity" select="/m:response/m:show-entity/m:entity[1]"/>
    <xsl:variable name="selected-type" select="/m:response/m:request/m:entity-types/m:type[@selected eq 'selected']"/>
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
                <xsl:value-of select="$reading-room-path || '/glossary.html?' || string-join((concat('type[]=', string-join($selected-type/@id, ',')),concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text/text())), '&amp;')"/>
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
                                <xsl:value-of select="'Our combined glossary of terms, people, places, and texts.'"/>
                            </p>
                        </div>
                    </div>
                    
                    <!-- Title -->
                    <h1 class="sr-only">
                        <xsl:value-of select="$page-title"/>
                    </h1>
                    
                    <!-- Tabs -->
                    <div class="tabs-container-center">
                        <ul class="nav nav-tabs top-margin" role="tablist">
                            
                            <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
                            <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', /m:response/m:request/@term-lang), concat('type[]=', ($selected-type[1]/@id, /m:response/m:request/m:entity-types/m:type[1]/@id)[1]))"/>
                            
                            <li role="presentation">
                                <xsl:if test="string-length(normalize-space($root/m:response/m:request/m:search)) ne 1">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?search=', ''), $internal-link-attrs, '', $root/m:response/@lang)"/>
                                    <xsl:value-of select="'Search '"/>
                                    <i class="fa fa-search"/>
                                </a>
                            </li>
                            
                            <xsl:for-each select="1 to string-length($alphabet)">
                                <xsl:variable name="letter" select="substring($alphabet, ., 1)"/>
                                <li role="presentation" class="letter">
                                    <xsl:if test="$letter eq upper-case(normalize-space($root/m:response/m:request/m:search))">
                                        <xsl:attribute name="class" select="'active letter'"/>
                                    </xsl:if>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link(concat('/glossary.html?search=', $letter), $internal-link-attrs, '', $root/m:response/@lang)"/>
                                        <xsl:value-of select="$letter"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                            
                        </ul>
                    </div>
                    
                    <xsl:choose>
                        
                        <!-- Search box -->
                        <xsl:when test="string-length($search-text) ne 1">
                            <form action="/glossary.html" method="post" role="search" class="form-inline">
                                
                                <div class="align-center bottom-margin">
                                    <div class="form-group">
                                        
                                        <xsl:for-each select="m:request/m:entity-types/m:type">
                                            <div class="checkbox">
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
                        
                        <!-- Type/Lang controls -->
                        <xsl:otherwise>
                            
                            <div class="center-vertical-md align-center bottom-margin">
                                
                                <!-- Type tabs -->
                                <div>
                                    
                                    <ul class="nav nav-pills">
                                        
                                        <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', $selected-term-lang/@id), concat('search=', $search-text))"/>
                                        
                                        <xsl:for-each select="m:request/m:entity-types/m:type">
                                            
                                            <li role="presentation">
                                                <xsl:if test="@selected eq 'selected'">
                                                    <xsl:attribute name="class" select="'active'"/>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href" select="common:internal-link('/glossary.html', (concat('type[]=', @id), $internal-link-attrs) , '', /m:response/@lang)"/>
                                                    <xsl:value-of select="m:label[@type eq 'plural']"/>
                                                </a>
                                            </li>
                                            
                                        </xsl:for-each>
                                        
                                    </ul>
                                    
                                    
                                </div>
                                
                                <!-- Language tabs -->
                                <div>
                                    
                                    <ul class="nav nav-pills">
                                        
                                        <xsl:variable name="internal-link-attrs" select="(concat('type[]=', string-join($selected-type[1]/@id, ',')), concat('search=', $search-text))"/>
                                        
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
                                    
                                </div>
                            </div>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <!-- Results -->
                    <div id="glossary-results" class="row">
                        <xsl:choose>
                            
                            <!-- Result -->
                            <xsl:when test="$show-entity or $entities">
                                
                                <!-- Selected entity -->
                                <div id="entity-selected" class="col-md-8 col-lg-9">
                                   
                                   <div id="entity-detail">
                                       
                                       <xsl:if test="$show-entity">
                                           
                                           <xsl:attribute name="class" select="'search-result collapse in persist'"/>
                                           
                                           <!-- Show first record by default -->
                                           <xsl:variable name="primary-label" select="($show-entity/m:label[@primary eq 'true'], $show-entity/m:label[1])[1]"/>
                                           <xsl:variable name="primary-transliterated" select="$show-entity/m:label[@primary-transliterated eq 'true']"/>
                                           
                                           <div class="entity-detail-container replace" id="term-translations">
                                               
                                               <xsl:attribute name="id" select="concat($show-entity/@xml:id, '-detail')"/>
                                               
                                               <div class="entity-detail-header">
                                                   
                                                   <h2>
                                                       
                                                       <span>
                                                           <xsl:attribute name="class">
                                                               <xsl:value-of select="string-join(((), common:lang-class($primary-label/@xml:lang)),' ')"/>
                                                           </xsl:attribute>
                                                           <xsl:value-of select="normalize-space($primary-label/text())"/>
                                                       </span>
                                                       
                                                       <xsl:for-each-group select="$show-entity/m:type" group-by="@type">
                                                           <xsl:variable name="type" select="."/>
                                                           <xsl:value-of select="' '"/>
                                                           <span class="label label-info">
                                                               <xsl:value-of select="/m:response/m:request/m:entity-types/m:type[@id eq $type[1]/@type]/m:label[@type eq 'singular']"/>
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
                                               
                                               <!-- Glossary entries -->
                                               <!-- Group by translation -->
                                               <xsl:for-each-group select="$show-entity/m:instance/m:item" group-by="m:term[@xml:lang eq 'en'][1]/normalize-space(.)">
                                                   
                                                   <xsl:sort select="m:sort-term"/>
                                                   <xsl:variable name="item-group-index" select="position()"/>
                                                   
                                                   <h3 class="term">
                                                       <xsl:value-of select="m:term[@xml:lang eq 'en'][1] ! functx:capitalize-first(.)"/>
                                                   </h3>
                                                   
                                                   <!-- Group by type (translation/knowledgebase) -->
                                                   <xsl:for-each-group select="current-group()" group-by="m:text/@type">
                                                       
                                                       <xsl:call-template name="expand-item">
                                                           
                                                           <xsl:with-param name="id" select="concat('expand-', $item-group-index, '-', m:text/@type)"/>
                                                           <xsl:with-param name="accordion-selector" select="'no-accordion'"/>
                                                           <xsl:with-param name="active" select="(count($show-entity/m:instance) eq 1)"/>
                                                           
                                                           <xsl:with-param name="title">
                                                               <div class="sml-margin bottom">
                                                                   <span class="badge badge-notification">
                                                                       <xsl:value-of select="count(current-group())"/>
                                                                   </span>
                                                                   <span class="badge-text">
                                                                       <xsl:choose>
                                                                           <xsl:when test="m:text[@type eq 'knowledgebase']">
                                                                               <xsl:value-of select="if(count(current-group()) eq 1) then 'knowledge base page' else 'knowledge base pages'"/>
                                                                           </xsl:when>
                                                                           <xsl:otherwise>
                                                                               <xsl:value-of select="if(count(current-group()) eq 1) then 'publication' else 'publications'"/>
                                                                           </xsl:otherwise>
                                                                       </xsl:choose>
                                                                   </span>
                                                               </div>
                                                           </xsl:with-param>
                                                           
                                                           <xsl:with-param name="content">
                                                               
                                                               <xsl:for-each select="current-group()">
                                                                   
                                                                   <xsl:apply-templates select="."/>
                                                                   
                                                               </xsl:for-each>
                                                               
                                                           </xsl:with-param>
                                                           
                                                       </xsl:call-template>
                                                       
                                                   </xsl:for-each-group>
                                                   
                                               </xsl:for-each-group>
                                               
                                               <!-- Knowledgebase page -->
                                               <xsl:if test="$show-entity/m:instance[m:page]">
                                                   
                                                   <div class="text-muted italic top-margin">
                                                       <xsl:value-of select="'Read more in the 84000 Knowledge Base'"/>
                                                   </div>
                                                   
                                                   <xsl:for-each-group select="$show-entity/m:instance/m:page" group-by="m:titles/m:title[@type eq 'mainTitle'][1]/normalize-space(.)">
                                                       
                                                       <xsl:sort select="m:sort-name"/>
                                                       
                                                       <a target="84000-knowledgebase">
                                                           <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                           <h3 class="no-top-margin">
                                                               <xsl:value-of select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                                                           </h3>
                                                       </a>
                                                       
                                                   </xsl:for-each-group>
                                                   
                                               </xsl:if>
                                               
                                           </div>
                                           
                                       </xsl:if>
                                   
                                   </div>
                                   
                               </div>
                               
                                <!-- Entity list -->
                                <div id="entity-list" class="col-md-4 col-lg-3">
                                   
                                   <xsl:if test="$entities">
                                       
                                       <div class="form-group top-margin">
                                           <span class="badge badge-notification">
                                               <xsl:value-of select="count($entities)"/>
                                           </span>
                                           <span class="badge-text">
                                               <xsl:choose>
                                                   <xsl:when test="count($entities) eq 1">
                                                       <xsl:value-of select="' match'"/>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <xsl:value-of select="'matches'"/>
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
                                                       
                                                       <h4>
                                                           <xsl:attribute name="class">
                                                               <xsl:value-of select="string-join(('results-list-item-heading', common:lang-class($primary-label/@xml:lang)),' ')"/>
                                                           </xsl:attribute>
                                                           <xsl:value-of select="normalize-space($primary-label/text())"/>
                                                       </h4>
                                                       
                                                       <xsl:if test="$primary-transliterated and $selected-term-lang[not(@id eq 'Bo-Ltn')]">
                                                           <div>
                                                               <xsl:attribute name="class">
                                                                   <xsl:value-of select="string-join(('text-muted small', common:lang-class($primary-transliterated/@xml:lang)),' ')"/>
                                                               </xsl:attribute>
                                                               <xsl:value-of select="normalize-space($primary-transliterated/text())"/>
                                                           </div>
                                                       </xsl:if>
                                                       
                                                       <ul class="list-unstyled">
                                                           <xsl:for-each-group select="$entity/m:instance/m:item/m:term[@xml:lang eq $selected-term-lang/@id]" group-by="common:standardized-sa(text())">
                                                               <xsl:variable name="match-text" select="string-join(tokenize(data(), '\s+') ! common:standardized-sa(.) ! common:alphanumeric(.), ' ')"/>
                                                               <xsl:variable name="match-regex" select="concat(if(string-length($search-text) ne 1) then '(?:^|\s+)' else '^', string-join(tokenize($search-text, '\s+') ! common:standardized-sa(.) ! common:alphanumeric(.), '.*\s+'))"/>
                                                               <li class="small">
                                                                   <!--<xsl:value-of select="$match-text"/><br/>
                                                                   <xsl:value-of select="$match-regex"/><br/>-->
                                                                   <xsl:choose>
                                                                       <xsl:when test="matches($match-text, $match-regex, 'i')">
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

                            </xsl:when>
                            
                            <!-- No result -->
                            <xsl:otherwise>
                                <div class="col-sm-12 top-margin">
                                    <p class="text-center text-muted italic">
                                        <xsl:value-of select="'- No results for this query -'"/>
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
    
    <xsl:template match="m:item">
        
        <div class="result">
            
            <!-- Text -->
            <h4>
                
                <a>
                    <xsl:attribute name="href" select="concat($reading-room-path, '/', m:text/@type, '/', m:text/@id, '.html#', @id)"/>
                    <xsl:attribute name="target" select="concat(m:text/@id, '.html')"/>
                    <xsl:apply-templates select="m:text/m:title/text()"/>
                </a>
                
                <xsl:if test="m:text[m:toh]">
                    <small>
                        <xsl:value-of select="' / '"/>
                        <xsl:value-of select="m:text/m:toh/text()"/>
                    </small>
                </xsl:if>
                
                <xsl:if test="/m:response/m:request[@view-mode eq 'editor'] and $environment/m:url[@id eq 'operations']">
                    <small>
                        <xsl:value-of select="' / '"/>
                        <a target="84000-glossary-tool" class="underline small">
                            <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/data(), '/edit-glossary.html?resource-id=', m:text/@id, '&amp;glossary-id=', @id, '&amp;max-records=1')"/>
                            <xsl:value-of select="'Glossary editor'"/>
                        </a>
                    </small>
                </xsl:if>
                
            </h4>
            
            <!-- Translators -->
            <xsl:variable name="translators" select="m:text/m:authors/m:author[normalize-space(text())]"/>
            <xsl:if test="$translators">
                <div class="text-muted small">
                    <xsl:value-of select="'Translation by '"/>
                    <xsl:value-of select="string-join($translators ! normalize-space(data()), ' · ')"/>
                </div>
            </xsl:if>
            
            <!-- Output terms grouped and ordered by language -->
            <xsl:variable name="item" select="."/>
            <xsl:for-each select="('Bo-Ltn','bo','Sa-Ltn', 'zh')">
                
                <xsl:variable name="term-lang" select="."/>
                <xsl:variable name="term-lang-terms" select="$item/m:term[@xml:lang eq $term-lang]"/>
                <xsl:variable name="term-empty-text">
                    <xsl:call-template name="text">
                        <xsl:with-param name="global-key" select="concat('glossary.term-empty-', lower-case($term-lang))"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:if test="$term-lang-terms or $term-empty-text gt ''">
                    <ul class="list-inline inline-dots">
                        <xsl:choose>
                            <xsl:when test="$term-lang-terms">
                                <xsl:for-each select="$term-lang-terms">
                                    <li>
                                        
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
                                        
                                    </li>
                                </xsl:for-each>
                            </xsl:when>
                        </xsl:choose>
                    </ul>
                </xsl:if>
                
            </xsl:for-each>
            
            <!-- Alternatives -->
            <xsl:variable name="alternative-terms" select="m:alternative"/>
            <xsl:if test="$view-mode[@id = ('editor', 'annotation', 'tests', 'editor-passage')] and $alternative-terms">
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
            </xsl:if>
            
            <!-- Definition -->
            <xsl:for-each select="m:definition">
                <p class="definition">
                    <xsl:apply-templates select="."/>
                </p>
            </xsl:for-each>
            
        </div>
    </xsl:template>
    
</xsl:stylesheet>