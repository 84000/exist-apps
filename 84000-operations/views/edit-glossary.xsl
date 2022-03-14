<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
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
    <xsl:variable name="main-title">
        <xsl:choose>
            <xsl:when test="$request-resource-type eq 'knowledgebase'">
                <xsl:value-of select="$text/m:titles/m:title[@type eq 'mainTitle'][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en'][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="glossary" select="/m:response/m:glossary[1]"/>
    <xsl:variable name="glossary-cache" select="/m:response/m:glossary-cache[1]"/>
    <xsl:variable name="cache-slow" select="if($glossary-cache/@seconds-to-build ! xs:decimal(.) gt 120) then true() else false()" as="xs:boolean"/>
    <xsl:variable name="cache-glosses-behind" select="$glossary-cache/m:gloss[not(@tei-version eq $text/@tei-version)][m:location]"/>
    <xsl:variable name="cache-glosses-new-locations" select="$glossary-cache/m:gloss[m:location/@initial-version = $text/@tei-version]"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Glossary'"/>
                    </h3>
                    
                    <!-- Text title -->
                    <div class="h4 no-bottom-margin">
                        
                        <a>
                            <xsl:if test="$text[m:toh]">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/', $request-resource-type, '/', $text/m:toh[1]/@key, '.html?view-mode=editor')"/>
                                <xsl:attribute name="target" select="$request-resource-id"/>
                                <xsl:value-of select="$text/m:toh[1]/m:full/data()"/>
                                <xsl:value-of select="' / '"/>
                            </xsl:if>
                            <xsl:value-of select="common:limit-str($main-title, 80)"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a class="small underline">
                            <xsl:attribute name="href" select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor')"/>
                            <xsl:attribute name="target" select="$request-resource-id"/>
                            <xsl:value-of select="common:limit-str($request-resource-id, 100 - string-length($main-title))"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a target="_self" class="small underline" data-loading="Loading...">
                            <xsl:choose>
                                <xsl:when test="$request-resource-type eq 'knowledgebase'">
                                    <xsl:attribute name="href" select="concat('edit-kb-header.html?id=', $request-resource-id)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $request-resource-id)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="'Edit headers'"/>
                        </a>
                        
                        <div class="pull-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <xsl:if test="not($request-filter eq 'blank-form')">
                        
                        <hr class="sml-margin"/>
                        
                        <!-- Status row -->
                        <div class="center-vertical full-width">
                            
                            <!-- Version / status -->
                            <div>
                                <ul class="list-inline">
                                    <xsl:if test="$text[@tei-version]">
                                        
                                        <li>
                                            
                                            <span class="small">
                                                <xsl:value-of select="'Current TEI version: '"/>
                                            </span>
                                            
                                            <span class="label label-default">
                                                <xsl:value-of select="$text/@tei-version"/>
                                            </span>
                                            
                                        </li>
                                        
                                        <xsl:variable name="glossary-status" select="/m:response/m:entities/m:related/m:text[@id = $request-resource-id]/@glossary-status"/>
                                        <li>
                                            
                                            <span class="small">
                                                <xsl:value-of select="'Glossary status: '"/>
                                            </span>
                                            
                                            <span class="label label-default">
                                                <xsl:if test="$glossary-status">
                                                    <xsl:attribute name="class" select="'label label-danger'"/>
                                                </xsl:if>
                                                <xsl:value-of select="concat(format-number($glossary/@total-records, '#,###'), if($glossary/@total-records ! xs:integer(.) eq 1) then ' entry' else ' entries')"/>
                                            </span>
                                            
                                            <span class="label label-default">
                                                <xsl:choose>
                                                    <xsl:when test="$glossary-status">
                                                        <xsl:attribute name="class" select="'label label-danger'"/>
                                                        <xsl:value-of select="$glossary-status"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'included'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </span>
                                            
                                        </li>
                                        
                                        <li>
                                            
                                            <span class="small">
                                                <xsl:value-of select="'Cache: '"/>
                                            </span>
                                            
                                            <xsl:if test="$cache-glosses-new-locations">
                                                <span class="label label-success">
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="link-href">
                                                                <xsl:with-param name="filter" select="'new-locations'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                        <xsl:value-of select="concat(count($cache-glosses-new-locations), ' changed')"/>
                                                    </a>
                                                </span>
                                            </xsl:if>
                                            
                                            <xsl:choose>
                                                <xsl:when test="count($cache-glosses-behind) gt 0">
                                                    <span class="label label-warning">
                                                        <a>
                                                            <xsl:attribute name="href">
                                                                <xsl:call-template name="link-href">
                                                                    <xsl:with-param name="filter" select="'cache-behind'"/>
                                                                </xsl:call-template>
                                                            </xsl:attribute>
                                                            <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                            <xsl:value-of select="concat(count($cache-glosses-behind), ' behind'(:, $text/@tei-version:))"/>
                                                        </a>
                                                    </span>
                                                </xsl:when>
                                                <xsl:when test="count($glossary-cache/m:gloss) eq 0">
                                                    <span class="label label-default">
                                                        <xsl:value-of select="'No glossary cache'"/>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <span class="label label-default">
                                                        <xsl:value-of select="'0 behind'"/>
                                                    </span>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                            <xsl:if test="$glossary-cache/m:gloss[not(m:location)]">
                                                <span class="label label-danger">
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="link-href">
                                                                <xsl:with-param name="filter" select="'no-locations'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                        <xsl:value-of select="concat(count($glossary-cache/m:gloss[not(m:location)]), ' missing')"/>
                                                    </a>
                                                </span>
                                            </xsl:if>
                                            
                                        </li>
                                        
                                        <!-- Auto-assign entities -->
                                        <xsl:variable name="entries-without-entities" select="xs:integer($glossary/@total-records) - xs:integer($glossary/@records-assigned-entities)"/>
                                        <xsl:if test="$entries-without-entities gt 0">
                                            <li>
                                                <span class="small">
                                                    <xsl:value-of select="'Entities: '"/>
                                                </span>
                                                <span class="label label-danger">
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="link-href">
                                                                <xsl:with-param name="filter" select="'missing-entities'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                        <xsl:value-of select="concat(format-number($entries-without-entities, '#,###'), ' no entity')"/>
                                                    </a>
                                                </span>
                                            </li>
                                        </xsl:if>
                                        
                                    </xsl:if>
                                </ul>
                            </div>
                            
                            <!-- Links to more functions -->
                            <xsl:if test="not($request-filter eq 'blank-form')">
                                <div>
                                    <ul class="list-inline inline-dots pull-right">
                                        
                                        <xsl:choose>
                                            
                                            <xsl:when test="not(scheduler:job)">
                                                
                                                <!-- Show batch update options -->
                                                <li>
                                                    <a href="#batchUpdateOptions" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="batchUpdateOptions" class="small underline">
                                                        <xsl:value-of select="'Batch update options'"/>
                                                    </a>
                                                </li>
                                                
                                                <!-- Add new entry -->
                                                <li>
                                                    <xsl:call-template name="link">
                                                        <xsl:with-param name="filter" select="'blank-form'"/>
                                                        <xsl:with-param name="search" select="''"/>
                                                        <xsl:with-param name="link-text" select="'Add a new entry'"/>
                                                        <xsl:with-param name="link-class" select="'small underline'"/>
                                                    </xsl:call-template>
                                                </li>
                                                
                                            </xsl:when>
                                            
                                            <!-- Disable if processing -->
                                            <xsl:otherwise>
                                                <li>
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="'Job running, please wait...'"/>
                                                    </span>
                                                </li>
                                            </xsl:otherwise>
                                            
                                        </xsl:choose>
                                        
                                    </ul>
                                </div>
                            </xsl:if>
                            
                        </div>
                        
                        <!-- Batch update options -->
                        <xsl:if test="not(scheduler:job)">
                            <div id="batchUpdateOptions" class="collapse">
                                
                                <div class="well top-margin">
                                    <ul class="no-bottom-margin">
                                        
                                        <!-- Cache locations -->
                                        <xsl:if test="count($cache-glosses-behind) gt 0 and count($cache-glosses-behind) lt count($glossary-cache/m:gloss)">
                                            <li>
                                                <a target="_self" class="underline small" data-loading="Caching locations...">
                                                    <xsl:attribute name="href" select="concat('edit-glossary.html?resource-id=', $request-resource-id, '&amp;resource-type=', $request-resource-type, '&amp;form-action=cache-locations-version&amp;filter=new-locations')"/>
                                                    <xsl:value-of select="concat('Cache locations of ', count($cache-glosses-behind),' entries that are behind the current version')"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                        <li>
                                            
                                            <a target="_self" class="underline small" data-loading="Caching locations...">
                                                <xsl:attribute name="href" select="concat('edit-glossary.html?resource-id=', $request-resource-id, '&amp;resource-type=', $request-resource-type, '&amp;form-action=cache-locations-all&amp;filter=new-locations')"/>
                                                <xsl:value-of select="'Re-cache locations of all entries'"/>
                                            </a>
                                            
                                            <xsl:if test="$glossary-cache[@seconds-to-build]">
                                                <xsl:choose>
                                                    <xsl:when test="$cache-slow">
                                                        <span class="label label-warning">
                                                            <xsl:value-of select="concat('previously this took: ', format-number(($glossary-cache/@seconds-to-build ! xs:decimal(.) div 60), '#,##0.##'), ' minutes')"/>
                                                        </span>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <span class="label label-info">
                                                            <xsl:value-of select="concat('previously this took: ', format-number($glossary-cache/@seconds-to-build, '#,##0.##'), ' seconds')"/>
                                                        </span>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:if>
                                        </li>
                                        
                                        <!-- Auto-assign entities -->
                                        <xsl:if test="$glossary/@total-records ! xs:integer(.) gt $glossary/@records-assigned-entities ! xs:integer(.)">
                                            <li>
                                                <a target="_self" class="underline small" data-loading="Auto-assigning entities...">
                                                    <xsl:attribute name="href" select="concat('edit-glossary.html?resource-id=', $request-resource-id, '&amp;resource-type=', $request-resource-type, '&amp;form-action=merge-all-entities&amp;filter=requires-attention')"/>
                                                    <xsl:value-of select="'Auto-assign entries without entities'"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                    </ul>
                                </div>
                                
                            </div>
                        </xsl:if>
                        
                        <hr class="sml-margin"/>
                        
                        <!-- Filter / Pagination -->
                        <div class="center-vertical full-width">
                            
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
                                                    <option value="check-all">
                                                        <xsl:if test="$request-filter eq 'check-all'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Show all'"/>
                                                    </option>
                                                    <optgroup label="Filter by locations:">
                                                        <option value="check-locations">
                                                            <xsl:if test="$request-filter eq 'check-locations'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Show locations'"/>
                                                        </option>                                                        
                                                        <option value="no-locations">
                                                            <xsl:if test="$request-filter eq 'no-locations'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'No cached locations'"/>
                                                        </option>
                                                        <option value="cache-behind">
                                                            <xsl:if test="$request-filter eq 'cache-behind'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Cache behind'"/>
                                                        </option>
                                                        <option value="new-locations">
                                                            <xsl:if test="$request-filter eq 'new-locations'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Newly cached'"/>
                                                        </option>
                                                    </optgroup>
                                                    <optgroup label="Filter by entity:">
                                                        <option value="check-entities">
                                                            <xsl:if test="$request-filter eq 'check-entities'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Show entities'"/>
                                                        </option>
                                                        <option value="missing-entities">
                                                            <xsl:if test="$request-filter eq 'missing-entities'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'No entity'"/>
                                                        </option>
                                                        <option value="check-terms">
                                                            <xsl:if test="$request-filter eq 'check-terms'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Term entities'"/>
                                                        </option>
                                                        <option value="check-people">
                                                            <xsl:if test="$request-filter eq 'check-people'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'People entities'"/>
                                                        </option>
                                                        <option value="check-places">
                                                            <xsl:if test="$request-filter eq 'check-places'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Place entities'"/>
                                                        </option>
                                                        <option value="check-texts">
                                                            <xsl:if test="$request-filter eq 'check-texts'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Text entities'"/>
                                                        </option>
                                                    </optgroup>
                                                    <optgroup label="Flagged:">
                                                        <xsl:for-each select="/m:response/m:entity-flags/m:flag">
                                                            <option value="requires-attention">
                                                                <xsl:attribute name="value" select="@id"/>
                                                                <xsl:if test="$request-filter eq @id">
                                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="m:label"/>
                                                            </option>
                                                        </xsl:for-each>
                                                    </optgroup>
                                                </select>
                                                
                                            </div>
                                            
                                            <xsl:variable name="active-item" select="$glossary/m:entry[@active-item eq 'true'][1]"/>
                                            <xsl:choose>
                                                
                                                <!-- Filter by glossary-id -->
                                                <xsl:when test="$active-item">
                                                    <div class="checkbox">
                                                        <label>
                                                            <input type="checkbox" name="glossary-id" checked="checked">
                                                                <xsl:attribute name="value" select="$active-item/@id"/>
                                                            </input>
                                                            <xsl:value-of select="' '"/>
                                                            <xsl:value-of select="common:limit-str($active-item/m:term[@xml:lang eq 'en'][1]/data(), 24)"/>
                                                        </label>
                                                    </div>
                                                </xsl:when>
                                                
                                                <!-- Search -->
                                                <xsl:otherwise>
                                                    <div class="input-group">
                                                        
                                                        <div class="input-group-addon">
                                                            <xsl:value-of select="'Search:'"/>
                                                        </div>
                                                        
                                                        <input type="text" name="search" id="search" class="form-control" size="10" maxlength="100">
                                                            <xsl:attribute name="value" select="$request-search"/>
                                                        </input>
                                                        
                                                    </div>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
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
                    
                    <hr class="sml-margin"/>
                    
                    <!-- Loop through glossary items -->
                    <xsl:choose>
                        <xsl:when test="$glossary[m:entry]">
                            <xsl:for-each select="$glossary/m:entry">
                                
                                <xsl:variable name="loop-glossary" select="."/>
                                <xsl:variable name="loop-glossary-id" select="($loop-glossary/@id, 'new-glossary')[1]"/>
                                <xsl:variable name="loop-glossary-cache" select="$glossary-cache/m:gloss[@id eq $loop-glossary-id]"/>
                                
                                <xsl:variable name="loop-glossary-instance" select="key('entity-instance', $loop-glossary/@id, $root)[1]"/>
                                <xsl:variable name="loop-glossary-entity" select="$loop-glossary-instance/parent::m:entity"/>
                                <xsl:variable name="loop-glossary-entity-relations" select="$loop-glossary-entity/m:relation | /m:response/m:entities/m:related/m:entity[not(@xml:id = $loop-glossary-entity/m:relation/@id)]/m:relation[@id eq $loop-glossary-entity/@xml:id]"/>
                                
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
                                            <a>
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', '#', $loop-glossary-id)"/>
                                                <xsl:attribute name="target" select="$request-resource-id"/>
                                                <xsl:value-of select="$loop-glossary-id"/>
                                            </a>
                                        </span>
                                        
                                        <!-- link to Combined glossary -->
                                        <xsl:if test="$loop-glossary-entity">
                                            <span class="small">
                                                <xsl:value-of select="' / '"/>
                                                <a target="84000-glossary">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $loop-glossary-entity/@xml:id, '&amp;view-mode=editor')"/>
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
                                                <xsl:with-param name="filter" select="if($request-filter = ('check-entities', 'check-locations')) then $request-filter else 'check-all'"/>
                                            </xsl:call-template>
                                        </span>
                                        
                                    </h4>
                                    
                                    <!-- Definition -->
                                    <xsl:if test="$loop-glossary/m:definition[node()]">
                                        <div class="sml-margin bottom collapse-one-line">
                                            <xsl:call-template name="glossary-definition">
                                                <xsl:with-param name="item" select="$loop-glossary"/>
                                            </xsl:call-template>
                                        </div>
                                    </xsl:if>
                                    
                                    <!-- Entity definition setting -->
                                    <xsl:if test="$loop-glossary-entity/m:content[@type eq 'glossary-definition'] and (not($loop-glossary/m:definition[node()]) or $loop-glossary-instance[@use-definition eq 'both'])">
                                        <div class="sml-margin bottom">
                                            <p>
                                                <span class="label label-info">
                                                    <xsl:value-of select="'Output will include the entity definition'"/>
                                                </span>
                                            </p>
                                        </div>
                                    </xsl:if>
                                    
                                    <!-- Accordion -->
                                    <div class="list-group accordion accordion-background" role="tablist" aria-multiselectable="false">
                                        
                                        <xsl:attribute name="id" select="concat('accordion-', $loop-glossary-id)"/>
                                        
                                        <!-- Panel: Glossary form -->
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="id" select="concat('glossary-form-',$loop-glossary-id)"/>
                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                            <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'glossary-form'"/>
                                            <xsl:with-param name="persist" select="true()"/>
                                            
                                            <xsl:with-param name="title">
                                                
                                                <span class="h4">
                                                    <xsl:value-of select="'Glossary entry: '"/>
                                                </span>
                                                
                                                <xsl:call-template name="glossary-terms">
                                                    <xsl:with-param name="entry" select="."/>
                                                </xsl:call-template>
                                                
                                            </xsl:with-param>
                                            
                                            <xsl:with-param name="content">
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <xsl:call-template name="form">
                                                    
                                                    <xsl:with-param name="show-tab" select="'glossary-form'"/>
                                                    <xsl:with-param name="form-action" select="'update-glossary'"/>
                                                    <xsl:with-param name="form-content">
                                                        
                                                        <xsl:call-template name="glossary-form">
                                                            <xsl:with-param name="entry" select="$loop-glossary"/>
                                                            <xsl:with-param name="entity" select="$loop-glossary-entity"/>
                                                        </xsl:call-template>
                                                        
                                                    </xsl:with-param>
                                                    
                                                </xsl:call-template>
                                                
                                            </xsl:with-param>
                                        
                                        </xsl:call-template>
                                        
                                        <!-- Panel: Show locations of this glossary in the text-->
                                        <xsl:if test="$request-filter = ('check-locations', 'check-all', 'new-locations', 'no-locations', 'cache-behind')">
                                            
                                            <xsl:variable name="locations-cache-new" select="$loop-glossary-cache/m:location[@initial-version eq $text/@tei-version]"/>
                                            <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $loop-glossary-id, $root)"/>
                                            <xsl:variable name="locations-not-cached" select="$loop-glossary/m:locations/m:location[not(@id = $glossary-cache-gloss/m:location/@id)]"/>
                                            <xsl:variable name="locations-cache-behind" select="$loop-glossary-cache[m:location] and $cache-glosses-behind[@id eq $loop-glossary-id]"/>
                                            
                                            <xsl:call-template name="expand-item">
                                                
                                                <xsl:with-param name="id" select="concat('expressions-',$loop-glossary-id)"/>
                                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'expressions'"/>
                                                <xsl:with-param name="persist" select="true()"/>
                                                
                                                <xsl:with-param name="title">
                                                    <div class="center-vertical align-left">
                                                        
                                                        <div>
                                                            <xsl:variable name="count-locations" select="count($loop-glossary/m:locations/m:location)"/>
                                                            <span>
                                                                <xsl:value-of select="' ↳ '"/>
                                                            </span>
                                                            <span class="badge badge-notification">
                                                                <xsl:choose>
                                                                    <xsl:when test="$loop-glossary-cache[m:location/@initial-version = $text/@tei-version]">
                                                                        <xsl:attribute name="class" select="'badge badge-notification'"/>
                                                                    </xsl:when>
                                                                    <xsl:when test="$loop-glossary[m:locations[m:location]]">
                                                                        <xsl:attribute name="class" select="'badge badge-notification badge-info'"/>
                                                                    </xsl:when>
                                                                    <xsl:when test="$loop-glossary[m:locations]">
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
                                                        
                                                        <xsl:if test="not($loop-glossary-cache/m:location)">
                                                            <div>
                                                                <span class="label label-danger">
                                                                    <xsl:value-of select="'Not cached'"/>
                                                                </span>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="$cache-glosses-new-locations[@id eq $loop-glossary-id]">
                                                            <div>
                                                                <span class="label label-success">
                                                                    <xsl:value-of select="concat(count($cache-glosses-new-locations[@id eq $loop-glossary-id]/m:location[@initial-version = $text/@tei-version]), ' newly cached')"/>
                                                                </span>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="$locations-not-cached">
                                                            <div>
                                                                <span class="label label-danger">
                                                                    <xsl:value-of select="concat(count($locations-not-cached), ' not cached')"/>
                                                                </span>
                                                            </div>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="$locations-cache-behind">
                                                            <div>
                                                                <span class="label label-warning">
                                                                    <xsl:value-of select="'Cache behind current version'"/>
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
                                                                
                                                                <xsl:when test="$loop-glossary/m:locations[m:location]">
                                                                    
                                                                    <div class="div-list sml-margin top bottom">
                                                                        
                                                                        <xsl:for-each select="$loop-glossary/m:locations/m:location">
                                                                            <xsl:sort select="xs:integer(@sort-index)"/>
                                                                            <xsl:apply-templates select="."/>  
                                                                        </xsl:for-each>
                                                                        
                                                                        <xsl:if test="$locations-not-cached or $locations-cache-behind">
                                                                            <div class="item center-vertical full-width">
                                                                                
                                                                                <div class="text-danger">
                                                                                    <span class="small">
                                                                                        <xsl:value-of select="'Any passages labelled as '"/>
                                                                                    </span>
                                                                                    
                                                                                    <span class="label label-danger">
                                                                                        <xsl:value-of select="'Location not cached'"/>
                                                                                    </span>
                                                                                    <span class="small">
                                                                                        <xsl:value-of select="' will not appear in the public Reading Room.'"/>
                                                                                    </span>
                                                                                    <br/>
                                                                                    <span class="small">
                                                                                        <xsl:value-of select="'Select &#34;Cache locations&#34; on the right to cache this item, or re-cache all locations using the link in &#34;Batch update options&#34;.'"/>
                                                                                    </span>
                                                                                </div>
                                                                                
                                                                                <div>
                                                                                    <button type="submit" class="btn btn-danger btn-sm pull-right" data-loading="Caching locations...">
                                                                                        <xsl:choose>
                                                                                            <xsl:when test="/m:response/scheduler:job">
                                                                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                                                                                <xsl:value-of select="'Job running, please wait...'"/>
                                                                                            </xsl:when>
                                                                                            <xsl:otherwise>
                                                                                                <xsl:value-of select="'Cache locations'"/>
                                                                                            </xsl:otherwise>
                                                                                        </xsl:choose>
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
                                        <xsl:if test="$request-filter = ('check-entities', 'check-terms', 'check-people', 'check-places', 'check-texts', 'check-all', 'missing-entities', 'requires-attention')">
                                            
                                            <!-- Panel: Entity form -->
                                            <xsl:call-template name="expand-item">
                                                
                                                <xsl:with-param name="id" select="concat('entity-', $loop-glossary-id)"/>
                                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity'"/>
                                                <xsl:with-param name="persist" select="true()"/>
                                                
                                                <!-- Entity panel title -->
                                                <xsl:with-param name="title">
                                                    
                                                    <span class="h4">
                                                        <xsl:value-of select="'Shared entity: '"/>
                                                    </span>
                                                    
                                                    <ul class="list-inline inline-dots">
                                                        <xsl:choose>
                                                            <xsl:when test="$loop-glossary-entity">
                                                                
                                                                <xsl:variable name="loop-glossary-entity-label" select="($loop-glossary-entity/m:label[@xml:lang eq 'en'], $loop-glossary-entity/m:label[@xml:lang eq 'Sa-Ltn'], $loop-glossary-entity/m:label)[1]"/>
                                                                
                                                                <li>
                                                                    <span>
                                                                        <xsl:attribute name="class">
                                                                            <xsl:value-of select="common:lang-class($loop-glossary-entity-label/@xml:lang)"/>
                                                                        </xsl:attribute>
                                                                        <xsl:value-of select="common:limit-str($loop-glossary-entity-label/data() ! fn:normalize-space(.), 150)"/>
                                                                    </span>
                                                                </li>
                                                                
                                                                <li class="small">
                                                                    <xsl:value-of select="$loop-glossary-entity/@xml:id"/>
                                                                </li>
                                                                
                                                                <li>
                                                                    <xsl:call-template name="entity-type-labels">
                                                                        <xsl:with-param name="entity" select="$loop-glossary-entity"/>
                                                                        <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                                                    </xsl:call-template>
                                                                </li>
                                                                
                                                                <li>
                                                                    <a target="_self" class="small">
                                                                        <xsl:attribute name="href">
                                                                            <xsl:call-template name="link-href">
                                                                                <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                                                <xsl:with-param name="add-parameters" select="'unlink-glossary=' || $loop-glossary-id"/>
                                                                            </xsl:call-template>
                                                                        </xsl:attribute>
                                                                        <xsl:value-of select="'un-link'"/>
                                                                    </a>
                                                                </li>
                                                                
                                                                <li>
                                                                    <a target="84000-glossary" class="small">
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $loop-glossary-entity/@xml:id, '&amp;view-mode=editor')"/>
                                                                        <xsl:value-of select="'84000 Glossary'"/>
                                                                    </a>
                                                                </li>
                                                                
                                                                <xsl:for-each select="/m:response/m:entity-flags/m:flag">
                                                                    <li>
                                                                        <xsl:choose>
                                                                            <xsl:when test="@id = $loop-glossary-instance/m:flag/@type">
                                                                                <span>
                                                                                    <xsl:attribute name="class" select="'label label-danger'"/>
                                                                                    <xsl:value-of select="m:label"/>
                                                                                    <xsl:value-of select="' / '"/>
                                                                                    <a target="_self">
                                                                                        <xsl:attribute name="href">
                                                                                            <xsl:call-template name="link-href">
                                                                                                <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                                                                <xsl:with-param name="add-parameters" select="'remove-flag=' || @id"/>
                                                                                            </xsl:call-template>
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="'un-flag'"/>
                                                                                    </a>
                                                                                </span>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <a target="_self" class="small">
                                                                                    <xsl:attribute name="href">
                                                                                        <xsl:call-template name="link-href">
                                                                                            <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                                                            <xsl:with-param name="add-parameters" select="'set-flag=' || @id"/>
                                                                                        </xsl:call-template>
                                                                                    </xsl:attribute>
                                                                                    <xsl:value-of select="'Set flag: '"/>
                                                                                    <xsl:value-of select="m:label"/>
                                                                                </a>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </li>
                                                                </xsl:for-each>
                                                                
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <li>
                                                                    <xsl:call-template name="entity-type-labels">
                                                                        <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                                                    </xsl:call-template>
                                                                </li>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </ul>
                                                    
                                                </xsl:with-param>
                                                
                                                <!-- Entity panel content -->
                                                <xsl:with-param name="content">
                                                    
                                                    <hr class="sml-margin"/>
                                                    
                                                    <xsl:call-template name="entity-form-warning">
                                                        <xsl:with-param name="entity" select="$loop-glossary-entity"/>
                                                    </xsl:call-template>
                                                    
                                                    <!-- Form: for editing/adding an entity -->
                                                    <xsl:call-template name="glossary-entity-form">
                                                        <xsl:with-param name="glossary-entry" select="$loop-glossary"/>
                                                        <xsl:with-param name="glossary-entity" select="$loop-glossary-entity"/>
                                                    </xsl:call-template>
                                                    
                                                </xsl:with-param>
                                            
                                            </xsl:call-template>
                                            
                                            <!-- Panel: Entity instances -->
                                            <xsl:if test="$loop-glossary-entity">
                                                <xsl:call-template name="expand-item">
                                                    
                                                    <xsl:with-param name="id" select="concat('entity-instances-', $loop-glossary-id)"/>
                                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                    <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity-instances'"/>
                                                    <xsl:with-param name="persist" select="true()"/>
                                                    
                                                    <xsl:with-param name="title">
                                                        <xsl:variable name="count-entity-instances" select="count($loop-glossary-entity/m:instance)"/>
                                                        <span>
                                                            <xsl:value-of select="' ↳ '"/>
                                                        </span>
                                                        <span class="badge badge-notification badge-info">
                                                            <xsl:value-of select="$count-entity-instances"/>
                                                        </span>
                                                        <span class="badge-text">
                                                            <xsl:value-of select="if($count-entity-instances eq 1) then 'matching element' else 'matching elements'"/>
                                                        </span>
                                                    </xsl:with-param>
                                                    
                                                    <xsl:with-param name="content">
                                                        
                                                        <hr class="sml-margin"/>
                                                        
                                                        <!-- List related glossary items -->
                                                        <xsl:for-each select="/m:response/m:entities/m:related/m:text[m:entry/@id = $loop-glossary-entity/m:instance/@id]">
                                                            
                                                            <xsl:sort select="@id/string()"/>
                                                            
                                                            <xsl:call-template name="related-text-entries">
                                                                <xsl:with-param name="related-text" select="."/>
                                                                <xsl:with-param name="entity" select="$loop-glossary-entity"/>
                                                                <xsl:with-param name="active-glossary-id" select="$loop-glossary/@id"/>
                                                                <xsl:with-param name="remove-instance-href">
                                                                    <xsl:call-template name="link-href">
                                                                        <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
                                                                        <xsl:with-param name="add-parameters" select="'remove-instance={instance-id}'"/>
                                                                    </xsl:call-template>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                            
                                                        </xsl:for-each>
                                                        
                                                        <!-- List related knowledgebase pages -->
                                                        <xsl:call-template name="knowledgebase-page-instance">
                                                            <xsl:with-param name="knowledgebase-page" select="/m:response/m:entities/m:related/m:page[@xml:id = $loop-glossary-entity/m:instance/@id]"/>
                                                            <xsl:with-param name="active-kb-id" select="''"/>
                                                        </xsl:call-template>
                                                        
                                                    </xsl:with-param>
                                                    
                                                </xsl:call-template>
                                            </xsl:if>
                                            
                                            <!-- Panel: Entity relations -->
                                            <xsl:if test="$loop-glossary-entity">
                                                <xsl:call-template name="expand-item">
                                                    
                                                    <xsl:with-param name="id" select="concat('entity-relations-', $loop-glossary-id)"/>
                                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                    <xsl:with-param name="active" select="$request-show-tab eq 'entity-relations'"/>
                                                    <xsl:with-param name="persist" select="true()"/>
                                                    
                                                    <xsl:with-param name="title">
                                                        
                                                        <xsl:variable name="count-relations" select="count($loop-glossary-entity-relations)"/>
                                                        <span>
                                                            <xsl:value-of select="' ↳ '"/>
                                                        </span>
                                                        <span class="badge badge-notification badge-info">
                                                            <xsl:value-of select="$count-relations"/>
                                                        </span>
                                                        <span class="badge-text">
                                                            <xsl:value-of select="if($count-relations eq 1) then 'related entity' else 'related entities'"/>
                                                        </span>
                                                         
                                                    </xsl:with-param>
                                                    
                                                    <xsl:with-param name="content">
                                                        
                                                        <hr class="sml-margin"/>
                                                        
                                                        <xsl:choose>
                                                            
                                                            <xsl:when test="$loop-glossary-entity-relations">
                                                                
                                                                <div class="sml-margin bottom">
                                                                    <xsl:call-template name="glossary-terms">
                                                                        <xsl:with-param name="entry" select="$loop-glossary"/>
                                                                    </xsl:call-template>
                                                                </div>
                                                                
                                                                <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                                                    
                                                                    <xsl:attribute name="id" select="concat('accordion-glossary-', $loop-glossary-id, '-relations')"/>
                                                                    
                                                                    <xsl:for-each select="$loop-glossary-entity-relations">
                                                                        
                                                                        <xsl:sort select="if(@predicate = 'isUnrelated') then 1 else 0"/>
                                                                        
                                                                        <xsl:variable name="relation" select="."/>
                                                                        <xsl:variable name="relation-entity" as="element(m:entity)?">
                                                                            <xsl:choose>
                                                                                <xsl:when test="$relation/@id eq $loop-glossary-entity/@xml:id">
                                                                                    <xsl:sequence select="key('related-entities', $relation/parent::m:entity/@xml:id, $root)[1]"/>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <xsl:sequence select="key('related-entities', $relation/@id, $root)[1]"/>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </xsl:variable>
                                                                        
                                                                        <xsl:call-template name="expand-item">
                                                                            
                                                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-glossary-', $loop-glossary-id, '-relations')"/>
                                                                            <xsl:with-param name="id" select="concat('glossary-', $loop-glossary-id, '-relation-', $relation-entity/@xml:id)"/>
                                                                            <xsl:with-param name="persist" select="true()"/>
                                                                            
                                                                            <xsl:with-param name="title">
                                                                                
                                                                                <div class="center-vertical align-left">
                                                                                    
                                                                                    <div>
                                                                                        <xsl:value-of select="' ↳ '"/>
                                                                                    </div>
                                                                                    
                                                                                    <div>
                                                                                        <ul class="list-inline inline-dots">
                                                                                            
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
                                                                                            
                                                                                            <xsl:variable name="relation-entity-label" select="($relation-entity/m:label[@xml:lang eq 'en'], $relation-entity/m:label[@xml:lang eq 'Sa-Ltn'], $relation-entity/m:label)[1]"/>
                                                                                            
                                                                                            <xsl:if test="$relation-entity-label">
                                                                                                <li>
                                                                                                    <span>
                                                                                                        <xsl:attribute name="class">
                                                                                                            <xsl:value-of select="common:lang-class($relation-entity-label/@xml:lang)"/>
                                                                                                        </xsl:attribute>
                                                                                                        <xsl:value-of select="common:limit-str($relation-entity-label/data(), 80)"/>
                                                                                                    </span>
                                                                                                </li>
                                                                                            </xsl:if>
                                                                                            
                                                                                            <li>
                                                                                                <xsl:call-template name="entity-type-labels">
                                                                                                    <xsl:with-param name="entity" select="$relation-entity"/>
                                                                                                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                                                                                </xsl:call-template>
                                                                                            </li>
                                                                                            
                                                                                            <xsl:if test="/m:response/m:entity-types/m:type[@glossary-type = $relation-entity/m:type/@type]">
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
                                                                                                    <xsl:with-param name="add-parameters" select="('form-action=merge-entities', 'predicate=removeRelation', 'entity-id=' || $relation-entity/@xml:id, 'target-entity-id=' || $loop-glossary-entity/@xml:id)"/>
                                                                                                </xsl:call-template>
                                                                                            </li>
                                                                                            
                                                                                        </ul>
                                                                                    </div>
                                                                                    
                                                                                </div>
                                                                                
                                                                            </xsl:with-param>
                                                                            
                                                                            <xsl:with-param name="content">
                                                                                
                                                                                <hr class="sml-margin"/>
                                                                                
                                                                                <xsl:call-template name="entity-option-content">
                                                                                    <xsl:with-param name="entity" select="$relation-entity"/>
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
                                            </xsl:if>
                                            
                                            <!-- Panel: Similar entities -->
                                            <xsl:call-template name="expand-item">
                                                
                                                <xsl:with-param name="id" select="concat('entity-similar-', $loop-glossary-id)"/>
                                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity-similar'"/>
                                                <xsl:with-param name="persist" select="true()"/>
                                                
                                                <xsl:with-param name="title">
                                                    
                                                    <xsl:variable name="count-similar-entities" select="count($loop-glossary/m:similar/m:entity)"/>
                                                    
                                                    <span>
                                                        <xsl:value-of select="' ↳ '"/>
                                                    </span>
                                                    
                                                    <span class="badge badge-notification badge-info">
                                                        <xsl:if test="$count-similar-entities eq 0">
                                                            <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="$count-similar-entities"/>
                                                    </span>
                                                    
                                                    <span class="badge-text">
                                                        <xsl:choose>
                                                            <xsl:when test="$loop-glossary-entity">
                                                                <xsl:choose>
                                                                    <xsl:when test="$count-similar-entities eq 1">
                                                                        <xsl:value-of select="'similar entity'"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="'similar entities'"/>
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
                                                        <xsl:with-param name="entry" select="$loop-glossary"/>
                                                        <xsl:with-param name="entry-entity" select="$loop-glossary-entity"/>
                                                        <xsl:with-param name="match-mode">
                                                            <xsl:choose>
                                                                <xsl:when test="$loop-glossary-entity">
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
                        </xsl:when>
                        <xsl:when test="not($request-filter eq 'blank-form')">
                            <p class="text-muted italic">
                                <xsl:value-of select="'No matching glossary entries'"/>
                            </p>
                        </xsl:when>
                    </xsl:choose>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title">
                <xsl:if test="$text[m:toh]">
                    <xsl:value-of select="$text/m:toh/m:full/data()"/>
                    <xsl:value-of select="' | '"/>
                </xsl:if>
                <xsl:value-of select="common:limit-str($main-title, 80)"/>
                <xsl:value-of select="' | '"/>
                <xsl:value-of select="'Glossary'"/>
                <xsl:value-of select="' | '"/>
                <xsl:value-of select="'84000 Project Management'"/>
            </xsl:with-param>
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
            
            <!-- Additional other parameters -->
            <xsl:sequence select="$add-parameters"/>
            
            <!-- Make sure it reloads despite the anchor -->
            <xsl:value-of select="concat('timestamp=', current-dateTime())"/>
            
        </xsl:variable>
        
        <xsl:value-of select="concat('/edit-glossary.html?', string-join($parameters, '&amp;'),'#selected-entity')"/>
        
    </xsl:template>
    
    <xsl:template name="form">
        
        <xsl:param name="first-record" as="xs:integer" select="$request-first-record"/>
        <xsl:param name="glossary-id" as="xs:string" select="''"/>
        <xsl:param name="show-tab" as="xs:string" select="''"/>
        <xsl:param name="form-action" as="xs:string" select="''"/>
        <xsl:param name="form-content" as="node()*" required="yes"/>
        <xsl:param name="form-class" as="xs:string" select="'form-horizontal'"/>
        <xsl:param name="target-id" as="xs:string" select="'selected-entity'"/>
        
        <form method="post" data-loading="Loading...">
            
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
        
        <xsl:param name="entry" as="element(m:entry)?"/>
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:variable name="entity-instance" select="$entity/m:instance[@type eq 'glossary-item'][@id eq $entry/@id]"/>
        
        <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
        
        <!-- Main term -->
        <xsl:variable name="main-term" select="$entry/m:term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq 'en'][1]"/>
        <xsl:variable name="element-id" select="string-join(('main-term', $entry/@id), '-')"/>
        <div class="form-group">
            <label for="{ $element-id }" class="col-sm-2 control-label">
                <xsl:value-of select="'Glossary main term:'"/>
            </label>
            <div class="col-sm-2">
                <input type="text" class="form-control" value="Translation" disabled="disabled"/>
            </div>
            <div class="col-sm-6">
                <input type="text" name="main-term" id="{ $element-id }" value="{ $main-term/text() }" class="form-control"/>
            </div>
        </div>
        
        <!-- Equivalent terms -->
        <xsl:variable name="source-terms" select="$entry/m:term[not(@type = ('definition','alternative'))][not(@xml:lang = ('en', 'bo'))]"/>
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
                
                <xsl:call-template name="term-input">
                    <xsl:with-param name="id" select="($entry/@id, 'new-glossary')[1]"/>
                    <xsl:with-param name="index" select="$index"/>
                    <xsl:with-param name="input-name" select="'term'"/>
                    <xsl:with-param name="label" select="'Equivalent(s):'"/>
                    <xsl:with-param name="term" select="$source-terms[$index]/text()"/>
                    <xsl:with-param name="lang" select="if(tokenize($source-terms[$index]/@type, '\s+')[. = ('semanticReconstruction')]) then concat($element-lang, '-sr') else if(tokenize($source-terms[$index]/@type, '\s+')[. = ('transliterationReconstruction')]) then concat($element-lang, '-tr') else if(tokenize($source-terms[$index]/@type, '\s+')[. = ('sourceAttested')]) then concat($element-lang, '-sa') else $element-lang"/>
                    <xsl:with-param name="status" select="($source-terms[$index]/@status, '')[1]"/>
                    <xsl:with-param name="language-options" select="('en', 'Bo-Ltn', 'Sa-Ltn', 'Sa-Ltn-sr', 'Sa-Ltn-tr', 'Sa-Ltn-sa', 'zh')"/>
                </xsl:call-template>
                
            </xsl:for-each>
            
            <!-- Add alternatives as Additional English terms -->
            <!-- This redundant if is added for exist 4.7.1 -->
            <xsl:if test="$entry">
                <xsl:for-each select="$entry/m:alternative">
                    
                    <xsl:call-template name="term-input">
                        <xsl:with-param name="id" select="$entry/@id"/>
                        <xsl:with-param name="index" select="$source-terms-count + position()"/>
                        <xsl:with-param name="input-name" select="'term'"/>
                        <xsl:with-param name="label" select="''"/>
                        <xsl:with-param name="term" select="text()"/>
                        <xsl:with-param name="lang" select="'en'"/>
                        <xsl:with-param name="language-options" select="('en', 'Bo-Ltn', 'Sa-Ltn', 'Sa-Ltn-sr', 'Sa-Ltn-tr', 'Sa-Ltn-sa', 'zh')"/>
                    </xsl:call-template>
                    
                </xsl:for-each>
            </xsl:if>
            
            <div class="row">
                <div class="col-sm-offset-2 col-sm-10">
                    <p class="text-muted small">
                        <xsl:call-template name="hyphen-help-text"/>
                    </p>
                </div>
            </div>
            
            <!-- Add more terms -->
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
            
            <label for="{ concat('glossary-type-', $entry/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Glossary type:'"/>
            </label>
            
            <div class="col-sm-2">
                <select name="glossary-type" id="{ concat('glossary-type-', $entry/@id) }" class="form-control">
                    <option value="term">
                        <xsl:if test="$entry[@type eq 'term']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Term'"/>
                    </option>
                    <option value="person">
                        <xsl:if test="$entry[@type eq 'person']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Person'"/>
                    </option>
                    <option value="place">
                        <xsl:if test="$entry[@type eq 'place']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Place'"/>
                    </option>
                    <option value="text">
                        <xsl:if test="$entry[@type eq 'text']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Text'"/>
                    </option>
                </select>
            </div>
            
        </div>
        
        <!-- Mode match|marked -->
        <div class="form-group">
            
            <label for="{ concat('glossary-mode-', $entry/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Find instances:'"/>
            </label>
            
            <div class="col-sm-2">
                <div class="radio">
                    <label>
                        <input type="radio" name="glossary-mode" value="match" id="{ concat('glossary-mode-', $entry/@id) }">
                            <xsl:if test="not($entry) or $entry[not(@mode eq 'marked')]">
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
                            <xsl:if test="$entry[@mode eq 'marked']">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Marked'"/>
                    </label>
                </div>
            </div>
            
        </div>
        
        <!-- Definition -->
        <xsl:variable name="definitions" select="$entry/m:definition[node()]"/>
        <xsl:variable name="entity-definitions" select="$entity/m:content[@type eq 'glossary-definition']"/>
        <div class="form-group">
            
            <label for="{ concat('term-definition-text-', $entry/@id, '-1') }" class="col-sm-2 control-label">
                <xsl:value-of select="'Definition:'"/>
            </label>
            
            <div class="col-sm-8 add-nodes-container">
                
                <xsl:for-each select="(1 to (if(count($definitions) gt 0) then count($definitions) else 1))">
                    <xsl:variable name="index" select="."/>
                    <xsl:variable name="element-name" select="concat('term-definition-text-', $index)"/>
                    <xsl:variable name="element-id" select="concat('term-definition-text-', $entry/@id, '-', $index)"/>
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
                    <xsl:with-param name="element-id" select="($entry/@id, 'new-glossary')[1]"/>
                </xsl:call-template>
            </div>
        </div>
        
        <!-- Include entity definition -->
        <!-- Submit button -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label" for="use-definition">
                <xsl:value-of select="'Definition status:'"/>
            </label>
            
            <div class="col-sm-6">
                <select name="use-definition" id="use-definition" class="form-control">
                    <option value="">
                        <xsl:value-of select="'INCOMPATIBLE: show either glossary definition or entity definition'"/>
                    </option>
                    <xsl:if test="$definitions and $entity-definitions">
                        <option value="both">
                            <xsl:if test="$entity-instance[@use-definition eq 'both']">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'COMPATIBLE: show both glossary definition and entity definition'"/>
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
        
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="entry-entity" as="element(m:entity)?" required="yes"/>
        <xsl:param name="match-mode" as="xs:string" required="yes"/>
        
        <!-- Form: search for similar entities -->
        <xsl:call-template name="form">
            
            <xsl:with-param name="glossary-id" select="$entry/@id"/>
            <xsl:with-param name="show-tab" select="'similar'"/>
            <xsl:with-param name="form-class" select="'form-horizontal sml-margin bottom'"/>
            <xsl:with-param name="target-id" select="concat('entity-search-', $entry/@id)"/>
            <xsl:with-param name="form-content">
                
                <div class="input-group">
                    <xsl:attribute name="id" select="concat('entity-search-', $entry/@id)"/>
                    <xsl:variable name="search-str" select="if($request-glossary-id eq $entry/@id) then $request-similar-search else ''"/>
                    <input type="text" name="similar-search" class="form-control" id="similar-search" value="{ $search-str }" placeholder="Widen search..."/>
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
            
            <xsl:when test="$entry/m:similar[m:entity]">
                
                <div class="sml-margin bottom">
                    <xsl:call-template name="glossary-terms">
                        <xsl:with-param name="entry" select="$entry"/>
                        <xsl:with-param name="list-class" select="'sml-margin top bottom'"/>
                    </xsl:call-template>
                </div>
                
                <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                    
                    <xsl:variable name="id" select="concat('accordion-glossary-', $entry/@id, '-entities')"/>
                    <xsl:attribute name="id" select="$id"/>
                    
                    <xsl:for-each select="$entry/m:similar/m:entity">
                        
                        <xsl:call-template name="entity-option">
                            <xsl:with-param name="entry" select="$entry"/>
                            <xsl:with-param name="entry-entity" select="$entry-entity"/>
                            <xsl:with-param name="entity" select="."/>
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
        
        <xsl:param name="entry" as="element(m:entry)" required="yes"/>
        <xsl:param name="entry-entity" as="element(m:entity)?" required="yes"/>
        <xsl:param name="entity" as="element(m:entity)" required="yes"/>
        
        <xsl:param name="match-mode" as="xs:string" required="yes"/>
        <xsl:param name="entity-search-form-id" as="xs:string" required="yes"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="concat('#accordion-glossary-', $entry/@id, '-entities')"/>
            <xsl:with-param name="id" select="concat('glossary-', $entry/@id, '-', $entity/@xml:id)"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                
                <!-- Form: resolving entites -->
                <xsl:call-template name="form">
                    <xsl:with-param name="form-action" select="if(not($entry-entity)) then 'match-entity' else 'merge-entities'"/>
                    <xsl:with-param name="form-class" select="'form-inline'"/>
                    <xsl:with-param name="show-tab" select="'similar'"/>
                    <xsl:with-param name="glossary-id" select="$entry/@id"/>
                    <xsl:with-param name="target-id" select="$entity-search-form-id"/>
                    <xsl:with-param name="form-content">
                        
                        <input type="hidden" name="similar-search" value="{ $request-similar-search }"/>
                        
                        <xsl:call-template name="entity-resolve-form-input">
                            
                            <xsl:with-param name="entity" select="$entry-entity"/>
                            <xsl:with-param name="target-entity" select="$entity"/>
                            <xsl:with-param name="predicates" select="/m:response/m:entity-predicates//m:predicate"/>
                            <xsl:with-param name="target-entity-label">
                                
                                <xsl:variable name="entity-label" select="($entity/m:label[@xml:lang eq 'en'], $entity/m:label[@xml:lang eq 'Sa-Ltn'], $entity/m:label)[1]"/>
                                
                                <ul class="list-inline inline-dots">
                                    
                                    <li class="small">
                                        <span>
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="common:lang-class($entity-label/@xml:lang)"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="common:limit-str($entity-label ! normalize-space(.), 80)"/>
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
                    <xsl:with-param name="active-glossary-id" select="$entry/@id"/>
                    <xsl:with-param name="active-kb-id" select="''"/>
                </xsl:call-template>
                
            </xsl:with-param>
            
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossary-entity-form">
        
        <xsl:param name="glossary-entry" as="element(m:entry)"/>
        <xsl:param name="glossary-entity" as="element(m:entity)?"/>
        
        <xsl:call-template name="form">
            
            <xsl:with-param name="show-tab" select="'entity'"/>
            <xsl:with-param name="form-action" select="'update-entity'"/>
            <xsl:with-param name="form-class" select="'form-horizontal'"/>
            <xsl:with-param name="glossary-id" select="$glossary-entry/@id"/>
            <xsl:with-param name="target-id" select="concat('expand-item-entity-', $glossary-entry/@id, '-detail')"/>
            
            <xsl:with-param name="form-content">
                
                <xsl:variable name="default-label" select="($glossary-entry/m:term[@xml:lang eq 'Bo-Ltn'], $glossary-entry/m:term[@xml:lang eq 'bo'], $glossary-entry/m:term[@xml:lang eq'Sa-Ltn'], $glossary-entry/m:term[@xml:lang])[1]"/>
                
                <xsl:call-template name="entity-form-input">
                    <xsl:with-param name="entity" select="$glossary-entity"/>
                    <xsl:with-param name="context-id" select="$glossary-entry/@id"/>
                    <xsl:with-param name="default-label-text" select="$default-label/text()"/>
                    <xsl:with-param name="default-label-lang" select="$default-label/@xml:lang"/>
                    <xsl:with-param name="default-entity-type" select="concat('eft-', $glossary-entry/@type)"/>
                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                    <xsl:with-param name="instance" select="$glossary-entity/m:instance[@id eq $glossary-entry/@id]"/>
                </xsl:call-template>
                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:location">
        
        <xsl:variable name="location-id" select="@id"/>
        <xsl:variable name="glossary" select="parent::m:locations/parent::m:entry"/>
        <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $glossary/@id, $root)"/>
        <xsl:variable name="cache-location" select="$glossary-cache-gloss/m:location[@id eq $location-id]"/>
        
        <xsl:variable name="cache-location-status" as="xs:string?">
            <xsl:choose>
                <xsl:when test="not($cache-location)">
                    <xsl:value-of select="'missing'"/>
                </xsl:when>
                <xsl:when test="$cache-location/@initial-version eq $text/@tei-version">
                    <xsl:value-of select="'updated'"/>
                </xsl:when>
                <xsl:when test="$cache-glosses-behind[@id eq $glossary/@id]">
                    <xsl:value-of select="'behind'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <div class="item tei-parser editor-mode rw-full-width pad { $cache-location-status }">
            
            <div class="small">
                <xsl:apply-templates select="xhtml:*"/>
            </div>
            
            <xsl:choose>
                <xsl:when test="$cache-location-status eq 'missing'">
                    <div>
                        <span class="label label-danger">
                            <xsl:value-of select="'Location not cached'"/>
                        </span>
                    </div>
                </xsl:when>
                <xsl:when test="$cache-location-status eq 'updated'">
                    <div>
                        <span class="label label-success">
                            <xsl:value-of select="concat('Newly cached in ', $text/@tei-version)"/>
                        </span>
                    </div>
                </xsl:when>
                <xsl:when test="$cache-location-status eq 'behind'">
                    <div>
                        <span class="label label-warning">
                            <xsl:value-of select="concat('Cached in ', ($glossary-cache-gloss/@tei-version, 'previous version')[1])"/>
                        </span>
                    </div>
                </xsl:when>
            </xsl:choose>
            
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
        <xsl:variable name="glossary-entry" select="ancestor::m:entry[@id][1]"/>
        
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
                        <xsl:value-of select="concat($reading-room-path, $link-href-query, if(contains($link-href-query, '?')) then '&amp;' else '?', 'highlight=', string-join($glossary-entry/m:term[@xml:lang eq 'bo'], ','), $link-href-hash)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$link/@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="class">
                <xsl:variable name="local-class" select="string-join(tokenize(@class, '\s+')[not(. = ('pop-up', 'log-click'))], ' ')"/>
                <xsl:choose>
                    <xsl:when test="$glossary-entry[@id eq $link/@data-glossary-id]">
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