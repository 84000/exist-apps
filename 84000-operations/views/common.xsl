<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
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
                        <xsl:value-of select="'Knowledge Base Page'"/>
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
    
</xsl:stylesheet>