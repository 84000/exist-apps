<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="request-resource-id" select="/m:response/m:request/@resource-id"/>
    <xsl:variable name="request-resource-type" select="/m:response/m:request/@resource-type"/>
    <xsl:variable name="request-first-record" select="common:enforce-integer(/m:response/m:request/@first-record)" as="xs:integer"/>
    <xsl:variable name="request-max-records" select="common:enforce-integer(/m:response/m:request/@max-records)" as="xs:integer"/>
    <xsl:variable name="request-filter" select="/m:response/m:request/@filter"/>
    <xsl:variable name="request-search" select="/m:response/m:request/m:search[1]/text()"/>
    <xsl:variable name="request-similar-search" select="/m:response/m:request/m:similar-search[1]/text()"/>
    
    <xsl:variable name="request-glossary-id" select="/m:response/m:request/@glossary-id"/>
    <xsl:variable name="request-show-tab" select="/m:response/m:request/@show-tab"/>
    
    <xsl:variable name="text" select="/m:response/m:text[1]"/>
    <xsl:variable name="glossary" select="/m:response/m:glossary[1]"/>
    <xsl:variable name="glossary-cache" select="/m:response/m:glossary-cache[1]"/>
    <xsl:variable name="cache-slow" select="if($glossary-cache/@seconds-to-build ! xs:decimal(.) gt 120) then true() else false()" as="xs:boolean"/>
    <xsl:variable name="cache-old" select="if(compare($text/@tei-version, $glossary/@tei-version-cached) ne 0) then true() else false()" as="xs:boolean"/>
    
    <xsl:variable name="term-langs" select="('', 'en', 'Bo-Ltn', 'bo', 'Sa-Ltn', 'zh')" as="xs:string*"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Glossary'"/>
                    </h3>
                    
                    <!-- Page title / add new link / cache all link -->
                    <div class="center-vertical full-width no-bottom-margin">
                        
                        <!-- Text title / link -->
                        <div class="h3">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor')"/>
                                <xsl:variable name="title-limited">
                                    <xsl:choose>
                                        <xsl:when test="$request-resource-type eq 'knowledgebase'">
                                            <xsl:value-of select="common:limit-str($text/m:titles/m:title[@type eq 'mainTitle'][1], 80)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="common:limit-str($text/m:titles/m:title[@xml:lang eq 'en'][1], 80)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:value-of select="$title-limited"/>
                                <small>
                                    <xsl:value-of select="' / '"/>
                                    <xsl:value-of select="common:limit-str($request-resource-id, 100 - string-length($title-limited))"/>
                                </small>
                            </a>
                        </div>
                        
                        <!-- Cache locations button - uncached -->
                        <xsl:if test="$request-filter = ('no-cache') and not($request-search gt '') and $glossary[m:item]">
                            <div>
                                <xsl:call-template name="form">
                                    <xsl:with-param name="form-action" select="'cache-locations-uncached'"/>
                                    <xsl:with-param name="form-class" select="'form-inline pull-right'"/>
                                    <xsl:with-param name="form-content">
                                        <button type="submit" class="btn btn-danger btn-sm" data-loading="Caching locations...">
                                            <xsl:value-of select="'Cache locations of items with no cache'"/>
                                        </button>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </div>
                        </xsl:if>
                        
                        <!-- Add new button -->
                        <xsl:if test="not($request-filter eq 'blank-form')">
                            <div>
                                <!-- A link to close the item -->
                                <xsl:call-template name="link">
                                    <xsl:with-param name="filter" select="'blank-form'"/>
                                    <xsl:with-param name="search" select="''"/>
                                    <xsl:with-param name="link-text" select="'Add a new glossary item'"/>
                                    <xsl:with-param name="link-class" select="'btn btn-success btn-sm pull-right'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:if>
                        
                    </div>
                    
                    <hr class="sml-margin"/>
                    
                    <!-- Version row -->
                    <ul class="list-inline inline-dots no-bottom-margin">
                        
                        <xsl:if test="$text[@tei-version]">
                            <li>
                                <span class="small">
                                    <xsl:value-of select="'Current TEI version: '"/>
                                </span>
                                <span class="label label-default">
                                    <xsl:value-of select="$text/@tei-version"/>
                                </span>
                            </li>
                        </xsl:if>
                        
                        <xsl:if test="$glossary[@tei-version-cached]">
                            <li>
                                <span class="small">
                                    <xsl:value-of select="'Cache version: '"/>
                                </span>
                                <span class="label label-default">
                                    <xsl:if test="$cache-old">
                                        <xsl:attribute name="class" select="'label label-warning'"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$glossary[@tei-version-cached gt '0']">
                                            <xsl:value-of select="$glossary/@tei-version-cached"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'[none]'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                            </li>
                        </xsl:if>
                        
                        <xsl:choose>
                            
                            <xsl:when test="$cache-slow">
                                <li>
                                    <span class="small">
                                        <xsl:value-of select="'The latest location cache took '"/>
                                    </span>
                                    <span class="label label-warning">
                                        <xsl:value-of select="concat(format-number(($glossary-cache/@seconds-to-build ! xs:decimal(.) div 60), '#,###.##'), ' minutes')"/>
                                    </span>
                                </li>
                            </xsl:when>
                            
                            <xsl:when test="$glossary-cache[@seconds-to-build]">
                                <li>
                                    <span class="small">
                                        <xsl:value-of select="'The latest location cache took '"/>
                                    </span>
                                    <span class="label label-default">
                                        <xsl:value-of select="concat(format-number($glossary-cache/@seconds-to-build, '#,###.##'), ' seconds')"/>
                                    </span>
                                </li>
                            </xsl:when>
                            
                        </xsl:choose>
                        
                        <li>
                            <a target="_self" class="underline" data-loading="Re-caching locations...">
                                <xsl:attribute name="href" select="concat('edit-glossary.html?resource-id=', $request-resource-id, '&amp;resource-type=', $request-resource-type, '&amp;form-action=cache-locations-all&amp;filter=check-expressions')"/>
                                <span class="small">
                                    <xsl:value-of select="'Re-cache locations of all items'"/>
                                </span>
                            </a>
                        </li>
                        
                        <li>
                            <a target="_self" class="underline">
                                <xsl:choose>
                                    <xsl:when test="$request-resource-type eq 'knowledgebase'">
                                        <xsl:attribute name="href" select="concat('edit-kb-header.html?id=', $request-resource-id)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $request-resource-id)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <span class="small">
                                    <xsl:value-of select="'Edit headers'"/>
                                </span>
                            </a>
                        </li>
                        
                        <li>
                            <a target="_self" class="underline" data-loading="Auto-assigning entities...">
                                <xsl:attribute name="href" select="concat('edit-glossary.html?resource-id=', $request-resource-id, '&amp;resource-type=', $request-resource-type, '&amp;form-action=merge-all-entities&amp;filter=requires-attention')"/>
                                <span class="small">
                                    <xsl:value-of select="'Auto-assign entities'"/>
                                </span>
                            </a>
                        </li>
                        
                    </ul>
                    
                    <!-- Filter / Pagination -->
                    <xsl:if test="not($request-filter eq 'blank-form')">
                        
                        <hr class="sml-margin"/>
                        
                        <div class="center-vertical full-width no-bottom-margin">
                            
                            <div>
                                <xsl:call-template name="form">
                                    <xsl:with-param name="form-class" select="'form-inline'"/>
                                    <xsl:with-param name="first-record" select="1"/>
                                    <xsl:with-param name="form-content">
                                        
                                        <div class="form-group">
                                            <div class="input-group">
                                                
                                                <div class="input-group-addon">
                                                    <xsl:value-of select="'Mode:'"/>
                                                </div>
                                                
                                                <select name="filter" class="form-control">
                                                    <option value="check-entities">
                                                        <xsl:if test="$request-filter eq 'check-entities'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Check entities'"/>
                                                    </option>
                                                    <option value="check-expressions">
                                                        <xsl:if test="$request-filter eq 'check-expressions'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Check locations'"/>
                                                    </option>
                                                    <option value="check-all">
                                                        <xsl:if test="$request-filter eq 'check-all'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Check all'"/>
                                                    </option>
                                                    <option value="missing-entities">
                                                        <xsl:if test="$request-filter eq 'missing-entities'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'No shared entity'"/>
                                                    </option>
                                                    <option value="requires-attention">
                                                        <xsl:if test="$request-filter eq 'requires-attention'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Requiring attention'"/>
                                                    </option>
                                                    <option value="no-cache">
                                                        <xsl:if test="$request-filter eq 'no-cache'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Not cached'"/>
                                                    </option>
                                                    <option value="new-expressions">
                                                        <xsl:if test="$request-filter eq 'new-expressions'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'New locations'"/>
                                                        <xsl:if test="$cache-slow">
                                                            <xsl:value-of select="concat(' (', format-number(($glossary-cache/@seconds-to-build ! xs:decimal(.) div 60), '#,###'), ' mins)')"/>
                                                        </xsl:if>
                                                    </option>
                                                    <option value="no-expressions">
                                                        <xsl:if test="$request-filter eq 'no-expressions'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'No locations'"/>
                                                        <xsl:if test="$cache-slow">
                                                            <xsl:value-of select="concat(' (', format-number(($glossary-cache/@seconds-to-build ! xs:decimal(.) div 60), '#,###'), ' mins)')"/>
                                                        </xsl:if>
                                                    </option>
                                                </select>
                                                
                                            </div>
                                        
                                            <div class="input-group">
                                                
                                                <div class="input-group-addon">
                                                    <xsl:value-of select="'Search:'"/>
                                                </div>
                                                
                                                <input type="text" name="search" id="search" class="form-control" size="10" maxlength="100">
                                                    <xsl:attribute name="value" select="$request-search"/>
                                                </input>
                                                
                                            </div>
                                        
                                            <div class="input-group">
                                                    
                                                <div class="input-group-addon">
                                                    <xsl:value-of select="'Records:'"/>
                                                </div>
                                                
                                                <input type="number" name="max-records" id="max-records" class="form-control" size="3" min="1" max="100">
                                                    <xsl:attribute name="value" select="$request-max-records"/>
                                                </input>
                                                
                                            </div>
                                            
                                            <div class="input-group">
                                                <button class="btn btn-primary" type="submit" data-loading="Applying filter...">
                                                    <i class="fa fa-refresh"/>
                                                </button>
                                            </div>
                                            
                                        </div>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </div>
                            
                            <div>
                                <xsl:variable name="pagination-href">
                                    <xsl:call-template name="link-href"/>
                                </xsl:variable>
                                <xsl:sequence select="common:pagination(common:enforce-integer($glossary/@first-record), common:enforce-integer($glossary/@max-records), common:enforce-integer($glossary/@count-records), $pagination-href)"/>
                            </div>
                            
                        </div>
                    
                    </xsl:if>
                    
                    <!-- Form for adding a new entry -->
                    <xsl:if test="$request-filter eq 'blank-form'">
                        
                        <hr class="sml-margin"/>
                        
                        <h4 class="no-top-margin">
                            <xsl:value-of select="'Add a new Entry'"/>
                        </h4>
                        
                        <hr class="sml-margin"/>
                        
                        <xsl:call-template name="form">
                            
                            <xsl:with-param name="form-action" select="'update-glossary'"/>
                            <xsl:with-param name="form-content">
                                
                                <!-- Go to the normal list on adding a new item -->
                                <input type="hidden" name="filter" value="check-all"/>
                                
                                <xsl:call-template name="glossary-form"/>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                    </xsl:if>
                    
                    <!-- Loop through glossary items -->
                    <xsl:if test="$glossary[m:item]">
                        
                        <hr class="sml-margin"/>
                        
                        <xsl:for-each select="$glossary/m:item">
                            
                            <xsl:variable name="loop-glossary" select="."/>
                            <xsl:variable name="loop-glossary-id" select="($loop-glossary/@id, 'new-glossary')[1]"/>
                            <xsl:variable name="loop-glossary-cache" select="$glossary-cache/m:gloss[@id eq $loop-glossary-id][m:location]"/>
                            <xsl:variable name="locations-cached" select="$loop-glossary/m:expressions/m:location[@id = $loop-glossary-cache/m:location/@id]"/>
                            <xsl:variable name="locations-not-cached" select="$loop-glossary/m:expressions/m:location[not(@id = $locations-cached/@id)]"/>
                            <xsl:variable name="loop-glossary-instance" select="$loop-glossary/m:entity/m:instance[@id eq $loop-glossary-id]"/>
                            
                            <div>
                                
                                <!-- Set id to support scroll to selected item -->
                                <xsl:if test="$loop-glossary[@active-item eq 'true']">
                                    <xsl:attribute name="id" select="'selected-entity'"/>
                                </xsl:if>
                                
                                <!-- Title -->
                                <h4 class="sml-margin bottom">
                                    
                                    <!-- Term -->
                                    <span class="text-danger">
                                        <xsl:value-of select="m:term[@xml:lang eq 'en'][1]"/>
                                    </span>
                                    
                                    <!-- Reading Room link -->
                                    <span class="small">
                                        <xsl:value-of select="' / '"/>
                                        <a target="reading-room">
                                            <xsl:attribute name="href" select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', '#', $loop-glossary-id)"/>
                                            <xsl:value-of select="$loop-glossary-id"/>
                                        </a>
                                    </span>
                                    
                                    <!-- link to Combined glossary -->
                                    <xsl:if test="$loop-glossary[m:entity]">
                                        <span class="small">
                                            <xsl:value-of select="' / '"/>
                                            <a target="84000-glossary">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $loop-glossary/m:entity/@xml:id, '&amp;view-mode=editor')"/>
                                                <xsl:value-of select="'84000 glossary'"/>
                                            </a>
                                        </span>
                                    </xsl:if>
                                    
                                    <!-- Isolate a single record -->
                                    <span class="small">
                                        <xsl:value-of select="' / '"/>
                                        <xsl:call-template name="link">
                                            <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                            <xsl:with-param name="max-records" select="1"/>
                                            <xsl:with-param name="link-text" select="'isolate'"/>
                                            <xsl:with-param name="search" select="''"/>
                                            <xsl:with-param name="filter" select="if($request-filter = ('check-entities', 'check-expressions')) then $request-filter else 'check-all'"/>
                                        </xsl:call-template>
                                    </span>
                                    
                                </h4>
                                
                                <!-- Definition -->
                                <xsl:if test="$loop-glossary/m:definition[node()]">
                                    <div class="sml-margin bottom collapse-one-line">
                                        <xsl:choose>
                                            <xsl:when test="not($loop-glossary-instance[@use-definition eq 'replace'])">
                                                <xsl:call-template name="glossary-definition">
                                                    <xsl:with-param name="item" select="$loop-glossary"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <div class="sml-margin bottom">
                                                    <span class="label label-default">
                                                        <xsl:value-of select="'Glossary definition hidden'"/>
                                                    </span>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </xsl:if>
                                
                                <!-- Entity definition used -->
                                <xsl:if test="$loop-glossary/m:entity/m:content[@type eq 'glossary-definition'] and $loop-glossary-instance[@use-definition  = ('after', 'replace')]">
                                    <div class="sml-margin bottom">
                                        <p>
                                            <span class="label label-default">
                                                <xsl:value-of select="'Entity definition included'"/>
                                            </span>
                                        </p>
                                    </div>
                                </xsl:if>
                                
                                <!-- Accordion -->
                                <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                    
                                    <xsl:attribute name="id" select="concat('accordion-', $loop-glossary-id)"/>
                                    
                                    <!-- Panel: Glossary form -->
                                    <xsl:call-template name="expand-item">
                                        
                                        <xsl:with-param name="id" select="concat('glossary-form-',$loop-glossary-id)"/>
                                        <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                        <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'glossary-form'"/>
                                        
                                        <xsl:with-param name="title">
                                            
                                            <xsl:call-template name="glossary-terms">
                                                <xsl:with-param name="item" select="."/>
                                                <xsl:with-param name="list-class" select="'no-bottom-margin'"/>
                                            </xsl:call-template>
                                            
                                        </xsl:with-param>
                                        
                                        <xsl:with-param name="content">
                                            
                                            <hr class="sml-margin"/>
                                            
                                            <xsl:call-template name="form">
                                                
                                                <xsl:with-param name="show-tab" select="'glossary-form'"/>
                                                <xsl:with-param name="form-action" select="'update-glossary'"/>
                                                <xsl:with-param name="form-content">
                                                    
                                                    <xsl:call-template name="glossary-form">
                                                        <xsl:with-param name="glossary" select="$loop-glossary"/>
                                                    </xsl:call-template>
                                                    
                                                </xsl:with-param>
                                                
                                            </xsl:call-template>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Panel: Show locations of this glossary in the text-->
                                    <xsl:if test="$request-filter = ('check-expressions', 'check-all', 'no-cache', 'new-expressions', 'no-expressions')">
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="id" select="concat('expressions-',$loop-glossary-id)"/>
                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                            <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'expressions'"/>
                                            
                                            <xsl:with-param name="title">
                                                <div class="center-vertical align-left">
                                                    
                                                    <div>
                                                        <xsl:variable name="count-locations" select="count($loop-glossary-cache/m:location)"/>
                                                        <span>
                                                            <xsl:value-of select="' ↳ '"/>
                                                        </span>
                                                        <span class="badge badge-notification badge-muted">
                                                            <xsl:choose>
                                                                <xsl:when test="$loop-glossary[m:expressions[m:locations]]">
                                                                    <xsl:attribute name="class" select="'badge badge-notification badge-info'"/>
                                                                </xsl:when>
                                                                <xsl:when test="$loop-glossary[m:expressions]">
                                                                    <xsl:attribute name="class" select="'badge badge-notification'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            <xsl:value-of select="$count-locations"/>
                                                        </span>
                                                        <span class="badge-text">
                                                            <xsl:choose>
                                                                <xsl:when test="$count-locations eq 1">
                                                                    <xsl:value-of select="'location'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="'locations'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </span>
                                                    </div>
                                                    
                                                    <xsl:if test="not($loop-glossary-cache)">
                                                        <div>
                                                            <span class="label label-danger">
                                                                <xsl:value-of select="'Not cached'"/>
                                                            </span>
                                                        </div>
                                                    </xsl:if>
                                                
                                                    <xsl:if test="$locations-not-cached">
                                                        <div>
                                                            <span class="label label-danger">
                                                                <xsl:value-of select="concat(count($locations-not-cached), ' new location')"/>
                                                            </span>
                                                        </div>
                                                    </xsl:if>
                                                    
                                                </div>
                                            </xsl:with-param>
                                            
                                            <xsl:with-param name="content">
                                                
                                                <!-- Replace with Ajax call on opening -->
                                                <xsl:call-template name="form">
                                                    
                                                    <xsl:with-param name="show-tab" select="'expressions'"/>
                                                    <xsl:with-param name="form-class" select="'form-inline'"/>
                                                    <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                    
                                                    <xsl:with-param name="form-content">
                                                        
                                                        <input type="hidden" name="form-action" value="cache-locations"/>
                                                        
                                                        <xsl:choose>
                                                            
                                                            <xsl:when test="$loop-glossary/m:expressions[m:location]">
                                                                
                                                                <div class="div-list sml-margin top bottom">
                                                                    
                                                                    <xsl:for-each select="$loop-glossary/m:expressions/m:location">
                                                                        <xsl:sort select="xs:integer(@sort-index)"/>
                                                                        <xsl:apply-templates select="."/>  
                                                                    </xsl:for-each>
                                                                    
                                                                    <xsl:if test="$locations-not-cached">
                                                                        <div class="item center-vertical full-width">
                                                                            
                                                                            <div class="small text-danger">
                                                                                <xsl:value-of select="'Once you have confirmed that these are the valid instances of this glossary entry, please select the option &#34;Cache locations&#34;.'"/>
                                                                                <br/>
                                                                                <xsl:value-of select="'An instance will not appear in the public Reading Room until its location is cached.'"/>
                                                                            </div>
                                                                            
                                                                            <div>
                                                                                <button type="submit" class="btn btn-danger btn-sm pull-right" data-loading="Caching locations...">
                                                                                    <xsl:value-of select="'Cache locations'"/>
                                                                                </button>
                                                                            </div>
                                                                            
                                                                        </div>
                                                                    </xsl:if>
                                                                    
                                                                </div>
                                                                
                                                            </xsl:when>
                                                            
                                                            <xsl:otherwise>
                                                                <hr class="sml-margin"/>
                                                                <p class="text-muted small">
                                                                    <xsl:value-of select="'No instances of this glossary term found in this text!'"/>
                                                                </p>
                                                            </xsl:otherwise>
                                                            
                                                        </xsl:choose>
                                                        
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                                
                                            </xsl:with-param>
                                            
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                    <!-- Entity panels -->
                                    <xsl:if test="$request-filter = ('check-entities', 'check-all', 'missing-entities', 'requires-attention')">
                                        
                                        <xsl:variable name="entity" select="$loop-glossary/m:entity"/>
                                        
                                        <!-- Panel: Entity form -->
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="id" select="concat('entity-', $loop-glossary-id)"/>
                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                            <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity'"/>
                                            
                                            <!-- Entity panel title -->
                                            <xsl:with-param name="title">
                                                
                                                <ul class="list-inline inline-dots no-bottom-margin">
                                                    <xsl:choose>
                                                        <xsl:when test="$entity">
                                                            
                                                            <li>
                                                                <span class="small">
                                                                    <xsl:value-of select="'Entity: '"/>
                                                                </span>
                                                                <span>
                                                                    <xsl:attribute name="class">
                                                                        <xsl:value-of select="common:lang-class($entity/m:label[1]/@xml:lang)"/>
                                                                    </xsl:attribute>
                                                                    <xsl:value-of select="common:limit-str($entity/m:label[1] ! fn:normalize-space(.), 150)"/>
                                                                </span>
                                                            </li>
                                                            
                                                            <li class="small">
                                                                <xsl:value-of select="$entity/@xml:id"/>
                                                            </li>
                                                            
                                                            <li>
                                                                <xsl:call-template name="entity-type-labels">
                                                                    <xsl:with-param name="entity" select="$entity"/>
                                                                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                                                </xsl:call-template>
                                                            </li>
                                                            
                                                            <xsl:for-each select="/m:response/m:entity-flags/m:flag[@id = $entity/m:flag/@type]">
                                                                <li>
                                                                    <span class="label label-danger">
                                                                        <xsl:value-of select="m:label"/>
                                                                    </span>
                                                                </li>
                                                            </xsl:for-each>
                                                            
                                                            <li>
                                                                <a target="84000-glossary" class="small">
                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $entity/@xml:id, '&amp;view-mode=editor')"/>
                                                                    <xsl:value-of select="'84000 Glossary'"/>
                                                                </a>
                                                            </li>
                                                            
                                                            
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <li>
                                                                <span class="label label-danger">
                                                                    <xsl:value-of select="'No shared entity'"/>
                                                                </span>
                                                            </li>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </ul>
                                                
                                            </xsl:with-param>
                                            
                                            <!-- Entity panel content -->
                                            <xsl:with-param name="content">
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <xsl:call-template name="entity-form-warning">
                                                    <xsl:with-param name="entity" select="$entity"/>
                                                </xsl:call-template>
                                                
                                                <!-- Form: for editing/adding an entity -->
                                                <xsl:call-template name="entity-form">
                                                    <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                </xsl:call-template>
                                                
                                            </xsl:with-param>
                                        
                                        </xsl:call-template>
                                        
                                        <!-- Panel: Entity instances -->
                                        <xsl:if test="$entity">
                                            <xsl:call-template name="expand-item">
                                                
                                                <xsl:with-param name="id" select="concat('entity-instances-', $loop-glossary-id)"/>
                                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity-instances'"/>
                                                
                                                <xsl:with-param name="title">
                                                    <xsl:variable name="count-entity-instances" select="count($entity/m:instance)"/>
                                                    <span>
                                                        <xsl:value-of select="' ↳ '"/>
                                                    </span>
                                                    <span class="badge badge-notification badge-info">
                                                        <xsl:value-of select="$count-entity-instances"/>
                                                    </span>
                                                    <span class="badge-text">
                                                        <xsl:choose>
                                                            <xsl:when test="$count-entity-instances eq 1">
                                                                <xsl:value-of select="'matching element'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'matching elements'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                </xsl:with-param>
                                                
                                                <xsl:with-param name="content">
                                                    
                                                    <hr class="sml-margin"/>
                                                    
                                                    <!-- List related glossary items -->
                                                    <xsl:for-each-group select="$entity/m:instance/m:item" group-by="m:text/@id">
                                                        
                                                        <xsl:sort select="if(current-group()[@id eq $loop-glossary/@id]) then 1 else 2"/>
                                                        <xsl:sort select="m:text[1]/@id"/>
                                                        
                                                        <xsl:call-template name="glossary-items-text-group">
                                                            <xsl:with-param name="glossary-items" select="current-group()"/>
                                                            <xsl:with-param name="active-glossary-id" select="$loop-glossary/@id"/>
                                                        </xsl:call-template>
                                                        
                                                    </xsl:for-each-group>
                                                    
                                                    <!-- List related knowledgebase pages -->
                                                    <xsl:call-template name="knowledgebase-page-instance">
                                                        <xsl:with-param name="knowledgebase-page" select="$entity/m:instance/m:page"/>
                                                        <xsl:with-param name="active-kb-id" select="''"/>
                                                    </xsl:call-template>
                                                    
                                                </xsl:with-param>
                                                
                                            </xsl:call-template>
                                        </xsl:if>
                                        
                                        <!-- Panel: Entity relations -->
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="id" select="concat('entity-relations-', $loop-glossary-id)"/>
                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-relations'"/>
                                            
                                            <xsl:with-param name="title">
                                                
                                                <xsl:variable name="count-relations" select="count($entity/m:relation)"/>
                                                <span>
                                                    <xsl:value-of select="' ↳ '"/>
                                                </span>
                                                <span class="badge badge-notification badge-info">
                                                    <xsl:value-of select="$count-relations"/>
                                                </span>
                                                <span class="badge-text">
                                                    <xsl:choose>
                                                        <xsl:when test="$count-relations eq 1">
                                                            <xsl:value-of select="'related entity'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'related entities'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                 
                                            </xsl:with-param>
                                            
                                            <xsl:with-param name="content">
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <xsl:choose>
                                                    
                                                    <xsl:when test="$entity/m:relation">
                                                        
                                                        <xsl:call-template name="glossary-terms">
                                                            <xsl:with-param name="item" select="$loop-glossary"/>
                                                        </xsl:call-template>
                                                        
                                                        <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                                            
                                                            <xsl:attribute name="id" select="concat('accordion-glossary-', $loop-glossary-id, '-relations')"/>
                                                            
                                                            <xsl:for-each select="$entity/m:relation">
                                                                
                                                                <xsl:variable name="relation" select="."/>
                                                                
                                                                <xsl:call-template name="expand-item">
                                                                    
                                                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-glossary-', $loop-glossary-id, '-relations')"/>
                                                                    <xsl:with-param name="id" select="concat('glossary-', $loop-glossary-id, '-relation-', $relation/@id)"/>
                                                                    
                                                                    <xsl:with-param name="title">
                                                                        
                                                                        <div class="center-vertical align-left">
                                                                            
                                                                            <div>
                                                                                <xsl:value-of select="' ↳ '"/>
                                                                            </div>
                                                                            
                                                                            <div>
                                                                                <ul class="list-inline inline-dots no-bottom-margin">
                                                                                    <li>
                                                                                        <span>
                                                                                            <xsl:choose>
                                                                                                <xsl:when test="$relation/@predicate eq 'isUnrelated'">
                                                                                                    <xsl:attribute name="class" select="'label label-default'"/>
                                                                                                </xsl:when>
                                                                                                <xsl:otherwise>
                                                                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                                                                </xsl:otherwise>
                                                                                            </xsl:choose>
                                                                                            <xsl:value-of select="/m:response/m:entity-predicates//m:predicate[@xml:id eq $relation/@predicate]/m:label"/>
                                                                                            <xsl:value-of select="':'"/>
                                                                                        </span>
                                                                                    </li>
                                                                                    <li>
                                                                                        <span class="small">
                                                                                            <xsl:value-of select="' Entity: '"/>
                                                                                        </span>
                                                                                        <xsl:for-each select="$relation/m:label">
                                                                                            <span>
                                                                                                <xsl:attribute name="class">
                                                                                                    <xsl:value-of select="common:lang-class(@xml:lang)"/>
                                                                                                </xsl:attribute>
                                                                                                <xsl:value-of select="common:limit-str(text(), 80)"/>
                                                                                            </span>
                                                                                        </xsl:for-each>
                                                                                    </li>
                                                                                    <li>
                                                                                        <xsl:call-template name="entity-type-labels">
                                                                                            <xsl:with-param name="entity" select="$relation/m:entity[1]"/>
                                                                                            <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                                                                        </xsl:call-template>
                                                                                    </li>
                                                                                    <xsl:if test="/m:response/m:entity-types/m:type[@glossary-type = $relation/m:entity[1]/m:type/@type]">
                                                                                        <li>
                                                                                            <a target="84000-glossary" class="small">
                                                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $relation/@id, '&amp;view-mode=editor')"/>
                                                                                                <xsl:value-of select="'84000 Glossary'"/>
                                                                                            </a>
                                                                                        </li>
                                                                                    </xsl:if>
                                                                                    <li>
                                                                                        <xsl:call-template name="link">
                                                                                            <xsl:with-param name="link-text" select="'remove relation'"/>
                                                                                            <xsl:with-param name="link-class" select="'small'"/>
                                                                                            <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                                                            <xsl:with-param name="add-parameters" select="('form-action=merge-entities', 'predicate=removeRelation', 'entity-id=' || $entity/@xml:id, 'target-entity-id=' || $relation/@id)"/>
                                                                                        </xsl:call-template>
                                                                                    </li>
                                                                                </ul>
                                                                            </div>
                                                                            
                                                                        </div>
                                                                        
                                                                    </xsl:with-param>
                                                                    
                                                                    <xsl:with-param name="content">
                                                                        
                                                                        <hr class="sml-margin"/>
                                                                        
                                                                        <xsl:call-template name="entity-option-content">
                                                                            <xsl:with-param name="entity" select="m:entity"/>
                                                                            <xsl:with-param name="active-glossary-id" select="$loop-glossary-id"/>
                                                                            <xsl:with-param name="active-kb-id" select="''"/>
                                                                        </xsl:call-template>
                                                                        
                                                                    </xsl:with-param>
                                                                    
                                                                </xsl:call-template>
                                                                
                                                            </xsl:for-each>
                                                        </div>
                                                        
                                                    </xsl:when>
                                                    
                                                    <xsl:otherwise>
                                                        <p class="text-center text-muted small bottom-margin">
                                                            <xsl:value-of select="'No related entities found'"/>
                                                        </p>
                                                    </xsl:otherwise>
                                                    
                                                </xsl:choose>
                                                
                                            </xsl:with-param>
                                            
                                        </xsl:call-template>
                                        
                                        <!-- Panel: Similar entities -->
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="id" select="concat('entity-similar-', $loop-glossary-id)"/>
                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                            <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity-similar'"/>
                                            
                                            <xsl:with-param name="title">
                                                
                                                <xsl:variable name="count-similar-entities" select="count($loop-glossary/m:similar-entities/m:entity)"/>
                                                
                                                <span>
                                                    <xsl:value-of select="' ↳ '"/>
                                                </span>
                                                
                                                <span class="badge badge-notification">
                                                    <xsl:if test="$count-similar-entities eq 0">
                                                        <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="$count-similar-entities"/>
                                                </span>
                                                
                                                <span class="badge-text">
                                                    <xsl:choose>
                                                        <xsl:when test="$entity">
                                                            <xsl:choose>
                                                                <xsl:when test="$count-similar-entities eq 1">
                                                                    <xsl:value-of select="'similar entity un-resolved'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="'similar entities un-resolved'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:choose>
                                                                <xsl:when test="$count-similar-entities eq 1">
                                                                    <xsl:value-of select="'possible match'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="'possible matches'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                
                                            </xsl:with-param>
                                            
                                            <xsl:with-param name="content">
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <xsl:call-template name="entity-search">
                                                    <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                    <xsl:with-param name="match-mode">
                                                        <xsl:choose>
                                                            <xsl:when test="$entity">
                                                                <xsl:value-of select="'merge-entities'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'match-entity'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                                
                                            </xsl:with-param>
                                            
                                        </xsl:call-template>
                                        
                                    </xsl:if>
                                
                                </div>
                                
                            </div>
                        
                        </xsl:for-each>
                        
                    </xsl:if>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Glossary | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 Glossary'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="link">
        
        <xsl:param name="resource-id" as="xs:string" select="$request-resource-id"/>
        <xsl:param name="resource-type" as="xs:string" select="$request-resource-type"/>
        <xsl:param name="first-record" select="$request-first-record"/>
        <xsl:param name="max-records" select="$request-max-records"/>
        <xsl:param name="filter" select="$request-filter"/>
        <xsl:param name="search" select="$request-search"/>
        
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        <xsl:param name="add-parameters" as="xs:string*" select="()"/>
        
        <xsl:param name="link-class" as="xs:string" select="''"/>
        <xsl:param name="link-text" as="xs:string" required="yes"/>
        <xsl:param name="link-target" as="xs:string" select="'_self'"/>
        
        <a>
            
            <xsl:attribute name="href">
                <xsl:call-template name="link-href">
                    <xsl:with-param name="resource-id" select="$resource-id"/>
                    <xsl:with-param name="first-record" select="$first-record"/>
                    <xsl:with-param name="max-records" select="$max-records"/>
                    <xsl:with-param name="filter" select="$filter"/>
                    <xsl:with-param name="search" select="$search"/>
                    <xsl:with-param name="glossary-id" select="$glossary-id"/>
                    <xsl:with-param name="add-parameters" select="$add-parameters"/>
                </xsl:call-template>
            </xsl:attribute>
            
            <xsl:attribute name="class" select="$link-class"/>
            <xsl:attribute name="target" select="$link-target"/>
            
            <xsl:if test="$link-target eq '_self'">
                <xsl:attribute name="data-loading" select="'Loading page...'"/>
            </xsl:if>
            
            <xsl:choose>
                <xsl:when test="starts-with($link-text, 'fa-')">
                    <i>
                        <xsl:attribute name="class" select="concat('fa ',$link-text)"/>
                    </i>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link-text"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </a>
        
    </xsl:template>
    
    <xsl:template name="link-href">
        
        <xsl:param name="resource-id" as="xs:string" select="$request-resource-id"/>
        <xsl:param name="resource-type" as="xs:string" select="$request-resource-type"/>
        <xsl:param name="first-record" select="$request-first-record"/>
        <xsl:param name="max-records" select="$request-max-records"/>
        <xsl:param name="filter" select="$request-filter"/>
        <xsl:param name="search" select="$request-search"/>
        
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        <xsl:param name="add-parameters" as="xs:string*" select="()"/>
        
        <xsl:variable name="parameters" as="xs:string*">
            
            <!-- Maintain the state of the page -->
            <xsl:value-of select="concat('resource-id=', $resource-id)"/>
            <xsl:value-of select="concat('resource-type=', $resource-type)"/>
            <xsl:value-of select="concat('max-records=', $max-records)"/>
            <xsl:value-of select="concat('filter=', $filter)"/>
            <xsl:value-of select="concat('search=', $search)"/>
            
            <!-- If a specific glossary is requested then override the page -->
            <xsl:choose>
                <xsl:when test="$glossary-id gt ''">
                    <xsl:value-of select="concat('glossary-id=', $glossary-id)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('first-record=', $first-record)"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Make sure it reloads despite the anchor -->
            <xsl:value-of select="concat('timestamp=', current-dateTime())"/>
            
        </xsl:variable>
        
        <xsl:value-of select="concat('/edit-glossary.html?', string-join(($parameters, $add-parameters), '&amp;'),'#selected-entity')"/>
        
    </xsl:template>
    
    <xsl:template name="form">
        
        <xsl:param name="first-record" as="xs:integer" select="$request-first-record"/>
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        <xsl:param name="show-tab" as="xs:string" select="''"/>
        <xsl:param name="form-action" as="xs:string" select="''"/>
        <xsl:param name="form-content" as="node()*" required="yes"/>
        <xsl:param name="form-class" as="xs:string" select="'form-horizontal'"/>
        <xsl:param name="target-id" as="xs:string" select="'selected-entity'"/>
        
        <form method="post">
            
            <xsl:attribute name="action" select="concat('/edit-glossary.html#', $target-id)"/>
            <xsl:attribute name="class" select="$form-class"/>
            
            <!-- Maintain the state of the page -->
            <input type="hidden" name="resource-id" value="{ $request-resource-id }"/>
            <input type="hidden" name="resource-type" value="{ $request-resource-type }"/>
            <input type="hidden" name="first-record" value="{ $first-record }"/>
            
            <!-- Allow the option to override with a control in the form-content -->
            
            <xsl:if test="not($form-content//*[@name eq 'max-records'])">
                <input type="hidden" name="max-records" value="{ $request-max-records }"/>
            </xsl:if>
            <xsl:if test="not($form-content//*[@name eq 'filter'])">
                <input type="hidden" name="filter" value="{ $request-filter }"/>
            </xsl:if>
            <xsl:if test="not($form-content//*[@name eq 'search'])">
                <input type="hidden" name="search" value="{ $request-search }"/>
            </xsl:if>
            
            <xsl:if test="$form-action  gt ''">
                <input type="hidden" name="form-action" value="{ $form-action  }"/>
            </xsl:if>
            
            <xsl:if test="$glossary-id gt ''">
                <input type="hidden" name="glossary-id" value="{ $glossary-id }"/>
            </xsl:if>
            
            <xsl:if test="$show-tab gt ''">
                <input type="hidden" name="show-tab" value="{ $show-tab }"/>
            </xsl:if>
            
            <xsl:copy-of select="$form-content"/>
            
        </form>
        
    </xsl:template>
    
    <xsl:template name="glossary-form">
        
        <xsl:param name="glossary" as="element(m:item)?"/>
        
        <xsl:variable name="glossary-instance" select="$glossary/m:entity/m:instance[@type eq 'glossary-item'][@id eq $glossary/@id]"/>
        
        <input type="hidden" name="glossary-id" value="{ $glossary/@id }"/>
        
        <!-- Main term -->
        <xsl:variable name="main-term" select="$glossary/m:term[not(@type)][not(@xml:lang) or @xml:lang eq 'en'][1]"/>
        <xsl:variable name="element-id" select="string-join(('main-term', $glossary/@id), '-')"/>
        <div class="form-group">
            <label for="{ $element-id }" class="col-sm-2 control-label">
                <xsl:value-of select="'Main Term:'"/>
            </label>
            <div class="col-sm-2">
                <input type="text" class="form-control" value="Translation" disabled="disabled"/>
            </div>
            <div class="col-sm-6">
                <input type="text" name="main-term" id="{ $element-id }" value="{ $main-term/text() }" class="form-control"/>
            </div>
        </div>
        
        <!-- Equivalent terms -->
        <xsl:variable name="source-terms" select="$glossary/m:term[not(@type)][not(@xml:lang eq 'en')]"/>
        <xsl:variable name="source-terms-count" select="count($source-terms)"/>
        <div class="add-nodes-container">
            
            <!-- Add input for Sanskrit and Wylie if this is new -->
            <xsl:for-each select="(1 to (if($source-terms-count gt 0) then count($source-terms) else 2))">
                
                <xsl:variable name="index" select="."/>
                
                <xsl:variable name="element-lang" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="not($source-terms[$index]) and $index eq 1">
                            <xsl:value-of select="'Bo-Ltn'"/>
                        </xsl:when>
                        <xsl:when test="not($source-terms[$index]) and $index eq 2">
                            <xsl:value-of select="'Sa-Ltn'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$source-terms[$index]/@xml:lang"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:call-template name="text-input-with-lang">
                    <xsl:with-param name="text" select="$source-terms[$index]/text()"/>
                    <xsl:with-param name="lang" select="$element-lang"/>
                    <xsl:with-param name="id" select="($glossary/@id, 'new-glossary')[1]"/>
                    <xsl:with-param name="index" select="$index"/>
                    <xsl:with-param name="input-name" select="'term'"/>
                    <xsl:with-param name="label" select="'Equivalent:'"/>
                </xsl:call-template>
                
            </xsl:for-each>
            
            <!-- Add alternatives as Additional English terms -->
            <xsl:for-each select="$glossary/m:alternative">
                
                <xsl:call-template name="text-input-with-lang">
                    <xsl:with-param name="text" select="text()"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="id" select="parent::m:item/@id"/>
                    <xsl:with-param name="index" select="$source-terms-count + position()"/>
                    <xsl:with-param name="input-name" select="'term'"/>
                    <xsl:with-param name="label" select="'Equivalent:'"/>
                </xsl:call-template>
                
            </xsl:for-each>
            
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-2">
                    <a href="#add-nodes" class="add-nodes">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a term'"/>
                    </a>
                </div>
                <div class="col-sm-8">
                    <p class="text-muted small">
                        <xsl:value-of select="'Additional Translation terms will be added as alternative spellings'"/>
                    </p>
                </div>
            </div>
        </div>
        
        <!-- Type term|person|place|text -->
        <div class="form-group">
            
            <label for="{ concat('glossary-type-', $glossary/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Glossary type:'"/>
            </label>
            
            <div class="col-sm-2">
                <select name="glossary-type" id="{ concat('glossary-type-', $glossary/@id) }" class="form-control">
                    <option value="term">
                        <xsl:if test="$glossary[@type eq 'term']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Term'"/>
                    </option>
                    <option value="person">
                        <xsl:if test="$glossary[@type eq 'person']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Person'"/>
                    </option>
                    <option value="place">
                        <xsl:if test="$glossary[@type eq 'place']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Place'"/>
                    </option>
                    <option value="text">
                        <xsl:if test="$glossary[@type eq 'text']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Text'"/>
                    </option>
                </select>
            </div>
            
            <div class="col-sm-8">
                <p class="sml-margin top text-muted small">
                    <xsl:value-of select="'Standard hyphens added to Sanskrit strings will be converted to soft-hyphens when saved'"/>
                </p>
            </div>
            
        </div>
        
        <!-- Mode match|marked -->
        <div class="form-group">
            
            <label for="{ concat('glossary-mode-', $glossary/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Find instances:'"/>
            </label>
            
            <div class="col-sm-2">
                <div class="radio">
                    <label>
                        <input type="radio" name="glossary-mode" value="match" id="{ concat('glossary-mode-', $glossary/@id) }">
                            <xsl:if test="not($glossary) or $glossary[not(@mode eq 'marked')]">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Match'"/>
                    </label>
                </div>
            </div>
            
            <div class="col-sm-2">
                <div class="radio">
                    <label>
                        <input type="radio" name="glossary-mode" value="marked">
                            <xsl:if test="$glossary[@mode eq 'marked']">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Marked'"/>
                    </label>
                </div>
            </div>
            
        </div>
        
        <!-- Definition -->
        <xsl:variable name="definitions" select="$glossary/m:definition"/>
        <div class="form-group">
            
            <label for="{ concat('term-definition-text-', $glossary/@id, '-1') }" class="col-sm-2 control-label">
                <xsl:value-of select="'Definition:'"/>
            </label>
            
            <div class="col-sm-8 add-nodes-container">
                
                <xsl:for-each select="(1 to (if(count($definitions) gt 0) then count($definitions) else 1))">
                    <xsl:variable name="index" select="."/>
                    <xsl:variable name="element-name" select="concat('term-definition-text-', $index)"/>
                    <xsl:variable name="element-id" select="concat('term-definition-text-', $glossary/@id, '-', $index)"/>
                    <div class="sml-margin bottom add-nodes-group">
                        <textarea name="{ $element-name }" id="{ $element-id }" class="form-control">
                            
                            <xsl:variable name="definition">
                                <unescaped xmlns="http://read.84000.co/ns/1.0">
                                    <xsl:sequence select="$definitions[$index]/node()"/>
                                </unescaped>
                            </xsl:variable>
                            
                            <xsl:variable name="definition-escaped">
                                <xsl:apply-templates select="$definition"/>
                            </xsl:variable>
                            
                            <xsl:attribute name="rows" select="ops:textarea-rows($definition-escaped, 2, 105)"/>
                                
                            <xsl:sequence select="$definition-escaped/m:escaped/data()"/>
                            
                        </textarea>
                    </div>
                </xsl:for-each>
                
                <div class="sml-margin top">
                    <a href="#add-nodes" class="add-nodes">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a paragraph'"/>
                    </a>
                </div>
                
            </div>
            
        </div>
        
        <!-- Glossary definition tag reference -->
        <div class="form-group">
            <div class="col-sm-12">
                <xsl:call-template name="definition-tag-reference">
                    <xsl:with-param name="element-id" select="($glossary/@id, 'new-glossary')[1]"/>
                </xsl:call-template>
            </div>
        </div>
        
        <!-- Include entity definition -->
        <!-- Submit button -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label" for="use-definition">
                <xsl:value-of select="'Definition display:'"/>
            </label>
            
            <div class="col-sm-6">
                <select name="use-definition" id="use-definition" class="form-control">
                    <option value="">
                        <xsl:value-of select="'Display glossary entry definition'"/>
                    </option>
                    <xsl:if test="$glossary/m:entity/m:content[@type eq 'glossary-definition']">
                        <option value="replace">
                            <xsl:if test="$glossary-instance[@use-definition eq 'replace']">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Display shared entity definition'"/>
                        </option>
                        <option value="after">
                            <xsl:if test="$glossary-instance[@use-definition eq 'after']">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Display both'"/>
                        </option>
                    </xsl:if>
                </select>
            </div>
            
            <div class="col-sm-2">
                <button type="submit" class="btn btn-primary pull-right" data-loading="Applying changes...">
                    <xsl:value-of select="'Apply changes'"/>
                </button>
            </div>
            
        </div>
        
    </xsl:template>
    
    <xsl:template name="entity-search">
        
        <xsl:param name="loop-glossary" as="element(m:item)"/>
        <xsl:param name="match-mode" as="xs:string" required="yes"/>
        
        <!-- Form: search for similar entities -->
        <xsl:call-template name="form">
            
            <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
            <xsl:with-param name="show-tab" select="'similar'"/>
            <xsl:with-param name="form-class" select="'form-horizontal bottom-margin'"/>
            <xsl:with-param name="target-id" select="concat('entity-search-', $loop-glossary/@id)"/>
            <xsl:with-param name="form-content">
                
                <div class="input-group">
                    <xsl:attribute name="id" select="concat('entity-search-', $loop-glossary/@id)"/>
                    <input type="text" name="similar-search" class="form-control" id="similar-search" value="{ $request-similar-search }" placeholder="Widen search..."/>
                    <div class="input-group-btn">
                        <button type="submit" class="btn btn-primary" data-loading="Searching for similar terms...">
                            <i class="fa fa-search"/>
                        </button>
                    </div>
                </div>
                
            </xsl:with-param>
        </xsl:call-template>
        
        <!-- List similar entities -->
        <xsl:choose>
            
            <xsl:when test="$loop-glossary/m:similar-entities[m:entity]">
                
                <xsl:call-template name="glossary-terms">
                    <xsl:with-param name="item" select="$loop-glossary"/>
                </xsl:call-template>
                
                <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                    
                    <xsl:variable name="id" select="concat('accordion-glossary-', $loop-glossary/@id, '-entities')"/>
                    <xsl:attribute name="id" select="$id"/>
                    
                    <xsl:for-each select="$loop-glossary/m:similar-entities/m:entity">
                        
                        <xsl:call-template name="entity-option">
                            <xsl:with-param name="entity" select="."/>
                            <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                            <xsl:with-param name="match-mode" select="$match-mode"/>
                            <xsl:with-param name="entity-search-form-id" select="$id"/>
                        </xsl:call-template>
                        
                    </xsl:for-each>
                    
                </div>
                
            </xsl:when>
            
            <xsl:otherwise>
                <p class="text-center text-muted small bottom-margin">
                    <xsl:value-of select="'No similar glossary items found in other shared entities'"/>
                </p>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="entity-option">
        
        <xsl:param name="entity" as="element(m:entity)" required="yes"/>
        <xsl:param name="loop-glossary" as="element(m:item)" required="yes"/>
        <xsl:param name="match-mode" as="xs:string" required="yes"/>
        <xsl:param name="entity-search-form-id" as="xs:string" required="yes"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="concat('#accordion-glossary-', $loop-glossary/@id, '-entities')"/>
            <xsl:with-param name="id" select="concat('glossary-', $loop-glossary/@id, '-', $entity/@xml:id)"/>
            
            <xsl:with-param name="title">
                
                <!-- Form: resolving entites -->
                <xsl:call-template name="form">
                    <xsl:with-param name="form-action" select="if(not($loop-glossary[m:entity])) then 'match-entity' else 'merge-entities'"/>
                    <xsl:with-param name="form-class" select="'form-inline'"/>
                    <xsl:with-param name="show-tab" select="'similar'"/>
                    <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
                    <xsl:with-param name="target-id" select="$entity-search-form-id"/>
                    <xsl:with-param name="form-content">
                        
                        <input type="hidden" name="similar-search" value="{ $request-similar-search }"/>
                        
                        <xsl:call-template name="entity-resolve-form-input">
                            <xsl:with-param name="entity" select="$loop-glossary/m:entity[1]"/>
                            <xsl:with-param name="target-entity" select="$entity"/>
                            <xsl:with-param name="predicates" select="/m:response/m:entity-predicates//m:predicate"/>
                            <xsl:with-param name="target-entity-label">
                                
                                <ul class="list-inline inline-dots no-bottom-margin">
                                    
                                    <li class="small">
                                        <span>
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="common:lang-class($entity/m:label[1]/@xml:lang)"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="common:limit-str($entity/m:label[1] ! normalize-space(.), 80)"/>
                                        </span>
                                    </li>
                                    
                                    <li>
                                        <xsl:call-template name="entity-type-labels">
                                            <xsl:with-param name="entity" select="$entity"/>
                                            <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                        </xsl:call-template>
                                    </li>
                                    
                                    <li class="small">
                                        <xsl:value-of select="concat('Groups ', count($entity/m:instance), ' elements')"/>
                                    </li>
                                    
                                </ul>
                                
                            </xsl:with-param>
                        </xsl:call-template>
                        
                    </xsl:with-param>
                </xsl:call-template>
                
            </xsl:with-param>
            
            <xsl:with-param name="content">
                
                <xsl:call-template name="entity-option-content">
                    <xsl:with-param name="entity" select="$entity"/>
                    <xsl:with-param name="active-glossary-id" select="$loop-glossary/@id"/>
                    <xsl:with-param name="active-kb-id" select="''"/>
                </xsl:call-template>
                
            </xsl:with-param>
            
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="entity-form">
        
        <xsl:param name="loop-glossary"/>
        
        <xsl:call-template name="form">
            
            <xsl:with-param name="show-tab" select="'entity'"/>
            <xsl:with-param name="form-action" select="'update-entity'"/>
            <xsl:with-param name="form-class" select="'form-horizontal'"/>
            <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
            <xsl:with-param name="target-id" select="concat('expand-item-entity-', $loop-glossary/@id, '-detail')"/>
            
            <xsl:with-param name="form-content">
                
                <xsl:variable name="default-label" select="($loop-glossary/m:term[@xml:lang eq'Sa-Ltn'], $loop-glossary/m:term[@xml:lang eq 'bo'], $loop-glossary/m:term[@xml:lang])[1]"/>
                
                <xsl:call-template name="entity-form-input">
                    <xsl:with-param name="entity" select="$loop-glossary/m:entity"/>
                    <xsl:with-param name="context-id" select="$loop-glossary/@id"/>
                    <xsl:with-param name="default-label-text" select="$default-label/text()"/>
                    <xsl:with-param name="default-label-lang" select="$default-label/@xml:lang"/>
                    <xsl:with-param name="default-entity-type" select="concat('eft-', $loop-glossary/@type)"/>
                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                    <xsl:with-param name="entity-flags" select="/m:response/m:entity-flags/m:flag"/>
                    <xsl:with-param name="instance" select="$loop-glossary/m:entity/m:instance[@id eq $loop-glossary/@id]"/>
                </xsl:call-template>
                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:location">
        
        <xsl:variable name="location-id" select="@id" as="xs:string"/>
        <xsl:variable name="glossary-item" select="parent::m:expressions/parent::m:item"/>
        <xsl:variable name="cache-location" select="$glossary-cache/m:gloss[@id eq $glossary-item/@id]/m:location[@id = $location-id]"/>
        
        <div class="item tei-parser editor-mode rw-full-width small pad">
            
            <xsl:if test="not($cache-location)">
                <xsl:attribute name="class" select="'item tei-parser editor-mode translation rw-full-width small pad flagged'"/>
            </xsl:if>
            
            <xsl:apply-templates select="xhtml:*"/>
            
        </div>
        
    </xsl:template>
    
    <!-- Copy xhtml nodes -->
    <xsl:template match="xhtml:*">
        
        <xsl:variable name="node" select="."/>
        
        <xsl:choose>
            
            <!-- Special case for the first element in the first div of a location -->
            <xsl:when test="$node[parent::xhtml:div[parent::m:location[xhtml:div[1][xhtml:*[1] = $node]]]]">
                <xsl:choose>
                    
                    <!-- It's a .gtr -> add a ref -->
                    <xsl:when test="$node[contains(@class, 'gtr')]">
                        <xsl:copy>
                            <xsl:copy-of select="$node/@*"/>
                            <xsl:apply-templates select="$node/node()"/>
                            <xsl:apply-templates select="$node/parent::xhtml:div/parent::m:location/m:preceding-ref/xhtml:*"/>
                        </xsl:copy>
                    </xsl:when>
                    
                    <!-- It's the first node but not a .gtr -> so add .gtr with ref -->
                    <xsl:otherwise>
                        
                        <div>
                            <xsl:attribute name="class" select="'gtr'"/>
                            <xsl:apply-templates select="$node/parent::xhtml:div/parent::m:location/m:preceding-bookmark/xhtml:*"/>
                            <xsl:apply-templates select="$node/parent::xhtml:div/parent::m:location/m:preceding-ref/xhtml:*"/>
                        </div>
                        
                        <xsl:copy>
                            <xsl:copy-of select="$node/@*"/>
                            <xsl:apply-templates select="$node/node()"/>
                        </xsl:copy>
                        
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <!-- Copy xhtml:* by default -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="$node/@*"/>
                    <xsl:apply-templates select="$node/node()"/>
                </xsl:copy>
            </xsl:otherwise>
            
        </xsl:choose>
        
        
    </xsl:template>
    
    <!-- Localise links in html -->
    <xsl:template match="xhtml:a">
        
        <xsl:variable name="link" select="."/>
        <xsl:variable name="glossary-item" select="ancestor::m:item[@id][1]"/>
        
        <xsl:element name="a">
            
            <xsl:copy-of select="@*[not(name(.) = ('href', 'class', 'data-bookmark', 'target', 'title'))]"/>
            
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$link[@data-glossary-id]">
                        <xsl:call-template name="link-href">
                            <xsl:with-param name="glossary-id" select="$link/@data-glossary-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$link[@data-bookmark]">
                        <xsl:value-of select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-glossary-location]">
                        <xsl:value-of select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-pointer-type eq 'id']">
                        <xsl:value-of select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-ref]">
                        <xsl:variable name="link-href-tokenized" select="tokenize($link/@href, '#')"/>
                        <xsl:variable name="link-href-query" select="$link-href-tokenized[1]"/>
                        <xsl:variable name="link-href-hash" select="if(count($link-href-tokenized) gt 1) then concat('#', $link-href-tokenized[last()]) else ()"/>
                        <xsl:value-of select="concat($reading-room-path, $link-href-query, if(contains($link-href-query, '?')) then '&amp;' else '?', 'highlight=', string-join($glossary-item/m:term[@xml:lang eq 'bo'], ','), $link-href-hash)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$link/@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="class">
                <xsl:variable name="local-class" select="string-join(tokenize(@class, '\s+')[not(. = ('pop-up', 'log-click'))], ' ')"/>
                <xsl:choose>
                    <xsl:when test="$glossary-item[@id eq $link/@data-glossary-id]">
                        <xsl:value-of select="string-join(($local-class, 'mark'), ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$local-class"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="$link[@data-glossary-id]">
                        <xsl:value-of select="'_self'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$request-resource-id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:sequence select="node()"/>
            
        </xsl:element>
        
    </xsl:template>
    
</xsl:stylesheet>