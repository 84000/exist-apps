<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
    
    <!-- Accordion panel -->
    <xsl:template name="panel">
        <xsl:param name="type" required="yes"/>
        <xsl:param name="form" required="yes"/>
        <xsl:param name="flag"/>
        <xsl:param name="active"/>
        <div class="panel panel-default no-shadow">
            <div class="panel-heading" role="tab">
                <xsl:attribute name="id" select="concat('panelHeading', $type)"/>
                <a role="button" data-toggle="collapse" aria-expanded="false" data-parent="#forms-accordion" class="collapsed">
                    <xsl:attribute name="href" select="concat('#panel', $type)"/>
                    <xsl:attribute name="aria-controls" select="concat('panel', $type)"/>
                    <xsl:if test="$active">
                        <xsl:attribute name="class" select="''"/>
                        <xsl:attribute name="aria-expanded" select="'true'"/>
                    </xsl:if>
                    <div class="center-vertical full-width">
                        <span>
                            <h3 class="panel-title">
                                <xsl:value-of select="concat($type, ' ')"/>
                                <xsl:copy-of select="$flag"/>
                            </h3>
                        </span>
                        <span class="text-right">
                            <i class="fa fa-plus collapsed-show"/>
                            <i class="fa fa-minus collapsed-hide"/>
                        </span>
                    </div>
                </a>
            </div>
            <div class="panel-collapse collapse" role="tabpanel">
                <xsl:attribute name="id" select="concat('panel', $type)"/>
                <xsl:attribute name="aria-labelledby" select="concat('panelHeading', $type)"/>
                <xsl:if test="$active">
                    <xsl:attribute name="class" select="'panel-collapse collapse in'"/>
                </xsl:if>
                <div class="panel-body">
                    <xsl:copy-of select="$form"/>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <!-- Titles in a panel -->
    <xsl:template name="titles-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            <xsl:with-param name="type" select="'Titles'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="titles-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#titles-form'"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    <div class="add-nodes-container">
                        <xsl:choose>
                            <xsl:when test="m:translation/m:titles/m:title">
                                <xsl:call-template name="titles-controls">
                                    <xsl:with-param name="text-titles" select="m:translation/m:titles/m:title"/>
                                    <xsl:with-param name="title-types" select="/m:response/m:title-types/m:title-type"/>
                                    <xsl:with-param name="title-langs" select="/m:response/m:title-types/m:title-lang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="titles-controls">
                                    <xsl:with-param name="text-titles">
                                        <m:title/>
                                    </xsl:with-param>
                                    <xsl:with-param name="title-types" select="/m:response/m:title-types/m:title-type"/>
                                    <xsl:with-param name="title-langs" select="/m:response/m:title-types/m:title-lang"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div>
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">+</span> add a title </a>
                        </div>
                    </div>
                    <div class="pull-right">
                        <button type="submit" class="btn btn-primary">
                            <xsl:value-of select="'Save'"/>
                        </button>
                    </div>
                </form>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Title row -->
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
                                <xsl:value-of select="$label"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="col-sm-8">
                    <input class="form-control">
                        <xsl:attribute name="name" select="concat('title-text-', position())"/>
                        <xsl:attribute name="value" select="$title-text"/>
                    </input>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Locations in a panel -->
    <xsl:template name="locations-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            <xsl:with-param name="type" select="'Locations'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="locations-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#locations-form'"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    <xsl:call-template name="locations-controls">
                        <xsl:with-param name="tohs" select="m:translation/m:toh"/>
                    </xsl:call-template>
                    <div class="pull-right">
                        <button type="submit" class="btn btn-primary">
                            <xsl:value-of select="'Save'"/>
                        </button>
                    </div>
                </form>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Location row -->
    <xsl:template name="locations-controls">
        <xsl:param name="tohs" required="yes"/>
        <xsl:for-each select="$tohs">
            <xsl:variable name="toh-key" select="./@key"/>
            <xsl:variable name="toh-location" select="/m:response/m:translation/m:location[@key eq $toh-key]"/>
            <input type="hidden">
                <xsl:attribute name="name" select="concat('location-', $toh-key)"/>
                <xsl:attribute name="value" select="$toh-key"/>
            </input>
            <fieldset>
                <legend>
                    <xsl:value-of select="concat('Toh ', ./m:base)"/>
                </legend>
                <div class="row">
                    <div class="col-sm-4">
                        <xsl:copy-of select="m:text-input('Start volume', concat('start-volume-', $toh-key), $toh-location/m:start/@volume, 6, 'required')"/>
                        <xsl:copy-of select="m:text-input('Start page', concat('start-page-', $toh-key), $toh-location/m:start/@page, 6, 'required')"/>
                    </div>
                    <div class="col-sm-4">
                        <xsl:copy-of select="m:text-input('End volume', concat('end-volume-', $toh-key), $toh-location/m:end/@volume, 6, 'required')"/>
                        <xsl:copy-of select="m:text-input('End page', concat('end-page-', $toh-key), $toh-location/m:end/@page, 6, 'required')"/>
                    </div>
                    <div class="col-sm-4">
                        <xsl:copy-of select="m:text-input('Count pages', concat('count-pages-', $toh-key), $toh-location/@count-pages, 6, 'required')"/>
                    </div>
                </div>
            </fieldset>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Contributors in a panel -->
    <xsl:template name="contributors-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            <xsl:with-param name="type" select="'Contributors'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="contributors-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#contributors-form'"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    <div class="row">
                        <div class="col-sm-8">
                            <xsl:copy-of select="m:select-input('Translation Status', 'translation-status', 9, 1, m:text-statuses/m:status)"/>
                            <xsl:variable name="translator-team-id" select="substring-after(m:translation/m:translation/m:contributors/m:summary[1]/@ref, 'contributors.xml#')"/>
                            <div class="form-group">
                                <label class="control-label col-sm-3">
                                    <xsl:value-of select="'Translator Team'"/>
                                </label>
                                <div class="col-sm-9">
                                    <select class="form-control">
                                        <xsl:attribute name="name" select="'translator-team-id'"/>
                                        <option value=""/>
                                        <xsl:for-each select="/m:response/m:contributor-teams/m:team">
                                            <option>
                                                <xsl:attribute name="value" select="concat('contributors.xml#', @xml:id)"/>
                                                <xsl:if test="@xml:id eq $translator-team-id">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="m:sort-name"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <xsl:if test="m:translation/m:translation/m:contributors/m:summary">
                                <div class="text-bold">Attribution</div>
                                <xsl:for-each select="m:translation/m:translation/m:contributors/m:summary">
                                    <p>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </xsl:if>
                        </div>
                    </div>
                    <hr class="sml-margin"/>
                    <div class="row">
                        <div class="col-sm-8">
                            <div class="add-nodes-container">
                                <xsl:call-template name="contributors-controls">
                                    <xsl:with-param name="text-contributors" select="m:translation/m:translation/m:contributors/m:*[self::m:author | self::m:editor | self::m:consultant]"/>
                                    <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type"/>
                                </xsl:call-template>
                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span> add a contributor </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <xsl:if test="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p">
                                <div class="text-bold">
                                    <xsl:value-of select="'Acknowledgments'"/>
                                </div>
                                <xsl:apply-templates select="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                            </xsl:if>
                        </div>
                    </div>
                    <hr class="sml-margin"/>
                    <div>
                        <p class="small text-muted">
                            <xsl:value-of select="'If a contributor is not automatically recognised in the acknowledgement text then please specify what they are &#34;expressed as&#34;. If a contributor is already highlighted then you can leave this field blank.'"/>
                        </p>
                    </div>
                    <hr class="sml-margin"/>
                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-10">
                            <div class="pull-right">
                                <div class="center-vertical">
                                    <span>
                                        <a>
                                            <xsl:if test="not(/m:response/@model-type eq 'operations/edit-text-sponsors')">
                                                <xsl:attribute name="target" select="'operations'"/>
                                            </xsl:if>
                                            <xsl:attribute name="href" select="concat($operations-path, '/edit-translator.html')"/>
                                            <xsl:value-of select="'Enter a new contributor'"/>
                                        </a>
                                    </span>
                                    <span>|</span>
                                    <span>
                                        <button type="submit" class="btn btn-primary">Save</button>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Contributors row -->
    <xsl:template name="contributors-controls">
        <xsl:param name="text-contributors" required="yes"/>
        <xsl:param name="contributor-types" required="yes"/>
        <xsl:choose>
            <xsl:when test="$text-contributors">
                <xsl:for-each select="$contributor-types">
                    <xsl:variable name="contributor-types-node-name" select="@node-name"/>
                    <xsl:variable name="contributor-types-role" select="@role"/>
                    <xsl:for-each select="$text-contributors[xs:string(local-name(.)) eq $contributor-types-node-name][xs:string(@role) eq $contributor-types-role]">
                        <xsl:variable name="contributor-id" select="substring-after(./@ref, 'contributors.xml#')"/>
                        <xsl:variable name="contributor-type" select="concat(node-name(.), '-', @role)"/>
                        <xsl:variable name="index" select="common:index-of-node($text-contributors, .)"/>
                        <div class="form-group add-nodes-group">
                            <div class="col-sm-3">
                                <xsl:call-template name="select-contributor-type">
                                    <xsl:with-param name="contributor-types" select="$contributor-types"/>
                                    <xsl:with-param name="control-name" select="concat('contributor-type-', $index)"/>
                                    <xsl:with-param name="selected-value" select="$contributor-type"/>
                                </xsl:call-template>
                            </div>
                            <div class="col-sm-3">
                                <xsl:call-template name="select-contributor">
                                    <xsl:with-param name="contributor-id" select="$contributor-id"/>
                                    <xsl:with-param name="control-name" select="concat('contributor-id-', $index)"/>
                                </xsl:call-template>
                            </div>
                            <label class="control-label col-sm-2">
                                <xsl:value-of select="'expression:'"/>
                            </label>
                            <div class="col-sm-4">
                                <input class="form-control" placeholder="same">
                                    <xsl:attribute name="name" select="concat('contributor-expression-', $index)"/>
                                    <xsl:if test="$contributor-type != ('summary-')">
                                        <xsl:attribute name="value" select="text()"/>
                                    </xsl:if>
                                </input>
                            </div>
                        </div>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- No existing contributors so show an set of controls -->
                <div class="form-group add-nodes-group">
                    <div class="col-sm-2">
                        <xsl:call-template name="select-contributor-type">
                            <xsl:with-param name="contributor-types" select="$contributor-types"/>
                            <xsl:with-param name="control-name" select="'contributor-type-1'"/>
                            <xsl:with-param name="selected-value" select="''"/>
                        </xsl:call-template>
                    </div>
                    <div class="col-sm-4">
                        <xsl:call-template name="select-contributor">
                            <xsl:with-param name="control-name" select="'contributor-id-1'"/>
                            <xsl:with-param name="contributor-id" select="''"/>
                        </xsl:call-template>
                    </div>
                    <label class="control-label col-sm-2">
                        <xsl:value-of select="'expressed as:'"/>
                    </label>
                    <div class="col-sm-4">
                        <input class="form-control" placeholder="same">
                            <xsl:attribute name="name" select="'contributor-expression-1'"/>
                        </input>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Contributor type <select/> -->
    <xsl:template name="select-contributor-type">
        <xsl:param name="contributor-types" required="yes"/>
        <xsl:param name="control-name" required="yes"/>
        <xsl:param name="selected-value" required="yes"/>
        <select class="form-control">
            <xsl:attribute name="name" select="$control-name"/>
            <xsl:for-each select="$contributor-types">
                <option>
                    <xsl:variable name="value" select="concat(@node-name, '-', @role)"/>
                    <xsl:attribute name="value" select="$value"/>
                    <xsl:if test="$value eq $selected-value">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="m:label/text()"/>
                </option>
            </xsl:for-each>
        </select>
    </xsl:template>
    
    <!-- Contributor <select/> -->
    <xsl:template name="select-contributor">
        <xsl:param name="contributor-id"/>
        <xsl:param name="control-name"/>
        <xsl:variable name="summary" select="/m:response/m:translation/m:translation/m:contributors/m:summary[1]"/>
        <xsl:variable name="translator-team-id" select="substring-after($summary/@ref, 'contributors.xml#')"/>
        <xsl:variable name="team-contributors" select="/m:response/m:contributor-persons/m:person[m:team[@id = $translator-team-id]]"/>
        <xsl:variable name="other-contributors" select="/m:response/m:contributor-persons/m:person[not(m:team[@id = $translator-team-id])]"/>
        <select class="form-control">
            <xsl:attribute name="name" select="$control-name"/>
            <option value=""/>
            <xsl:if test="$team-contributors">
                <xsl:for-each select="$team-contributors">
                    <option>
                        <xsl:attribute name="value" select="concat('contributors.xml#', @xml:id)"/>
                        <xsl:if test="@xml:id eq $contributor-id">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="m:sort-name"/>
                    </option>
                </xsl:for-each>
                <option value="">-</option>
            </xsl:if>
            <xsl:for-each select="$other-contributors">
                <option>
                    <xsl:attribute name="value" select="concat('contributors.xml#', @xml:id)"/>
                    <xsl:if test="@xml:id eq $contributor-id">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="m:sort-name"/>
                </option>
            </xsl:for-each>
        </select>
    </xsl:template>
    
    <!-- Translation status in a panel -->
    <xsl:template name="translation-status-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            <xsl:with-param name="type" select="'Status'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="publication-status-form">
                    <xsl:attribute name="action" select="'edit-text-header.html'"/>
                    
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="alert alert-warning small text-center">
                        <xsl:choose>
                            <xsl:when test="m:translation/@status eq '1'">
                                <p>Updating the version number will commit the new version to the <a href="https://github.com/84000/data/commits/master" target="github" class="alert-link">Github repository</a> and will generate new pdf and ebook files. This can take some time.</p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>Updating the version number will commit the new version to the <a href="https://github.com/84000/data/commits/master" target="github" class="alert-link">Github repository</a>.</p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    
                    <div class="row">
                        <!-- <div class="col-sm-12"> -->
                        <div class="col-sm-8">
                            <xsl:copy-of select="m:select-input('Translation Status', 'translation-status', 9, 1, m:text-statuses/m:status)"/>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="publication-date">
                                    <xsl:value-of select="'Publication Date'"/>
                                </label>
                                <div class="col-sm-4">
                                    <input type="date" name="publication-date" id="publication-date" class="form-control">
                                        <xsl:attribute name="value" select="m:translation/m:translation/m:publication-date"/>
                                        <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                            <xsl:attribute name="required" select="'required'"/>
                                        </xsl:if>
                                    </input>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="text-version">Version</label>
                                <div class="col-sm-2">
                                    <input type="text" name="text-version" id="text-version" class="form-control" placeholder="e.g. v 1.0">
                                        <xsl:attribute name="value" select="m:translation/m:translation/m:edition/text()"/>
                                        <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                            <xsl:attribute name="required" select="'required'"/>
                                        </xsl:if>
                                    </input>
                                </div>
                                <div class="col-sm-2">
                                    <input type="text" name="text-version-date" id="text-version-date" class="form-control" placeholder="e.g. 2019">
                                        <xsl:attribute name="value" select="m:translation/m:translation/m:edition/tei:date"/>
                                        <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                            <xsl:attribute name="required" select="'required'"/>
                                        </xsl:if>
                                    </input>
                                </div>
                            </div>
                            <!--  -->
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="progress-notes">
                                    <xsl:value-of select="'Awaiting action from:'"/>
                                </label>
                                <div class="col-sm-4">
                                    <input type="text" class="form-control" name="action-note" id="action-note" placeholder="e.g. Konchog">
                                        <xsl:attribute name="value" select="m:translation-status/m:action-note/text()"/>
                                    </input>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="progress-note">
                                    <xsl:value-of select="'Progress notes:'"/>
                                </label>
                                <div class="col-sm-9">
                                    <textarea class="form-control" rows="5" name="progress-note" id="progress-note" placeholder="Notes about the status of the translation...">
                                        <xsl:copy-of select="m:translation-status/m:progress-note/text()"/>
                                    </textarea>
                                    <xsl:if test="m:translation-status/m:progress-note/@last-edited">
                                        <div class="small text-muted margin-top-sm">
                                            <xsl:value-of select="common:date-user-string('Last updated', m:translation-status/m:progress-note/@last-edited, m:translation-status/m:progress-note/@last-edited-by)"/>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="text-note">
                                    <xsl:value-of select="'Text notes:'"/>
                                </label>
                                <div class="col-sm-9">
                                    <textarea class="form-control" rows="5" name="text-note" id="text-note" placeholder="Notes about the text itself...">
                                        <xsl:copy-of select="m:translation-status/m:text-note/text()"/>
                                    </textarea>
                                    <xsl:if test="m:translation-status/m:text-note/@last-edited">
                                        <div class="small text-muted margin-top-sm">
                                            <xsl:value-of select="common:date-user-string('Last updated', m:translation-status/m:text-note/@last-edited, m:translation-status/m:text-note/@last-edited-by)"/>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                        </div>
                        
                        <!--  -->
                        <div class="col-sm-4">
                            <h4 class="no-top-margin">
                                <xsl:choose>
                                    <xsl:when test="m:translation-status/m:task[not(@checked-off)][@added]">
                                        <xsl:attribute name="class" select="'no-top-margin text-danger'"/>
                                        <xsl:value-of select="'Current Tasks'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'No Current Tasks'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </h4>
                            <!-- This task/@id is in the history or in the current tasks -->
                            <xsl:variable name="task-ids-in-use" select="m:translation-status/m:task/@task-id"/>
                            <xsl:variable name="custom-task">
                                <m:task/>
                            </xsl:variable>
                            <div>
                                <xsl:for-each select="(m:translation-status/m:task[not(@checked-off)][@added] | m:publication-tasks/m:task | $custom-task)">
                                    <xsl:sort select="if(@added) then 0 else 1"/>
                                    <xsl:sort select="@added"/>
                                    <div class="pull-quote red-quote">
                                        <xsl:choose>
                                            <xsl:when test="@added and @xml:id">
                                                <div class="row">
                                                    <div class="col-sm-9 margin-top-sm">
                                                        <xsl:value-of select="text()"/>
                                                    </div>
                                                    <div class="col-sm-3">
                                                        <div class="checkbox">
                                                            <label class="small">
                                                                <input type="checkbox" name="task-check-off[]">
                                                                    <xsl:attribute name="value" select="@xml:id"/>
                                                                </input>
                                                                <xsl:value-of select="'Done'"/>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:variable name="id" select="if(@id) then @id else 'custom'"/>
                                                <xsl:variable name="label" select="if(@id) then text() else 'Custom task'"/>
                                                <div class="collapse">
                                                    <xsl:attribute name="id" select="concat('task-add-', $id)"/>
                                                    <input type="text" class="form-control">
                                                        <xsl:attribute name="name" select="concat('task-add-', $id)"/>
                                                        <xsl:attribute name="value" select="text()"/>
                                                        <xsl:attribute name="placeholder" select="$label"/>
                                                    </input>
                                                    <input type="checkbox" name="task-add[]" class="hidden">
                                                        <xsl:attribute name="value" select="$id"/>
                                                    </input>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </xsl:for-each>
                            </div>
                            <a href="#task-add" class="collapsed text-color small" role="button" data-toggle="collapse" aria-controls="task-add" aria-expanded="false">
                                <div class="center-vertical text-danger">
                                    <span>
                                        <i class="fa fa-chevron-down"/>
                                    </span>
                                    <span>
                                        <xsl:value-of select="'Add to current tasks'"/>
                                    </span>
                                </div>
                            </a>
                            <div class="collapse" id="task-add">
                                <p class="small text-muted">
                                    <xsl:value-of select="'After selecting a standard task you can modify its label with your own text, however the task remains linked to its type. If you want to add an entirely different task type please add a &#34;Custom task&#34;.'"/>
                                </p>
                                <ol class="small">
                                    <xsl:for-each select="m:publication-tasks/m:task | $custom-task">
                                        <xsl:variable name="id" select="if(@id) then @id else 'custom'"/>
                                        <xsl:variable name="label" select="if(@id) then text() else 'Custom task'"/>
                                        <li>
                                            <a data-toggle="collapse">
                                                <xsl:attribute name="href" select="concat('#task-add-', $id)"/>
                                                <xsl:variable name="onclick-set">
                                                    {<xsl:value-of select="concat('&#34;#task-add-',$id, ' input[type=\&#34;checkbox\&#34;]&#34; : &#34;toggle&#34;')"/>}
                                                </xsl:variable>
                                                <xsl:attribute name="data-onclick-set" select="normalize-space($onclick-set)"/>
                                                <span>
                                                    <xsl:if test="$id = $task-ids-in-use">
                                                        <xsl:attribute name="class" select="'line-through'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="$label"/>
                                                </span>
                                            </a>
                                        </li>
                                    </xsl:for-each>
                                </ol>
                            </div>
                            <xsl:variable name="history" select="(m:translation-status/m:status-update | m:translation-status/m:task[@checked-off])"/>
                            <xsl:if test="$history">
                                <hr class="sml-margin"/>
                                <h4 class="no-top-margin">
                                    <xsl:value-of select="'History'"/>
                                </h4>
                                <div class="max-height-220">
                                    <ul class="small list-unstyled">
                                        <xsl:for-each select="$history">
                                            <xsl:sort select="(./@date-time | ./@checked-off)" order="descending"/>
                                            <li>
                                                <xsl:choose>
                                                    <xsl:when test="@update eq 'text-version'">
                                                        <div class="text-bold">
                                                            <xsl:value-of select="concat('Version update - ', text())"/>
                                                        </div>
                                                        <div class="text-muted italic">
                                                            <xsl:value-of select="common:date-user-string('Set ', ./@date-time, ./@user)"/>
                                                        </div>
                                                    </xsl:when>
                                                    <xsl:when test="@update eq 'translation-status'">
                                                        <div class="text-bold">
                                                            <xsl:value-of select="concat('Status update - ', ./@value)"/>
                                                        </div>
                                                        <div class="text-muted italic">
                                                            <xsl:value-of select="common:date-user-string('Set ', ./@date-time, ./@user)"/>
                                                        </div>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <div class="text-bold">
                                                            <xsl:value-of select="text()"/>
                                                        </div>
                                                        <div class="text-muted italic">
                                                            <xsl:value-of select="common:date-user-string('Checked off ', ./@checked-off, ./@checked-off-by)"/>
                                                        </div>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </xsl:if>
                            
                        </div>
                    </div>
                    <hr/>
                    <div class="center-vertical full-width">
                        <span>
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:value-of select="'Update'"/>
                            </button>
                        </span>
                    </div>
                </form>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Sponsors form -->
    <xsl:template name="text-sponsors-form">
        <form method="post" class="form-horizontal form-update">
            <xsl:attribute name="action" select="'edit-text-sponsors.html'"/>
            <input type="hidden" name="post-id">
                <xsl:attribute name="value" select="m:translation/@id"/>
            </input>
            <div class="row">
                <div class="col-sm-8">
                    <xsl:copy-of select="m:select-input('Sponsorship Status', 'sponsorship-status', 9, 1, m:sponsorhip-statuses/m:status)"/>
                    <fieldset class="add-nodes-container">
                        <legend>
                            <xsl:value-of select="'Sponsors'"/>
                        </legend>
                        <xsl:choose>
                            <xsl:when test="m:translation/m:translation/m:sponsors/m:sponsor">
                                <xsl:call-template name="sponsors-controls">
                                    <xsl:with-param name="text-sponsors" select="m:translation/m:translation/m:sponsors/m:sponsor"/>
                                    <xsl:with-param name="all-sponsors" select="/m:response/m:sponsors/m:sponsor"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="sponsors-controls">
                                    <xsl:with-param name="text-sponsors">
                                        <m:sponsor ref="dummy"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="all-sponsors" select="/m:response/m:sponsors/m:sponsor"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div>
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">+</span>
                                <xsl:value-of select="'add a sponsor'"/>
                            </a>
                        </div>
                    </fieldset>
                </div>
                <div class="col-sm-4">
                    <div class="text-bold">
                        <xsl:value-of select="'Acknowledgment'"/>
                    </div>
                    <xsl:if test="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                        <xsl:apply-templates select="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                        <hr/>
                    </xsl:if>
                    <p class="small text-muted">
                        <xsl:value-of select="'If a sponsor is not automatically recognised in the acknowledgement text then please specify what they are &#34;expressed as&#34;. If a sponsor is already highlighted then you can leave this field blank.'"/>
                    </p>
                </div>
            </div>
            <hr/>
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <div class="pull-right">
                        <div class="center-vertical">
                            <span>
                                <a>
                                    <xsl:if test="not(/m:response/@model-type eq 'operations/edit-text-sponsors')">
                                        <xsl:attribute name="target" select="'operations'"/>
                                    </xsl:if>
                                    <xsl:attribute name="href" select="concat($operations-path, '/search.html?sponsored=sponsored')"/>
                                    <xsl:value-of select="'List of sponsored texts'"/>
                                </a>
                            </span>
                            <span>|</span>
                            <span>
                                <a>
                                    <xsl:if test="not(/m:response/@model-type eq 'operations/edit-text-sponsors')">
                                        <xsl:attribute name="target" select="'operations'"/>
                                    </xsl:if>
                                    <xsl:attribute name="href" select="concat($operations-path, '/edit-sponsor.html')"/>
                                    <xsl:value-of select="'Add a new sponsor'"/>
                                </a>
                            </span>
                            <span>|</span>
                            <span>
                                <button type="submit" class="btn btn-primary">
                                    <xsl:value-of select="'Save'"/>
                                </button>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </xsl:template>
    
    <!-- Sponsors row -->
    <xsl:template name="sponsors-controls">
        <xsl:param name="text-sponsors" required="yes"/>
        <xsl:param name="all-sponsors" required="yes"/>
        <xsl:for-each select="$text-sponsors">
            <xsl:variable name="id" select="substring-after(@ref, 'sponsors.xml#')"/>
            <div class="form-group add-nodes-group">
                <div class="col-sm-5">
                    <select class="form-control">
                        <xsl:attribute name="name" select="concat('sponsor-id-', position())"/>
                        <option value=""/>
                        <xsl:for-each select="$all-sponsors">
                            <option>
                                <xsl:attribute name="value" select="concat('sponsors.xml#', @xml:id)"/>
                                <xsl:if test="@xml:id eq $id">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="m:internal-name">
                                        <xsl:value-of select="concat(m:label, ' / ', m:internal-name)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="m:label"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <label class="control-label col-sm-2">
                    <xsl:value-of select="'expressed as:'"/>
                </label>
                <div class="col-sm-5">
                    <input class="form-control" placeholder="same">
                        <xsl:attribute name="name" select="concat('sponsor-expression-', position())"/>
                        <xsl:attribute name="value" select="text()"/>
                    </input>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <!-- <input type="text"/> -->
    <xsl:function name="m:text-input">
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
    <xsl:function name="m:text-multiple-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="values"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <xsl:for-each select="$values">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:copy-of select="m:text-input($label, concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="m:text-input('+', concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:copy-of select="m:text-input('+', concat($name, '-', (count($values) + 1)), '', $size, $css-class)"/>
    </xsl:function>
    
    <!-- <select/> -->
    <xsl:function name="m:select-input">
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
    <xsl:function name="m:select-input-name">
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
                    <option value=""/>
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
    
    <!-- Acknowledgements -->
    <xsl:template name="acknowledgements">
        <xsl:param name="acknowledgements" required="yes"/>
        <xsl:param name="group" as="xs:string" required="yes"/>
        <xsl:param name="css-class" as="xs:string" required="yes"/>
        <xsl:param name="link-href" as="xs:string" required="yes"/>
        <xsl:choose>
            <xsl:when test="$acknowledgements">
                <xsl:for-each select="$acknowledgements">
                    <xsl:sort select="xs:integer(m:toh/@number)"/>
                    <div>
                        <xsl:attribute name="class" select="$css-class"/>
                        <xsl:if test="$group gt ''">
                            <xsl:attribute name="data-match-height" select="concat('group-', $group)"/>
                        </xsl:if>
                        <div class="pull-quote">
                            <div class="title top-vertical full-width">
                                <a>
                                    <xsl:attribute name="href" select="replace($link-href, '@translation-id', @translation-id)"/>
                                    <xsl:value-of select="m:toh/m:full"/> / <xsl:value-of select="m:title"/>
                                </a>
                                <span>
                                    <xsl:copy-of select="common:translation-status(@translation-status)"/>
                                </span>
                            </div>
                            <xsl:apply-templates select="tei:div[@type eq 'acknowledgment']/*"/>
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
    
    <!-- Submissions panel prototype -->
    <xsl:template name="submissions-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            
            <xsl:with-param name="type" select="'Submissions'"/>
            <xsl:with-param name="active" select="$active"/>
            
            <xsl:with-param name="flag">
                <span class="badge badge-notification">
                    <xsl:value-of select="count(m:translation-status/m:submission)"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="form">
                
                <form method="post" enctype="multipart/form-data" class="form-horizontal form-update" id="submissions-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#submissions-form'"/>
                    
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="form-group">
                        <label for="submit-file" class="col-sm-3 control-label">
                            <xsl:value-of select="'Upload a translation file'"/>
                        </label>
                        <div class="col-sm-7">
                            <input type="file" name="submit-translation-file" id="submit-translation-file" class="form-control" required="required" accept="application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>
                        </div>
                        <div class="col-sm-2">
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:value-of select="'Submit'"/>
                            </button>
                        </div>
                    </div>
                </form>
                
                <xsl:for-each select="m:translation-status/m:submission">
                    <xsl:variable name="submission" select="."/>
                    <xsl:variable name="latest-document" select="common:index-of-node(/m:response/m:translation-status/m:submission[@file-type eq 'document'], $submission) eq 1"/>
                    <xsl:variable name="latest-spreadsheet" select="common:index-of-node(/m:response/m:translation-status/m:submission[@file-type eq 'spreadsheet'], $submission) eq 1"/>
                    <hr class="sml-margin"/>
                    <div class="row">
                        <div class="col-sm-8">
                            <a>
                                <xsl:attribute name="href" select="concat('/edit-text-submission.html?text-id=', /m:response/m:translation/@id,'&amp;submission-id=', $submission/@id)"/>
                                <xsl:value-of select="$submission/@file-name"/>
                            </a>
                        </div>
                        <div class="col-sm-4 text-right text-muted italic small">
                            <xsl:value-of select="common:date-user-string('Submited', $submission/@date-time, $submission/@user)"/>
                        </div>
                        <div class="col-sm-12">
                            <xsl:choose>
                                
                                <xsl:when test="$submission/@file-type eq 'spreadsheet'">
                                    <xsl:if test="$latest-spreadsheet">
                                        <span class="label label-success">
                                            <i class="fa fa-check"/>
                                            <xsl:value-of select="' Latest spreadsheet'"/>
                                        </span>
                                    </xsl:if>
                                    <xsl:for-each select="/m:response/m:submission-checklist/m:spreadsheet/m:item">
                                        <xsl:variable name="item" select="."/>
                                        <span class="label label-default">
                                            <xsl:if test="$submission/m:item-checked[@item-id eq $item/@id]">
                                                <xsl:if test="$latest-spreadsheet">
                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                </xsl:if>
                                                <i class="fa fa-check"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(' ', $item/text())"/>
                                        </span>
                                    </xsl:for-each>
                                </xsl:when>
                                
                                <xsl:when test="$submission/@file-type eq 'document'">
                                    <xsl:if test="$latest-document">
                                        <span class="label label-primary">
                                            <i class="fa fa-check"/>
                                            <xsl:value-of select="' Latest document'"/>
                                        </span> 
                                    </xsl:if>
                                    <xsl:for-each select="/m:response/m:submission-checklist/m:document/m:item">
                                        <xsl:variable name="item" select="."/>
                                        <span class="label label-default">
                                            <xsl:if test="$submission/m:item-checked[@item-id eq $item/@id]">
                                                <xsl:if test="$latest-document">
                                                    <xsl:attribute name="class" select="'label label-primary'"/>
                                                </xsl:if>
                                                <i class="fa fa-check"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(' ', $item/text())"/>
                                        </span>
                                    </xsl:for-each>
                                </xsl:when>
                            </xsl:choose>
                            
                            <span class="label label-default">
                                <xsl:if test="$submission/m:tei-file/@file-exists eq 'true'">
                                    <xsl:choose>
                                        <xsl:when test="$latest-spreadsheet">
                                            <xsl:attribute name="class" select="'label label-success'"/>
                                        </xsl:when>
                                        <xsl:when test="$latest-document">
                                            <xsl:attribute name="class" select="'label label-primary'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <i class="fa fa-check"/>
                                </xsl:if>
                                <xsl:value-of select="'Generate TEI'"/>
                            </span>
                            
                        </div>
                    </div>
                </xsl:for-each>
                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>