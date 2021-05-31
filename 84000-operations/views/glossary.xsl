<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="request-resource-id" select="/m:response/m:request/@resource-id"/>
    <xsl:variable name="request-first-record" select="common:enforce-integer(/m:response/m:request/@first-record)" as="xs:integer"/>
    <xsl:variable name="request-max-records" select="common:enforce-integer(/m:response/m:request/@max-records)" as="xs:integer"/>
    <xsl:variable name="request-filter" select="/m:response/m:request/@filter"/>
    <xsl:variable name="request-search" select="/m:response/m:request/m:search[1]/text()"/>
    <xsl:variable name="request-similar-search" select="/m:response/m:request/m:similar-search[1]/text()"/>
    
    <xsl:variable name="request-glossary-id" select="/m:response/m:request/@glossary-id"/>
    <xsl:variable name="request-item-tab" select="/m:response/m:request/@item-tab"/>
    
    <xsl:variable name="text" select="/m:response/m:translation[1]"/>
    <xsl:variable name="glossary" select="/m:response/m:glossary[1]"/>
    <xsl:variable name="glossary-cache" select="/m:response/m:glossary-cache[1]"/>
    <xsl:variable name="text-id" select="$text/@id"/>
    <xsl:variable name="toh-key" select="$text/m:source/@key"/>
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
                    <div class="center-vertical full-width sml-margin bottom">
                        
                        <!-- Text title / link -->
                        <div class="h3">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $toh-key, '.html?view-mode=editor')"/>
                                <xsl:value-of select="$text/m:source/m:toh"/>
                                <xsl:value-of select="' / '"/>
                                <xsl:value-of select="common:limit-str($text/m:titles/m:title[@xml:lang eq 'en'][1], 80)"/>
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
                    
                    <!-- Version row -->
                    <ul class="list-inline inline-dots  sml-margin bottom">
                        
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
                                        <xsl:when test="$glossary[@tei-version-cached]">
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
                            <a target="_self" class="underline">
                                <xsl:attribute name="href" select="concat('glossary.html?resource-id=', $request-resource-id, '&amp;form-action=cache-locations-all')"/>
                                <span class="small">
                                    <xsl:value-of select="'Re-cache locations of all items'"/>
                                </span>
                            </a>
                        </li>
                        
                        <li>
                            <a target="_self" class="underline">
                                <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $request-resource-id)"/>
                                <span class="small">
                                    <xsl:value-of select="'Edit headers'"/>
                                </span>
                            </a>
                        </li>
                        
                    </ul>
                    
                    <!-- Filter / Pagination -->
                    <xsl:if test="not($request-filter eq 'blank-form')">
                        <div class="center-vertical full-width sml-margin bottom">
                            <div>
                                <xsl:call-template name="form">
                                    <xsl:with-param name="form-class" select="'form-inline'"/>
                                    <xsl:with-param name="first-record" select="1"/>
                                    <xsl:with-param name="form-content">
                                        <div class="input-group">
                                            
                                            <div class="input-group-addon">
                                                <xsl:value-of select="'Filter'"/>
                                            </div>
                                            
                                            <select name="filter" class="form-control">
                                                <option value="">
                                                    <xsl:value-of select="'All glossary entries'"/>
                                                </option>
                                                <option value="missing-entities">
                                                    <xsl:if test="$request-filter eq 'missing-entities'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'No shared entity'"/>
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
                                                <xsl:value-of select="'Records per page:'"/>
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
                                    </xsl:with-param>
                                </xsl:call-template>
                            </div>
                            
                            <div>
                                <xsl:copy-of select="common:pagination(common:enforce-integer($glossary/@first-record), common:enforce-integer($glossary/@max-records), common:enforce-integer($glossary/@count-records), concat('glossary.html?resource-id=', $request-resource-id, '&amp;filter=', $request-filter, '&amp;search=', $request-search), '')"/>
                            </div>
                            
                        </div>
                    </xsl:if>
                    
                    <!-- Form for adding a new entry -->
                    <xsl:if test="$request-filter eq 'blank-form'">
                        <hr/>
                        <xsl:call-template name="form">
                            
                            <xsl:with-param name="form-action" select="'update-glossary'"/>
                            <xsl:with-param name="form-content">
                                
                                <!-- Go to the normal list on adding a new item -->
                                <input type="hidden" name="filter" value="''"/>
                                
                                <xsl:call-template name="glossary-form"/>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                    </xsl:if>
                    
                    <!-- Loop through each item -->
                    <xsl:for-each select="$glossary/m:item">
                        
                        <xsl:variable name="loop-glossary" select="."/>
                        <xsl:variable name="loop-glossary-id" select="($loop-glossary/@id, 'new-glossary')[1]"/>
                        <xsl:variable name="loop-glossary-cache" select="$glossary-cache/m:gloss[@id eq $loop-glossary-id]"/>
                        <xsl:variable name="locations-cached" select="$loop-glossary/m:expressions/m:location[@id = $loop-glossary-cache/m:location/@id]"/>
                        <xsl:variable name="locations-not-cached" select="$loop-glossary/m:expressions/m:location[not(@id = $locations-cached/@id)]"/>
                        
                        <div>
                            
                            <!-- Set id to support scroll to selected item -->
                            <xsl:if test="$loop-glossary[@active-item eq 'true']">
                                <xsl:attribute name="id" select="'selected-entity'"/>
                            </xsl:if>
                            
                            <!-- Title -->
                            <h4 class="sml-margin bottom">
                                
                                <!-- Term -->
                                <span class="text-danger">
                                    <xsl:value-of select="m:term[@xml:lang eq 'en']"/>
                                </span>
                                
                                <!-- Reading Room link -->
                                <span class="small">
                                    <xsl:value-of select="' / '"/>
                                    <a target="reading-room">
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $toh-key, '.html?view-mode=editor', '#', $loop-glossary-id)"/>
                                        <xsl:value-of select="$loop-glossary-id"/>
                                    </a>
                                </span>
                                
                                <!-- link to Combined glossary -->
                                <xsl:if test="$loop-glossary[m:entity]">
                                    <span class="small">
                                        <xsl:value-of select="' / '"/>
                                        <a target="84000-glossary">
                                            <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $loop-glossary/m:entity/@xml:id)"/>
                                            <xsl:value-of select="'glossary'"/>
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
                                        <xsl:with-param name="filter" select="''"/>
                                    </xsl:call-template>
                                </span>
                                
                            </h4>
                            
                            <!-- Definition -->
                            <xsl:if test="$loop-glossary/m:definition[node()]">
                                <div class="sml-margin bottom collapse-one-line">
                                    <xsl:call-template name="definition">
                                        <xsl:with-param name="item" select="$loop-glossary"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:if>
                            
                            <!-- Accordion -->
                            <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                
                                <xsl:attribute name="id" select="concat('accordion-', $loop-glossary-id)"/>
                                
                                <!-- Panel: for editing the glossary item-->
                                <xsl:call-template name="expand-item">
                                    
                                    <xsl:with-param name="id" select="concat('glossary-form-',$loop-glossary-id)"/>
                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                    <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-item-tab eq 'glossary-form'"/>
                                    
                                    <xsl:with-param name="title">
                                        
                                        <xsl:call-template name="terms">
                                            <xsl:with-param name="item" select="."/>
                                            <xsl:with-param name="list-class" select="'no-bottom-margin'"/>
                                        </xsl:call-template>
                                        
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="content">
                                        
                                        <hr class="sml-margin"/>
                                        
                                        <xsl:call-template name="form">
                                            
                                            <xsl:with-param name="tab-id" select="'glossary-form'"/>
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
                                <xsl:call-template name="expand-item">
                                    
                                    <xsl:with-param name="id" select="concat('expressions-',$loop-glossary-id)"/>
                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                    <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-item-tab eq 'expressions'"/>
                                    
                                    <xsl:with-param name="title">
                                        <ul class="list-inline inline-dots no-bottom-margin">
                                            <li>
                                                <xsl:value-of select="concat('Locations: ', count($loop-glossary/m:expressions/m:location), ' ')"/>
                                            </li>
                                            <xsl:choose>
                                                <xsl:when test="not($loop-glossary-cache)">
                                                    <li>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="'Not cached'"/>
                                                        </span>
                                                    </li>
                                                </xsl:when>
                                                <xsl:when test="$locations-not-cached">
                                                    <li>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="concat(count($locations-not-cached), ' not cached')"/>
                                                        </span>
                                                    </li>
                                                </xsl:when>
                                            </xsl:choose>
                                        </ul>
                                        
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="content">
                                        
                                        <xsl:call-template name="form">
                                            
                                            <xsl:with-param name="tab-id" select="'expressions'"/>
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
                                                                    
                                                                    <div>
                                                                        <p class="small text-muted text-center">
                                                                            <xsl:value-of select="'Once you have confirmed that these are the valid instances of this glossary entry, please select the option to cache the locations.'"/>
                                                                            <br/>
                                                                            <xsl:value-of select="'An instance will not appear in the Reading Room until the location is cached.'"/>
                                                                        </p>
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
                                                        <hr/>
                                                        <p class="text-center text-muted small bottom-margin">
                                                            <xsl:value-of select="'No instances of this glossary term found in this text!'"/>
                                                        </p>
                                                    </xsl:otherwise>
                                                    
                                                </xsl:choose>
                                                
                                            </xsl:with-param>
                                        </xsl:call-template>
                                        
                                    </xsl:with-param>
                                
                                </xsl:call-template>
                                
                                <!-- Panel: View the entity -->
                                <xsl:call-template name="expand-item">
                                    
                                    <xsl:with-param name="id" select="concat('entity-', $loop-glossary-id)"/>
                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                    <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-item-tab eq 'entity'"/>
                                    
                                    <!-- Entity panel title -->
                                    <xsl:with-param name="title">
                                        
                                        <ul class="list-inline inline-dots no-bottom-margin">
                                            <xsl:choose>
                                                <xsl:when test="$loop-glossary[m:entity]">
                                                    <li>
                                                        <xsl:value-of select="'Entity: '"/>
                                                        <span>
                                                            <xsl:attribute name="class">
                                                                <xsl:value-of select="common:lang-class($loop-glossary/m:entity/m:label[1]/@xml:lang)"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="common:limit-str($loop-glossary/m:entity/m:label[1] ! fn:normalize-space(.), 150)"/>
                                                        </span>
                                                    </li>
                                                    <li class="small">
                                                        <xsl:value-of select="concat('ID: ', $loop-glossary/m:entity/@xml:id)"/>
                                                    </li>
                                                    <li>
                                                        <xsl:call-template name="entity-type-labels">
                                                            <xsl:with-param name="entity" select="$loop-glossary/m:entity"/>
                                                        </xsl:call-template>
                                                    </li>
                                                    <li class="small">
                                                        <xsl:value-of select="concat('Groups ', count($loop-glossary/m:entity/m:instance[@type eq 'glossary-item']), ' glossaries ')"/>
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
                                            <xsl:if test="$loop-glossary/m:similar-entities[m:entity]">
                                                <li>
                                                    <span class="label label-warning">
                                                        <xsl:value-of select="concat(count($loop-glossary/m:similar-entities/m:entity), ' possible matching entities')"/>
                                                    </span>
                                                </li>
                                            </xsl:if>
                                        </ul>
                                        
                                    </xsl:with-param>
                                    
                                    <!-- Entity panel content -->
                                    <xsl:with-param name="content">
                                        
                                        <hr class="sml-margin"/>
                                        
                                        <xsl:choose>
                                            
                                            <!-- When there is an entity  -->
                                            <xsl:when test="$loop-glossary[m:entity]">
                                                
                                                <!-- Warning -->
                                                <div class="row">
                                                    <div class="col-sm-offset-2 col-sm-8">
                                                        <div class="alert alert-info">
                                                            <p class="small text-center">
                                                                <xsl:value-of select="'NOTE: Updates to this shared entity must apply for all glossaries matched to this entity!'"/>
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Form: for editing the shared entity -->
                                                <xsl:call-template name="entity-form">
                                                    <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                </xsl:call-template>
                                                
                                                <!-- List matched glossaries -->
                                                <div class="row">
                                                    <div class="col-sm-offset-2 col-sm-8">
                                                        
                                                        <hr/>
                                                        
                                                        <xsl:choose>
                                                            
                                                            <xsl:when test="$loop-glossary/m:entity-glossaries/m:item[not(@id = $loop-glossary-id)]">
                                                                
                                                                <section class="preview">
                                                                    
                                                                    <xsl:variable name="section-id" select="concat('glossary-items-text-group-', $loop-glossary/@id)"/>
                                                                    <xsl:attribute name="id" select="$section-id"/>
                                                                    
                                                                    <div>
                                                                        <p class="text-center text-muted uppercase">
                                                                            <xsl:value-of select="concat('~ Groups ', count($loop-glossary/m:entity/m:instance[@type eq 'glossary-item']), ' glossaries ~')"/>
                                                                        </p>
                                                                    </div>
                                                                    
                                                                    <xsl:for-each-group select="$loop-glossary/m:entity-glossaries/m:item" group-by="m:text/@id">
                                                                        
                                                                        <xsl:sort select="m:text[1]/@id"/>
                                                                        
                                                                        <xsl:call-template name="glossary-items-text-group">
                                                                            <xsl:with-param name="glossary-items" select="current-group()"/>
                                                                            <xsl:with-param name="active-glossary-id" select="$loop-glossary/@id"/>
                                                                        </xsl:call-template>
                                                                        
                                                                    </xsl:for-each-group>
                                                                    
                                                                    <xsl:call-template name="preview-controls">
                                                                        <xsl:with-param name="section-id" select="$section-id"/>
                                                                    </xsl:call-template>
                                                                    
                                                                </section>
                                                                
                                                                
                                                            </xsl:when>
                                                            
                                                            <xsl:otherwise>
                                                                
                                                                <div>
                                                                    <p class="text-center text-muted small bottom-margin">
                                                                        <xsl:value-of select="'There are currently no other glossary items matched to this entity'"/>
                                                                    </p>
                                                                </div>
                                                                
                                                            </xsl:otherwise>
                                                            
                                                        </xsl:choose>
                                                        
                                            
                                                    </div>
                                                </div>
                                                
                                                <!-- Search for matching entities -->
                                                <div class="row top-margin">
                                                    <div class="col-sm-offset-2 col-sm-8">
                                                        
                                                        <div class="text-center text-muted uppercase bottom-margin">
                                                            <xsl:value-of select="concat('~ ', count($loop-glossary/m:similar-entities/m:entity), ' possible matching entities ~')"/>
                                                        </div>
                                                        
                                                        <xsl:call-template name="entity-search">
                                                            <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                            <xsl:with-param name="match-mode" select="'merge-entities'"/>
                                                        </xsl:call-template>
                                                    </div>
                                                </div>
                                                
                                            </xsl:when>
                                            
                                            <!-- When there is no entity -->
                                            <xsl:otherwise>
                                                
                                                <!-- Search for matching entities -->
                                                <div class="row">
                                                    <div class="col-sm-offset-2 col-sm-8">
                                                        
                                                        <div class="text-center text-muted uppercase top-margin bottom-margin">
                                                            <xsl:value-of select="'~ Match an existing entity ~'"/>
                                                        </div>
                                                        
                                                        <xsl:call-template name="entity-search">
                                                            <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                            <xsl:with-param name="match-mode" select="'match-glossary'"/>
                                                        </xsl:call-template>
                                                        
                                                    </div>
                                                </div>
                                                
                                                <!-- Warning -->
                                                <div class="row">
                                                    <div class="col-sm-offset-2 col-sm-8">
                                                        <div class="alert alert-danger">
                                                            <p class="small text-center">
                                                                <xsl:value-of select="'Please search thoroughly for an existing entity before creating a new one!'"/>
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Form: for adding the shared entity -->
                                                <div class="text-center text-muted uppercase bottom-margin">
                                                    <xsl:value-of select="'~ or create a new shared entity ~'"/>
                                                </div>
                                                <xsl:call-template name="entity-form">
                                                    <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                </xsl:call-template>
                                                
                                            </xsl:otherwise>
                                            
                                        </xsl:choose>
                                        
                                    </xsl:with-param>
                                
                                </xsl:call-template>
                                
                            </div>
                            
                        </div>
                    
                    </xsl:for-each>
                    
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
        
        <xsl:param name="resource-id" as="xs:string" select="$text-id"/>
        <xsl:param name="first-record" select="$request-first-record"/>
        <xsl:param name="max-records" select="$request-max-records"/>
        <xsl:param name="filter" select="$request-filter"/>
        <xsl:param name="search" select="$request-search"/>
        
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        
        <xsl:param name="link-class" as="xs:string" select="''"/>
        <xsl:param name="link-text" as="xs:string" required="yes"/>
        <xsl:param name="link-target" as="xs:string" select="'_self'"/>
        
        <a>
            
            <xsl:call-template name="link-href">
                <xsl:with-param name="resource-id" select="$resource-id"/>
                <xsl:with-param name="first-record" select="$first-record"/>
                <xsl:with-param name="max-records" select="$max-records"/>
                <xsl:with-param name="filter" select="$filter"/>
                <xsl:with-param name="search" select="$search"/>
                <xsl:with-param name="glossary-id" select="$glossary-id"/>
            </xsl:call-template>
            
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
        
        <xsl:param name="resource-id" as="xs:string" select="$text-id"/>
        <xsl:param name="first-record" select="$request-first-record"/>
        <xsl:param name="max-records" select="$request-max-records"/>
        <xsl:param name="filter" select="$request-filter"/>
        <xsl:param name="search" select="$request-search"/>
        
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        
        <xsl:variable name="parameters" as="xs:string*">
            
            <!-- Maintain the state of the page -->
            <xsl:value-of select="concat('resource-id=', $resource-id)"/>
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
            <xsl:value-of select="concat('reload=', current-dateTime())"/>
            
        </xsl:variable>
        
        <xsl:attribute name="href">
            <xsl:value-of select="concat('/glossary.html?', string-join($parameters, '&amp;'),'#selected-entity')"/>
        </xsl:attribute>
        
    </xsl:template>
    
    <xsl:template name="form">
        
        <xsl:param name="first-record" as="xs:integer" select="$request-first-record"/>
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        <xsl:param name="tab-id" as="xs:string" select="''"/>
        <xsl:param name="form-action" as="xs:string" select="''"/>
        <xsl:param name="form-content" as="node()*" required="yes"/>
        <xsl:param name="form-class" as="xs:string" select="'form-horizontal'"/>
        <xsl:param name="target-id" as="xs:string" select="'selected-entity'"/>
        
        <form method="post">
            
            <xsl:attribute name="action" select="concat('/glossary.html#', $target-id)"/>
            <xsl:attribute name="class" select="$form-class"/>
            
            <!-- Maintain the state of the page -->
            <input type="hidden" name="resource-id" value="{ $text-id }"/>
            <input type="hidden" name="first-record" value="{ $first-record }"/>
            
            <!-- Give the option to override with a control in the form-content -->
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
            
            <xsl:if test="$tab-id gt ''">
                <input type="hidden" name="tab-id" value="{ $tab-id }"/>
            </xsl:if>
            
            <xsl:copy-of select="$form-content"/>
            
        </form>
        
    </xsl:template>
    
    <xsl:template name="glossary-form">
        
        <xsl:param name="glossary" as="element(m:item)?"/>
        
        <input type="hidden" name="glossary-id" value="{ $glossary/@id }"/>
        
        <!-- Main term -->
        <xsl:variable name="main-term" select="$glossary/m:term[not(@type)][not(@xml:lang) or @xml:lang eq 'en'][1]"/>
        <xsl:variable name="element-id" select="concat('main-term-', $glossary/@id)"/>
        <div class="form-group">
            <label for="{ $element-id }" class="col-sm-2 control-label">
                <xsl:value-of select="'Main Term:'"/>
            </label>
            <div class="col-sm-2">
                <input type="text" class="form-control" value="English" disabled="disabled"/>
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
                        <xsl:value-of select="'Additional English terms will be added as alternative spellings'"/>
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
                        <textarea name="{ $element-name }" id="{ $element-id }" class="form-control" rows="3">
                            
                            <xsl:if test="count($definitions) gt 1">
                                <xsl:attribute name="rows" select="2"/>
                            </xsl:if>
                            
                            <xsl:variable name="definition">
                                <div xmlns="http://www.tei-c.org/ns/1.0" type="unescaped">
                                    <xsl:sequence select="$definitions[$index]/node()"/>
                                </div>
                            </xsl:variable>
                            
                            <xsl:variable name="definition-escaped">
                                <xsl:apply-templates select="$definition"/>
                            </xsl:variable>
                                
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
        <xsl:call-template name="definition-tag-reference">
            <xsl:with-param name="element-id" select="($glossary/@id, 'new-glossary')[1]"/>
        </xsl:call-template>
        
        <!-- Submit button -->
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-8">
                <button type="submit" class="btn btn-primary pull-right" data-loading="Applying changes...">
                    <xsl:value-of select="'Apply changes'"/>
                </button>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="glossary-items-text-group">
        
        <xsl:param name="glossary-items" as="element(m:item)*"/>
        <xsl:param name="active-glossary-id" as="xs:string"/>
        
        <fieldset>
            
            <!-- Text -->
            <legend>
                <xsl:value-of select="concat('In ', $glossary-items[1]/m:text/m:toh, ' / ', common:limit-str($glossary-items[1]/m:text/m:title, 80))"/>
            </legend>
            
            <div class="div-list no-border-top no-padding-top">
                <xsl:for-each select="$glossary-items">
                    <xsl:variable name="item" select="."/>
                    <div class="item">
                        <div class="item-row">
                            <!-- Main term -->
                            <span class="text-danger">
                                <xsl:value-of select="$item/m:term[@xml:lang eq 'en'][1]"/>
                            </span>
                            <!-- Link to Reading Room -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <a target="reading-room" class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $item/m:text/@id, '.html#', @id)"/>
                                    <xsl:value-of select="@id"/>
                                </a>
                            </span>
                            <!-- A link to switch to this item -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <xsl:choose>
                                    <xsl:when test="not(@id eq $active-glossary-id)">
                                        <xsl:call-template name="link">
                                            <xsl:with-param name="resource-id" select="$item/m:text/@id"/>
                                            <xsl:with-param name="glossary-id" select="$item/@id"/>
                                            <xsl:with-param name="link-text" select="'edit'"/>
                                            <xsl:with-param name="link-class" select="'small'"/>
                                            <xsl:with-param name="link-target" select="concat('glossary-', $item/m:text/@id)"/>
                                            <xsl:with-param name="max-records" select="1"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <small class="text-muted">
                                            <xsl:value-of select="'editing'"/>
                                        </small>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </div>
                        <div class="item-row">
                            <!-- Terms -->
                            <xsl:call-template name="terms">
                                <xsl:with-param name="item" select="."/>
                                <xsl:with-param name="list-class" select="'no-bottom-margin'"/>
                            </xsl:call-template>
                        </div>
                        <div class="item-row">
                            <!-- Definition -->
                            <xsl:call-template name="definition">
                                <xsl:with-param name="item" select="."/>
                            </xsl:call-template>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
            
        </fieldset>
        
        
    </xsl:template>
    
    <xsl:template name="terms">
        
        <xsl:param name="item" as="element(m:item)"/>
        <xsl:param name="list-class" as="xs:string?"/>
        
        <ul class="list-inline inline-dots">
            
            <xsl:if test="$list-class">
                <xsl:attribute name="class" select="concat('list-inline inline-dots ', $list-class)"/>
            </xsl:if>
            
            <!-- Main term -->
            <xsl:for-each select="$item/m:term[not(@xml:lang eq 'en')]">
                <xsl:sort select="@xml:lang"/>
                <li>
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="common:lang-class(@xml:lang)"/>
                        </xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
            
            <xsl:for-each select="m:alternative">
                <li class="text-warning">
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="common:lang-class(@xml:lang)"/>
                        </xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
            
        </ul>
        
    </xsl:template>
    
    <xsl:template name="definition">
        <xsl:param name="item"/>
        <xsl:if test="$item/m:definition[node()]">
            <div class="text-muted small">
                <xsl:for-each select="$item/m:definition[node()]">
                    <xsl:variable name="definition-html">
                        <xsl:apply-templates select="node()"/>
                    </xsl:variable>
                    <p class="definition">
                        <xsl:apply-templates select="$definition-html"/>
                    </p>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="definition-tag-reference">
        
        <xsl:param name="element-id" as="xs:string" required="true"/>
        
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-8">
                <div class="panel panel-default no-bottom-margin">
                    <div class="panel-heading" role="tab">
                        <a href="{ concat('#tag-reference-', $element-id) }" aria-controls="{ concat('tag-reference-', $element-id) }" id="{ concat('#tag-reference-heading-', $element-id) }" class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                            <h5 class="text-muted">
                                <xsl:value-of select="'Glossary definition tag reference'"/>
                            </h5>
                            <span class="text-right">
                                <i class="fa fa-plus collapsed-show"/>
                                <i class="fa fa-minus collapsed-hide"/>
                            </span>
                        </a>
                    </div>
                    <div id="{ concat('tag-reference-', $element-id) }" aria-labelledby="{ concat('#tag-reference-heading-', $element-id) }" class="panel-body collapse" role="tabpanel" aria-expanded="false">
                        
                        <p class="small text-muted">
                            <xsl:value-of select="'These are the valid tags that can be used in glossary definitions. For more details refer to the 84000 TEI guidelines.'"/>
                        </p>
                        
                        <p>
                            
                            <xsl:variable name="serialization-parameters" as="element(output:serialization-parameters)">
                                <output:serialization-parameters>
                                    <output:method value="xml"/>
                                    <output:version value="1.1"/>
                                    <output:indent value="no"/>
                                    <output:omit-xml-declaration value="yes"/>
                                </output:serialization-parameters>
                            </xsl:variable>
                            
                            <xsl:variable name="samples">
                                <term type="ignore">affliction</term>
                                <distinct>dhāraṇī</distinct>
                                <emph>Reality</emph>
                                <foreign xml:lang="Sa-Ltn">āyatana</foreign>
                                <hi rend="small-caps">bce</hi>
                                <mantra xml:lang="Sa-Ltn">oṃ</mantra>
                                <ptr target="#UT22084-001-001"/>
                                <ref target="http://tripitaka.cbeta.org/T15n0599 ">cbeta.org</ref>
                                <title xml:lang="en">The Rice Seedling</title>
                            </xsl:variable>
                            
                            <xsl:for-each select="$samples/*">
                                <p>
                                    <code>
                                        <xsl:value-of select="replace(normalize-space(serialize(., $serialization-parameters)), '\s*xmlns=&#34;\S*&#34;', '')"/>
                                    </code>
                                </p>
                            </xsl:for-each>
                        </p>
                        
                    </div>
                </div>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="entity-search">
        
        <xsl:param name="loop-glossary" as="element(m:item)"/>
        <xsl:param name="match-mode" as="xs:string" required="yes"/>
        
        <!-- Form: search for similar entities -->
        <xsl:call-template name="form">
            
            <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
            <xsl:with-param name="tab-id" select="'entity'"/>
            <xsl:with-param name="form-class" select="'form-horizontal bottom-margin'"/>
            <xsl:with-param name="target-id" select="concat('expand-item-entity-', $loop-glossary/@id, '-entity-search')"/>
            <xsl:with-param name="form-content">
                
                <div class="input-group">
                    <xsl:attribute name="id" select="concat('expand-item-entity-', $loop-glossary/@id, '-entity-search')"/>
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
            
            <xsl:with-param name="accordion-selector" select="concat('accordion-glossary-', $loop-glossary/@id, '-entities')"/>
            <xsl:with-param name="id" select="concat('glossary-', $loop-glossary/@id, '-', $entity/@xml:id)"/>
            
            <xsl:with-param name="title">
                <div class="center-vertical align-left">
                    
                    <!-- Form: match/merge/exclude entity -->
                    <xsl:choose>
                        <xsl:when test="$match-mode eq 'merge-entities'">
                            
                            <!-- Form: merge entites -->
                            <div>
                                <xsl:call-template name="form">
                                    <xsl:with-param name="form-action" select="'merge-entity'"/>
                                    <xsl:with-param name="tab-id" select="'similar'"/>
                                    <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
                                    <xsl:with-param name="target-id" select="$entity-search-form-id"/>
                                    <xsl:with-param name="form-content">
                                        <input type="hidden" name="entity-id">
                                            <xsl:attribute name="value" select="$loop-glossary/m:entity[1]/@xml:id"/>
                                        </input>
                                        <input type="hidden" name="target-entity-id">
                                            <xsl:attribute name="value" select="$entity/@xml:id"/>
                                        </input>
                                        <button type="submit" class="btn btn-warning btn-sm" data-loading="Merging entities...">
                                            <xsl:value-of select="'Merge'"/>
                                        </button>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </div>
                            
                            <!-- Form: exclude match -->
                            <div>
                                <xsl:call-template name="form">
                                    <xsl:with-param name="form-action" select="'exclude-entity'"/>
                                    <xsl:with-param name="tab-id" select="'similar'"/>
                                    <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
                                    <xsl:with-param name="target-id" select="$entity-search-form-id"/>
                                    <xsl:with-param name="form-content">
                                        <input type="hidden" name="entity-id">
                                            <xsl:attribute name="value" select="$loop-glossary/m:entity[1]/@xml:id"/>
                                        </input>
                                        <input type="hidden" name="exclude-entity-id">
                                            <xsl:attribute name="value" select="$entity/@xml:id"/>
                                        </input>
                                        <button type="submit" class="btn btn-danger btn-sm" data-loading="Excluding match...">
                                            <xsl:value-of select="'Exclude'"/>
                                        </button>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </div>
                            
                        </xsl:when>
                        <xsl:when test="$match-mode eq 'match-glossary'">
                            
                            <!-- Form: match entity -->
                            <div>
                                <xsl:call-template name="form">
                                    <xsl:with-param name="form-action" select="'match-glossary'"/>
                                    <xsl:with-param name="tab-id" select="'similar'"/>
                                    <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
                                    <xsl:with-param name="form-content">
                                        <input type="hidden" name="entity-id">
                                            <xsl:attribute name="value" select="$entity/@xml:id"/>
                                        </input>
                                        <button type="submit" class="btn btn-warning btn-sm" data-loading="Applying match...">
                                            <xsl:value-of select="'Match'"/>
                                        </button>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </div>
                            
                        </xsl:when>
                    </xsl:choose>
                    
                    <div>
                        <ul class="list-inline inline-dots no-bottom-margin">
                            <li class="small">
                                <xsl:value-of select="'Entity: '"/>
                                <span>
                                    <xsl:attribute name="class">
                                        <xsl:value-of select="common:lang-class($entity/m:label[1]/@xml:lang)"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="common:limit-str($entity/m:label[1] ! fn:normalize-space(.), 80)"/>
                                </span>
                            </li>
                            <li class="small">
                                <xsl:value-of select="concat('ID: ', $entity/@xml:id)"/>
                            </li>
                            <li>
                                <xsl:call-template name="entity-type-labels">
                                    <xsl:with-param name="entity" select="$entity"/>
                                </xsl:call-template>
                            </li>
                            <li class="small">
                                <xsl:value-of select="concat('Groups ', count($entity/m:instance[@type eq 'glossary-item']), ' glossaries')"/>
                            </li>
                        </ul>
                    </div>
                    
                </div>
            </xsl:with-param>
            
            <xsl:with-param name="content">
                <xsl:for-each-group select="$entity/m:instance[@type eq 'glossary-item']/m:item" group-by="m:text/@id">
                    
                    <xsl:sort select="m:text[1]/@id"/>
                    
                    <xsl:call-template name="glossary-items-text-group">
                        <xsl:with-param name="glossary-items" select="current-group()"/>
                        <xsl:with-param name="active-glossary-id" select="$loop-glossary/@id"/>
                    </xsl:call-template>
                    
                </xsl:for-each-group>
            </xsl:with-param>
            
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="entity-form">
        
        <xsl:param name="loop-glossary"/>
        
        <xsl:call-template name="form">
            
            <xsl:with-param name="tab-id" select="'entity'"/>
            <xsl:with-param name="form-action" select="'update-entity'"/>
            <xsl:with-param name="form-class" select="'form-horizontal'"/>
            <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
            <xsl:with-param name="target-id" select="concat('expand-item-entity-', $loop-glossary/@id, '-detail')"/>
            
            <xsl:with-param name="form-content">
                
                <input type="hidden" name="entity-id" value="{ $loop-glossary/m:entity/@xml:id }"/>
                
                <!-- Labels -->
                <div class="add-nodes-container">
                    
                    <xsl:choose>
                        <xsl:when test="$loop-glossary[m:entity]">
                            <xsl:for-each select="$loop-glossary/m:entity/m:label">
                                <xsl:call-template name="text-input-with-lang">
                                    <xsl:with-param name="text" select="text()"/>
                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                    <xsl:with-param name="id" select="parent::m:entity/@xml:id"/>
                                    <xsl:with-param name="index" select="position()"/>
                                    <xsl:with-param name="input-name" select="'entity-label'"/>
                                    <xsl:with-param name="label" select="'Label:'"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="text-input-with-lang">
                                <xsl:with-param name="text" select="$loop-glossary/m:term[@xml:lang = ('bo', 'Sa-Ltn')][1]/text()"/>
                                <xsl:with-param name="lang" select="$loop-glossary/m:term[@xml:lang = ('bo', 'Sa-Ltn')][1]/@xml:lang"/>
                                <xsl:with-param name="id" select="$loop-glossary/@id"/>
                                <xsl:with-param name="index" select="position()"/>
                                <xsl:with-param name="input-name" select="'entity-label'"/>
                                <xsl:with-param name="label" select="'Label:'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-2">
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">
                                    <xsl:value-of select="'+'"/>
                                </span>
                                <xsl:value-of select="' add a label'"/>
                            </a>
                        </div>
                        <div class="col-sm-8">
                            <p class="text-muted small">
                                <xsl:value-of select="'Standard hyphens added to Sanskrit strings will be converted to soft-hyphens when saved'"/>
                            </p>
                        </div>
                    </div>
                    
                </div>
                
                <!-- Type checkboxes -->
                <div class="form-group">
                    
                    <label class="col-sm-2 control-label">
                        <xsl:value-of select="'Type(s):'"/>
                    </label>
                    
                    <xsl:for-each select="('eft-glossary-term', 'eft-glossary-person', 'eft-glossary-place', 'eft-glossary-text')">
                        <xsl:variable name="loop-glossary-type" select="."/>
                        <div class="col-sm-2">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="entity-type[]">
                                        <xsl:attribute name="value" select="$loop-glossary-type"/>
                                        <xsl:if test="$loop-glossary/m:entity/m:type[@type = $loop-glossary-type]">
                                            <xsl:attribute name="checked" select="'checked'"/>
                                        </xsl:if>
                                    </input>
                                    <xsl:choose>
                                        <xsl:when test="$loop-glossary-type eq 'eft-glossary-term'">
                                            <xsl:value-of select="' Term'"/>
                                        </xsl:when>
                                        <xsl:when test="$loop-glossary-type eq 'eft-glossary-person'">
                                            <xsl:value-of select="' Person'"/>
                                        </xsl:when>
                                        <xsl:when test="$loop-glossary-type eq 'eft-glossary-place'">
                                            <xsl:value-of select="' Place'"/>
                                        </xsl:when>
                                        <xsl:when test="$loop-glossary-type eq 'eft-glossary-text'">
                                            <xsl:value-of select="' Text'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </label>
                            </div>
                        </div>
                    </xsl:for-each>
                    
                </div>
                
                <!-- Entity definition -->
                <div class="form-group">
                    
                    <label class="col-sm-2 control-label">
                        <xsl:attribute name="for" select="concat('entity-definition-', $loop-glossary/@id, '-', ($loop-glossary/m:entity/@xml:id, 'new-entity')[1], '-1')"/>
                        <xsl:value-of select="'Definition (public):'"/>
                    </label>
                    
                    <div class="col-sm-8 add-nodes-container">
                        
                        <xsl:variable name="entity-definitions" select="$loop-glossary/m:entity/m:content[@type eq 'glossary-definition']"/>
                        
                        <xsl:for-each select="(1 to (if(count($entity-definitions) gt 0) then count($entity-definitions) else 1))">
                            <xsl:variable name="definition-index" select="."/>
                            <div class="sml-margin bottom add-nodes-group">
                                <textarea class="form-control" rows="3">
                                    
                                    <xsl:if test="count($entity-definitions) gt 1">
                                        <xsl:attribute name="rows" select="2"/>
                                    </xsl:if>
                                    
                                    <xsl:attribute name="id" select="concat('entity-definition-', $loop-glossary/@id, '-', ($loop-glossary/m:entity/@xml:id, 'new-entity')[1], '-', $definition-index)"/>
                                    <xsl:attribute name="name" select="concat('entity-definition-', $definition-index)"/>
                                    
                                    <xsl:variable name="definition">
                                        <div xmlns="http://www.tei-c.org/ns/1.0" type="unescaped">
                                            <xsl:sequence select="$entity-definitions[$definition-index]/node()"/>
                                        </div>
                                    </xsl:variable>
                                    
                                    <xsl:variable name="definition-escaped">
                                        <xsl:apply-templates select="$definition"/>
                                    </xsl:variable>
                                    
                                    <xsl:sequence select="$definition-escaped/m:escaped/node()"/>
                                    
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
                <xsl:call-template name="definition-tag-reference">
                    <xsl:with-param name="element-id" select="concat( $loop-glossary/@id, '-entity')"/>
                </xsl:call-template>
                
                <!-- Entity notes -->
                <div class="form-group">
                    
                    <label class="col-sm-2 control-label">
                        <xsl:attribute name="for" select="concat('entity-note-', $loop-glossary/@id, '-', ($loop-glossary/m:entity/@xml:id, 'new-entity')[1], '-1')"/>
                        <xsl:value-of select="'Notes (internal):'"/>
                    </label>
                    
                    <div class="col-sm-8 add-nodes-container">
                        
                        <xsl:variable name="entity-notes" select="$loop-glossary/m:entity/m:content[@type eq 'glossary-notes']"/>
                        
                        <xsl:for-each select="(1 to (if(count($entity-notes) gt 0) then count($entity-notes) else 1))">
                            <xsl:variable name="note-index" select="."/>
                            <div class="sml-margin bottom add-nodes-group">
                                <textarea class="form-control" rows="3">
                                    <xsl:if test="count($entity-notes) gt 1">
                                        <xsl:attribute name="rows" select="2"/>
                                    </xsl:if>
                                    <xsl:attribute name="id" select="concat('entity-note-', $loop-glossary/@id, '-', ($loop-glossary/m:entity/@xml:id, 'new-entity')[1], '-', $note-index)"/>
                                    <xsl:attribute name="name" select="concat('entity-note-', $note-index)"/>
                                    <xsl:value-of select="$entity-notes[$note-index]"/>
                                </textarea>
                            </div>
                        </xsl:for-each>
                        
                        <div class="sml-margin top">
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">
                                    <xsl:value-of select="'+'"/>
                                </span>
                                <xsl:value-of select="' add a note'"/>
                            </a>
                        </div>
                        
                    </div>
                    
                </div>
                
                <!-- Submit button / un-link option -->
                <div class="form-group">
                    
                    <div class="col-sm-offset-2 col-sm-6">
                        <xsl:if test="$loop-glossary[m:entity]">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="instance-remove">
                                        <xsl:attribute name="value" select="$loop-glossary/@id"/>
                                    </input>
                                    <span class="text-danger">
                                        <i class="fa fa-exclamation-circle"/>
                                        <xsl:value-of select="' Un-link this glossary from this shared entity'"/>
                                    </span>
                                </label>
                            </div>
                        </xsl:if>
                    </div>
                    
                    <div class="col-sm-2">
                        <button type="submit" data-loading="Applying changes...">
                            <xsl:choose>
                                <xsl:when test="$loop-glossary[m:entity]">
                                    <xsl:attribute name="class" select="'btn btn-primary pull-right'"/>
                                    <xsl:value-of select="'Apply changes'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="class" select="'btn btn-danger pull-right'"/>
                                    <xsl:value-of select="'Create Shared Entity'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </button>
                    </div>
                    
                </div>
                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="entity-type-labels">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:choose>
            <xsl:when test="$entity">
                <xsl:choose>
                    <xsl:when test="$entity[m:type]">
                        <xsl:for-each select="$entity/m:type">
                            <span class="label label-info">
                                <xsl:choose>
                                    <xsl:when test="@type eq 'eft-glossary-term'">
                                        <xsl:value-of select="'Term'"/>
                                    </xsl:when>
                                    <xsl:when test="@type eq 'eft-glossary-person'">
                                        <xsl:value-of select="'Person'"/>
                                    </xsl:when>
                                    <xsl:when test="@type eq 'eft-glossary-place'">
                                        <xsl:value-of select="'Place'"/>
                                    </xsl:when>
                                    <xsl:when test="@type eq 'eft-glossary-text'">
                                        <xsl:value-of select="'Text'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@type"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="label label-warning">
                            <xsl:value-of select="'No type selected'"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <span class="label label-danger">
                    <xsl:value-of select="'No shared entity defined'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="text-input-with-lang">
        
        <xsl:param name="text" as="xs:string?"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:param name="id" as="xs:string" required="true"/>
        <xsl:param name="index" as="xs:integer" required="true"/>
        <xsl:param name="input-name" as="xs:string" required="true"/>
        <xsl:param name="label" as="xs:string" required="true"/>
        
        <div class="form-group add-nodes-group">
            
            <xsl:if test="$index eq 1">
                <label for="{ concat($input-name, '-', $id, '-', $index) }" class="col-sm-2 control-label">
                    <xsl:value-of select="$label"/>
                </label>
            </xsl:if>
            
            <div class="col-sm-2">
                <xsl:if test="not($index eq 1)">
                    <xsl:attribute name="class" select="'col-sm-offset-2 col-sm-2'"/>
                </xsl:if>
                <xsl:call-template name="select-language">
                    <xsl:with-param name="selected-language" select="$lang"/>
                    <xsl:with-param name="input-name" select="concat($input-name, '-lang-', $index)"/>
                    <xsl:with-param name="input-id" select="concat($input-name, '-lang-', $id, '-', $index)"/>
                </xsl:call-template>
            </div>
            
            <div class="col-sm-6">
                <input type="text" name="{ concat($input-name, '-text-', $index) }" id="{ concat($input-name, '-', $id, '-', $index) }" class="form-control">
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="$lang eq 'Sa-Ltn'">
                                <xsl:attribute name="value" select="replace($text, '­', '-')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value" select="$text"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </input>
            </div>
            
        </div>
    </xsl:template>
    
    <xsl:template name="select-language">
        
        <xsl:param name="selected-language" as="xs:string?"/>
        <xsl:param name="input-name" as="xs:string" required="yes"/>
        <xsl:param name="input-id" as="xs:string" required="yes"/>
        <xsl:param name="allow-empty" as="xs:boolean" select="false()"/>
        
        <select class="form-control">
            <xsl:attribute name="name" select="$input-name"/>
            <xsl:attribute name="id" select="$input-id"/>
            <xsl:if test="$allow-empty">
                <option value=""/>
            </xsl:if>
            <option value="en">
                <xsl:if test="$selected-language = ('','en')">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'English'"/>
            </option>
            <option value="bo">
                <xsl:if test="$selected-language eq 'bo'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Tibetan'"/>
            </option>
            <option value="bo-ltn">
                <xsl:if test="$selected-language eq 'Bo-Ltn'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Wylie'"/>
            </option>
            <option value="sa-ltn">
                <xsl:if test="$selected-language eq 'Sa-Ltn'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Sanskrit'"/>
            </option>
            <option value="zh">
                <xsl:if test="$selected-language eq 'zh'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Chinese'"/>
            </option>
            <xsl:if test="not($selected-language = $term-langs)">
                <option>
                    <xsl:attribute name="value" select="$selected-language"/>
                    <xsl:attribute name="selected" select="'selected'"/>
                    <xsl:value-of select="$selected-language"/>
                </option>
            </xsl:if>
        </select>
        
    </xsl:template>
    
    <xsl:template match="m:location">
        
        <xsl:variable name="location-id" select="@id" as="xs:string"/>
        <xsl:variable name="glossary-item" select="parent::m:expressions/parent::m:item"/>
        <xsl:variable name="cache-location" select="$glossary-cache/m:gloss[@id eq $glossary-item/@id]/m:location[@id = $location-id]"/>
        
        <div class="item tei-parser editor-mode rw-full-width small pad">
            
            <xsl:if test="not($cache-location)">
                <xsl:attribute name="class" select="'item editor-mode translation rw-full-width small pad flagged'"/>
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
                        <xsl:value-of select="concat($reading-room-path, '/translation/', $toh-key, '.html?view-mode=editor', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-glossary-location]">
                        <xsl:value-of select="concat($reading-room-path, '/translation/', $toh-key, '.html?view-mode=editor', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-pointer-type eq 'id']">
                        <xsl:value-of select="concat($reading-room-path, '/translation/', $toh-key, '.html?view-mode=editor', $link/@href)"/>
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
                        <xsl:value-of select="$toh-key"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            
            <xsl:sequence select="node()"/>
            
        </xsl:element>
        
    </xsl:template>
    
</xsl:stylesheet>