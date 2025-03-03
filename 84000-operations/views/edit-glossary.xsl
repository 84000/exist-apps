<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="response" select="/m:response"/>
    <xsl:variable name="request-resource-id" select="$response/m:request/@resource-id"/>
    <xsl:variable name="request-resource-type" select="$response/m:request/@resource-type"/>
    <xsl:variable name="request-first-record" select="common:enforce-integer($response/m:request/@first-record)" as="xs:integer"/>
    <xsl:variable name="request-max-records" select="common:enforce-integer($response/m:request/@max-records)" as="xs:integer"/>
    <xsl:variable name="request-filter" select="$response/m:request/@filter"/>
    <xsl:variable name="request-search" select="$response/m:request/m:search[1]/text()"/>
    <xsl:variable name="request-similar-search" select="$response/m:request/m:similar-search[1]/text()"/>
    
    <xsl:variable name="request-glossary-id" select="$response/m:request/@glossary-id"/>
    <xsl:variable name="request-show-tab" select="$response/m:request/@show-tab"/>
    
    <xsl:variable name="text" select="$response/m:text[1]"/>
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
    <xsl:variable name="glossary" select="$response/m:glossary[1]"/>
    <xsl:variable name="glossary-cached-locations" select="$response/m:glossary-cached-locations[1]"/>
    <xsl:variable name="cache-slow" select="if($glossary-cached-locations/@seconds-to-build ! xs:decimal(.) gt 120) then true() else false()" as="xs:boolean"/>
    <xsl:variable name="cache-glosses-behind" select="$glossary-cached-locations/m:gloss[not(@tei-version eq $text/@tei-version)][m:location]"/>
    <xsl:variable name="cache-glosses-new-locations" select="$glossary-cached-locations/m:gloss[m:location/@initial-version = $text/@tei-version]"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Glossary'"/>
                    </h3>
                    
                    <!-- Title / status -->
                    <div class="top-vertical full-width sml-margin bottom">
                        
                        <div class="h3">
                            <a>
                                <xsl:attribute name="href" select="m:translation-href(($text/m:toh/@key)[1], (), (), (), (), $reading-room-path)"/>
                                <xsl:attribute name="target" select="concat(($text/m:toh/@key)[1], '.html')"/>
                                <xsl:value-of select="string-join(($text/m:toh/m:full, $main-title), ' / ')"/>
                            </a>
                        </div>
                        
                        <div class="text-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <!-- Links -->
                    <xsl:call-template name="text-links-list">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="disable-links" select="('edit-glossary')"/>
                        <xsl:with-param name="text-status" select="$response/m:text-statuses/m:status[@status-id eq $text/@status]"/>
                        <xsl:with-param name="glossary-filter" select="$request-filter"/>
                    </xsl:call-template>
                    
                    <!-- Status and filter rows -->
                    <xsl:if test="not($request-filter eq 'blank-form')">
                        
                        <hr class="sml-margin"/>
                        
                        <!-- Status / version row -->
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
                                        
                                        <xsl:variable name="glossary-status" select="$glossary/@status"/>
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
                                                        <xsl:value-of select="concat(format-number(count($cache-glosses-new-locations), '#,###'), ' changed')"/>
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
                                                            <xsl:value-of select="concat(format-number(count($cache-glosses-behind), '#,###'), ' behind'(:, $text/@tei-version:))"/>
                                                        </a>
                                                    </span>
                                                </xsl:when>
                                                <xsl:when test="count($glossary-cached-locations/m:gloss) eq 0">
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
                                            
                                            <xsl:if test="$glossary-cached-locations/m:gloss[not(m:location)]">
                                                <span class="label label-danger">
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="link-href">
                                                                <xsl:with-param name="filter" select="'no-locations'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                        <xsl:value-of select="concat(format-number(count($glossary-cached-locations/m:gloss[not(m:location)]), '#,###'), ' missing')"/>
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
                                                    
                                                    <a class="small underline">
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="link-href">
                                                                <xsl:with-param name="filter" select="'blank-form'"/>
                                                                <xsl:with-param name="search" select="''"/>
                                                                <xsl:with-param name="fragment-id" select="'#glossary-entry-new'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                        <xsl:variable name="callback-url" as="xs:string?">
                                                            <xsl:call-template name="link-href">
                                                                <xsl:with-param name="fragment-id" select="'#dummy'"/>
                                                            </xsl:call-template>
                                                        </xsl:variable>
                                                        <xsl:attribute name="data-editor-callbackurl" select="concat($operations-path, $callback-url)"/>
                                                        <xsl:attribute name="data-ajax-loading" select="'Loading form...'"/>
                                                        <xsl:value-of select="'Add a new entry'"/>
                                                    </a>
                                                    
                                                </li>
                                                
                                            </xsl:when>
                                            
                                            <!-- Disable if processing -->
                                            <xsl:otherwise>
                                                <li>
                                                    <a title="Re-load status" data-loading="Loading...">
                                                        <xsl:attribute name="href">
                                                            <xsl:call-template name="link-href"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="data-autoclick-seconds" select="120"/>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="'Job running, please wait...'"/>
                                                        </span>
                                                    </a>
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
                                        <xsl:if test="count($cache-glosses-behind) gt 0 and count($cache-glosses-behind) lt count($glossary-cached-locations/m:gloss)">
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
                                            
                                            <xsl:if test="$glossary-cached-locations[@seconds-to-build]">
                                                <xsl:choose>
                                                    <xsl:when test="$cache-slow">
                                                        <span class="label label-warning">
                                                            <xsl:value-of select="concat('previously this took: ', format-number(($glossary-cached-locations/@seconds-to-build ! xs:decimal(.) div 60), '#,##0.##'), ' minutes')"/>
                                                        </span>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <span class="label label-info">
                                                            <xsl:value-of select="concat('previously this took: ', format-number($glossary-cached-locations/@seconds-to-build, '#,##0.##'), ' seconds')"/>
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
                        
                        <!-- Filter / pagination row -->
                        <div class="center-vertical full-width">
                            
                            <div>
                                <!-- Form: filter page -->
                                <xsl:call-template name="form">
                                    
                                    <xsl:with-param name="form-id" select="'glossary-filter-form'"/>
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
                                                        <xsl:value-of select="'Full check'"/>
                                                    </option>
                                                    <option value="check-none">
                                                        <xsl:if test="$request-filter eq 'check-none'">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Entry only'"/>
                                                    </option>
                                                    <optgroup label="Filter by locations:">
                                                        <option value="check-locations">
                                                            <xsl:if test="$request-filter eq 'check-locations'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Check locations'"/>
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
                                                            <xsl:value-of select="'Check entities'"/>
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
                                                        <option value="exclusive-entities">
                                                            <xsl:if test="$request-filter eq 'exclusive-entities'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Exclusive entities'"/>
                                                        </option>
                                                        <option value="shared-entities">
                                                            <xsl:if test="$request-filter eq 'shared-entities'">
                                                                <xsl:attribute name="selected" select="'selected'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Shared entities'"/>
                                                        </option>
                                                    </optgroup>
                                                    <optgroup label="Flagged:">
                                                        <xsl:for-each select="$response/m:entity-flags/m:flag">
                                                            <option>
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
                                                <button class="btn btn-round" type="submit" data-loading="Applying filter...">
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
                        
                        <xsl:variable name="request-entity" select="$entities/id($response/m:request/@entity-id)" as="element(m:entity)?"/>
                        <xsl:variable name="form-id" select="string-join(('glossary-entry-new', $request-entity/@xml:id),'-')"/>
                        
                        <div id="{ $form-id }" class="data-container">
                            
                            <h4 class="sml-margin top bottom text-danger">
                                <xsl:choose>
                                    <xsl:when test="$root//m:request/m:default-term[text()]">
                                        <xsl:value-of select="'Add ' || $root//m:request/m:default-term[text()][1] || ' to ' || $text/m:toh/m:full"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Add a new entry to ' || $text/m:toh/m:full"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </h4>
                            
                            <hr class="sml-margin"/>
                            
                            <!-- Form: add new entry -->
                            <xsl:call-template name="form">
                                
                                <xsl:with-param name="form-id" select="string-join(($form-id, 'form'),'-')"/>
                                <xsl:with-param name="form-action" select="'update-glossary'"/>
                                <xsl:with-param name="form-class" select="'form-horizontal labels-left'"/>
                                <xsl:with-param name="form-content">
                                    
                                    <!-- Go to the normal list on adding a new item -->
                                    <input type="hidden" name="filter" value="check-all"/>
                                    
                                    <!-- Output entity if specified -->
                                    
                                    <xsl:if test="$request-entity">
                                        
                                        <div>
                                            
                                            <!-- Checkbox -->
                                            <div class="checkbox-inline">
                                                <label>
                                                    <input type="checkbox" name="entity-id" value="{ $request-entity/@xml:id }" checked="checked"/>
                                                    <xsl:value-of select="'Link to entity'"/>
                                                </label>
                                            </div>
                                            
                                            <!-- Summary -->
                                            <div class="sml-margin bottom">
                                                <ul class="list-inline inline-dots">
                                                    
                                                    <xsl:variable name="loop-glossary-entity-label" select="($request-entity/m:label[@xml:lang eq 'en'], $request-entity/m:label[@xml:lang eq 'Sa-Ltn'], $request-entity/m:label)[1]"/>
                                                    
                                                    <li>
                                                        <xsl:call-template name="entity-type-labels">
                                                            <xsl:with-param name="entity" select="$request-entity"/>
                                                            <xsl:with-param name="entity-types" select="$response/m:entity-types/m:type"/>
                                                        </xsl:call-template>
                                                    </li>
                                                    
                                                    <li>
                                                        <span class="{ common:lang-class($loop-glossary-entity-label/@xml:lang) }" title="{ common:normalize-data(string-join($loop-glossary-entity-label,' ')) }">
                                                            <xsl:value-of select="common:limit-str($loop-glossary-entity-label/data() ! fn:normalize-space(.), 90)"/>
                                                        </span>
                                                    </li>
                                                    
                                                    <li class="small">
                                                        <xsl:value-of select="$request-entity/@xml:id"/>
                                                    </li>
                                                    
                                                    <li>
                                                        <a target="84000-glossary" class="small">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $request-entity/@xml:id, '.html?view-mode=editor')"/>
                                                            <xsl:value-of select="'84000 Glossary Entry'"/>
                                                        </a>
                                                    </li>
                                                    
                                                </ul>
                                                
                                            </div>
                                            
                                            <!-- Definition -->
                                            <xsl:variable name="entity-definition" as="element()?">
                                                <xsl:call-template name="entity-definition">
                                                    <xsl:with-param name="entity" select="$request-entity"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <xsl:when test="$entity-definition">
                                                    <xsl:sequence select="$entity-definition"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <p class="text-muted small">
                                                        <xsl:value-of select="'[No shared definition]'"/>
                                                    </p>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                        <hr class="sml-margin"/>
                                        
                                    </xsl:if>
                                    
                                    <xsl:call-template name="glossary-form">
                                        <xsl:with-param name="entity" select="$request-entity"/>
                                    </xsl:call-template>
                                    
                                </xsl:with-param>
                                
                            </xsl:call-template>
                            
                        </div>
                        
                    </xsl:if>
                    
                    <!-- Loop through glossary items -->
                    <xsl:choose>
                        <xsl:when test="$glossary[m:entry]">
                            
                            <hr class="sml-margin"/>
                            
                            <xsl:for-each select="$glossary/m:entry">
                                
                                <xsl:variable name="loop-glossary" select="."/>
                                <xsl:variable name="loop-glossary-id" select="($loop-glossary/@id, 'new-glossary')[1]"/>
                                <xsl:variable name="loop-glossary-cached-locations-gloss" select="$glossary-cached-locations/m:gloss[@id eq $loop-glossary-id]"/>
                                
                                <xsl:variable name="loop-glossary-instance" select="key('entity-instance', $loop-glossary/@id, $root)[1]"/>
                                <xsl:variable name="loop-glossary-entity" select="$loop-glossary-instance/parent::m:entity"/>
                                <xsl:variable name="loop-glossary-entity-relations" select="$loop-glossary-entity/m:relation | $response/m:entities/m:related/m:entity[not(@xml:id = $loop-glossary-entity/m:relation/@id)]/m:relation[@id eq $loop-glossary-entity/@xml:id][not(@predicate eq 'sameAs')]" as="element(m:relation)*"/>
                                
                                <div>
                                    
                                    <xsl:attribute name="id" select="concat('glossary-entry-', $loop-glossary/@id)"/>
                                    <xsl:attribute name="class" select="'data-container replace'"/>
                                    
                                    <!-- Title -->
                                    <h3 class="sml-margin bottom">
                                        
                                        <xsl:if test="$loop-glossary[@active-item eq 'true']">
                                            <xsl:attribute name="id" select="'selected-entry'"/>
                                        </xsl:if>
                                        
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
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $loop-glossary-entity/@xml:id, '.html?view-mode=editor')"/>
                                                    <xsl:value-of select="'84000 Glossary Entry'"/>
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
                                        
                                    </h3>
                                    
                                    <!-- Definition -->
                                    <xsl:call-template name="combined-definitions">
                                        <xsl:with-param name="entry" select="$loop-glossary"/>
                                        <xsl:with-param name="entity" select="$loop-glossary-entity"/>
                                    </xsl:call-template>
                                    
                                    <!-- Set flags -->
                                    <xsl:if test="$loop-glossary-instance">
                                        <div class="sml-margin bottom">
                                            <xsl:call-template name="flag-options">
                                                <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                <xsl:with-param name="glossary-instance" select="$loop-glossary-instance"/>
                                                <xsl:with-param name="flag-options-href">
                                                    <xsl:call-template name="link-href">
                                                        <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                        <xsl:with-param name="add-parameters" select="'{flag-action}={flag-id}'"/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </div>
                                    </xsl:if>
                                    
                                    <!-- Accordion -->
                                    <div class="list-group accordion accordion-bordered accordion-background" role="tablist" aria-multiselectable="false">
                                        
                                        <xsl:attribute name="id" select="concat('accordion-', $loop-glossary-id)"/>
                                        
                                        <!-- Panel: Glossary form -->
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="id" select="concat('glossary-form-',$loop-glossary-id)"/>
                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                            <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'glossary-form'"/>
                                            <xsl:with-param name="persist" select="true()"/>
                                            
                                            <xsl:with-param name="title">
                                                
                                                <h4 class="no-top-margin no-bottom-margin">
                                                    <xsl:if test="@mode eq 'surfeit'">
                                                        <xsl:attribute name="class" select="'no-top-margin no-bottom-margin line-through'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Glossary entry:'"/>
                                                </h4>
                                                
                                                <xsl:call-template name="glossary-terms">
                                                    <xsl:with-param name="entry" select="."/>
                                                    <xsl:with-param name="languages" select="('Bo-Ltn','Sa-Ltn')"/>
                                                </xsl:call-template>
                                                
                                            </xsl:with-param>
                                            
                                            <xsl:with-param name="content">
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <!-- Form: edit glossary entry -->
                                                <xsl:call-template name="form">
                                                    
                                                    <xsl:with-param name="form-id" select="concat('glossary-form-',$loop-glossary-id)"/>
                                                    <xsl:with-param name="show-tab" select="'glossary-form'"/>
                                                    <xsl:with-param name="form-action" select="'update-glossary'"/>
                                                    <xsl:with-param name="form-class" select="'form-horizontal labels-left data-container'"/>
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
                                        <xsl:if test="$request-filter = ('check-locations', 'check-all', 'new-locations', 'no-locations', 'cache-behind') and $loop-glossary/m:locations">
                                            
                                            <xsl:variable name="locations-cache-new" select="$loop-glossary-cached-locations-gloss/m:location[@initial-version eq $text/@tei-version]"/>
                                            <xsl:variable name="glossary-locations-gloss" select="key('glossary-locations-gloss', $loop-glossary-id, $root)"/>
                                            <xsl:variable name="locations-not-cached" select="$loop-glossary/m:locations/m:location[not(@id = $glossary-locations-gloss/m:location/@id)]"/>
                                            <xsl:variable name="locations-cache-behind" select="$loop-glossary-cached-locations-gloss[m:location] and $cache-glosses-behind[@id eq $loop-glossary-id]"/>
                                            
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
                                                                    <xsl:when test="$loop-glossary-cached-locations-gloss[m:location/@initial-version = $text/@tei-version]">
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
                                                                        <xsl:value-of select="'location in the translation'"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="'locations in the translation'"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </span>
                                                        </div>
                                                        
                                                        <xsl:if test="not($loop-glossary-cached-locations-gloss/m:location)">
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
                                                    
                                                    <!-- Form: cache locations -->
                                                    <!-- Replace with Ajax call on opening -->
                                                    <xsl:call-template name="form">
                                                        
                                                        <xsl:with-param name="form-id" select="concat('glossary-locations-form-',$loop-glossary-id)"/>
                                                        <xsl:with-param name="form-class" select="'form-inline'"/>
                                                        <xsl:with-param name="show-tab" select="'expressions'"/>
                                                        
                                                        <xsl:with-param name="form-content">
                                                            
                                                            <input type="hidden" name="form-action" value="cache-locations"/>
                                                            <input type="hidden" name="glossary-id" value="{ $loop-glossary-id }"/>
                                                            <input type="hidden" name="ajax-target" value="{ concat('glossary-entry-', $loop-glossary-id) }"/>
                                                            <input type="hidden" name="max-records" value="1"/>
                                                            <!-- Override the filter as otherwise this won't get returned -->
                                                            <xsl:choose>
                                                                <xsl:when test="$request-filter = ('cache-behind', 'no-locations')">
                                                                    <input type="hidden" name="filter" value="check-locations"/>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                            
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
                                                                                        <xsl:value-of select="'Any instances in passages labelled as '"/>
                                                                                    </span>
                                                                                    
                                                                                    <span class="label label-danger">
                                                                                        <xsl:value-of select="'Location not cached'"/>
                                                                                    </span>
                                                                                    <span class="small">
                                                                                        <xsl:value-of select="' will not be linked in the public Reading Room.'"/>
                                                                                    </span>
                                                                                    <br/>
                                                                                    <span class="small">
                                                                                        <xsl:value-of select="'Select &#34;Cache locations&#34; on the right to cache this item, or re-cache all locations using the link in &#34;Batch update options&#34;.'"/>
                                                                                    </span>
                                                                                </div>
                                                                                
                                                                                <div>
                                                                                    <button type="submit" class="btn btn-danger btn-sm pull-right" data-loading="Caching locations...">
                                                                                        <xsl:choose>
                                                                                            <xsl:when test="$response/scheduler:job">
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
                                        <xsl:if test="$request-filter = ('check-entities', 'check-terms', 'check-people', 'check-places', 'check-texts', 'check-all', 'missing-entities', 'requires-attention', 'entity-definition', 'shared-entities', 'exclusive-entities')">
                                            
                                            <!-- Panel: Entity form -->
                                            <xsl:call-template name="expand-item">
                                                
                                                <xsl:with-param name="id" select="concat('entity-', $loop-glossary-id)"/>
                                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity'"/>
                                                <xsl:with-param name="persist" select="true()"/>
                                                
                                                <!-- Entity panel title -->
                                                <xsl:with-param name="title">
                                                    
                                                    <h4 class="no-top-margin no-bottom-margin">
                                                        <xsl:value-of select="'Shared entity:'"/>
                                                    </h4>
                                                    
                                                    <ul class="list-inline inline-dots">
                                                        <xsl:choose>
                                                            <xsl:when test="$loop-glossary-entity">
                                                                
                                                                <xsl:variable name="loop-glossary-entity-label" select="($loop-glossary-entity/m:label[@xml:lang eq 'en'], $loop-glossary-entity/m:label[@xml:lang eq 'Sa-Ltn'], $loop-glossary-entity/m:label)[1]"/>
                                                                
                                                                <li>
                                                                    <xsl:call-template name="entity-type-labels">
                                                                        <xsl:with-param name="entity" select="$loop-glossary-entity"/>
                                                                        <xsl:with-param name="entity-types" select="$response/m:entity-types/m:type"/>
                                                                    </xsl:call-template>
                                                                </li>
                                                                
                                                                <li>
                                                                    <span class="{ common:lang-class($loop-glossary-entity-label/@xml:lang) }" title="{ common:normalize-data(string-join($loop-glossary-entity-label,' ')) }">
                                                                        <xsl:value-of select="common:limit-str($loop-glossary-entity-label/data() ! fn:normalize-space(.), 90)"/>
                                                                    </span>
                                                                </li>
                                                                
                                                                <li class="small">
                                                                    <xsl:value-of select="$loop-glossary-entity/@xml:id"/>
                                                                </li>
                                                                
                                                                <li>
                                                                    <a target="_self" class="small" data-loading="Loading...">
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
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $loop-glossary-entity/@xml:id, '.html?view-mode=editor')"/>
                                                                        <xsl:value-of select="'84000 Glossary Entry'"/>
                                                                    </a>
                                                                </li>
                                                                
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <li>
                                                                    <xsl:call-template name="entity-type-labels">
                                                                        <xsl:with-param name="entity-types" select="$response/m:entity-types/m:type"/>
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
                                                
                                                <xsl:variable name="related-entry-texts" select="$response/m:entities/m:related/m:text[m:entry/@id = $loop-glossary-entity/m:instance/@id]"/>
                                                
                                                <xsl:call-template name="expand-item">
                                                    
                                                    <xsl:with-param name="id" select="concat('entity-instances-', $loop-glossary-id)"/>
                                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                                    <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-show-tab eq 'entity-instances'"/>
                                                    <xsl:with-param name="persist" select="true()"/>
                                                    
                                                    <xsl:with-param name="title">
                                                        
                                                        <xsl:variable name="count-entity-instances" select="count($loop-glossary-entity/m:instance[@id = $related-entry-texts/m:entry/@id])"/>
                                                        
                                                        <span>
                                                            <xsl:value-of select="' ↳ '"/>
                                                        </span>
                                                        
                                                        <span class="badge badge-notification badge-info">
                                                            <xsl:value-of select="$count-entity-instances"/>
                                                        </span>
                                                        
                                                        <span class="badge-text">
                                                            <xsl:value-of select="if($count-entity-instances eq 1) then 'grouped glossary entry' else 'grouped glossary entries'"/>
                                                        </span>
                                                        
                                                        <!-- Flag if the types don't match -->
                                                        <xsl:if test="not($response/m:entity-types/m:type[@id = $loop-glossary-entity/m:type/@type][@glossary-type eq $loop-glossary/@type])">
                                                            <xsl:value-of select="' '"/>
                                                            <span class="label label-warning">
                                                                <xsl:value-of select="'Types do not conform'"/>
                                                            </span>
                                                        </xsl:if>
                                                        
                                                    </xsl:with-param>
                                                    
                                                    <xsl:with-param name="content">
                                                        
                                                        <!-- List related glossary items -->
                                                        <xsl:for-each select="$related-entry-texts">
                                                            
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
                                                                <xsl:with-param name="set-flags-href">
                                                                    <xsl:call-template name="link-href">
                                                                        <xsl:with-param name="glossary-id" select="'{instance-id}'"/>
                                                                        <xsl:with-param name="add-parameters" select="'{flag-action}={flag-id}'"/>
                                                                    </xsl:call-template>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                            
                                                        </xsl:for-each>
                                                        
                                                        <!-- List related knowledgebase pages -->
                                                        <xsl:call-template name="knowledgebase-page-instance">
                                                            <xsl:with-param name="knowledgebase-page" select="$response/m:entities/m:related/m:page[@xml:id = $loop-glossary-entity/m:instance/@id]"/>
                                                            <xsl:with-param name="knowledgebase-active-id" select="''"/>
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
                                                        
                                                        <xsl:choose>
                                                            
                                                            <xsl:when test="$loop-glossary-entity-relations">
                                                                
                                                                <div class="list-group accordion accordion-bordered top-margin" role="tablist" aria-multiselectable="false">
                                                                    
                                                                    <xsl:attribute name="id" select="concat('accordion-glossary-', $loop-glossary-id, '-relations')"/>
                                                                    
                                                                    <div class="list-group-item">
                                                                        <xsl:call-template name="glossary-terms">
                                                                            <xsl:with-param name="entry" select="$loop-glossary"/>
                                                                            <xsl:with-param name="languages" select="('Bo-Ltn','Sa-Ltn')"/>
                                                                        </xsl:call-template>
                                                                    </div>
                                                                    
                                                                    <xsl:for-each select="$loop-glossary-entity-relations">
                                                                        
                                                                        <xsl:sort select="if(@predicate = ('isUnrelated', 'sameAs')) then 1 else 0"/>
                                                                        
                                                                        <xsl:variable name="relation" select="."/>
                                                                        
                                                                        <!-- Check if the relation is derived -->
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
                                                                        
                                                                        <!-- Reverse the predicate if the relation is derived -->
                                                                        <xsl:variable name="relation-predicate" as="element(m:predicate)?">
                                                                            <xsl:variable name="reverse-predicate" as="element(m:predicate)?">
                                                                                <xsl:if test="$relation/@id eq $loop-glossary-entity/@xml:id">
                                                                                    <xsl:sequence select="$response/m:entity-predicates//m:predicate[@reverse eq $relation/@predicate]"/>
                                                                                </xsl:if>
                                                                            </xsl:variable>
                                                                            <xsl:sequence select="($reverse-predicate, $response/m:entity-predicates//m:predicate[@xml:id eq $relation/@predicate])[1]"/>
                                                                        </xsl:variable>
                                                                        
                                                                        <xsl:call-template name="expand-item">
                                                                            
                                                                            <xsl:with-param name="accordion-selector" select="concat('#accordion-glossary-', $loop-glossary-id, '-relations')"/>
                                                                            <xsl:with-param name="id" select="concat('glossary-', $loop-glossary-id, '-relation-', ($relation-entity/@xml:id, $relation/@id)[1])"/>
                                                                            <xsl:with-param name="persist" select="true()"/>
                                                                            
                                                                            <xsl:with-param name="title">
                                                                                
                                                                                <div class="center-vertical align-left">
                                                                                    
                                                                                    <div>
                                                                                        <xsl:value-of select="' ↳ '"/>
                                                                                    </div>
                                                                                    
                                                                                    <div>
                                                                                        <ul class="list-inline inline-dots">
                                                                                            
                                                                                            <!-- Predicate -->
                                                                                            <li>
                                                                                                <span>
                                                                                                    <xsl:choose>
                                                                                                        <xsl:when test="$relation-predicate[@xml:id = ('isUnrelated', 'sameAs')]">
                                                                                                            <xsl:attribute name="class" select="'label label-default'"/>
                                                                                                        </xsl:when>
                                                                                                        <xsl:otherwise>
                                                                                                            <xsl:attribute name="class" select="'label label-success'"/>
                                                                                                        </xsl:otherwise>
                                                                                                    </xsl:choose>
                                                                                                    <xsl:value-of select="$relation-predicate/m:label"/>
                                                                                                    <xsl:value-of select="':'"/>
                                                                                                </span>
                                                                                            </li>
                                                                                            
                                                                                            <!-- Entity label -->
                                                                                            <xsl:variable name="relation-entity-label" select="($relation-entity/m:label[@xml:lang eq 'en'], $relation-entity/m:label[@xml:lang eq 'Sa-Ltn'], $relation-entity/m:label, $relation/m:label)[1]"/>
                                                                                            <li>
                                                                                                <xsl:choose>
                                                                                                    <xsl:when test="$relation-entity-label">
                                                                                                        <span>
                                                                                                            <xsl:attribute name="class">
                                                                                                                <xsl:value-of select="common:lang-class($relation-entity-label/@xml:lang)"/>
                                                                                                            </xsl:attribute>
                                                                                                            <xsl:value-of select="common:limit-str($relation-entity-label/data(), 80)"/>
                                                                                                        </span>
                                                                                                    </xsl:when>
                                                                                                    <xsl:otherwise>
                                                                                                        <xsl:value-of select="$relation/@id"/>
                                                                                                    </xsl:otherwise>
                                                                                                </xsl:choose>
                                                                                            </li>
                                                                                            
                                                                                            <xsl:if test="$relation-entity">
                                                                                                
                                                                                                <!-- Type -->
                                                                                                <li>
                                                                                                    <xsl:call-template name="entity-type-labels">
                                                                                                        <xsl:with-param name="entity" select="$relation-entity"/>
                                                                                                        <xsl:with-param name="entity-types" select="$response/m:entity-types/m:type"/>
                                                                                                    </xsl:call-template>
                                                                                                </li>
                                                                                                
                                                                                                <!-- Glossary link -->
                                                                                                <xsl:if test="$response/m:entity-types/m:type[@glossary-type = $relation-entity/m:type/@type]">
                                                                                                    <li>
                                                                                                        <a target="84000-glossary" class="small">
                                                                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $relation/@id, '.html?view-mode=editor')"/>
                                                                                                            <xsl:value-of select="'84000 Glossary Entry'"/>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                </xsl:if>
                                                                                                
                                                                                                <!-- Remove relation link -->
                                                                                                <li>
                                                                                                    <xsl:call-template name="link">
                                                                                                        <xsl:with-param name="link-text" select="'remove relation'"/>
                                                                                                        <xsl:with-param name="link-class" select="'small'"/>
                                                                                                        <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                                                                        <xsl:with-param name="add-parameters" select="('form-action=merge-entities', 'predicate=removeRelation', 'entity-id=' || $relation-entity/@xml:id, 'target-entity-id=' || $loop-glossary-entity/@xml:id)"/>
                                                                                                    </xsl:call-template>
                                                                                                </li>
                                                                                                
                                                                                            </xsl:if>
                                                                                            
                                                                                        </ul>
                                                                                    </div>
                                                                                    
                                                                                </div>
                                                                                
                                                                            </xsl:with-param>
                                                                            
                                                                            <xsl:with-param name="content">
                                                                                
                                                                                <hr class="sml-margin"/>
                                                                                
                                                                                <xsl:if test="$relation-entity">
                                                                                    <xsl:call-template name="entity-option-content">
                                                                                        <xsl:with-param name="entity" select="$relation-entity"/>
                                                                                        <xsl:with-param name="active-glossary-id" select="$loop-glossary-id"/>
                                                                                        <xsl:with-param name="active-knowledgebase-id" select="''"/>
                                                                                    </xsl:call-template>
                                                                                </xsl:if>
                                                                                
                                                                                <xsl:if test="$relation[@predicate eq 'sameAs']">
                                                                                    <p class="text-muted italic">
                                                                                        <xsl:value-of select="'Requests for ' || $relation/@id || ' will be directed to the merged entity ' || $loop-glossary-entity/@xml:id"/>
                                                                                    </p>
                                                                                </xsl:if>
                                                                                
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
                                            
                                            <!-- Panel: Similar entities / suggested matches -->
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
                                                            <xsl:when test="$count-similar-entities eq 1">
                                                                <xsl:value-of select="'suggested match'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'suggested matches'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    
                                                </xsl:with-param>
                                                
                                                <xsl:with-param name="content">
                                                    
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
                            
                            <hr class="sml-margin"/>
                            
                            <p class="text-muted italic">
                                <xsl:value-of select="'No matching glossary entries'"/>
                            </p>
                            
                        </xsl:when>
                    </xsl:choose>
                    
                </xsl:with-param>
                
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                    <!-- Pop-up for tei-editor -->
                    <xsl:call-template name="tei-editor-footer"/>
                    
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
        <xsl:param name="fragment-id" select="'#selected-entry'"/>
        
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
        
        <xsl:value-of select="concat('/edit-glossary.html?', string-join($parameters, '&amp;'), $fragment-id)"/>
        
    </xsl:template>
    
    <xsl:template name="form">
        
        <xsl:param name="form-id" as="xs:string"/>
        <xsl:param name="form-action" as="xs:string" select="''"/>
        <xsl:param name="form-content" as="node()*" required="yes"/>
        <xsl:param name="form-class" as="xs:string" select="'form-horizontal'"/>
        <xsl:param name="first-record" as="xs:integer" select="$request-first-record"/>
        <xsl:param name="show-tab" as="xs:string" select="''"/>
        
        <form method="post" data-loading="Loading...">
            
            <xsl:variable name="ajax-target" select="$form-content//*[@name eq 'ajax-target']/@value" as="xs:string?"/>
            <xsl:choose>
                <xsl:when test="$ajax-target">
                    <xsl:attribute name="action" select="'/edit-glossary.html'"/>
                    <xsl:attribute name="data-ajax-target" select="concat('#', $ajax-target)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="action" select="'/edit-glossary.html#selected-entry'"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:attribute name="id" select="$form-id"/>
            <xsl:attribute name="class" select="$form-class"/>
            
            <!-- Maintain the state of the page -->
            <input type="hidden" name="resource-id" value="{ $request-resource-id }"/>
            <input type="hidden" name="resource-type" value="{ $request-resource-type }"/>
            <input type="hidden" name="first-record" value="{ $first-record }"/>
            
            <!-- Allow the option to override with input in the form-content -->
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
            
            <xsl:if test="$show-tab gt ''">
                <input type="hidden" name="show-tab" value="{ $show-tab }"/>
            </xsl:if>
            
            <xsl:sequence select="$form-content"/>
            
        </form>
        
    </xsl:template>
    
    <xsl:template name="glossary-form">
        
        <xsl:param name="entry" as="element(m:entry)?"/>
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:choose>
            <xsl:when test="$entry[@id]">
                <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
                <input type="hidden" name="ajax-target" value="{ concat('glossary-entry-', $entry/@id) }"/>
                <input type="hidden" name="max-records" value="1"/>
            </xsl:when>
            <xsl:otherwise>
                <!--<input type="hidden" name="ajax-target" value="glossary-entry-new"/>-->
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Feedback if returned after update -->
        <xsl:if test="$response/m:updates/m:updated[@update][@node eq 'glossary-item'] and $entry[@id eq $request-glossary-id]">
            <div class="top-margin">
                <div class="alert alert-success alert-temporary small" role="alert">
                    <xsl:value-of select="'Updated'"/>
                </div>
            </div>
        </xsl:if>
        
        <!-- Main term -->
        <xsl:variable name="preferred-translation" select="$entity/m:content[@type eq 'preferred-translation']"/>
        <xsl:variable name="main-term" select="($entry/m:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type eq 'translationAlternative')], $preferred-translation)[1]"/>
        <xsl:variable name="element-id" select="string-join(('main-term', $entry/@id), '-')"/>
        <div class="form-group">
            <xsl:if test="$preferred-translation">
                <xsl:choose>
                    <xsl:when test="$main-term ! normalize-space(.) eq $preferred-translation ! normalize-space(.)">
                        <xsl:attribute name="class" select="'form-group has-success'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class" select="'form-group has-warning'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <label for="{ $element-id }" class="col-sm-2 control-label">
                <xsl:value-of select="'Translated term:'"/>
            </label>
            <div class="col-sm-8">
                <input type="text" name="main-term" id="{ $element-id }" value="{ $main-term/text() }" class="form-control" required="required"/>
            </div>
            <xsl:if test="$preferred-translation">
                <div class="col-sm-offset-2 col-sm-8">
                    <span class="help-block">
                        <xsl:value-of select="'Preferred translation: ' || $preferred-translation"/>
                    </span>
                </div>
            </xsl:if>
        </div>
        
        <!-- Equivalent terms -->
        <xsl:variable name="source-terms" select="$entry/m:term[not(@xml:lang = ('en', 'bo'))][not(@type eq 'translationAlternative')]"/>
        <xsl:variable name="source-terms-count" select="count($source-terms)"/>
        <div class="add-nodes-container">
            
            <!-- Add alternatives as Additional English terms -->
            <xsl:for-each select="$entry/m:alternative">
                
                <xsl:call-template name="term-input">
                    <xsl:with-param name="id" select="$entry/@id"/>
                    <xsl:with-param name="index" select="$source-terms-count + position()"/>
                    <xsl:with-param name="input-name" select="'term'"/>
                    <xsl:with-param name="label" select="''"/>
                    <xsl:with-param name="term-text" select="text()"/>
                    <xsl:with-param name="lang" select="'en'"/>
                    <xsl:with-param name="language-options" select="('en-alt', 'Bo-Ltn', 'Sa-Ltn', 'zh', 'Pi-Ltn')"/>
                </xsl:call-template>
                
            </xsl:for-each>
            
            <!-- Add input for Sanskrit and Wylie if this is new -->
            <xsl:for-each select="(1 to (if($source-terms-count gt 0) then count($source-terms) else 2))">
                
                <xsl:variable name="index" select="."/>
                
                <!-- Add fields if there is no existing Wylie or Sanskrit -->
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
                
                <xsl:variable name="term-text-default" as="xs:string?">
                    <xsl:if test="not($source-terms[$index][text()])">
                        <xsl:value-of select="$root//m:request/m:default-term[@xml:lang eq $element-lang]"/>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:call-template name="term-input">
                    <xsl:with-param name="id" select="($entry/@id, 'new-glossary')[1]"/>
                    <xsl:with-param name="index" select="$index"/>
                    <xsl:with-param name="input-name" select="'term'"/>
                    <xsl:with-param name="label" select="'Equivalent(s):'"/>
                    <xsl:with-param name="term-text" select="($source-terms[$index]/text(), $term-text-default)[1]"/>
                    <xsl:with-param name="lang" select="$element-lang"/>
                    <xsl:with-param name="type" select="($source-terms[$index]/@type, $root//m:attestation-types/m:attestation-type[m:appliesToLang[@xml:lang eq $element-lang][@default]][1]/@id)[1]"/>
                    <xsl:with-param name="status" select="($source-terms[$index]/@status, if($request-resource-type eq 'translation') then 'unverified' else ())[1]"/>
                    <xsl:with-param name="language-options" select="('en-alt', 'Bo-Ltn', 'Sa-Ltn', 'zh', 'Pi-Ltn')"/>
                    <xsl:with-param name="type-options" select="$root//m:attestation-types/m:attestation-type[m:appliesToLang/@xml:lang = $element-lang]"/>
                </xsl:call-template>
                
            </xsl:for-each>
            
            <!-- Add more terms -->
            <div class="row">
                
                <div class="col-sm-2">
                    <a href="#add-nodes" class="add-nodes pull-right">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a term'"/>
                    </a>
                </div>
                
                <div class="col-sm-10">
                    <span class="text-muted small">
                        <xsl:value-of select="'Additional Translation terms will be added as alternative spellings'"/>
                    </span>
                </div>
                
            </div>
            
            <!-- Hyphen help text -->
            <div class="row">
                <div class="col-sm-offset-2 col-sm-10">
                    <span class="text-muted small">
                        <xsl:call-template name="hyphen-help-text"/>
                    </span>
                </div>
            </div>
        
        </div>
        
        <hr class="sml-margin"/>
        
        <!-- Type term|person|place|text -->
        <div class="form-group">
            
            <label for="{ concat('glossary-type-', $entry/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Glossary type:'"/>
            </label>
            
            <xsl:variable name="entry-type" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="$entry[@type = ('term','person','place''text')]">
                        <xsl:value-of select="$entry/@type"/>
                    </xsl:when>
                    <xsl:when test="$entity[m:type]">
                        <xsl:value-of select="($response/m:entity-types/m:type[@id = $entity/m:type/@type])[last()]/@glossary-type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'term'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <div class="col-sm-10">
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-type" value="term" id="{ concat('glossary-type-', $entry/@id) }">
                            <xsl:if test="$entry-type eq 'term'">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Term'"/>
                    </label>
                </div>
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-type" value="person">
                            <xsl:if test="$entry-type eq 'person'">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Person'"/>
                    </label>
                </div>
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-type" value="place">
                            <xsl:if test="$entry-type eq 'place'">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Place'"/>
                    </label>
                </div>
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-type" value="text">
                            <xsl:if test="$entry-type eq 'text'">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Text'"/>
                    </label>
                </div>
            </div>
             
        </div>
        
        <!-- Mode match|marked -->
        <div class="form-group">
            
            <label for="{ concat('glossary-mode-', $entry/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Find instances:'"/>
            </label>
            
            <div class="col-sm-10">
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-mode" value="match" id="{ concat('glossary-mode-', $entry/@id) }">
                            <xsl:if test="not($entry) or $entry[not(@mode = ('marked', 'surfeit'))]">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Match'"/>
                    </label>
                </div>
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-mode" value="marked">
                            <xsl:if test="$entry[@mode eq 'marked']">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Marked'"/>
                    </label>
                </div>
                <div class="radio-inline">
                    <label>
                        <input type="radio" name="glossary-mode" value="surfeit">
                            <xsl:if test="$entry[@mode eq 'surfeit']">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Surfeit'"/>
                    </label>
                </div>
            </div>
            
        </div>
        
        <hr class="sml-margin"/>
        
        <!-- Definition -->
        <xsl:variable name="entry-definition" select="$entry/m:definition[descendant::text()[normalize-space()]]"/>
        <xsl:variable name="entity-definition" select="$entity/m:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]"/>
        <div class="form-group">
            
            <label for="{ concat('term-definition-text-', $entry/@id, '-1') }" class="col-sm-2 control-label">
                <xsl:value-of select="'Definition in this text:'"/>
            </label>
            
            <div class="col-sm-10 add-nodes-container">
                
                <xsl:variable name="entry-definition-paragraphs" select="$entry/m:definition/tei:p[descendant::text()[normalize-space()]]"/>
                <xsl:for-each select="(1 to (if(count($entry-definition-paragraphs) gt 0) then count($entry-definition-paragraphs) else 1))">
                    <xsl:variable name="index" select="."/>
                    <xsl:variable name="element-name" select="concat('term-definition-text-', $index)"/>
                    <xsl:variable name="element-id" select="concat('term-definition-text-', $entry/@id, '-', $index)"/>
                    <div class="sml-margin bottom add-nodes-group">
                        <textarea name="{ $element-name }" id="{ $element-id }" class="form-control">
                            
                            <xsl:variable name="definition-unescaped">
                                <unescaped xmlns="http://read.84000.co/ns/1.0">
                                    <xsl:sequence select="$entry-definition-paragraphs[$index]/node()"/>
                                </unescaped>
                            </xsl:variable>
                            
                            <xsl:variable name="definition-escaped">
                                <xsl:apply-templates select="$definition-unescaped"/>
                            </xsl:variable>
                            
                            <xsl:attribute name="rows" select="ops:textarea-rows(string-join($definition-escaped/m:escaped/text()), 2, 130)"/>
                            
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
            <div class="col-sm-offset-2 col-sm-10">
                <xsl:call-template name="definition-tag-reference">
                    <xsl:with-param name="element-id" select="($entry/@id, 'new-glossary')[1]"/>
                </xsl:call-template>
            </div>
        </div>
        
        <!-- Include entity definition -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label" for="use-definition">
                <xsl:value-of select="'Definition status:'"/>
            </label>
            
            <div class="col-sm-10">
                <select name="use-definition" id="use-definition" class="form-control">
                    <option value="">
                        <xsl:value-of select="'Text preferred: only show an entity definition if there is no glossary definition (default)'"/>
                    </option>
                    <!-- Handle this in the update module
                    <xsl:if test="$entry-definition and $entity-definition">-->
                        <option value="override">
                            <xsl:if test="$entry-definition[@use-definition eq 'override']">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Entity preferred: override the glossary definition with the entity definition'"/>
                        </option>
                        <option value="prepend">
                            <xsl:if test="$entry-definition[@use-definition = ('both', 'prepend')]">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Prepend entity: first the entity definition, then the glossary definition'"/>
                        </option>
                        <option value="append">
                            <xsl:if test="$entry-definition[@use-definition eq 'append']">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Append entity: first the glossary definition, then the entity definition'"/>
                        </option>
                        <option value="incompatible">
                            <xsl:if test="$entry-definition[@use-definition eq 'incompatible']">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Incompatible: show the glossary definition in the text, but hide in the cumulative glossary'"/>
                        </option>
                    <!--</xsl:if>-->
                </select>
            </div>
            
        </div>
        
        <hr class="sml-margin"/>
        
        <!-- Submit button -->
        <div class="form-group">
            <div class="col-sm-12">
                
                <xsl:if test="$response/m:text[not(@locked-by-user gt '')] and $entry[@id]">
                    <a class="btn btn-danger" target="_self" data-loading="Deleting entry..." data-confirm="Are you sure you want to delete this glossary entry?">
                        <xsl:attribute name="href">
                            <xsl:call-template name="link-href">
                                <xsl:with-param name="max-records" select="''"/>
                                <xsl:with-param name="first-record" select="'1'"/>
                                <xsl:with-param name="glossary-id" select="$entry/@id"/>
                                <!-- update-glossary with no term deletes the record -->
                                <xsl:with-param name="add-parameters" select="('form-action=update-glossary', 'main-term=')"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:value-of select="'Delete'"/>
                    </a>
                </xsl:if>
                
                <button type="submit" class="btn btn-primary pull-right" data-loading="Applying changes...">
                    <xsl:if test="$response/m:text[@locked-by-user gt '']">
                        <xsl:attribute name="disabled" select="'disabled'"/>
                    </xsl:if>
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
            
            <xsl:with-param name="form-id" select="concat('glossary-similar-form-',$entry/@id)"/>
            <xsl:with-param name="form-class" select="'form-horizontal top-margin sml-margin bottom'"/>
            <xsl:with-param name="show-tab" select="'entity-similar'"/>
            
            <xsl:with-param name="form-content">
                
                <div class="input-group">
                    
                    <xsl:attribute name="id" select="concat('entity-search-', $entry/@id)"/>
                    
                    <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
                    <input type="hidden" name="ajax-target" value="{ concat('glossary-entry-', $entry/@id) }"/>
                    <input type="hidden" name="max-records" value="1"/>
                    
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
                
                <div class="list-group accordion accordion-bordered" role="tablist" aria-multiselectable="false">
                    
                    <xsl:variable name="id" select="concat('accordion-glossary-', $entry/@id, '-entities')"/>
                    <xsl:attribute name="id" select="$id"/>
                    
                    <div class="list-group-item">
                        <xsl:call-template name="glossary-terms">
                            <xsl:with-param name="entry" select="$entry"/>
                            <xsl:with-param name="languages" select="('Bo-Ltn','Sa-Ltn')"/>
                        </xsl:call-template>
                    </div>
                    
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
                    
                    <xsl:with-param name="form-id" select="concat('entity-similar-form-', $entry/@id, '-', $entity/@xml:id)"/>
                    <xsl:with-param name="form-action" select="if(not($entry-entity)) then 'match-entity' else 'merge-entities'"/>
                    <xsl:with-param name="form-class" select="'form-inline'"/>
                    <xsl:with-param name="show-tab" select="'entity-similar'"/>
                    
                    <xsl:with-param name="form-content">
                        
                        <input type="hidden" name="similar-search" value="{ $request-similar-search }"/>
                        <input type="hidden" name="glossary-id" value="{ $entry/@id }"/>
                        <input type="hidden" name="ajax-target" value="{ concat('glossary-entry-', $entry/@id) }"/>
                        <input type="hidden" name="max-records" value="1"/>
                        
                        <!-- Override the filter as otherwise this won't get returned -->
                        <xsl:choose>
                            <xsl:when test="$request-filter = ('missing-entities')">
                                <input type="hidden" name="filter" value="check-entities"/>
                            </xsl:when>
                        </xsl:choose>
                        
                        <xsl:call-template name="entity-resolve-form-input">
                            
                            <xsl:with-param name="entity" select="$entry-entity"/>
                            <xsl:with-param name="target-entity" select="$entity"/>
                            <xsl:with-param name="predicates" select="$response/m:entity-predicates//m:predicate"/>
                            <xsl:with-param name="target-entity-label">
                                
                                <xsl:variable name="entity-label" select="($entity/m:label[@xml:lang eq 'en'], $entity/m:label[@xml:lang eq 'Sa-Ltn'], $entity/m:label)[1]"/>
                                <xsl:variable name="entity-instance-entry-definition" as="xs:string?">
                                    <xsl:if test="count($entity/m:instance) eq 1">
                                        <xsl:value-of select="string-join($response/m:entities/m:related/m:text/m:entry[@id = $entity/m:instance/@id]/m:definition/tei:p[descendant::text()[normalize-space()]] ! string-join(descendant::text()), ' ')"/>
                                    </xsl:if>
                                </xsl:variable>
                                <xsl:variable name="entity-label-limited" select="common:limit-str($entity-label ! normalize-space(.), (if($entity-instance-entry-definition) then 70 else 90) - string-length(string-join($response/m:entity-types/m:type/text(), ' ')))"/>
                                <xsl:variable name="entity-instance-entry-definition-limited" select="common:limit-str($entity-instance-entry-definition ! normalize-space(.), (90 - string-length(string-join(($entity-label-limited, $response/m:entity-types/m:type/text()), ' '))))"/>
                                
                                <ul class="list-inline inline-dots">
                                    
                                    <li>
                                        <xsl:call-template name="entity-type-labels">
                                            <xsl:with-param name="entity" select="$entity"/>
                                            <xsl:with-param name="entity-types" select="$response/m:entity-types/m:type"/>
                                        </xsl:call-template>
                                    </li>
                                    
                                    
                                    <li class="small">
                                        <span>
                                            <xsl:attribute name="class" select="common:lang-class($entity-label/@xml:lang)"/>
                                            <xsl:attribute name="title" select="$entity-label ! normalize-space(.)"/>
                                            <xsl:value-of select="$entity-label-limited"/>
                                        </span>
                                    </li>
                                    
                                    <li class="small">
                                        <xsl:value-of select="concat('Groups ', count($entity/m:instance))"/>
                                    </li>
                                    
                                    <xsl:if test="$entity-instance-entry-definition">
                                        <li class="small text-muted">
                                            <xsl:attribute name="title" select="$entity-instance-entry-definition"/>
                                            <xsl:value-of select="$entity-instance-entry-definition-limited"/>
                                        </li>
                                    </xsl:if>
                                    
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
                    <xsl:with-param name="active-knowledgebase-id" select="''"/>
                </xsl:call-template>
                
            </xsl:with-param>
            
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossary-entity-form">
        
        <xsl:param name="glossary-entry" as="element(m:entry)"/>
        <xsl:param name="glossary-entity" as="element(m:entity)?"/>
        
        <!-- Form: entity form -->
        <xsl:call-template name="form">
            
            <xsl:with-param name="form-action" select="'update-entity'"/>
            <xsl:with-param name="form-id" select="string-join(('entity-form', $glossary-entry/@id, $glossary-entity/@xml:id), '-')"/>
            <xsl:with-param name="form-class" select="'form-horizontal labels-left'"/>
            <xsl:with-param name="show-tab" select="'entity'"/>
            
            <xsl:with-param name="form-content">
                
                <input type="hidden" name="glossary-id" value="{ $glossary-entry/@id }"/>
                <input type="hidden" name="ajax-target" value="{ concat('glossary-entry-', $glossary-entry/@id) }"/>
                <input type="hidden" name="max-records" value="1"/>
                
                <!-- Override the filter as otherwise this won't get returned -->
                <xsl:choose>
                    <xsl:when test="$request-filter = ('missing-entities')">
                        <input type="hidden" name="filter" value="check-entities"/>
                    </xsl:when>
                </xsl:choose>
                
                <xsl:variable name="default-label" select="($glossary-entry/m:term[@xml:lang eq 'Bo-Ltn'], $glossary-entry/m:term[@xml:lang eq 'bo'], $glossary-entry/m:term[@xml:lang eq'Sa-Ltn'], $glossary-entry/m:term[@xml:lang])[1]"/>
                
                <xsl:call-template name="entity-form-input">
                    <xsl:with-param name="entity" select="$glossary-entity"/>
                    <xsl:with-param name="context-id" select="$glossary-entry/@id"/>
                    <xsl:with-param name="default-label-text" select="$default-label/text()"/>
                    <xsl:with-param name="default-label-lang" select="$default-label/@xml:lang"/>
                    <xsl:with-param name="default-entity-type" select="concat('eft-', $glossary-entry/@type)"/>
                    <xsl:with-param name="entity-types" select="$response/m:entity-types/m:type"/>
                    <xsl:with-param name="instance" select="$glossary-entity/m:instance[@id eq $glossary-entry/@id]"/>
                </xsl:call-template>
                
            </xsl:with-param>
            
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:location">
        
        <xsl:variable name="location-id" select="@id"/>
        <xsl:variable name="glossary" select="parent::m:locations/parent::m:entry"/>
        <xsl:variable name="glossary-locations-gloss" select="key('glossary-locations-gloss', $glossary/@id, $root)"/>
        <xsl:variable name="cache-location" select="$glossary-locations-gloss/m:location[@id eq $location-id][1]"/>
        
        <xsl:variable name="cache-location-status" as="xs:string?">
            <xsl:choose>
                <xsl:when test="not($cache-location)">
                    <xsl:value-of select="'missing'"/>
                </xsl:when>
                <xsl:when test="$cache-location[@initial-version eq $text/@tei-version]">
                    <xsl:value-of select="'updated'"/>
                </xsl:when>
                <xsl:when test="$cache-glosses-behind[@id eq $glossary/@id]">
                    <xsl:value-of select="'behind'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <div class="item tei-parser editor-mode rw-full-width { $cache-location-status }">
            
            <ul class="list-inline inline-dots sml-margin bottom small">
                
                <xsl:if test="m:preceding-bookmark[xhtml:*]">
                    <li>
                        <xsl:apply-templates select="m:preceding-bookmark/xhtml:*"/>
                    </li>
                </xsl:if>
                
                <xsl:if test="m:preceding-ref[xhtml:*]">
                    <li>
                        <xsl:apply-templates select="m:preceding-ref/xhtml:*"/>
                    </li>
                </xsl:if>
                
                <xsl:choose>
                    <xsl:when test="$cache-location-status eq 'missing'">
                        <li>
                            <span class="text-danger underline">
                                <xsl:value-of select="'Location not cached'"/>
                            </span>
                        </li>
                    </xsl:when>
                    <xsl:when test="$cache-location-status eq 'updated'">
                        <li>
                            <span class="text-success underline">
                                <xsl:value-of select="concat('Newly cached in ', $text/@tei-version)"/>
                            </span>
                        </li>
                    </xsl:when>
                    <xsl:when test="$cache-location-status eq 'behind'">
                        <li>
                            <span class="text-warning underline">
                                <xsl:value-of select="concat('Cached in ', ($glossary-locations-gloss/@tei-version, 'previous version')[1])"/>
                            </span>
                        </li>
                    </xsl:when>
                </xsl:choose>
                
            </ul>
            
            <div class="small clearfix">
                <xsl:apply-templates select="xhtml:*"/>
            </div>
            
        </div>
        
    </xsl:template>
    
    <!-- Copy xhtml nodes -->
    <xsl:template match="xhtml:*">
        
        <xsl:variable name="node" select="."/>
        
        <xsl:choose>
            
            <xsl:when test="$node[matches(@class, '(^|\s+)gtr(\s+|$)')]">
                <!-- Skip -->
            </xsl:when>
            
            <!-- Don't copy, just pass down -->
            <!--<xsl:when test="$node[matches(@class, '(^|\s+)rw(\s+|$)')]">
                <xsl:apply-templates select="$node/node()"/>
            </xsl:when>-->
            
            <!-- Copy xhtml:* by default -->
            <xsl:otherwise>
                <xsl:copy>
                    <!-- Filter out class="rw" -->
                    <xsl:copy-of select="$node/@*[not(local-name() eq 'class')]"/>
                    <xsl:attribute name="class" select="replace(@class, '(^|\s+)rw(\s+|$)', '')"/>
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
            
            <xsl:copy-of select="@*[not(name(.) = ('href', 'class', 'target', 'title', 'data-bookmark'))]"/>
            
            <xsl:variable name="link-href-tokenized" select="tokenize($link/@href, '#')"/>
            <xsl:variable name="link-href-query" select="concat($link-href-tokenized[1], concat(if(contains($link-href-tokenized[1], '?')) then '&amp;' else '?', 'glossary-id=', $glossary-entry/@id))"/>
            <xsl:variable name="link-href-hash" select="concat('#', string-join((($link-href-tokenized[2], 'top')[1], fn:encode-for-uri(concat('[data-glossary-id=&#34;', $glossary-entry/@id, '&#34;]'))), '/'))"/>
            
            <!-- Href -->
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$link[@data-glossary-id]">
                        <xsl:call-template name="link-href">
                            <xsl:with-param name="glossary-id" select="$link/@data-glossary-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$link[@data-bookmark]">
                        <xsl:value-of select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', $link-href-hash)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-pointer-type eq 'id']">
                        <xsl:value-of select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html?view-mode=editor', $link-href-hash)"/>
                    </xsl:when>
                    <xsl:when test="$link[matches(@class, '(^|\s+)folio\-ref(\s+|$)')]">
                        <xsl:value-of select="concat($reading-room-path, $link-href-query, (:'&amp;view-mode=editor',:) $link-href-hash)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$link/@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <!-- Class -->
            <xsl:attribute name="class">
                <xsl:variable name="local-class" select="string-join(tokenize(@class, '\s+')[not(. = ('pop-up', 'log-click'))], ' ')"/>
                <xsl:choose>
                    <xsl:when test="$glossary-entry[@id eq $link/@data-glossary-id]">
                        <xsl:value-of select="string-join(($local-class, 'mark'), ' ')"/>
                    </xsl:when>
                    <xsl:when test="parent::m:preceding-ref">
                        <xsl:value-of select="string-join(($local-class, 'milestone'), ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$local-class"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <!-- Target -->
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="$link[@data-glossary-id]">
                        <xsl:value-of select="'_self'"/>
                    </xsl:when>
                    <xsl:when test="$link[@target]">
                        <xsl:value-of select="$link/@target"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$request-resource-id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <!-- Other attributes -->
            <xsl:choose>
                <xsl:when test="$link[matches(@class, '(^|\s+)folio\-ref(\s+|$)')][@data-dualview-href]">
                    
                    <xsl:variable name="dualview-href-tokenized" select="tokenize($link/@data-dualview-href, '#')"/>
                    <xsl:variable name="dualview-href-query" select="concat($dualview-href-tokenized[1], concat(if(contains($dualview-href-tokenized[1], '?')) then '&amp;' else '?', 'glossary-id=', $glossary-entry/@id))"/>
                    <xsl:variable name="dualview-href-hash" select="concat('#', string-join((($dualview-href-tokenized[2], 'top')[1], fn:encode-for-uri(concat('[data-glossary-id=&#34;', $glossary-entry/@id, '&#34;]'))), '/'))"/>
                    
                    <xsl:attribute name="data-dualview-href">
                        <xsl:value-of select="concat($reading-room-path, $dualview-href-query, (:'&amp;view-mode=editor',:) $dualview-href-hash)"/>
                    </xsl:attribute>
                    
                </xsl:when>
                <xsl:when test="$link[@data-bookmark]">
                    
                    <xsl:attribute name="data-dualview-href">
                        <xsl:value-of select="concat($reading-room-path, '/', $request-resource-type, '/', $request-resource-id, '.html', $link-href-hash)"/>
                    </xsl:attribute>
                    
                    <xsl:attribute name="data-dualview-title">
                        <xsl:value-of select="$text/m:toh/m:full/data()"/>
                    </xsl:attribute>
                    
                </xsl:when>
            </xsl:choose>
            
            <!-- Nodes -->
            <xsl:sequence select="node()"/>
            
        </xsl:element>
        
    </xsl:template>
    
</xsl:stylesheet>