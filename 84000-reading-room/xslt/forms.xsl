<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    <xsl:import href="tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
    
    <!-- Generic alert -->
    <xsl:template name="alert-updated">
        <xsl:if test="m:updates/m:updated">
            <div class="alert alert-success alert-temporary" role="alert">
                <xsl:value-of select="'Updated'"/>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- Alert if translation is locked -->
    <xsl:template name="alert-translation-locked">
        <xsl:if test="m:translation/@locked-by-user gt ''">
            <div class="alert alert-danger" role="alert">
                <xsl:value-of select="concat('File ', m:translation/@document-url, ' is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                <xsl:value-of select="'You cannot modify this file until the lock is released.'"/>
            </div>
        </xsl:if>
    </xsl:template>
    
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
                                        <m:title sameAs="dummy"/>
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
    
    <!-- location row -->
    <xsl:template name="locations-controls">
        <xsl:param name="tohs" required="yes"/>
        <xsl:for-each select="$tohs">
            <xsl:variable name="toh-key" select="@key"/>
            <xsl:variable name="toh-location" select="/m:response/m:translation/m:location[@key eq $toh-key]"/>
            <input type="hidden">
                <xsl:attribute name="name" select="concat('location-', $toh-key)"/>
                <xsl:attribute name="value" select="$toh-key"/>
            </input>
            <fieldset>
                <legend>
                    <xsl:value-of select="concat('Toh ', m:base)"/>
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
                            <xsl:variable name="translator-summary" select="m:translation/m:translation/m:contributors/m:summary[1]"/>
                            <xsl:variable name="translator-team-id" select="substring-after($translator-summary/@sameAs, 'contributors.xml#')"/>
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
                            <!-- Force user to add group first -->
                            <xsl:if test="$translator-summary">
                                <div class="add-nodes-container">
                                    <xsl:variable name="contributors" select="m:translation/m:translation/m:contributors/m:*[self::m:author | self::m:editor | self::m:consultant]"/>
                                    <xsl:choose>
                                        <xsl:when test="$contributors">
                                            <xsl:call-template name="contributors-controls">
                                                <xsl:with-param name="text-contributors" select="$contributors"/>
                                                <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="contributors-controls">
                                                <!-- use the summary as a dummy author record -->
                                                <xsl:with-param name="text-contributors" select="$translator-summary"/>
                                                <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <div>
                                        <a href="#add-nodes" class="add-nodes">
                                            <span class="monospace">+</span> add a contributor </a>
                                    </div>
                                </div>
                            </xsl:if>
                        </div>
                        <div class="col-sm-4">
                            <xsl:if test="m:translation/m:translation/m:contributors/m:summary">
                                <div class="text-bold">Attribution</div>
                                <xsl:for-each select="m:translation/m:translation/m:contributors/m:summary">
                                    <p>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                                <hr/>
                            </xsl:if>
                            <xsl:if test="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p">
                                <div class="text-bold">
                                    <xsl:value-of select="'Acknowledgment'"/>
                                </div>
                                <xsl:apply-templates select="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                <hr/>
                            </xsl:if>
                            <p class="small text-muted"> If a sponsor or a translator is not automatically recognised in the acknowledgement text then please specify what they are "expressed as". If a
                                sponsor or a translator is already highlighted then you can leave this field blank. </p>
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
        <xsl:for-each select="$contributor-types">
            <xsl:variable name="contributor-types-node-name" select="@node-name"/>
            <xsl:variable name="contributor-types-role" select="@role"/>
            <xsl:for-each select="$text-contributors[xs:string(node-name(.)) eq $contributor-types-node-name][xs:string(@role) eq $contributor-types-role]">
                <xsl:variable name="contributor-id" select="substring-after(./@sameAs, 'contributors.xml#')"/>
                <xsl:variable name="contributor-type" select="concat(node-name(.), '-', @role)"/>
                <xsl:variable name="index" select="common:index-of-node($text-contributors, .)"/>
                <div class="form-group add-nodes-group">
                    <div class="col-sm-2">
                        <xsl:call-template name="select-contributor-type">
                            <xsl:with-param name="contributor-types" select="$contributor-types"/>
                            <xsl:with-param name="control-name" select="concat('contributor-type-', $index)"/>
                            <xsl:with-param name="selected-value" select="$contributor-type"/>
                        </xsl:call-template>
                    </div>
                    <div class="col-sm-4">
                        <xsl:call-template name="select-contributor">
                            <xsl:with-param name="contributor-id" select="$contributor-id"/>
                            <xsl:with-param name="control-name" select="concat('contributor-id-', $index)"/>
                        </xsl:call-template>
                    </div>
                    <label class="control-label col-sm-2">
                        <xsl:value-of select="'expressed as:'"/>
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
        <xsl:variable name="translator-team-id" select="substring-after($summary/@sameAs, 'contributors.xml#')"/>
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
                    <div class="row">
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
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="progress-notes">
                                    <xsl:value-of select="'Awaiting action from:'"/>
                                </label>
                                <div class="col-sm-3">
                                    <input type="text" class="form-control" name="action-note" id="action-note" placeholder="e.g. Konchog">
                                        <xsl:attribute name="value" select="m:translation-status/m:action-note/text()"/>
                                    </input>
                                </div>
                                <div class="col-sm-6 small text-muted margin-top-sm">
                                    <xsl:if test="m:translation-status/m:action-note/@last-edited">
                                        <xsl:value-of select="common:date-user-string('Last updated', m:translation-status/m:action-note/@last-edited, m:translation-status/m:action-note/@last-edited-by)"/>
                                    </xsl:if>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="progress-note">Progress notes:</label>
                                <div class="col-sm-9">
                                    <textarea class="form-control" rows="6" name="progress-note" id="progress-note" placeholder="Notes about the status of the translation...">
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
                                    <textarea class="form-control" rows="6" name="text-note" id="text-note" placeholder="Notes about the text itself...">
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
                        <div class="col-sm-4">
                            <h4 class="no-top-margin text-danger">
                                <xsl:value-of select="'Task list'"/>
                            </h4>
                            <xsl:for-each select="m:translation-status/m:task[not(@hidden)][not(@checked-off)][@added]">
                                <xsl:sort select="@added"/>
                                <div class="small text-muted margin-top-sm">
                                    <xsl:value-of select="common:date-user-string('Added', @added, @added-by)"/>
                                </div>
                                <div class="row">
                                    <div class="col-sm-9">
                                        <p class="margin-top-sm pull-quote red-quote">
                                            <xsl:value-of select="text()"/>
                                        </p>
                                    </div>
                                    <div class="col-sm-3">
                                        <div class="checkbox">
                                            <label class="small">
                                                <input type="checkbox" name="task-check-off[]">
                                                    <xsl:attribute name="value" select="@xml:id"/>
                                                </input> Done </label>
                                        </div>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <div class="form-group margin-top-sm">
                                <label for="new-task" class="sr-only">
                                    <xsl:value-of select="'New task'"/>
                                </label>
                                <div class="col-sm-12">
                                    <input type="text" name="new-task" id="new-task" class="form-control" placeholder="New task"/>
                                </div>
                            </div>
                            <xsl:if test="m:translation-status/m:task[not(@hidden)][@checked-off]">
                                <h4>
                                    <xsl:value-of select="'Recently done'"/>
                                </h4>
                                <xsl:for-each select="m:translation-status/m:task[not(@hidden)][@checked-off]">
                                    <xsl:sort select="@checked-off" order="descending"/>
                                    <div class="small text-muted">
                                        <xsl:value-of select="common:date-user-string('Marked done', @checked-off, @checked-off-by)"/>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-9">
                                            <p class="line-through text-muted margin-top-sm pull-quote">
                                                <xsl:value-of select="text()"/>
                                            </p>
                                        </div>
                                        <div class="col-sm-3">
                                            <div class="checkbox">
                                                <label class="small">
                                                    <input type="checkbox" name="task-hide[]">
                                                        <xsl:attribute name="value" select="@xml:id"/>
                                                    </input> Hide </label>
                                            </div>
                                        </div>
                                    </div>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:if test="m:translation-status/m:task[@hidden]">
                                <hr class="sml-margin"/>
                                <h4>
                                    <a href="#hidden-tasks" class="collapsed text-color" role="button" data-toggle="collapse" aria-controls="hidden-tasks" aria-expanded="false">
                                        <i class="fa fa-chevron-down"/> Hidden tasks </a>
                                </h4>
                                <div class="collapse" id="hidden-tasks">
                                    <xsl:for-each select="m:translation-status/m:task[@hidden]">
                                        <xsl:sort select="@hidden" order="descending"/>
                                        <div class="small text-muted">
                                            <xsl:value-of select="common:date-user-string('Hidden', @hidden, @hidden-by)"/>
                                        </div>
                                        <div class="row">
                                            <div class="col-sm-12">
                                                <p class="line-through text-muted margin-top-sm pull-quote">
                                                    <xsl:value-of select="text()"/>
                                                </p>
                                            </div>
                                        </div>
                                    </xsl:for-each>
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
    <xsl:template name="sponsors-form">
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
                                        <m:sponsor sameAs="dummy"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="all-sponsors" select="/m:response/m:sponsors/m:sponsor"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div>
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">+</span> add a sponsor </a>
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
                    <p class="small text-muted"> If a sponsor is not automatically recognised in the acknowledgement text then please specify what they are "expressed as". If a sponsor is already
                        highlighted then you can leave this field blank. </p>
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
            <xsl:variable name="id" select="substring-after(@sameAs, 'sponsors.xml#')"/>
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
                        <xsl:variable name="text" select="                                 if (m:name | m:label) then                                     (m:name | m:label)[1]                                 else                                     text()"/>
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
    </xsl:template>
    
    <!-- Submissions panel prototype -->
    <xsl:template name="submissions-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            
            <xsl:with-param name="type" select="'Submissions'"/>
            <xsl:with-param name="active" select="$active"/>
            
            <xsl:with-param name="flag">
                <span class="badge badge-notification">
                    <xsl:value-of select="'3'"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="form">
                <div class="alert alert-warning small text-center">
                    "Generate TEI" will create or overwrite the toh1-1.tei files in the translation or glossary folders in 84000-import-data. These must then be copy/pasted into the correct TEI file.
                </div>
                <div class="row">
                    <div class="col-sm-3 text-muted small italic">
                        Uploaded 14th Jan 2019 17:17 by admin
                    </div>
                    <div class="col-sm-5">
                        1. Tohoku 1-1 final draft.docx
                    </div>
                    <div class="col-sm-2 text-right">
                        <a href="#" class="underline small">
                            Download
                        </a>
                    </div>
                    <div class="col-sm-2 text-right">
                        <a href="#" class="underline small">
                            Generate TEI
                        </a>
                    </div>
                </div>
                <hr class="sml-margin"/>
                <div class="row">
                    <div class="col-sm-3 text-muted small italic">
                        Uploaded 14th Jan 2019 18:15 by admin
                    </div>
                    <div class="col-sm-5">
                        2. Tohoku 1-1 final glossary.xls
                        <span class="text-muted small italic">
                            - latest spreadsheed
                        </span>
                    </div>
                    <div class="col-sm-2 text-right">
                        <a href="#" class="underline small">
                            Download
                        </a>
                    </div>
                    <div class="col-sm-2 text-right">
                        <a href="#" class="underline small">
                            Generate TEI
                        </a>
                    </div>
                </div>
                <hr class="sml-margin"/>
                <div class="row">
                    <div class="col-sm-3 text-muted small italic">
                        Uploaded 1st Feb 2019 09:15 by admin
                    </div>
                    <div class="col-sm-5">
                        3. Tohoku 1-1 final draft(1).docx
                        <span class="text-muted small italic">
                            - latest document
                        </span>
                    </div>
                    <div class="col-sm-2 text-right">
                        <a href="#" class="underline small">
                            Download
                        </a>
                    </div>
                    <div class="col-sm-2 text-right">
                        <a href="#" class="underline small">
                            Generate TEI
                        </a>
                    </div>
                </div>
                <hr class="sml-margin"/>
                <form method="post" class="form-horizontal form-update" id="submissions-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#submissions-form'"/>
                    
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="form-group">
                        <label for="submit-file" class="col-sm-3 control-label">Upload a translation file</label>
                        <div class="col-sm-7">
                            <input type="file" id="submit-file" class="form-control" accept=".doc,.docx,.xls"/>
                        </div>
                        <div class="col-sm-2">
                            <button type="submit" class="btn btn-primary pull-right">Submit</button>
                        </div>
                    </div>
                </form>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>