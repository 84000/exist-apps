<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="functions.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()" as="xs:string"/>
    <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
    
    <!-- Page header -->
    <xsl:template name="operations-page">
        
        <xsl:param name="active-tab"/>
        <xsl:param name="tab-content" required="yes"/>
        <xsl:param name="aside-content"/>
        
        <div class="title-band hidden-print">
            <div class="container">
                <div class="center-vertical full-width">
                    <span class="logo">
                        <img alt="84000 logo">
                            <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                        </img>
                    </span>
                    <span>
                        <h1 class="title">
                            <xsl:value-of select="'Project Management'"/>
                        </h1>
                    </span>
                    <span class="text-right">
                        <a target="reading-room">
                            <xsl:attribute name="href" select="$reading-room-path"/>
                            <xsl:value-of select="'Reading Room'"/>
                        </a>
                    </span>
                </div>
            </div>
        </div>
        
        <main class="content-band">
            <div class="container">
                <xsl:call-template name="tabs">
                    <xsl:with-param name="active-tab" select="$active-tab"/>
                </xsl:call-template>
                <div class="tab-content">
                    <xsl:copy-of select="$tab-content"/>
                </div>
            </div>
        </main>
        
        <aside>
            <xsl:sequence select="$aside-content"/>
        </aside>
        
    </xsl:template>
    
    <!-- Generic alert -->
    <xsl:template name="alert-updated">
        <xsl:if test="m:updates/m:updated[@update]">
            
            <div class="alert alert-success alert-temporary" role="alert">
                <xsl:value-of select="'Updated'"/>
            </div>
            
            <xsl:choose>
                <xsl:when test="m:updates/m:updated[@update][@node eq 'text-version']">
                    <div class="alert alert-warning" role="alert">
                        <xsl:value-of select="'The version number has been updated'"/>
                    </div>
                </xsl:when>
                <xsl:when test="m:updates/m:updated[@update][@node eq 'cache-glossary']">
                    <div class="alert alert-warning" role="alert">
                        <xsl:value-of select="'Glossary locations have been cached'"/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="alert alert-danger" role="alert">
                        <xsl:value-of select="'To ensure these updates are deployed to the distribution server please update the version in the status section!!'"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:if>
    </xsl:template>
    
    <!-- Alert if translation is locked -->
    <xsl:template name="alert-translation-locked">
        <xsl:variable name="element" select="(//m:*[@locked-by-user][@document-url])[1]"/>
        <xsl:if test="$element[@locked-by-user gt '']">
            <div class="alert alert-danger" role="alert">
                <p class="break">
                    <span class="text-bold">
                        <xsl:value-of select="concat('This file is currenly locked by user ', $element/@locked-by-user)"/>
                    </span>
                    <br/>
                    <small class="monospace">
                        <xsl:value-of select="$element/@document-url"/>
                    </small>
                    <br/>
                    <small>
                        <xsl:value-of select="'You cannot modify this file until the lock is released'"/>
                    </small>
                </p>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- Tabs -->
    <xsl:template name="tabs">
        <xsl:param name="active-tab"/>
        <ul class="nav nav-tabs active-tab-refresh hidden-print" role="tablist">
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/index'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="index.html">
                    <xsl:value-of select="'Summary'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/search'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="search.html">
                    <xsl:value-of select="'Texts'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sections'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sections.html">
                    <xsl:value-of select="'Sections'"/>
                </a>
            </li>
            <!--<li role="presentation">
                <xsl:if test="$active-tab eq 'operations/knowledgebase'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="knowledgebase.html">
                    <xsl:value-of select="'Knowledge Base'"/>
                </a>
            </li>-->
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sponsors'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sponsors.html">
                    <xsl:value-of select="'Sponsors'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translators'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translators.html">
                    <xsl:value-of select="'Contributors'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-teams'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-teams.html">
                    <xsl:value-of select="'Teams'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-institutions'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-institutions.html">
                    <xsl:value-of select="'Institutions'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sys-config'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sys-config.html">
                    <xsl:value-of select="'Config'"/>
                </a>
            </li>
            <xsl:if test="$active-tab eq 'operations/glossary'">
                <li role="presentation">
                    <xsl:if test="$active-tab eq 'operations/glossary'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a>
                        <xsl:choose>
                            <xsl:when test="/m:response/m:request/@resource-id gt ''">
                                <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', /m:response/m:request/@resource-id, '&amp;resource-type=', /m:response/m:request/@resource-type)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href" select="'/edit-glossary.html'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="data-loading" select="'Loading glossary...'"/>
                        <xsl:value-of select="'Glossary'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/quotes'">
                <li role="presentation">
                    <xsl:if test="$active-tab eq 'operations/quotes'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-quotes.html?resource-id=', /m:response/m:request/@resource-id, '&amp;part=', /m:response/m:request/@part)"/>
                        <xsl:attribute name="data-loading" select="'Loading quotes...'"/>
                        <xsl:value-of select="'Quotes'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Text Header'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-kb-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', /m:response/m:request/@id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Knowledge Base Article'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-sponsors'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', /m:response/m:request/@id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Sponsorship'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-sponsor'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-sponsor.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Sponsor'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', /m:response/m:request/@id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Contributor'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-team'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', /m:response/m:request/@id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Translator Team'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-institution'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', /m:response/m:request/@id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Translator Institution'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-submission'">
                <li role="presentation">
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@text-id, '#submissions-form')"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Text Header'"/>
                    </a>
                </li>
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-submission.html?text-id=', /m:response/m:request/@text-id, '&amp;submission-id=', /m:response/m:request/@submission-id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit Submission'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/annotation-tei'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/annotation-tei.html?text-id=', /m:response/m:request/@text-id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Archived for Annotations'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-tm'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', /m:response/m:request/@text-id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Edit TM'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/source'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/source.html?text-id=', /m:response/m:request/@text-id)"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <xsl:value-of select="'Source Text'"/>
                    </a>
                </li>
            </xsl:if>
        </ul>
    </xsl:template>
    
    <!-- Acknowledgements -->
    <xsl:template name="acknowledgements">
        
        <xsl:param name="acknowledgements" required="yes"/>
        <xsl:param name="group" as="xs:string" required="yes"/>
        <xsl:param name="css-class" as="xs:string" required="yes"/>
        <xsl:param name="link-href" as="xs:string" required="yes"/>
        
        <xsl:choose>
            
            <xsl:when test="$acknowledgements">
                <xsl:for-each select="$acknowledgements">
                    <xsl:sort select="xs:integer(m:toh/@number[1])"/>
                    <div>
                        <xsl:attribute name="class" select="$css-class"/>
                        <xsl:if test="$group gt ''">
                            <xsl:attribute name="data-match-height" select="concat('group-', $group)"/>
                        </xsl:if>
                        <div class="pull-quote">
                            
                            <xsl:choose>
                                <xsl:when test="@status-group eq 'published'">
                                    <xsl:attribute name="class" select="'pull-quote green-quote'"/>
                                </xsl:when>
                                <xsl:when test="@status-group = ('translated', 'in-translation')">
                                    <xsl:attribute name="class" select="'pull-quote orange-quote'"/>
                                </xsl:when>
                                <xsl:when test="@status-group eq 'in-application'">
                                    <xsl:attribute name="class" select="'pull-quote orange-red'"/>
                                </xsl:when>
                            </xsl:choose>
                            
                            <!-- Text title -->
                            <div class="top-vertical full-width">
                                <a>
                                    <xsl:attribute name="href" select="replace($link-href, '@translation-id', @translation-id)"/>
                                    <xsl:value-of select="m:toh/m:full"/> / <xsl:value-of select="m:title"/>
                                </a>
                                <span class="text-right">
                                    <xsl:copy-of select="ops:sponsorship-status(m:sponsorship-status/m:status)"/>
                                    <xsl:copy-of select="ops:translation-status(@status-group)"/>
                                </span>
                            </div>
                            
                            <div class="small">
                                
                                <!-- Contributions -->
                                <xsl:if test="m:contribution">
                                    <div>
                                        <ul class="list-inline inline-dots">
                                            <xsl:for-each select="m:contribution">
                                                <xsl:variable name="contribution" select="."/>
                                                <li class="text-warning">
                                                    <xsl:value-of select="/m:response/m:contributor-types/m:contributor-type[@node-name eq $contribution/@node-name][@role eq $contribution/@role]/m:label"/>
                                                </li>
                                            </xsl:for-each>
                                        </ul>  
                                    </div>
                                </xsl:if>
                                
                                <!-- Acknowledgment statement -->
                                <xsl:choose>
                                    <xsl:when test="tei:div[@type eq 'acknowledgment'][descendant::text()[normalize-space()]]">
                                        <xsl:apply-templates select="tei:div[@type eq 'acknowledgment']/node()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p class="text-muted italic">
                                            <xsl:value-of select="'Not explicitly mentioned in the acknowledgment statement'"/>
                                        </p>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </div>
                        </div>
                    </div>
                </xsl:for-each>
            </xsl:when>
            
            <xsl:otherwise>
                <div class="text-muted italic">
                    <xsl:value-of select="'No acknowledgments'"/>
                </div>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Title controls -->
    <xsl:template name="title-controls">
        
        <xsl:param name="title" as="element(m:title)?"/>
        <xsl:param name="title-index" as="xs:integer"/>
        <xsl:param name="title-types" required="yes"/>
        <xsl:param name="source-keys" as="xs:string*"/>
        
        <div class="form-group add-nodes-group">
            
            <div class="col-sm-2">
                <select class="form-control">
                    <xsl:variable name="control-name" select="concat('title-type-', $title-index)"/>
                    <xsl:attribute name="name" select="$control-name"/>
                    <xsl:attribute name="id" select="$control-name"/>
                    <xsl:for-each select="$title-types">
                        <xsl:variable name="option-value" select="@id"/>
                        <xsl:variable name="label" select="text()"/>
                        <option>
                            <xsl:attribute name="value" select="$option-value"/>
                            <xsl:if test="$option-value eq $title/@type">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="$label"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
            
            <!-- Could we use text-input-with-lang or select-language templates here? -->
            <div class="col-sm-2">
                <xsl:call-template name="select-language">
                    <xsl:with-param name="language-options" select="('en','bo','Bo-Ltn','Sa-Ltn', 'Sa-Ltn-rc', 'zh', 'Pi-Ltn')"/>
                    <xsl:with-param name="selected-language">
                        <xsl:choose>
                            <xsl:when test="$title[@xml:lang eq 'Sa-Ltn'][@rend eq 'reconstruction']">
                                <xsl:value-of select="'Sa-Ltn-rc'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$title/@xml:lang"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="input-name" select="concat('title-lang-', $title-index)"/>
                    <xsl:with-param name="input-id" select="concat('title-lang-', $title-index)"/>
                </xsl:call-template>
            </div>
            
            <xsl:if test="count($source-keys) gt 0">
                <div class="col-sm-2">
                    <select class="form-control">
                        <xsl:variable name="control-name" select="concat('title-key-', $title-index)"/>
                        <xsl:attribute name="name" select="$control-name"/>
                        <xsl:attribute name="id" select="$control-name"/>
                        <option>
                            <xsl:attribute name="value" select="''"/>
                            <xsl:value-of select="''"/>
                        </option>
                        <xsl:for-each select="$source-keys">
                            <xsl:variable name="option-value" select="." as="xs:string"/>
                            <option>
                                <xsl:attribute name="value" select="$option-value"/>
                                <xsl:if test="$option-value eq $title/@key">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
            </xsl:if>
            
            <div class="col-sm-8">
                <xsl:if test="count($source-keys) gt 0">
                    <xsl:attribute name="class" select="'col-sm-6'"/>
                </xsl:if>
                <input class="form-control">
                    <xsl:attribute name="name" select="concat('title-text-', $title-index)"/>
                    <xsl:choose>
                        <xsl:when test="$title[@xml:lang eq 'Sa-Ltn']">
                            <xsl:attribute name="value" select="replace($title/text(), '­', '-')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="value" select="$title/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </input>
            </div>
            
        </div>
        
    </xsl:template>
    
    <!-- Output entity types as <span class="label"/> -->
    <xsl:template name="entity-type-labels">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="entity-types" as="element(m:type)*"/>
        
        <xsl:choose>
            <xsl:when test="$entity">
                <xsl:choose>
                    <xsl:when test="$entity[m:type]">
                        <xsl:for-each select="$entity/m:type">
                            <xsl:variable name="type" select="."/>
                            <span class="label label-info">
                                <xsl:choose>
                                    <xsl:when test="$entity-types[@id eq $type/@type]">
                                        <xsl:value-of select="$entity-types[@id eq $type/@type]/m:label[@type eq 'singular']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$type/@type"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$entity-types">
                        <span class="label label-warning">
                            <xsl:value-of select="'No type selected'"/>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <span class="label label-danger">
                    <xsl:value-of select="'No shared entity / excluded from 84000 glossary'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Output warnings on an entity form -->
    <xsl:template name="entity-form-warning">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <!-- Warning -->
        <xsl:choose>
            
            <!-- When there is an entity  -->
            <xsl:when test="$entity">
                
                <div class="alert alert-danger">
                    <p class="small text-center">
                        <xsl:value-of select="'NOTE: Updates to this '"/>
                        <strong>
                            <xsl:value-of select="'shared entity'"/>
                        </strong>
                        <xsl:value-of select="' must apply for all grouped entries listed below!'"/>
                    </p>
                </div>
                
            </xsl:when>
            
            <!-- When there is no entity -->
            <xsl:otherwise>
                
                <div class="alert alert-danger">
                    <p class="small text-center">
                        <xsl:value-of select="'Please check &#34;possible matches&#34; for an existing entity before creating a new one!'"/>
                    </p>
                </div>
                
            </xsl:otherwise>
            
        </xsl:choose>
        
        
    </xsl:template>
    
    <!-- Output form input controls for an entity -->
    <xsl:template name="entity-form-input">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="context-id" as="xs:string"/><!-- To create sub-ids in the DOM -->
        <xsl:param name="default-label-text" as="xs:string?"/>
        <xsl:param name="default-label-lang" as="xs:string?"/>
        <xsl:param name="default-entity-type" as="xs:string"/>
        <xsl:param name="entity-types" as="element(m:type)*"/>
        <xsl:param name="instance" as="element(m:instance)?"/>
                
        <input type="hidden" name="entity-id" value="{ $entity/@xml:id }"/>
        
        <!-- Labels -->
        <div class="add-nodes-container">
            
            <xsl:choose>
                <xsl:when test="$entity">
                    <xsl:for-each select="$entity/m:label">
                        <xsl:call-template name="term-input">
                            <xsl:with-param name="id" select="$entity/@xml:id"/>
                            <xsl:with-param name="index" select="position()"/>
                            <xsl:with-param name="input-name" select="'entity-label'"/>
                            <xsl:with-param name="label" select="'Label (internal use):'"/>
                            <xsl:with-param name="term-text" select="text()"/>
                            <xsl:with-param name="lang" select="@xml:lang"/>
                            <xsl:with-param name="language-options" select="('mixed', 'bo', 'Bo-Ltn', 'Sa-Ltn')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="term-input">
                        <xsl:with-param name="id" select="$context-id"/>
                        <xsl:with-param name="index" select="1"/>
                        <xsl:with-param name="input-name" select="'entity-label'"/>
                        <xsl:with-param name="label" select="'Label (internal use):'"/>
                        <xsl:with-param name="term-text" select="$default-label-text"/>
                        <xsl:with-param name="lang" select="$default-label-lang"/>
                        <xsl:with-param name="language-options" select="('mixed', 'bo', 'Bo-Ltn', 'Sa-Ltn')"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            
            <div class="form-group">
                <div class="col-sm-2">
                    <a href="#add-nodes" class="add-nodes pull-right">
                        <span class="monospace">
                            <xsl:value-of select="'+'"/>
                        </span>
                        <xsl:value-of select="' add a label'"/>
                    </a>
                </div>
                <div class="col-sm-10">
                    <p class="text-muted small">
                        <xsl:value-of select="'Standard hyphens added to Sanskrit strings will be converted to soft-hyphens when saved'"/>
                    </p>
                </div>
            </div>
            
        </div>
        
        <hr class="sml-margin"/>
        
        <!-- Type checkboxes -->
        <xsl:if test="$entity-types">
            <div class="form-group">
                
                <label class="col-sm-2 control-label">
                    <xsl:value-of select="'Type(s):'"/>
                </label>
                
                <div class="col-sm-10">
                    <xsl:for-each select="$entity-types">
                        <xsl:variable name="entity-type" select="."/>
                        <div class="checkbox-inline">
                            <label>
                                <input type="checkbox" name="entity-type[]">
                                    <xsl:attribute name="value" select="$entity-type/@id"/>
                                    <xsl:if test="$entity/m:type[@type = $entity-type/@id] or not($entity) and $entity-type/@id eq $default-entity-type">
                                        <xsl:attribute name="checked" select="'checked'"/>
                                    </xsl:if>
                                </input>
                                <xsl:value-of select="concat(' ', $entity-type/m:label[@type eq 'singular'])"/>
                            </label>
                        </div>
                    </xsl:for-each>
                </div>
                
            </div>
        </xsl:if>
        
        <hr class="sml-margin"/>
        
        <!-- Entity definition -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label">
                <xsl:attribute name="for" select="concat('entity-definition-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-1')"/>
                <xsl:value-of select="'Definition (public):'"/>
            </label>
            
            <div class="col-sm-10 add-nodes-container">
                
                <xsl:variable name="entity-definitions" select="$entity/m:content[@type eq 'glossary-definition']"/>
                
                <xsl:for-each select="(1 to (if(count($entity-definitions) gt 0) then count($entity-definitions) else 1))">
                    <xsl:variable name="definition-index" select="."/>
                    <div class="sml-margin bottom add-nodes-group">
                        <textarea class="form-control">
                            
                            <xsl:attribute name="id" select="concat('entity-definition-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-', $definition-index)"/>
                            <xsl:attribute name="name" select="concat('entity-definition-', $definition-index)"/>
                            
                            <xsl:variable name="definition">
                                <unescaped xmlns="http://read.84000.co/ns/1.0">
                                    <xsl:sequence select="$entity-definitions[$definition-index]/node()"/>
                                </unescaped>
                            </xsl:variable>
                            
                            <xsl:variable name="definition-escaped">
                                <xsl:apply-templates select="$definition"/>
                            </xsl:variable>
                            
                            <xsl:attribute name="rows" select="ops:textarea-rows(string-join($definition-escaped/m:escaped/text()), 2, 105)"/>
                            
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
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-10">
                <xsl:call-template name="definition-tag-reference">
                    <xsl:with-param name="element-id" select="concat($context-id, '-', ($entity/@xml:id, 'new-entity')[1])"/>
                </xsl:call-template>
            </div>
        </div>
        
        <!-- Entity notes -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label">
                <xsl:attribute name="for" select="concat('entity-note-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-1')"/>
                <xsl:value-of select="'Notes (internal):'"/>
            </label>
            
            <div class="col-sm-10 add-nodes-container">
                
                <xsl:variable name="entity-notes" select="$entity/m:content[@type eq 'glossary-notes']"/>
                
                <xsl:for-each select="(1 to (if(count($entity-notes) gt 0) then count($entity-notes) else 1))">
                    <xsl:variable name="note-index" select="."/>
                    <div class="sml-margin bottom add-nodes-group">
                        <textarea class="form-control">
                            
                            <xsl:attribute name="id" select="concat('entity-note-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-', $note-index)"/>
                            <xsl:attribute name="name" select="concat('entity-note-', $note-index)"/>
                            <xsl:attribute name="rows" select="ops:textarea-rows($entity-notes[$note-index]/text(), 2, 105)"/>
                            
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
            
            <div class="col-sm-offset-2 col-sm-8">
                
                <xsl:if test="$instance">
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" name="instance-remove">
                                <xsl:attribute name="value" select="$instance/@id"/>
                            </input>
                            <span class="text-danger">
                                <i class="fa fa-exclamation-circle"/>
                                <xsl:choose>
                                    <xsl:when test="$instance[@type eq 'knowledgebase-article']">
                                        <xsl:value-of select="' Un-link this articled from this shared entity'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="' Un-link this glossary from this shared entity'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </label>
                    </div>
                </xsl:if>
                
            </div>
            
            <div class="col-sm-2">
                <button type="submit" data-loading="Applying changes...">
                    <xsl:choose>
                        <xsl:when test="$entity">
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
        
    </xsl:template>
    
    <!-- List elements linked to an entity -->
    <xsl:template name="entity-option-content">
        
        <xsl:param name="entity" as="element(m:entity)"/>
        <xsl:param name="active-glossary-id" as="xs:string"/>
        <xsl:param name="active-knowledgebase-id" as="xs:string"/>
        
        <h4>
            <xsl:value-of select="$entity/@xml:id"/>
        </h4>
        
        <xsl:for-each select="$entity/m:content[@type eq 'glossary-definition']">
            <xsl:if test="position() eq 1">
                <h5 class="small no-bottom-margin">
                    <xsl:value-of select="'Definition'"/>
                </h5>
            </xsl:if>
            <p class="small text-muted">
                <xsl:apply-templates select="."/>
            </p>
        </xsl:for-each>
        
        <xsl:for-each select="$entity/m:content[@type eq 'glossary-notes']">
            <div class="well well-sm">
                <xsl:if test="position() eq 1">
                    <h5 class="small no-bottom-margin">
                        <xsl:value-of select="'Internal notes'"/>
                    </h5>
                </xsl:if>
                <p class="small text-muted">
                    <xsl:apply-templates select="."/>
                </p>
            </div>
        </xsl:for-each>
        
        <xsl:for-each select="/m:response/m:entities/m:related/m:text[m:entry/@id = $entity/m:instance/@id]">
            
            <xsl:sort select="@id/string()"/>
            
            <xsl:call-template name="related-text-entries">
                <xsl:with-param name="related-text" select="."/>
                <xsl:with-param name="entity" select="$entity"/>
                <xsl:with-param name="active-glossary-id" select="$active-glossary-id"/>
            </xsl:call-template>
            
        </xsl:for-each>
        
        <!-- List related knowledgebase pages -->
        <xsl:call-template name="knowledgebase-page-instance">
            <xsl:with-param name="knowledgebase-page" select="/m:response/m:entities/m:related/m:page[@xml:id = $entity/m:instance/@id]"/>
            <xsl:with-param name="knowledgebase-active-id" select="$active-knowledgebase-id"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Form controls for resolving similar entities -->
    <xsl:template name="entity-resolve-form-input">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="target-entity" as="element(m:entity)"/>
        <xsl:param name="target-entity-label" as="node()*"/>
        <xsl:param name="predicates" as="element(m:predicate)*" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="$entity">
        
                <input type="hidden" name="entity-id" value="{ $entity/@xml:id }"/>
                <input type="hidden" name="target-entity-id" value="{ $target-entity/@xml:id }"/>
                
                <div class="center-vertical align-left">
                    
                    <div>
                        <xsl:value-of select="' ↳ '"/>
                    </div>
                    
                    <div>
                        <button type="submit" class="btn btn-success btn-sm" data-loading="Resolving entities...">
                            <xsl:value-of select="'Resolve'"/>
                        </button>
                    </div>
                    
                    <div>
                        <select name="predicate" class="form-control">
                            <option value="sameAs">
                                <xsl:value-of select="concat(($predicates[@xml:id eq 'sameAs']/m:label, 'sameAs')[1], ':')"/>
                            </option>
                            <option value="isUnrelated">
                                <xsl:value-of select="concat(($predicates[@xml:id eq 'isUnrelated']/m:label, 'isUnrelated')[1], ':')"/>
                            </option>
                            <xsl:for-each select="$predicates[not(@xml:id = ('sameAs', 'isUnrelated'))]">
                                <option>
                                    <xsl:attribute name="value" select="@xml:id"/>
                                    <xsl:value-of select="concat((m:label, @xml:id)[1], ':')"/>
                                </option>
                            </xsl:for-each>
                        </select>
                    </div>
                    
                    <div>
                        <xsl:sequence select="$target-entity-label"/>
                    </div>
                    
                </div>
                
            </xsl:when>
            
            <xsl:otherwise>
                
                <input type="hidden" name="entity-id">
                    <xsl:attribute name="value" select="$target-entity/@xml:id"/>
                </input>
                
                <div class="center-vertical align-left">
                    
                    <div>
                        <xsl:value-of select="' ↳ '"/>
                    </div>
                    
                    <div>
                        <button type="submit" class="btn btn-warning btn-sm" data-loading="Applying match...">
                            <xsl:value-of select="concat(($predicates[@xml:id eq 'sameAs']/m:label, 'sameAs')[1], ':')"/>
                        </button>
                    </div>
                    
                    <div>
                        <xsl:sequence select="$target-entity-label"/>
                    </div>
                    
                </div>
                
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Tag reference for definitions -->
    <xsl:template name="definition-tag-reference">
        
        <xsl:param name="element-id" as="xs:string" required="true"/>
        
        <div class="panel panel-default no-bottom-margin">
            <div class="panel-heading" role="tab">
                <a href="{ concat('#tag-reference-', $element-id) }" aria-controls="{ concat('tag-reference-', $element-id) }" id="{ concat('#tag-reference-heading-', $element-id) }" class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                    <h5 class="text-muted italic">
                        <xsl:value-of select="'Tag reference'"/>
                    </h5>
                    <span class="text-right">
                        <i class="fa fa-plus collapsed-show"/>
                        <i class="fa fa-minus collapsed-hide"/>
                    </span>
                </a>
            </div>
            <div id="{ concat('tag-reference-', $element-id) }" aria-labelledby="{ concat('#tag-reference-heading-', $element-id) }" class="panel-body collapse" role="tabpanel" aria-expanded="false">
                
                <p class="small text-muted">
                    <xsl:value-of select="'These are the valid tags that can be used in definitions. For more details refer to the 84000 TEI guidelines.'"/>
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
                        <term rend="ignore">affliction</term>
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

    </xsl:template>
    
    <!-- Output a text input control with an associated language dropdown -->
    <xsl:template name="term-input">
        
        <xsl:param name="id" as="xs:string" required="true"/>
        <xsl:param name="index" as="xs:integer" required="true"/>
        <xsl:param name="input-name" as="xs:string" required="true"/>
        <xsl:param name="label" as="xs:string" required="true"/>
        <xsl:param name="term-text" as="xs:string?"/>
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:param name="type" as="xs:string?"/>
        <xsl:param name="status" as="xs:string?"/>
        <xsl:param name="language-options" as="xs:string*"/>
        <xsl:param name="type-options" as="element(m:attestation-type)*"/>
        
        <div class="form-group add-nodes-group">
            
            <div class="col-sm-2">
                <xsl:call-template name="select-language">
                    <xsl:with-param name="language-options" select="$language-options"/>
                    <xsl:with-param name="selected-language" select="$lang"/>
                    <xsl:with-param name="input-name" select="concat($input-name, '-lang-', $index)"/>
                    <xsl:with-param name="input-id" select="concat($input-name, '-lang-', $id, '-', $index)"/>
                </xsl:call-template>
            </div>
            
            <div class="col-sm-8">
                
                <div>
                    
                    <xsl:if test="not(empty($status))">
                        <xsl:attribute name="class" select="'input-group'"/>
                    </xsl:if>
                    
                    <input type="text" name="{ concat($input-name, '-text-', $index) }" id="{ concat($input-name, '-', $id, '-', $index) }" class="form-control">
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="matches($lang,'^sa\-ltn', 'i')">
                                    <xsl:attribute name="value" select="replace($term-text, '­', '-'(: This is a soft-hyphen :))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="value" select="$term-text"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </input>
                    
                    <xsl:if test="not(empty($status))">
                        <span class="input-group-addon">
                            <label>
                                <input type="checkbox" name="{ concat($input-name, '-status-', $index) }" value="verified" aria-label="Term verified">
                                    <xsl:if test="$status eq 'verified'">
                                        <xsl:attribute name="checked" select="'checked'"/>
                                    </xsl:if>
                                </input>
                                <xsl:value-of select="' Verified'"/>
                            </label>
                        </span>
                    </xsl:if>
                </div>
                
            </div>
            
            <xsl:if test="$type-options">
                <div class="col-sm-2">
                    <select name="{ concat($input-name, '-type-', $index) }" class="form-control">
                        <xsl:for-each select="$type-options">
                            <option value="{ @id }">
                                <xsl:if test="@id eq $type  or m:migrate[@id eq $type]">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:value-of select="concat(@code, ' / ', m:label) ! normalize-space(.)"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
            </xsl:if>
            
        </div>
    
    </xsl:template>
    
    <!-- language <select/> -->
    <xsl:template name="select-language">
        
        <xsl:param name="language-options" as="xs:string*"/>
        <xsl:param name="selected-language" as="xs:string?"/>
        <xsl:param name="input-name" as="xs:string" required="yes"/>
        <xsl:param name="input-id" as="xs:string" required="yes"/>
        
        <select class="form-control">
            <xsl:attribute name="name" select="$input-name"/>
            <xsl:attribute name="id" select="$input-id"/>
            <xsl:if test="$language-options = ''">
                <option value=""/>
            </xsl:if>
            <xsl:if test="$language-options = ('en','en-alt','mixed')">
                <option value="en">
                    <xsl:if test="$selected-language = ('','en')">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$language-options = 'en-alt'">
                            <xsl:value-of select="'Alt. translation'"/>
                        </xsl:when>
                        <xsl:when test="$language-options = 'mixed'">
                            <xsl:value-of select="'English / Mixed'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Translation'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </option>
            </xsl:if>
            <xsl:if test="$language-options = 'bo'">
                <option value="bo">
                    <xsl:if test="$selected-language  eq 'bo'">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="'Tibetan'"/>
                </option>
            </xsl:if>
            <xsl:if test="$language-options = 'Bo-Ltn'">
                <option value="bo-ltn">
                    <xsl:if test="$selected-language eq 'Bo-Ltn'">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="'Wylie'"/>
                </option>
            </xsl:if>
            <xsl:if test="$language-options = 'Sa-Ltn'">
                <option value="sa-ltn">
                    <xsl:if test="$selected-language eq 'Sa-Ltn'">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="'Sanskrit*'"/>
                </option>
            </xsl:if>
            <xsl:if test="$language-options = 'Sa-Ltn-rc'">
                <option value="sa-ltn-rc">
                    <xsl:if test="$selected-language eq 'Sa-Ltn-rc'">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="'Sanskrit* / Reconstructed'"/>
                </option>
            </xsl:if>
            <xsl:if test="$language-options = 'zh'">
                <option value="zh">
                    <xsl:if test="$selected-language eq 'zh'">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="'Chinese'"/>
                </option>
            </xsl:if>
            <xsl:if test="$language-options = 'Pi-Ltn'">
                <option value="Pi-Ltn">
                    <xsl:if test="$selected-language eq 'Pi-Ltn'">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="'Pali'"/>
                </option>
            </xsl:if>
            <xsl:if test="not($selected-language = ('','en','bo','Bo-Ltn','Sa-Ltn','Sa-Ltn-rc','zh','Pi-Ltn'))">
                <option>
                    <xsl:attribute name="value" select="$selected-language"/>
                    <xsl:attribute name="selected" select="'selected'"/>
                    <xsl:value-of select="$selected-language"/>
                </option>
            </xsl:if>
        </select>
        
    </xsl:template>
    
    <!-- Help text for hyphenation input -->
    <xsl:template name="hyphen-help-text">
        <xsl:value-of select="'* Standard hyphens can be added to Sanskrit strings and will be converted to soft-hyphens when saved'"/>
    </xsl:template>
    
    <!-- Output terms of a gloss/item -->
    <xsl:template name="glossary-terms">
        
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="list-class" as="xs:string?"/>
        <xsl:param name="languages" as="xs:string*"/>
        
        <xsl:variable name="languages" select="if(count($languages) gt 0) then $languages else distinct-values($entry/m:term/@xml:lang)[not(.eq 'en')]" as="xs:string*"/>
        
        <ul class="list-inline inline-dots">
            
            <xsl:if test="$list-class">
                <xsl:attribute name="class" select="concat('list-inline inline-dots ', $list-class)"/>
            </xsl:if>
            
            <li>
                <span class="label label-info">
                    <xsl:choose>
                        <xsl:when test="$entry/@type eq 'term'">
                            <xsl:value-of select="'Term'"/>
                        </xsl:when>
                        <xsl:when test="$entry/@type eq 'person'">
                            <xsl:value-of select="'Person'"/>
                        </xsl:when>
                        <xsl:when test="$entry/@type eq 'place'">
                            <xsl:value-of select="'Place'"/>
                        </xsl:when>
                        <xsl:when test="$entry/@type eq 'text'">
                            <xsl:value-of select="'Text'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$entry/@type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </li>
            
            <!-- Main terms -->
            <xsl:for-each select="$entry/m:term[@xml:lang = $languages]">
                <xsl:sort select="if(@xml:lang eq 'Bo-Ltn') then 1 else if(@xml:lang eq 'bo') then 2 else if(@xml:lang eq 'Sa-Ltn') then 3 else 4"/>
                <li>
                    <span>
                        <xsl:call-template name="ops:class-attribute">
                            <xsl:with-param name="lang" select="@xml:lang"/>
                        </xsl:call-template>
                        <xsl:value-of select="text()"/>
                    </span>
                    <xsl:if test="tokenize(@status, ' ')[. = ('verified')]">
                        <xsl:value-of select="' '"/>
                        <span class="text-warning small">
                            <xsl:value-of select="'[Verified]'"/>
                        </span>
                    </xsl:if>
                </li>
            </xsl:for-each>
            
            <xsl:for-each select="$entry/m:alternative">
                <li class="text-warning">
                    <span>
                        <xsl:call-template name="ops:class-attribute">
                            <xsl:with-param name="lang" select="@xml:lang"/>
                        </xsl:call-template>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
            
            <xsl:if test="$entry[@mode ne 'match']">
                <li>
                    <span class="label label-info">
                        <xsl:if test="$entry/@mode eq 'surfeit'">
                            <xsl:attribute name="class" select="'label label-warning'"/>
                        </xsl:if>
                        <xsl:value-of select="$entry/@mode"/>
                    </span>
                </li>
            </xsl:if>
            
        </ul>
        
    </xsl:template>
    
    <!-- Output definition of a gloss/item -->
    <xsl:template name="glossary-definition">
        
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="line-through" select="false()" as="xs:boolean?"/>
        
        <xsl:if test="$entry/m:definition[descendant::text()[normalize-space()]]">
            <div class="small" title="Glossary definition">
                
                <xsl:if test="$line-through">
                    <xsl:attribute name="class" select="'text-muted small line-through'"/>
                    <xsl:attribute name="title" select="'Entity definition incompatible with glossary definition!'"/>
                </xsl:if>
                
                <xsl:for-each select="$entry/m:definition/tei:p[descendant::text()[normalize-space()]]">
                    
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
    
    <!-- Output definition of a gloss/item -->
    <xsl:template name="entity-definition">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="line-through" select="false()" as="xs:boolean?"/>
        
        <xsl:if test="$entity/m:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]">
            
            <div class="text-warning small" title="Entity definition included">
                
                <xsl:if test="$line-through">
                    <xsl:attribute name="class" select="'text-muted small line-through'"/>
                    <xsl:attribute name="title" select="'Entity definition overrides glossary definition!'"/>
                </xsl:if>
                
                <xsl:for-each select="$entity/m:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]">
                    
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
    
    <xsl:template name="combined-definitions">
        
        <xsl:param name="entry" as="element(m:entry)"/>
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:variable name="entry-definition" select="$entry/m:definition[descendant::text()[normalize-space()]]"/>
        <xsl:variable name="entity-definition" select="$entity/m:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]"/>
        
        <!-- Use entity definition before -->
        <xsl:if test="$entity-definition and $entry-definition[@use-definition = ('both','prepend')]">
            <div class="sml-margin bottom collapse-one-line">
                <xsl:call-template name="entity-definition">
                    <xsl:with-param name="entity" select="$entity"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        
        <!-- Output glossary definition -->
        <xsl:if test="$entry-definition">
            <div class="sml-margin bottom collapse-one-line">
                <xsl:call-template name="glossary-definition">
                    <xsl:with-param name="entry" select="$entry"/>
                    <xsl:with-param name="line-through" select="if($entity-definition and $entry-definition[@use-definition eq 'override']) then true() else false()"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        
        <!-- Use entity definition after -->
        <xsl:if test="$entity-definition and $entry-definition[not(@use-definition = ('both','prepend'))]">
            <div class="sml-margin bottom collapse-one-line">
                <xsl:call-template name="entity-definition">
                    <xsl:with-param name="entity" select="$entity"/>
                    <xsl:with-param name="line-through" select="if($entry-definition and $entry-definition[not(@use-definition = ('append','override'))]) then true() else false()"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Glossary items grouped by text -->
    <xsl:template name="related-text-entries">
        
        <xsl:param name="related-text" as="element(m:text)"/>
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="active-glossary-id" as="xs:string"/>
        <xsl:param name="remove-instance-href" as="xs:string?"/>
        <xsl:param name="set-flags-href" as="xs:string?"/>
        
        <fieldset>
            
            <xsl:if test="$related-text/m:entry[@id eq $active-glossary-id]">
                <xsl:attribute name="class" select="'active'"/>
            </xsl:if>
            
            <!-- Text -->
            <legend>
                <xsl:value-of select="concat('In ', ($related-text/m:bibl/m:toh/m:full)[1], ' / ', ops:limit-str($related-text/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en'][1], 80))"/>
                <xsl:if test="$related-text[@glossary-status eq 'excluded']">
                    <xsl:value-of select="' '"/>
                    <span class="label label-danger">
                        <xsl:value-of select="'excluded'"/>
                    </span>
                </xsl:if>
            </legend>
            
            <div class="div-list no-border-top no-padding-top">
                <xsl:for-each select="$related-text/m:entry[@id = $entity/m:instance/@id]">
                    
                    <xsl:variable name="entry" select="."/>
                    
                    <xsl:variable name="entity-instance" select="$entity/m:instance[@id eq $entry/@id]"/>
                    
                    <div class="item">
                        
                        <!-- Header -->
                        <div class="item-row">
                            
                            <!-- Main term -->
                            <span class="text-danger">
                                <xsl:value-of select="$entry/m:term[@xml:lang eq 'en'][1]"/>
                            </span>
                            
                            <!-- Link to Reading Room -->
                            <span>
                                <xsl:value-of select="' / '"/>
                                <a target="reading-room" class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $related-text/@id, '.html#', $entry/@id)"/>
                                    <xsl:value-of select="$entry/@id"/>
                                </a>
                            </span>
                            
                            <!-- A link to switch to this item -->
                            <xsl:choose>
                                <xsl:when test="not($entry/@id eq $active-glossary-id)">
                                    
                                    <span>
                                        <xsl:value-of select="' / '"/>
                                        <a class="small">
                                            <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $related-text/@id, '&amp;resource-type=', $related-text/@type, '&amp;glossary-id=', $entry/@id, '&amp;max-records=1')"/>
                                            <xsl:attribute name="target" select="concat('glossary-', $related-text/@id)"/>
                                            <xsl:value-of select="'edit entry'"/>
                                        </a>
                                    </span>
                                    
                                    <!-- Links to remove as instance -->
                                    <xsl:if test="$remove-instance-href">
                                        <xsl:value-of select="' / '"/>
                                        <span class="small">
                                            <a target="_self" data-loading="Loading...">
                                                <xsl:attribute name="href" select="replace($remove-instance-href, '\{instance\-id\}', $entry/@id)"/>
                                                <xsl:value-of select="'Un-link (+ create new)'"/>
                                            </a>
                                        </span>
                                    </xsl:if>
                                    
                                </xsl:when>
                                <xsl:otherwise>
                                    
                                    <span>
                                        <xsl:value-of select="' / '"/>
                                        <small class="text-muted">
                                            <xsl:value-of select="'editing'"/>
                                        </small>
                                    </span>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </div>
                        
                        <!-- Terms -->
                        <div class="item-row">
                            <xsl:call-template name="glossary-terms">
                                <xsl:with-param name="entry" select="$entry"/>
                                <xsl:with-param name="list-class" select="'no-bottom-margin'"/>
                                <xsl:with-param name="languages" select="('Bo-Ltn','Sa-Ltn')"/>
                            </xsl:call-template>
                        </div>
                        
                        <!-- Definition -->
                        <div class="item-row">
                            
                            <xsl:call-template name="combined-definitions">
                                <xsl:with-param name="entry" select="$entry"/>
                                <xsl:with-param name="entity" select="$entity"/>
                            </xsl:call-template>
                            
                        </div>
                        
                        <div class="item-row">
                            
                            <!-- Links to set flags -->
                            <xsl:if test="$set-flags-href and $entity-instance">
                                <xsl:call-template name="flag-options">
                                    <xsl:with-param name="glossary-id" select="$entry/@id"/>
                                    <xsl:with-param name="glossary-instance" select="$entity-instance"/>
                                    <xsl:with-param name="flag-options-href" select="replace($set-flags-href, '\{instance\-id\}', $entry/@id)"/>
                                </xsl:call-template>
                            </xsl:if>
                            
                        </div>
                        
                    </div>
                </xsl:for-each>
            </div>
            
        </fieldset>
        
    </xsl:template>
    
    <!-- Set flags -->
    <xsl:template name="flag-options">
        
        <xsl:param name="glossary-id" as="xs:string" required="true"/>
        <xsl:param name="glossary-instance" as="element(m:instance)"/>
        <xsl:param name="flag-options-href" as="xs:string" required="true"/>
        
        <xsl:for-each select="/m:response/m:entity-flags/m:flag[not(@type eq 'computed')]">
            <xsl:choose>
                <xsl:when test="@id = $glossary-instance/m:flag/@type">
                    <span>
                        <xsl:attribute name="class" select="'label label-danger'"/>
                        <xsl:value-of select="m:label"/>
                        <xsl:value-of select="' / '"/>
                        <a target="_self" data-loading="Removing flag...">
                            <xsl:attribute name="href" select="replace(replace($flag-options-href, '\{flag\-action\}', 'remove-flag'), '\{flag\-id\}', @id)"/>
                            <xsl:value-of select="'un-flag'"/>
                        </a>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <a target="_self" data-loading="Setting flag..." class="small">
                        <xsl:attribute name="href" select="replace(replace($flag-options-href, '\{flag\-action\}', 'set-flag'), '\{flag\-id\}', @id)"/>
                        <xsl:value-of select="'Flag this entry: '"/>
                        <xsl:value-of select="m:label"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Output Knowledge base article reference -->
    <xsl:template name="knowledgebase-page-instance">
        
        <xsl:param name="knowledgebase-page" as="element(m:page)*"/>
        <xsl:param name="knowledgebase-active-id" as="xs:string"/>
        
        <xsl:if test="$knowledgebase-page">
            <fieldset>
                
                <xsl:if test="$knowledgebase-page[@xml:id eq $knowledgebase-active-id]">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                
                <!-- Knowledge Base Artice -->
                <legend>
                    <xsl:value-of select="'In the 84000 Knowledge Base'"/>
                </legend>
                
                <xsl:for-each select="$knowledgebase-page">
                    
                    <div class="item">
                        <div class="item-row">
                            
                            <!-- Main term -->
                            <span class="text-danger">
                                <xsl:value-of select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                            </span>
                            
                            <!-- Link to Reading Room -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <a target="reading-room" class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @xml:id, '.html')"/>
                                    <xsl:value-of select="@xml:id"/>
                                </a>
                            </span>
                            
                            <!-- A link to switch to this item -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <xsl:choose>
                                    <xsl:when test="not(@xml:id eq $knowledgebase-active-id)">
                                        <a class="small">
                                            <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', @xml:id)"/>
                                            <xsl:attribute name="target" select="@kb-id"/>
                                            <xsl:value-of select="'edit'"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <small class="text-muted">
                                            <xsl:value-of select="'editing'"/>
                                        </small>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </span>
                            
                        </div>
                    </div>
                    
                </xsl:for-each>
                
            </fieldset>    
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>