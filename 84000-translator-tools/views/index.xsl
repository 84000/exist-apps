<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-search.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/text-overlay.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="tab-label" select="m:tabs/m:tab[@id eq /m:response/m:request/@tab]/m:label"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <span class="title">
                            <xsl:value-of select="concat('84000 Translator Tools / ', $tab-label)"/>
                        </span>
                        
                        <span>
                            <a href="#navigation-sidebar" class="center-vertical together pull-right show-sidebar">
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
                    
                    <div class="panel-body">
                        
                        <div id="navigation-sidebar" class="fixed-sidebar collapse width hidden-print">
                            
                            <div class="container">
                                <div class="fix-width">
                                    <h4 class="uppercase">
                                        <xsl:value-of select="'84000 Translator Tools'"/>
                                    </h4>
                                    <table class="table table-hover no-border">
                                        <tbody>
                                            <xsl:for-each select="m:tabs/m:tab">
                                                <tr>
                                                    <xsl:if test="/m:response/m:request/@tab eq @id">
                                                        <xsl:attribute name="class" select="'active'"/>
                                                    </xsl:if>
                                                    <td>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat('?tab=', @id)"/>
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
                                <button type="button" class="btn-round close" aria-label="Close">
                                    <span aria-hidden="true">
                                        <i class="fa fa-times"/>
                                    </span>
                                </button>
                            </div>
                            
                        </div>
                        
                        <!-- Content -->
                        <div class="tab-content">
                            
                            <xsl:choose>
                                
                                <!-- Search results -->
                                <xsl:when test="/m:response/m:request/@tab eq 'search'">
                                    
                                    <div class="alert alert-warning small text-center">
                                        <p>
                                            <xsl:value-of select="'Use the form below to search for terms, phrases, titles, and so forth in published and nearly-published 84000 translations. Search results link directly to passages in the Reading Room.'"/>
                                        </p>
                                    </div>
                                    
                                    <xsl:call-template name="search">
                                        <xsl:with-param name="action" select="'index.html?tab=search'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                
                                <!-- Cumulative Glossary -->
                                <xsl:when test="/m:response/m:request/@tab eq 'glossary'">
                                    <xsl:call-template name="glossary"/>
                                </xsl:when>
                                
                                <!-- Tibetan Search -->
                                <xsl:when test="/m:response/m:request/@tab eq 'tibetan-search'">
                                    
                                    <div class="alert alert-warning small text-center">
                                        <p>The Tibetan Search below is a convenient way to browse translation memories created from published 84000 translations. Search for a term or phrase by entering Tibetan script or Wylie into the search fields, or simply highlight a segment in the e-Kangyur display on the left. You can learn more about Translation Memories under the <a href="?tab=smartcat">CAT Tools</a> tab.</p>
                                        <p>**Please be aware that this is a beta version.**</p>
                                    </div>
                                    
                                    <xsl:call-template name="tibetan-search"/>
                                    
                                </xsl:when>
                                
                                <!-- Translations list -->
                                <xsl:when test="/m:response/m:request/@tab eq 'translations'">
                                    <xsl:call-template name="translations"/>
                                </xsl:when>
                                
                                <xsl:otherwise>
                                    <xsl:copy-of select="article/*"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </div>
                        
                    </div>
                    
                </div>
            </div>
            
            <!-- Link to top of page -->
            <div class="hidden-print">
                <div id="link-to-top-container" class="fixed-btn-container">
                    <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                        <i class="fa fa-arrow-up" aria-hidden="true"/>
                    </a>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities wait'"/>
            <xsl:with-param name="page-title" select="concat($tab-label, ' | 84000 Translator Tools')"/>
            <xsl:with-param name="page-description" select="'Tools for 84000 translators'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossary">
        
        <xsl:variable name="request-lang" select="if(m:glossary/@lang gt '') then m:glossary/@lang else 'en'"/>
        <xsl:variable name="request-type" select="if(m:glossary/@type gt '') then m:glossary/@type else 'term'"/>
        <xsl:variable name="request-search" select="/m:response/m:request/m:search"/>
        
        <div id="cumulative-glossary">
            <div class="center-vertical full-width">
                <div>
                    <ul class="nav nav-pills">
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'term'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=term&amp;lang=', $request-lang,'&amp;search=', $request-search)"/>
                                <xsl:value-of select="'Terms'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'person'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=person&amp;lang=', $request-lang,'&amp;search=', $request-search)"/>
                                <xsl:value-of select="'Persons'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'place'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=place&amp;lang=', $request-lang,'&amp;search=', $request-search)"/>
                                <xsl:value-of select="'Places'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'text'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=text&amp;lang=', $request-lang,'&amp;search=', $request-search)"/>
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
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', $request-type,'&amp;lang=en','&amp;search=', $request-search)"/>
                                <xsl:value-of select="'Translation'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'sa-ltn'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', $request-type,'&amp;lang=Sa-Ltn','&amp;search=', $request-search)"/>
                                <xsl:value-of select="'Sanskrit'"/>
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'bo-ltn'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', $request-type,'&amp;lang=Bo-Ltn','&amp;search=', $request-search)"/>
                                <xsl:value-of select="'Wylie'"/>
                            </a>
                        </li>
                    </ul>
                </div>
                <div>
                    <form method="post" role="search" class="form-inline">
                        <xsl:attribute name="action" select="'/index.html'"/>
                        <input type="hidden" name="tab" value="glossary"/>
                        <input type="hidden" name="type" value="search"/>
                        <input type="hidden" name="lang" value=""/>
                        <div id="search-controls" class="input-group">
                            <input type="text" name="search" class="form-control" placeholder="Search all types and languages...">
                                <xsl:if test="/m:response/m:request/@type eq 'search'">
                                    <xsl:attribute name="value" select="$request-search"/>
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
                <!-- 
                    Removed as it takes too long.
                    This needs another solution.
                <div>
                    <div class="pull-right">
                        <a href="cumulative-glossary.zip" class="download-link center-vertical">
                            <span>
                                <i class="fa fa-cloud-download"/>
                            </span>
                            <span>
                                <xsl:value-of select="'Download All (.xml)'"/>
                            </span>
                        </a>
                    </div>
                </div>
                 -->
            </div>
            
            <ul class="nav nav-tabs sml-tabs top-margin" role="tablist">
                <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
                <xsl:for-each select="1 to string-length($alphabet)">
                    <xsl:variable name="letter" select="substring($alphabet, ., 1)"/>
                    <li role="presentation">
                        <xsl:if test="$letter eq upper-case($request-search)">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', $request-type,'&amp;lang=', $request-lang,'&amp;search=', $letter)"/>
                            <xsl:value-of select="$letter"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
            
            <div class="div-list top-margin">
                <xsl:choose>
                    <xsl:when test="m:glossary/m:term">
                        
                        <xsl:for-each select="m:glossary/m:term">
                            <div class="item">
                                
                                <div class="row">
                                    <div class="col-sm-6 name">
                                        <xsl:value-of select="normalize-space(m:main-term/text())"/>
                                    </div>
                                    <div class="col-sm-6 text-right">
                                        <a target="_self">
                                            <xsl:attribute name="href" select="concat('glossary-items.html?term=', fn:encode-for-uri(m:main-term/text()), '&amp;lang=', m:main-term/@xml:lang)"/>
                                            <xsl:attribute name="data-ajax-target" select="concat('#occurrences-', position())"/>
                                            <xsl:choose>
                                                <xsl:when test="xs:integer(@count-items) gt 1">
                                                    <xsl:value-of select="concat(@count-items, ' matches')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(@count-items, ' match')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </a>
                                    </div>
                                </div>
                                
                                <div class="collpase">
                                    <xsl:attribute name="id" select="concat('occurrences-', position())"/>
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
    
    <xsl:template name="tibetan-search">
        
        <xsl:variable name="request-volume" select="/m:response/m:request/@volume"/>
        
        <div id="search-container">
            
            <div class="row">
                <div class="col-sm-8">
                    <form action="index.html" method="post" class="form-inline filter-form">
                        
                        <input type="hidden" name="tab" value="tibetan-search"/>
                        <input type="hidden" name="search">
                            <xsl:attribute name="value" select="/m:response/m:tm-search/m:request/text()"/>
                        </input>
                        
                        <div class="form-group">
                            <label for="volume" class="sr-only">
                                <xsl:value-of select="'Volume'"/>
                            </label>
                            <select name="volume" class="form-control" id="volume">
                                <xsl:for-each select="/m:response/m:volumes/m:volume">
                                    <xsl:sort select="xs:integer(@number)"/>
                                    <option>
                                        <xsl:attribute name="value" select="@number"/>
                                        <xsl:if test="xs:integer(@number) eq xs:integer($request-volume)">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="concat('eKangyur volume ', @number, ' (', @id, ')')"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="page" class="sr-only">
                                <xsl:value-of select="'Page'"/>
                            </label>
                            <select name="page" class="form-control" id="page">
                                <xsl:variable name="requested-page" select="/m:response/m:request/@page" as="xs:integer"/>
                                <xsl:for-each select="/m:response/m:volumes/m:volume[xs:integer(@number) eq xs:integer($request-volume)]/m:page">
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
                            <button class="btn btn-default" type="submit">
                                <i class="fa fa-refresh"/>
                            </button>
                        </div>
                        
                        <input type="hidden" data-onload-mark="#folio-text">
                            <xsl:attribute name="value" select="/m:response/m:tm-search/m:request-bo"/>
                        </input>
                        
                    </form>
                    
                    <div class="source text-overlay">
                        <div class="text divided text-bo">
                            <xsl:call-template name="text-marked">
                                <xsl:with-param name="data" select="/m:response/m:source/m:language[@xml:lang eq 'bo']"/>
                            </xsl:call-template>
                        </div>
                        <div id="folio-text" class="text plain text-bo" data-mouseup-set-input="#search-text-bo">
                            <xsl:call-template name="text-plain">
                                <xsl:with-param name="data" select="/m:response/m:source/m:language[@xml:lang eq 'bo']//tei:p"/>
                            </xsl:call-template>
                        </div>
                    </div>
                    
                </div>
                
                <div class="col-sm-4">
                    <form action="index.html" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="tab" value="tibetan-search"/>
                        <input type="hidden" name="lang" value="bo"/>
                        <input type="hidden" name="volume">
                            <xsl:attribute name="value" select="$request-volume"/>
                        </input>
                        <input type="hidden" name="page">
                            <xsl:attribute name="value" select="/m:response/m:request/@page/xs:integer(.)"/>
                        </input>
                        <label for="search-text-bo">
                            <xsl:value-of select="'Select or type some Tibetan'"/>
                        </label>
                        <div class="form-group">
                            <textarea rows="2" class="form-control text-bo" name="search" id="search-text-bo">
                                <xsl:apply-templates select="/m:response/m:tm-search/m:request-bo"/>
                            </textarea>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Search Tibetan</button>
                        </div>
                    </form>
                    <form action="index.html" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="tab" value="tibetan-search"/>
                        <input type="hidden" name="lang" value="bo-ltn"/>
                        <input type="hidden" name="volume">
                            <xsl:attribute name="value" select="$request-volume"/>
                        </input>
                        <input type="hidden" name="page">
                            <xsl:attribute name="value" select="/m:response/m:request/@page/xs:integer(.)"/>
                        </input>
                        <label for="search-text-bo-ltn">
                            <xsl:value-of select="'or type some Wylie'"/>
                        </label>
                        <div class="form-group">
                            <textarea rows="2" class="form-control text-wy" name="search" id="search-text-bo-ltn">
                                <xsl:apply-templates select="/m:response/m:tm-search/m:request-bo-ltn"/>
                            </textarea>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Search Wylie</button>
                        </div>
                    </form>
                </div>
            </div>
            
            <xsl:variable name="results" select="/m:response/m:tm-search/m:results"/>
            <xsl:choose>
                <xsl:when test="$results/m:item">
                    <div class="search-results sml-margin top">
                        <xsl:for-each select="$results/m:item">
                            <div class="search-result row">
                                <div class="col-sm-6">
                                    <div class="row">
                                        <div class="col-sm-1 small text-muted sml-margin top">
                                            <xsl:value-of select="concat(position() + $results/@first-record - 1, '.')"/>
                                        </div>
                                        <div class="col-sm-11">
                                            <p class="text-bo">
                                                <xsl:apply-templates select="m:match/m:tibetan"/>
                                            </p>
                                            <p class="translation">
                                                <xsl:apply-templates select="m:match/m:translation"/>
                                            </p>
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
                                        <p class="title">
                                            <a target="reading-room">
                                                <xsl:choose>
                                                    <xsl:when test="m:match/@type eq 'glossary-term'">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:source/@resource-id, '.html#', m:match/@id)"/>
                                                    </xsl:when>
                                                    <xsl:when test="m:match/@type eq 'tm-unit'">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:source/@resource-id, '.html#', '')"/>
                                                    </xsl:when>
                                                </xsl:choose>
                                                <xsl:apply-templates select="m:source/m:title"/>
                                            </a>
                                            <br/>
                                            <span class="translators text-muted small">
                                                <xsl:value-of select="'Translated by '"/>
                                                <xsl:variable name="author-ids" select="m:source/m:translation/m:contributors/m:author[@role eq 'translatorEng']/@ref ! substring-after(., 'contributors.xml#')"/>
                                                <xsl:value-of select="string-join(/m:response/m:contributor-persons/m:person[@xml:id = $author-ids]/m:label, ' · ')"/>
                                            </span>
                                            <xsl:for-each select="m:source/m:bibl">
                                                <br/>
                                                <span class="ancestors text-muted small">
                                                    <xsl:value-of select="'in '"/>
                                                    <xsl:for-each select="m:parent | m:parent//m:parent">
                                                        <xsl:sort select="@nesting" order="descending"/>
                                                        <xsl:value-of select="m:title[@xml:lang='en']/text()"/>
                                                        <xsl:value-of select="' / '"/>
                                                    </xsl:for-each>
                                                    <xsl:if test="m:toh/m:full">
                                                        <xsl:value-of select="m:toh/m:full"/>
                                                    </xsl:if>
                                                </span>
                                            </xsl:for-each>
                                        </p>
                                    </div>
                                </div>
                                
                            </div>
                        </xsl:for-each>
                    </div>
                    
                    <!-- Pagination -->
                    <xsl:copy-of select="common:pagination($results/@first-record, $results/@max-records, $results/@count-records, 'index.html?tab=tibetan-search', concat('&amp;search=', /m:response/m:tm-search/m:request-bo/text()/normalize-space(), '&amp;volume=', /m:response/m:request/@volume, '&amp;page=', /m:response/m:request/@page))"/>
                    
                </xsl:when>
                <xsl:otherwise>
                    <hr class="sml-margin"/>
                    <p>
                        <xsl:value-of select="'No search results'"/>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
            
        </div>
    </xsl:template>
    
    <xsl:template name="translations">
        <div class="alert alert-warning small text-center">
            <p>This page lists all current translations and some meta data. The <strong>editor mode</strong> links open the translations with all sections expanded. This is convenient for searching.</p>
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
                <xsl:for-each select="m:translations/m:text">
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
                                    <xsl:value-of select="m:titles/m:title[@xml:lang eq 'sa-ltn']"/>
                                </span>
                            </div>
                            <ul class="list-unstyled small sml-margin top text-muted">
                                <li>
                                    <xsl:value-of select="tei:bibl/tei:biblScope"/>
                                </li>
                                <li>
                                    <xsl:value-of select="'Translator(s): '"/>
                                    <xsl:value-of select="string-join(m:translation/m:contributors/m:author[@role eq 'translatorEng'], ' · ')"/>
                                </li>
                                <xsl:if test="m:translation/m:contributors/m:editor[@role eq 'reviser']">
                                    <li>
                                        <xsl:value-of select="'Editor(s): '"/>
                                        <xsl:value-of select="string-join(m:translation/m:contributors/m:editor[@role eq 'reviser'], ' · ')"/>
                                    </li>
                                </xsl:if>
                                <xsl:if test="m:translation/m:contributors/m:consultant[@role eq 'advisor']">
                                    <li>
                                        <xsl:value-of select="'Advisor(s): '"/>
                                        <xsl:value-of select="string-join(m:translation/m:contributors/m:consultant[@role eq 'advisor'], ' · ')"/>
                                    </li>
                                </xsl:if>
                                <li>
                                    <xsl:value-of select="concat('Published ', format-date(m:translation/m:publication-date, '[FNn,*-3], [D1o] [MNn,*-3] [Y]'))"/>
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
                <xsl:if test="$page-number eq /m:response/m:request/@page/xs:integer(.)">
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