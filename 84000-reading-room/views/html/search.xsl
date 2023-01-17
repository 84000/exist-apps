<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="base-url" select="common:internal-link('/search.html',(concat('search-type=', $request/@search-type), concat('search-lang=', $request/@search-lang), concat('search=', $request/m:search)), (), /m:response/@lang)"/>
    <xsl:variable name="specified-text" select="/m:response/m:tei-search/m:request/m:tei"/>
    
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
                    
                    <div class="section-title row">
                        <div class="col-sm-offset-2 col-sm-8">
                            <h1 class="title main-title">
                                <xsl:value-of select="'Search Our Translations'"/>
                            </h1>
                        </div>
                    </div>
                    
                    <!-- Search type tabs -->
                    <xsl:if test="$environment/m:enable[@type eq 'tm-search']">
                        <div class="tabs-container-center">
                            <ul class="nav nav-tabs" role="tablist">
                                
                                <!-- TEI search tab -->
                                <li role="presentation">
                                    <xsl:if test="not(m:request/@search-type eq 'tm')">
                                        <xsl:attribute name="class" select="'active'"/>
                                    </xsl:if>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/search.html', (concat('search=', $request/m:search)), '', $root/m:response/@lang)"/>
                                        <xsl:attribute name="title" select="'Search the 84000 published translations'"/>
                                        <xsl:attribute name="data-loading" select="'Searching...'"/>
                                        <xsl:value-of select="'The Publications'"/>
                                    </a>
                                </li>
                                
                                <!-- TM search tab -->
                                <li role="presentation" class="icon">
                                    <xsl:if test="m:request/@search-type eq 'tm'">
                                        <xsl:attribute name="class" select="'active'"/>
                                    </xsl:if>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/search.html', ('search-type=tm', concat('search=', $request/m:search), 'search-glossary=1'), '', $root/m:response/@lang)"/>
                                        <xsl:attribute name="title" select="'Search the 84000 Translation Memory'"/>
                                        <xsl:attribute name="data-loading" select="'Searching...'"/>
                                        <xsl:value-of select="'Translation Memory'"/>
                                    </a>
                                </li>
                                
                            </ul>
                        </div>
                    </xsl:if>
                    
                    <xsl:choose>
                        
                        <!-- TM search -->
                        <xsl:when test="m:request/@search-type eq 'tm' and $environment/m:enable[@type eq 'tm-search']">
                            
                            <p class="text-center text-muted small">
                                <xsl:value-of select="'Search our Translation Memory files to find translations aligned with the Tibetan source.'"/>
                                <br/>
                                <xsl:value-of select="'Use quotation marks e.g. &#34;realm of phenomena&#34; to search for complete phrases rather than individual words.'"/>
                            </p>
                            
                            <div id="search-container">
                                
                                <!-- TM search form -->
                                <xsl:call-template name="tm-search-form"/>
                                
                                <!-- TM search results -->
                                <xsl:apply-templates select="m:tm-search"/>
                                
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
                                <xsl:apply-templates select="m:tei-search"/>
                                
                            </div>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </div>
            </main>
            
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
                <form action="/search.html" method="get" role="search" class="form-horizontal">
                    
                    <input type="hidden" name="lang" value="{ $request/@lang }"/>
                    <input type="hidden" name="search-type" value="tei"/>
                    
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
                            <xsl:value-of select="concat('in ', $specified-text/m:titles/m:title[@xml:lang eq 'en'][1] , ' / ', $specified-text/m:bibl/m:toh/m:full[1])"/>
                            <span class="pull-right">
                                <a class="inline-block alert-link">
                                    <xsl:attribute name="href" select="$base-url"/>
                                    <xsl:value-of select="'remove filter'"/>
                                </a>
                            </span>
                        </div>
                    </xsl:if>
                    
                </form>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="tm-search-form">

        <div class="row">
            <div class="col-sm-8 col-sm-offset-2">
                <form action="/search.html" method="get" role="search" accept-charset="UTF-8" class="form-horizontal">
                    
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
                        
                        <input type="text" name="search" class="form-control" value="{ $request/m:search }"/>
                        
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
    
    <xsl:template match="m:tei-search">
        
        <div class="row">
            <div class="col-sm-8 col-sm-offset-2">
                
                <!-- Results list -->
                <xsl:choose>
                    <xsl:when test="m:results[m:item]">
                        
                        <xsl:variable name="first-record" select="m:results/@first-record"/>
                        
                        <div class="search-results">
                            <xsl:for-each select="m:results/m:item">
                                
                                <xsl:sort select="@score ! xs:double(.)" order="descending"/>
                                
                                <xsl:variable name="tei" select="m:tei"/>
                                <xsl:variable name="matches" select="m:match"/>
                                <xsl:variable name="count-matches" select="@count-records" as="xs:integer"/>
                                <xsl:variable name="record-number" select="$first-record + (position() - 1)"/>
                                
                                <div class="search-result">
                                    
                                    <!-- Title -->
                                    <div class="row">
                                        
                                        <div class="col-sm-12 col-md-10">
                                            
                                            <h3 class="result-title">
                                                <a>
                                                    <xsl:attribute name="target" select="concat($tei/@resource-id, '.html')"/>
                                                    <!-- If the match is in the main title then use the match, otherwise output the title -->
                                                    <xsl:variable name="title-match" select="$matches[@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en'][1]"/>
                                                    <xsl:choose>
                                                        
                                                        <xsl:when test="$title-match">
                                                            <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $title-match/@link), (), '', /m:response/@lang)"/>
                                                            <xsl:apply-templates select="$title-match"/>
                                                        </xsl:when>
                                                        
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $tei/@link), (), '', /m:response/@lang)"/>
                                                            <xsl:choose>
                                                                <xsl:when test="$tei/m:titles/m:title[@xml:lang eq 'en']/text()">
                                                                    <xsl:value-of select="$tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="$tei/m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </a>
                                            </h3>
                                            
                                        </div>
                                        
                                        <div class="col-sm-12 col-md-2 text-right-md">
                                            
                                            <xsl:choose>
                                                <xsl:when test="$tei[@type = 'section']">
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="'Section'"/>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="common:translation-status($tei/@translation-status-group)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                    </div>
                                    
                                    <!-- Location / breadcrumbs -->
                                    <xsl:for-each select="$tei[@type eq 'translation']/m:bibl">
                                        <xsl:variable name="toh-key" select="m:toh/@key"/>
                                        <nav role="navigation" aria-label="Breadcrumbs" class="small text-muted">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                
                                                <xsl:sequence select="common:breadcrumb-items(m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                                
                                                <xsl:if test="m:toh/m:full">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="target" select="concat($tei/@resource-id, '.html')"/>
                                                            <!-- If the match is a Toh number then output the match -->
                                                            <xsl:variable name="key-match" select="$matches[@key eq $toh-key and @node-name eq 'bibl'][1]"/>
                                                            <xsl:choose>
                                                                <xsl:when test="$key-match">
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $key-match/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:apply-templates select="$key-match"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $tei/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:apply-templates select="m:toh/m:full"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                            </ul>
                                        </nav>
                                    </xsl:for-each>
                                    
                                    <xsl:for-each select="$tei[@type eq 'knowledgebase']/m:page">
                                        <p class="small">
                                            <span class="text-muted">
                                                <xsl:value-of select="'in '"/>
                                            </span>
                                            <xsl:value-of select="'The 84000 Knowledge Base'"/>
                                        </p>
                                    </xsl:for-each>
                                    
                                    <!-- Warnings -->
                                    <xsl:variable name="tantric-restriction" select="$tei[@type eq 'translation']/m:publication/m:tantric-restriction"/>
                                    <xsl:if test="$tantric-restriction/tei:p">
                                        <div class="row">
                                            <div class="col-sm-12">
                                                
                                                <a data-toggle="modal" class="warning">
                                                    <xsl:attribute name="href" select="concat('#tantra-warning-', $tei/@resource-id)"/>
                                                    <xsl:attribute name="data-target" select="concat('#tantra-warning-', $tei/@resource-id)"/>
                                                    <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                    <xsl:value-of select="' Tantra Text Warning'"/>
                                                </a>
                                                
                                                <div class="modal fade warning" tabindex="-1" role="dialog">
                                                    <xsl:attribute name="id" select="concat('tantra-warning-', $tei/@resource-id)"/>
                                                    <xsl:attribute name="aria-labelledby" select="concat('tantra-warning-label-', $tei/@resource-id)"/>
                                                    <div class="modal-dialog" role="document">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                    <span aria-hidden="true">
                                                                        <i class="fa fa-times"/>
                                                                    </span>
                                                                </button>
                                                                <h4 class="modal-title">
                                                                    <xsl:attribute name="id" select="concat('tantra-warning-label-', $tei/@resource-id)"/>
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
                                    
                                    <!-- Matches -->
                                    <section class="result-matches">
                                        
                                        <xsl:variable name="section-id" select="concat('result-matches-', position())"/>
                                        <xsl:attribute name="id" select="$section-id"/>
                                        
                                        <xsl:if test="not($specified-text) and count($matches[not(@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en')]) gt 0">
                                            
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
                                                    <xsl:value-of select="$count-matches"/> 
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
                                        <xsl:for-each select="$matches[not(@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en')]">
                                            <xsl:sort select="@score" data-type="number" order="descending"/>
                                            <xsl:choose>
                                                <xsl:when test="@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en'">
                                                    <!-- Don't bother if it's the title, we already show this -->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="."/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                        
                                        <!-- Link to view remainder -->
                                        <xsl:if test="$count-matches gt count($matches)">
                                            <div class="row">
                                                
                                                <div class="col-sm-12">
                                                    
                                                    <xsl:if test="not($specified-text)">
                                                        
                                                        <p>
                                                            <xsl:value-of select="concat('These are the first ', count($matches), ' matches. ')"/>
                                                            <a target="_self">
                                                                <xsl:attribute name="href" select="common:internal-link('/search.html',(concat('search-type=', $request/@search-type), concat('search-lang=', $request/@search-lang), concat('search=', $request/m:search), concat('specified-text=', $tei/@resource-id)), (), /m:response/@lang)"/>
                                                                <xsl:value-of select="concat('View all ', $count-matches)"/>
                                                            </a>
                                                        </p>
                                                        
                                                    </xsl:if>
                                                    
                                                </div>
                                            </div>
                                            
                                        </xsl:if>
                                        
                                    </section>
                                    
                                </div>
                                
                            </xsl:for-each>
                        </div>
                        
                        <!-- Pagination -->
                        <xsl:sequence select="common:pagination($request/@first-record, $request/@max-records, m:results/@count-records, $base-url)"/>
                        
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
    
    <xsl:template match="m:tm-search">
        
        <!-- Results list -->
        <xsl:choose>
            <xsl:when test="m:results[m:item]">
                
                <hr/>
                
                <div class="search-results">
                    <xsl:for-each select="m:results/m:item">
                        
                        <xsl:sort select="@score ! xs:double(.)" order="descending"/>
                        
                        <div class="search-result">
                            <div class="row">
                                
                                <div class="col-sm-6">
                                    <div class="row">
                                        <div class="col-sm-1 sml-margin top">
                                            
                                            <span class="text-muted">
                                                <xsl:value-of select="concat(($request/@first-record ! xs:integer(.) - 1) + position(), '.')"/>
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
                                
                                <div class="col-sm-6">
                                    
                                    <div>
                                        
                                        <!-- 
                                        Link to text
                                        - allow for surfeit glossary entries that shouldn't be linked -->
                                        
                                        <xsl:choose>
                                            <xsl:when test="m:match/@location gt ''">
                                                <a>
                                                    
                                                    <xsl:choose>
                                                        <xsl:when test="m:match/@type eq 'glossary-term'">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, m:match/@location)"/>
                                                        </xsl:when>
                                                        <xsl:when test="m:match/@type eq 'tm-unit'">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, m:match/@location)"/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                    
                                                    <xsl:attribute name="target" select="concat(m:tei/@resource-id, '.html')"/>
                                                    
                                                    <xsl:apply-templates select="m:tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                                    
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                
                                                <xsl:apply-templates select="m:tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                                
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        <xsl:value-of select="' '"/>
                                        
                                        <xsl:choose>
                                            <xsl:when test="m:match/@type eq 'glossary-term'">
                                                <span class="label label-default">
                                                    <xsl:value-of select="'Glossary'"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:when test="m:match/@type eq 'tm-unit'">
                                                <span class="label label-default">
                                                    <xsl:value-of select="'TM'"/>
                                                </span>
                                            </xsl:when>
                                        </xsl:choose>
                                        
                                    </div>
                                    
                                    <xsl:if test="m:tei/m:publication/m:contributors/m:author[@role eq 'translatorEng'][text()]">
                                        <div class="translators text-muted small">
                                            
                                            <xsl:value-of select="'Translated by: '"/>
                                            
                                            <ul class="list-inline inline-dots">
                                                <xsl:for-each select="m:tei/m:publication/m:contributors/m:author[@role eq 'translatorEng'][text()]">
                                                    <li>
                                                        <xsl:value-of select="."/>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                            
                                        </div>
                                    </xsl:if>
                                    
                                    <xsl:for-each select="m:tei/m:bibl">
                                        <div class="ancestors text-muted small">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                <xsl:for-each select="m:parent | m:parent//m:parent">
                                                    <xsl:sort select="@nesting" order="descending"/>
                                                    <li>
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang='en']"/>
                                                    </li>
                                                </xsl:for-each>
                                                <xsl:if test="m:toh/m:full">
                                                    <li>
                                                        <xsl:value-of select="m:toh/m:full"/>
                                                    </li>
                                                    
                                                </xsl:if>
                                            </ul>
                                            
                                        </div>
                                    </xsl:for-each>
                                    
                                </div>
                                
                            </div>
                            
                        </div>
                    
                    </xsl:for-each>
                </div>
                
                <!-- Pagination -->
                <xsl:sequence select="common:pagination($request/@first-record, $request/@max-records, m:results/@count-records, $base-url)"/>
                
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
                                            <xsl:attribute name="data-loading" select="'Loading...'"/>
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
    
    <xsl:template match="m:match">
        <xsl:choose>
            
            <xsl:when test="@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en'">
                <!-- A main title replaces the title string -->
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <!-- Everything else is listed as a search-match -->
                <div class="search-match">
                    
                    <!-- Output the match (unless it's only in the note) -->
                    <xsl:if test="descendant::exist:match[not(ancestor::tei:note)][not(ancestor::tei:orig)] or not(descendant::exist:match)">
                        <div>
                            <xsl:attribute name="class" select="concat('search-match-', @node-name)"/>
                            <!-- Reduce this to a snippet -->
                            <xsl:apply-templates select="node()"/>
                        </div>
                    </xsl:if>
                    
                    <!-- Output related notes if they have matches too -->
                    <xsl:for-each select="descendant::tei:note[descendant::exist:match][@place eq 'end'][@xml:id]">
                        <xsl:variable name="end-note" select="."/>
                        <xsl:variable name="cache-note" select="ancestor::m:item[1]/m:pre-processed[@type eq 'end-notes']/m:end-note[@id eq $end-note/@xml:id]"/>
                        <div class="row search-match-note">
                            <div class="col-sm-1">
                                <span>
                                    <xsl:value-of select="concat('n.', $cache-note/@index)"/>
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
                    
                    <xsl:if test="parent::m:item/m:tei[@translation-status-group eq 'published']">
                        <div>
                            <a>
                                <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, @link), (), '', /m:response/@lang)"/>
                                <xsl:attribute name="target" select="concat(parent::m:item/m:tei/@resource-id, '.html')"/>
                                <xsl:value-of select="'read...'"/>
                            </a>
                        </div>
                    </xsl:if>
                    
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:note">
        <xsl:variable name="end-note" select="."/>
        <xsl:variable name="cache-note" select="ancestor::m:item[1]/m:pre-processed[@type eq 'end-notes']/m:end-note[@id eq $end-note/@xml:id]"/>
        <sup>
            <xsl:value-of select="$cache-note/@index"/>
        </sup>
    </xsl:template>
    
    <xsl:template match="tei:title">
        <xsl:choose>
            <xsl:when test="preceding-sibling::*">
                <em>
                    <xsl:apply-templates select="node()"/>
                </em>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:bibl">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tei:gloss">
        
        <xsl:variable name="gloss" select="."/>
        
        <h4 class="term">
            <xsl:apply-templates select="$gloss/tei:term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq 'en'][1]"/>
        </h4>
        
        <xsl:for-each select="('Bo-Ltn','bo','Sa-Ltn')">
            
            <xsl:variable name="term-lang" select="."/>
            <xsl:variable name="term-lang-terms" select="$gloss/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq $term-lang][normalize-space(data())]"/>
            
            <xsl:choose>
                <xsl:when test="$term-lang-terms">
                    <div>
                        <ul class="list-inline inline-dots">
                            <xsl:for-each select="$term-lang-terms">
                                <li>
                                    <xsl:attribute name="class" select="string-join((common:lang-class($term-lang), if(@type = ('reconstruction', 'semanticReconstruction','transliterationReconstruction')) then 'reconstructed' else ()), ' ')"/>
                                    <xsl:apply-templates select="node()"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
        <xsl:for-each select="$gloss/tei:term[@type eq 'definition'][node()]">
            <p>
                <xsl:apply-templates select="node()"/>
            </p>
        </xsl:for-each>
        
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
    
</xsl:stylesheet>