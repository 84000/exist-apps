<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="request-resource-id" select="/m:response/m:request/@resource-id"/>
    <xsl:variable name="request-first-record" select="common:enforce-integer(/m:response/m:request/@first-record)" as="xs:integer"/>
    <xsl:variable name="request-max-records" select="common:enforce-integer(/m:response/m:request/@max-records)" as="xs:integer"/>
    <xsl:variable name="request-filter" select="/m:response/m:request/@filter"/>
    <xsl:variable name="request-search" select="/m:response/m:request/m:search[1]/text()"/>
    <xsl:variable name="request-similar-search" select="/m:response/m:request/m:similar-search[1]/text()"/>
    
    <xsl:variable name="request-glossary-id" select="/m:response/m:request/@glossary-id"/>
    <xsl:variable name="request-item-tab" select="/m:response/m:request/@item-tab"/>
    
    <xsl:variable name="text" select="/m:response/m:text[1]"/>
    <xsl:variable name="glossary" select="/m:response/m:glossary[1]"/>
    <xsl:variable name="text-id" select="$text/@id"/>
    <xsl:variable name="toh-key" select="$text/m:source/@key"/>
    <xsl:variable name="cache-slow" select="if($glossary[@seconds-to-build]/@seconds-to-build ! xs:decimal(.) gt 120) then true() else false()" as="xs:boolean"/>
    <xsl:variable name="cache-old" select="if(compare($text/@tei-version, $glossary/@tei-version-cached) ne 0) then true() else false()" as="xs:boolean"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Glossary'"/>
                    </h3>
                    
                    <!-- Page title / add new link / cache all link -->
                    <div class="center-vertical full-width">
                        
                        <!-- Text title / link -->
                        <div class="h3 sml-margin top bottom">
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
                    <div class="small text-muted">
                        
                        <xsl:choose>
                            
                            <xsl:when test="$cache-slow">
                                <xsl:value-of select="'The latest location cache took '"/>
                                <span class="label label-warning">
                                    <xsl:value-of select="concat(format-number(($glossary/@seconds-to-build ! xs:decimal(.) div 60), '#,###.##'), ' minutes')"/>
                                </span>
                                <xsl:value-of select="' '"/>
                            </xsl:when>
                            
                            <xsl:when test="$glossary[@seconds-to-build]">
                                <xsl:value-of select="'The latest location cache took '"/>
                                <span class="label label-default">
                                    <xsl:value-of select="concat(format-number($glossary/@seconds-to-build, '#,###.##'), ' seconds')"/>
                                </span>
                                <xsl:value-of select="' '"/>
                            </xsl:when>
                            
                        </xsl:choose>
                        
                        <xsl:if test="$text[@tei-version]">
                            <xsl:value-of select="'Current TEI version:'"/>
                            <span class="label label-default">
                                <xsl:value-of select="$text/@tei-version"/>
                            </span>
                            <xsl:value-of select="' '"/>
                            <xsl:value-of select="'Cached TEI version:'"/>
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
                            <xsl:value-of select="' '"/>
                        </xsl:if>
                        
                        <a target="_self" class="underline">
                            <xsl:attribute name="href" select="concat('glossary.html?resource-id=', $request-resource-id, '&amp;form-action=cache-locations-all')"/>
                            <xsl:value-of select="'Re-cache locations of all items'"/>
                        </a>
                        
                    </div>
                    
                    <!-- Filter / Pagination -->
                    <xsl:if test="not($request-filter eq 'blank-form')">
                        <div class="center-vertical full-width">
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
                                                        <xsl:value-of select="concat(' - takes ', format-number(($glossary/@seconds-to-build ! xs:decimal(.) div 60), '#,###'), ' mins!')"/>
                                                    </xsl:if>
                                                </option>
                                                <option value="no-expressions">
                                                    <xsl:if test="$request-filter eq 'no-expressions'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'No locations'"/>
                                                    <xsl:if test="$cache-slow">
                                                        <xsl:value-of select="concat(' - takes ', format-number(($glossary/@seconds-to-build ! xs:decimal(.) div 60), '#,###'), ' mins!')"/>
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
                        <xsl:variable name="loop-glossary-id" select="$loop-glossary/@id"/>
                        <xsl:variable name="locations-cached" select="$loop-glossary/m:expressions/m:location[@id = $loop-glossary/m:cache/m:location/@id]"/>
                        <xsl:variable name="locations-not-cached" select="$loop-glossary/m:expressions/m:location[not(@id = $locations-cached/@id)]"/>
                        
                        <div>
                            
                            <!-- Set id to support scroll to selected item -->
                            <xsl:if test="$loop-glossary[@active-item eq 'true']">
                                <xsl:attribute name="id" select="'selected-entity'"/>
                            </xsl:if>
                            
                            <!-- Title -->
                            <h4 class="sml-margin bottom">
                                
                                <!-- Term -->
                                <xsl:value-of select="m:term[@xml:lang eq 'en']"/>
                                
                                <!-- Reading Room link -->
                                <small>
                                    <xsl:value-of select="' / '"/>
                                    <a target="reading-room">
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $toh-key, '.html#', $loop-glossary-id, '&amp;view-mode=editor')"/>
                                        <xsl:value-of select="$loop-glossary-id"/>
                                    </a>
                                </small>
                                
                                <!-- Isolate a single record -->
                                <small>
                                    <xsl:value-of select="' / '"/>
                                    <xsl:call-template name="link">
                                        <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                        <xsl:with-param name="max-records" select="1"/>
                                        <xsl:with-param name="link-text" select="'isolate'"/>
                                        <xsl:with-param name="search" select="''"/>
                                        <xsl:with-param name="filter" select="''"/>
                                    </xsl:call-template>
                                </small>
                                
                            </h4>
                            
                            <!-- Definition -->
                            <div class="sml-margin bottom">
                                <xsl:call-template name="definition">
                                    <xsl:with-param name="item" select="."/>
                                </xsl:call-template>
                            </div>
                            
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
                                            <li class="small">
                                                <xsl:value-of select="concat('Locations: ', count($loop-glossary/m:expressions/m:location), ' ')"/>
                                            </li>
                                            <xsl:choose>
                                                <xsl:when test="not($loop-glossary/m:cache)">
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
                                                                            <xsl:value-of select="'An instances will not appear in the Reading Room until the location is cached.'"/>
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
                                    
                                    <xsl:with-param name="id" select="concat('entity-',$loop-glossary-id)"/>
                                    <xsl:with-param name="accordion-selector" select="concat('#accordion-', $loop-glossary-id)"/>
                                    <xsl:with-param name="active" select="$loop-glossary[@active-item eq 'true'] and $request-item-tab eq 'entity'"/>
                                    
                                    <xsl:with-param name="title">
                                        
                                        <ul class="list-inline inline-dots no-bottom-margin">
                                            <li class="small">
                                                <xsl:value-of select="concat('Matched with: ', count($loop-glossary/m:entity-glossaries/m:item[not(@id eq $loop-glossary-id)]))"/>
                                            </li>
                                            <xsl:if test="$loop-glossary/m:entity">
                                                <li class="small">
                                                    <xsl:value-of select="$loop-glossary/m:entity/m:label"/>
                                                </li>
                                                <li class="small">
                                                    <xsl:value-of select="$loop-glossary/m:entity/@xml:id"/>
                                                </li>
                                            </xsl:if>
                                            <li>
                                                <xsl:call-template name="entity-type-labels">
                                                    <xsl:with-param name="entity" select="$loop-glossary/m:entity"/>
                                                </xsl:call-template>
                                            </li>
                                        </ul>
                                        
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="content">
                                        
                                        <!-- List: matched entities or similar entities -->
                                        <xsl:choose>
                                            
                                            <!-- When there is an entity  -->
                                            <xsl:when test="$loop-glossary/m:entity">
                                                
                                                <xsl:choose>
                                                    
                                                    <!-- When there are other items matched to it show the list -->
                                                    <xsl:when test="$loop-glossary/m:entity-glossaries/m:item[not(@id = $loop-glossary-id)]">
                                                        
                                                        <xsl:for-each-group select="$loop-glossary/m:entity-glossaries/m:item" group-by="m:text/@id">
                                                            
                                                            <xsl:sort select="m:text[1]/@id"/>
                                                            
                                                            <xsl:call-template name="text-glossaries">
                                                                <xsl:with-param name="glossaries" select="current-group()"/>
                                                                <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                            </xsl:call-template>
                                                            
                                                        </xsl:for-each-group>
                                                        
                                                    </xsl:when>
                                                    
                                                    <!-- No other matched items -->
                                                    <xsl:otherwise>
                                                        
                                                        <hr/>
                                                        <div>
                                                            <p class="text-center text-muted small bottom-margin">
                                                                <xsl:value-of select="'There are currently no other glossary items matched to this entity'"/>
                                                                <!--<br/>
                                                                <a target="entities">
                                                                    <xsl:attribute name="href" select="concat('entities.html?id=', $loop-glossary/m:entity/@xml:id)"/>
                                                                    <xsl:value-of select="'Find similar entities'"/>
                                                                </a>-->
                                                            </p>
                                                        </div>
                                                        
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                            </xsl:when>
                                            
                                            <!-- When there is no entity -->
                                            <xsl:otherwise>
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <!-- Form: search for similar entities -->
                                                <xsl:call-template name="form">
                                                    <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                    <xsl:with-param name="tab-id" select="'entity'"/>
                                                    <xsl:with-param name="form-content">
                                                        
                                                        <p class="small text-muted text-center">
                                                            <xsl:value-of select="'Match this glossary item to an existing shared entity. Use the search to find additional terms not automatically suggested.'"/>
                                                        </p>
                                                        
                                                        <div class="form-group">
                                                            <div class="col-sm-offset-4 col-sm-4">
                                                                <div class="input-group">
                                                                    <input type="text" name="similar-search" class="form-control" id="similar-search" value="{ $request-similar-search }" placeholder="Widen search..."/>
                                                                    <div class="input-group-btn">
                                                                        <button type="submit" class="btn btn-primary" data-loading="Searching for similar terms...">
                                                                            <i class="fa fa-search"/>
                                                                        </button>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <!-- List similar entities -->
                                                <xsl:choose>
                                                    
                                                    <xsl:when test="$loop-glossary/m:similar-entities[m:entity]">
                                                        <xsl:for-each select="$loop-glossary/m:similar-entities/m:entity">
                                                            
                                                            <xsl:call-template name="entity-glossaries">
                                                                <xsl:with-param name="entity" select="."/>
                                                                <xsl:with-param name="loop-glossary" select="$loop-glossary"/>
                                                            </xsl:call-template>
                                                            
                                                        </xsl:for-each>
                                                    </xsl:when>
                                                    
                                                    <xsl:otherwise>
                                                        <p class="text-center text-muted small">
                                                            <xsl:value-of select="'No similar glossary items found in other texts'"/>
                                                        </p>
                                                    </xsl:otherwise>
                                                    
                                                </xsl:choose>
                                                
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        <!-- Form: for editing/adding the shared entity -->
                                        <xsl:call-template name="form">
                                            
                                            <xsl:with-param name="tab-id" select="'entity'"/>
                                            <xsl:with-param name="form-action" select="'update-entity'"/>
                                            <xsl:with-param name="form-class" select="'form-horizontal top-margin'"/>
                                            <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                            <xsl:with-param name="form-content">
                                                
                                                <div class="alert alert-warning">
                                                    <p class="small text-center">
                                                        <xsl:choose>
                                                            <xsl:when test="$loop-glossary/m:entity">
                                                                <xsl:value-of select="'NOTE: Updates to this shared entity must apply for all glossaries matched to this entity!'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'Check thoroughly for an existing shared entity before adding a new one!'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </p>
                                                </div>
                                                
                                                <input type="hidden" name="entity-id" value="{ $loop-glossary/m:entity/@xml:id }"/>
                                                
                                                <div class="form-group">
                                                    <label for="entity-label" class="col-sm-2 control-label">
                                                        <xsl:attribute name="for" select="concat('entity-label', $loop-glossary-id)"/>
                                                        <xsl:value-of select="'Label'"/>
                                                    </label>
                                                    <div class="col-sm-2">
                                                        <xsl:call-template name="select-language">
                                                            <xsl:with-param name="selected-language" select="$loop-glossary/m:entity/m:label/@xml:lang"/>
                                                            <xsl:with-param name="input-name" select="'entity-label-lang'"/>
                                                            <xsl:with-param name="input-id" select="concat('entity-label-lang', $loop-glossary-id)"/>
                                                            <xsl:with-param name="allow-empty" select="true()"/>
                                                        </xsl:call-template>
                                                    </div>
                                                    <div class="col-sm-6">
                                                        <input type="text" name="entity-label" class="form-control" value="{ $loop-glossary/m:entity/m:label }">
                                                            <xsl:attribute name="id" select="concat('entity-label', $loop-glossary-id)"/>
                                                        </input>
                                                    </div>
                                                </div>
                                                
                                                <div class="form-group">
                                                    
                                                    <label class="col-sm-2 control-label">
                                                        <xsl:value-of select="'Type(s)'"/>
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
                                                
                                                <!-- Option to unlink from the entity -->
                                                <xsl:if test="$loop-glossary/m:entity">
                                                    <div class="form-group">
                                                        <div class="col-sm-offset-2 col-sm-10">
                                                            <div class="checkbox">
                                                                <label>
                                                                    <input type="checkbox" name="instance-remove">
                                                                        <xsl:attribute name="value" select="$loop-glossary-id"/>
                                                                    </input>
                                                                    <span class="text-danger">
                                                                        <i class="fa fa-exclamation-circle"/>
                                                                        <xsl:value-of select="' Un-link this glossary from this shared entity'"/>
                                                                    </span>
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </xsl:if>
                                                
                                                <!-- Submit button -->
                                                <div class="form-group">
                                                    <div class="col-sm-offset-2 col-sm-10">
                                                        <button type="submit" data-loading="Applying changes...">
                                                            <xsl:choose>
                                                                <xsl:when test="$loop-glossary/m:entity">
                                                                    <xsl:attribute name="class" select="'btn btn-primary'"/>
                                                                    <xsl:value-of select="'Apply changes'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="class" select="'btn btn-warning'"/>
                                                                    <xsl:value-of select="'Create Shared Entity'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </button>
                                                    </div>
                                                </div>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                        
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
    
    <xsl:template name="expand-item">
        
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:param name="title" required="yes" as="node()*"/>
        <xsl:param name="accordion-selector" required="yes" as="xs:string"/>
        <xsl:param name="active" as="xs:boolean"/>
        <xsl:param name="content" required="no" as="node()*"/>
        
        <div class="list-group-item collapse-background">
            
            <xsl:if test="$active">
                <xsl:attribute name="class" select="'list-group-item collapse-background show-background'"/>
            </xsl:if>
            
            <div role="tab">
                
                <xsl:attribute name="id" select="concat('expand-item-', $id, '-heading')"/>
                
                <div class="center-vertical full-width">
                    
                    <div>
                        <xsl:copy-of select="$title"/>
                    </div>
                    
                    <a class="text-right collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                        
                        <xsl:attribute name="href" select="concat('#expand-item-', $id, '-detail')"/>
                        <xsl:attribute name="aria-controls" select="concat('expand-item-',$id, '-detail')"/>
                        <xsl:attribute name="data-parent" select="$accordion-selector"/>
                        
                        <xsl:if test="$active">
                            <xsl:attribute name="class" select="'text-right'"/>
                            <xsl:attribute name="aria-expanded" select="'true'"/>
                        </xsl:if>
                        
                        <span>
                            <i class="fa fa-plus collapsed-show"/>
                            <i class="fa fa-minus collapsed-hide"/>
                        </span>
                    </a>
                    
                </div>
            </div>
            
            <div class="panel-collapse collapse" role="tabpanel" aria-expanded="false">
                
                <xsl:attribute name="id" select="concat('expand-item-',$id, '-detail')"/>
                <xsl:attribute name="aria-labelledby" select="concat('expand-item-',$id, '-heading')"/>
                
                <xsl:if test="$active">
                    <xsl:attribute name="class" select="'panel-collapse collapse in'"/>
                    <xsl:attribute name="aria-expanded" select="'true'"/>
                </xsl:if>
                
                <div class="panel-body no-padding">
                    <xsl:copy-of select="$content"/>
                </div>
                
            </div>
            
        </div>
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
        
        <form action="/glossary.html#selected-entity" method="post">
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
        
        <xsl:variable name="terms" select="$glossary/m:term"/>
        
        <input type="hidden" name="glossary-id" value="{ $glossary/@id }"/>
        
        <div class="add-nodes-container">
            
            <xsl:for-each select="(1 to (if(count($terms) gt 0) then count($terms) else 3))">
                <xsl:variable name="index" select="."/>
                <xsl:variable name="element-name" select="concat('term-main-text-', $index)"/>
                <xsl:variable name="element-id" select="concat('term-main-text-', $glossary/@id, '-', $index)"/>
                <div class="form-group add-nodes-group">
                    <xsl:if test="$index eq 1">
                        <label for="{ $element-id }" class="col-sm-2 control-label">
                            <xsl:value-of select="'Term'"/>
                        </label>
                    </xsl:if>
                    <div class="col-sm-2">
                        <xsl:if test="not($index eq 1)">
                            <xsl:attribute name="class" select="'col-sm-offset-2 col-sm-2'"/>
                        </xsl:if>
                        <xsl:call-template name="select-language">
                            <xsl:with-param name="selected-language">
                                <xsl:choose>
                                    <xsl:when test="not($terms[$index]) and $index eq 1">
                                        <xsl:value-of select="'en'"/>
                                    </xsl:when>
                                    <xsl:when test="not($terms[$index]) and $index eq 2">
                                        <xsl:value-of select="'Bo-Ltn'"/>
                                    </xsl:when>
                                    <xsl:when test="not($terms[$index]) and $index eq 3">
                                        <xsl:value-of select="'Sa-Ltn'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$terms[$index]/@xml:lang"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="input-name" select="concat('term-main-lang-', $index)"/>
                            <xsl:with-param name="input-id" select="concat('term-main-lang-', $glossary/@id, '-',$index)"/>
                        </xsl:call-template>
                    </div>
                    <div class="col-sm-6">
                        <input type="text" name="{ $element-name }" id="{ $element-id }" value="{ $terms[$index]/text() }" class="form-control"/>
                    </div>
                </div>
            </xsl:for-each>
            
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <a href="#add-nodes" class="add-nodes">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a term'"/>
                    </a>
                </div>
            </div>
            
        </div>
        
        <xsl:variable name="alternative-spellings" select="$glossary/m:alternative"/>
        <div class="add-nodes-container">
            
            <xsl:for-each select="(1 to (if(count($alternative-spellings) gt 0) then count($alternative-spellings) else 1))">
                <xsl:variable name="index" select="."/>
                <xsl:variable name="element-name" select="concat('term-alternative-text-', $index)"/>
                <xsl:variable name="element-id" select="concat('term-alternative-text-', $glossary/@id, '-', $index)"/>
                <div class="form-group add-nodes-group">
                    <xsl:if test="$index eq 1">
                        <label for="{ $element-id }" class="col-sm-2 control-label">
                            <xsl:value-of select="'Alt. spelling'"/>
                        </label>
                    </xsl:if>
                    <div class="col-sm-2">
                        <xsl:if test="not($index eq 1)">
                            <xsl:attribute name="class" select="'col-sm-offset-2 col-sm-2'"/>
                        </xsl:if>
                        <xsl:call-template name="select-language">
                            <xsl:with-param name="selected-language" select="$alternative-spellings[$index]/@xml:lang"/>
                            <xsl:with-param name="input-name" select="concat('term-alternative-lang-', $index)"/>
                            <xsl:with-param name="input-id" select="concat('term-alternative-lang-', $glossary/@id, '-', $index)"/>
                        </xsl:call-template>
                    </div>
                    <div class="col-sm-6">
                        <input type="text" name="{ $element-name }" id="{ $element-id }" value="{ $alternative-spellings[$index]/text() }" class="form-control"/>
                    </div>
                </div>
            </xsl:for-each>
            
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <a href="#add-nodes" class="add-nodes">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add an alternative spelling'"/>
                    </a>
                </div>
            </div>
            
        </div>
        
        <div class="form-group">
            
            <label for="{ concat('glossary-type-', $glossary/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Glossary type'"/>
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
                    <xsl:value-of select="'NOTE: Glossary type will be deprecated in favour of entity types'"/>
                </p>
            </div>
            
        </div>
        
        <div class="form-group">
            
            <label for="{ concat('glossary-mode-', $glossary/@id) }" class="col-sm-2 control-label">
                <xsl:value-of select="'Find instances'"/>
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
        
        <xsl:variable name="definitions" select="$glossary/m:markdown/m:definition"/>
        <div class="form-group no-bottom-margin">
            
            <label for="{ concat('term-definition-text-', $glossary/@id, '-1') }" class="col-sm-2 control-label">
                <xsl:value-of select="'Definition'"/>
            </label>
            
            <div class="col-sm-6 add-nodes-container">
                
                <xsl:for-each select="(1 to (if(count($definitions) gt 0) then count($definitions) else 1))">
                    <xsl:variable name="index" select="."/>
                    <xsl:variable name="element-name" select="concat('term-definition-text-', $index)"/>
                    <xsl:variable name="element-id" select="concat('term-definition-text-', $glossary/@id, '-', $index)"/>
                    <div class="sml-margin bottom add-nodes-group">
                        <textarea name="{ $element-name }" id="{ $element-id }" class="form-control" rows="4">
                            <xsl:value-of select="$definitions[$index]"/>
                        </textarea>
                    </div>
                </xsl:for-each>
                
                <div class="sml-margin top bottom-margin">
                    <a href="#add-nodes" class="add-nodes">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a definition'"/>
                    </a>
                </div>
                
            </div>
            
            <!--<div class="col-sm-4">
                <div class="panel panel-default">
                    <div class="panel-heading" role="tab">
                        <a href="{ concat('#tag-reference-', $glossary/@id) }" aria-controls="{ concat('tag-reference-', $glossary/@id) }" id="{ concat('#tag-reference-heading-', $glossary/@xml:id) }" class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                            <h5>
                                <xsl:value-of select="'Glossary Definition Tag Reference'"/>
                            </h5>
                            <span class="text-right">
                                <i class="fa fa-plus collapsed-show"/>
                                <i class="fa fa-minus collapsed-hide"/>
                            </span>
                        </a>
                    </div>
                    <div id="{ concat('tag-reference-', $glossary/@id) }" aria-labelledby="{ concat('#tag-reference-heading-', $glossary/@id) }" class="panel-body collapse" role="tabpanel" aria-expanded="false">
                        <p class="small text-muted">
                            <xsl:value-of select="'These are the valid tags for glossary definitions'"/>
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
                                <foreign xml:lang="Sa-Ltn">āyatana</foreign>
                            </xsl:variable>
                            <xsl:for-each select="$samples/*">
                                <p>
                                    <code>
                                        <xsl:value-of select="replace(normalize-space(serialize(., $serialization-parameters)), '\sxmlns\S+', ' ')"/>
                                    </code>
                                </p>
                            </xsl:for-each>
                        </p>
                        
                    </div>
                </div>
            </div>-->
            
        </div>
        
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-2">
                <button type="submit" class="btn btn-primary" data-loading="Applying changes...">
                    <xsl:value-of select="'Apply changes'"/>
                </button>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="text-glossaries">
        
        <xsl:param name="glossaries" as="element(m:item)*" required="yes"/>
        <xsl:param name="loop-glossary" as="element(m:item)" required="yes"/>
        
        <fieldset class="relative">
            
            <legend>
                <xsl:value-of select="concat('In ', $glossaries[1]/m:text/m:toh, ' / ', common:limit-str($glossaries[1]/m:text/m:title, 100))"/>
            </legend>
            
            <div class="div-list no-border-top no-padding-top">
                <xsl:for-each select="$glossaries">
                    <div class="item">
                        <ul class="list-inline inline-dots no-top-margin item-row">
                            <!-- Term -->
                            <li>
                                <xsl:value-of select="m:term[@xml:lang eq 'en'][1]"/>
                            </li>
                            <!-- Link to Reading Room -->
                            <li>
                                
                                <a target="reading-room" class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:text/@id, '.html#', @id)"/>
                                    <xsl:value-of select="@id"/>
                                </a>
                            </li>
                            <!-- A link to switch to this item -->
                            <li>
                                <xsl:choose>
                                    <xsl:when test="not(@id eq $loop-glossary/@id)">
                                        <xsl:call-template name="link">
                                            <xsl:with-param name="resource-id" select="m:text/@id"/>
                                            <xsl:with-param name="glossary-id" select="@id"/>
                                            <xsl:with-param name="link-text" select="'edit'"/>
                                            <xsl:with-param name="link-class" select="'small'"/>
                                            <xsl:with-param name="link-target" select="concat('glossary-', m:text/@id)"/>
                                            <xsl:with-param name="max-records" select="1"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <small class="text-muted">
                                            <xsl:value-of select="'editing'"/>
                                        </small>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </ul>
                        
                        <!-- Terms -->
                        <div class="item-row">
                            <xsl:call-template name="terms">
                                <xsl:with-param name="item" select="."/>
                            </xsl:call-template>
                        </div>
                        
                        <!-- Definition -->
                        <div class="item-row">
                            <xsl:call-template name="definition">
                                <xsl:with-param name="item" select="."/>
                            </xsl:call-template>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
            
        </fieldset>
        
    </xsl:template>
    
    <xsl:template name="entity-glossaries">
        
        <xsl:param name="entity" as="element(m:entity)" required="yes"/>
        <xsl:param name="loop-glossary" as="element(m:item)" required="yes"/>
        
        <fieldset class="relative">
            
            <legend>
                <span>
                    <xsl:attribute name="class">
                        <xsl:value-of select="common:lang-class($entity/m:label/@xml:lang)"/>
                    </xsl:attribute>
                    <xsl:value-of select="common:limit-str($entity/m:label ! fn:normalize-space(.), 80)"/>
                </span>
                <xsl:value-of select="' / '"/>
                <small>
                    <xsl:value-of select="$entity/@xml:id"/>
                </small>
                <xsl:value-of select="' / '"/>
                <xsl:call-template name="entity-type-labels">
                    <xsl:with-param name="entity" select="$entity"/>
                </xsl:call-template>
                <xsl:value-of select="' / '"/>
                <small>
                    <xsl:value-of select="concat(count($entity/m:instance[@type eq 'glossary-item']), ' glossaries')"/>
                </small>
            </legend>
            
            <div class="div-list no-border-top no-padding-top">
                <xsl:for-each select="$entity/m:instance[@type eq 'glossary-item']/m:item">
                    <div class="item">
                        
                        <ul class="list-inline inline-dots no-top-margin item-row">
                            <!-- Term -->
                            <li>
                                <xsl:value-of select="m:term[@xml:lang eq 'en'][1]"/>
                            </li>
                            <!-- Link to Reading Room -->
                            <li>
                                <a target="reading-room" class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:text/@id, '.html#', @id)"/>
                                    <xsl:value-of select="@id"/>
                                </a>
                            </li>
                            <!-- A link to switch to this item -->
                            <li>
                                <xsl:choose>
                                    <xsl:when test="not(@id eq $loop-glossary/@id)">
                                        <xsl:call-template name="link">
                                            <xsl:with-param name="resource-id" select="m:text/@id"/>
                                            <xsl:with-param name="glossary-id" select="@id"/>
                                            <xsl:with-param name="link-text" select="'edit'"/>
                                            <xsl:with-param name="link-class" select="'small'"/>
                                            <xsl:with-param name="link-target" select="concat('glossary-', m:text/@id)"/>
                                            <xsl:with-param name="max-records" select="1"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <small class="text-muted">
                                            <xsl:value-of select="'editing'"/>
                                        </small>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </ul>
                        
                        <!-- Terms -->
                        <div class="item-row">
                            <xsl:call-template name="terms">
                                <xsl:with-param name="item" select="."/>
                            </xsl:call-template>
                        </div>
                        
                        <!-- Definition -->
                        <div class="item-row">
                            <xsl:call-template name="definition">
                                <xsl:with-param name="item" select="."/>
                            </xsl:call-template>
                        </div>
                        
                        <!-- Text -->
                        <div class="item-row small">
                            <xsl:value-of select="concat('In ', m:text/m:toh, ' / ', m:text/m:title)"/>
                        </div>
                        
                    </div>
                </xsl:for-each>
            </div>
            
            <div class="item-controls">
                
                <!-- Form: accept this match -->
                <xsl:call-template name="form">
                    <xsl:with-param name="form-action" select="'match-entity'"/>
                    <xsl:with-param name="tab-id" select="'similar'"/>
                    <xsl:with-param name="glossary-id" select="$loop-glossary/@id"/>
                    <xsl:with-param name="form-content">
                        
                        <input type="hidden" name="entity-id">
                            <xsl:attribute name="value" select="$entity/@xml:id"/>
                        </input>
                        
                        <button type="submit" class="btn btn-success btn-sm" data-loading="Applying match...">
                            <xsl:value-of select="'Match'"/>
                        </button>
                        
                    </xsl:with-param>
                </xsl:call-template>
                
            </div>
            
        </fieldset>
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
                <xsl:if test="$selected-language eq 'en'">
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
        </select>
        
    </xsl:template>
    
    <xsl:template name="entity-type-labels">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:choose>
            <xsl:when test="$entity">
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
                <span class="label label-danger">
                    <xsl:value-of select="'No shared entity defined'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="terms">
        
        <xsl:param name="item" as="element(m:item)"/>
        
        <ul class="list-inline inline-dots no-bottom-margin small">
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
            <xsl:if test="m:alternative">
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
            </xsl:if>
        </ul>
        
    </xsl:template>
    
    <xsl:template name="definition">
        <xsl:param name="item"/>
        <xsl:if test="$item/m:definition[node()]">
            <div class="text-muted">
                <xsl:for-each select="$item/m:definition[node()]">
                    <p class="small">
                        <xsl:sequence select="node()"/>
                    </p>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="m:location">
        
        <xsl:variable name="location-id" select="@id" as="xs:string"/>
        <xsl:variable name="glossary-item" select="parent::m:expressions/parent::m:item"/>
        <xsl:variable name="cache-location" select="$glossary-item/m:cache/m:location[@id = $location-id]"/>
        
        <div class="item editor-mode translation rw-full-width small pad">
            
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
                        <!-- Possibly add &mark=$glossary-item/@id to this to highlight the target - need to split the href though to insert the parameter -->
                        <xsl:value-of select="concat($reading-room-path, '/translation/', $toh-key, '.html', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-glossary-location]">
                        <xsl:value-of select="concat($reading-room-path, '/translation/', $toh-key, '.html', $link/@href)"/>
                    </xsl:when>
                    <xsl:when test="$link[@data-ref]">
                        <xsl:value-of select="concat($reading-room-path, substring-before($link/@href, '#'), '&amp;highlight=', string-join($glossary-item/m:term[@xml:lang eq 'bo'], ','), '#', substring-after($link/@href, '#'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($reading-room-path, $link/@href)"/>
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
            
            <xsl:attribute name="target" select="$toh-key"/>
            
            <xsl:sequence select="node()"/>
            
        </xsl:element>
        
    </xsl:template>
    
</xsl:stylesheet>