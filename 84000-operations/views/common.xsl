<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
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
        <xsl:variable name="element" select="(//m:*[@locked-by-user][@document-url])[1]"/>
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
                    <xsl:attribute name="data-loading" select="'Loading Summary...'"/>
                    <xsl:value-of select="'Summary'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/search'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="search.html">
                    <xsl:attribute name="data-loading" select="'Loading Texts...'"/>
                    <xsl:value-of select="'Texts'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sections'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sections.html">
                    <xsl:attribute name="data-loading" select="'Loading Sections...'"/>
                    <xsl:value-of select="'Sections'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/knowledgebase'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="knowledgebase.html">
                    <xsl:attribute name="data-loading" select="'Loading Knowledge Base...'"/>
                    <xsl:value-of select="'Knowledge Base'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sponsors'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sponsors.html">
                    <xsl:attribute name="data-loading" select="'Loading Sponsors...'"/>
                    <xsl:value-of select="'Sponsors'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translators'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translators.html">
                    <xsl:attribute name="data-loading" select="'Loading Contributors...'"/>
                    <xsl:value-of select="'Contributors'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-teams'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-teams.html">
                    <xsl:attribute name="data-loading" select="'Loading Teams...'"/>
                    <xsl:value-of select="'Teams'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-institutions'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-institutions.html">
                    <xsl:attribute name="data-loading" select="'Loading Institutions...'"/>
                    <xsl:value-of select="'Institutions'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sys-config'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sys-config.html">
                    <xsl:attribute name="data-loading" select="'Loading Config...'"/>
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
                        <xsl:attribute name="data-loading" select="'Loading Glossary...'"/>
                        <xsl:value-of select="'Glossary'"/>
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
            
            <xsl:call-template name="title-controls">
                <xsl:with-param name="title" select="."/>
                <xsl:with-param name="title-index" select="position()"/>
                <xsl:with-param name="title-langs" select="$title-langs"/>
                <xsl:with-param name="title-types" select="$title-types"/>
            </xsl:call-template>
        
        </xsl:for-each>
        
    </xsl:template>
    <xsl:template name="title-controls">
        
        <xsl:param name="title" as="element(m:title)?"/>
        <xsl:param name="title-index" as="xs:integer"/>
        <xsl:param name="title-types" required="yes"/>
        <xsl:param name="title-langs" required="yes"/>
        
        <xsl:variable name="title-type" select="$title/@type"/>
        <xsl:variable name="title-lang" select="$title/@xml:lang"/>
        <xsl:variable name="title-text" select="$title/text()"/>
        
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
                    <xsl:variable name="control-name" select="concat('title-lang-', $title-index)"/>
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
                    <xsl:attribute name="name" select="concat('title-text-', $title-index)"/>
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
    
    <!-- Limit string length ... -->
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
    
    <!-- Set number of rows for a <textarea/> -->
    <xsl:function name="ops:textarea-rows" as="xs:integer">
        
        <xsl:param name="content" as="node()*"/>
        <xsl:param name="default-rows" as="xs:integer"/>
        <xsl:param name="chars-per-row" as="xs:integer"/>
        
        <xsl:variable name="lines" select="sum(tokenize($content, '\n') ! ceiling((string-length(.) + 1) div $chars-per-row))"/>
        
        <xsl:value-of select="if($lines gt $default-rows) then $lines else $default-rows"/>
        
    </xsl:function>
    
    <!-- Translate number to letter -->
    <xsl:function name="ops:position-to-letter" as="xs:string">
        
        <xsl:param name="position" as="xs:integer"/>
        
        <xsl:variable name="alphabet" select="'abcdefghijklmnopqursuvwxyz'"/>
        <xsl:variable name="position-mod" select="$position mod string-length($alphabet)"/>
        
        <xsl:value-of select="substring($alphabet, $position-mod, 1)"/>
        
    </xsl:function>
    
    <!-- Find position of a node in a collection -->
    <xsl:function name="ops:index-of-node" as="xs:integer*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="nodeToFind" as="node()?"/>
        <xsl:sequence select="for $seq in (1 to count($nodes)) return $seq[$nodes[$seq] is $nodeToFind]"/>
    </xsl:function>
    
    <!-- Set element namespace recurring -->
    <xsl:function name="ops:change-element-ns-deep" as="node()*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="newns" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:for-each select="$nodes">
            <xsl:variable name="node" select="."/>
            <xsl:choose>
                <xsl:when test="$node instance of element()">
                    <xsl:element name="{concat($prefix, if ($prefix = '') then '' else ':', local-name($node))}" namespace="{$newns}">
                        <xsl:sequence select="($node/@*, ops:change-element-ns-deep($node/node(), $newns, $prefix))"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$node instance of document-node()">
                    <xsl:document>
                        <xsl:sequence select="ops:change-element-ns-deep($node/node(), $newns, $prefix)"/>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$node"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Repeat a string, Repeat a string, ... -->
    <xsl:function name="ops:repeat-string" as="xs:string">
        <xsl:param name="stringToRepeat" as="xs:string?"/>
        <xsl:param name="count" as="xs:integer"/>
        
        <xsl:sequence select="string-join((for $i in 1 to $count return $stringToRepeat),'')"/>
        
    </xsl:function>
    
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
                    <xsl:value-of select="'No shared entity defined'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Output warnings on an entity form -->
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
                                <xsl:value-of select="'NOTE: Updates to this shared entity must apply for all elements matched to this entity!'"/>
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
            </div>
        </div>
        
    </xsl:template>
    
    <!-- Output form input controls for an entity -->
    <xsl:template name="entity-form-input">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="context-id" as="xs:string"/><!-- To create sub-ids in the DOM -->
        <xsl:param name="default-label-text" as="xs:string?"/>
        <xsl:param name="default-label-lang" as="xs:string?"/>
        <xsl:param name="default-entity-type" as="xs:string"/>
        <xsl:param name="entity-types" as="element(m:type)*"/>
        <xsl:param name="entity-flags" as="element(m:flag)*"/>
        
        <input type="hidden" name="entity-id" value="{ $entity/@xml:id }"/>
        
        <!-- Labels -->
        <div class="add-nodes-container">
            
            <xsl:choose>
                <xsl:when test="$entity">
                    <xsl:for-each select="$entity/m:label[not(@primary-transliterated)]">
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
        
        <!-- Flag checkboxes -->
        <xsl:if test="$entity-flags">
            <div class="form-group">
                
                <label class="col-sm-2 control-label">
                    <xsl:value-of select="'Flags:'"/>
                </label>
                <div class="col-sm-10">
                    <xsl:for-each select="$entity-flags">
                        <xsl:variable name="entity-flag" select="."/>
                        <div class="checkbox-inline">
                            <label>
                                <input type="checkbox" name="entity-flag[]">
                                    <xsl:attribute name="value" select="$entity-flag/@id"/>
                                    <xsl:if test="$entity/m:flag[@type = $entity-flag/@id]">
                                        <xsl:attribute name="checked" select="'checked'"/>
                                    </xsl:if>
                                </input>
                                <xsl:value-of select="concat(' ', $entity-flag/m:label[1])"/>
                            </label>
                        </div>
                    </xsl:for-each>
                </div>
                
            </div>
        </xsl:if>
        
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
    
    <!-- List elements linked to an entity -->
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
    
    <!-- Form controls for resolving similar entities -->
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
    
    <!-- Tag reference for definitions -->
    <xsl:template name="definition-tag-reference">
        
        <xsl:param name="element-id" as="xs:string" required="true"/>
        
        <div class="form-group">
            <div class="col-sm-offset-2 col-sm-8">
                <div class="panel panel-default no-bottom-margin">
                    <div class="panel-heading" role="tab">
                        <a href="{ concat('#tag-reference-', $element-id) }" aria-controls="{ concat('tag-reference-', $element-id) }" id="{ concat('#tag-reference-heading-', $element-id) }" class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                            <h5 class="text-muted small">
                                <xsl:value-of select="'Tag reference for definitions'"/>
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
    
    <!-- Output a text input control with an associated language dropdown -->
    <xsl:template name="text-input-with-lang">
        
        <xsl:param name="text" as="xs:string?"/>
        <xsl:param name="lang" as="xs:string?"/>
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
    
    <!-- language <select/> -->
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
                <xsl:value-of select="'Translation'"/>
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
    
    <!-- Output terms of a gloss/item -->
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
    
    <!-- Output definition of a gloss/item -->
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
    
    <!-- Glossary items grouped by text -->
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
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $item/m:text/@id, '.html#', $item/@id)"/>
                                    <xsl:value-of select="$item/@id"/>
                                </a>
                            </span>
                            
                            <!-- A link to switch to this item -->
                            <xsl:value-of select="' / '"/>
                            <span>
                                <xsl:choose>
                                    <xsl:when test="not(@id eq $active-glossary-id)">
                                        <a class="small">
                                            <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $item/m:text/@id, '&amp;resource-type=', $item/m:text/@type, '&amp;glossary-id=', $item/@id, '&amp;max-records=1&amp;filter=check-entities', '#expand-item-glossary-form-', $item/@id, '-detail')"/>
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
                                <xsl:with-param name="item" select="$item"/>
                                <xsl:with-param name="list-class" select="'no-bottom-margin'"/>
                            </xsl:call-template>
                        </div>
                        
                        <!-- Definition -->
                        <div class="item-row">
                            
                            <xsl:call-template name="glossary-definition">
                                <xsl:with-param name="item" select="$item"/>
                            </xsl:call-template>
                            
                            
                            
                            <!-- Use entity definition -->
                            <xsl:if test="$item/parent::m:instance[@use-definition gt '']/parent::m:entity/m:content[@type eq 'glossary-definition']">
                                <div class="sml-margin bottom">
                                    <span class="label label-default">
                                        <xsl:value-of select="'Includes entity definition'"/>
                                    </span>
                                </div>
                            </xsl:if>
                            
                        </div>
                        
                    </div>
                </xsl:for-each>
            </div>
            
        </fieldset>
        
    </xsl:template>
    
    <!-- Output Knowledge base article reference -->
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
                                <xsl:value-of select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
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
    
    <!-- MARKDOWN templates:
        
        Markdown                       XML                                              Notes / Conditions
        ~~~~~~~~~~~~~~~~~~~~~~~~       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        text                      <->  <p>text</p>                                      Where text is on a new line
        (tag)                     <->  <tag/>                                           Where tag is on a new line e.g. <lb/>
        (tag id:abc)              <->  <tag xml:id="abc"/>                              Where tag is on a new line e.g. <milestone/>
        [data](tag)               <->  <tag>data</tag>
        [data](tag lang:bo)       <->  <tag xml:lang="bo">data</tag>
        [data[[data]](tag)](tag)  <->  <tag xml:lang="bo">data[[data]](tag)</tag>       Match the outermost brackets, then recurse.
        [data](bo)                <->  <foreign xml:lang="bo">data</foreign>            Where lang is known-lang
        [data](http://abc)        <->  <ref target="http://abc">data</ref>              Valid for http: and https:
        
    -->
    <xsl:variable name="element-regex" select="'(?:^\s*|\[((?:\[{2,}|\]{2,}|[^\[\]])+)\])\((.+?)\)'"/>
    <xsl:variable name="heading-regex" select="'^\s*#+\s+'"/>
    <xsl:variable name="bullet-item-regex" select="'^\s*\*\s+'"/>
    <xsl:variable name="numbers-item-regex" select="'^\s*\d\.\s+'"/>
    <xsl:variable name="letters-item-regex" select="'^\s*[a-zA-Z]\.\s+'"/>
    <xsl:variable name="endnote-regex" select="'^\s*n\.\d\s+'"/>
    
    <!-- 
        Known languages can be used in short codes 
        e.g. [data](bo) -> <foreign xml:lang="bo">data</foreign>
    -->
    <xsl:variable name="known-langs" select="('bo', 'en', 'zh', 'Sa-Ltn', 'Bo-Ltn', 'Pi-Ltn')"/>
    
    <!-- Return character for new lines in markdown -->
    <xsl:variable name="char-nl" select="'&#xA;'"/>
    
    <xsl:function name="markdown:new-line">
        <xsl:param name="position"/>
        <xsl:if test="$position gt 1">
            <xsl:value-of select="$char-nl || $char-nl"/>
        </xsl:if>
    </xsl:function>
    
    <!-- Tei -> Markdown -->
    <xsl:template match="tei:div[@type eq 'markup']">
        
        <xsl:variable name="markup" select="."/>
        <!-- The element to convert for a new-line -->
        <xsl:variable name="newline-element" select="($markup/@newline-element, 'p')[1]" as="xs:string"/>
        
        <xsl:element name="markdown" namespace="http://read.84000.co/ns/1.0">
            
            <!-- Loop through nodes formatting everything to markdown strings -->
            <xsl:for-each select="$markup/node()[normalize-space(data())]">
                
                <xsl:choose>
                    
                    <!-- Text node -->
                    <xsl:when test=". instance of text() and normalize-space(.) gt ''">
                        
                        <xsl:call-template name="markdown:string">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                    </xsl:when>
                    
                    <!-- Element -->
                    <xsl:when test=". instance of element()">
                        <xsl:choose>
                            
                            <!-- List -->
                            <xsl:when test="local-name(.) eq 'list' and @type eq 'bullet'">
                                
                                <xsl:variable name="list-style" select="@rend"/>
                                
                                <xsl:for-each select="*:item">
                                    
                                    <!-- New line before list item -->
                                    <xsl:value-of select="markdown:new-line(position())"/>
                                    
                                    <!-- Leading chars to markdown list -->
                                    <xsl:choose>
                                        
                                        <!-- Numbered list -->
                                        <xsl:when test="$list-style eq 'numbers'">
                                            <xsl:value-of select="concat(position(), '. ')"/>
                                        </xsl:when>
                                        
                                        <!-- Letters list -->
                                        <xsl:when test="$list-style eq 'letters'">
                                            <xsl:value-of select="concat(ops:position-to-letter(position()), '. ')"/>
                                        </xsl:when>
                                        
                                        <!-- Bullet list -->
                                        <xsl:otherwise>
                                            <xsl:value-of select="'* '"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                    
                                    <!-- Parse each content node -->
                                    <xsl:choose>
                                        <!-- Shortcut for single p element -->
                                        <xsl:when test="count(child::*) eq 1 and child::tei:p">
                                            <xsl:for-each select="child::tei:p/node()">
                                                <xsl:call-template name="markdown:string">
                                                    <xsl:with-param name="node" select="."/>
                                                    <xsl:with-param name="markup" select="$markup"/>
                                                </xsl:call-template>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <!-- Otherwise markdown all content -->
                                        <xsl:otherwise>
                                            <xsl:for-each select="node()">
                                                <xsl:call-template name="markdown:string">
                                                    <xsl:with-param name="node" select="."/>
                                                    <xsl:with-param name="markup" select="$markup"/>
                                                </xsl:call-template>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:for-each>
                                
                            </xsl:when>
                            
                            <!-- Heading -->
                            <xsl:when test="local-name(.) eq 'head' and @type = ('section', 'nonStructuralBreak') and not(@*[not(local-name(.) = ('type', 'tid'))]) and not(*)">
                                
                                <!-- New line before heading -->
                                <xsl:value-of select="markdown:new-line(position())"/>
                                
                                <!-- Hash specifies a header -->
                                <xsl:value-of select="'# '"/>
                                
                                <!-- Output value -->
                                <xsl:value-of select="normalize-space(data())"/>
                                
                            </xsl:when>
                            
                            <!-- Element creating a new line -->
                            <xsl:when test="local-name(.) eq $newline-element and not(@*[not(local-name(.) eq 'tid')])">
                                
                                <!-- New line before paragraph -->
                                <xsl:value-of select="markdown:new-line(position())"/>
                                
                                <!-- Parse each content node -->
                                <xsl:for-each select="node()">
                                    <xsl:call-template name="markdown:string">
                                        <xsl:with-param name="node" select="."/>
                                        <xsl:with-param name="markup" select="$markup"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                
                            </xsl:when>
                            
                            <!-- Parse the content -->
                            <xsl:otherwise>
                                
                                <xsl:call-template name="markdown:string">
                                    <xsl:with-param name="node" select="."/>
                                    <xsl:with-param name="markup" select="$markup"/>
                                </xsl:call-template>
                                
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                
            </xsl:for-each>
            
            <!-- Output notes at the end -->
            <xsl:for-each select="//tei:note[@place eq 'end']">
                
                <!-- Force new line -->
                <xsl:value-of select="markdown:new-line(2)"/>
                
                <xsl:value-of select="concat('n.', position(), ' ')"/>
                
                <xsl:for-each select="node()">
                    <xsl:call-template name="markdown:string">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
                
            </xsl:for-each>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Markdown -> XML(TEI) -->
    <xsl:template match="m:markdown">
    
        <!-- The source node -->
        <xsl:variable name="source" select="."/>
        
        <!-- The element to apply for a new-line -->
        <xsl:variable name="newline-element" select="($source/@newline-element, 'p')[1]" as="xs:string"/>
        <!-- The target namespace for markup -->
        <xsl:variable name="namespace" select="($source/@target-namespace, 'http://www.tei-c.org/ns/1.0')[1]" as="xs:string"/>
        <!-- The content tokenized into lines -->
        <xsl:variable name="lines" select="tokenize($source/node(), '\n')" as="xs:string*"/>
        
        <!-- Parse lines to elements -->
        <xsl:variable name="elements">
            
            <!-- Need a root element so we can evaluate siblings -->
            <elements xmlns="http://read.84000.co/ns/1.0">
                
                <!-- Exclude empty lines and notes -->
                <xsl:for-each select="$lines[matches(., '\w+')][not(matches(., $endnote-regex))]">
                    
                    <xsl:variable name="line" select="."/>
                    <xsl:variable name="line-number" select="position()"/>
                    
                    <xsl:choose>
                        
                        <!-- This line defines an element -->
                        <xsl:when test="matches($line, concat('^\s*', $element-regex, '\s*$'), 'i')">
                            <xsl:call-template name="markdown:element">
                                <xsl:with-param name="md-string" select="replace($line, '\s+', ' ')"/>
                                <xsl:with-param name="namespace" select="$namespace"/>
                                <xsl:with-param name="lines" select="$lines"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                        <!-- Otherwise derive the element -->
                        <xsl:otherwise>
                            
                            <xsl:variable name="element-name">
                                <xsl:choose>
                                    
                                    <!-- Check known patterns -->
                                    
                                    <xsl:when test="matches($line, $heading-regex)">
                                        <xsl:value-of select="'head'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $bullet-item-regex)">
                                        <xsl:value-of select="'item'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $numbers-item-regex)">
                                        <xsl:value-of select="'item'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $letters-item-regex)">
                                        <xsl:value-of select="'item'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $endnote-regex)">
                                        <xsl:value-of select="'note'"/>
                                    </xsl:when>
                                    
                                    <!-- Default element -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="$newline-element"/>
                                    </xsl:otherwise>
                                    
                                </xsl:choose>
                            </xsl:variable>
                            
                            <!-- Add a container element -->
                            <xsl:element name="{ $element-name }" namespace="{ $namespace }">
                                
                                <!-- Set item type -->
                                <xsl:if test="$element-name eq 'item'">
                                    <xsl:attribute name="line-group-type">
                                        <xsl:choose>
                                            
                                            <xsl:when test="matches($line, $bullet-item-regex)">
                                                <xsl:value-of select="'list-item-bullet'"/>
                                            </xsl:when>
                                            
                                            <xsl:when test="matches($line, $numbers-item-regex)">
                                                <xsl:value-of select="'list-item-number'"/>
                                            </xsl:when>
                                            
                                            <xsl:when test="matches($line, $letters-item-regex)">
                                                <xsl:value-of select="'list-item-letter'"/>
                                            </xsl:when>
                                            
                                        </xsl:choose>
                                    </xsl:attribute>
                                </xsl:if>
                                
                                <!-- Set head type -->
                                <xsl:if test="$element-name eq 'head'">
                                    <xsl:attribute name="type">
                                        
                                        <!-- 
                                            Remove option for multiple #
                                            Heading type determined by position in section
                                            
                                            <!-/- Evaluate the indent level -/->
                                            <xsl:variable name="leading-hashes" select="replace($line, '^\s*(#+)\s+(.*)', '$1')"/>
                                            
                                            <xsl:choose>
                                                <xsl:when test="string-length($leading-hashes) eq 1">
                                                    <xsl:value-of select="'section'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="'nonStructuralBreak'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        -->
                                        
                                        <xsl:choose>
                                            <xsl:when test="$line-number eq 1">
                                                <xsl:value-of select="'section'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'nonStructuralBreak'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </xsl:attribute>
                                    
                                </xsl:if>
                                
                                <!-- Get content -->
                                <xsl:variable name="content">
                                    <xsl:choose>
                                        
                                        <!-- Head -->
                                        <xsl:when test="matches($line, $heading-regex)">
                                            <xsl:value-of select="replace(., $heading-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Bullet list -->
                                        <xsl:when test="matches($line, $bullet-item-regex)">
                                            <xsl:value-of select="replace(., $bullet-item-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Number list -->
                                        <xsl:when test="matches($line, $numbers-item-regex)">
                                            <xsl:value-of select="replace(., $numbers-item-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Letter list -->
                                        <xsl:when test="matches($line, $letters-item-regex)">
                                            <xsl:value-of select="replace(., $letters-item-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Note -->
                                        <xsl:when test="matches($line, $endnote-regex)">
                                            <xsl:value-of select="replace(., $endnote-regex, '')"/>
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <!-- Parse content -->
                                <xsl:analyze-string select="replace(replace($content, '^\s+', ''), '\s+', ' ')" regex="{ $element-regex }">
                                    
                                    <xsl:matching-substring>
                                        <xsl:call-template name="markdown:element">
                                            <xsl:with-param name="md-string" select="."/>
                                            <xsl:with-param name="namespace" select="$namespace"/>
                                            <xsl:with-param name="lines" select="$lines"/>
                                            <xsl:with-param name="leading-space" select="if(matches(., '^\s+')) then ' ' else ''"/>
                                            <xsl:with-param name="trailing-space" select="if(matches(., '\s+$')) then ' ' else ''"/>
                                        </xsl:call-template>
                                    </xsl:matching-substring>
                                    
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                    
                                </xsl:analyze-string>
                                
                            </xsl:element>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </xsl:for-each>
            
            </elements>
        
        </xsl:variable>
        
        <!-- Make groups of similar items for lists -->
        <xsl:variable name="elements">
            <xsl:for-each select="$elements/m:elements/*">
                
                <xsl:variable name="element" select="."/>
                
                <!-- Make a copy of the element -->
                <!-- Add a group for list items -->
                <xsl:element name="{ node-name($element) }" namespace="{ namespace-uri($element) }">
                    
                    <!-- Copy attributes -->
                    <xsl:sequence select="$element/@*"/>
                    
                    <!-- Add an attribute grouping list items -->
                    <xsl:attribute name="line-group-id">
                        <xsl:choose>
                            
                            <!-- List types where it's not the first in the list -->
                            <xsl:when test="local-name($element) eq 'item' and preceding-sibling::*[1][@line-group-type eq $element/@line-group-type]">
                                <!-- 
                                    Find the first in this list
                                    - Closest sibling of this type that has a first sibling of not this type
                                    - Use the index of that as the group id
                                -->
                                <xsl:variable name="first-in-group" select="$element/preceding-sibling::*[@line-group-type eq $element/@line-group-type][preceding-sibling::*[1][not(@line-group-type eq $element/@line-group-type)]][1]"/>
                                <xsl:value-of select="ops:index-of-node($elements/m:elements/*, $first-in-group)"/>
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <xsl:value-of select="ops:index-of-node($elements/m:elements/*, $element)"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:attribute>
                    
                    <!-- Copy nodes -->
                    <xsl:sequence select="node()"/>
                    
                </xsl:element>
                
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Output tei -->
        <xsl:element name="div" namespace="{ $namespace }">
            
            <xsl:attribute name="type" select="'markup'"/>
            
            <xsl:for-each-group select="$elements/*" group-by="@line-group-id">
                <xsl:choose>
                    
                    <!-- Add a list for list items -->
                    <xsl:when test="local-name(.) eq 'item'">
                        <xsl:element name="list" namespace="{ $namespace }">
                            
                            <xsl:attribute name="type" select="'bullet'"/>
                            
                            <xsl:choose>
                                <xsl:when test="@line-group-type eq 'list-item-bullet'">
                                    <xsl:attribute name="rend" select="'dots'"/>
                                </xsl:when>
                                <xsl:when test="@line-group-type eq 'list-item-number'">
                                    <xsl:attribute name="rend" select="'numbers'"/>
                                </xsl:when>
                                <xsl:when test="@line-group-type eq 'list-item-letter'">
                                    <xsl:attribute name="rend" select="'letters'"/>
                                </xsl:when>
                            </xsl:choose>
                            
                            <!-- Add each item in the list -->
                            <xsl:for-each select="current-group()">
                                <xsl:choose>
                                    <!-- If item has direct child data then nest in a <p/> -->
                                    <xsl:when test="node()[. instance of text() and normalize-space(.)]">
                                        <xsl:element name="item" namespace="{ namespace-uri(.) }">
                                            <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                            <xsl:element name="p" namespace="{ $namespace }">
                                                <xsl:sequence select="node()"/>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:when>
                                    <!-- Otherwise output item -->
                                    <xsl:otherwise>
                                        <xsl:element name="item" namespace="{ namespace-uri(.) }">
                                            <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                            <xsl:sequence select="node()"/>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            
                        </xsl:element>
                    </xsl:when>
                    
                    <!-- Add the element -->
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:element name="{ node-name(.) }" namespace="{ $namespace }">
                                <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                <xsl:sequence select="node()"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:otherwise>
                    
                </xsl:choose>  
            </xsl:for-each-group>
            
        </xsl:element>
           
    </xsl:template>
    
    <!-- XML(TEI) -> escaped string -->
    <xsl:template match="m:unescaped">
        
        <xsl:element name="escaped" namespace="http://read.84000.co/ns/1.0">
            
            <xsl:variable name="serialization-parameters" as="element(output:serialization-parameters)">
                <output:serialization-parameters>
                    <output:method value="xml"/>
                    <output:version value="1.1"/>
                    <output:indent value="no"/>
                    <output:omit-xml-declaration value="yes"/>
                </output:serialization-parameters>
            </xsl:variable>
            
            <!-- Loop through nodes to avoid whitespace from passing node() sequence -->
            <xsl:for-each select="node()[normalize-space(.) gt '']">
                <xsl:value-of select="replace(replace(serialize(., $serialization-parameters), '\s+', ' '), '\s*xmlns=&#34;\S*&#34;', '')"/>
            </xsl:for-each>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Escaped string -> XML(TEI) -->
    <xsl:template match="m:escaped">
        
        <xsl:variable name="source" select="."/>
        <xsl:variable name="namespace" select="($source/@target-namespace, 'http://www.tei-c.org/ns/1.0')[1]"/>
        
        <xsl:element name="div" namespace="{ $namespace }">
            
            <xsl:attribute name="type" select="'markup'"/>
            
            <xsl:sequence select="ops:change-element-ns-deep(parse-xml(concat('&lt;doc&gt;',text(),'&lt;/doc&gt;'))/doc/node(), $namespace, '')"/>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Create an element from a markdown string -->
    <xsl:template name="markdown:element">
        
        <xsl:param name="md-string" as="xs:string"/>
        <xsl:param name="lines" as="xs:string*"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="leading-space" as="xs:string?"/>
        <xsl:param name="trailing-space" as="xs:string?"/>
        
        <xsl:variable name="content" select="replace($md-string, $element-regex, '$1')"/>
        <xsl:variable name="element" select="replace($md-string, $element-regex, '$2')"/>
        <xsl:variable name="element-tokenized" select="tokenize($element, '\s+')"/>
        <xsl:variable name="element-one" select="$element-tokenized[1]"/>
        <xsl:variable name="element-one-tokenized" select="tokenize($element-one,':')"/>
        <xsl:variable name="element-rest" select="subsequence($element-tokenized, 2)"/>
        
        <!-- Derive the element from the first token -->
        <xsl:variable name="element-name" as="xs:string?">
            <xsl:choose>
                <xsl:when test="lower-case($element-one) = $known-langs ! lower-case(.)">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="count($element-one-tokenized) eq 1">
                    <xsl:value-of select="$element-one-tokenized"/>
                </xsl:when>
                <xsl:when test="$element-one-tokenized[1] eq 'lang'">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="$element-one-tokenized[1] = ('http', 'https')">
                    <xsl:value-of select="'ref'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- If it's a note derive the content from a different line -->
        <xsl:variable name="content">
            
            <xsl:choose>
                
                <xsl:when test="$element-name eq 'note'">
                    <xsl:value-of select="$lines[matches(., concat('^\s*n\.', $content, '\s+'))][1] ! replace(., $endnote-regex, '')"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:value-of select="$content"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- An element has been determined -->
            <xsl:when test="$element-name">
                
                <xsl:value-of select="$leading-space"/>
                
                <!-- Add the element -->
                <xsl:element name="{ $element-name }" namespace="{ $namespace }">
                    
                    <!-- Add attributes based on first token -->
                    <xsl:choose>
                        <xsl:when test="lower-case($element-one) = $known-langs ! lower-case(.)">
                            <xsl:attribute name="xml:lang" select="$known-langs[lower-case(.) eq lower-case($element-one)]"/>
                        </xsl:when>
                        <xsl:when test="$element-one-tokenized[1] eq 'lang'">
                            <xsl:call-template name="markdown:attributes">
                                <xsl:with-param name="md-string" select="$element-one"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$element-one-tokenized[1] = ('http', 'https')">
                            <xsl:attribute name="target" select="$element-one"/>
                        </xsl:when>
                        <xsl:when test="$element-name eq 'milestone'">
                            <xsl:attribute name="unit" select="'chunk'"/>
                        </xsl:when>
                        <xsl:when test="$element-name eq 'note'">
                            <xsl:attribute name="place" select="'end'"/>
                        </xsl:when>
                    </xsl:choose>
                    
                    <!-- Parse other attributes -->
                    <xsl:call-template name="markdown:attributes">
                        <xsl:with-param name="md-string" select="$element-rest"/>
                    </xsl:call-template>
                    
                    <!-- Add the content -->
                    <xsl:if test="normalize-space($content) gt ''">
                        
                        <!-- Parse content -->
                        <!-- Remove a bracket from nested brackets - single brackets get parsed e.g. [[data]](tag) (will be ignored) -> [data](tag) (will be marked up) -->
                        <xsl:variable name="content-unnested" select="replace(replace($content, '(?:\]{2})([^\]])', ']$1'), '(?:\[{2})([^\[])', '[$1')"/>
                        <xsl:analyze-string select="$content-unnested" regex="{ $element-regex }">
                            
                            <xsl:matching-substring>
                                <xsl:call-template name="markdown:element">
                                    <xsl:with-param name="md-string" select="."/>
                                    <xsl:with-param name="namespace" select="$namespace"/>
                                    <xsl:with-param name="lines" select="$lines"/>
                                    <xsl:with-param name="leading-space" select="if(matches(., '^\s+')) then ' ' else ''"/>
                                    <xsl:with-param name="trailing-space" select="if(matches(., '\s+$')) then ' ' else ''"/>
                                </xsl:call-template>
                            </xsl:matching-substring>
                            
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                            
                        </xsl:analyze-string>
                        
                    </xsl:if>
                    
                </xsl:element>
                
                <xsl:value-of select="$trailing-space"/>
                
            </xsl:when>
            
            <!-- No element determined -->
            <xsl:otherwise>
                <xsl:value-of select="$md-string"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Create attributes from markdown string -->
    <xsl:template name="markdown:attributes">
        
        <xsl:param name="md-string" as="xs:string*"/>
        
        <xsl:for-each select="$md-string">
            
            <xsl:variable name="attribute-tokenized" select="tokenize(., ':')"/>
            
            <xsl:if test="count($attribute-tokenized) eq 2">
                <xsl:choose>
                    <xsl:when test="$attribute-tokenized[1] eq 'lang'">
                        <xsl:attribute name="xml:lang" select="($known-langs[lower-case(.) eq lower-case($attribute-tokenized[2])], $attribute-tokenized[2])[1]"/>
                    </xsl:when>
                    <xsl:when test="$attribute-tokenized[1] eq 'id'">
                        <xsl:attribute name="xml:id" select="$attribute-tokenized[2]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{ $attribute-tokenized[1] }" select="$attribute-tokenized[2]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Create a markdown string from an element -->
    <xsl:template name="markdown:string">
        
        <xsl:param name="node" as="node()"/>
        <xsl:param name="markup" as="node()*"/>
        <xsl:param name="nesting" as="xs:integer" select="1"/>
        
        <xsl:choose>
            
            <!-- Text node -->
            <xsl:when test="$node instance of text()">
                <xsl:value-of select="replace($node/data(), '\s+', ' ')"/>
            </xsl:when>
            
            <!-- Element -->
            <xsl:when test="$node instance of element()">
                
                <!-- Add data in square brackets -->
                <xsl:if test="$node[data()]">
                    
                    <xsl:value-of select="ops:repeat-string('[', $nesting)"/>
                    
                    <xsl:choose>
                        
                        <!-- If it's an end note then just output the number e.g. 1) -->
                        <xsl:when test="$node[self::tei:note[@place eq 'end']]">
                            <xsl:value-of select="ops:index-of-node($markup//tei:note[@place eq 'end'], $node)"/>
                        </xsl:when>
                        
                        <!-- Otherwise parse the sub nodes -->
                        <xsl:otherwise>
                            <xsl:for-each select="$node/node()">
                                <xsl:call-template name="markdown:string">
                                    <xsl:with-param name="node" select="."/>
                                    <xsl:with-param name="markup" select="$markup"/>
                                    <xsl:with-param name="nesting" select="$nesting + 1"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <xsl:value-of select="ops:repeat-string(']', $nesting)"/>
                    
                </xsl:if>
                
                <!-- Attributes string -->
                <xsl:variable name="attributes-strings" as="xs:string*">
                    
                    <xsl:variable name="exclude-attributes" as="xs:string*">
                        <xsl:value-of select="'tid'"/>
                        <xsl:choose>
                            <xsl:when test="local-name($node) eq 'milestone'">
                                <xsl:value-of select="'unit'"/>
                            </xsl:when>
                            <xsl:when test="local-name($node) eq 'note' and $node[@place eq 'end']">
                                <xsl:value-of select="'index'"/>
                                <xsl:value-of select="'place'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="included-attributes" select="$node/@*[not(local-name(.) = $exclude-attributes)]"/>
                    
                    <xsl:choose>
                        <xsl:when test="count($included-attributes) eq 1 and local-name($node) eq 'foreign' and local-name($included-attributes[1]) eq 'lang' and $known-langs[lower-case(.) eq lower-case($included-attributes[1])]">
                            <xsl:value-of select="$known-langs[lower-case(.) eq lower-case($included-attributes[1])]"/>
                        </xsl:when>
                        <xsl:when test="count($included-attributes) eq 1 and local-name($node) eq 'ref' and local-name($included-attributes[1]) eq 'target' and matches($included-attributes[1]/string(), '^(http:|https:)')">
                            <xsl:value-of select="$included-attributes[1]/string()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$included-attributes ! concat(local-name(.), ':', string())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:variable>
                
                <!-- Element name -->
                <xsl:variable name="element-name" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="count($attributes-strings) eq 1 and ($known-langs[. eq $attributes-strings[1]] or matches($attributes-strings[1], '^(http:|https:)'))">
                            <!-- Short code: no element name required -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name($node)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Add element name & attributes in round brackets -->
                <xsl:value-of select="concat('(', string-join(($element-name, $attributes-strings), ' '), ')')"/>
                
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Markdown help guide -->
    <xsl:template name="markdown:guide">
        
        <xsl:param name="mode" as="xs:string?"/>
        
        <h3>
            <xsl:value-of select="'Using Markdown'"/>
        </h3>
        
        <div class="small">
            
            <xsl:if test="$mode eq 'full'">
                
                <p class="text-muted">
                    <xsl:value-of select="'Markdown is a standard for marking-up content using simplified syntax. '"/>
                    <xsl:value-of select="'Here we have extended the markdown standard to allow us to update TEI.'"/>
                    <br/>
                    <span class="text-danger uppercase">
                        <xsl:value-of select="'Note: this is NOT standard markdown.'"/>
                    </span>
                </p>
                
                <p>
                    <xsl:value-of select="'To add a new paragraph simply start a new line'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'A paragraph has no line breaks in it.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'A new paragraph comes after a line break.'"/>
                    <br/>
                </pre>
                
                <p>
                    <xsl:value-of select="'Specify a heading with a #'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'# Heading'"/>
                </pre>
                
                <p>
                    <xsl:value-of select="'Easily define lists'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'* First bullet list item'"/>
                    <br/>
                    <xsl:value-of select="'* Next bullet list item'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'1. First numbered list item'"/>
                    <br/>
                    <xsl:value-of select="'2. Next numbered list item'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'a. First lettered list item'"/>
                    <br/>
                    <xsl:value-of select="'b. Next lettered list item'"/>
                    <br/>
                </pre>
                
                <p>
                    <xsl:value-of select="'There are also some short-code tags'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'(lb)'"/>
                    <br/>
                    <xsl:value-of select="'This paragraph will have an extra line of space above.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'(milestone)'"/>
                    <br/>
                    <xsl:value-of select="'This paragraph has a milestone in the margin.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'The term [Maitrāyanī](Sa-Ltn) is tagged as Sanskrit.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'This [84000.co](https://84000.co) will be rendered as a link.'"/>
                    <br/>
                </pre>
                
            </xsl:if>
            
            <p>
                <xsl:value-of select="'All TEI tags are supported by specifying the text in square brackets [text] followed by the tag definition in round brackets (tag).'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'You can specify a tag for any text inline [Karmaśataka](title). '"/>
                <br/>
                <br/>
                <xsl:value-of select="'Add the language attribute [Karmaśataka](title lang:Sa-Ltn).'"/>
                <br/>
                <br/>
                <xsl:value-of select="'And add further attributes [Karmaśataka](title lang:Sa-Ltn ref:entity-123).'"/>
                <br/>
            </pre>
            
            <pre class="wrap">
                <xsl:value-of select="'You may encounter complex nesting of elements, like [[[The Teaching of [[[Vimalakīrti]]](term ref:entity-123)]](http://read.84000.co/translation/toh176.html)](title lang:en) (Toh 176). '"/>
                <xsl:value-of select="'If in doubt leave brackets alone and ask a TEI editor to help. '"/>
            </pre>
            
            <pre class="wrap">
                <xsl:value-of select="'You can add a notes using the syntax [1](note) and another [2](note).'"/>
                <br/>
                <br/>
                <xsl:value-of select="'n.1 The content of the 1st note is after the passage.'"/>
                <br/>
                <xsl:value-of select="'n.2 And the content for the 2nd is on a new line.'"/>
                <br/>
            </pre>
            
        </div>
    </xsl:template>
    
</xsl:stylesheet>