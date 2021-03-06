<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
    
    <!-- Accordion panel -->
    <xsl:template name="panel">
        <xsl:param name="type" required="yes"/>
        <xsl:param name="title" required="yes"/>
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
            <xsl:with-param name="title" select="'Titles'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="titles-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#titles-form'"/>
                    <input type="hidden" name="form-action" value="update-titles"/>
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
                        <div class="form-group">
                            <div class="col-sm-12">
                                <a href="#add-nodes" class="add-nodes">
                                    <span class="monospace">
                                        <xsl:value-of select="'+'"/>
                                    </span>
                                    <xsl:value-of select="' add a title'"/>
                                </a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <div class="col-sm-12">
                            <div class="center-vertical full-width">
                                <div>
                                    <p class="text-muted">
                                        <xsl:value-of select="'* Standard hyphens can be added to Sanskrit strings and will be converted to soft-hyphens when saved'"/>
                                    </p>
                                </div>
                                <div>
                                    <button type="submit" class="btn btn-primary pull-right">
                                        <xsl:value-of select="'Save'"/>
                                    </button>
                                </div>
                            </div>
                        </div>
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
    
    <!-- Locations in a panel -->
    <xsl:template name="locations-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            <xsl:with-param name="type" select="'Locations'"/>
            <xsl:with-param name="title" select="'Locations'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="locations-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#locations-form'"/>
                    <input type="hidden" name="form-action" value="update-locations"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    <xsl:for-each select="m:translation/m:toh">
                        <xsl:variable name="toh-key" select="./@key"/>
                        <xsl:variable name="toh-location" select="/m:response/m:translation/m:location[@key eq $toh-key][1]"/>
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
                                <xsl:value-of select="concat('Toh ', ./m:base)"/>
                            </legend>
                            <div class="add-nodes-container">
                                <xsl:for-each select="$toh-location/m:volume">
                                    <div class="row add-nodes-group">
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="m:text-input('Volume: ', concat('volume-', $toh-key, '-', position()), @number, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="m:text-input('First page: ', concat('start-page-', $toh-key, '-', position()), @start-page, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="m:text-input('Last page: ', concat('end-page-', $toh-key, '-', position()), @end-page, 6, 'required')"/>
                                        </div>
                                        <div class="col-sm-3">
                                            <xsl:copy-of select="m:text-input('Count: ', concat('count-pages-', $toh-key, '-', position()), sum(@end-page - (@start-page - 1)), 6, 'disabled')"/>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span> add a volume </a>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-9">
                                    <xsl:variable name="sum-volume-pages" select="sum($toh-location/m:volume ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1))) ! xs:integer(.)"/>
                                    <xsl:if test="$sum-volume-pages ne xs:integer($toh-location/@count-pages)">
                                        <div class="text-danger text-right sml-margin top">
                                            <xsl:value-of select="concat('The sum of the volumes is ', $sum-volume-pages)"/>
                                        </div>
                                    </xsl:if>
                                </div>
                                <div class="col-sm-3">
                                    <xsl:copy-of select="m:text-input('Page count: ', concat('count-pages-', $toh-key), $toh-location/@count-pages, 6, 'required')"/>
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
    
    <!-- Contributors in a panel -->
    <xsl:template name="contributors-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            <xsl:with-param name="type" select="'Contributors'"/>
            <xsl:with-param name="title" select="'Contributors'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="contributors-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#contributors-form'"/>
                    <input type="hidden" name="form-action" value="update-contributors"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="row">
                        <div class="col-sm-8">
                            <xsl:variable name="translator-team-id" select="substring-after(m:translation/m:publication/m:contributors/m:summary[1]/@ref, 'contributors.xml#')"/>
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
                            <hr class="sml-margin"/>
                            <div class="add-nodes-container">
                                <xsl:call-template name="contributors-controls">
                                    <xsl:with-param name="text-contributors" select="m:translation/m:publication/m:contributors/m:*[self::m:author | self::m:editor | self::m:consultant]"/>
                                    <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type"/>
                                </xsl:call-template>
                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span> add a contributor </a>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <xsl:if test="m:translation/m:publication/m:contributors/m:summary">
                                <div class="text-bold">Attribution</div>
                                <xsl:for-each select="m:translation/m:publication/m:contributors/m:summary">
                                    <p>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </xsl:if>
                            <hr class="sml-margin"/>
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
                
                <xsl:for-each select="$text-contributors">
                    <xsl:sort select="common:index-of-node($contributor-types, $contributor-types[@node-name eq xs:string(local-name(current()))][@role eq current()/@role])" order="ascending"/>
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
        <xsl:variable name="summary" select="/m:response/m:translation/m:publication/m:contributors/m:summary[1]"/>
        <xsl:variable name="translator-team-id" select="substring-after($summary/@ref, 'contributors.xml#')"/>
        <xsl:variable name="team-contributors" select="/m:response/m:contributor-persons/m:person[m:team[@id = $translator-team-id]]"/>
        <xsl:variable name="other-contributors" select="/m:response/m:contributor-persons/m:person[not(m:team[@id = $translator-team-id])]"/>
        <select class="form-control">
            <xsl:attribute name="name" select="$control-name"/>
            <option value="">
                <xsl:value-of select="'[none]'"/>
            </option>
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
            <xsl:with-param name="type" select="'PublicationStatus'"/>
            <xsl:with-param name="title" select="'Publication Status'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="form">
                <form method="post" class="form-horizontal form-update" id="publication-status-form">
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
                        
                        <div class="col-sm-4">
                            
                            <!-- History -->
                            <xsl:if test="m:translation/m:status-updates/m:status-update[@date-time]">
                                
                                <div class="match-height-overflow" data-match-height="status-form">
                                    <h4 class="no-top-margin no-bottom-margin">
                                        <xsl:value-of select="'History'"/>
                                    </h4>
                                    <hr class="sml-margin"/>
                                    <ul class="small list-unstyled">
                                        <xsl:for-each select="m:translation/m:status-updates/m:status-update[@date-time]">
                                            <xsl:sort select="xs:dateTime(@date-time)" order="descending"/>
                                            <li>
                                                <div class="text-bold">
                                                    <xsl:choose>
                                                        <xsl:when test="local-name(.) eq 'status-update'">
                                                            <xsl:choose>
                                                                <xsl:when test="@update eq 'text-version'">
                                                                    <xsl:value-of select="'Version update: ' || @value"/>
                                                                </xsl:when>
                                                                <xsl:when test="@update eq 'translation-status'">
                                                                    <xsl:value-of select="'Status update: ' || @value"/>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                            <xsl:if test="text() and not(text() eq @value)">
                                                                <xsl:value-of select="concat(' / ', text())"/>
                                                            </xsl:if>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="text()"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                                <div class="text-muted italic">
                                                    <xsl:choose>
                                                        <xsl:when test="local-name(.) eq 'status-update'">
                                                            <xsl:value-of select="common:date-user-string('- Set ', @date-time, @user)"/>
                                                        </xsl:when>
                                                        <xsl:when test="local-name(.) eq 'task'">
                                                            <xsl:value-of select="common:date-user-string('- Set ', @checked-off, @checked-off-by)"/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </div>
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
            <input type="hidden" name="form-action" value="update-sponsorship"/>
            <input type="hidden" name="post-id">
                <xsl:attribute name="value" select="m:translation/@id"/>
            </input>
            <input type="hidden" name="sponsorship-project-id">
                <xsl:attribute name="value" select="m:sponsorship-status/@project-id"/>
            </input>
            <div class="row">
                <div class="col-sm-8">
                    <fieldset>
                        <legend>
                            <xsl:value-of select="'Project'"/>
                        </legend>
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="add-nodes-container">
                                    <xsl:choose>
                                        <xsl:when test="m:sponsorship-status/m:text">
                                            <xsl:for-each select="m:sponsorship-status/m:text">
                                                <div class="form-group add-nodes-group">
                                                    <label class="control-label col-sm-4">
                                                        <xsl:value-of select="'Text:'"/>
                                                    </label>
                                                    <div class="col-sm-8">
                                                        <input type="text" class="form-control">
                                                            <xsl:attribute name="name" select="concat('sponsorship-text-', position())"/>
                                                            <xsl:attribute name="value" select="@text-id"/>
                                                        </input>
                                                    </div>
                                                </div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div class="form-group add-nodes-group">
                                                <label class="control-label col-sm-4">
                                                    <xsl:value-of select="'Text:'"/>
                                                </label>
                                                <div class="col-sm-8">
                                                    <input type="text" name="sponsorship-text-1" class="form-control">
                                                        <xsl:attribute name="value" select="m:translation/@id"/>
                                                    </input>
                                                </div>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                    <div>
                                        <a href="#add-text" class="add-nodes">
                                            <span class="monospace">+</span>
                                            <xsl:value-of select="'add a text'"/>
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <p class="small text-muted">Enter multiple text ids to combine several texts into the same sponsorship project.</p>
                            </div>
                        </div>
                    </fieldset>
                    <fieldset class="tests">
                        
                        <legend>
                            <xsl:value-of select="'Money'"/>
                        </legend>
                        <xsl:variable name="configured-cost" select="m:sponsorship-status/m:cost"/>
                        <xsl:variable name="estimated-cost" select="m:sponsorship-status/m:estimate/m:cost"/>
                        <xsl:variable name="sum-cost-parts" select="sum($configured-cost/m:part/@amount)"/>
                        
                        <!-- Pages -->
                        <div class="form-group">
                            <label class="control-label col-sm-3">
                                <xsl:value-of select="'Sponsorship pages:'"/>
                            </label>
                            <div class="col-sm-2">
                                <input type="text" name="sponsorship-pages" class="form-control">
                                    <xsl:attribute name="value" select="$configured-cost/@pages"/>
                                </input>
                            </div>
                            <div class="col-sm-7">
                                <div class="center-vertical">
                                    <span class="large-icons">
                                        <xsl:choose>
                                            <xsl:when test="xs:integer($configured-cost/@pages) eq xs:integer($estimated-cost/@pages)">
                                                <i class="fa fa-check-circle"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <i class="fa fa-times-circle"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </span>
                                    <span class="small text-muted">
                                        <xsl:value-of select="concat('This project has ', $estimated-cost/@pages, ' pages')"/>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Rounded cost -->
                        <div class="form-group">
                            <label class="control-label col-sm-3">
                                <xsl:value-of select="'Cost (rounded):'"/>
                            </label>
                            <div class="col-sm-2">
                                <input type="text" name="rounded-cost" class="form-control">
                                    <xsl:attribute name="value" select="$configured-cost/@rounded-cost"/>
                                </input>
                            </div>
                            <xsl:variable name="use-cost" select="if($configured-cost/@rounded-cost) then $configured-cost else $estimated-cost"/>
                            <xsl:variable name="use-cost-rounded" select="ceiling(xs:integer($use-cost/@pages) * xs:integer($use-cost/@per-page-price) div 1000) * 1000"/>
                            <div class="col-sm-7">
                                <div class="center-vertical">
                                    <span class="large-icons">
                                        <xsl:choose>
                                            <xsl:when test="$use-cost-rounded eq xs:integer($use-cost/@rounded-cost)">
                                                <i class="fa fa-check-circle"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <i class="fa fa-times-circle"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </span>
                                    <span class="small text-muted">
                                        <xsl:value-of select="concat(format-number($use-cost/@pages, '#,###'), ' pages x ', $use-cost/@per-page-price, ' = ', format-number($use-cost/@basic-cost, '#,###'))"/>
                                        <xsl:value-of select="concat(' ≅ ', format-number($use-cost-rounded, '#,###'))"/>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Cost parts -->
                        <div class="add-nodes-container">
                            
                            <xsl:if test="$configured-cost/m:part">
                                
                                <!-- List the parts -->
                                <xsl:for-each select="$configured-cost/m:part">
                                    <xsl:call-template name="sponsorship-cost-part">
                                        <xsl:with-param name="index" select="position()"/>
                                        <xsl:with-param name="amount" select="@amount"/>
                                        <xsl:with-param name="status" select="@status"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                
                                <!-- Validation of the costs -->
                                <div class="row">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <div class="center-vertical">
                                            <span class="large-icons">
                                                <xsl:choose>
                                                    <xsl:when test="xs:integer($configured-cost/@rounded-cost) eq xs:integer($sum-cost-parts)">
                                                        <i class="fa fa-check-circle"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <i class="fa fa-times-circle"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </span>
                                            <span class="small text-muted">
                                                <xsl:value-of select="concat('Sum of cost parts = ', format-number($sum-cost-parts, '#,###'))"/>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Add a new part -->
                                <div>
                                    <a href="#add-cost-part" class="add-nodes">
                                        <span class="monospace">+</span>
                                        <xsl:value-of select="'add a cost part'"/>
                                    </a>
                                </div>
                            </xsl:if>
                            
                        </div>
                    </fieldset>
                    <fieldset class="add-nodes-container">
                        <legend>
                            <xsl:value-of select="'Sponsors'"/>
                        </legend>
                        <xsl:choose>
                            <xsl:when test="m:translation/m:publication/m:sponsors/m:sponsor">
                                <xsl:call-template name="sponsors-controls">
                                    <xsl:with-param name="text-sponsors" select="m:translation/m:publication/m:sponsors/m:sponsor"/>
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
                            <a href="#add-sponsor" class="add-nodes">
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
                    <xsl:if test="m:translation/m:sponsors/tei:div[@type eq 'acknowledgment']/@generated">
                        <div class="alert alert-warning small sml-margin bottom">
                            <p>Text auto-generated from the list. No acknowledgment found in the TEI.</p>
                        </div>
                    </xsl:if>
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
                                    <xsl:choose>
                                        <xsl:when test="m:sponsorship-status/m:status[@id = 'full']">
                                            <xsl:attribute name="href" select="concat($operations-path, '/search.html?sponsored=fully-sponsored')"/>
                                            <xsl:value-of select="'Back to search: Fully sponsored texts'"/>
                                        </xsl:when>
                                        <xsl:when test="m:sponsorship-status/m:status[@id = 'part']">
                                            <xsl:attribute name="href" select="concat($operations-path, '/search.html?sponsored=part-sponsored')"/>
                                            <xsl:value-of select="'Back to search: Part sponsored texts'"/>
                                        </xsl:when>
                                        <xsl:when test="m:sponsorship-status/m:status[@id = 'available']">
                                            <xsl:attribute name="href" select="concat($operations-path, '/search.html?sponsored=available')"/>
                                            <xsl:value-of select="'Back to search: Texts available for sponsorship'"/>
                                        </xsl:when>
                                        <xsl:when test="m:sponsorship-status/m:status[@id = 'priority']">
                                            <xsl:attribute name="href" select="concat($operations-path, '/search.html?sponsored=priority')"/>
                                            <xsl:value-of select="'Back to search: Texts prioritised for sponsorship'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="href" select="concat($operations-path, '/search.html?sponsored=sponsored')"/>
                                            <xsl:value-of select="'Back to search: All sponsored texts'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
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
                        <option value="">
                            <xsl:value-of select="'[none]'"/>
                        </option>
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
                    <input type="text" class="form-control" placeholder="same">
                        <xsl:attribute name="name" select="concat('sponsor-expression-', position())"/>
                        <xsl:attribute name="value" select="text()"/>
                    </input>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="sponsorship-cost-part">
        
        <xsl:param name="index" required="yes" as="xs:integer"/>
        <xsl:param name="amount" required="yes" as="xs:integer"/>
        <xsl:param name="status" required="no" as="xs:string?"/>
        
        <div class="form-group add-nodes-group">
            <label class="control-label col-sm-3">
                <xsl:value-of select="concat('Cost part ', if($index gt 1) then $index else '', ':')"/>
            </label>
            <div class="col-sm-2">
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="concat('cost-part-amount-', $index)"/>
                    <xsl:attribute name="value" select="$amount"/>
                </input>
            </div>
            <div class="col-sm-4">
                <select class="form-control">
                    <xsl:attribute name="name" select="concat('cost-part-status-', $index)"/>
                    <option value="available">
                        <xsl:if test="not($status)">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Available'"/>
                    </option>
                    <option value="priority">
                        <xsl:if test="$status eq 'priority'">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Priority'"/>
                    </option>
                    <option value="reserved">
                        <xsl:if test="$status eq 'reserved'">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Reserved'"/>
                    </option>
                    <option value="sponsored">
                        <xsl:if test="$status eq 'sponsored'">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="'Sponsored'"/>
                    </option>
                    <option value="remove">
                        <xsl:value-of select="'Remove'"/>
                    </option>
                </select>
            </div>
        </div>
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
                            
                            <!-- Text title -->
                            <div class="top-vertical full-width">
                                <a>
                                    <xsl:attribute name="href" select="replace($link-href, '@translation-id', @translation-id)"/>
                                    <xsl:value-of select="m:toh/m:full"/> / <xsl:value-of select="m:title"/>
                                </a>
                                <span class="text-right">
                                    <xsl:copy-of select="common:sponsorship-status(m:sponsorship-status/m:status)"/>
                                    <xsl:copy-of select="common:translation-status(@translation-status-group)"/>
                                </span>
                            </div>
                            
                            <div class="small">
                                
                                <!-- Contribution -->
                                <xsl:variable name="contribution" select="m:contribution"/>
                                <xsl:if test="$contribution">
                                    <div class="text-warning">
                                        <xsl:value-of select="/m:response/m:contributor-types/m:contributor-type[@node-name eq $contribution/@node-name][@role eq $contribution/@role]/m:label"/>
                                    </div>
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
    
    <!-- Submissions panel prototype -->
    <xsl:template name="submissions-form-panel">
        <xsl:param name="active"/>
        <xsl:call-template name="panel">
            
            <xsl:with-param name="type" select="'Submissions'"/>
            <xsl:with-param name="title" select="'Submissions'"/>
            <xsl:with-param name="active" select="$active"/>
            
            <xsl:with-param name="flag">
                <span class="badge badge-notification">
                    <xsl:value-of select="count(m:translation-status/m:text/m:submission)"/>
                </span>
            </xsl:with-param>
            
            <xsl:with-param name="form">
                
                <xsl:for-each select="m:translation-status/m:text/m:submission">
                    <xsl:variable name="submission" select="."/>
                    
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
                    <hr class="sml-margin"/>
                </xsl:for-each>
                
                <form method="post" enctype="multipart/form-data" class="form-horizontal form-update" id="submissions-form">
                    <xsl:attribute name="action" select="'edit-text-header.html#submissions-form'"/>
                    <input type="hidden" name="form-action" value="process-upload"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="m:translation/@id"/>
                    </input>
                    
                    <div class="form-group">
                        <label for="submit-file" class="col-sm-3 control-label">
                            <xsl:value-of select="'Upload a translation file'"/>
                        </label>
                        <div class="col-sm-7">
                            <input type="file" name="submit-translation-file" id="submit-translation-file" class="form-control" required="required" accept="application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>
                        </div>
                        <div class="col-sm-2">
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:value-of select="'Submit'"/>
                            </button>
                        </div>
                    </div>
                </form>
                
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>