<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:ops="http://operations.84000.co" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="tei-id" select="/m:response/m:knowledgebase/m:page/@xml:id" as="xs:string"/>
    <xsl:variable name="title" select="/m:response/m:knowledgebase/m:page/m:titles ! (m:title[@type eq 'articleTitle'], m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], m:title[@type eq 'mainTitle'])[1]" as="element(m:title)?"/>
    <xsl:variable name="entity" select="/m:response/m:entities/m:entity[m:instance/@id = $tei-id][1]" as="element(m:entity)?"/>
    <xsl:variable name="entity-label" select="($entity/m:label[@xml:lang eq 'en'], $entity/m:label[@xml:lang eq 'Sa-Ltn'], $entity/m:label)[1]" as="element(m:label)?"/>
    <xsl:variable name="request-show-tab" select="/m:response/m:request/@show-tab" as="xs:string?"/>
    <xsl:variable name="request-similar-search" select="/m:response/m:request/m:similar-search[1]/text()" as="xs:string?"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    
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
                            <xsl:value-of select="concat('TEI file: ', m:knowledgebase/m:page/@document-url)"/>
                        </a>
                    </div>
                    
                    <!-- Accordion -->
                    <div class="list-group accordion accordion-bordered accordion-background" role="tablist" aria-multiselectable="false">
                        
                        <xsl:attribute name="id" select="concat('accordion-', $tei-id)"/>
                        
                        <!-- Panel: KB form -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('kb-form-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'kb-form'"/>
                            <xsl:with-param name="persist" select="true()"/>
                            
                            <xsl:with-param name="title">
                                
                                <span class="h4">
                                    <xsl:value-of select="'Edit Headers: '"/>
                                </span>
                                
                                <span>
                                    <xsl:attribute name="class">
                                        <xsl:value-of select="common:lang-class($title/@xml:lang)"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="common:limit-str($title ! fn:normalize-space(.), 150)"/>
                                </span>
                                
                            </xsl:with-param>
                            
                            <xsl:with-param name="content">
                                
                                <hr class="sml-margin"/>
                                
                                <div class="row">
                                    
                                    <!-- Form -->
                                    <div class="col-sm-8">
                                        <div class="match-this-height" data-match-height="status-form">
                                        
                                            <form action="/edit-kb-header.html" method="post" class="form-horizontal form-update" data-loading="Updating knowledge base...">
                                                
                                                <input type="hidden" name="id" value="{ $tei-id }"/>
                                                <input type="hidden" name="form-action" value="update-kb-header"/>
                                                <input type="hidden" name="show-tab" value="kb-form"/>
                                                
                                                <!-- Titles -->
                                                <fieldset>
                                                    
                                                    <legend>
                                                        <xsl:value-of select="'Titles'"/>
                                                    </legend>
                                                    
                                                    <div class="add-nodes-container">
                                                        
                                                        <xsl:variable name="main-title" select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'articleTitle'][1]"/>
                                                        <xsl:variable name="other-titles" select="m:knowledgebase/m:page/m:titles/m:title except $main-title"/>
                                                        <xsl:variable name="title-types" select="m:title-types/m:title-type"/>
                                                        
                                                        <xsl:call-template name="title-controls">
                                                            <xsl:with-param name="title" select="$main-title"/>
                                                            <xsl:with-param name="title-index" select="1"/>
                                                            <xsl:with-param name="title-types" select="$title-types[@id eq 'articleTitle']"/>
                                                        </xsl:call-template>
                                                        
                                                        <xsl:choose>
                                                            <xsl:when test="$other-titles">
                                                                <xsl:for-each select="$other-titles">
                                                                    <xsl:call-template name="title-controls">
                                                                        <xsl:with-param name="title" select="."/>
                                                                        <xsl:with-param name="title-index" select="position() + 1"/>
                                                                        <xsl:with-param name="title-types" select="$title-types[@id = ('mainTitle', 'otherTitle')]"/>
                                                                    </xsl:call-template>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:call-template name="title-controls">
                                                                    <xsl:with-param name="title-index" select="2"/>
                                                                    <xsl:with-param name="title-types" select="$title-types[@id = ('mainTitle', 'otherTitle')]"/>
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
                                                    
                                                </fieldset>
                                                
                                                <!-- Status -->
                                                <fieldset>
                                                    
                                                    <legend>
                                                        <xsl:value-of select="'Status'"/>
                                                    </legend>
                                                    
                                                    <!--Publication Status-->
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
                                                            <input type="text" name="text-version" id="text-version" class="form-control" placeholder="e.g. v 1.0.1">
                                                                <!-- Force the addition of a version number if the form is used -->
                                                                <xsl:attribute name="value">
                                                                    <xsl:choose>
                                                                        <xsl:when test="m:knowledgebase/m:publication/m:edition[normalize-space(text())][1] ! normalize-space()">
                                                                            <xsl:value-of select="m:knowledgebase/m:publication/m:edition[normalize-space(text())][1]/text() ! normalize-space()"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="'0.0.1'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:attribute>
                                                                <xsl:if test="m:text-statuses/m:status[@selected eq 'selected'][@value eq '1']">
                                                                    <xsl:attribute name="required" select="'required'"/>
                                                                </xsl:if>
                                                            </input>
                                                        </div>
                                                        
                                                        <div class="col-sm-2">
                                                            <input type="text" class="form-control" disabled="disabled">
                                                                <xsl:attribute name="value">
                                                                    <xsl:choose>
                                                                        <xsl:when test="m:knowledgebase/m:publication/m:edition/tei:date[normalize-space(text())]">
                                                                            <xsl:value-of select="m:knowledgebase/m:publication/m:edition/tei:date/text() ! normalize-space()"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]')"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:attribute>
                                                            </input>
                                                        </div>
                                                    </div>
                                                    
                                                    <!-- Version note -->
                                                    <div class="form-group">
                                                        <label class="control-label col-sm-3" for="version-note">
                                                            <xsl:value-of select="'Version note:'"/>
                                                        </label>
                                                        <div class="col-sm-9">
                                                            <input type="text" name="version-note" id="version-note" class="form-control"/>
                                                        </div>
                                                    </div>
                                                    
                                                </fieldset>
                                                
                                                <!-- Submit button -->
                                                <div class="form-group">
                                                    <div class="col-sm-12">
                                                        <button type="submit" class="btn btn-primary pull-right">
                                                            <xsl:if test="m:knowledgebase/m:page[@locked-by-user gt '']">
                                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="'Save'"/>
                                                        </button>
                                                    </div>
                                                </div>
                                                
                                            </form>
                                            
                                        </div>
                                    </div>
                                    
                                    <!-- History -->
                                    <div class="col-sm-4">
                                        <div class="match-height-overflow" data-match-height="status-form">
                                            
                                            <xsl:apply-templates select="m:knowledgebase/m:status-updates"/>
                                            
                                        </div>
                                    </div>
                                    
                                </div>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <!-- Panel: Entity form -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('entity-form-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-form'"/>
                            <xsl:with-param name="persist" select="true()"/>
                            
                            <xsl:with-param name="title">
                                
                                <span class="h4">
                                    <xsl:value-of select="'Shared entity: '"/>
                                </span>
                                
                                <ul class="list-inline inline-dots">
                                    <xsl:choose>
                                        <xsl:when test="$entity">
                                            
                                            <li>
                                                <span>
                                                    <xsl:attribute name="class">
                                                        <xsl:value-of select="common:lang-class($entity-label/@xml:lang)"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="common:limit-str($entity-label ! fn:normalize-space(.), 150)"/>
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
                                            
                                            <xsl:variable name="entity-entry" select="key('related-entries', $entity/m:instance/@id, $root)[1]"/>
                                            <xsl:if test="$entity-entry">
                                                <li>
                                                    <a target="84000-glossary" class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $entity/@xml:id, '.html?view-mode=editor')"/>
                                                        <xsl:value-of select="'84000 Glossary'"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:variable name="entity-instance" select="key('entity-instance', $tei-id, $root)[1]"/>
                                            <xsl:variable name="entity-instance-flags" select="/m:response/m:entity-flags/m:flag[@id = $entity-instance/m:flag/@type]"/>
                                            <xsl:if test="$entity-instance-flags">
                                                <li>
                                                    <xsl:for-each select="$entity-instance-flags">
                                                        <xsl:value-of select="' '"/>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="m:label"/>
                                                        </span>
                                                    </xsl:for-each>
                                                </li>
                                            </xsl:if>
                                            
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
                                
                                <form action="/edit-kb-header.html" method="post" class="form-horizontal" data-loading="Updating entity...">
                                    
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
                                        <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                        <xsl:with-param name="instance" select="$entity/m:instance[@id eq $tei-id]"/>
                                    </xsl:call-template>
                                                                        
                                </form>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <!-- Entity instances and relations -->
                        <xsl:if test="$entity">
                            
                            <!-- Panel: Entity instances -->
                            <xsl:call-template name="expand-item">
                                
                                <xsl:with-param name="id" select="concat('entity-list-', $tei-id)"/>
                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                                <xsl:with-param name="active" select="$request-show-tab eq 'entity-list'"/>
                                <xsl:with-param name="persist" select="true()"/>
                                
                                <xsl:with-param name="title">
                                    <xsl:variable name="count-entity-instances" select="count($entity/m:instance[not(@id eq $tei-id)])"/>
                                    <span>
                                        <xsl:value-of select="' ↳ '"/>
                                    </span>
                                    <span class="badge badge-notification badge-info">
                                        <xsl:value-of select="$count-entity-instances"/>
                                    </span>
                                    <span class="badge-text">
                                        <xsl:value-of select="if($count-entity-instances eq 1) then 'grouped glossary entry' else 'grouped glossary entries'"/>
                                    </span>
                                </xsl:with-param>
                                
                                <xsl:with-param name="content">
                                    
                                    <hr class="sml-margin"/>
                                    
                                    <!-- List related glossary items -->
                                    <xsl:for-each select="/m:response/m:entities/m:related/m:text[m:entry/@id = $entity/m:instance/@id]">
                                        
                                        <xsl:sort select="@id/string()"/>
                                        
                                        <xsl:call-template name="related-text-entries">
                                            <xsl:with-param name="related-text" select="."/>
                                            <xsl:with-param name="entity" select="$entity"/>
                                            <xsl:with-param name="active-glossary-id" select="''"/>
                                        </xsl:call-template>
                                        
                                    </xsl:for-each>
                                    
                                    <!-- List related knowledgebase pages -->
                                    <xsl:call-template name="knowledgebase-page-instance">
                                        <xsl:with-param name="knowledgebase-page" select="/m:response/m:entities/m:related/m:page[@xml:id = $entity/m:instance/@id]"/>
                                        <xsl:with-param name="knowledgebase-active-id" select="$tei-id"/>
                                    </xsl:call-template>
                                    
                                </xsl:with-param>
                                
                            </xsl:call-template>
                            
                            <!-- Panel: Entity relations -->
                            <xsl:call-template name="expand-item">
                                
                                <xsl:with-param name="id" select="concat('entity-relations-', $tei-id)"/>
                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                                <xsl:with-param name="active" select="$request-show-tab eq 'entity-relations'"/>
                                <xsl:with-param name="persist" select="true()"/>
                                
                                <xsl:with-param name="title">
                                    
                                    <xsl:variable name="count-relations" select="count(distinct-values($entity/m:relation/@id))"/>
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
                                        
                                        <xsl:when test="$entity/m:relation">
                                            
                                            <xsl:call-template name="entity-summary"/>
                                            
                                            <div class="list-group accordion accordion-bordered" role="tablist" aria-multiselectable="false">
                                                
                                                <xsl:attribute name="id" select="'accordion-relations'"/>
                                                
                                                <xsl:for-each-group select="$entity/m:relation" group-by="@id">
                                                    
                                                    <xsl:sort select="if(@predicate = 'isUnrelated') then 1 else 0"/>
                                                    
                                                    <xsl:variable name="relation" select="current-group()[1]"/>
                                                    <xsl:variable name="relation-entity" select="key('related-entities', $relation/@id, $root)[1]"/>
                                                    
                                                    <xsl:call-template name="expand-item">
                                                        
                                                        <xsl:with-param name="accordion-selector" select="'#accordion-relations'"/>
                                                        <xsl:with-param name="id" select="concat('relation-', $relation/@id)"/>
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
                                                                                    <xsl:when test="$relation/@predicate = ('isUnrelated', 'sameAs')">
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
                                                                        
                                                                            <li>
                                                                                <xsl:call-template name="entity-type-labels">
                                                                                    <xsl:with-param name="entity" select="$relation-entity"/>
                                                                                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                                                                                </xsl:call-template>
                                                                            </li>
                                                                            
                                                                            <xsl:if test="/m:response/m:entity-types/m:type[@glossary-type = $relation-entity/m:type/@type]">
                                                                                <li>
                                                                                    <a target="84000-glossary" class="small">
                                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $relation/@id, '.html?view-mode=editor')"/>
                                                                                        <xsl:value-of select="'84000 Glossary'"/>
                                                                                    </a>
                                                                                </li>
                                                                            </xsl:if>
                                                                            
                                                                            <li>
                                                                                <a class="small">
                                                                                    <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', $tei-id, '&amp;form-action=merge-entities', '&amp;predicate=removeRelation', '&amp;entity-id=', $entity/@xml:id, '&amp;target-entity-id=', $relation/@id)"/>
                                                                                    <xsl:value-of select="'remove relation'"/>
                                                                                </a>
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
                                                                    <xsl:with-param name="active-knowledgebase-id" select="$tei-id"/>
                                                                    <xsl:with-param name="active-glossary-id" select="''"/>
                                                                </xsl:call-template>
                                                            </xsl:if>
                                                            
                                                            <xsl:if test="$relation[@predicate eq 'sameAs']">
                                                                <p class="text-muted italic">
                                                                    <xsl:value-of select="'Requests for ' || $relation/@id || ' will be directed to the merged entity ' || $entity/@xml:id"/>
                                                                </p>
                                                            </xsl:if>
                                                            
                                                        </xsl:with-param>
                                                        
                                                    </xsl:call-template>
                                                    
                                                </xsl:for-each-group>
                                                
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
                            
                            <xsl:with-param name="id" select="concat('entity-similar-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-similar'"/>
                            <xsl:with-param name="persist" select="true()"/>
                            
                            <xsl:with-param name="title">
                                
                                <xsl:variable name="count-similar-entities" select="count(m:similar/m:entity)"/>
                                
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
                                
                                <hr class="sml-margin"/>
                                
                                <form action="/edit-kb-header.html#entity-search" method="post" id="entity-search" class="form-horizontal sml-margin bottom" data-loading="Loading possible matches...">
                                    
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
                                    
                                    <xsl:when test="m:similar[m:entity]">
                                        
                                        <div class="sml-margin bottom">
                                            <xsl:value-of select="$title"/>
                                        </div>
                                        
                                        <div class="list-group accordion accordion-bordered" role="tablist" aria-multiselectable="false">
                                            
                                            <xsl:variable name="id" select="'accordion-similar-entities'"/>
                                            <xsl:attribute name="id" select="$id"/>
                                            
                                            <xsl:for-each select="m:similar/m:entity">
                                                
                                                <xsl:call-template name="expand-item">
                                                    
                                                    <xsl:with-param name="accordion-selector" select="'accordion-similar-entities'"/>
                                                    <xsl:with-param name="id" select="concat('accordion-similar-entities-', @xml:id)"/>
                                                    <xsl:with-param name="persist" select="true()"/>
                                                    
                                                    <xsl:with-param name="title">
                                                        
                                                        <form action="/edit-kb-header.html#entity-search" method="post" class="form-inline" data-loading="Merging entities...">
                                                            
                                                            <input type="hidden" name="id" value="{ $tei-id }"/>
                                                            <input type="hidden" name="form-action" value="{ if(not($entity)) then 'match-entity' else 'merge-entities' }"/>
                                                            <input type="hidden" name="similar-search" value="{ $request-similar-search }"/>
                                                            <input type="hidden" name="show-tab" value="entity-similar"/>
                                                            
                                                            <xsl:call-template name="entity-resolve-form-input">
                                                                <xsl:with-param name="entity" select="$entity"/>
                                                                <xsl:with-param name="target-entity" select="."/>
                                                                <xsl:with-param name="predicates" select="/m:response/m:entity-predicates//m:predicate"/>
                                                                <xsl:with-param name="target-entity-label">
                                                                    
                                                                    <xsl:variable name="label" select="(m:label[@xml:lang eq 'en'], m:label[@xml:lang eq 'Sa-Ltn'], m:label)[1]"/>
                                                                    
                                                                    <ul class="list-inline inline-dots">
                                                                        <li class="small">
                                                                            <span>
                                                                                <xsl:attribute name="class">
                                                                                    <xsl:value-of select="common:lang-class($label/@xml:lang)"/>
                                                                                </xsl:attribute>
                                                                                <xsl:value-of select="common:limit-str($label ! normalize-space(.), 80)"/>
                                                                            </span>
                                                                        </li>
                                                                        <li>
                                                                            <xsl:call-template name="entity-type-labels">
                                                                                <xsl:with-param name="entity" select="."/>
                                                                                <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
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
                                                            <xsl:with-param name="active-knowledgebase-id" select="$tei-id"/>
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
            <xsl:with-param name="page-title" select="concat($title, ' | Knowledge Base Header  | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Editing headers for Knowledge Base page: ', $title)"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="entity-summary">
        
        <div class="sml-margin bottom">
            <ul class="list-inline inline-dots sml-margin top bottom">
                
                <li>
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="common:lang-class($entity-label/@xml:lang)"/>
                        </xsl:attribute>
                        <xsl:value-of select="common:limit-str($entity-label ! fn:normalize-space(.), 150)"/>
                    </span>
                </li>
                
                <li>
                    <xsl:call-template name="entity-type-labels">
                        <xsl:with-param name="entity" select="$entity"/>
                        <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                    </xsl:call-template>
                </li>
                
            </ul>
        </div>
        
    </xsl:template>

</xsl:stylesheet>