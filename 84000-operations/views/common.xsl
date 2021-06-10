<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()" as="xs:string"/>
    <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
    
    <!-- Page header -->
    <xsl:template name="operations-page">
        
        <xsl:param name="active-tab"/>
        <xsl:param name="page-content" required="yes"/>
        
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
                    <xsl:copy-of select="$page-content"/>
                </div>
            </div>
        </main>
        
        <!-- Link to top of page -->
        <div class="hidden-print">
            <div id="link-to-top-container" class="fixed-btn-container">
                <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                    <i class="fa fa-arrow-up" aria-hidden="true"/>
                </a>
            </div>
        </div>
        
        <!-- Source pop-up -->
        <div id="popup-footer-source" class="fixed-footer collapse hidden-print">
            <div class="fix-height">
                <div class="data-container">
                    <!-- Ajax data here -->
                    <div class="ajax-target"/>
                </div>
            </div>
            <div class="fixed-btn-container close-btn-container">
                <button type="button" class="btn-round close close-collapse" aria-label="Close">
                    <span aria-hidden="true">
                        <i class="fa fa-times"/>
                    </span>
                </button>
            </div>
        </div>
        
    </xsl:template>
    
    <!-- Generic alert -->
    <xsl:template name="alert-updated">
        <xsl:if test="m:updates/m:updated[@update]">
            <div class="alert alert-success alert-temporary" role="alert">
                <xsl:value-of select="'Updated'"/>
            </div>
            <!--<xsl:if test="/m:response/@model-type eq 'operations/edit-text-header'">-->
                <xsl:choose>
                    <xsl:when test="m:updates/m:updated[@update][@node eq 'text-version']">
                        <div class="alert alert-warning" role="alert">
                            <xsl:value-of select="'The version number has been updated'"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="alert alert-danger" role="alert">
                            <xsl:value-of select="'To ensure these updates are deployed to the distribution server please update the version in the status section!!'"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            <!--</xsl:if>-->
        </xsl:if>
    </xsl:template>
    
    <!-- Alert if translation is locked -->
    <xsl:template name="alert-translation-locked">
        <xsl:variable name="element" select="(m:translation, m:knowledgebase)[1]"/>
        <xsl:if test="$element[@locked-by-user gt '']">
            <div class="alert alert-danger" role="alert">
                <xsl:value-of select="concat('File ', $element/@document-url, ' is currenly locked by user ', $element/@locked-by-user, '. ')"/>
                <xsl:value-of select="'You cannot modify this file until the lock is released.'"/>
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
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/knowledgebase'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="knowledgebase.html">
                    <xsl:value-of select="'Knowledge Base'"/>
                </a>
            </li>
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
                                <xsl:attribute name="href" select="concat('/glossary.html?resource-id=', /m:response/m:request/@resource-id)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href" select="'/glossary.html'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="'Glossary'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Text Header'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-kb-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-kb-header.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Knowledge Base Article'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-sponsors'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Text Sponsors'"/>
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
                        <xsl:value-of select="'Edit Contributor'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-team'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Translator Team'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-institution'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Translator Institution'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-submission'">
                <li role="presentation">
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@text-id, '#submissions-form')"/>
                        <xsl:value-of select="'Edit Text Header'"/>
                    </a>
                </li>
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-submission.html?text-id=', /m:response/m:request/@text-id, '&amp;submission-id=', /m:response/m:request/@submission-id)"/>
                        <xsl:value-of select="'Edit Submission'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/tei-editor'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/tei-editor.html?type=', /m:response/m:request/@type,'&amp;resource-id=', /m:response/m:request/@resource-id, '&amp;section-id=', /m:response/m:request/@section-id, '&amp;sibling-id=', /m:response/m:request/@sibling-id)"/>
                        <xsl:value-of select="'TEI Editor'"/>
                    </a>
                </li>
            </xsl:if>
        </ul>
        
    </xsl:template>
    
    <!-- Accordion panel -->
    <xsl:template name="panel">
        <xsl:param name="type" required="yes"/>
        <xsl:param name="title" required="yes"/>
        <xsl:param name="form" required="yes"/>
        <xsl:param name="flag"/>
        <xsl:param name="active"/>
        <div class="panel panel-default no-shadow">
            <div class="panel-heading" role="tab">
                <xsl:attribute name="id" select="concat('panelHeading-', $type)"/>
                <a role="button" data-toggle="collapse" aria-expanded="false" data-parent="#forms-accordion" class="collapsed">
                    <xsl:attribute name="href" select="concat('#panel-', $type)"/>
                    <xsl:attribute name="aria-controls" select="concat('panel-', $type)"/>
                    <xsl:if test="$active">
                        <xsl:attribute name="class" select="''"/>
                        <xsl:attribute name="aria-expanded" select="'true'"/>
                    </xsl:if>
                    <div class="center-vertical full-width">
                        <span>
                            <span class="h3 panel-title">
                                <xsl:value-of select="concat($title, ' ')"/>
                                <xsl:copy-of select="$flag"/>
                            </span>
                        </span>
                        <span class="text-right">
                            <i class="fa fa-plus collapsed-show"/>
                            <i class="fa fa-minus collapsed-hide"/>
                        </span>
                    </div>
                </a>
            </div>
            <div class="panel-collapse collapse" role="tabpanel">
                <xsl:attribute name="id" select="concat('panel-', $type)"/>
                <xsl:attribute name="aria-labelledby" select="concat('panelHeading-', $type)"/>
                <xsl:if test="$active">
                    <xsl:attribute name="class" select="'panel-collapse collapse in'"/>
                </xsl:if>
                <div class="panel-body">
                    <xsl:copy-of select="$form"/>
                </div>
            </div>
        </div>
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
                                <xsl:when test="@translation-status-group eq 'published'">
                                    <xsl:attribute name="class" select="'pull-quote green-quote'"/>
                                </xsl:when>
                                <xsl:when test="@translation-status-group = ('translated', 'in-translation')">
                                    <xsl:attribute name="class" select="'pull-quote orange-quote'"/>
                                </xsl:when>
                                <xsl:when test="@translation-status-group eq 'in-application'">
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
                                    <xsl:copy-of select="ops:translation-status(@translation-status-group)"/>
                                </span>
                            </div>
                            
                            <div class="small">
                                
                                <!-- Contributions -->
                                <xsl:if test="m:contribution">
                                    <ul class="list-inline inline-dots">
                                        <xsl:for-each select="m:contribution">
                                            <xsl:variable name="contribution" select="."/>
                                            <li class="text-warning">
                                                <xsl:value-of select="/m:response/m:contributor-types/m:contributor-type[@node-name eq $contribution/@node-name][@role eq $contribution/@role]/m:label"/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>    
                                </xsl:if>
                                
                                <!-- Acknowledgment statement -->
                                <xsl:choose>
                                    <xsl:when test="tei:div[@type eq 'acknowledgment']/*">
                                        <xsl:apply-templates select="tei:div[@type eq 'acknowledgment']/*"/>
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
    <xsl:template name="titles-controls">
        <xsl:param name="text-titles" required="yes"/>
        <xsl:param name="title-types" required="yes"/>
        <xsl:param name="title-langs" required="yes"/>
        <xsl:for-each select="$text-titles">
            <xsl:variable name="title-type" select="@type"/>
            <xsl:variable name="title-lang" select="@xml:lang"/>
            <xsl:variable name="title-text" select="text()"/>
            <div class="form-group add-nodes-group">
                <div class="col-sm-2">
                    <select class="form-control">
                        <xsl:variable name="control-name" select="concat('title-type-', position())"/>
                        <xsl:attribute name="name" select="$control-name"/>
                        <xsl:attribute name="id" select="$control-name"/>
                        <xsl:for-each select="$title-types">
                            <xsl:variable name="option-value" select="@id"/>
                            <xsl:variable name="label" select="text()"/>
                            <option>
                                <xsl:attribute name="value" select="$option-value"/>
                                <xsl:if test="$option-value eq $title-type">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:value-of select="$label"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="col-sm-2">
                    <select class="form-control">
                        <xsl:variable name="control-name" select="concat('title-lang-', position())"/>
                        <xsl:attribute name="name" select="$control-name"/>
                        <xsl:attribute name="id" select="$control-name"/>
                        <xsl:for-each select="$title-langs">
                            <xsl:variable name="option-value" select="@id"/>
                            <xsl:variable name="label" select="text()"/>
                            <option>
                                <xsl:attribute name="value" select="$option-value"/>
                                <xsl:if test="$option-value eq $title-lang">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="$option-value eq 'Sa-Ltn'">
                                        <xsl:value-of select="concat($label, ' *')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$label"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="col-sm-8">
                    <input class="form-control">
                        <xsl:attribute name="name" select="concat('title-text-', position())"/>
                        <xsl:choose>
                            <xsl:when test="$title-lang eq 'Sa-Ltn'">
                                <xsl:attribute name="value" select="replace($title-text, '­', '-')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value" select="$title-text"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </input>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <!-- <input type="text"/> -->
    <xsl:function name="ops:text-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div>
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:attribute name="value" select="$value"/>
                    <xsl:attribute name="class" select="concat('form-control', ' ', $css-class)"/>
                    <xsl:if test="contains($css-class, 'disabled')">
                        <xsl:attribute name="disabled" select="'disabled'"/>
                    </xsl:if>
                    <xsl:if test="contains($css-class, 'required')">
                        <xsl:attribute name="required" select="'required'"/>
                    </xsl:if>
                </input>
            </div>
        </div>
    </xsl:function>
    
    <!-- Sequence of <input type="text"/> elements -->
    <xsl:function name="ops:text-multiple-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="values"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <xsl:for-each select="$values">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:sequence select="ops:text-input($label, concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ops:text-input('+', concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:sequence select="ops:text-input('+', concat($name, '-', (count($values) + 1)), '', $size, $css-class)"/>
    </xsl:function>
    
    <!-- <select/> -->
    <xsl:function name="ops:select-input">
        <!-- $options sequence requires @value and @selected attributes -->
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="rows"/>
        <xsl:param name="options"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div class="col-sm-10">
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <select class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:if test="$rows gt 1">
                        <xsl:attribute name="multiple" select="'multiple'"/>
                        <xsl:attribute name="size" select="$rows"/>
                    </xsl:if>
                    <xsl:for-each select="$options">
                        <option>
                            <xsl:attribute name="value" select="@value"/>
                            <xsl:if test="@selected eq 'selected'">
                                <xsl:attribute name="selected" select="@selected"/>
                            </xsl:if>
                            <xsl:value-of select="text()"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:function>
    
    <!-- <select/> variation -->
    <xsl:function name="ops:select-input-name">
        <!-- $options sequence requires m:name, m:label or text() and @xml:id or @id elements -->
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="options"/>
        <xsl:param name="selected-id"/>
        <div class="form-group">
            <xsl:if test="$label">
                <label>
                    <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                    <xsl:attribute name="for" select="$name"/>
                    <xsl:value-of select="$label"/>
                </label>
            </xsl:if>
            <div>
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <select class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <option value="">
                        <xsl:value-of select="'[none]'"/>
                    </option>
                    <xsl:for-each select="$options">
                        <xsl:variable name="option-id" select="(@xml:id, @id)[1]"/>
                        <xsl:variable name="text" select="if (m:name | m:label) then (m:name | m:label)[1] else text()"/>
                        <option>
                            <xsl:attribute name="value" select="$option-id"/>
                            <xsl:if test="$option-id eq $selected-id">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="$text"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:function>
    
    <!-- Translation status -->
    <xsl:function name="ops:translation-status">
        <xsl:param name="status-group"/>
        <xsl:choose>
            <xsl:when test="$status-group eq 'published'">
                <span class="label label-success published">
                    <xsl:value-of select="'Published'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'translated'">
                <span class="label label-warning in-progress">
                    <xsl:value-of select="'In progress'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'in-translation'">
                <span class="label label-warning in-progress">
                    <xsl:value-of select="'In progress'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'in-application'">
                <span class="label label-danger in-progress">
                    <xsl:value-of select="'Application pending'"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="label label-default">
                    <xsl:value-of select="'Not Started'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Sponsorship status -->
    <xsl:function name="ops:sponsorship-status">
        <xsl:param name="sponsorship-statuses"/>
        <xsl:for-each select="$sponsorship-statuses">
            <xsl:if test="not(@id eq 'no-sponsorship')">
                <span>
                    <xsl:choose>
                        <xsl:when test="@id = 'available'">
                            <xsl:attribute name="class" select="'nowrap label label-success'"/>
                        </xsl:when>
                        <xsl:when test="@id = 'full'">
                            <xsl:attribute name="class" select="'nowrap label label-info'"/>
                        </xsl:when>
                        <xsl:when test="@id = ('part', 'reserved', 'priority')">
                            <xsl:attribute name="class" select="'nowrap label label-warning'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class" select="'nowrap label label-default'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="m:label"/>
                </span>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Standardise wayward lang ids -->
    <xsl:function name="ops:lang-class" as="xs:string">
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="lower-case($lang) eq 'bo'">
                <xsl:value-of select="'text-bo'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'sa-ltn'">
                <xsl:value-of select="'text-sa'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                <xsl:value-of select="'text-wy'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = ('eng', 'en')">
                <xsl:value-of select="'text-en'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'zh'">
                <xsl:value-of select="'text-zh'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'ja'">
                <xsl:value-of select="'text-ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ops:limit-str" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="max-length" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string-length($string) gt $max-length ">
                <xsl:value-of select="concat(substring($string ,1, $max-length), '...')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ops:textarea-rows" as="xs:integer">
        
        <xsl:param name="content" as="node()*"/>
        <xsl:param name="default-rows" as="xs:integer"/>
        <xsl:param name="chars-per-row" as="xs:integer"/>
        
        <xsl:variable name="lines" select="sum(tokenize($content, '\n') ! ceiling((string-length(.) + 1) div $chars-per-row))"/>
        
        <xsl:value-of select="if($lines gt $default-rows) then $lines else $default-rows"/>
        
    </xsl:function>
    
    <xsl:template name="entity-type-labels">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="entity-types" as="element(m:entity-type)*"/>
        
        <xsl:choose>
            <xsl:when test="$entity">
                <xsl:choose>
                    <xsl:when test="$entity[m:type]">
                        <xsl:for-each select="$entity/m:type">
                            <xsl:variable name="type" select="."/>
                            <span class="label label-info">
                                <xsl:choose>
                                    <xsl:when test="$entity-types[@id eq $type/@type]">
                                        <xsl:value-of select="$entity-types[@id eq $type/@type]/text()"/>
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
                    <xsl:value-of select="'No shared entity defined'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="entity-form-warning">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <!-- Warning -->
        <div class="row">
            <div class="col-sm-offset-2 col-sm-8">
                <xsl:choose>
                    
                    <!-- When there is an entity  -->
                    <xsl:when test="$entity">
                        
                        <div class="alert alert-info">
                            <p class="small text-center">
                                <xsl:value-of select="'NOTE: Updates to this shared entity must apply for all glossaries matched to this entity!'"/>
                            </p>
                        </div>
                        
                    </xsl:when>
                    
                    <!-- When there is no entity -->
                    <xsl:otherwise>
                        
                        <div class="alert alert-danger">
                            <p class="small text-center">
                                <xsl:value-of select="'Please search thoroughly for an existing entity before creating a new one!'"/>
                            </p>
                        </div>
                        
                    </xsl:otherwise>
                    
                </xsl:choose>
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="entity-form-input">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="context-id" as="xs:string"/>
        <xsl:param name="default-label-text" as="xs:string"/>
        <xsl:param name="default-label-lang" as="xs:string"/>
        <xsl:param name="default-entity-type" as="xs:string"/>
        <xsl:param name="entity-types" as="element(m:entity-type)*"/>
        
        <input type="hidden" name="entity-id" value="{ $entity/@xml:id }"/>
        
        <!-- Labels -->
        <div class="add-nodes-container">
            
            <xsl:choose>
                <xsl:when test="$entity">
                    <xsl:for-each select="$entity/m:label">
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
                        <xsl:with-param name="text" select="$default-label-text"/>
                        <xsl:with-param name="lang" select="$default-label-lang"/>
                        <xsl:with-param name="id" select="$context-id"/>
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
        <xsl:if test="$entity-types">
            <div class="form-group">
                
                <label class="col-sm-2 control-label">
                    <xsl:value-of select="'Type(s):'"/>
                </label>
                
                <xsl:for-each select="$entity-types">
                    <xsl:variable name="entity-type" select="."/>
                    <div class="col-sm-2">
                        <div class="checkbox">
                            <label>
                                <input type="checkbox" name="entity-type[]">
                                    <xsl:attribute name="value" select="$entity-type/@id"/>
                                    <xsl:if test="$entity/m:type[@type = $entity-type/@id] or not($entity) and $entity-type/@id eq $default-entity-type">
                                        <xsl:attribute name="checked" select="'checked'"/>
                                    </xsl:if>
                                </input>
                                <xsl:value-of select="concat(' ', $entity-type/text())"/>
                            </label>
                        </div>
                    </div>
                </xsl:for-each>
                
            </div>
        </xsl:if>
        
        <!-- Entity definition -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label">
                <xsl:attribute name="for" select="concat('entity-definition-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-1')"/>
                <xsl:value-of select="'Definition (public):'"/>
            </label>
            
            <div class="col-sm-8 add-nodes-container">
                
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
                            
                            <xsl:attribute name="rows" select="ops:textarea-rows($definition-escaped, 2, 105)"/>
                            
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
            <div class="col-sm-12">
                <xsl:call-template name="definition-tag-reference">
                    <xsl:with-param name="element-id" select="concat($context-id, '-entity')"/>
                </xsl:call-template>
            </div>
        </div>
        
        <!-- Entity notes -->
        <div class="form-group">
            
            <label class="col-sm-2 control-label">
                <xsl:attribute name="for" select="concat('entity-note-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-1')"/>
                <xsl:value-of select="'Notes (internal):'"/>
            </label>
            
            <div class="col-sm-8 add-nodes-container">
                
                <xsl:variable name="entity-notes" select="$entity/m:content[@type eq 'glossary-notes']"/>
                
                <xsl:for-each select="(1 to (if(count($entity-notes) gt 0) then count($entity-notes) else 1))">
                    <xsl:variable name="note-index" select="."/>
                    <div class="sml-margin bottom add-nodes-group">
                        <textarea class="form-control">
                            
                            <xsl:attribute name="id" select="concat('entity-note-', $context-id, '-', ($entity/@xml:id, 'new-entity')[1], '-', $note-index)"/>
                            <xsl:attribute name="name" select="concat('entity-note-', $note-index)"/>
                            <xsl:attribute name="rows" select="ops:textarea-rows($entity-notes[$note-index], 2, 105)"/>
                            
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
                <xsl:if test="$entity">
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" name="instance-remove">
                                <xsl:attribute name="value" select="$context-id"/>
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
    
    <xsl:template name="entity-option-content">
        
        <xsl:param name="entity" as="element(m:entity)"/>
        <xsl:param name="active-glossary-id" as="xs:string"/>
        <xsl:param name="active-kb-id" as="xs:string"/>
        
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
            <xsl:if test="position() eq 1">
                <h5 class="small no-bottom-margin">
                    <xsl:value-of select="'Internal notes'"/>
                </h5>
            </xsl:if>
            <p class="small text-muted">
                <xsl:apply-templates select="."/>
            </p>
        </xsl:for-each>
        
        <!-- List related glossary items -->
        <xsl:for-each-group select="$entity/m:instance[@type eq 'glossary-item']/m:item" group-by="m:text/@id">
            
            <xsl:sort select="m:text[1]/@id"/>
            
            <xsl:call-template name="glossary-items-text-group">
                <xsl:with-param name="glossary-items" select="current-group()"/>
                <xsl:with-param name="active-glossary-id" select="$active-glossary-id"/>
            </xsl:call-template>
            
        </xsl:for-each-group>
        
        <!-- List related knowledgebase pages -->
        <xsl:call-template name="knowledgebase-page-instance">
            <xsl:with-param name="knowledgebase-page" select="$entity/m:instance[@type eq 'knowledgebase-article']/m:page"/>
            <xsl:with-param name="active-kb-id" select="$active-kb-id"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="entity-resolve-form-input">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="target-entity" as="element(m:entity)"/>
        <xsl:param name="target-entity-label" as="node()*"/>
        <xsl:param name="predicates" as="element(m:predicate)*" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="$entity">
        
                <input type="hidden" name="entity-id">
                    <xsl:attribute name="value" select="$entity/@xml:id"/>
                </input>
                <input type="hidden" name="target-entity-id">
                    <xsl:attribute name="value" select="$target-entity/@xml:id"/>
                </input>
                
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
    
    <xsl:template name="definition-tag-reference">
        
        <xsl:param name="element-id" as="xs:string" required="true"/>
        
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-8">
                <div class="panel panel-default no-bottom-margin">
                    <div class="panel-heading" role="tab">
                        <a href="{ concat('#tag-reference-', $element-id) }" aria-controls="{ concat('tag-reference-', $element-id) }" id="{ concat('#tag-reference-heading-', $element-id) }" class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                            <h5 class="text-muted small">
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
            <xsl:if test="not($selected-language = ('', 'en', 'bo', 'Bo-Ltn', 'Sa-Ltn', 'zh'))">
                <option>
                    <xsl:attribute name="value" select="$selected-language"/>
                    <xsl:attribute name="selected" select="'selected'"/>
                    <xsl:value-of select="$selected-language"/>
                </option>
            </xsl:if>
        </select>
        
    </xsl:template>
    
    <xsl:template name="glossary-terms">
        
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
                            <xsl:value-of select="ops:lang-class(@xml:lang)"/>
                        </xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
            
            <xsl:for-each select="$item/m:alternative">
                <li class="text-warning">
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="ops:lang-class(@xml:lang)"/>
                        </xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </span>
                </li>
            </xsl:for-each>
            
            <li>
                <span class="label label-info">
                    <xsl:choose>
                        <xsl:when test="$item/@type eq 'term'">
                            <xsl:value-of select="'Term'"/>
                        </xsl:when>
                        <xsl:when test="$item/@type eq 'person'">
                            <xsl:value-of select="'Person'"/>
                        </xsl:when>
                        <xsl:when test="$item/@type eq 'place'">
                            <xsl:value-of select="'Place'"/>
                        </xsl:when>
                        <xsl:when test="$item/@type eq 'text'">
                            <xsl:value-of select="'Text'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$item/@type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </li>
            
        </ul>
        
    </xsl:template>
    
    <xsl:template name="glossary-definition">
        
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
    
    <xsl:template name="glossary-items-text-group">
        
        <xsl:param name="glossary-items" as="element(m:item)*"/>
        <xsl:param name="active-glossary-id" as="xs:string"/>
        
        <fieldset>
            
            <!-- Text -->
            <legend>
                <xsl:value-of select="concat('In ', $glossary-items[1]/m:text/m:toh, ' / ', ops:limit-str($glossary-items[1]/m:text/m:title, 80))"/>
            </legend>
            
            <div class="div-list no-border-top no-padding-top">
                <xsl:for-each select="$glossary-items">
                    <xsl:variable name="item" select="."/>
                    <div class="item">
                        
                        <!-- Header -->
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
                                        <a class="small">
                                            <xsl:attribute name="href" select="concat('/glossary.html?resource-id=', $item/m:text/@id, '&amp;glossary-id=', $item/@id, '&amp;max-records=1')"/>
                                            <xsl:attribute name="target" select="concat('glossary-', $item/m:text/@id)"/>
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
                        
                        <!-- Terms -->
                        <div class="item-row">
                            <xsl:call-template name="glossary-terms">
                                <xsl:with-param name="item" select="."/>
                                <xsl:with-param name="list-class" select="'no-bottom-margin'"/>
                            </xsl:call-template>
                        </div>
                        
                        <!-- Definition -->
                        <div class="item-row">
                            <xsl:call-template name="glossary-definition">
                                <xsl:with-param name="item" select="."/>
                            </xsl:call-template>
                        </div>
                        
                    </div>
                </xsl:for-each>
            </div>
            
        </fieldset>
        
    </xsl:template>
    
    <xsl:template name="knowledgebase-page-instance">
        
        <xsl:param name="knowledgebase-page" as="element(m:page)*"/>
        <xsl:param name="active-kb-id" as="xs:string"/>
        
        <xsl:if test="$knowledgebase-page">
            <fieldset>
                
                <!-- Knowledge Base Artice -->
                <legend>
                    <xsl:value-of select="'In the 84000 Knowledge Base'"/>
                </legend>
                
                <xsl:for-each select="$knowledgebase-page">
                    
                    <div class="item">
                        <div class="item-row">
                            
                            <!-- Main term -->
                            <span class="text-danger">
                                <xsl:value-of select="m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en'][1]"/>
                            </span>
                            
                            <!-- Link to Reading Room -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <a target="reading-room" class="small">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', $knowledgebase-page/@xml:id, '.html')"/>
                                    <xsl:value-of select="@xml:id"/>
                                </a>
                            </span>
                            
                            <!-- A link to switch to this item -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <xsl:choose>
                                    <xsl:when test="not(@xml:id eq $active-kb-id)">
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