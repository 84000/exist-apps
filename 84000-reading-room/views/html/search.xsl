<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="base-url" select="common:internal-link('/search.html',(concat('search-type=', $request/@search-type), concat('search-lang=', $request/@search-lang), $request/m:search-data/m:type[@selected eq 'selected'] ! concat('search-data[]=', @id), concat('search=', $request/m:search)), (), /m:response/@lang)"/>
    <xsl:variable name="specified-text" select="/m:response/m:tei-search/m:request/m:header"/>
    
    <xsl:key name="end-notes-pre-processed" match="m:pre-processed[@type eq 'end-notes']/m:end-note" use="@id"/>
    
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
                                        <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', @lang)"/>
                                        <xsl:value-of select="'The Collection'"/>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('search.html', (), '', @lang)"/>
                                        <xsl:value-of select="'Search Our Translations'"/>
                                    </a>
                                </li>
                                <xsl:if test="$request/m:search[text()]">
                                    <li>
                                        <xsl:value-of select="$request/m:search"/>
                                    </li>
                                </xsl:if>
                            </ul>
                        </nav>
                        
                        <div>
                            <div class="center-vertical pull-right">
                                
                                <div>
                                    <a class="center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', @lang)"/>
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
                            <h1 class="title main-title">
                                <xsl:value-of select="'Search Our Translations'"/>
                            </h1>
                        </div>
                    </div>
                    
                    <!-- Search type tabs -->
                    <div class="tabs-container-center">
                        <ul class="nav nav-tabs" role="tablist">
                            
                            <!-- TEI search tab -->
                            <li role="presentation">
                                <xsl:if test="not($request/@search-type eq 'tm')">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/search.html', (concat('search=', $request/m:search)), '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Search the 84000 published translations'"/>
                                    <xsl:attribute name="data-loading" select="'Loading publications search...'"/>
                                    <xsl:value-of select="'The Publications'"/>
                                </a>
                            </li>
                            
                            <!-- TM search tab -->
                            <li role="presentation" class="icon">
                                <xsl:if test="$request/@search-type eq 'tm'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a>
                                    <xsl:attribute name="href" select="common:internal-link('/search.html', ('search-type=tm', concat('search=', $request/m:search), 'search-glossary=1'), '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="title" select="'Search the 84000 Translation Memory'"/>
                                    <xsl:attribute name="data-loading" select="'Loading translation memory search...'"/>
                                    <xsl:value-of select="'Translation Memory'"/>
                                </a>
                            </li>
                            
                        </ul>
                    </div>
                    
                    <!-- Search types -->
                    <xsl:choose>
                        
                        <!-- TM search -->
                        <xsl:when test="$request/@search-type eq 'tm'">
                            
                            <p class="text-center text-muted small">
                                <xsl:value-of select="'Search our Translation Memory files to find translations aligned with the Tibetan source.'"/>
                                <br/>
                                <xsl:value-of select="'Use quotation marks e.g. &#34;realm of phenomena&#34; to search for complete phrases rather than individual words.'"/>
                            </p>
                            
                            <div id="search-container">
                                
                                <!-- TM search form -->
                                <xsl:call-template name="tm-search-form"/>
                                
                                <!-- TM search results -->
                                <xsl:call-template name="tm-search-results">
                                    <xsl:with-param name="results" select="m:tm-search/m:results"/>
                                    <xsl:with-param name="pagination-url" select="$base-url"/>
                                    <xsl:with-param name="dualview" select="true()"/>
                                </xsl:call-template>
                                
                            </div>
                            
                        </xsl:when>
                        
                        <!-- TEI search -->
                        <xsl:otherwise>
                            
                            <p class="text-center text-muted small bottom-margin">
                                <xsl:value-of select="'The 84000 database contains both the translated texts and titles and summaries for other works within the Kangyur and Tengyur.'"/>
                            </p>
                            
                            <div id="search-container">
                                
                                <!-- TEI search form -->
                                <xsl:call-template name="tei-search-form"/>
                                
                                <!-- TEI search results -->
                                <xsl:call-template name="tei-search-results">
                                    <xsl:with-param name="results" select="m:tei-search/m:results"/>
                                    <xsl:with-param name="pagination-url" select="$base-url"/>
                                </xsl:call-template>
                                
                            </div>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </div>
            </main>
            
            <xsl:call-template name="dualview-popup"/>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/search.html?s=', $request/m:search)"/>
            <xsl:with-param name="page-class" select="'reading-room section'"/>
            <xsl:with-param name="page-title" select="string-join((if($request/m:search/text() gt '') then $request/m:search/text() else (), 'Search' , '84000 Reading Room'), ' | ')"/>
            <xsl:with-param name="page-description" select="if($request/m:search/text() gt '') then concat('Search results for ', $request/m:search) else 'Search the 84000 Reading Room'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="tei-search-form">
        
        <div class="row">
            <div class="col-sm-8 col-sm-offset-2">
                <form action="/search.html" method="get" role="search" class="form-horizontal" data-loading="Loading...">
                    
                    <input type="hidden" name="lang" value="{ $request/@lang }"/>
                    <input type="hidden" name="search-type" value="tei"/>
                    
                    <xsl:if test="not($specified-text)">
                        <div class="form-group align-center bottom-margin">
                            <xsl:for-each select="$request/m:search-data/m:type">
                                <div class="checkbox-inline">
                                    <label>
                                        <input type="checkbox" name="search-data[]">
                                            <xsl:attribute name="value" select="@id"/>
                                            <xsl:if test="@selected eq 'selected'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="' ' || text()"/>
                                    </label>
                                </div>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    
                    <div class="input-group">
                        <input type="search" name="search" id="search" class="form-control" aria-label="Search text" placeholder="Search" required="required">
                            <xsl:attribute name="value" select="$request/m:search"/>
                        </input>
                        <span class="input-group-btn">
                            <button type="submit" class="btn btn-primary">
                                <xsl:value-of select="'Search'"/>
                            </button>
                        </span>
                    </div>
                    
                    <xsl:if test="$specified-text">
                        <input type="hidden" name="specified-text" value="{ $specified-text/@resource-id }"/>
                        <div class="alert alert-warning small top-margin no-bottom-margin" role="alert">
                            <xsl:value-of select="concat('in ', ($specified-text/m:titles/m:title[@xml:lang eq 'en'])[1] , ' / ', ($specified-text/m:bibl/m:toh/m:full)[1])"/>
                            <span class="pull-right">
                                <a class="inline-block alert-link">
                                    <xsl:attribute name="href" select="$base-url"/>
                                    <xsl:value-of select="'remove filter'"/>
                                </a>
                            </span>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="m:tei-search/m:results[@count-matches-processed lt @count-matches-all]">
                        <div class="alert alert-danger small top-margin no-bottom-margin" role="alert">
                            <xsl:value-of select="concat('Please refine your search. This term is very common and only the first ', format-number(m:tei-search/m:results/@count-matches-processed, '#,###'), ' of ',  format-number(m:tei-search/m:results/@count-matches-all, '#,###'), ' matches have been processed.')"/>
                        </div>
                    </xsl:if>
                    
                </form>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="tm-search-form">

        <div class="row">
            <div class="col-sm-8 col-sm-offset-2">
                <form action="/search.html" method="get" role="search" accept-charset="UTF-8" class="form-horizontal" data-loading="Loading...">
                    
                    <input type="hidden" name="lang" value="{ $request/@lang }"/>
                    <input type="hidden" name="search-type" value="tm"/>
                    
                    <div class="form-group align-center bottom-margin">
                        
                        <xsl:for-each select="$request/m:search-langs/m:lang">
                            <div class="radio-inline">
                                <label>
                                    <input type="radio" name="search-lang">
                                        <xsl:attribute name="value" select="@id"/>
                                        <xsl:if test="@selected eq 'selected'">
                                            <xsl:attribute name="checked" select="'checked'"/>
                                        </xsl:if>
                                    </input>
                                    <xsl:value-of select="' ' || text()"/>
                                </label>
                            </div>
                        </xsl:for-each>
                        
                        <div class="radio-inline">
                            <label>
                                <input type="checkbox" name="search-glossary">
                                    <xsl:attribute name="value" select="'1'"/>
                                    <xsl:if test="$request/@search-glossary eq '1'">
                                        <xsl:attribute name="checked" select="'checked'"/>
                                    </xsl:if>
                                </input>
                                <xsl:value-of select="' Include glossary entries'"/>
                            </label>
                        </div>
                        
                    </div>
                    
                    <div class="input-group">
                        
                        <input type="search" name="search" class="form-control" value="{ $request/m:search }" aria-label="Search text" placeholder="Search" required="required"/>
                        
                        <div class="input-group-btn">
                            <button type="submit" class="btn btn-primary">
                                <xsl:value-of select="' Search'"/>
                            </button>
                        </div>
                        
                    </div>
                    
                </form>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="tei-search-results">
        
        <xsl:param name="results" as="element(m:results)?"/>
        <xsl:param name="pagination-url" as="xs:string"/>
        <xsl:param name="ajax-target" as="xs:string?"/>
        
        <div class="row">
            <div class="col-sm-8 col-sm-offset-2">
                
                <!-- Results list -->
                <xsl:choose>
                    <xsl:when test="$results[m:result]">
                        
                        <xsl:variable name="first-record" select="$results/@first-record"/>
                        
                        <div class="search-results">
                            <xsl:for-each select="$results/m:result">
                                
                                <xsl:sort select="@score ! xs:double(.)" order="descending"/>
                                
                                <xsl:variable name="result" select="."/>
                                <xsl:variable name="header" select="$result/m:header"/>
                                <xsl:variable name="matches" select="$result/m:match"/>
                                <xsl:variable name="count-matches" select="$result/@count-matches" as="xs:integer"/>
                                <xsl:variable name="record-number" select="$first-record + (position() - 1)"/>
                                
                                <xsl:variable name="matched-elements" select="$matches/*"/>
                                <xsl:variable name="matched-title" select="$matches/tei:title[@type eq 'mainTitle'][@xml:lang eq 'en'][1]" as="element(tei:title)?"/>
                                
                                <xsl:variable name="matched-entity-data" as="element(m:entity-data)?">
                                    <xsl:if test="$header[@type eq 'entity']">
                                        <xsl:call-template name="entity-data">
                                            <xsl:with-param name="entity" select="$header/m:entity"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </xsl:variable>
                                
                                <div class="search-result">
                                    
                                    <!-- Title -->
                                    <div class="row">
                                        
                                        <div class="col-sm-12 col-md-10">
                                            
                                            <h3 class="result-title">
                                                <a>
                                                    
                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $header/@link), (), '', /m:response/@lang)"/>
                                                    
                                                    <xsl:attribute name="target" select="concat($header/@resource-id, '.html')"/>
                                                    
                                                    <!-- If the match is in the main title then use the match, otherwise output the title -->
                                                    
                                                    <xsl:choose>
                                                        
                                                        <xsl:when test="$matched-title">
                                                            <xsl:apply-templates select="$matched-title/node()"/>
                                                        </xsl:when>
                                                        
                                                        <xsl:when test="$matched-entity-data">
                                                            <xsl:sequence select="common:mark-string(($matched-entity-data/m:term[@xml:lang eq 'en'], $matched-entity-data/m:label[@xml:lang eq 'Sa-Ltn'], $matched-entity-data/m:label[@xml:lang eq 'bo'])[1]/text() ! normalize-space(.), common:escape-for-regex($request/m:search/text()))"/>
                                                        </xsl:when>
                                                        
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="($header/m:titles/m:title[@xml:lang eq 'en'], $header/m:titles/m:title[@xml:lang eq 'Sa-Ltn'], $header/m:label)[normalize-space(text())][1]/node()"/>
                                                        </xsl:otherwise>
                                                        
                                                    </xsl:choose>
                                                    
                                                </a>
                                            </h3>
                                            
                                        </div>
                                        
                                        <div class="col-sm-12 col-md-2 text-right-md">
                                            
                                            <xsl:choose>
                                                <xsl:when test="$header[@type = 'section']">
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="'Section'"/>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:sequence select="common:translation-status($header/@status-group)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                    </div>
                                    
                                    <!-- Location / breadcrumbs -->
                                    <xsl:for-each select="$header/m:bibl">
                                        <xsl:variable name="toh-key" select="m:toh/@key"/>
                                        <nav role="navigation" aria-label="Breadcrumbs" class="small text-muted">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                
                                                <xsl:sequence select="common:breadcrumb-items(m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                                
                                                <xsl:if test="m:toh/m:full">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="target" select="concat($header/@resource-id, '.html')"/>
                                                            <!-- If the match is a Toh number then output the match -->
                                                            <xsl:variable name="bibl-match" select="$matches/tei:bibl[@key eq $toh-key][tei:ref/exist:match][1]" as="element(tei:bibl)?"/>
                                                            <xsl:choose>
                                                                <xsl:when test="$bibl-match">
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $bibl-match/parent::m:match/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:apply-templates select="$bibl-match/tei:ref"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $header/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:apply-templates select="m:toh/m:full"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                            </ul>
                                        </nav>
                                    </xsl:for-each>
                                    
                                    <xsl:for-each select="$header[@render eq 'knowledgebase']/m:page">
                                        <p class="small">
                                            <span class="text-muted">
                                                <xsl:value-of select="'in '"/>
                                            </span>
                                            <xsl:value-of select="'The 84000 Knowledge Base'"/>
                                        </p>
                                    </xsl:for-each>
                                    
                                    <xsl:for-each select="$header[@type eq 'entity']">
                                        <p class="small">
                                            <span class="text-muted">
                                                <xsl:value-of select="'in '"/>
                                            </span>
                                            <xsl:value-of select="'The 84000 Glossary of Terms'"/>
                                        </p>
                                    </xsl:for-each>
                                    
                                    <!-- Warnings -->
                                    <xsl:variable name="tantric-restriction" select="$header[@render eq 'translation']/m:publication/m:tantric-restriction"/>
                                    <xsl:if test="$tantric-restriction/tei:p">
                                        <div class="row">
                                            <div class="col-sm-12">
                                                
                                                <xsl:call-template name="tantra-warning">
                                                    <xsl:with-param name="id" select="$header/@resource-id"/>
                                                </xsl:call-template>
                                                
                                            </div>
                                        </div>
                                    </xsl:if>
                                    
                                    <!-- Matches -->
                                    <section class="result-matches">
                                        
                                        <xsl:variable name="section-id" select="concat('result-matches-', position())"/>
                                        <xsl:attribute name="id" select="$section-id"/>
                                        
                                        <xsl:if test="not($specified-text) and count($matched-elements) gt count($matched-title) and count($matched-elements) gt 1">
                                            
                                            <xsl:attribute name="class" select="'result-matches preview'"/>
                                            
                                            <xsl:call-template name="preview-controls">
                                                
                                                <xsl:with-param name="section-id" select="$section-id"/>
                                                <xsl:with-param name="href" select="concat('#', $section-id)"/>
                                                
                                            </xsl:call-template>
                                            
                                        </xsl:if>
                                        
                                        <!-- Count of matches -->
                                        <div class="row">
                                            <div class="col-sm-12">
                                                
                                                <span class="badge badge-notification">
                                                    <xsl:value-of select="format-number($count-matches, '#,###')"/> 
                                                </span>
                                                
                                                <span class="badge-text">
                                                    <xsl:choose>
                                                        <xsl:when test="$count-matches eq 1">
                                                            <xsl:value-of select="' match'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="' matches'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                
                                            </div>
                                        </div>
                                        
                                        <!-- Output the matches -->
                                        <xsl:if test="count($matched-elements) gt count($matched-title)">
                                            <xsl:for-each select="$matches">
                                                
                                                <xsl:sort select="@score" data-type="number" order="descending"/>
                                                
                                                <xsl:variable name="match" select="."/>
                                                
                                                <!-- If this is the matched title and it's not the only result -->
                                                <xsl:if test="count($matches) eq 1 or count($match | $matched-title/parent::m:match) gt count($matched-title/parent::m:match)">
                                                    
                                                    <div class="search-match">
                                                        
                                                        <!-- Output the match (unless it's only in the note) -->
                                                        <xsl:if test="($match/descendant::exist:match[not(ancestor::tei:note[@place eq 'end'])][not(ancestor::tei:orig)] or not($match/descendant::exist:match))">
                                                            <div>
                                                                <!-- Reduce this to a snippet -->
                                                                <xsl:apply-templates select="node()"/>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                        <!-- Output related notes if they have matches too -->
                                                        <xsl:for-each select="$match/descendant::tei:note[descendant::exist:match][@place eq 'end'][@xml:id]">
                                                            <xsl:variable name="end-note" select="."/>
                                                            <xsl:variable name="end-note-pre-processed" select="key('end-notes-pre-processed', $end-note/@xml:id)[@source-key = $header/m:bibl/m:toh/@key[1]][1]" as="element(m:end-note)?"/>
                                                            <div class="row search-match-note">
                                                                <div class="col-sm-1">
                                                                    <span>
                                                                        <xsl:value-of select="concat('n.', $end-note-pre-processed/@index)"/>
                                                                    </span>
                                                                </div>
                                                                <div class="col-sm-11">
                                                                    <span>
                                                                        <!-- Reduce this to a snippet -->
                                                                        <xsl:apply-templates select="node()"/>
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </xsl:for-each>
                                                        
                                                        <xsl:if test="$match[@link gt '']">
                                                            <div>
                                                                <a>
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $match/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:attribute name="target" select="concat($header/@resource-id, '.html')"/>
                                                                    <xsl:value-of select="'read...'"/>
                                                                </a>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                    </div>
                                                    
                                                </xsl:if>
                                                
                                            </xsl:for-each>
                                        </xsl:if>
                                        
                                        <!-- Link to view remainder -->
                                        <xsl:if test="$count-matches gt count($matches)">
                                            <div class="row">
                                                
                                                <div class="col-sm-12">
                                                    <p>
                                                        
                                                        <xsl:value-of select="concat('These are the first ', count($matches), ' matches. ')"/>
                                                        
                                                        <xsl:choose>
                                                            <xsl:when test="$header[@type eq 'translation'] and not($specified-text)">
                                                                
                                                                <a target="_self">
                                                                    <xsl:attribute name="href" select="common:internal-link('/search.html',(concat('search-type=', $request/@search-type), concat('search-lang=', $request/@search-lang), concat('search=', $request/m:search), concat('specified-text=', $header/@resource-id)), (), /m:response/@lang)"/>
                                                                    <xsl:value-of select="concat('View all ', format-number($count-matches, '#,###'))"/>
                                                                </a>
                                                                
                                                            </xsl:when>
                                                            <xsl:when test="$header[@type eq 'entity']">
                                                                
                                                                <a>
                                                                    <xsl:attribute name="target" select="concat($header/@resource-id, '.html')"/>
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $header/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:value-of select="'View the glossary entry.'"/>
                                                                </a>
                                                                
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </p>
                                                </div>
                                            </div>
                                            
                                        </xsl:if>
                                        
                                    </section>
                                    
                                </div>
                                
                            </xsl:for-each>
                        </div>
                        
                        <!-- Pagination -->
                        <xsl:sequence select="common:pagination($results/@first-record, $results/@max-records, $results/@count-records, $pagination-url, $ajax-target)"/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        
                        <!-- No results -->
                        <div class="text-center top-margin">
                            
                            <p class="text-muted italic ">
                                <xsl:value-of select="'~ No search results ~'"/>
                            </p>
                            
                        </div>
                        
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="tm-search-results">
        
        <xsl:param name="results" as="element(m:results)?"/>
        <xsl:param name="pagination-url" as="xs:string"/>
        <xsl:param name="ajax-target" as="xs:string?"/>
        <xsl:param name="dualview" as="xs:boolean" select="false()"/>
        
        <xsl:choose>
            <xsl:when test="$results[m:item]">
                
                <div class="search-results top-margin">
                    
                    <xsl:for-each select="$results/m:item">
                        
                        <xsl:sort select="@score ! xs:double(.)" order="descending"/>
                        
                        <div class="search-result" id="search-result-{ @index }">
                            <div class="row">
                                
                                <!-- Segments -->
                                <div class="col-sm-6">
                                    <div class="row">
                                        <div class="col-sm-1 sml-margin top">
                                            
                                            <span class="text-muted">
                                                <xsl:value-of select="concat(@index, '.')"/>
                                            </span>
                                            
                                            <!--<br/>
                                            <xsl:value-of select="@score"/>-->
                                            
                                        </div>
                                        <div class="col-sm-11">
                                            
                                            <ul class="list-unstyled search-match-gloss">
                                                <xsl:if test="m:match/m:tibetan[node()]">
                                                    <li>
                                                        <span class="text-bo">
                                                            <xsl:apply-templates select="m:match/m:tibetan/node()"/>
                                                        </span>
                                                    </li>
                                                </xsl:if>
                                                <xsl:if test="m:match/m:translation[node()]">
                                                    <li>
                                                        <span class="translation">
                                                            <xsl:apply-templates select="m:match/m:translation/node()"/>
                                                        </span>
                                                    </li>
                                                </xsl:if>
                                                <xsl:if test="m:match/m:sanskrit[node()]">
                                                    <li>
                                                        <span class="text-sa">
                                                            <xsl:apply-templates select="m:match/m:sanskrit/node()"/>
                                                        </span>
                                                    </li>
                                                </xsl:if>
                                                
                                            </ul>
                                            
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Metadata -->
                                <div class="col-sm-6">
                                    
                                    <!-- 
                                        Link to text
                                        - allow for surfeit glossary entries that shouldn't be linked -->
                                    <div>
                                        <xsl:choose>
                                            <xsl:when test="m:match/@location gt ''">
                                                
                                                <!-- Dualview link -->
                                                <a>
                                                    <xsl:attribute name="href" select="concat($reading-room-path, m:match/@location)"/>
                                                    <xsl:choose>
                                                        <xsl:when test="$dualview">
                                                            <xsl:attribute name="target" select="concat('translation-', m:header/@resource-id)"/>
                                                            <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, m:match/@location)"/>
                                                            <xsl:attribute name="data-dualview-title" select="m:header/m:bibl[1]/m:toh/m:full/text()"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="target" select="concat(m:header/@resource-id, '.html')"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:apply-templates select="m:header/m:titles/m:title[@xml:lang eq 'en']"/>
                                                </a>
                                                
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="m:header/m:titles/m:title[@xml:lang eq 'en']"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </div>
                                    
                                    <!-- Location in the canon -->
                                    <xsl:for-each select="m:header/m:bibl">
                                        
                                        <xsl:variable name="bibl" select="."/>
                                        
                                        <div class="ancestors text-muted small">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                
                                                <xsl:sequence select="common:breadcrumb-items($bibl/m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                                
                                                <xsl:if test="$bibl/m:toh/m:full">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $bibl/m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="target" select="concat($bibl/@resource-id, '.html')"/>
                                                            <xsl:apply-templates select="$bibl/m:toh/m:full"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                            </ul>
                                        </div>
                                        
                                    </xsl:for-each>
                                    
                                    <!-- Contributors -->
                                    <xsl:if test="m:header/m:publication/m:contributors/m:author[@role eq 'translatorEng'][text()]">
                                        <div class="translators text-muted small">
                                            <span class="nowrap">
                                                <xsl:value-of select="'Translated by: '"/> 
                                            </span>
                                            <ul class="list-inline inline-dots">
                                                <xsl:for-each select="m:header/m:publication/m:contributors/m:author[@role eq 'translatorEng'][text()]">
                                                    <li>
                                                        <xsl:value-of select="."/>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </xsl:if>
                                    
                                    <!-- labels -->
                                    <div>
                                        <ul class="list-inline">
                                            
                                            <xsl:choose>
                                                <xsl:when test="m:match/@type eq 'glossary-term'">
                                                    <li>
                                                        <span class="label label-default">
                                                            <xsl:value-of select="'Glossary'"/>
                                                        </span>
                                                    </li>
                                                </xsl:when>
                                                <xsl:when test="m:match/@type eq 'tm-unit'">
                                                    <li>
                                                        <span class="label label-default">
                                                            <xsl:value-of select="'TM'"/>
                                                        </span>
                                                    </li>
                                                </xsl:when>
                                            </xsl:choose>
                                            
                                            <xsl:if test="m:match/m:flag[@type eq 'machine-alignment']">
                                                <li>
                                                    <span class="label label-default">
                                                        <xsl:value-of select="'Machine alignment'"/>
                                                    </span>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:if test="m:match/m:flag[@type eq 'alternative-source']">
                                                <li>
                                                    <span class="label label-default">
                                                        <xsl:value-of select="'Translated from a different source'"/>
                                                    </span>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:if test="m:match/m:flag[not(@type = ('machine-alignment','alternative-source','requires-attention'))]">
                                                <li>
                                                    <span class="label label-default">
                                                        <xsl:value-of select="m:match/m:flag/@type"/>
                                                    </span>
                                                </li>
                                            </xsl:if>
                                            
                                        </ul>
                                    </div>
                                    
                                </div>
                                
                            </div>
                            
                        </div>
                    
                    </xsl:for-each>
                </div>
                
                <hr class="sml-margin"/>
                
                <!-- Pagination -->
                <xsl:sequence select="common:pagination($results/@first-record, $results/@max-records, $results/@count-records, $pagination-url, $ajax-target)"/>
                
            </xsl:when>
            <xsl:otherwise>
                
                <div class="text-center top-margin">
                    
                    <p class="text-muted italic">
                        <xsl:value-of select="'~ No search results ~'"/>
                    </p>
                    
                    <xsl:choose>
                        
                        <!-- Nothing found -->
                        <xsl:when test="$request/m:search ! normalize-space(.) gt ''">
                            
                            <p class="italic">
                                <xsl:value-of select="'Try a different search'"/>
                            </p>
                            
                            <ul class="list-inline inline-dots">
                                <xsl:for-each select="$request/m:search-langs/m:lang[not(@selected)]">
                                    <li>
                                        <a class="underline">
                                            <xsl:attribute name="href" select="common:internal-link('/search.html',(concat('search-type=', $request/@search-type), concat('search-lang=', @id), concat('search=', $request/m:search)), (), $root/m:response/@lang)"/>
                                            <xsl:value-of select="text()"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                            
                        </xsl:when>
                    </xsl:choose>
                    
                </div>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="tei:note">
        <xsl:variable name="end-note" select="."/>
        <xsl:variable name="item" select="$end-note/ancestor::m:item[1]"/>
        <xsl:variable name="end-note-pre-processed" select="key('end-notes-pre-processed', $end-note/@xml:id)[@source-key = $item/m:header/m:bibl/m:toh/@key[1]][1]" as="element(m:end-note)?"/>
        <sup>
            <xsl:value-of select="$end-note-pre-processed/@index"/>
        </sup>
    </xsl:template>
    
    <xsl:template match="tei:title[parent::m:match]">
        <div>
            <xsl:attribute name="class" select="concat('h4 ', common:lang-class(@xml:lang))"/>
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <div class="h4">
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:bibl[@key]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tei:gloss">
        
        <xsl:variable name="gloss" select="."/>
        
        <div class="search-match-gloss">
            
            <h4 class="h4">
                <xsl:apply-templates select="$gloss/tei:term[not(@type eq 'translationAlternative')][not(@xml:lang) or @xml:lang eq 'en'][1]"/>
            </h4>
            
            <xsl:variable name="term-langs" select="('Bo-Ltn','bo','Sa-Ltn', 'zh')" as="xs:string*"/>
            <xsl:if test="$gloss/tei:term[not(@type eq 'translationAlternative')][@xml:lang = $term-langs][normalize-space(data())]">
                <div>
                    <ul class="list-inline inline-dots">
                        <xsl:for-each select="$term-langs">
                            
                            <xsl:variable name="term-lang" select="."/>
                            <xsl:variable name="term-lang-terms" select="$gloss/tei:term[not(@type eq 'translationAlternative')][@xml:lang eq $term-lang][normalize-space(data())]"/>
                            
                            <xsl:for-each select="$term-lang-terms">
                                <li>
                                    <xsl:attribute name="class" select="string-join((common:lang-class($term-lang), if(@type = ('reconstruction', 'semanticReconstruction','transliterationReconstruction')) then 'reconstructed' else ()), ' ')"/>
                                    <xsl:apply-templates select="node()"/>
                                </li>
                            </xsl:for-each>
                            
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>
            
            <xsl:for-each select="$gloss/tei:note[@type eq 'definition']/tei:p[descendant::text()[normalize-space()]]">
                <p>
                    <xsl:apply-templates select="node()"/>
                </p>
            </xsl:for-each>
            
        </div>
        
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <span class="date">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:l">
        <xsl:apply-templates select="node()"/>
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="@cRef">
                <span class="ref">[<xsl:apply-templates select="@cRef"/>]</span>
            </xsl:when>
            <xsl:when test="following-sibling::*">
                <xsl:apply-templates select="node()"/>
                <br/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:ptr">
        <!-- Needs implementing in search -->
        <span class="ptr">[link]</span>
    </xsl:template>
    
    <xsl:template match="tei:biblScope | tei:author | tei:editor">
        
        <xsl:choose>
            <xsl:when test="local-name(.) eq 'author' and not(@role)">
                <xsl:value-of select="'By '"/>
            </xsl:when>
            <xsl:when test="local-name(.) eq 'author'">
                <xsl:value-of select="'Tibetan translation: '"/>
            </xsl:when>
            <xsl:when test="local-name(.) eq 'editor'">
                <xsl:value-of select="'Revision: '"/>
            </xsl:when>
        </xsl:choose>
        
        <xsl:variable name="lang-class" select="common:lang-class(@xml:lang)"/>
        
        <xsl:choose>
            <xsl:when test="$lang-class gt ''">
                <span class="{ $lang-class }">
                    <xsl:apply-templates select="node()"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:if test="following-sibling::*[self::tei:biblScope | self::tei:author | self::tei:editor]">
            <br/>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="m:full[parent::m:toh]">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
    <xsl:template match="m:entity">
        
        <h4 class="text-muted italic sml-margin bottom">
            <xsl:value-of select="'Definition from the 84000 Glossary of Terms:'"/>
        </h4>
        
        <xsl:for-each select="m:content[@type eq 'glossary-definition'][node()]">
            <p>
                <xsl:apply-templates select="node()"/>
            </p>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="tei:emph">
        <em>
            <xsl:attribute name="class">
                <xsl:variable name="classes" as="xs:string*">
                    <xsl:if test="@rend eq 'bold'">
                        <xsl:value-of select="'text-bold'"/>
                    </xsl:if>
                    <xsl:value-of select="common:lang-class(@xml:lang)"/>
                </xsl:variable>
                <xsl:value-of select="string-join($classes, ' ')"/>
            </xsl:attribute>
            
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
</xsl:stylesheet>