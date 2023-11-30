<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="response" select="/m:response"/>
    <xsl:variable name="text" select="$response/m:text"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <div class="center-vertical full-width sml-margin bottom">
                        
                        <div class="h3">
                            <a target="{ $text/@id }-html">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/@id, '.html')"/>
                                <xsl:value-of select="concat(string-join($text/m:toh/m:full, ' / '), ' / ', $text/m:titles/m:title[@xml:lang eq 'en'][1])"/>
                            </a>
                        </div>
                        
                        <div class="text-right">
                            <xsl:sequence select="ops:sponsorship-status(m:sponsorship-status/m:status)"/>
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <!-- Links -->
                    <xsl:call-template name="text-links-list">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="exclude-links" select="('edit-text-sponsors', 'source-folios')"/>
                        <xsl:with-param name="text-status" select="$response/m:text-statuses/m:status[@status-id eq $text/@status]"/>
                    </xsl:call-template>
                    
                    <hr class="sml-margin"/>
                    
                    <xsl:call-template name="text-sponsors-form"/>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sponsor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Institutions configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Sponsors form -->
    <xsl:template name="text-sponsors-form">
        <form method="post" class="form-horizontal form-update" data-loading="Updating sponsors...">
            <xsl:attribute name="action" select="'edit-text-sponsors.html'"/>
            <input type="hidden" name="form-action" value="update-sponsorship"/>
            <input type="hidden" name="post-id">
                <xsl:attribute name="value" select="$text/@id"/>
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
                                                        <xsl:attribute name="value" select="$text/@id"/>
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
                            <xsl:when test="$text/m:publication/m:sponsors/m:sponsor">
                                <xsl:call-template name="sponsors-controls">
                                    <xsl:with-param name="text-sponsors" select="$text/m:publication/m:sponsors/m:sponsor"/>
                                    <xsl:with-param name="all-sponsors" select="$response/m:sponsors/m:sponsor"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="sponsors-controls">
                                    <xsl:with-param name="text-sponsors">
                                        <m:sponsor ref="dummy"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="all-sponsors" select="$response/m:sponsors/m:sponsor"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div>
                            <a href="#add-sponsor" class="add-nodes">
                                <span class="monospace">+</span>
                                <xsl:value-of select="' add a sponsor'"/>
                            </a>
                        </div>
                    </fieldset>
                    
                </div>
                <div class="col-sm-4">
                    <div class="text-bold">
                        <xsl:value-of select="'Acknowledgment'"/>
                    </div>
                    <xsl:if test="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/@generated">
                        <div class="alert alert-warning small sml-margin bottom">
                            <p>Text auto-generated from the list. No acknowledgment found in the TEI.</p>
                        </div>
                    </xsl:if>
                    <xsl:if test="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                        <xsl:apply-templates select="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                        <hr/>
                    </xsl:if>
                    <p class="small text-muted">
                        <xsl:value-of select="'If a sponsor is not automatically recognised in the acknowledgement text then please specify what they are &#34;expressed as&#34;. If a sponsor is already highlighted then you can leave this field blank.'"/>
                    </p>
                </div>
            </div>
            
            <hr class="sml-margin"/>
            
            
            <div class="form-group">
                <div class="col-sm-12">
                    <div class="center-vertical full-width">
                        <div>
                            <ul class="list-inline inline-dots small">
                                <li>
                                    <span class="text-muted">
                                        <xsl:value-of select="'Back to search: '"/>
                                    </span>
                                    <a>
                                        <xsl:choose>
                                            <xsl:when test="m:sponsorship-status/m:status[@id = 'full']">
                                                <xsl:attribute name="href" select="concat($operations-path, '/search.html?filter=fully-sponsored')"/>
                                                <xsl:value-of select="'Fully sponsored texts'"/>
                                            </xsl:when>
                                            <xsl:when test="m:sponsorship-status/m:status[@id = 'part']">
                                                <xsl:attribute name="href" select="concat($operations-path, '/search.html?filter=part-sponsored')"/>
                                                <xsl:value-of select="'Part sponsored texts'"/>
                                            </xsl:when>
                                            <xsl:when test="m:sponsorship-status/m:status[@id = 'available']">
                                                <xsl:attribute name="href" select="concat($operations-path, '/search.html?filter=available')"/>
                                                <xsl:value-of select="'Texts available for sponsorship'"/>
                                            </xsl:when>
                                            <xsl:when test="m:sponsorship-status/m:status[@id = 'priority']">
                                                <xsl:attribute name="href" select="concat($operations-path, '/search.html?filter=priority')"/>
                                                <xsl:value-of select="'Texts prioritised for sponsorship'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="href" select="concat($operations-path, '/search.html?filter=sponsored')"/>
                                                <xsl:value-of select="'All sponsored texts'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:if test="not($response/@model eq 'operations/edit-text-sponsors')">
                                            <xsl:attribute name="target" select="'operations'"/>
                                        </xsl:if>
                                        <xsl:attribute name="href" select="concat($operations-path, '/edit-sponsor.html')"/>
                                        <xsl:value-of select="'Add a new sponsor'"/>
                                    </a>
                                </li>
                            </ul>
                        </div>
                        <div>
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:if test="$text[@locked-by-user gt '']">
                                    <xsl:attribute name="disabled" select="'disabled'"/>
                                </xsl:if>
                                <xsl:value-of select="'Save'"/>
                            </button>
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
            
            <xsl:variable name="sponsorship-id" select="@xml:id"/>
            <xsl:variable name="text-sponsor" select="$all-sponsors[m:instance/@id = $sponsorship-id]"/>
            
            <div class="form-group add-nodes-group">
                
                <input type="hidden" name="{ concat('sponsorship-id-', position()) }" value="{ $sponsorship-id }"/>
                
                <div class="col-sm-5">
                    <select class="form-control">
                        <xsl:attribute name="name" select="concat('sponsor-id-', position())"/>
                        <option value="">
                            <xsl:value-of select="'[none]'"/>
                        </option>
                        <xsl:for-each select="$all-sponsors">
                            <option>
                                <xsl:attribute name="value" select="@xml:id"/>
                                <xsl:if test="@xml:id eq $text-sponsor/@xml:id">
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
    
</xsl:stylesheet>