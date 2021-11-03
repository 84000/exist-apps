<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="tei-id" select="m:knowledgebase/m:page/@xml:id"/>
        <xsl:variable name="title" select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][1]"/>
        <xsl:variable name="entity" select="m:entity"/>
        <xsl:variable name="entity-label" select="$entity/m:label[not(@derived) and not(@derived-transliterated)][1]"/>
        <xsl:variable name="request-show-tab" select="(m:request/@show-tab, 'kb-form')[1]"/>
        <xsl:variable name="request-similar-search" select="m:request/m:similar-search[1]/text()"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
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
                            <xsl:value-of select="concat('TEI file: ', m:knowledgebase/m:page/@document-url)"/>
                        </a>
                    </div>
                    
                    <!-- Accordion -->
                    <div class="list-group accordion accordion-background" role="tablist" aria-multiselectable="false">
                        
                        <xsl:attribute name="id" select="concat('accordion-', $tei-id)"/>
                        
                        <!-- Panel: KB form -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('kb-form-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'kb-form'"/>
                            <xsl:with-param name="persist" select="true()"/>
                            
                            <xsl:with-param name="title">
                                <xsl:value-of select="'Edit Headers'"/>
                            </xsl:with-param>
                            
                            <xsl:with-param name="content">
                                
                                <hr class="sml-margin"/>
                                
                                <div class="row">
                                    
                                    <!-- Form -->
                                    <div class="col-sm-8">
                                        
                                        <form action="/edit-kb-header.html" method="post" data-match-height="status-form" class="form-horizontal form-update match-this-height" data-loading="Updating knowledge base...">
                                            
                                            <input type="hidden" name="id" value="{ $tei-id }"/>
                                            <input type="hidden" name="form-action" value="update-kb-header"/>
                                            <input type="hidden" name="show-tab" value="kb-form"/>
                                            
                                            <!-- Titles -->
                                            <fieldset>
                                                
                                                <legend>
                                                    <xsl:value-of select="'Titles'"/>
                                                </legend>
                                                
                                                <div class="add-nodes-container">
                                                    
                                                    <xsl:variable name="main-title" select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][1]"/>
                                                    <xsl:variable name="main-title-lang" select="$main-title/@xml:lang"/>
                                                    <xsl:variable name="other-titles" select="m:knowledgebase/m:page/m:titles/m:title[count((. | $main-title)) ne 1]"/>
                                                    <xsl:variable name="title-types" select="m:title-types/m:title-type"/>
                                                    
                                                    <xsl:call-template name="title-controls">
                                                        <xsl:with-param name="title" select="$main-title"/>
                                                        <xsl:with-param name="title-index" select="1"/>
                                                        <xsl:with-param name="title-types" select="$title-types[@id eq 'mainTitle']"/>
                                                    </xsl:call-template>
                                                    
                                                    <xsl:choose>
                                                        <xsl:when test="$other-titles">
                                                            <xsl:for-each select="$other-titles">
                                                                <xsl:call-template name="title-controls">
                                                                    <xsl:with-param name="title" select="."/>
                                                                    <xsl:with-param name="title-index" select="position() + 1"/>
                                                                    <xsl:with-param name="title-types" select="$title-types[@id eq 'otherTitle']"/>
                                                                </xsl:call-template>
                                                            </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:call-template name="title-controls">
                                                                <xsl:with-param name="title-index" select="2"/>
                                                                <xsl:with-param name="title-types" select="$title-types[@id eq 'otherTitle']"/>
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
                                                        <xsl:value-of select="common:lang-class($entity/m:label[1]/@xml:lang)"/>
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
                                            
                                            <xsl:for-each select="/m:response/m:entity-flags/m:flag[@id = $entity/m:flag/@type]">
                                                <li>
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="m:label"/>
                                                    </span>
                                                </li>
                                            </xsl:for-each>
                                            
                                            <xsl:if test="$entity[m:instance[@type eq 'glossary-item']]">
                                                <li>
                                                    <a target="84000-glossary" class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $entity/@xml:id)"/>
                                                        <xsl:value-of select="'84000 Glossary'"/>
                                                    </a>
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
                                        <xsl:with-param name="entity-flags" select="/m:response/m:entity-flags/m:flag"/>
                                        <xsl:with-param name="instance" select="$entity/m:instance[@id eq $tei-id]"/>
                                    </xsl:call-template>
                                                                        
                                </form>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <!-- Panel: Entity instances -->
                        <xsl:if test="$entity">
                            <xsl:call-template name="expand-item">
                                
                                <xsl:with-param name="id" select="concat('entity-list-', $tei-id)"/>
                                <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                                <xsl:with-param name="active" select="$request-show-tab eq 'entity-list'"/>
                                <xsl:with-param name="persist" select="true()"/>
                                
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
                                    <xsl:for-each-group select="$entity/m:instance/m:entry" group-by="m:text/@id">
                                        
                                        <xsl:sort select="m:text[1]/@id"/>
                                        
                                        <xsl:call-template name="glossary-items-text-group">
                                            <xsl:with-param name="glossary-items" select="current-group()"/>
                                            <xsl:with-param name="active-glossary-id" select="$tei-id"/>
                                        </xsl:call-template>
                                        
                                    </xsl:for-each-group>
                                    
                                    <!-- List related knowledgebase pages -->
                                    <xsl:call-template name="knowledgebase-page-instance">
                                        <xsl:with-param name="knowledgebase-page" select="$entity/m:instance/m:page"/>
                                        <xsl:with-param name="active-kb-id" select="$tei-id"/>
                                    </xsl:call-template>
                                    
                                </xsl:with-param>
                                
                            </xsl:call-template>
                        </xsl:if>
                        
                        <!-- Panel: Entity relations -->
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="concat('entity-relations-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-relations'"/>
                            <xsl:with-param name="persist" select="true()"/>
                            
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
                                        
                                        <xsl:call-template name="entity-summary">
                                            <xsl:with-param name="entity" select="$entity"/>
                                        </xsl:call-template>
                                        
                                        <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                            
                                            <xsl:attribute name="id" select="'accordion-relations'"/>
                                            
                                            <xsl:for-each select="$entity/m:relation">
                                                
                                                <xsl:sort select="if(@predicate = 'isUnrelated') then 1 else 0"/>
                                                
                                                <xsl:variable name="relation" select="."/>
                                                
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
                                                                    <xsl:for-each select="$relation/m:entity/m:label[not(@derived) and not(@derived-transliterated)][1]">
                                                                        <li>
                                                                            <span>
                                                                                <xsl:attribute name="class">
                                                                                    <xsl:value-of select="common:lang-class(@xml:lang)"/>
                                                                                </xsl:attribute>
                                                                                <xsl:value-of select="common:limit-str(text(), 80)"/>
                                                                            </span>
                                                                        </li>
                                                                    </xsl:for-each>
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
                                                                        <a class="small">
                                                                            <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', $tei-id, '&amp;form-action=merge-entities', '&amp;predicate=removeRelation', '&amp;entity-id=', $entity/@xml:id, '&amp;target-entity-id=', $relation/@id)"/>
                                                                            <xsl:value-of select="'remove relation'"/>
                                                                        </a>
                                                                    </li>
                                                                </ul>
                                                            </div>
                                                            
                                                        </div>
                                                        
                                                    </xsl:with-param>
                                                    
                                                    <xsl:with-param name="content">
                                                        
                                                        <hr class="sml-margin"/>
                                                        
                                                        <xsl:call-template name="entity-option-content">
                                                            <xsl:with-param name="entity" select="m:entity"/>
                                                            <xsl:with-param name="active-kb-id" select="''"/>
                                                            <xsl:with-param name="active-glossary-id" select="$tei-id"/>
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
                            
                            <xsl:with-param name="id" select="concat('entity-similar-', $tei-id)"/>
                            <xsl:with-param name="accordion-selector" select="concat('#accordion-', $tei-id)"/>
                            <xsl:with-param name="active" select="$request-show-tab eq 'entity-similar'"/>
                            <xsl:with-param name="persist" select="true()"/>
                            
                            <xsl:with-param name="title">
                                
                                <xsl:variable name="count-similar-entities" select="count(m:similar-entities/m:entity)"/>
                                
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
                                        <xsl:when test="$entity">
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
                                
                                <form action="/edit-kb-header.html#entity-search" method="post" id="entity-search" class="form-horizontal bottom-margin" data-loading="Loading possible matches...">
                                    
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
                                        
                                        <xsl:if test="$entity">
                                            <xsl:call-template name="entity-summary">
                                                <xsl:with-param name="entity" select="$entity"/>
                                            </xsl:call-template>
                                        </xsl:if>
                                        
                                        <div class="list-group accordion" role="tablist" aria-multiselectable="false">
                                            
                                            <xsl:variable name="id" select="'accordion-similar-entities'"/>
                                            <xsl:attribute name="id" select="$id"/>
                                            
                                            <xsl:for-each select="m:similar-entities/m:entity">
                                                
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
                                                                    
                                                                    <xsl:variable name="label" select="m:label[not(@derived) and not(@derived-transliterated)][1]"/>
                                                                    
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
            <xsl:with-param name="page-title" select="concat($title, ' | Knowledge Base Header  | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Editing headers for Knowledge Base page: ', $title)"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="entity-summary">
        
        <xsl:param name="entity" as="element(m:entity)"/>
        
        <ul class="list-inline inline-dots">
            
            <xsl:for-each select="/m:response/m:knowledgebase/m:page/m:titles/m:title[not(@xml:lang eq 'en')]">
                <li>
                    <span>
                        <xsl:attribute name="class" select="ops:lang-class(@xml:lang)"/>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
            
            <li>
                <xsl:call-template name="entity-type-labels">
                    <xsl:with-param name="entity" select="$entity"/>
                    <xsl:with-param name="entity-types" select="/m:response/m:entity-types/m:type"/>
                </xsl:call-template>
            </li>
            
        </ul>
    </xsl:template>

</xsl:stylesheet>