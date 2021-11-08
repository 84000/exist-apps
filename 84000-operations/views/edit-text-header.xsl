<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <xsl:variable name="text-id" select="m:translation/@id"/>
                    
                    <!-- Title / status -->
                    <div class="center-vertical full-width sml-margin bottom">

                        <div class="h3">
                            <a target="_blank">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.html')"/>
                                <xsl:value-of select="concat(string-join(m:translation/m:toh/m:full, ' / '), ' : ', m:translation/m:title)"/>
                            </a>
                        </div>
                        
                        <span class="text-right">
                            <xsl:sequence select="ops:translation-status(m:translation/@status-group)"/>
                        </span>
                        
                    </div>
                    
                    <!-- TEI -->
                    <div class="center-vertical full-width sml-margin bottom">
                        
                        <!-- url -->
                        <div>
                            <a class="text-muted small">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                <xsl:attribute name="target" select="concat($text-id, '.tei')"/>
                                <xsl:value-of select="concat('TEI file: ', m:translation/@document-url)"/>
                            </a>
                        </div>
                        
                        <!-- Version -->
                        <span class="text-right">
                            <a class="label label-info">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                <xsl:attribute name="target" select="concat($text-id, '.tei')"/>
                                <xsl:value-of select="concat('TEI VERSION: ', if(m:translation[@tei-version gt '']) then m:translation/@tei-version else '[none]')"/>
                            </a>
                        </span>
                        
                    </div>
                    
                    <!-- Due date -->
                    <xsl:variable name="next-target-date" select="m:translation-status/m:text[@status-surpassable eq 'true']/m:target-date[@next eq 'true'][1]"/>
                    <xsl:if test="$next-target-date">
                        <div class="center-vertical full-width sml-margin bottom">
                            
                            <span class="small">
                                <xsl:value-of select="'Target dates: '"/>
                            </span>
                            
                            <span class="text-right">
                                <xsl:choose>
                                    <xsl:when test="xs:integer($next-target-date/@due-days) ge 0">
                                        
                                        <span class="label label-success">
                                            <xsl:value-of select="'Due in '"/>
                                            <xsl:value-of select="$next-target-date/@due-days"/>
                                            <xsl:value-of select="' days'"/>
                                        </span>
                                        
                                    </xsl:when>
                                    <xsl:when test="xs:integer($next-target-date/@due-days) lt 0">
                                        
                                        <span class="label label-danger">
                                            <xsl:value-of select="'Overdue '"/>
                                            <xsl:value-of select="abs($next-target-date/@due-days)"/>
                                            <xsl:value-of select="' days'"/>
                                        </span>
                                        
                                    </xsl:when>
                                </xsl:choose>
                            </span>
                            
                        </div>
                    </xsl:if>
                    
                    <!-- Files -->
                    <xsl:if test="m:translation/@status-group eq 'published'">
                        
                        <!-- Downloads -->
                        <div>
                            <xsl:for-each select="m:translation/m:downloads">
                                
                                <!-- Status flags -->
                                <div class="center-vertical full-width sml-margin bottom">
                                    
                                    <xsl:variable name="downloads" select="."/>
                                    <xsl:variable name="resource-id" select="$downloads/@resource-id"/>
                                    <xsl:variable name="tei-version" select="$downloads/@tei-version"/>
                                    
                                    <span class="small">
                                        <xsl:value-of select="concat('Associated files for ', /m:response/m:translation/m:toh[@key eq $resource-id]/m:full, ': ')"/>
                                    </span>
                                    
                                    <span class="text-right">
                                        
                                        <xsl:for-each select="('cache', 'pdf', 'epub', 'azw3', 'rdf')">
                                            
                                            <xsl:variable name="download-type" select="."/>
                                            <xsl:variable name="download" select="$downloads/m:download[@type eq $download-type]"/>
                                            
                                            <a>
                                                
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="concat($reading-room-path, $download/@url)"/>
                                                </xsl:attribute>
                                                
                                                <xsl:attribute name="target">
                                                    <xsl:value-of select="$download/@url"/>
                                                </xsl:attribute>
                                                
                                                <xsl:attribute name="class">
                                                    <xsl:choose>
                                                        <xsl:when test="$download/@version eq $tei-version">
                                                            <xsl:value-of select="'label label-info'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'label label-danger'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$download/@version eq $tei-version">
                                                        <i class="fa fa-check"/>
                                                        <xsl:value-of select="' '"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <i class="fa fa-exclamation-circle"/>
                                                        <xsl:value-of select="' '"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                                <xsl:value-of select="concat(upper-case($download/@type), ': ', $download/@version)"/>
                                                
                                            </a>
                                            
                                        </xsl:for-each>
                                        
                                    </span>
                                    
                                </div>
                            </xsl:for-each>
                        </div>
                        
                        <xsl:variable name="files-outdated" select="m:translation/m:downloads/m:download[not(@version = ../@tei-version)]"/>
                        <xsl:variable name="cache-outdated" select="$files-outdated[@type eq 'cache']"/>
                        <xsl:variable name="master-store" select="$environment/m:store-conf[@type eq 'master']"/>
                        <xsl:if test="$cache-outdated or ($master-store and $files-outdated)">
                            <div class="sml-margin bottom text-right">
                                <ul class="list-inline inline-dots">
                                    <xsl:if test="$cache-outdated">
                                        <li>
                                            <a class="small">
                                                <xsl:attribute name="href" select="concat('edit-glossary.html?resource-id=', $text-id)"/>
                                                <xsl:value-of select="'Generate new cache (glossary tool)'"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                    <xsl:if test="$master-store">
                                        <li>
                                            <a class="small">
                                                <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $text-id, '&amp;form-action=generate-files')"/>
                                                <xsl:attribute name="data-loading" select="'Generating files...'"/>
                                                <xsl:value-of select="'Generate new associated files'"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                </ul>
                            </div>
                        </xsl:if>
                        
                    </xsl:if>
                    
                    <div class="list-group accordion accordion-background" role="tablist" aria-multiselectable="true" id="forms-accordion">
                        
                        <xsl:call-template name="titles-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'titles') then true() else false()"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="source-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'source') then true() else false()"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="contributors-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'contributors') then true() else false()"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="submissions-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'submissions') then true() else false()"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="translation-status-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'translation-status') then true() else false()"/>
                        </xsl:call-template>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat(string-join(m:translation/m:toh/m:full, ' / '), ' | Text header | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Editing headers for text: ', string-join(m:translation/m:toh/m:full, ' / '))"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Titles form -->
    <xsl:template name="titles-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'titles'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                <span class="h4">
                    <xsl:value-of select="'Titles'"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="content">
                <form method="post" class="form-horizontal labels-left labels-light form-update top-margin" id="titles-form" data-loading="Updating titles...">
                    <xsl:attribute name="action" select="'edit-text-header.html'"/>
                    
                    <input type="hidden" name="form-action" value="update-titles"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    <input type="hidden" name="form-expand" value="titles"/>
                    
                    <!-- Titles -->
                    <div class="add-nodes-container">
                        <xsl:choose>
                            <xsl:when test="m:translation/m:titles/m:title">
                                <xsl:for-each select="m:translation/m:titles/m:title">
                                    <xsl:call-template name="title-controls">
                                        <xsl:with-param name="title" select="."/>
                                        <xsl:with-param name="title-index" select="position()"/>
                                        <xsl:with-param name="title-types" select="/m:response/m:title-types/m:title-type"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="title-controls">
                                    <xsl:with-param name="title" select="()"/>
                                    <xsl:with-param name="title-index" select="1"/>
                                    <xsl:with-param name="title-types" select="/m:response/m:title-types/m:title-type"/>
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
                    
                    <!-- Title notes -->
                    <h5>
                        <xsl:value-of select="'Title note(s)'"/>
                    </h5>
                    <div class="add-nodes-container">
                        
                        <xsl:choose>
                            <xsl:when test="m:translation/m:titles/m:note">
                                <xsl:for-each select="m:translation/m:titles/m:note">
                                    <xsl:call-template name="title-note">
                                        <xsl:with-param name="index" select="position()"/>
                                        <xsl:with-param name="note" select="."/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="title-note">
                                    <xsl:with-param name="index" select="1"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <div>
                            <a href="#add-nodes" class="add-nodes">
                                <span class="monospace">
                                    <xsl:value-of select="'+'"/>
                                </span>
                                <xsl:value-of select="' add a note'"/>
                            </a>
                        </div>
                        
                    </div>
                    
                    <div class="form-group">
                        <div class="col-sm-12">
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:value-of select="'Save'"/>
                            </button>
                        </div>
                    </div>
                    
                </form>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="title-note">
        
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="note" as="element(m:note)?"/>
        
        <div class="form-group add-nodes-group">
            <div class="col-sm-2">
                <select class="form-control">
                    <xsl:attribute name="name" select="concat('titles-note-type-', $index)"/>
                    <option value="public">
                        <xsl:if test="$note[@type eq 'title']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Public'"/>
                    </option>
                    <option value="internal">
                        <xsl:if test="$note[@type eq 'title-internal']">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Internal'"/>
                    </option>
                </select>
            </div>
            <div class="col-sm-10">
                <input class="form-control">
                    <xsl:attribute name="name" select="concat('titles-note-text-', $index)"/>
                    <xsl:attribute name="value" select="$note/text()"/>
                    <xsl:attribute name="placeholder" select="'e.g. In the Pedurma this text is also known as...'"/>
                </input>
            </div>
        </div>
        
    </xsl:template>
    
    <!-- Contributors form -->
    <xsl:template name="contributors-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'contributors'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                <span class="h4">
                    <xsl:value-of select="'Contributors'"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="content">
                
                <xsl:variable name="summary" select="/m:response/m:translation/m:publication/m:contributors/m:summary[1]"/>
                <xsl:variable name="translator-team-id" select="lower-case(replace($summary/@ref, '^(eft:|contributors\.xml#)', '', 'i'))"/>
                
                <form method="post" class="form-horizontal form-update labels-left top-margin" id="contributors-form" data-loading="Updating contributors...">
                    
                    <xsl:attribute name="action" select="'edit-text-header.html#contributors-form'"/>
                    
                    <input type="hidden" name="form-action" value="update-contributors"/>
                    
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="row">
                        <div class="col-sm-8">
                            
                            <div class="form-group">
                                <label class="control-label col-sm-3">
                                    <xsl:value-of select="'Translator Team'"/>
                                </label>
                                <div class="col-sm-9">
                                    <select class="form-control">
                                        <xsl:attribute name="name" select="'translator-team-id'"/>
                                        <option value="">
                                            <xsl:value-of select="'[none]'"/>
                                        </option>
                                        <xsl:for-each select="/m:response/m:contributor-teams/m:team">
                                            <option>
                                                <xsl:attribute name="value" select="@xml:id"/>
                                                <xsl:if test="@xml:id eq $translator-team-id">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="m:label/text()"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="add-nodes-container top-margin">
                                
                                <xsl:variable name="team-contributors" select="/m:response/m:contributor-persons/m:person[m:team[@id = $translator-team-id]]"/>
                                <xsl:variable name="other-contributors" select="/m:response/m:contributor-persons/m:person[not(m:team[@id = $translator-team-id])]"/>
                                
                                <xsl:call-template name="contributors-controls">
                                    <xsl:with-param name="text-contributors" select="m:translation/m:publication/m:contributors/m:*[self::m:author | self::m:editor | self::m:consultant]"/>
                                    <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type[@type eq 'translation']"/>
                                    <xsl:with-param name="team-contributors" select="$team-contributors"/>
                                    <xsl:with-param name="other-contributors" select="$other-contributors"/>
                                </xsl:call-template>
                                
                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span> add a contributor </a>
                                </div>
                                
                            </div>
                        </div>
                        <div class="col-sm-4">
                            
                            <div class="text-bold">
                                <xsl:value-of select="'Attribution'"/>
                            </div>
                            <xsl:choose>
                                <xsl:when test="m:translation/m:publication/m:contributors/m:summary">
                                    <xsl:for-each select="m:translation/m:publication/m:contributors/m:summary">
                                        <p>
                                            <xsl:apply-templates select="node()"/>
                                        </p>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <p class="text-muted italic">
                                        <xsl:value-of select="'No attribution text in the TEI'"/>
                                    </p>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <hr class="sml-margin"/>
                            
                            <div class="text-bold">
                                <xsl:value-of select="'Acknowledgments'"/>
                            </div>
                            <xsl:choose>
                                <xsl:when test="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p">
                                    <xsl:apply-templates select="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <p class="text-muted italic">
                                        <xsl:value-of select="'No acknowledgment text in the TEI'"/>
                                    </p>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </div>
                    </div>
                    <xsl:if test="m:translation/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p">
                        <hr class="sml-margin"/>
                        <div>
                            <p class="small text-muted">
                                <xsl:value-of select="'If a contributor is not automatically recognised in the acknowledgement text then please specify how they are expressed (their &#34;expression&#34;). If a contributor is already highlighted then you can leave this field blank.'"/>
                            </p>
                        </div>
                    </xsl:if>
                    <hr class="sml-margin"/>
                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-10">
                            <div class="pull-right">
                                <div class="center-vertical">
                                    <span>
                                        <a>
                                            <xsl:if test="not(/m:response/@model eq 'operations/edit-text-sponsors')">
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
        <xsl:param name="team-contributors" as="element(m:person)*"/>
        <xsl:param name="other-contributors" as="element(m:person)*"/>
        
        <xsl:choose>
            <xsl:when test="$text-contributors">
                <xsl:for-each select="$text-contributors">
                    
                    <xsl:sort select="common:index-of-node($contributor-types, $contributor-types[@node-name eq xs:string(local-name(current()))][@role eq current()/@role])" order="ascending"/>
                    
                    <xsl:variable name="contributor-id" select="lower-case(replace(@ref, '^(eft:|contributors\.xml#)', '', 'i'))"/>
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
                                <xsl:with-param name="team-contributors" select="$team-contributors"/>
                                <xsl:with-param name="other-contributors" select="$other-contributors"/>
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
            </xsl:when>
            <xsl:otherwise>
                <!-- No existing contributors so show an set of controls -->
                <div class="form-group add-nodes-group">
                    
                    <div class="col-sm-3">
                        <xsl:call-template name="select-contributor-type">
                            <xsl:with-param name="contributor-types" select="$contributor-types"/>
                            <xsl:with-param name="control-name" select="'contributor-type-1'"/>
                            <xsl:with-param name="selected-value" select="''"/>
                        </xsl:call-template>
                    </div>
                    
                    <div class="col-sm-3">
                        <xsl:call-template name="select-contributor">
                            <xsl:with-param name="control-name" select="'contributor-id-1'"/>
                            <xsl:with-param name="contributor-id" select="''"/>
                            <xsl:with-param name="team-contributors" select="$team-contributors"/>
                            <xsl:with-param name="other-contributors" select="$other-contributors"/>
                        </xsl:call-template>
                    </div>
                    
                    <label class="control-label col-sm-2">
                        <xsl:value-of select="'expression:'"/>
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
        
        <xsl:param name="contributor-id" as="xs:string?"/>
        <xsl:param name="control-name" as="xs:string"/>
        <xsl:param name="team-contributors" as="element(m:person)*"/>
        <xsl:param name="other-contributors" as="element(m:person)*"/>
        
        <select class="form-control">
            <xsl:attribute name="name" select="$control-name"/>
            <option value="">
                <xsl:value-of select="'[none]'"/>
            </option>
            <xsl:if test="$team-contributors">
                <xsl:for-each select="$team-contributors">
                    <option>
                        <xsl:attribute name="value" select="@xml:id"/>
                        <xsl:if test="@xml:id eq $contributor-id">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="m:label/text()"/>
                    </option>
                </xsl:for-each>
                <option value="">-</option>
            </xsl:if>
            <xsl:for-each select="$other-contributors">
                <option>
                    <xsl:attribute name="value" select="@xml:id"/>
                    <xsl:if test="@xml:id eq $contributor-id">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="m:label/text()"/>
                </option>
            </xsl:for-each>
        </select>
        
    </xsl:template>
    
    <!-- Translation status form -->
    <xsl:template name="translation-status-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'translation-status'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                <span class="h4">
                    <xsl:value-of select="'Translation project status'"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="content">
                
                <form method="post" class="form-horizontal form-update top-margin" id="publication-status-form" data-loading="Updating status...">
                    <xsl:attribute name="action" select="'edit-text-header.html'"/>
                    <input type="hidden" name="form-action" value="update-publication-status"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="alert alert-warning small text-center">
                        <p>
                            <xsl:value-of select="'Updating the version number will commit the new version to the '"/>
                            <a target="_blank" class="alert-link">
                                <xsl:attribute name="href" select="concat('https://github.com/84000/data-tei/commits/master/', substring-after(m:translation/@document-url, concat(/m:response/@data-path, '/tei/')))"/>
                                <xsl:value-of select="'Github repository'"/>
                            </a>
                            <xsl:value-of select="'. '"/>
                            <xsl:if test="m:translation/@status eq '1'">
                                <xsl:value-of select="'Associated files (pdfs, ebooks) will be generated for published texts. This can take some time.'"/>
                            </xsl:if>
                        </p>
                    </div>
                    
                    <div class="row">
                        
                        <!-- Form -->
                        <div class="col-sm-8 match-this-height" data-match-height="status-form">
                            
                            <!--Contract details-->
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="contract-number">
                                    <xsl:value-of select="'Contract number:'"/>
                                </label>
                                <div class="col-sm-3">
                                    <input type="text" name="contract-number" id="contract-number" class="form-control" placeholder="">
                                        <xsl:attribute name="value" select="normalize-space(m:translation-status/m:text/m:contract/@number)"/>
                                    </input>
                                </div>
                                <label class="control-label col-sm-3" for="contract-date">
                                    <xsl:value-of select="'Contract date:'"/>
                                </label>
                                <div class="col-sm-3">
                                    <input type="date" name="contract-date" id="contract-date" class="form-control">
                                        <xsl:attribute name="value" select="m:translation-status/m:text/m:contract/@date"/>
                                    </input>
                                </div>
                            </div>
                            
                            <!--Translation Status-->
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="translation-status">
                                    <xsl:value-of select="'Translation Status:'"/>
                                </label>
                                <div class="col-sm-9">
                                    <select class="form-control" name="translation-status" id="translation-status">
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
                                    <xsl:value-of select="'Publication Date:'"/>
                                </label>
                                <div class="col-sm-3">
                                    <input type="date" name="publication-date" id="publication-date" class="form-control">
                                        <xsl:attribute name="value" select="m:translation/m:publication/m:publication-date"/>
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
                                                <xsl:when test="m:translation/m:publication/m:edition/text()[1]/normalize-space()">
                                                    <xsl:value-of select="m:translation/m:publication/m:edition/text()[1]/normalize-space()"/>
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
                                                <xsl:when test="m:translation/m:publication/m:edition/tei:date/text()/normalize-space()">
                                                    <xsl:value-of select="m:translation/m:publication/m:edition/tei:date/text()/normalize-space()"/>
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
                                <div class="col-sm-5">
                                    <input type="text" name="update-notes" id="update-notes" class="form-control" placeholder="Add a note about this version"/>
                                </div>
                            </div>
                            
                            <!-- Action note -->
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="progress-notes">
                                    <xsl:value-of select="'Awaiting action from:'"/>
                                </label>
                                <div class="col-sm-3">
                                    <input type="text" class="form-control" name="action-note" id="action-note" placeholder="e.g. Konchog">
                                        <xsl:attribute name="value" select="normalize-space(m:translation-status/m:text/m:action-note)"/>
                                    </input>
                                </div>
                            </div>
                            
                            <!-- Progress note -->
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="progress-note">
                                    <xsl:value-of select="'Progress notes:'"/>
                                </label>
                                <div class="col-sm-9">
                                    <textarea class="form-control" rows="4" name="progress-note" id="progress-note" placeholder="Notes about the status of the translation...">
                                        <xsl:copy-of select="normalize-space(m:translation-status/m:text/m:progress-note)"/>
                                    </textarea>
                                    <xsl:if test="m:translation-status/m:text/m:progress-note/@last-edited">
                                        <div class="small text-muted sml-margin top">
                                            <xsl:value-of select="common:date-user-string('Last updated', m:translation-status/m:text/m:progress-note/@last-edited, m:translation-status/m:text/m:progress-note/@last-edited-by)"/>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                            
                            <!-- Text note -->
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="text-note">
                                    <xsl:value-of select="'Text notes:'"/>
                                </label>
                                <div class="col-sm-9">
                                    <textarea class="form-control" rows="4" name="text-note" id="text-note" placeholder="Notes about the text itself...">
                                        <xsl:copy-of select="normalize-space(m:translation-status/m:text/m:text-note)"/>
                                    </textarea>
                                    <xsl:if test="m:translation-status/m:text/m:text-note/@last-edited">
                                        <div class="small text-muted sml-margin top">
                                            <xsl:value-of select="common:date-user-string('Last updated', m:translation-status/m:text/m:text-note/@last-edited, m:translation-status/m:text/m:text-note/@last-edited-by)"/>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                            
                            <!-- Target dates -->
                            <xsl:variable name="target-dates" select="m:translation-status/m:text/m:target-date"/>
                            <xsl:variable name="actual-dates" select="m:translation/m:status-updates/m:status-update[@update eq 'translation-status']"/>
                            <div class="form-group">
                                <label class="control-label col-sm-3 top-margin" for="text-note">
                                    <xsl:value-of select="'Target dates:'"/>
                                </label>
                                <div class="col-sm-9 tests">
                                    <table class="table table-responsive table-icons no-border">
                                        <thead>
                                            <tr>
                                                <th>
                                                    <xsl:value-of select="'Status'"/>
                                                </th>
                                                <th>
                                                    <xsl:value-of select="'Target date'"/>
                                                </th>
                                                <th colspan="2">
                                                    <xsl:value-of select="'Actual date'"/>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="m:text-statuses/m:status[@target-date eq 'true']">
                                                
                                                <xsl:variable name="status-id" select="@status-id"/>
                                                <xsl:variable name="status-surpassed" select="@selected eq 'selected' or preceding-sibling::m:status[@selected eq 'selected']"/>
                                                <xsl:variable name="target-date" select="$target-dates[@status-id eq $status-id][1]"/>
                                                
                                                <xsl:variable name="actual-date" select="if($status-surpassed) then $actual-dates[@value eq $status-id][last()] else ()"/>
                                                <xsl:variable name="target-date-hit" select="($target-date[@date-time] and $actual-date[@date-time] and xs:dateTime($target-date/@date-time) ge xs:dateTime($actual-date/@date-time))"/>
                                                <xsl:variable name="target-date-miss" select="($target-date[@date-time] and (xs:dateTime($target-date/@date-time) lt current-dateTime()) or ($actual-date[@date-time] and xs:dateTime($target-date/@date-time) lt xs:dateTime($actual-date/@date-time)))"/>
                                                
                                                <tr>
                                                    <td class="small">
                                                        <xsl:if test="$status-surpassed">
                                                            <xsl:attribute name="class" select="'text-muted'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="common:limit-str(concat($status-id, ' / ', text()), 28)"/>
                                                    </td>
                                                    <td>
                                                        <input type="date" class="form-control">
                                                            <xsl:attribute name="name" select="concat('target-date-', @index)"/>
                                                            <xsl:if test="$target-date">
                                                                <xsl:attribute name="value" select="format-dateTime($target-date/@date-time, '[Y]-[M01]-[D01]')"/>
                                                            </xsl:if>
                                                            <xsl:if test="$status-surpassed">
                                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                                            </xsl:if>
                                                        </input>
                                                    </td>
                                                    <td class="icon">
                                                        <xsl:choose>
                                                            <xsl:when test="$target-date-hit">
                                                                <i class="fa fa-check-circle"/>
                                                            </xsl:when>
                                                            <xsl:when test="$target-date-miss">
                                                                <i class="fa fa-times-circle"/>
                                                            </xsl:when>
                                                            <xsl:when test="$target-date[@next eq 'true']">
                                                                <i class="fa fa-exclamation-circle"/>
                                                            </xsl:when>
                                                            <xsl:when test="$status-surpassed">
                                                                <i class="fa fa-question-circle"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </td>
                                                    <td class="small">
                                                        <xsl:choose>
                                                            <xsl:when test="$actual-date[@date-time]">
                                                                <xsl:value-of select="format-dateTime($actual-date/@date-time, '[D01] [MNn,*-3] [Y]')"/>
                                                            </xsl:when>
                                                            <xsl:when test="$target-date[@next eq 'true']">
                                                                <xsl:choose>
                                                                    <xsl:when test="xs:integer($target-date/@due-days) ge 0">
                                                                        <xsl:value-of select="'Due in '"/>
                                                                        <xsl:value-of select="$target-date/@due-days"/>
                                                                        <xsl:value-of select="' days'"/>
                                                                    </xsl:when>
                                                                    <xsl:when test="xs:integer($target-date/@due-days) lt 0">
                                                                        <xsl:value-of select="'Overdue '"/>
                                                                        <xsl:value-of select="abs($target-date/@due-days)"/>
                                                                        <xsl:value-of select="' days'"/>
                                                                    </xsl:when>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                        </div>
                        
                        <!-- History -->
                        <div class="col-sm-4">
                            
                            <xsl:apply-templates select="m:translation/m:status-updates"/>
                            
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
    
    <!-- Submissions form -->
    <xsl:template name="submissions-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'submissions'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>
            
            <xsl:with-param name="title">
                <span class="h4">
                    <xsl:value-of select="'Submissions '"/>
                    <span class="badge badge-notification">
                        <xsl:value-of select="count(m:translation-status/m:text/m:submission)"/>
                    </span>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="content">
                
                <xsl:for-each select="m:translation-status/m:text/m:submission">
                    
                    <xsl:variable name="submission" select="."/>
                    
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
                                    <xsl:if test="$submission/@latest eq 'true'">
                                        <span class="label label-success">
                                            <i class="fa fa-check"/>
                                            <xsl:value-of select="' Latest spreadsheet'"/>
                                        </span>
                                    </xsl:if>
                                    <xsl:for-each select="/m:response/m:submission-checklist/m:spreadsheet/m:item">
                                        <xsl:variable name="item" select="."/>
                                        <span class="label label-default">
                                            <xsl:if test="$submission/m:item-checked[@item-id eq $item/@id]">
                                                <xsl:if test="$submission/@latest eq 'true'">
                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                </xsl:if>
                                                <i class="fa fa-check"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(' ', $item/text())"/>
                                        </span>
                                    </xsl:for-each>
                                </xsl:when>
                                
                                <xsl:when test="$submission/@file-type eq 'document'">
                                    <xsl:if test="$submission/@latest eq 'true'">
                                        <span class="label label-primary">
                                            <i class="fa fa-check"/>
                                            <xsl:value-of select="' Latest document'"/>
                                        </span> 
                                    </xsl:if>
                                    <xsl:for-each select="/m:response/m:submission-checklist/m:document/m:item">
                                        <xsl:variable name="item" select="."/>
                                        <span class="label label-default">
                                            <xsl:if test="$submission/m:item-checked[@item-id eq $item/@id]">
                                                <xsl:if test="$submission/@latest eq 'true'">
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
                                        <xsl:when test="$submission/@latest eq 'true' and $submission/@file-type eq 'spreadsheet'">
                                            <xsl:attribute name="class" select="'label label-success'"/>
                                        </xsl:when>
                                        <xsl:when test="$submission/@latest eq 'true' and $submission/@file-type eq 'document'">
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
                
                <hr class="sml-margin"/>
                
                <form method="post" enctype="multipart/form-data" class="form-horizontal form-update labels-left" id="submissions-form" data-loading="Uploading submission...">
                    
                    <xsl:attribute name="action" select="'edit-text-header.html#submissions-form'"/>
                    
                    <input type="hidden" name="form-action" value="process-upload"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="form-group">
                        <div class="col-sm-10">
                            <input type="file" name="submit-translation-file" id="submit-translation-file" required="required" accept=".doc,.docx,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>
                        </div>
                        <div class="col-sm-2">
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:value-of select="'Upload a file'"/>
                            </button>
                        </div>
                    </div>
                    
                </form>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Source form -->
    <xsl:template name="source-form-panel">
        
        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
            
            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'source'"/>
            <xsl:with-param name="active" select="$active"/>
            
            <xsl:with-param name="title">
                <span class="h4">
                    <xsl:value-of select="'Source'"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="content">
                
                <form method="post" class="form-horizontal labels-left labels-light form-update" id="locations-form" data-loading="Updating source...">
                    
                    <xsl:attribute name="action" select="'edit-text-header.html#locations-form'"/>
                    
                    <input type="hidden" name="form-action" value="update-source"/>
                    
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <xsl:for-each select="m:translation/m:source">
                        
                        <xsl:variable name="toh-key" select="@key"/>
                        <xsl:variable name="toh-location" select="m:location"/>
                        
                        <input type="hidden">
                            <xsl:attribute name="name" select="concat('work-', $toh-key)"/>
                            <xsl:attribute name="value" select="$toh-location/@work"/>
                        </input>
                        
                        <input type="hidden">
                            <xsl:attribute name="name" select="concat('location-', $toh-key)"/>
                            <xsl:attribute name="value" select="$toh-key"/>
                        </input>
                        
                        <fieldset>
                            
                            <legend>
                                <xsl:value-of select="m:toh"/>
                            </legend>
                            
                            <div class="add-nodes-container bottom-margin">
                                <xsl:variable name="attributions" select="m:attribution"/>
                                <xsl:variable name="attribution-entities" as="element(m:entity)*">
                                    <xsl:for-each select="/m:response/m:attribution-entities/m:entity">
                                        <xsl:sort select="m:label[not(@derived) and not(@derived-transliterated)][1] ! lower-case(.)"/>
                                        <xsl:sequence select="."/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="$attributions">
                                        <xsl:for-each select="$attributions">
                                            <xsl:call-template name="attribution-controls">
                                                <xsl:with-param name="attribution" select="."/>
                                                <xsl:with-param name="attribution-index" select="common:index-of-node($attributions, .)"/>
                                                <xsl:with-param name="toh-key" select="$toh-key"/>
                                                <xsl:with-param name="attribution-entities" select="$attribution-entities"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="attribution-controls">
                                            <xsl:with-param name="attribution-index" select="1"/>
                                            <xsl:with-param name="toh-key" select="$toh-key"/>
                                            <xsl:with-param name="attribution-entities" select="$attribution-entities"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span> add an attribution </a>
                                </div>
                            </div>
                            
                            <hr/>
                            
                            <div class="add-nodes-container">
                                <h4>
                                    <xsl:value-of select="concat('Location in the Degé ', if($toh-location/@work eq 'UT4CZ5369') then 'Kangyur' else 'Tengyur')"/>
                                </h4>
                                <xsl:for-each select="$toh-location/m:volume">
                                    <div class="row add-nodes-group">
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="ops:text-input('Volume: ', concat('volume-', $toh-key, '-', position()), @number, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="ops:text-input('First page: ', concat('start-page-', $toh-key, '-', position()), @start-page, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="ops:text-input('Last page: ', concat('end-page-', $toh-key, '-', position()), @end-page, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="ops:text-input('Count: ', concat('count-pages-', $toh-key, '-', position()), sum(@end-page - (@start-page - 1)), 6, 'disabled')"/>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                
                                <div class="row">
                                    <div class="col-sm-3 sml-margin top">
                                        <a href="#add-nodes" class="add-nodes">
                                            <span class="monospace">+</span> add a volume </a>
                                    </div>
                                    <div class="col-sm-6 sml-margin top">
                                        <xsl:variable name="sum-volume-pages" select="sum($toh-location/m:volume ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1))) ! xs:integer(.)"/>
                                        <xsl:if test="$sum-volume-pages ne xs:integer($toh-location/@count-pages)">
                                            <div class="text-right">
                                                <span class="label label-danger">
                                                    <xsl:value-of select="concat('The sum of the above pages is ', $sum-volume-pages)"/>
                                                </span>
                                            </div>
                                        </xsl:if>
                                    </div>
                                    <div class="col-sm-3">
                                        <xsl:copy-of select="ops:text-input('Total pages: ', concat('count-pages-', $toh-key), $toh-location/@count-pages, 6, 'required')"/>
                                    </div>
                                </div>
                                
                            </div>
                            
                        </fieldset>
                        
                    </xsl:for-each>
                    
                    <div class="pull-right">
                        <button type="submit" class="btn btn-primary">
                            <xsl:value-of select="'Save'"/>
                        </button>
                    </div>
                    
                </form>
            </xsl:with-param>
        
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Attribution row -->
    <xsl:template name="attribution-controls">
        
        <xsl:param name="attribution" as="element(m:attribution)?"/>
        <xsl:param name="attribution-index" as="xs:integer"/>
        <xsl:param name="toh-key" as="xs:string"/>
        <xsl:param name="attribution-entities" as="element(m:entity)*"/>
        
        <xsl:variable name="attribution-entity-id" select="$attribution/@ref ! replace(., '^eft:', '')"/>
        
        <div class="row add-nodes-group sml-margin bottom">
            
            <input type="hidden">
                <xsl:attribute name="name" select="concat('attribution-revision-', $toh-key, '-', $attribution-index)"/>
                <xsl:attribute name="value" select="$attribution/@revision"/>
            </input>
            
            <input type="hidden">
                <xsl:attribute name="name" select="concat('attribution-key-', $toh-key, '-', $attribution-index)"/>
                <xsl:attribute name="value" select="$attribution/@key"/>
            </input>
            
            <div class="col-sm-3">
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-role-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Attribution role:'"/>
                </label>
                <xsl:call-template name="select-attribution-role">
                    <xsl:with-param name="selected-value" select="$attribution/@role"/>
                    <xsl:with-param name="control-name" select="concat('attribution-role-', $toh-key, '-', $attribution-index)"/>
                </xsl:call-template>
            </div>
            
            <div class="col-sm-3">
                
                <xsl:variable name="entity" select="/m:response/m:attribution-entities/m:entity/id($attribution-entity-id)"/>
                <xsl:variable name="kb-id" select="$entity/m:instance/m:page/@kb-id"/>
                <xsl:variable name="glossary-id" select="$entity/m:instance/m:entry/@id"/>
                
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-entity-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Entity:'"/>
                </label>
                
                <xsl:if test="$entity">
                    
                    <ul class="list-inline inline-dots small add-nodes-remove">

                        <li>
                            <xsl:choose>
                                <xsl:when test="$kb-id">
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', $kb-id, '.html')"/>
                                        <xsl:attribute name="target" select="$kb-id"/>
                                        <xsl:value-of select="'Knowledge base'"/>
                                    </a>
                                    <xsl:value-of select="' '"/>
                                    <span>
                                        <xsl:choose>
                                            <xsl:when test="$entity/m:instance/m:page/@status-group eq 'published'">
                                                <xsl:attribute name="class" select="'label label-success'"/>
                                            </xsl:when>
                                            <xsl:when test="$entity/m:instance/m:page/@status-group eq 'in-progress'">
                                                <xsl:attribute name="class" select="'label label-warning'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="class" select="'label label-default'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:value-of select="if($entity/m:instance/m:page/@status) then $entity/m:instance/m:page/@status else '0'"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="/knowledgebase.html#new-article-form">
                                        <xsl:value-of select="'Add to knowledge base'"/>
                                    </a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                        
                        <xsl:if test="$glossary-id">
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/glossary.html?entity-id=', $entity/@xml:id)"/>
                                    <xsl:attribute name="target" select="'84000-glossary'"/>
                                    <xsl:value-of select="'Glossary'"/>
                                </a>
                            </li>
                        </xsl:if>
                        
                    </ul>
                    
                </xsl:if>
                
                <select class="form-control">
                    <xsl:attribute name="name" select="concat('attribution-entity-', $toh-key, '-', $attribution-index)"/>
                    <xsl:attribute name="id" select="concat('attribution-entity-', $toh-key, '-', $attribution-index)"/>
                    <option>
                        <xsl:attribute name="value" select="''"/>
                        <xsl:value-of select="'[No entity]'"/>
                    </option>
                    <option>
                        <xsl:attribute name="value" select="'create-entity-for-expression'"/>
                        <xsl:value-of select="'[Create an entity for expression]'"/>
                    </option>
                    <xsl:for-each select="$attribution-entities">
                        <option>
                            <xsl:attribute name="value" select="@xml:id"/>
                            <xsl:if test="@xml:id eq $attribution-entity-id">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="m:label[not(@derived) and not(@derived-transliterated)][1]"/>
                        </option>
                    </xsl:for-each>
                </select>
                
            </div>
            
            <div class="col-sm-4">
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-expression-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Expression in this text:'"/>
                </label>
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="concat('attribution-expression-', $toh-key, '-', $attribution-index)"/>
                    <xsl:attribute name="id" select="concat('attribution-expression-', $toh-key, '-', $attribution-index)"/>
                    <xsl:attribute name="value" select="text()"/>
                </input>
            </div>
            
            <div class="col-sm-2">
                <label class="control-label">
                    <xsl:attribute name="for" select="concat('attribution-lang-', $toh-key, '-', $attribution-index)"/>
                    <xsl:value-of select="'Expr. lang.:'"/>
                </label>
                <xsl:call-template name="select-language">
                    <xsl:with-param name="input-id" select="concat('attribution-lang-', $toh-key, '-', $attribution-index)"/>
                    <xsl:with-param name="input-name" select="concat('attribution-lang-', $toh-key, '-', $attribution-index)"/>
                    <xsl:with-param name="language-options" select="('','en','Bo-Ltn','Sa-Ltn')"/>
                    <xsl:with-param name="selected-language" select="@xml:lang"/>
                </xsl:call-template>
            </div>
            
        </div>
        
    </xsl:template>
    
    <!-- Attribution role <select/> -->
    <xsl:template name="select-attribution-role">
        <xsl:param name="control-name" required="yes"/>
        <xsl:param name="selected-value" required="yes"/>
        <select class="form-control">
            
            <xsl:attribute name="name" select="$control-name"/>
            <xsl:attribute name="id" select="$control-name"/>
            
            <option value="">
                <xsl:value-of select="'[No role]'"/>
            </option>
            
            <option value="author">
                <xsl:if test="$selected-value eq 'author'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Author'"/>
            </option>
            
            <option value="translator">
                <xsl:if test="$selected-value eq 'translator'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Translator'"/>
            </option>
            
            <option value="reviser">
                <xsl:if test="$selected-value eq 'reviser'">
                    <xsl:attribute name="selected" select="'selected'"/>
                </xsl:if>
                <xsl:value-of select="'Reviser'"/>
            </option>
            
        </select>
    </xsl:template>
    
</xsl:stylesheet>