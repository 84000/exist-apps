<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/text-overlay.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="glossary" select="/m:response/m:glossary"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="tab-label" select="m:tabs/m:tab[@id eq $request/@tab]/m:label"/>
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical full-width">
                        <span class="logo">
                            <img alt="84000 logo">
                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                            </img>
                        </span>
                        <span>
                            <h1 class="title">
                                <xsl:value-of select="concat('84000 Community / ', $tab-label)"/>
                            </h1>
                        </span>
                        <span>
                            <a href="#navigation-sidebar" class="center-vertical align-right show-sidebar">
                                <span class="btn-round-text">
                                    <xsl:value-of select="'Navigation'"/>
                                </span>
                                <span>
                                    <span class="btn-round sml">
                                        <i class="fa fa-bars"/>
                                    </span>
                                </span>
                            </a>
                        </span>
                    </div>
                </div>
            </div>
            
            <!-- Content -->
            <div class="content-band">
                <div class="container">
                    <div class="tab-content">
                        
                        <xsl:copy-of select="xhtml:article/*"/>
                        
                    </div>
                </div>
            </div>
            
            <!-- Sidebar -->
            <div id="navigation-sidebar" class="fixed-sidebar collapse width hidden-print">
                <div class="fix-width">
                    <div class="sidebar-content">
                        
                        <h4 class="uppercase">
                            <xsl:value-of select="'84000 Community'"/>
                        </h4>
                        
                        <table class="table table-hover no-border">
                            <tbody>
                                <xsl:for-each select="m:tabs/m:tab">
                                    <tr>
                                        <xsl:if test="$request/@tab eq @id">
                                            <xsl:attribute name="class" select="'active'"/>
                                        </xsl:if>
                                        <td>
                                            <a>
                                                <xsl:choose>
                                                    <xsl:when test="@url">
                                                        <xsl:attribute name="href" select="@url"/>
                                                        <xsl:attribute name="target" select="'_blank'"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="href" select="concat('?tab=', @id)"/>
                                                        <xsl:attribute name="data-loading" select="'Loading ' || m:label || '...'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:value-of select="m:label"/>
                                            </a>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td>
                                        <a target="reading-room">
                                            <xsl:attribute name="href" select="$reading-room-path"/>
                                            <xsl:value-of select="'Go to the 84000 Reading Room'"/>
                                        </a>
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                        
                    </div>
                </div>
                
                <div class="fixed-btn-container close-btn-container right">
                    <button type="button" class="btn-round close close-collapse" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat($tab-label, ' | 84000 Community')"/>
            <xsl:with-param name="page-description" select="'Tools for the 84000 translator community'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossary">
        
        <div id="cumulative-glossary">
            
            <div class="center-vertical full-width">
                <div>
                    <ul class="nav nav-pills">
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'term'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="type" select="'term'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading terms...'"/>
                                <xsl:value-of select="'Terms'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'person'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="type" select="'person'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading people...'"/>
                                <xsl:value-of select="'People'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'place'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="type" select="'place'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading places...'"/>
                                <xsl:value-of select="'Places'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'text'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="type" select="'text'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading texts...'"/>
                                <xsl:value-of select="'Texts'"/>
                            </a>
                        </li>
                    </ul>
                </div>
                <div>
                    <ul class="nav nav-pills">
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'en'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="lang" select="'en'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading translation...'"/>
                                <xsl:value-of select="'Translation'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'sa-ltn'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="lang" select="'Sa-Ltn'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading Sanskrit...'"/>
                                <xsl:value-of select="'Sanskrit'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'bo-ltn'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="link-to-self">
                                        <xsl:with-param name="lang" select="'Bo-Ltn'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="data-loading" select="'Loading Wylie...'"/>
                                <xsl:value-of select="'Wylie'"/>
                            </a>
                        </li>
                    </ul>
                </div>
                <div>
                    <form method="post" role="search" class="form-inline">
                        <xsl:attribute name="action" select="'/index.html'"/>
                        <xsl:attribute name="data-loading" select="'Searching...'"/>
                        <input type="hidden" name="tab" value="glossary"/>
                        <input type="hidden" name="type" value="search"/>
                        <input type="hidden" name="lang" value=""/>
                        <div id="search-controls" class="input-group">
                            <input type="text" name="search" class="form-control" placeholder="Search all types and languages...">
                                <xsl:if test="$request/@type eq 'search'">
                                    <xsl:attribute name="value" select="$request/m:search"/>
                                </xsl:if>
                            </input>
                            <span class="input-group-btn">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-search"/>
                                </button>
                            </span>
                        </div>
                    </form>
                </div>
                <xsl:if test="m:tabs/m:tab[@id eq 'glossary']/m:setting[@id eq 'glossary-download-spreadsheet']">
                    <div>
                        <div class="pull-right">
                            <a class="download-link center-vertical">
                                <xsl:attribute name="href" select="concat('/84000-data/translator-tools/data/', m:tabs/m:tab[@id eq 'glossary']/m:setting[@id eq 'glossary-download-spreadsheet']/@value)"/>
                                <span>
                                    <span class="btn-round sml">
                                        <i class="fa fa-cloud-download"/>
                                    </span>
                                </span>
                                <span class="btn-round-text">
                                    <xsl:value-of select="'Full Glossary (.xslx)'"/>
                                </span>
                            </a>
                        </div>
                    </div>
                </xsl:if>
            </div>
            
            <ul class="nav nav-tabs sml-tabs top-margin" role="tablist">
                <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
                <xsl:for-each select="1 to string-length($alphabet)">
                    <xsl:variable name="letter" select="substring($alphabet, ., 1)"/>
                    <li role="presentation">
                        <xsl:if test="$letter eq upper-case($request/m:search)">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:call-template name="link-to-self">
                                    <xsl:with-param name="search" select="$letter"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:attribute name="data-loading" select="'Loading ' || $letter || '...'"/>
                            <xsl:value-of select="$letter"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
            
            <div class="div-list no-border-top">
                <xsl:choose>
                    <xsl:when test="m:glossary/m:term">
                        
                        <div class="heading">
                            <div class="row">
                                <div class="col-sm-6">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:call-template name="link-to-self">
                                                <xsl:with-param name="glossary-sort" select="'name'"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:value-of select="'Terms'"/>
                                    </a>
                                    <xsl:value-of select="' / '"/>
                                    <xsl:value-of select="format-number(count(m:glossary/m:term),'#,###')"/>
                                </div>
                                <div class="col-sm-6 text-right">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:call-template name="link-to-self">
                                                <xsl:with-param name="glossary-sort" select="'matches'"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:value-of select="'Number of similar terms'"/>
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <xsl:for-each select="m:glossary/m:term">
                            <xsl:sort select="if($request/@glossary-sort eq 'matches') then @count-items ! xs:integer(.) else 0" order="descending"/>
                            <xsl:sort select="m:normalized-term ! lower-case(.)"/>
                            <div class="item">
                                
                                <div class="row">
                                    <div class="col-sm-6 name">
                                        <xsl:value-of select="normalize-space(m:main-term/text())"/>
                                    </div>
                                    <div class="col-sm-6 text-right">
                                        <a target="_self">
                                            <xsl:attribute name="href" select="concat('glossary-items.html?term=', fn:encode-for-uri(m:main-term/text()), '&amp;lang=', m:main-term/@xml:lang, '#glossary-items')"/>
                                            <xsl:attribute name="data-ajax-target" select="concat('#occurrences-', position(), ' .ajax-target')"/>
                                            <span class="badge badge-notification">
                                                <xsl:value-of select="@count-items"/>
                                            </span>
                                            <span class="badge-text">
                                                <xsl:value-of select="' similar'"/>
                                            </span>
                                        </a>
                                    </div>
                                </div>
                                
                                <div class="collapse sml-margin top">
                                    <xsl:attribute name="id" select="concat('occurrences-', position())"/>
                                    <!-- Ajax data here -->
                                    <div class="ajax-target"/>
                                </div>
                                
                            </div>                                    
                        </xsl:for-each>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="item text-muted italic">
                            <xsl:value-of select="'No search results'"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            
        </div>
    
    </xsl:template>
    
    <xsl:template name="link-to-self">
        
        <xsl:param name="type" select="($glossary/@type[normalize-space()], 'term')[1]"/>
        <xsl:param name="lang" select="($glossary/@lang[normalize-space()], 'en')[1] "/>
        <xsl:param name="glossary-sort" select="($request/@glossary-sort, '')[1]"/>
        <xsl:param name="search" select="($request/m:search, 'A')[1]"/>
        
        <xsl:value-of select="concat('?tab=glossary&amp;type=', $type,'&amp;lang=', $lang,'&amp;search=', $search, '&amp;glossary-sort=', $glossary-sort)"/>
        
    </xsl:template>
    
    <xsl:template name="tm-search">
        
        <div class="alert alert-info small text-center">
            <p>
                <xsl:value-of select="'This page searches translation memories created from published 84000 translations. It will additionally return any results from the 84000 cumulative glossary. Search for a term or phrase by entering Tibetan, Wylie or English into the search fields, or search larger passages of Tibetan in the Select a Passage tab.'"/>
            </p>
        </div>
       
        <div id="search-container">
            
            <div class="tabs-container-center">
                <ul class="nav nav-tabs" role="tablist">
                    
                    <!-- Folio tab -->
                    <li role="presentation">
                        <xsl:if test="$request/@type = ('folio')">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a href="#folio-search" aria-controls="folio-search" role="tab" data-toggle="tab">Select a Passage</a>
                    </li>
                    
                    <!-- Tibetan tab -->
                    <li role="presentation">
                        <xsl:if test="$request/@type = ('bo')">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a href="#tibetan-search" aria-controls="tibetan-search" role="tab" data-toggle="tab">Tibetan</a>
                    </li>
                    
                    <!-- Wylie tab -->
                    <li role="presentation">
                        <xsl:if test="lower-case($request/@type) = ('bo-ltn')">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a href="#wylie-search" aria-controls="wylie-search" role="tab" data-toggle="tab">Wylie</a>
                    </li>
                    
                    <!-- English tab -->
                    <li role="presentation">
                        <xsl:if test="$request/@type = ('en')">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a href="#english-search" aria-controls="english-search" role="tab" data-toggle="tab">English</a>
                    </li>
                    
                </ul>
                
            </div>
            
            <div class="tab-content">
                
                <div role="tabpanel" id="folio-search" class="tab-pane fade">
                    
                    <xsl:if test="$request/@type = ('folio')">
                        <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                    </xsl:if>
                    
                    <div class="row">
                        <div class="col-sm-8 col-sm-offset-2">
                            
                            <div class="bottom-margin">
                                <p class="text-muted small text-center">
                                    <xsl:value-of select="'Use your mouse to select any passage from the text below and search for any relevant translations.'"/>
                                </p>
                            </div>
                            
                            <form action="index.html" method="post" class="form-inline filter-form bottom-margin">
                                
                                <input type="hidden" name="tab" value="tm-search"/>
                                <input type="hidden" name="type" value="folio"/>
                                <input type="hidden" name="lang" value="bo"/>
                                
                                <input type="hidden" name="search" id="search-text-folio" data-onload-mark="#folio-text">
                                    <xsl:attribute name="value">
                                        <xsl:apply-templates select="/m:response/m:request[@type eq 'folio']/m:search"/>
                                    </xsl:attribute>
                                </input>
                                
                                <div class="form-group">
                                    <label for="volume">
                                        <xsl:value-of select="'Volume:'"/>
                                    </label>
                                    <select name="volume" class="form-control" id="volume">
                                        <xsl:for-each select="/m:response/m:volumes/m:volume">
                                            <xsl:sort select="xs:integer(@number)"/>
                                            <option>
                                                <xsl:attribute name="value" select="@number"/>
                                                <xsl:if test="xs:integer(@number) eq xs:integer(/m:response/m:request/@volume)">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="concat('eKangyur volume ', @number, ' (', @id, ')')"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label for="page">
                                        <xsl:value-of select="' Folio:'"/>
                                    </label>
                                    <select name="page" class="form-control" id="page">
                                        <xsl:variable name="requested-page" select="/m:response/m:request/@page" as="xs:integer"/>
                                        <xsl:for-each select="/m:response/m:volumes/m:volume[xs:integer(@number) eq xs:integer(/m:response/m:request/@volume)]/m:page">
                                            <option>
                                                <xsl:attribute name="value" select="@index"/>
                                                <xsl:if test="xs:integer(@index) eq $requested-page">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="@folio"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <button class="btn btn-primary" type="submit">
                                        <xsl:value-of select="'Search for selection'"/>
                                    </button>
                                </div>
                                
                            </form>
                            
                        </div>
                    </div>
                    
                    <div class="source text-overlay text-left">
                        <div class="text divided text-bo">
                            <xsl:call-template name="text-marked">
                                <xsl:with-param name="data" select="/m:response/m:page/m:language[@xml:lang eq 'bo']"/>
                            </xsl:call-template>
                        </div>
                        <div id="folio-text" class="text plain text-bo" data-mouseup-set-input="#search-text-folio">
                            <xsl:call-template name="text-plain">
                                <xsl:with-param name="data" select="/m:response/m:page/m:language[@xml:lang eq 'bo']//tei:p"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    
                    <xsl:call-template name="tm-search-results">
                        <xsl:with-param name="results" select="if($request/@type eq 'folio') then /m:response/m:tm-search/m:results else ()"/>
                    </xsl:call-template>
                    
                </div>
                
                <div role="tabpanel" id="tibetan-search" class="tab-pane fade">
                    
                    <xsl:if test="$request/@type eq 'bo'">
                        <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                    </xsl:if>
                    
                    <xsl:call-template name="tm-search-form">
                        <xsl:with-param name="type" select="'bo'"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="tm-search-results">
                        <xsl:with-param name="results" select="if($request/@type eq 'bo') then /m:response/m:tm-search/m:results else ()"/>
                    </xsl:call-template>
                    
                </div>
                
                <div role="tabpanel" id="wylie-search" class="tab-pane fade">
                    
                    <xsl:if test="lower-case($request/@type) eq 'bo-ltn'">
                        <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                    </xsl:if>
                    
                    <xsl:call-template name="tm-search-form">
                        <xsl:with-param name="type" select="'Bo-Ltn'"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="tm-search-results">
                        <xsl:with-param name="results" select="if(lower-case($request/@type) eq 'bo-ltn') then /m:response/m:tm-search/m:results else ()"/>
                    </xsl:call-template>
                    
                </div>
                
                <div role="tabpanel" id="english-search" class="tab-pane fade">
                    
                    <xsl:if test="$request/@type eq 'en'">
                        <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                    </xsl:if>
                    
                    <xsl:call-template name="tm-search-form">
                        <xsl:with-param name="type" select="'en'"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="tm-search-results">
                        <xsl:with-param name="results" select="if($request/@type eq 'en') then /m:response/m:tm-search/m:results else ()"/>
                    </xsl:call-template>
                    
                </div>
                
            </div>
            
        </div>
    </xsl:template>
    
    <xsl:template name="tm-search-form">
        
        <xsl:param name="type" as="xs:string"/>
        
        <xsl:variable name="lang" as="xs:string">
            <xsl:choose>
                <xsl:when test="$type eq 'folio'">
                    <xsl:value-of select="'bo'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <div class="row">
            <div class="col-sm-8 col-sm-offset-2">
                <form action="index.html" method="post" accept-charset="UTF-8" class="form-horizontal">
                    <input type="hidden" name="tab" value="tm-search"/>
                    <input type="hidden" name="type">
                        <xsl:attribute name="value" select="$type"/>
                    </input>
                    <input type="hidden" name="lang">
                        <xsl:attribute name="value" select="$lang"/>
                    </input>
                    <input type="hidden" name="volume">
                        <xsl:attribute name="value" select="$request/@volume"/>
                    </input>
                    <input type="hidden" name="page">
                        <xsl:attribute name="value" select="$request/@page ! xs:integer(.)"/>
                    </input>
                    <div class="input-group">
                        <input type="text" name="search">
                            <xsl:attribute name="id" select="concat('tm-search-', $type)"/>
                            <xsl:choose>
                                <xsl:when test="$lang eq 'bo'">
                                    <xsl:attribute name="class" select="'form-control text-bo'"/>
                                </xsl:when>
                                <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                                    <xsl:attribute name="class" select="'form-control text-wy'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="class" select="'form-control'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="value">
                                <xsl:apply-templates select="$request[@type eq $type]/m:search"/>
                            </xsl:attribute>
                        </input>
                        <div class="input-group-btn">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-search"/>
                                
                                <xsl:choose>
                                    <xsl:when test="$lang eq 'bo'">
                                        <xsl:value-of select="' Search Tibetan'"/>
                                    </xsl:when>
                                    <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                                        <xsl:value-of select="' Search Wylie'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="' Search English'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="tm-search-results">
        
        <xsl:param name="results" as="element(m:results)?"/>
        
        <xsl:choose>
            <xsl:when test="$results[m:item]">
                
                <hr/>
                
                <!-- Results list -->
                <div class="search-results">
                    
                    <xsl:for-each select="$results/m:item">
                        <div class="search-result row">
                            <div class="col-sm-6">
                                <div class="row">
                                    <div class="col-sm-1 small text-muted sml-margin top">
                                        <xsl:value-of select="concat(position() + $results/@first-record - 1, '.')"/>
                                    </div>
                                    <div class="col-sm-11">
                                        <xsl:if test="string(m:match/m:tibetan)">
                                            <p class="text-bo">
                                                <xsl:apply-templates select="m:match/m:tibetan"/>
                                            </p>
                                        </xsl:if>
                                        <xsl:if test="string(m:match/m:translation)">
                                            <p class="translation">
                                                <xsl:apply-templates select="m:match/m:translation"/>
                                            </p>
                                        </xsl:if>
                                        <xsl:if test="string(m:match/m:sanskrit)">
                                            <p class="text-sa">
                                                <xsl:apply-templates select="m:match/m:sanskrit"/>
                                            </p>
                                        </xsl:if>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <div class="col-sm-6">
                                    
                                    <div>
                                        <!-- 
                                            Link to text
                                            - allow for surfeit glossary entries that shouldn't be linked -->
                                        <xsl:choose>
                                            <xsl:when test="m:match/@location gt ''">
                                                <a target="reading-room">
                                                    <xsl:choose>
                                                        <xsl:when test="m:match/@type eq 'glossary-term'">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, m:match/@location)"/>
                                                        </xsl:when>
                                                        <xsl:when test="m:match/@type eq 'tm-unit'">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, m:match/@location)"/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                    <xsl:apply-templates select="m:tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="m:tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                    
                                    <div class="translators text-muted small">
                                        <xsl:value-of select="'Translated by '"/>
                                        <xsl:variable name="author-ids" select="m:tei/m:publication/m:contributors/m:author[@role eq 'translatorEng']/@ref ! replace(., '^(eft:|contributors\.xml#)', '', 'i')"/>
                                        <xsl:value-of select="string-join(/m:response/m:contributor-persons/m:person[@xml:id = $author-ids]/m:label, ' · ')"/>
                                    </div>
                                    
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
                
                <hr class="sml-margin"/>
                
                <!-- Pagination -->
                <!-- To do: change this to a re-post of the form maybe? -->
                <xsl:variable name="base-url" select="concat('index.html?tab=tm-search&amp;type=', $request/@type, '&amp;search=', $request/m:search/text()/normalize-space(), '&amp;lang=', $request/@lang, '&amp;volume=', $request/@volume, '&amp;page=', $request/@page)"/>
                <xsl:sequence select="common:pagination($results/@first-record, $results/@max-records, $results/@count-records, $base-url)"/>
                
            </xsl:when>
            <xsl:otherwise>
                <hr/>
                <p class="text-muted italic text-center">
                    <xsl:value-of select="'~ No search results ~'"/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    <xsl:template name="translations">
        <div class="alert alert-info small text-center">
            <p>
                <xsl:value-of select="'This page lists all current translations and some meta data. The editor mode links open the translations with all sections expanded, this is convenient for searching, and an embedded annotation tool. For more information about using this tool please contact us.'"/>
            </p>
        </div>
        <table class="table table-responsive">
            <thead>
                <tr>
                    <th>
                        <xsl:value-of select="'Toh.'"/>
                    </th>
                    <th colspan="2">
                        <xsl:value-of select="'Title'"/>
                    </th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="m:texts/m:text">
                    <xsl:sort select="number(m:toh/@number)"/>
                    <xsl:sort select="m:toh/m:base"/>
                    <xsl:variable name="row-id" select="concat('text-', position())"/>
                    <tr>
                        <xsl:attribute name="id" select="m:toh/@key"/>
                        <td>
                            <xsl:value-of select="m:toh/m:base"/>
                        </td>
                        <td>
                            <div class="break">
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html')"/>
                                    <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                    <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                </a>
                                <xsl:value-of select="' / '"/>
                                <a class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html?view-mode=editor')"/>
                                    <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                    <xsl:value-of select="'editor mode'"/>
                                </a>
                                <xsl:value-of select="' / '"/>
                                <a class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html?view-mode=annotation')"/>
                                    <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                    <xsl:value-of select="'annotation mode'"/>
                                </a>
                            </div>
                        </td>
                        <td>
                            <a class="collapsed pull-right" role="button" data-toggle="collapse" aria-expanded="false">
                                <xsl:attribute name="href" select="concat('#', $row-id, '-sub')"/>
                                <xsl:attribute name="aria-controls" select="concat($row-id, '-sub')"/>
                                <i class="fa fa-plus collapsed-show"/>
                                <i class="fa fa-minus collapsed-hide"/>
                            </a>
                        </td>
                    </tr>
                    <tr class="sub collapse">
                        <xsl:attribute name="id" select="concat($row-id, '-sub')"/>
                        <td/>
                        <td colspan="2">
                            <div class="vertical-align">
                                <span class="text-bo">
                                    <xsl:value-of select="m:titles/m:title[@xml:lang eq 'bo']"/>
                                </span>
                                <span>
                                    <xsl:value-of select="' · '"/>
                                </span>
                                <span class="text-sa">
                                    <xsl:value-of select="m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                                </span>
                            </div>
                            <ul class="list-unstyled small sml-margin top text-muted">
                                <li>
                                    <xsl:value-of select="tei:bibl/tei:biblScope"/>
                                </li>
                                <li>
                                    <xsl:value-of select="'Translator(s): '"/>
                                    <xsl:value-of select="string-join(m:publication/m:contributors/m:author[@role eq 'translatorEng'], ' · ')"/>
                                </li>
                                <xsl:if test="m:publication/m:contributors/m:editor[@role eq 'reviser']">
                                    <li>
                                        <xsl:value-of select="'Editor(s): '"/>
                                        <xsl:value-of select="string-join(m:publication/m:contributors/m:editor[@role eq 'reviser'], ' · ')"/>
                                    </li>
                                </xsl:if>
                                <xsl:if test="m:publication/m:contributors/m:consultant[@role eq 'advisor']">
                                    <li>
                                        <xsl:value-of select="'Advisor(s): '"/>
                                        <xsl:value-of select="string-join(m:publication/m:contributors/m:consultant[@role eq 'advisor'], ' · ')"/>
                                    </li>
                                </xsl:if>
                                <li>
                                    <xsl:value-of select="concat('Published ', format-date(m:publication/m:publication-date, '[FNn,*-3], [D1o] [MNn,*-3] [Y]'))"/>
                                </li>
                            </ul>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template name="page-options">
        <xsl:param name="page-number"/>
        <xsl:param name="page-count"/>
        <xsl:if test="$page-number le $page-count">
            <option>
                <xsl:attribute name="value" select="$page-number"/>
                <xsl:if test="$page-number eq $request/@page ! xs:integer(.)">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="concat('Page ', $page-number)"/>
            </option>
            <xsl:call-template name="page-options">
                <xsl:with-param name="page-number" select="xs:integer($page-number) + 1"/>
                <xsl:with-param name="page-count" select="$page-count"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>