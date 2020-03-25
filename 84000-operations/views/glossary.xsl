<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="request-resource-id" select="/m:response/m:request/@resource-id"/>
    <xsl:variable name="request-start-letter" select="/m:response/m:request/@start-letter"/>
    <xsl:variable name="request-glossary-id" select="/m:response/m:request/@glossary-id"/>
    <xsl:variable name="request-test-alternative" select="/m:response/m:request/@test-alternative"/>
    <xsl:variable name="request-item-tab" select="/m:response/m:request/@item-tab"/>
    <xsl:variable name="request-glossary" select="/m:response/m:selected-glossary"/>
    <xsl:variable name="request-entity" select="/m:response/m:entities/m:entity[m:definition/@id = $request-glossary/m:item/@uid][1]"/>
    <xsl:variable name="page-url" select="/m:response/m:expressions/@page-url"/>
    
    <xsl:template match="/m:response">
        
        <!-- Make a sorted copy so we can browse from one to the next -->
        <xsl:variable name="sorted-items">
            <xsl:for-each select="m:glossary/m:item">
                <xsl:sort select="m:sort-term"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="entities" select="m:entities/m:entity"/>
        <xsl:variable name="expressions" select="m:expressions/m:item"/>
        <xsl:variable name="matched-glossary-items" select="m:matched-glossaries/m:item"/>
        <xsl:variable name="similar-glossary-items" select="m:similar-glossaries/m:item"/>
        <xsl:variable name="similar-entities" select="m:similar-entities/m:entity"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Glossary'"/>
                    </h3>
                    
                    <div class="row">
                        <div class="col-sm-12">
                            
                            <!-- Form: selects the text and start letter -->
                            <form action="/glossary.html#selected-entity" method="post" class="filter-form">
                                
                                <div class="center-vertical full-width">
                                    <div>
                                        <!-- Select a start letter -->
                                        <label class="sr-only" for="resource-id">
                                            <xsl:value-of select="'Filter by start letter'"/>
                                        </label>
                                        <select name="start-letter" id="start-letter" class="form-control">
                                            <xsl:variable name="alaphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
                                            <xsl:for-each select="(1 to 26)">
                                                <xsl:variable name="letter" select="substring($alaphabet, ., 1)"/>
                                                <option>
                                                    <xsl:attribute name="value" select="$letter"/>
                                                    <xsl:if test="$letter eq $request-start-letter">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="$letter"/>
                                                </option>
                                            </xsl:for-each>
                                        </select>
                                    </div>
                                    <div>
                                        <xsl:value-of select="'in'"/>
                                    </div>
                                    <div>
                                        <!-- Select a text -->
                                        <label class="sr-only" for="resource-id">
                                            <xsl:value-of select="'Filter by text'"/>
                                        </label>
                                        <select name="resource-id" id="resource-id" class="form-control">
                                            <xsl:for-each select="m:translations/m:file">
                                                <xsl:sort select="@id"/>
                                                <option>
                                                    <xsl:attribute name="value" select="@id"/>
                                                    <xsl:if test="@id eq $request-resource-id">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="data(.)"/>
                                                </option>
                                            </xsl:for-each>
                                        </select>
                                    </div>
                                    <div>
                                        <a target="reading-room">
                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $request-resource-id, '.html')"/>
                                            <xsl:value-of select="'Open in the Reading Room'"/>
                                        </a>
                                    </div>
                                    <div>
                                        <a href="#new-glossary" data-toggle="collapse" class="btn btn-warning" role="button" aria-expanded="false" aria-controls="new-glossary">
                                            <xsl:value-of select="'Add a new entry'"/>
                                        </a>
                                    </div>
                                </div>
                            </form>
                            
                        </div>
                    </div>
                    
                    <div class="collapse" id="new-glossary">
                        <div class="well top-margin">
                            <xsl:call-template name="form">
                                
                                <xsl:with-param name="form-action" select="'update-glossary'"/>
                                <xsl:with-param name="form-content">
                                    
                                    <xsl:call-template name="glossary-form"/>
                                    
                                </xsl:with-param>
                                
                            </xsl:call-template>
                        </div>
                    </div>
                    
                    <div class="div-list top-margin">
                        
                        <xsl:for-each select="$sorted-items/m:item">
                            
                            <xsl:variable name="loop-glossary" select="."/>
                            <xsl:variable name="loop-glossary-id" select="$loop-glossary/@uid"/>
                            <xsl:variable name="loop-glossary-selected" select="if($loop-glossary-id eq $request-glossary-id) then true() else false()" as="xs:boolean"/>
                            <xsl:variable name="loop-entity" select="$entities[m:definition[@id = $loop-glossary-id]][1]"/>
                            
                            <div class="item pad">
                                
                                <xsl:if test="$loop-glossary-selected">
                                    <xsl:attribute name="class" select="'item pad selected bottom-margin'"/>
                                    <xsl:attribute name="id" select="'selected-entity'"/>
                                </xsl:if>
                                
                                <!-- Controls for the item -->
                                <div class="item-controls">
                                    <xsl:if test="$loop-glossary-selected">
                                        
                                        <!-- A link to close the item -->
                                        <xsl:call-template name="link">
                                            <xsl:with-param name="glossary-id" select="''"/>
                                            <xsl:with-param name="link-text" select="'close'"/>
                                            <xsl:with-param name="link-class" select="'btn btn-default btn-sm'"/>
                                        </xsl:call-template>
                                        
                                        <xsl:if test="$loop-glossary/following-sibling::m:item">
                                            <xsl:call-template name="link">
                                                <xsl:with-param name="glossary-id" select="$loop-glossary/following-sibling::m:item[1]/@uid"/>
                                                <xsl:with-param name="link-text" select="'open next'"/>
                                                <xsl:with-param name="link-class" select="'btn btn-default btn-sm'"/>
                                            </xsl:call-template>
                                        </xsl:if>
                                        
                                    </xsl:if>
                                </div>
                                
                                <!-- Header row -->
                                <div class="item-row center-vertical full-width">
                                    
                                    <!-- Title -->
                                    <h3 class="no-top-margin no-bottom-margin">
                                        <xsl:choose>
                                            <xsl:when test="$loop-glossary-selected">
                                                
                                                <xsl:value-of select="m:term[@xml:lang eq 'en']"/>
                                                
                                            </xsl:when>
                                            <xsl:otherwise>
                                                
                                                <!-- A link to open the item -->
                                                <xsl:call-template name="link">
                                                    <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                    <xsl:with-param name="link-text" select="m:term[@xml:lang eq 'en']"/>
                                                </xsl:call-template>
                                                
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <small>
                                            <xsl:value-of select="' / '"/>
                                            <a target="reading-room">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $request-resource-id, '.html#', $loop-glossary-id)"/>
                                                <xsl:value-of select="$loop-glossary-id"/>
                                            </a>  
                                        </small>
                                    </h3>
                                    
                                    <!-- Types -->
                                    <div class="text-right">
                                        <xsl:choose>
                                            <xsl:when test="$loop-entity">
                                                <xsl:call-template name="type-labels">
                                                    <xsl:with-param name="entity" select="$loop-entity"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span class="label label-danger">
                                                    <xsl:value-of select="'No shared entity defined'"/>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                    
                                </div>
                                
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
                                
                                <!-- Entity -->
                                <xsl:if test="$loop-entity">
                                    <p class="item-row text-muted">
                                        <xsl:value-of select="concat($loop-entity/@xml:id, ' : &#34;', $loop-entity/m:label, '&#34; has ', count($loop-entity/m:definition), ' glossary item(s)')"/>
                                     </p>
                                </xsl:if>
                                
                                <!-- Body row -->
                                <!-- The selected glossary item - show forms -->
                                <xsl:if test="$loop-glossary-selected">
                                    
                                    <!-- Tabs -->
                                    <ul class="nav nav-tabs" role="tablist">
                                        <li role="presentation">
                                            <xsl:if test="$request-item-tab eq 'expressions'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a href="#expressions" aria-controls="expressions" role="tab" data-toggle="tab" aria-expanded="false">
                                                <xsl:value-of select="'Expressions '"/>
                                                <xsl:if test="not($request-test-alternative gt '')">
                                                    <span class="badge">
                                                        <xsl:value-of select="count($expressions)"/>
                                                        <!--<xsl:value-of select="'/'"/>
                                                        <xsl:value-of select="count($expressions//tei:match[@requested-glossary eq 'true'])"/>-->
                                                    </span>
                                                </xsl:if>
                                            </a>
                                        </li>
                                        <li role="presentation">
                                            <xsl:if test="$request-item-tab eq 'test-alternatives'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a href="#test-alternatives" aria-controls="test-alternatives" role="tab" data-toggle="tab" aria-expanded="false">
                                                <xsl:value-of select="'Test alt. spellings '"/>
                                                <xsl:if test="$request-test-alternative gt ''">
                                                    <span class="badge">
                                                        <xsl:value-of select="count($expressions)"/>
                                                        <!--<xsl:value-of select="'/'"/>
                                                        <xsl:value-of select="count($expressions//tei:match[@requested-glossary eq 'true'])"/>-->
                                                    </span>
                                                </xsl:if>
                                            </a>
                                        </li>
                                        <li role="presentation">
                                            <xsl:if test="$request-item-tab eq 'glossary-form'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a href="#glossary-form" aria-controls="glossary-form" role="tab" data-toggle="tab" aria-expanded="false">
                                                <xsl:value-of select="'Update glossary '"/>
                                            </a>
                                        </li>
                                        <li role="presentation">
                                            <xsl:if test="$request-item-tab eq 'entity-form'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a href="#entity-form" aria-controls="entity-form" role="tab" data-toggle="tab" aria-expanded="false">
                                                <xsl:value-of select="'Shared entity '"/>
                                                <xsl:if test="$matched-glossary-items[not(@uid = $loop-glossary-id)]">
                                                    <span class="badge">
                                                        <xsl:value-of select="count($matched-glossary-items)"/>
                                                    </span>
                                                </xsl:if>
                                            </a>
                                        </li>
                                        <li role="presentation">
                                            <xsl:if test="$request-item-tab eq 'similar'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a href="#similar" aria-controls="similar" role="tab" data-toggle="tab" aria-expanded="true">
                                                <xsl:value-of select="'Possible matches '"/>
                                                <span class="badge">
                                                    <xsl:value-of select="count($similar-glossary-items)"/>
                                                </span>
                                            </a>
                                        </li>
                                    </ul>
                                    
                                    <div class="tab-content">
                                        
                                        <!-- Tab: Show expressions of this glossary in the text-->
                                        <div id="expressions" class="tab-pane fade" role="tabpanel">
                                            
                                            <xsl:if test="$request-item-tab eq 'expressions'">
                                                <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                            </xsl:if>
                                        
                                            <xsl:choose>
                                                <xsl:when test="$request-test-alternative gt ''">
                                                    
                                                    <!-- Form: for reloading expressions -->
                                                    <xsl:call-template name="form">
                                                        
                                                        <xsl:with-param name="tab-id" select="'expressions'"/>
                                                        <xsl:with-param name="form-class" select="'form-inline bottom-margin text-center'"/>
                                                        <xsl:with-param name="form-content">
                                                            
                                                            <button type="submit" class="btn btn-default">
                                                                <xsl:value-of select="'Re-load expressions'"/>
                                                            </button>
                                                            
                                                        </xsl:with-param>
                                                    </xsl:call-template>
                                                    
                                                </xsl:when>
                                                
                                                <xsl:otherwise>
                                                    
                                                    <!-- Form: for caching expression locations -->
                                                    <xsl:call-template name="form">
                                                        <xsl:with-param name="tab-id" select="'expressions'"/>
                                                        <xsl:with-param name="form-class" select="'form-inline bottom-margin'"/>
                                                        <xsl:with-param name="form-content">
                                                            
                                                            <input type="hidden" name="form-action" value="cache-expressions"/>
                                                            
                                                            <xsl:for-each select="$expressions">
                                                                <input type="hidden" name="expression-location[]">
                                                                    <xsl:choose>
                                                                        <xsl:when test="tei:milestone[@xml:id]">
                                                                            <xsl:attribute name="value" select="tei:milestone/@xml:id"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:attribute name="value" select="m:item/@uid"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                    
                                                                </input>
                                                            </xsl:for-each>
                                                            
                                                            <div class="center-vertical full-width">
                                                                <div class="text-muted small">
                                                                    <xsl:value-of select="'Once you have confirmed that these are the correct expressions of this glossary entry please select the option to cache the locations. This will help us to perform fast and accurate analysis of the glossary.'"/>
                                                                </div>
                                                                <div>
                                                                    <button type="submit" class="btn btn-danger pull-right">
                                                                        <xsl:value-of select="'Cache locations'"/>
                                                                    </button>
                                                                </div>
                                                            </div>
                                                            
                                                        </xsl:with-param>
                                                    </xsl:call-template>
                                                    
                                                </xsl:otherwise>
                                                
                                            </xsl:choose>
                                            
                                            <xsl:choose>
                                                
                                                <xsl:when test="not($request-test-alternative gt '') and $expressions">
                                                    
                                                    <div class="div-list">
                                                        <xsl:apply-templates select="$expressions"/>
                                                    </div>
                                                    
                                                </xsl:when>
                                                
                                                <xsl:when test="not($expressions)">
                                                    
                                                    <hr/>
                                                    <p class="text-center">
                                                        <xsl:value-of select="'No expressions of this glossary item found in this text!'"/>
                                                    </p>
                                                    <hr/>
                                                    
                                                </xsl:when>
                                                
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                        <!-- Tab for testing alternative spellings -->
                                        <div id="test-alternatives" class="tab-pane fade" role="tabpanel">
                                            
                                            <xsl:if test="$request-item-tab eq 'test-alternatives'">
                                                <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                            </xsl:if>
                                            
                                            <!-- Form: for searching the text -->
                                            <xsl:call-template name="form">
                                                <xsl:with-param name="tab-id" select="'test-alternatives'"/>
                                                <xsl:with-param name="form-class" select="'form-inline bottom-margin'"/>
                                                <xsl:with-param name="form-content">
                                                    
                                                    <div class="text-center">
                                                        
                                                        <p class="text-muted text-center small">
                                                            <xsl:value-of select="'This page shows the expressions for this glossary were you to add this alternative spelling'"/>
                                                        </p>
                                                        
                                                        <div class="form-group">
                                                            <label for="test-alternative">
                                                                <xsl:value-of select="'Alternative spelling: '"/>
                                                            </label>
                                                            <input type="text" name="test-alternative" id="test-alternative" class="form-control">
                                                                <xsl:attribute name="value" select="$request-test-alternative"/>
                                                            </input>
                                                        </div>
                                                        
                                                        <button type="submit" class="btn btn-primary">
                                                            <xsl:value-of select="'Find matches'"/>
                                                        </button>
                                                        
                                                    </div>
                                                    
                                                </xsl:with-param>
                                            </xsl:call-template>
                                            
                                            <xsl:choose>
                                                <xsl:when test="$request-test-alternative gt '' and $expressions">
                                                    
                                                    <div class="div-list">
                                                        <xsl:apply-templates select="$expressions"/>
                                                    </div>
                                                    
                                                </xsl:when>
                                                
                                                <xsl:when test="not($expressions)">
                                                    
                                                    <hr/>
                                                    <p class="text-center">
                                                        <xsl:value-of select="'No expressions of this glossary item found in this text!'"/>
                                                    </p>
                                                    <hr/>
                                                    
                                                </xsl:when>
                                                
                                            </xsl:choose>
                                        </div>
                                        
                                        <!-- Tab: A form for editing the glossary -->
                                        <div id="glossary-form" class="tab-pane fade" role="tabpanel">
                                            
                                            <xsl:if test="$request-item-tab eq 'glossary-form'">
                                                <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                            </xsl:if>
                                            
                                            <!-- Form: for editing the glossary item-->
                                            <xsl:call-template name="form">
                                                
                                                <xsl:with-param name="tab-id" select="'glossary-form'"/>
                                                <xsl:with-param name="form-action" select="'update-glossary'"/>
                                                <xsl:with-param name="form-content">
                                                    
                                                    <xsl:call-template name="glossary-form">
                                                        <xsl:with-param name="selected-glossary" select="$request-glossary"/>
                                                    </xsl:call-template>
                                                    
                                                </xsl:with-param>
                                                
                                            </xsl:call-template>
                                            
                                        </div>
                                        
                                        <!-- Tab: A form for editing the entity -->
                                        <div id="entity-form" class="tab-pane fade" role="tabpanel">
                                            
                                            <xsl:if test="$request-item-tab eq 'entity-form'">
                                                <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                            </xsl:if>
                                            
                                            <p class="text-muted small text-center">
                                                <xsl:value-of select="'Update the shared entity associated with this glossary item'"/>
                                            </p>
                                            
                                            <!-- Form: for editing the shared entity -->
                                            <xsl:call-template name="form">
                                                
                                                <xsl:with-param name="tab-id" select="'entity-form'"/>
                                                <xsl:with-param name="form-action" select="'edit-entity'"/>
                                                <xsl:with-param name="form-content">
                                                    
                                                    <input type="hidden" name="entity-id" value="{ $loop-entity/@xml:id }"/>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">
                                                            <xsl:value-of select="'Entity ID'"/>
                                                        </label>
                                                        <div class="col-sm-3">
                                                            <input type="text" value="{ $loop-entity/@xml:id }" class="form-control" disabled="disabled"/>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label for="entity-label" class="col-sm-2 control-label">
                                                            <xsl:value-of select="'Label'"/>
                                                        </label>
                                                        <div class="col-sm-6">
                                                            <input type="text" name="entity-label" class="form-control" id="entity-label" value="{ $loop-entity/m:label }"/>
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
                                                                            <xsl:if test="$loop-entity/m:type[@type = $loop-glossary-type]">
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
                                                    
                                                    <!-- Option to un-link from the entity -->
                                                    <xsl:choose>
                                                        <xsl:when test="$loop-entity">
                                                            <div class="form-group">
                                                                <div class="col-sm-offset-2 col-sm-10">
                                                                    <div class="checkbox">
                                                                        <label>
                                                                            <input type="checkbox" name="entity-un-link" value="1">
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
                                                        </xsl:when>
                                                    </xsl:choose>
                                                    
                                                    <div class="form-group">
                                                        <div class="col-sm-offset-2 col-sm-10">
                                                            <xsl:choose>
                                                                <xsl:when test="$loop-entity">
                                                                    
                                                                    <button type="submit">
                                                                        <xsl:attribute name="class" select="'btn btn-danger'"/>
                                                                        <xsl:value-of select="'Save changes'"/>
                                                                    </button>
                                                                    
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    
                                                                    <button type="submit">
                                                                        <xsl:attribute name="class" select="'btn btn-success'"/>
                                                                        <xsl:value-of select="'Create a shared entity for this Glossary item'"/>
                                                                    </button>
                                                                    
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </div>
                                                    </div>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                            
                                            <!-- List matched entities with links to those forms -->
                                            <xsl:choose>
                                                <xsl:when test="$matched-glossary-items[not(@uid = $loop-glossary-id)]">
                                                 
                                                    <xsl:for-each select="$matched-glossary-items">
                                                        
                                                        <xsl:sort select="if(@uid eq $loop-glossary-id) then 0 else 1"/>
                                                        
                                                        <xsl:variable name="loop-glossary-id" select="@uid"/>
                                                        
                                                        <fieldset>
                                                            <legend>
                                                                <xsl:value-of select="concat($loop-entity/@xml:id, ' in ', m:text/m:title)"/>
                                                            </legend>
                                                            
                                                            <!-- Title -->
                                                            <h3 class="no-top-margin sml-margin bottom">
                                                                <!-- A link to open the item -->
                                                                <xsl:call-template name="link">
                                                                    <xsl:with-param name="resource-id" select="m:text/@id"/>
                                                                    <xsl:with-param name="start-letter" select="upper-case(substring(m:sort-term, 1, 1))"/>
                                                                    <xsl:with-param name="glossary-id" select="$loop-glossary-id"/>
                                                                    <xsl:with-param name="link-text" select="m:term[@xml:lang eq 'en']"/>
                                                                </xsl:call-template>
                                                                <small>
                                                                    <xsl:value-of select="' / '"/>
                                                                    <a target="reading-room">
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:text/@id, '.html#', $loop-glossary-id)"/>
                                                                        <xsl:value-of select="$loop-glossary-id"/>
                                                                    </a>  
                                                                </small>
                                                            </h3>
                                                            
                                                            <!-- Terms -->
                                                            <div class=" sml-margin bottom">
                                                                <xsl:call-template name="terms">
                                                                    <xsl:with-param name="item" select="."/>
                                                                </xsl:call-template>
                                                            </div>
                                                            
                                                            <!-- Definition -->
                                                            <xsl:call-template name="definition">
                                                                <xsl:with-param name="item" select="."/>
                                                            </xsl:call-template>
                                                            
                                                        </fieldset>
                                                        
                                                    </xsl:for-each>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <hr/>
                                                    <div>
                                                        <p class="text-center">
                                                            <xsl:value-of select="'There are currently no other glossary items associated with this entity'"/>
                                                        </p>
                                                    </div>
                                                    <hr/>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                        <!-- Tab: Show possible entity matches for this glossary -->
                                        <div id="similar" class="tab-pane fade" role="tabpanel">
                                            
                                            <xsl:if test="$request-item-tab eq 'similar'">
                                                <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                            </xsl:if>
                                            
                                            <p class="text-center text-muted small">
                                                <xsl:value-of select="'Use this form to match glossary items from different texts that refer to the same entity. Rejecting a match will remove it from the list.'"/>
                                            </p>
                                            
                                            <xsl:for-each select="$similar-glossary-items">
                                                
                                                <xsl:sort select="if(@uid eq $loop-glossary-id) then 0 else 1"/>
                                                
                                                <xsl:variable name="similar-glossary" select="."/>
                                                <xsl:variable name="similar-glossary-id" select="$similar-glossary/@uid"/>
                                                <xsl:variable name="similar-entity" select="$similar-entities[m:definition[@type = 'glossary-item'][@id = $similar-glossary-id]][1]"/>
                                                <xsl:variable name="similar-entity-id" select="$similar-entity/@xml:id"/>
                                                
                                                <fieldset>
                                                    <legend>
                                                        <xsl:value-of select="concat('Possible match in ', m:text/m:title)"/>
                                                    </legend>
                                                    
                                                    <!-- Title -->
                                                    <div class="center-vertical full-width sml-margin bottom">
                                                        
                                                        <h3 class="no-top-margin no-bottom-margin">
                                                            <!-- A link to open the item -->
                                                            <xsl:call-template name="link">
                                                                <xsl:with-param name="resource-id" select="m:text/@id"/>
                                                                <xsl:with-param name="start-letter" select="upper-case(substring(m:sort-term, 1, 1))"/>
                                                                <xsl:with-param name="glossary-id" select="$similar-glossary-id"/>
                                                                <xsl:with-param name="link-text" select="m:term[@xml:lang eq 'en']"/>
                                                            </xsl:call-template>
                                                            <small>
                                                                <xsl:value-of select="' / '"/>
                                                                <a target="reading-room">
                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:text/@id, '.html#', $similar-glossary-id)"/>
                                                                    <xsl:value-of select="$similar-glossary-id"/>
                                                                </a>  
                                                            </small>
                                                        </h3>
                                                        
                                                        <div class="text-right">
                                                            <xsl:call-template name="type-labels">
                                                                <xsl:with-param name="entity" select="$similar-entity"/>
                                                            </xsl:call-template>
                                                        </div>
                                                        
                                                    </div>
                                                    
                                                    <!-- Terms -->
                                                    <div class="sml-margin bottom">
                                                        <xsl:call-template name="terms">
                                                            <xsl:with-param name="item" select="."/>
                                                        </xsl:call-template>
                                                    </div>
                                                    
                                                    <!-- Definition -->
                                                    <div class="sml-margin bottom">
                                                        <xsl:call-template name="definition">
                                                            <xsl:with-param name="item" select="."/>
                                                        </xsl:call-template>
                                                    </div>
                                                    
                                                    <!-- Entity -->
                                                    <xsl:if test="$similar-entity">
                                                        <p class="sml-margin bottom text-muted">
                                                            <xsl:value-of select="concat($similar-entity/@xml:id, ' : &#34;', $similar-entity/m:label, '&#34; has ', count($similar-entity/m:definition), ' glossary item(s)')"/>
                                                        </p>
                                                    </xsl:if>
                                                    
                                                    <div class="center-vertical align-right">
                                                        <div>
                                                            
                                                            <!-- Form: rejects this match -->
                                                            <xsl:call-template name="form">
                                                                <xsl:with-param name="form-action" select="'reject-match'"/>
                                                                <xsl:with-param name="tab-id" select="'similar'"/>
                                                                <xsl:with-param name="form-content">
                                                                    <input type="hidden" name="match-glossary-id">
                                                                        <xsl:attribute name="value" select="$similar-glossary-id"/>
                                                                    </input>
                                                                    <input type="hidden" name="entity-id">
                                                                        <xsl:attribute name="value" select="$similar-entity/@xml:id"/>
                                                                    </input>
                                                                    <button type="submit" class="btn btn-default btn-sm">
                                                                        <xsl:value-of select="'Reject'"/>
                                                                    </button>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                            
                                                        </div>
                                                        <div>
                                                            
                                                            <!-- Form: accept this match -->
                                                            <xsl:call-template name="form">
                                                                <xsl:with-param name="form-action" select="'accept-match'"/>
                                                                <xsl:with-param name="tab-id" select="'similar'"/>
                                                                <xsl:with-param name="form-content">
                                                                    <input type="hidden" name="match-glossary-id">
                                                                        <xsl:attribute name="value" select="$similar-glossary-id"/>
                                                                    </input>
                                                                    <input type="hidden" name="entity-id">
                                                                        <xsl:attribute name="value" select="$similar-entity/@xml:id"/>
                                                                    </input>
                                                                    <button type="submit" class="btn btn-danger btn-sm">
                                                                        <xsl:value-of select="'Match'"/>
                                                                    </button>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                            
                                                        </div>
                                                    </div>
                                                    
                                                </fieldset>
                                                
                                            </xsl:for-each>
                                            
                                            
                                            <xsl:if test="count($similar-glossary-items) eq 0">
                                                
                                                <hr/>
                                                <p class="text-center">
                                                    <xsl:value-of select="'No similar glossary items found in other texts'"/>
                                                </p>
                                                <hr/>
                                                
                                            </xsl:if>
                                        </div>
                                        
                                    </div>
                                
                                </xsl:if>
                            </div>
                        </xsl:for-each>
                    </div>
                    
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
        <xsl:param name="start-letter" as="xs:string" select="$request-start-letter"/>
        <xsl:param name="glossary-id" as="xs:string" select="$request-glossary-id"/>
        <xsl:param name="tab-id" as="xs:string" select="''"/>
        <xsl:param name="link-class" as="xs:string" select="''"/>
        <xsl:param name="link-text" as="xs:string" required="yes"/>
        
        <a>
            <xsl:call-template name="link-href">
                <xsl:with-param name="glossary-id" select="$glossary-id"/>
                <xsl:with-param name="tab-id" select="$tab-id"/>
            </xsl:call-template>
            <xsl:attribute name="class" select="$link-class"/>
            <xsl:value-of select="$link-text"/>
        </a>
        
    </xsl:template>
    
    <xsl:template name="link-href">
        
        <xsl:param name="resource-id" as="xs:string" select="$request-resource-id"/>
        <xsl:param name="start-letter" as="xs:string" select="$request-start-letter"/>
        <xsl:param name="glossary-id" as="xs:string" select="$request-glossary-id"/>
        <xsl:param name="tab-id" as="xs:string" select="''"/>
        
        <xsl:variable name="parameters" as="xs:string*">
            <!-- Maintain the state of the page -->
            <xsl:value-of select="concat('resource-id=', $resource-id)"/>
            <xsl:value-of select="concat('start-letter=', $start-letter)"/>
            <xsl:value-of select="concat('glossary-id=', $glossary-id)"/>
            <xsl:if test="$tab-id gt ''">
                <xsl:value-of select="concat('tab-id=', $tab-id)"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:attribute name="href">
            <xsl:value-of select="concat('/glossary.html?', string-join($parameters, '&amp;'),'#selected-entity')"/>
        </xsl:attribute>
        
    </xsl:template>
    
    <xsl:template name="form">
        
        <xsl:param name="glossary-id" as="xs:string" select="$request-glossary-id"/>
        <xsl:param name="tab-id" as="xs:string" select="''"/>
        <xsl:param name="form-action" as="xs:string" select="''"/>
        <xsl:param name="form-content" as="node()*" required="yes"/>
        <xsl:param name="form-class" as="xs:string" select="'form-horizontal'"/>
        
        <form action="/glossary.html#selected-entity" method="post">
            <xsl:attribute name="class" select="$form-class"/>
            
            <!-- Maintain the state of the page -->
            <input type="hidden" name="resource-id" value="{ $request-resource-id }"/>
            <input type="hidden" name="start-letter" value="{ $request-start-letter }"/>
            <input type="hidden" name="glossary-id" value="{ $glossary-id }"/>
            <xsl:if test="$tab-id gt ''">
                <input type="hidden" name="tab-id" value="{ $tab-id }"/>
            </xsl:if>
            <xsl:if test="$form-action  gt ''">
                <input type="hidden" name="form-action" value="{ $form-action  }"/>
            </xsl:if>
            
            <xsl:copy-of select="$form-content"/>
            
        </form>
        
    </xsl:template>
    
    <xsl:template name="glossary-form">
        
        <xsl:param name="selected-glossary" as="element(m:selected-glossary)?"/>
        
        <input type="hidden" name="glossary-update-id">
            <xsl:attribute name="value" select="$selected-glossary/m:item/@uid"/>
        </input>
        
        <xsl:variable name="terms" select="$selected-glossary/m:item/m:term"/>
        <div class="add-nodes-container">
            
            <xsl:for-each select="(1 to (if(count($terms) gt 0) then count($terms) else 1))">
                <xsl:variable name="index" select="."/>
                <div class="form-group add-nodes-group">
                    <xsl:if test="position() eq 1">
                        <label class="col-sm-2 control-label">
                            <xsl:attribute name="for" select="concat('term-', $index)"/>
                            <xsl:value-of select="'Term'"/>
                        </label>
                    </xsl:if>
                    <div class="col-sm-2">
                        <xsl:if test="not(position() eq 1)">
                            <xsl:attribute name="class" select="'col-sm-offset-2 col-sm-2'"/>
                        </xsl:if>
                        <xsl:call-template name="select-language">
                            <xsl:with-param name="selected-language" select="$terms[$index]/@xml:lang"/>
                            <xsl:with-param name="input-name" select="concat('term-lang-', $index)"/>
                        </xsl:call-template>
                    </div>
                    <div class="col-sm-6">
                        <input type="text" class="form-control">
                            <xsl:attribute name="name" select="concat('term-', $index)"/>
                            <xsl:attribute name="id" select="concat('term-', $index)"/>
                            <xsl:attribute name="value" select="$terms[$index]/text()"/>
                        </input>
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
        
        <xsl:variable name="alternative-spellings" select="$selected-glossary/m:item/m:alternative"/>
        <div class="add-nodes-container">
            
            <xsl:for-each select="(1 to (if(count($alternative-spellings) gt 0) then count($alternative-spellings) else 1))">
                <xsl:variable name="index" select="."/>
                <xsl:variable name="element-id" select="concat('term-alternative-', $index)"/>
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
                        </xsl:call-template>
                    </div>
                    <div class="col-sm-6">
                        <input type="text" name="{ $element-id }" id="{ $element-id }" class="form-control">
                            <xsl:attribute name="value" select="$alternative-spellings[$index]/text()"/>
                        </input>
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
            
            <label for="mode" class="col-sm-2 control-label">
                <xsl:value-of select="'Find expressions'"/>
            </label>
            
            <div class="col-sm-2">
                <div class="radio">
                    <label>
                        <input type="radio" name="glossary-mode">
                            <xsl:if test="$selected-glossary/m:item[not(@mode eq 'marked')]">
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
                        <input type="radio" name="glossary-mode">
                            <xsl:if test="$selected-glossary/m:item[@mode eq 'marked']">
                                <xsl:attribute name="checked" select="'checked'"/>
                            </xsl:if>
                        </input>
                        <xsl:value-of select="' Marked'"/>
                    </label>
                </div>
            </div>
            
        </div>
        
        <xsl:variable name="definitions" select="$selected-glossary/tei:gloss/tei:term[@type = 'definition']"/>
        <div class="add-nodes-container">
            
            <xsl:for-each select="(1 to (if(count($definitions) gt 0) then count($definitions) else 1))">
                <xsl:variable name="index" select="."/>
                <xsl:variable name="element-id" select="concat('definition-', $index)"/>
                <div class="form-group add-nodes-group">
                    <xsl:if test="$index eq 1">
                        <label for="{ $element-id }" class="col-sm-2 control-label">
                            <xsl:value-of select="'Definition'"/>
                        </label>
                    </xsl:if>
                    <div class="col-sm-10">
                        <xsl:if test="not($index eq 1)">
                            <xsl:attribute name="class" select="'col-sm-offset-2 col-sm-10'"/>
                        </xsl:if>
                        <!--<textarea name="{ $element-id }" id="{ $element-id }" class="form-control" rows="2">
                            <xsl:copy-of select="$definitions[$index]/node()"/>
                        </textarea>-->
                        <p class="form-control" rows="2" contenteditable="true" id="{ $element-id }">
                            <xsl:copy-of select="$definitions[$index]/node()"/>
                        </p>
                    </div>
                </div>
            </xsl:for-each>
            
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <a href="#add-nodes" class="add-nodes">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a definition'"/>
                    </a>
                </div>
            </div>
            
        </div>
        
        <!--
        <div class="col-sm-offset-2 col-sm-10 sml-margin top">
            <p class="small text-muted">
                <xsl:value-of select="'Definition text can be edited here but markup must be edited using an XML editor e.g. Oxygen.'"/>
            </p>
        </div>-->
        
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-2">
                <button type="submit" class="btn btn-danger">
                    <xsl:value-of select="'Save changes'"/>
                </button>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="select-language">
        
        <xsl:param name="selected-language" as="xs:string?"/>
        <xsl:param name="input-name" as="xs:string" required="yes"/>
        
        <select class="form-control">
            <xsl:attribute name="name" select="$input-name"/>
            <xsl:attribute name="id" select="$input-name"/>
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
                <xsl:if test="$selected-language eq 'bo-ltn'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Wylie'"/>
            </option>
            <option value="sa-ltn">
                <xsl:if test="$selected-language eq 'sa-ltn'">
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
    
    <xsl:template name="type-labels">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
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
        
    </xsl:template>
    
    <xsl:template name="terms">
        
        <xsl:param name="item" as="element(m:item)"/>
        
        <ul class="list-inline inline-dots no-bottom-margin">
            <xsl:for-each select="$item/m:term[not(@xml:lang eq 'en')]">
                <li>
                    <span>
                        <xsl:choose>
                            <xsl:when test="@xml:lang eq 'bo'">
                                <xsl:attribute name="class" select="'text-bo'"/>
                            </xsl:when>
                            <xsl:when test="@xml:lang eq 'sa-ltn'">
                                <xsl:attribute name="class" select="'text-sa'"/>
                            </xsl:when>
                            <xsl:when test="@xml:lang eq 'bo-ltn'">
                                <xsl:attribute name="class" select="'text-wy'"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
        </ul>
        
    </xsl:template>
    
    <xsl:template name="definition">
        <xsl:param name="item"/>
        <xsl:if test="$item/m:definition[node()]">
            <div class="text-info collapse-one-line">
                <xsl:for-each select="$item/m:definition[node()]">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="m:expressions/m:item">
        <div class="item translation">
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="m:expressions/m:item/m:item[@uid]">
        <div class="glossary-item rw">
            <div class="gtr">
                <a>
                    <xsl:attribute name="href" select="concat($page-url, '#', @uid)"/>
                    <xsl:value-of select="concat('g.', '?')"/>  
                </a>
            </div>
            <xsl:call-template name="glossary-item">
                <xsl:with-param name="glossary-item" select="."/>
            </xsl:call-template>
        </div>
    </xsl:template>
    
    <xsl:template match="m:expressions/m:item/tei:note[@place eq 'end']">
        <div class="rw">
            <div class="gtr">
                <a>
                    <xsl:attribute name="href" select="concat($page-url, '#', @xml:id)"/>
                    <xsl:value-of select="concat('Note ', @index)"/>  
                </a>
            </div>
            <p>
                <xsl:apply-templates select="node()"/>
            </p>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:match[@glossary-id][not(@requested-glossary eq 'true')]">
        <a class="glossary-link">
            <xsl:call-template name="link-href">
                <xsl:with-param name="glossary-id" select="@glossary-id"/>
                <xsl:with-param name="start-letter" select="''"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </a>
    </xsl:template>
    
</xsl:stylesheet>