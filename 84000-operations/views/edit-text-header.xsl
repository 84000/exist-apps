<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="response" select="/m:response"/>
    <xsl:variable name="text" select="$response/m:text"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Title / status -->
                    <div class="center-vertical full-width sml-margin bottom">

                        <div class="h3">
                            <a target="_blank">
                                <xsl:attribute name="href" select="m:translation-href(($text/m:toh/@key)[1], (), (), (), (), $reading-room-path)"/>
                                <xsl:value-of select="concat(string-join($text/m:toh/m:full, ' / '), ' / ', $text/m:titles/m:title[@xml:lang eq 'en'][1])"/>
                            </a>
                        </div>
                        
                        <div class="text-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <!-- Links -->
                    <xsl:call-template name="text-links-list">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="disable-links" select="('edit-text-header')"/>
                        <xsl:with-param name="text-status" select="$response/m:text-statuses/m:status[@status-id eq $text/@status]"/>
                    </xsl:call-template>
                    
                    <!-- TEI -->
                    <div class="center-vertical full-width sml-margin top bottom">
                        
                        <!-- url -->
                        <div>
                            <a class="text-muted small">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/@id, '.tei')"/>
                                <xsl:attribute name="target" select="concat($text/@id, '.tei')"/>
                                <xsl:value-of select="concat('TEI file: ', $text/@document-url)"/>
                            </a>
                        </div>
                        
                        <!-- Version -->
                        <span class="text-right">
                            <a class="label label-success">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/@id, '.tei')"/>
                                <xsl:attribute name="target" select="concat($text/@id, '.tei')"/>
                                <xsl:value-of select="concat('TEI VERSION: ', if($text[@tei-version gt '']) then $text/@tei-version else '[none]')"/>
                            </a>
                        </span>
                        
                    </div>
                    
                    <!-- Forms accordion -->
                    <div class="list-group accordion accordion-bordered accordion-background top-margin" role="tablist" aria-multiselectable="true" id="forms-accordion">
                        
                        <xsl:call-template name="titles-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'titles') then true() else false()"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="source-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'source') then true() else false()"/>
                        </xsl:call-template>
                        
                    </div>
                
                </xsl:with-param>
                
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                </xsl:with-param>
                
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat(string-join($text/m:toh/m:full, ' / '), ' | Edit Text Header | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Edit headers for ', string-join($text/m:toh/m:full, ' / '))"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Titles form -->
    <xsl:template name="titles-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'titles'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                
                <div class="h4">
                    <xsl:value-of select="'Titles'"/>
                </div>
                
                <p class="text-muted small sml-margin top">
                    <xsl:value-of select="'Add and edit the titles of the text'"/>
                </p>
                
            </xsl:with-param>
            
            <xsl:with-param name="content">
                <form method="post" class="form-horizontal labels-left labels-light form-update top-margin" id="titles-form" data-loading="Updating titles...">
                    
                    <xsl:attribute name="action" select="'edit-text-header.html'"/>
                    
                    <input type="hidden" name="form-action" value="update-titles"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="$text/@id"/>
                    </input>
                    <input type="hidden" name="form-expand" value="titles"/>
                    
                    <!-- Titles -->
                    <div class="add-nodes-container">
                        <div class="form-group sml-margin bottom small text-muted">
                            <div class="col-sm-2">
                                <xsl:value-of select="'Type'"/>
                            </div>
                            <div class="col-sm-2">
                                <xsl:value-of select="'Lang.'"/>
                            </div>
                            <div class="col-sm-2">
                                <xsl:value-of select="'Toh.'"/>
                            </div>
                            <div class="col-sm-2">
                                <xsl:value-of select="'Text'"/>
                            </div>
                        </div>
                        <xsl:choose>
                            <xsl:when test="$text/m:titles/m:title">
                                <xsl:for-each select="$text/m:titles/m:title">
                                    <xsl:sort select="if(@type eq 'mainTitle') then 1 else if (@type eq 'longTitle') then 2 else if (@type eq 'otherTitle') then 3 else 4"/>
                                    <xsl:sort select="if(@xml:lang eq 'en') then 1 else if (@xml:lang eq 'Sa-Ltn') then 2 else if (@xml:lang eq 'bo') then 3 else 4"/>
                                    <xsl:sort select="@xml:lang"/>
                                    <xsl:sort select="@key"/>
                                    <xsl:call-template name="title-controls">
                                        <xsl:with-param name="title" select="."/>
                                        <xsl:with-param name="title-index" select="position()"/>
                                        <xsl:with-param name="title-types" select="/m:response/m:title-types/m:title-type[not(@id eq 'articleTitle')]"/>
                                        <xsl:with-param name="source-keys" select="$text/m:source/@key/string()"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="title-controls">
                                    <xsl:with-param name="title" select="()"/>
                                    <xsl:with-param name="title-index" select="1"/>
                                    <xsl:with-param name="title-types" select="/m:response/m:title-types/m:title-type[not(@id eq 'articleTitle')]"/>
                                    <xsl:with-param name="source-keys" select="$text/m:source/@key/string()"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div class="form-group">
                            <div class="col-sm-2">
                                <a href="#add-nodes" class="add-nodes">
                                    <span class="monospace">
                                        <xsl:value-of select="'+'"/>
                                    </span>
                                    <xsl:value-of select="' add a title'"/>
                                </a>
                            </div>
                            <div class="col-sm-10">
                                <p class="text-muted small">
                                    <xsl:call-template name="hyphen-help-text"/>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Title notes -->
                    <h5>
                        <xsl:value-of select="'Title note(s)'"/>
                    </h5>
                    <div class="add-nodes-container">
                        
                        <xsl:choose>
                            <xsl:when test="$text/m:titles/m:note">
                                <xsl:for-each select="$text/m:titles/m:note">
                                    <xsl:call-template name="title-note">
                                        <xsl:with-param name="index" select="position()"/>
                                        <xsl:with-param name="note" select="."/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="title-note">
                                    <xsl:with-param name="index" select="1"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <div>
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">
                                    <xsl:value-of select="'+'"/>
                                </span>
                                <xsl:value-of select="' add a note'"/>
                            </a>
                        </div>
                        
                    </div>
                    
                    <div class="form-group">
                        <div class="col-sm-12">
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:if test="/m:response/m:text[@locked-by-user gt '']">
                                    <xsl:attribute name="disabled" select="'disabled'"/>
                                </xsl:if>
                                <xsl:value-of select="'Save'"/>
                            </button>
                        </div>
                    </div>
                    
                </form>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="title-note">
        
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="note" as="element(m:note)?"/>
        
        <div class="form-group add-nodes-group">
            <div class="col-sm-2">
                <select class="form-control">
                    <xsl:attribute name="name" select="concat('titles-note-type-', $index)"/>
                    <option value="public">
                        <xsl:if test="$note[@type eq 'title']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Public'"/>
                    </option>
                    <option value="internal">
                        <xsl:if test="$note[@type eq 'title-internal']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Internal'"/>
                    </option>
                </select>
            </div>
            <div class="col-sm-10">
                <input class="form-control">
                    <xsl:attribute name="name" select="concat('titles-note-text-', $index)"/>
                    <xsl:attribute name="value" select="$note/text()"/>
                    <xsl:attribute name="placeholder" select="'e.g. In the Pedurma this text is also known as...'"/>
                </input>
            </div>
        </div>
        
    </xsl:template>
    
    <!-- Source form -->
    <xsl:template name="source-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'source'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                
                <div class="h4">
                    <xsl:value-of select="'Source'"/>
                </div>
                
                <p class="text-muted small sml-margin top">
                    <xsl:value-of select="'Specify the details of the Tibetan source text'"/>
                </p>
                
            </xsl:with-param>
            
            <xsl:with-param name="content">
                
                <form method="post" class="form-horizontal labels-left labels-light form-update" id="locations-form" data-loading="Updating source...">
                    
                    <xsl:attribute name="action" select="'edit-text-header.html'"/>
                    
                    <input type="hidden" name="form-action" value="update-source"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="$text/@id"/>
                    </input>
                    <input type="hidden" name="form-expand" value="source"/>
                    
                    <xsl:for-each select="$text/m:source">
                        
                        <xsl:variable name="toh-key" select="@key"/>
                        <xsl:variable name="toh-location" select="m:location"/>
                        
                        <input type="hidden">
                            <xsl:attribute name="name" select="concat('work-', $toh-key)"/>
                            <xsl:attribute name="value" select="$toh-location/@work"/>
                        </input>
                        
                        <input type="hidden">
                            <xsl:attribute name="name" select="concat('location-', $toh-key)"/>
                            <xsl:attribute name="value" select="$toh-key"/>
                        </input>
                        
                        <fieldset>
                            
                            <legend>
                                <xsl:value-of select="m:toh"/>
                            </legend>
                            
                            <div class="add-nodes-container bottom-margin">
                                <xsl:variable name="attributions" select="m:attribution"/>
                                <xsl:variable name="entities-sorted" as="element(m:entity)*">
                                    <xsl:perform-sort select="$entities">
                                        <xsl:sort select="(m:label[@xml:lang eq 'en'], m:label[@xml:lang eq 'Sa-Ltn'], m:label)[1] ! lower-case(.)"/>
                                    </xsl:perform-sort>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="$attributions">
                                        <xsl:for-each select="$attributions">
                                            <xsl:call-template name="attribution-controls">
                                                <xsl:with-param name="attribution" select="."/>
                                                <xsl:with-param name="attribution-index" select="common:index-of-node($attributions, .)"/>
                                                <xsl:with-param name="toh-key" select="$toh-key"/>
                                                <xsl:with-param name="entities-sorted" select="$entities-sorted"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="attribution-controls">
                                            <xsl:with-param name="attribution-index" select="1"/>
                                            <xsl:with-param name="toh-key" select="$toh-key"/>
                                            <xsl:with-param name="entities-sorted" select="$entities-sorted"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span>
                                        <xsl:value-of select="' add an attribution'"/>
                                    </a>
                                </div>
                            </div>
                            
                            <hr/>
                            
                            <div class="add-nodes-container">
                                <h4>
                                    <xsl:value-of select="concat('Location in the Degé ', if($toh-location/@work eq 'UT4CZ5369') then 'Kangyur' else 'Tengyur')"/>
                                </h4>
                                <xsl:for-each select="$toh-location/m:volume">
                                    <div class="row add-nodes-group">
                                        <div class="col-sm-3">
                                            <xsl:sequence select="ops:text-input('Volume: ', concat('volume-', $toh-key, '-', position()), @number, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:sequence select="ops:text-input('First page: ', concat('start-page-', $toh-key, '-', position()), @start-page, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:sequence select="ops:text-input('Last page: ', concat('end-page-', $toh-key, '-', position()), @end-page, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:sequence select="ops:text-input('Count: ', concat('count-pages-', $toh-key, '-', position()), sum(@end-page - (@start-page - 1)), 6, 'disabled')"/>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                
                                <div class="row">
                                    <div class="col-sm-3 sml-margin top">
                                        <a href="#add-nodes" class="add-nodes">
                                            <span class="monospace">+</span> add a volume </a>
                                    </div>
                                    <div class="col-sm-6 sml-margin top">
                                        <xsl:variable name="sum-volume-pages" select="sum($toh-location/m:volume ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1))) ! xs:integer(.)"/>
                                        <xsl:if test="$sum-volume-pages ne xs:integer($toh-location/@count-pages)">
                                            <div class="text-right">
                                                <span class="label label-danger">
                                                    <xsl:value-of select="concat('The sum of the above pages is ', $sum-volume-pages)"/>
                                                </span>
                                            </div>
                                        </xsl:if>
                                    </div>
                                    <div class="col-sm-3">
                                        <xsl:copy-of select="ops:text-input('Total pages: ', concat('count-pages-', $toh-key), $toh-location/@count-pages, 6, 'required')"/>
                                    </div>
                                </div>
                                
                            </div>
                            
                        </fieldset>
                        
                    </xsl:for-each>
                    
                    <div class="pull-right">
                        <button type="submit" class="btn btn-primary">
                            <xsl:if test="/m:response/m:text[@locked-by-user gt '']">
                                <xsl:attribute name="disabled" select="'disabled'"/>
                            </xsl:if>
                            <xsl:value-of select="'Save'"/>
                        </button>
                    </div>
                    
                </form>
            </xsl:with-param>
        
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Attribution row -->
    <xsl:template name="attribution-controls">
        
        <xsl:param name="attribution" as="element(m:attribution)?"/>
        <xsl:param name="attribution-index" as="xs:integer"/>
        <xsl:param name="toh-key" as="xs:string"/>
        <xsl:param name="entities-sorted" as="element(m:entity)*"/>
        
        <div class="row add-nodes-group sml-margin bottom">
            
            <input type="hidden">
                <xsl:attribute name="name" select="concat('attribution-id-', $toh-key, '-', $attribution-index)"/>
                <xsl:attribute name="value" select="$attribution/@xml:id"/>
            </input>
            
            <input type="hidden">
                <xsl:attribute name="name" select="concat('attribution-revision-', $toh-key, '-', $attribution-index)"/>
                <xsl:attribute name="value" select="$attribution/@revision"/>
            </input>
            
            <input type="hidden">
                <xsl:attribute name="name" select="concat('attribution-key-', $toh-key, '-', $attribution-index)"/>
                <xsl:attribute name="value" select="$attribution/@key"/>
            </input>
            
            <div class="col-sm-3">
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-role-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Attribution role:'"/>
                </label>
                <xsl:call-template name="select-attribution-role">
                    <xsl:with-param name="selected-value" select="$attribution/@role"/>
                    <xsl:with-param name="control-name" select="concat('attribution-role-', $toh-key, '-', $attribution-index)"/>
                </xsl:call-template>
            </div>
            
            <div class="col-sm-3">
                
                <xsl:variable name="entity" select="key('entity-instance', $attribution/@xml:id, $root)/parent::m:entity[1]" as="element(m:entity)?"/>
                <xsl:variable name="related-page" select="key('related-pages', $entity/m:instance/@id, $root)[1]"/>
                <xsl:variable name="related-entries" select="key('related-entries', $entity/m:instance/@id, $root)"/>
                
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-entity-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Entity:'"/>
                </label>
                
                <xsl:if test="$entity">
                    
                    <ul class="list-inline inline-dots small add-nodes-remove">
                        
                        <li>
                            <xsl:choose>
                                <xsl:when test="$related-page">
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', $related-page/@kb-id, '.html')"/>
                                        <xsl:attribute name="target" select="$related-page/@xml:id"/>
                                        <xsl:value-of select="'Knowledge base article'"/>
                                    </a>
                                    <xsl:value-of select="' '"/>
                                    <span>
                                        <xsl:choose>
                                            <xsl:when test="$related-page/@status-group eq 'published'">
                                                <xsl:attribute name="class" select="'label label-success'"/>
                                            </xsl:when>
                                            <xsl:when test="$related-page/@status-group eq 'in-progress'">
                                                <xsl:attribute name="class" select="'label label-warning'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="class" select="'label label-default'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:value-of select="$related-page/@status-group"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!--<a href="/knowledgebase.html" target="_blank">
                                        <xsl:value-of select="'No knowledge base article'"/>
                                    </a>-->
                                    <span class="text-muted">
                                        <xsl:value-of select="'No knowledge base article'"/>
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                        
                        <xsl:if test="$related-entries">
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $entity/@xml:id, '.html?view-mode=editor')"/>
                                    <xsl:attribute name="target" select="'84000-glossary'"/>
                                    <xsl:value-of select="'Glossary'"/>
                                </a>
                            </li>
                        </xsl:if>
                        
                    </ul>
                    
                </xsl:if>
                
                <select class="form-control">
                    <xsl:attribute name="name" select="concat('attribution-entity-', $toh-key, '-', $attribution-index)"/>
                    <xsl:attribute name="id" select="concat('attribution-entity-', $toh-key, '-', $attribution-index)"/>
                    <option>
                        <xsl:attribute name="value" select="''"/>
                        <xsl:value-of select="'[No entity]'"/>
                    </option>
                    <option>
                        <xsl:attribute name="value" select="'create-entity-for-expression'"/>
                        <xsl:value-of select="'[Create an entity for expression]'"/>
                    </option>
                    <xsl:for-each select="$entities-sorted">
                        <option>
                            <xsl:attribute name="value" select="@xml:id"/>
                            <xsl:if test="@xml:id eq $entity/@xml:id">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="(m:label[@xml:lang eq 'en'], m:label[@xml:lang eq 'Sa-Ltn'], m:label)[1] ! lower-case(.)"/>
                        </option>
                    </xsl:for-each>
                </select>
                
            </div>
            
            <div class="col-sm-4">
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-expression-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Expression in this text:'"/>
                </label>
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="concat('attribution-expression-', $toh-key, '-', $attribution-index)"/>
                    <xsl:attribute name="id" select="concat('attribution-expression-', $toh-key, '-', $attribution-index)"/>
                    <xsl:attribute name="value" select="text()"/>
                </input>
            </div>
            
            <div class="col-sm-2">
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-lang-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Expr. lang.:'"/>
                </label>
                <xsl:call-template name="select-language">
                    <xsl:with-param name="input-id" select="concat('attribution-lang-', $toh-key, '-', $attribution-index)"/>
                    <xsl:with-param name="input-name" select="concat('attribution-lang-', $toh-key, '-', $attribution-index)"/>
                    <xsl:with-param name="language-options" select="('','en','Bo-Ltn','Sa-Ltn')"/>
                    <xsl:with-param name="selected-language" select="$attribution/@xml:lang"/>
                </xsl:call-template>
            </div>
            
        </div>
        
    </xsl:template>
    
    <!-- Attribution role <select/> -->
    <xsl:template name="select-attribution-role">
        <xsl:param name="control-name" required="yes"/>
        <xsl:param name="selected-value" required="yes"/>
        <select class="form-control">
            
            <xsl:attribute name="name" select="$control-name"/>
            <xsl:attribute name="id" select="$control-name"/>
            
            <option value="">
                <xsl:value-of select="'[No role]'"/>
            </option>
            
            <option value="author">
                <xsl:if test="$selected-value eq 'author'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Author'"/>
            </option>
            
            <option value="author-contested">
                <xsl:if test="$selected-value eq 'author-contested'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Author (contested)'"/>
            </option>
            
            <option value="translator">
                <xsl:if test="$selected-value eq 'translator'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Translator'"/>
            </option>
            
            <option value="reviser">
                <xsl:if test="$selected-value eq 'reviser'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Reviser'"/>
            </option>
            
        </select>
    </xsl:template>
    
</xsl:stylesheet>