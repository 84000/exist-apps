<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bcrdb="http://www.bcrdb.org/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/search.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="page-attributes" select="($request/m:segment ! concat('segment=', .), $request/@text-id ! concat('text-id=', .), $request/@ref-index ! concat('ref-index=', .))" as="xs:string*"/>
    <xsl:variable name="translation" select="/m:response/m:translation"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <!-- Ajax content -->
            <div id="ajax-source" class="data-container replace">
                
                <!-- Form to adjust and re-load -->
                <div class="row">
                    <div class="col-sm-10 col-sm-offset-1">
                        <form action="/source-utils.html" method="post" class="form-horizontal" data-loading="Loading...">
                            
                            <xsl:attribute name="data-ajax-target" select="'#ajax-source'"/>
                            
                            <input type="hidden" name="util" value="{ $request/@util }"/>
                            <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                            
                            <div class="input-group">
                                
                                <!-- Selected text -->
                                <input type="search" name="segment" id="segment" class="form-control text-bo" aria-label="Search text" placeholder="Search" required="required">
                                    <xsl:attribute name="value" select="$request/m:segment"/>
                                </input>
                                
                                <span class="input-group-btn">
                                    <button type="submit" class="btn btn-warning" title="Re-load">
                                        <i class="fa fa-refresh"/>
                                    </button>
                                </span>
                                
                            </div>
                            
                            <!-- Translation tool options
                            <div class="row">
                                <div class="col-sm-9">
                                    
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Tibetan Segment</label>
                                        <div class="col-sm-9">
                                            <input type="search" name="search" id="search" class="form-control text-bo" placeholder="Tibetan" required="required">
                                                <xsl:attribute name="value" select="$request/m:segment"/>
                                            </input>
                                        </div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Translation</label>
                                        <div class="col-sm-9">
                                            <textarea class="form-control" rows="2"></textarea>
                                        </div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <div class="col-sm-offset-3 col-sm-9">
                                            <ul class="list-inline inline-dots small">
                                                <li>
                                                    <a>
                                                        <xsl:value-of select="'Insert a footnote'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a>
                                                        <xsl:value-of select="'Insert a ref'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <span class="text-muted small">
                                                        <xsl:value-of select="'  Place the cursor where the element is to be added'"/>
                                                    </span>
                                                </li>
                                            </ul>
                                            
                                        </div>
                                    </div>
                                    
                                </div>
                                <div class="col-sm-3">
                                    <div class="form-group">
                                        <select class="form-control">
                                            <option>
                                                <xsl:value-of select="'Start a new paragraph'"/>
                                            </option>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <button type="submit" class="btn btn-primary">
                                            <xsl:value-of select="'Save translation'"/>
                                        </button>
                                    </div>
                                </div>
                            </div>-->
                        
                        </form>
                    </div>
                </div>
                
                <!-- Title -->
                <!--<xsl:choose>
                    <xsl:when test="$request[@util eq 'glossary-builder']">
                        <h2>
                            <xsl:value-of select="'Matching Glossary Entries'"/>
                        </h2>
                    </xsl:when>
                    <xsl:when test="$request[@util eq 'tm-search']">
                        <h2>
                            <xsl:value-of select="'Translation Memory Matches'"/>
                        </h2>
                    </xsl:when>
                    <xsl:when test="$request[@util eq 'machine-translation']">
                        <h2>
                            <xsl:value-of select="'Machine Translation from Dharma Mitra'"/>
                        </h2>
                    </xsl:when>
                </xsl:choose>-->
                
                <!-- Tabs -->
                <div class="tabs-container-center top-margin">
                    <ul class="nav nav-tabs" role="tablist">
                        
                        <!-- Glossary search -->
                        <li role="presentation">
                            <xsl:if test="$request[@util eq 'glossary-builder']">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="common:internal-link('/source-utils.html', ('util=glossary-builder', $page-attributes), '#ajax-source', '')"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                <xsl:value-of select="'Glossary Matches'"/>
                            </a>
                        </li>
                        
                        <!-- TM search -->
                        <li role="presentation" class="icon">
                            <xsl:if test="$request[@util eq 'tm-search']">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="common:internal-link('/source-utils.html', ('util=tm-search', $page-attributes), '#ajax-source', '')"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                <xsl:value-of select="'Translation Memory'"/>
                            </a>
                        </li>
                        
                        <!-- Machine translation -->
                        <li role="presentation" class="icon">
                            <xsl:if test="$request[@util eq 'machine-translation']">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="common:internal-link('/source-utils.html', ('util=machine-translation', $page-attributes), '#ajax-source', '')"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                <xsl:value-of select="'Machine Translation'"/>
                            </a>
                        </li>
                        
                    </ul>
                </div>
                
                <!-- Results -->
                <xsl:choose>
                    <xsl:when test="m:entities">
                        
                        <div id="combined-glossary">
                            <xsl:call-template name="glossary-results">
                                <xsl:with-param name="entities" select="m:entities"/>
                                <xsl:with-param name="pagination-url" select="common:internal-link('/source-utils.html', ('util=glossary-builder', $page-attributes), '#ajax-source', '')"/>
                                <xsl:with-param name="ajax-target" select="'#popup-footer-editor .data-container'"/>
                            </xsl:call-template>
                        </div>
                        
                    </xsl:when>
                    <xsl:when test="m:tm-search">
                        
                        <div id="search-container" class="sml-margin top">
                            <xsl:call-template name="tm-search-results">
                                <xsl:with-param name="results" select="m:tm-search/m:results"/>
                                <xsl:with-param name="pagination-url" select="common:internal-link('/source-utils.html', ('util=tm-search', $page-attributes), '#ajax-source', '')"/>
                                <xsl:with-param name="ajax-target" select="'#popup-footer-editor .data-container'"/>
                            </xsl:call-template>
                        </div>
                        
                    </xsl:when>
                    <xsl:when test="m:machine-translation">
                        <div class="text-center sml-margin top">
                            <p>
                                <xsl:value-of select="m:machine-translation/m:response-sentence"/>
                            </p>
                            <hr/>
                            <p class="text-muted italic">
                                <xsl:choose>
                                    <xsl:when test="m:machine-translation[m:trailer/text()]">
                                        <xsl:value-of select="m:machine-translation/m:trailer"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <small>
                                            <i>This translation is generated by the MITRA model, being developed at the Berkeley AI Research Lab.</i>
                                        </small>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                        </div>
                    </xsl:when>
                </xsl:choose>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Source Utilities | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 Source Utilities'"/>
            <xsl:with-param name="content">
                
                <div class="title-band hidden-print">
                    <div class="container">
                        <div class="center-vertical full-width">
                            <span class="logo">
                                <img alt="84000 logo">
                                    <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                                </img>
                            </span>
                            <span>
                                <h1 class="title">
                                    <xsl:value-of select="'Source Utilities'"/>
                                </h1>
                            </span>
                        </div>
                    </div>
                </div>
                
                <main class="content-band">
                    <div class="container">
                        <xsl:sequence select="$content"/>
                    </div>
                </main>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossary-results">
        
        <xsl:param name="entities" as="element(m:entities)"/>
        <xsl:param name="pagination-url" as="xs:string"/>
        <xsl:param name="ajax-target" as="xs:string?"/>
        
        <xsl:variable name="link-add-new" as="element(xhtml:a)?">
            <a>
                <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $translation/@id,  '&amp;resource-type=translation&amp;filter=blank-form#glossary-entry-new')"/>
                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor #glossary-entry-new'"/>
                <xsl:attribute name="data-editor-callbackurl" select="concat($reading-room-path, '/source/', $translation/m:toh/@key, '.html', $request/@ref-index ! concat('?ref-index=', .), m:view-mode-parameter('editor'))"/>
                <xsl:attribute name="data-ajax-loading" select="'Loading editor...'"/>
                <xsl:attribute name="class" select="'editor small'"/>
                <xsl:value-of select="concat('Create a new entry for ', $translation/m:toh/m:full)"/>
            </a>
        </xsl:variable>
        
        <!-- Results list -->
        <div id="entity-list">
            <xsl:choose>
                <xsl:when test="$entities[m:entity]">
                    
                    <xsl:for-each select="$entities/m:entity">
                        
                        <xsl:variable name="entity" select="."/>
                        <xsl:variable name="entity-data" as="element(m:entity-data)?">
                            <xsl:call-template name="entity-data">
                                <xsl:with-param name="entity" select="$entity"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                        <xsl:if test="$entity[@xml:id] and $entity-data[@related-entries ! xs:integer(.) gt 0]">
                            
                            <xsl:variable name="item-id" select="$entity/@xml:id"/>
                            
                            <div class="list-item" id="{ $item-id }">
                                
                                <!-- Entity title / link -->
                                <a class="entity-title block-link opener-link log-click">
                                    
                                    <xsl:attribute name="href" select="common:internal-link(concat('/glossary/', $item-id, '.html'), (m:view-mode-parameter((),())), concat('#', $item-id, '-detail'), $root/m:response/@lang)"/>
                                    <xsl:attribute name="data-ajax-target" select="concat('#', $item-id, '-detail')"/>
                                    <xsl:attribute name="data-toggle-active" select="concat('#', $item-id)"/>
                                    <xsl:attribute name="data-ajax-loading" select="'Loading detail...'"/>
                                    
                                    <div>
                                        <ul class="list-inline inline-dots">
                                            <xsl:for-each select="$entity-data/m:term[@xml:lang eq 'bo']">
                                                <li>
                                                    <span class="h2 text-bo">
                                                        <!-- Try marking the match -->
                                                        <xsl:value-of select="text()"/>
                                                    </span>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                    
                                    <xsl:if test="$entity-data/m:term[@xml:lang eq 'Sa-Ltn']">
                                        <div>
                                            <ul class="list-inline inline-dots row-margin">
                                                <xsl:for-each select="$entity-data/m:term[@xml:lang eq 'Sa-Ltn']">
                                                    <li>
                                                        <span class="text-sa">
                                                            <xsl:value-of select="text()"/>
                                                        </span>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </xsl:if>
                                    
                                </a>
                                
                                <!-- Entity body -->
                                <div id="{ concat($item-id, '-body') }">
                                    
                                    <!-- Ajax data here -->
                                    <div class="entity-detail collapse persist" id="{ concat($item-id, '-detail') }"/>
                                    
                                </div>
                                
                                <!-- Form to add to current text -->
                                <xsl:if test="$translation">
                                    
                                    <!-- Restrict Tibetan options to those matching the segment -->
                                    <xsl:variable name="options-bo" select="$entity-data/m:term[@xml:lang eq 'bo'][matches($request/m:segment, replace(text(),'།',''), 'i')]"/>
                                    
                                    <div class="row-margin">
                                        
                                        <!--
                                        <form action="/edit-glossary.html" method="post" data-loading="Adding glossary entry...">
                                            
                                            <input type="hidden" name="resource-id" value="{ $translation/@id }"/>
                                            <input type="hidden" name="resource-type" value="translation"/>
                                            <input type="hidden" name="form-action" value="update-glossary"/>
                                            <input type="hidden" name="entity-id" value="{ $item-id }"/>
                                            <input type="hidden" name="term-lang-1" value="bo-ltn"/>
                                            <input type="hidden" name="term-lang-2" value="sa-ltn"/>
                                            
                                            <div class="row">
                                                
                                                <div class="col-xs-3">
                                                    <select class="form-control text-bo" name="term-text-1">
                                                        <xsl:for-each select="distinct-values($options-bo/text())">
                                                            <option>
                                                                <xsl:attribute name="value" select="replace(.,'།','','i')"/>
                                                                <xsl:value-of select="."/>
                                                            </option>
                                                        </xsl:for-each>
                                                    </select>
                                                </div>
                                                
                                                <div class="col-xs-3">
                                                    <input class="form-control text-sa" name="term-text-2" placeholder="Sanskrit"/>
                                                </div>
                                                
                                                <div class="col-xs-3">
                                                    <input class="form-control" name="main-term" placeholder="Translation"/>
                                                </div>
                                                
                                                <div class="col-xs-2">
                                                    <button type="submit" class="btn btn-warning" title="Re-load">
                                                        <xsl:value-of select="concat('Add to ', $translation/m:toh/m:full)"/>
                                                    </button>
                                                </div>
                                                
                                            </div>
                                            
                                        </form>-->
                                        
                                        <a>
                                            <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $translation/@id,  '&amp;resource-type=translation&amp;filter=blank-form&amp;entity-id=', $item-id, '&amp;default-term-bo=', $options-bo[1], '#glossary-entry-new')"/>
                                            <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor #glossary-entry-new'"/>
                                            <xsl:attribute name="data-editor-callbackurl" select="concat($reading-room-path, '/source/', $translation/m:toh/@key, '.html', $request/@ref-index ! concat('?ref-index=', .), m:view-mode-parameter('editor'))"/>
                                            <xsl:attribute name="data-ajax-loading" select="'Loading editor...'"/>
                                            <xsl:attribute name="class" select="'editor small'"/>
                                            <xsl:value-of select="concat('Add to ', $translation/m:toh/m:full)"/>
                                        </a>
                                        
                                    </div>
                                </xsl:if>
                                
                            </div>
                        </xsl:if>
                        
                    </xsl:for-each>
                    
                    <!-- Target for new form -->
                    <div class="list-item">
                        <div id="glossary-entry-new">
                            <xsl:sequence select="$link-add-new"/>
                        </div>
                    </div>
                    
                    <!-- Pagination -->
                    <xsl:sequence select="common:pagination($entities/@first-record, $entities/@max-records, $entities/@count-records, $pagination-url, $ajax-target)"/>
                    
                </xsl:when>
                <xsl:otherwise>
                    
                    <!-- No results -->
                    <div class="text-center top-margin">
                        <p class="text-muted italic">
                            <xsl:value-of select="'~ No results ~'"/>
                        </p>
                        <xsl:sequence select="$link-add-new"/>
                    </div>
                    
                </xsl:otherwise>
            </xsl:choose>
            
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>