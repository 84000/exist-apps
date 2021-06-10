<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="tei-id" select="m:knowledgebase/m:page/@xml:id"/>
        <xsl:variable name="title" select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][1]"/>
        <xsl:variable name="entity" select="m:entity"/>
        <xsl:variable name="request-show-tab" select="(m:request/@show-tab, 'kb-form')[1]"/>
        <xsl:variable name="request-similar-search" select="m:request/m:similar-search[1]/text()"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Title -->
                    <h2 class="no-top-margin sml-margin bottom">
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', $tei-id, '.html?view-mode=editor')"/>
                            <xsl:attribute name="target" select="concat($tei-id, '.html')"/>
                            <xsl:value-of select="$title"/>
                        </a>
                    </h2>
                    
                    <!-- Link to TEI -->
                    <div class="sml-margin bottom">
                        <a class="text-muted small">
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', $tei-id, '.tei')"/>
                            <xsl:attribute name="target" select="concat($tei-id, '.tei')"/>
                            <xsl:value-of select="concat('TEI file: ', m:knowledgebase/m:page/@uri)"/>
                        </a>
                    </div>
                    
                    <!-- Accordion -->
                    <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                        
                        <xsl:attribute name="id" select="concat('accordion-', $tei-id)"/>
                        
                        <!-- Panel: KB form -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('kb-form-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'kb-form'"/>
                            
                            <xsl:with-param name="title">
                                <xsl:value-of select="'Edit Headers'"/>
                            </xsl:with-param>
                            
                            <xsl:with-param name="content">
                                
                                <hr class="sml-margin"/>
                                
                                <div class="row">
                                    
                                    <!-- Form -->
                                    <div class="col-sm-8">
                                        <form action="/edit-kb-header.html" method="post" class="form-horizontal form-update">
                                            
                                            <input type="hidden" name="id" value="{ $tei-id }"/>
                                            <input type="hidden" name="form-action" value="update-kb-header"/>
                                            <input type="hidden" name="show-tab" value="kb-form"/>
                                            
                                            <!-- Titles -->
                                            <fieldset>
                                                
                                                <legend>
                                                    <xsl:value-of select="'Titles'"/>
                                                </legend>
                                                
                                                <div class="add-nodes-container">
                                                    <xsl:choose>
                                                        <xsl:when test="m:knowledgebase/m:page/m:titles/m:title">
                                                            <xsl:call-template name="titles-controls">
                                                                <xsl:with-param name="text-titles" select="m:knowledgebase/m:page/m:titles/m:title"/>
                                                                <xsl:with-param name="title-types" select="m:title-types/m:title-type"/>
                                                                <xsl:with-param name="title-langs" select="m:title-types/m:title-lang"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:call-template name="titles-controls">
                                                                <xsl:with-param name="text-titles">
                                                                    <m:title/>
                                                                </xsl:with-param>
                                                                <xsl:with-param name="title-types" select="m:title-types/m:title-type"/>
                                                                <xsl:with-param name="title-langs" select="m:title-types/m:title-lang"/>
                                                            </xsl:call-template>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <div class="form-group">
                                                        <div class="col-sm-12">
                                                            <a href="#add-nodes" class="add-nodes">
                                                                <span class="monospace">
                                                                    <xsl:value-of select="'+'"/>
                                                                </span>
                                                                <xsl:value-of select="' add a title'"/>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                            </fieldset>
                                            
                                            <!-- Status -->
                                            <fieldset>
                                                
                                                <legend>
                                                    <xsl:value-of select="'Status'"/>
                                                </legend>
                                                
                                                <!--Translation Status-->
                                                <div class="form-group">
                                                    <label class="control-label col-sm-3" for="publication-status">
                                                        <xsl:value-of select="'Publication status:'"/>
                                                    </label>
                                                    <div class="col-sm-9">
                                                        <select class="form-control" name="publication-status" id="publication-status">
                                                            <xsl:for-each select="m:text-statuses/m:status">
                                                                <xsl:sort select="@value eq '0'"/>
                                                                <xsl:sort select="@value"/>
                                                                <option>
                                                                    <xsl:attribute name="value" select="@value"/>
                                                                    <xsl:if test="@selected eq 'selected'">
                                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="concat(@value, ' / ', text())"/>
                                                                </option>
                                                            </xsl:for-each>
                                                        </select>
                                                    </div>
                                                </div>
                                                
                                                <!--Publication Date-->
                                                <div class="form-group">
                                                    <label class="control-label col-sm-3" for="publication-date">
                                                        <xsl:value-of select="'Publication date:'"/>
                                                    </label>
                                                    <div class="col-sm-3">
                                                        <input type="date" name="publication-date" id="publication-date" class="form-control">
                                                            <xsl:attribute name="value" select="m:knowledgebase/m:publication/m:publication-date"/>
                                                            <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                                <xsl:attribute name="required" select="'required'"/>
                                                            </xsl:if>
                                                        </input>
                                                    </div>
                                                    
                                                </div>
                                                
                                                <!--Version-->
                                                <div class="form-group">
                                                    <label class="control-label col-sm-3" for="text-version">
                                                        <xsl:value-of select="'Version:'"/>
                                                    </label>
                                                    <div class="col-sm-2">
                                                        <input type="text" name="text-version" id="text-version" class="form-control" placeholder="e.g. v 1.0">
                                                            <!-- Force the addition of a version number if the form is used -->
                                                            <xsl:attribute name="value">
                                                                <xsl:choose>
                                                                    <xsl:when test="m:knowledgebase/m:publication/m:edition/text()[1]/normalize-space()">
                                                                        <xsl:value-of select="m:knowledgebase/m:publication/m:edition/text()[1]/normalize-space()"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="'0.0.1'"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:attribute>
                                                            <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                                <xsl:attribute name="required" select="'required'"/>
                                                            </xsl:if>
                                                        </input>
                                                    </div>
                                                    <div class="col-sm-2">
                                                        <input type="text" name="text-version-date" id="text-version-date" class="form-control" placeholder="e.g. 2019">
                                                            <xsl:attribute name="value">
                                                                <xsl:choose>
                                                                    <xsl:when test="m:knowledgebase/m:publication/m:edition/tei:date/text()/normalize-space()">
                                                                        <xsl:value-of select="m:knowledgebase/m:publication/m:edition/tei:date/text()/normalize-space()"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]')"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:attribute>
                                                            <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                                <xsl:attribute name="required" select="'required'"/>
                                                            </xsl:if>
                                                        </input>
                                                    </div>
                                                </div>
                                                
                                                <!-- Version note -->
                                                <div class="form-group">
                                                    <label class="control-label col-sm-3" for="text-version">
                                                        <xsl:value-of select="'Version note:'"/>
                                                    </label>
                                                    <div class="col-sm-9">
                                                        <input type="text" name="update-notes" id="update-notes" class="form-control"/>
                                                    </div>
                                                </div>
                                                
                                            </fieldset>
                                            
                                            <!-- Submit button -->
                                            <div class="form-group">
                                                <div class="col-sm-12">
                                                    <button type="submit" class="btn btn-primary pull-right">
                                                        <xsl:value-of select="'Save'"/>
                                                    </button>
                                                </div>
                                            </div>
                                            
                                        </form>
                                        
                                    </div>
                                    
                                    <!-- History -->
                                    <div class="col-sm-4">
                                        
                                        <xsl:apply-templates select="m:knowledgebase/m:status-updates"/>
                                        
                                    </div>
                                    
                                </div>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <!-- Panel: Entity form -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('entity-form-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-form'"/>
                            
                            <xsl:with-param name="title">
                                <ul class="list-inline inline-dots no-bottom-margin">
                                    <xsl:choose>
                                        <xsl:when test="$entity">
                                            
                                            <li>
                                                <xsl:value-of select="'Entity: '"/>
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
                                                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:entity-type"/>
                                                </xsl:call-template>
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
                            
                            <xsl:with-param name="content">
                                
                                <hr class="sml-margin"/>
                                
                                <xsl:call-template name="entity-form-warning">
                                    <xsl:with-param name="entity" select="$entity"/>
                                </xsl:call-template>
                                
                                <form action="/edit-kb-header.html" method="post" class="form-horizontal">
                                    
                                    <input type="hidden" name="id" value="{ $tei-id }"/>
                                    <input type="hidden" name="knowledgebase-id" value="{ $tei-id }"/>
                                    <input type="hidden" name="form-action" value="update-entity"/>
                                    <input type="hidden" name="show-tab" value="entity-form"/>
                                    
                                    <xsl:call-template name="entity-form-input">
                                        <xsl:with-param name="entity" select="$entity"/>
                                        <xsl:with-param name="context-id" select="$tei-id"/>
                                        <xsl:with-param name="default-label-text" select="$title/text()"/>
                                        <xsl:with-param name="default-label-lang" select="$title/@xml:lang"/>
                                        <xsl:with-param name="default-entity-type" select="''"/>
                                        <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:entity-type[@group eq 'knowledgebase-article']"/>
                                    </xsl:call-template>
                                                                        
                                </form>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <!-- Panel: Entity list -->
                        <xsl:if test="$entity">
                            <xsl:call-template name="expand-item">
                                
                                <xsl:with-param name="id" select="concat('entity-list-', $tei-id)"/>
                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                                <xsl:with-param name="active" select="$request-show-tab eq 'entity-list'"/>
                                
                                <xsl:with-param name="title">
                                    <span class="badge badge-notification badge-muted">
                                        <xsl:value-of select="count($entity/m:instance)"/>
                                    </span>
                                    <xsl:value-of select="' elements grouped'"/>
                                </xsl:with-param>
                                
                                <xsl:with-param name="content">
                                    
                                    <hr class="sml-margin"/>
                                    
                                    <!-- List related glossary items -->
                                    <xsl:for-each-group select="m:entity-instances/m:item" group-by="m:text/@id">
                                        
                                        <xsl:sort select="m:text[1]/@id"/>
                                        
                                        <xsl:call-template name="glossary-items-text-group">
                                            <xsl:with-param name="glossary-items" select="current-group()"/>
                                            <xsl:with-param name="active-glossary-id" select="$tei-id"/>
                                        </xsl:call-template>
                                        
                                    </xsl:for-each-group>
                                    
                                    <!-- List related knowledgebase pages -->
                                    <xsl:call-template name="knowledgebase-page-instance">
                                        <xsl:with-param name="knowledgebase-page" select="m:entity-instances/m:page"/>
                                        <xsl:with-param name="active-kb-id" select="$tei-id"/>
                                    </xsl:call-template>
                                    
                                </xsl:with-param>
                                
                            </xsl:call-template>
                        </xsl:if>
                        
                        <!-- Panel: Entity matches -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('entity-similar-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-similar'"/>
                            
                            <xsl:with-param name="title">
                                
                                <xsl:variable name="count-similar-entities" select="count(m:similar-entities/m:entity)"/>
                                <span class="badge badge-notification">
                                    <xsl:if test="$count-similar-entities eq 0">
                                        <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                    </xsl:if>
                                    <xsl:value-of select="$count-similar-entities"/>
                                </span>
                                <xsl:choose>
                                    <xsl:when test="$entity">
                                        <xsl:value-of select="' similar entities un-resolved'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="' possible matches'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </xsl:with-param>
                            
                            <xsl:with-param name="content">
                                
                                <hr class="sml-margin"/>
                                
                                <form action="/edit-kb-header.html#entity-search" method="post" id="entity-search" class="form-horizontal bottom-margin">
                                    
                                    <input type="hidden" name="id" value="{ $tei-id }"/>
                                    <input type="hidden" name="show-tab" value="entity-similar"/>
                                    
                                    <div class="input-group">
                                        
                                        <input type="text" name="similar-search" class="form-control" id="similar-search" value="{ $request-similar-search }" placeholder="Widen search..."/>
                                        
                                        <div class="input-group-btn">
                                            <button type="submit" class="btn btn-primary" data-loading="Searching for similar terms...">
                                                <i class="fa fa-search"/>
                                            </button>
                                        </div>
                                        
                                    </div>
                                    
                                </form>
                                
                                <xsl:choose>
                                    
                                    <xsl:when test="m:similar-entities[m:entity]">
                                        
                                        <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                            
                                            <xsl:variable name="id" select="'accordion-similar-entities'"/>
                                            <xsl:attribute name="id" select="$id"/>
                                            
                                            <xsl:for-each select="m:similar-entities/m:entity">
                                                
                                                <xsl:call-template name="expand-item">
                                                    
                                                    <xsl:with-param name="accordion-selector" select="'accordion-similar-entities'"/>
                                                    <xsl:with-param name="id" select="concat('accordion-similar-entities-', @xml:id)"/>
                                                    
                                                    <xsl:with-param name="title">
                                                        
                                                        <form action="/edit-kb-header.html#entity-search" method="post" class="form-inline">
                                                            
                                                            <input type="hidden" name="id" value="{ $tei-id }"/>
                                                            <input type="hidden" name="form-action" value="{ if(not($entity)) then 'match-entity' else 'merge-entities' }"/>
                                                            <input type="hidden" name="similar-search" value="{ $request-similar-search }"/>
                                                            <input type="hidden" name="show-tab" value="entity-similar"/>
                                                            
                                                            <xsl:call-template name="entity-resolve-form-input">
                                                                <xsl:with-param name="entity" select="$entity"/>
                                                                <xsl:with-param name="target-entity" select="."/>
                                                                <xsl:with-param name="predicates" select="/m:response/m:entity-predicates//m:predicate"/>
                                                                <xsl:with-param name="target-entity-label">
                                                                    <ul class="list-inline inline-dots no-bottom-margin">
                                                                        <li class="small">
                                                                            <span>
                                                                                <xsl:attribute name="class">
                                                                                    <xsl:value-of select="common:lang-class(m:label[1]/@xml:lang)"/>
                                                                                </xsl:attribute>
                                                                                <xsl:value-of select="common:limit-str(m:label[1] ! normalize-space(.), 80)"/>
                                                                            </span>
                                                                        </li>
                                                                        <li>
                                                                            <xsl:call-template name="entity-type-labels">
                                                                                <xsl:with-param name="entity" select="."/>
                                                                                <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:entity-type"/>
                                                                            </xsl:call-template>
                                                                        </li>
                                                                        <li class="small">
                                                                            <xsl:value-of select="concat('Groups ', count(m:instance), ' elements')"/>
                                                                        </li>
                                                                    </ul>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                            
                                                        </form>
                                                        
                                                    </xsl:with-param>
                                                    
                                                    <xsl:with-param name="content">
                                                        
                                                        <xsl:call-template name="entity-option-content">
                                                            <xsl:with-param name="entity" select="."/>
                                                            <xsl:with-param name="active-glossary-id" select="''"/>
                                                            <xsl:with-param name="active-kb-id" select="$tei-id"/>
                                                        </xsl:call-template>
                                                        
                                                    </xsl:with-param>
                                                    
                                                    
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
                                    
                                
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                    </div>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat($title, ' - edit  | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Editing headers for Knowledge Base page: ', $title)"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>