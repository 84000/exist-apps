<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:include href="functions.xsl"/>
    
    <xsl:template name="alert-updated">
        <xsl:if test="m:updates/m:updated">
            <div class="alert alert-success alert-temporary" role="alert">
                Updated
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="alert-translation-locked">
        <xsl:if test="m:translation/@locked-by-user gt ''">
            <div class="alert alert-danger" role="alert">
                <xsl:value-of select="concat('File ', m:translation/@document-url, ' is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                You cannot modify this file until the lock is released.
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="titles-form-panel">
        <div class="panel panel-default no-shadow">
            <div class="panel-heading" role="tab" id="panelHeadingTitles">
                <a role="button" data-toggle="collapse" href="#panelTitles" aria-expanded="false" aria-controls="panelTitles" data-parent="#forms-accordion">
                    <h3 class="panel-title">
                        Titles
                    </h3>
                </a>
            </div>
            <div id="panelTitles" class="panel-collapse collapse" role="tabpanel" aria-labelledby="panelHeadingTitles">
                <div class="panel-body">
                    <form method="post" class="form-horizontal" id="titles-form">
                        
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
                                    <span class="monospace">+</span> add a title
                                </a>
                            </div>
                        </div>
                        
                        <div class="pull-right">
                            <button type="submit" class="btn btn-primary">Save</button>
                        </div>
                        
                    </form>
                </div>
            </div>
        </div>
    </xsl:template>
    
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
    
    <xsl:template name="locations-form-panel">
        <div class="panel panel-default no-shadow">
            <div class="panel-heading" role="tab" id="panelHeadingLocations">
                <a role="button" data-toggle="collapse" href="#panelLocations" aria-expanded="false" aria-controls="panelTitles" data-parent="#forms-accordion">
                    <h3 class="panel-title">
                        Locations
                    </h3>
                </a>
            </div>
            <div id="panelLocations" class="panel-collapse collapse" role="tabpanel" aria-labelledby="panelHeadingLocations">
                <div class="panel-body">
                    <form method="post" class="form-horizontal" id="locations-form">
                        
                        <xsl:attribute name="action" select="'edit-text-header.html#locations-form'"/>
                        
                        <input type="hidden" name="post-id">
                            <xsl:attribute name="value" select="m:translation/@id"/>
                        </input>
                        
                        <xsl:call-template name="locations-controls">
                            <xsl:with-param name="tohs" select="m:translation/m:toh"/>
                        </xsl:call-template>
                        
                        <div class="pull-right">
                            <button type="submit" class="btn btn-primary">Save</button>
                        </div>
                        
                    </form>
                </div>
            </div>
        </div>
    </xsl:template>
    
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
                        <xsl:copy-of select="m:text-input('Start volume',concat('start-volume-', $toh-key), $toh-location/m:start/@volume, 6, 'required')"/>
                        <xsl:copy-of select="m:text-input('Start page',concat('start-page-', $toh-key), $toh-location/m:start/@page, 6, 'required')"/>
                    </div>
                    <div class="col-sm-4">
                        <xsl:copy-of select="m:text-input('End volume',concat('end-volume-', $toh-key), $toh-location/m:end/@volume, 6, 'required')"/>
                        <xsl:copy-of select="m:text-input('End page',concat('end-page-', $toh-key), $toh-location/m:end/@page, 6, 'required')"/>
                    </div>
                    <div class="col-sm-4">
                        <xsl:copy-of select="m:text-input('Count pages',concat('count-pages-', $toh-key), $toh-location/@count-pages, 6, 'required')"/>
                    </div>
                </div>
            </fieldset>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="contributors-form-panel">
        <div class="panel panel-default no-shadow">
            <div class="panel-heading" role="tab" id="panelHeadingContributors">
                <a role="button" data-toggle="collapse" href="#panelContributors" aria-expanded="false" aria-controls="panelTitles" data-parent="#forms-accordion">
                    <h3 class="panel-title">
                        Contributors
                    </h3>
                </a>
            </div>
            <div id="panelContributors" class="panel-collapse collapse" role="tabpanel" aria-labelledby="panelHeadingContributors">
                <div class="panel-body">
                    <form method="post" class="form-horizontal" id="contributors-form">
                        
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
                                        Translator Team
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
                                
                                <div class="add-nodes-container">
                                    <xsl:variable name="contributors" select="m:translation/m:translation/m:contributors/m:author | m:translation/m:translation/m:contributors/m:editor | m:translation/m:translation/m:contributors/m:consultant"/>
                                    <xsl:choose>
                                        <xsl:when test="$contributors">
                                            <xsl:call-template name="contributors-controls">
                                                <xsl:with-param name="text-contributors" select="$contributors"/>
                                                <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="contributors-controls">
                                                <xsl:with-param name="text-contributors">
                                                    <m:author sameAs="dummy"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <div>
                                        <a href="#add-nodes" class="add-nodes">
                                            <span class="monospace">+</span> add a contributor
                                        </a>
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
                                    <hr/>
                                </xsl:if>
                                
                                <xsl:if test="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p">
                                    <div class="text-bold">Acknowledgment</div>
                                    <xsl:apply-templates select="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                    <hr/>
                                </xsl:if>
                                
                                <p class="small text-muted">
                                    If a sponsor or a translator is not automatically recognised in the acknowledgement text then please specify what they are "expressed as". If a sponsor or a translator is already highlighted then you can leave this field blank.
                                </p>
                                
                            </div>
                        </div>
                        
                        <hr/>
                        
                        <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                                <div class="pull-right">
                                    <div class="center-vertical">
                                        <span>
                                            <a href="/edit-translator.html">
                                                Enter a new contributor
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
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="contributors-controls">
        
        <xsl:param name="text-contributors" required="yes"/>
        <xsl:param name="contributor-types" required="yes"/>
        
        <xsl:for-each select="$text-contributors">
            <xsl:variable name="contributor-id" select="substring-after(@sameAs, 'contributors.xml#')"/>
            <xsl:variable name="contributor-type" select="concat(node-name(.), '-', @role)"/>
            <xsl:variable name="index" select="position()"/>
            <div class="form-group add-nodes-group">
                <div class="col-sm-2">
                    <select class="form-control">
                        <xsl:attribute name="name" select="concat('contributor-type-', $index)"/>
                        <xsl:for-each select="$contributor-types">
                            <option>
                                <xsl:variable name="value" select="concat(@node-name, '-', @role)"/>
                                <xsl:attribute name="value" select="$value"/>
                                <xsl:if test="$value eq $contributor-type">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:value-of select="m:label/text()"/>
                            </option>
                        </xsl:for-each>
                    </select>
                </div>
                <div class="col-sm-4">
                    <xsl:call-template name="select-contributor">
                        <xsl:with-param name="contributor-id" select="$contributor-id"/>
                        <xsl:with-param name="control-name" select="concat('contributor-id-', $index)"/>
                    </xsl:call-template>
                </div>
                <label class="control-label col-sm-2">
                    expressed as:
                </label>
                <div class="col-sm-4">
                    <input class="form-control" placeholder="same">
                        <xsl:attribute name="name" select="concat('contributor-expression-', $index)"/>
                        <xsl:attribute name="value" select="text()"/>
                    </input>
                </div>
            </div>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="select-contributor">
        
        <xsl:param name="contributor-id" required="yes"/>
        <xsl:param name="control-name" required="yes"/>
        
        <xsl:variable name="summary" select="/m:response/m:translation/m:translation/m:contributors/m:summary[1]"/>
        <xsl:variable name="translator-team-id" select="substring-after($summary/@sameAs, 'contributors.xml#')"/>
        <xsl:variable name="team-contributors" select="/m:response/m:contributor-persons/m:person[$translator-team-id = m:team/@id]"/>
        <xsl:variable name="other-contributors" select="/m:response/m:contributor-persons/m:person[not($translator-team-id = m:team/@id)]"/>
        
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
    
    <xsl:template name="translation-status-form-panel">
        <div class="panel panel-default no-shadow">
            <div class="panel-heading" role="tab" id="panelHeadingStatus">
                <a role="button" data-toggle="collapse" href="#panelStatus" aria-expanded="false" aria-controls="panelTitles" data-parent="#forms-accordion">
                    <h3 class="panel-title">
                        Status
                    </h3>
                </a>
            </div>
            <div id="panelStatus" class="panel-collapse collapse" role="tabpanel" aria-labelledby="panelHeadingStatus">
                <div class="panel-body">
                    <form method="post" class="form-horizontal" id="publication-status-form">
                        
                        <xsl:attribute name="action" select="'edit-text-header.html#publication-status-form'"/>
                        
                        <input type="hidden" name="post-id">
                            <xsl:attribute name="value" select="m:translation/@id"/>
                        </input>
                        
                        <div class="row">
                            <div class="col-sm-8">
                                
                                <xsl:copy-of select="m:select-input('Translation Status', 'translation-status', 9, 1, m:text-statuses/m:status)"/>
                                
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="publication-date">Publication Date</label>
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
                                    <label class="control-label col-sm-3" for="status-notes">Notes:</label>
                                    <div class="col-sm-9">
                                        <textarea class="form-control" rows="12" name="status-notes" id="status-notes" placeholder="Notes about the current status of the text...">
                                            <xsl:copy-of select="m:translation-status/m:notes/text()"/>
                                        </textarea>
                                        <xsl:if test="m:translation-status/m:notes/@last-edited">
                                            <div class="small text-muted margin-top-sm">
                                                <xsl:value-of select="common:date-user-string('Last updated', m:translation-status/m:notes/@last-edited, m:translation-status/m:notes/@last-edited-by)"/>
                                            </div>
                                        </xsl:if>
                                    </div>
                                </div>
                                
                            </div>
                            
                            <div class="col-sm-4">
                                
                                <h4 class="no-top-margin text-danger">Task list</h4>
                                <xsl:for-each select="m:translation-status/m:task[not(@hidden)][not(@checked-off)][@added]">
                                    <xsl:sort select="@added"/>
                                    <div class="small text-muted margin-top-sm">
                                        <xsl:value-of select="common:date-user-string('Added', @added, @added-by)"/>
                                    </div>
                                    <div class="row">
                                        <div class="col-sm-9">
                                            <p class="margin-top-sm pull-quote">
                                                <xsl:value-of select="text()"/>
                                            </p>
                                        </div>
                                        <div class="col-sm-3">
                                            <div class="checkbox">
                                                <label class="small">
                                                    <input type="checkbox" name="task-check-off[]">
                                                        <xsl:attribute name="value" select="@xml:id"/>
                                                    </input> Done
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                
                                <div class="form-group margin-top-sm">
                                    <label for="new-task" class="sr-only">New task</label>
                                    <div class="col-sm-12">
                                        <input type="text" name="new-task" id="new-task" class="form-control" placeholder="New task"/>
                                    </div>
                                </div>
                                
                                <h4>Recently done</h4>
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
                                                    </input> Hide
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                
                                <xsl:if test="m:translation-status/m:task[@hidden]">
                                    
                                    <hr class="sml-margin"/>
                                    <h4>
                                        <a href="#hidden-tasks" class="collapsed text-color" role="button" data-toggle="collapse" aria-controls="hidden-tasks" aria-expanded="false">
                                            <i class="fa fa-chevron-down"/> Hidden tasks
                                        </a>
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
                                <button type="submit" class="btn btn-primary pull-right">Update</button>
                            </span>
                            
                        </div>
                        
                    </form>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="sponsors-form">
        <form method="post" class="form-horizontal">
            
            <xsl:attribute name="action" select="'edit-text-sponsors.html'"/>
            
            <input type="hidden" name="post-id">
                <xsl:attribute name="value" select="m:translation/@id"/>
            </input>
            
            <div class="row">
                <div class="col-sm-8">
                    
                    <xsl:copy-of select="m:select-input('Sponsorship Status', 'sponsorship-status', 9, 1, m:sponsorhip-statuses/m:status)"/>
                    
                    <fieldset class="add-nodes-container">
                        <legend>
                            Sponsors
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
                                <span class="monospace">+</span> add a sponsor
                            </a>
                        </div>
                    </fieldset>
                    
                </div>
                <div class="col-sm-4">
                    <div class="text-bold">Acknowledgment</div>
                    <xsl:if test="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                        <xsl:apply-templates select="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                        <hr/>
                    </xsl:if>
                    <p class="small text-muted">
                        If a sponsor is not automatically recognised in the acknowledgement text then please specify what they are "expressed as". If a sponsor is already highlighted then you can leave this field blank.
                    </p>
                </div>
            </div>
            
            <hr/>
            
            <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                    <div class="pull-right">
                        <div class="center-vertical">
                            <span>
                                <a href="/search.html?sponsored=sponsored">
                                    List of sponsored texts
                                </a>
                            </span>
                            <span>|</span>
                            <span>
                                <a href="/edit-sponsor.html">
                                    Add a new sponsor
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
    </xsl:template>
    
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
                    expressed as:
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
                        <xsl:variable name="text" select="if(m:name | m:label) then (m:name | m:label)[1] else text()"/>
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
    
</xsl:stylesheet>