<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="request" select="/m:response/m:request" as="element(m:request)*"/>
    <xsl:variable name="texts" select="/m:response/m:texts" as="element(m:texts)*"/>
    <xsl:variable name="translation-status" select="/m:response/m:translation-status" as="element(m:translation-status)?"/>
    <xsl:variable name="text-statuses" select="/m:response/m:text-statuses/m:status" as="element(m:status)*"/>
    <xsl:variable name="selected-statuses" select="$text-statuses[@selected eq 'selected']" as="element(m:status)*"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    
                    <h1 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'84000 Project Management: Translations Report '"/>
                    </h1>
                    
                    <form action="search.html" method="post" class="form-horizontal" data-loading="Searching...">
                        <div class="row">
                            
                            <!-- Text statuses -->
                            <div class="col-sm-7  print-width-override">
                                
                                <table class="table table-condensed no-border no-padding no-bottom-margin hidden-print">
                                    <xsl:for-each select="m:text-statuses/m:status">
                                        <xsl:sort select="xs:integer(@index)"/>
                                        <tr class="vertical-middle">
                                            <td>
                                                <xsl:value-of select="@status-id"/>
                                            </td>
                                            <td>
                                                <div class="checkbox">
                                                    <label>
                                                        <input type="checkbox" name="status[]">
                                                            <xsl:attribute name="value" select="@value"/>
                                                            <xsl:attribute name="id" select="concat('status-', position())"/>
                                                            <xsl:if test="@selected eq 'selected'">
                                                                <xsl:attribute name="checked" select="'checked'"/>
                                                            </xsl:if>
                                                        </input>
                                                        <xsl:value-of select="text()"/>
                                                        <span class="small text-muted">
                                                            <xsl:value-of select="' / '"/>
                                                            <xsl:choose>
                                                                <xsl:when test="@group eq 'not-started'">
                                                                    <xsl:value-of select="'Not started'"/>
                                                                </xsl:when>
                                                                <xsl:when test="@group eq 'published'">
                                                                    <xsl:value-of select="'Published'"/>
                                                                </xsl:when>
                                                                <xsl:when test="@group eq 'translated'">
                                                                    <xsl:value-of select="'Translated'"/>
                                                                </xsl:when>
                                                                <xsl:when test="@group eq 'in-translation'">
                                                                    <xsl:value-of select="'In translation'"/>
                                                                </xsl:when>
                                                                <xsl:when test="@group eq 'in-application'">
                                                                    <xsl:value-of select="'Application phase'"/>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                        </span>
                                                    </label>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                                
                                <xsl:if test="$selected-statuses">
                                    <div class="visible-print-block">
                                        <p class="no-bottom-margin">
                                            <xsl:value-of select="'Selected statuses:'"/>
                                        </p>
                                        <ul class="no-top-margin sml-margin bottom">
                                            <xsl:for-each select="$selected-statuses">
                                                <li>
                                                    <xsl:value-of select="concat(@status-id, ' / ', text())"/>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </xsl:if>
                                
                            </div>
                            
                            <!-- Other options -->
                            <div class="col-sm-5 print-width-override">
                                
                                <!-- Kangyur / Tengyur / All -->
                                <div class="form-group hidden-print">
                                    <label for="work" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Section:'"/>
                                    </label>
                                    <div class="col-sm-8">
                                        <select class="form-control" name="work" id="work">
                                            <option value="all">
                                                <xsl:if test="$request/@work eq 'all'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'[All]'"/>
                                            </option>
                                            <option value="UT4CZ5369">
                                                <xsl:if test="$request/@work eq 'UT4CZ5369'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Kangyur'"/>
                                            </option>
                                            <option value="UT23703">
                                                <xsl:if test="$request/@work eq 'UT23703'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Tengyur'"/>
                                            </option>
                                        </select>
                                    </div>
                                </div>
                                
                                <xsl:if test="$request/@work = ('UT4CZ5369', 'UT23703')">
                                   <div class="visible-print-block">
                                       <xsl:choose>
                                           <xsl:when test="$request/@work eq 'UT4CZ5369'">
                                               <xsl:value-of select="'Work: Kangyur'"/>
                                           </xsl:when>
                                           <xsl:when test="$request/@work eq 'UT23703'">
                                               <xsl:value-of select="'Work: Tengyur'"/>
                                           </xsl:when>
                                       </xsl:choose>
                                   </div>
                                </xsl:if>
                                
                                <!-- Filters -->
                                <div class="form-group hidden-print">
                                    <label for="texts-filter" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Filter:'"/>
                                    </label>
                                    <div class="col-sm-8">
                                        <select name="filter" id="texts-filter" class="form-control">
                                            <option value="none">
                                                <xsl:if test="$texts/@filter eq 'none'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'[No filter]'"/>
                                            </option>
                                            <optgroup label="Sponsorship">
                                                <xsl:for-each select="m:sponsorship-groups/m:group">
                                                    <xsl:variable name="group-id" select="@id"/>
                                                    <option>
                                                        <xsl:attribute name="value" select="$group-id"/>
                                                        <xsl:if test="$texts[@filter eq $group-id]">
                                                            <xsl:attribute name="selected" select="'selected'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="m:label"/>
                                                    </option>
                                                </xsl:for-each>
                                            </optgroup>
                                            <optgroup label="Entities">
                                                <option value="entities-missing">
                                                    <xsl:if test="$texts[@filter eq 'entities-missing']">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Glossaries without entities'"/>
                                                </option>
                                                <option value="entities-flagged-attention">
                                                    <xsl:if test="$texts[@filter eq 'entities-flagged-attention']">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Entities requiring attention'"/>
                                                </option>
                                            </optgroup>
                                        </select>
                                    </div>
                                </div>
                                
                                <xsl:variable name="selected-sponsorship-group" select="m:sponsorship-groups/m:group[@id eq $texts/@sponsorship-group]"/>
                                <xsl:if test="$selected-sponsorship-group">
                                    <div class="visible-print-block">
                                        <xsl:value-of select="concat('Sponsorship group: ', $selected-sponsorship-group)"/>
                                    </div>
                                </xsl:if>
                                
                                <!-- Page range -->
                                <div class="form-group hidden-print">
                                    <label for="pages-min" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Number of pages:'"/>
                                    </label>
                                    <div class="col-sm-4">
                                        <input type="number" name="pages-min" id="pages-min" class="form-control" placeholder="min.">
                                            <xsl:attribute name="value" select="$request/@pages-min"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="number" name="pages-max" id="pages-max" class="form-control" placeholder="max.">
                                            <xsl:attribute name="value" select="$request/@pages-max"/>
                                        </input>
                                    </div>
                                </div>
                                <xsl:if test="$request/@pages-min gt '' or $request/@pages-max gt ''">
                                    <div class="visible-print-block">
                                        <xsl:value-of select="concat('Number of pages:', $request/@pages-min, ' - ', $request/@pages-max)"/>
                                    </div>
                                </xsl:if>
                                
                                <!-- Tohoku range -->
                                <div class="form-group hidden-print">
                                    <label for="toh-min" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Tohoku numbers:'"/>
                                    </label>
                                    <div class="col-sm-4">
                                        <input type="number" name="toh-min" id="toh-min" class="form-control" placeholder="min.">
                                            <xsl:attribute name="value" select="$request/@toh-min"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="number" name="toh-max" id="toh-max" class="form-control" placeholder="max.">
                                            <xsl:attribute name="value" select="$request/@toh-max"/>
                                        </input>
                                    </div>
                                </div>
                                <xsl:if test="$request/@toh-min gt '' or $request/@toh-max gt ''">
                                    <div class="visible-print-block">
                                        <xsl:value-of select="concat('Tohoku numbers:', $request/@toh-min, ' - ', $request/@toh-max)"/>
                                    </div>
                                </xsl:if>
                                
                                <!-- Target date -->
                                <div class="form-group hidden-print">
                                    <div class="col-sm-4">
                                        <select name="target-date-type" class="form-control">
                                            <option value="target-date">
                                                <xsl:if test="$request/@target-date-type eq 'target-date'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Target dates'"/>
                                            </option>
                                            <option value="status-date">
                                                <xsl:if test="$request/@target-date-type eq 'status-date'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Status achieved'"/>
                                            </option>
                                        </select>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="date" name="target-date-start" id="target-date-start" class="form-control" placeholder="">
                                            <xsl:attribute name="value" select="$request/@target-date-start"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="date" name="target-date-end" id="target-date-end" class="form-control" placeholder="">
                                            <xsl:attribute name="value" select="$request/@target-date-end"/>
                                        </input>
                                    </div>
                                </div>
                                <xsl:variable name="target-date-type-str">
                                    <xsl:choose>
                                        <xsl:when test="$request/@target-date-type eq 'target-date'">
                                            <xsl:value-of select="'Target dates'"/>
                                        </xsl:when>
                                        <xsl:when test="$request/@target-date-type eq 'status-date'">
                                            <xsl:value-of select="'Status achieved'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="$request/@target-date-start gt '' and $request/@target-date-end gt ''">
                                        <div class="visible-print-block">
                                            <xsl:value-of select="concat($target-date-type-str, ' between: ', format-date($request/@target-date-start, '[D01] [MNn,*-3] [Y]'), ' and ', format-date($request/@target-date-end, '[D01] [MNn,*-3] [Y]'))"/>
                                        </div>
                                    </xsl:when>
                                    <xsl:when test="$request/@target-date-start gt ''">
                                        <div class="visible-print-block">
                                            <xsl:value-of select="concat($target-date-type-str, ' from: ', format-date($request/@target-date-start, '[D01] [MNn,*-3] [Y]'))"/>
                                        </div>
                                    </xsl:when>
                                    <xsl:when test="$request/@target-date-end gt ''">
                                        <div class="visible-print-block">
                                            <xsl:value-of select="concat($target-date-type-str, ' until: ', format-date($request/@target-date-end, '[D01] [MNn,*-3] [Y]'))"/>
                                        </div>
                                    </xsl:when>
                                </xsl:choose>
                                
                                <!-- Sort -->
                                <div class="form-group hidden-print">
                                    <label for="sort" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Sort order:'"/>
                                    </label>
                                    <div class="col-sm-6 print-width-override">
                                        <select name="sort" id="sort" class="form-control">
                                            <option value="toh">
                                                <xsl:if test="m:texts/@sort eq 'toh'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort by Tohoku'"/>
                                            </option>
                                            <option value="status">
                                                <xsl:if test="m:texts/@sort eq 'status'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort by status'"/>
                                            </option>
                                            <option value="due-date">
                                                <xsl:if test="m:texts/@sort eq 'due-date'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort by due date'"/>
                                            </option>
                                            <option value="publication-date">
                                                <xsl:if test="m:texts/@sort eq 'publication-date'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort by publication date'"/>
                                            </option>
                                            <option value="longest">
                                                <xsl:if test="m:texts/@sort eq 'longest'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort by longest first'"/>
                                            </option>
                                            <option value="shortest">
                                                <xsl:if test="m:texts/@sort eq 'shortest'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort by shortest first'"/>
                                            </option>
                                        </select>
                                    </div>
                                </div>
                                <div class="visible-print-block">
                                    <xsl:choose>
                                        <xsl:when test="m:texts/@sort eq 'toh'">
                                            <xsl:value-of select="'Sorted by: Tohoku'"/>
                                        </xsl:when>
                                        <xsl:when test="m:texts/@sort eq 'status'">
                                            <xsl:value-of select="'Sorted by: status'"/>
                                        </xsl:when>
                                        <xsl:when test="m:texts/@sort eq 'due-date'">
                                            <xsl:value-of select="'Sorted by: due date'"/>
                                        </xsl:when>
                                        <xsl:when test="m:texts/@sort eq 'longest'">
                                            <xsl:value-of select="'Sorted by: longest first'"/>
                                        </xsl:when>
                                        <xsl:when test="m:texts/@sort eq 'shortest'">
                                            <xsl:value-of select="'Sorted by: shortest first'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </div>
                                
                                <!-- Grouping -->
                                <div class="form-group hidden-print">
                                    <label for="sort" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Grouping:'"/>
                                    </label>
                                    <div class="col-sm-6">
                                        <select name="deduplicate" class="form-control">
                                            <option value="toh">
                                                <xsl:if test="m:texts/@deduplicate eq 'toh'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'List all Tohs'"/>
                                            </option>
                                            <option value="text">
                                                <xsl:if test="m:texts/@deduplicate eq 'text'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Group by text'"/>
                                            </option>
                                            <option value="sponsorship">
                                                <xsl:if test="m:texts/@deduplicate eq 'sponsorship'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Group by sponsorship'"/>
                                            </option>
                                        </select>
                                    </div>
                                    <div class="col-sm-2">
                                        <input type="submit" value="Search" class="btn btn-primary pull-right"/>
                                    </div>
                                </div>
                                <div class="visible-print-block">
                                    <xsl:choose>
                                        <xsl:when test="m:texts/@deduplicate eq 'toh'">
                                            <xsl:value-of select="'Grouping: Tohoku'"/>
                                        </xsl:when>
                                        <xsl:when test="m:texts/@deduplicate eq 'text'">
                                            <xsl:value-of select="'Grouping: text'"/>
                                        </xsl:when>
                                        <xsl:when test="m:texts/@deduplicate eq 'sponsorship'">
                                            <xsl:value-of select="'Grouping: sponsorship'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </div>
                                
                                <!-- Results summary / download -->
                                <xsl:if test="m:texts">
                                    <div class="well well-sm small">
                                        
                                        <h4 class="no-top-margin sml-margin bottom">
                                            <xsl:value-of select="'Summary'"/>
                                        </h4>
                                        
                                        <div class="sml-margin bottom">
                                            <strong>
                                                <xsl:value-of select="format-number(count(m:texts/m:text), '#,###')"/>
                                            </strong>
                                            <xsl:value-of select="' texts / '"/>
                                            <strong>
                                                <xsl:variable name="text-pages" select="m:texts/m:text/m:source/m:location/@count-pages ! xs:integer(.)" as="xs:integer*"/>
                                                <xsl:variable name="status-pages" as="xs:integer*">
                                                    <xsl:for-each select="m:texts/m:text">
                                                        <xsl:call-template name="status-pages">
                                                            <xsl:with-param name="text" select="."/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="sum($status-pages) gt 0">
                                                        <xsl:value-of select="concat(format-number(sum($status-pages), '#,###'), if(sum($text-pages) gt sum($status-pages)) then concat(' of ', format-number(sum($text-pages), '#,###')) else '')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="format-number(sum($text-pages), '#,###')"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </strong>
                                            <xsl:value-of select="' pages / '"/>
                                            <strong>
                                                <xsl:value-of select="format-number(sum($translation-status/m:text[@text-id = $texts/m:text/@id]/@word-count ! xs:integer(.)), '#,###')"/>
                                            </strong>
                                            <xsl:value-of select="' words / '"/>
                                            <strong>
                                                <xsl:value-of select="format-number(sum($translation-status/m:text[@text-id = $texts/m:text/@id]/@glossary-count ! xs:integer(.)), '#,###')"/>
                                            </strong>
                                            <xsl:value-of select="' glossaries'"/>
                                        </div>
                                        
                                        <!-- Download spreadsheet -->
                                        <div>
                                            <a class="underline">
                                                <xsl:attribute name="href" select="concat('/search.xlsx?', string-join($request/@*[string() gt ''] ! concat(local-name(.), '=', string()), '&amp;'))"/>
                                                <xsl:value-of select="'Download as a spreadsheet'"/>
                                            </a>
                                        </div>
                                        
                                    </div>
                                </xsl:if>
                                
                            </div>
                        
                        </div>
                    </form>
                    
                    <xsl:if test="count(m:texts/m:text) eq 1024">
                        <div class="alert alert-danger small text-center">
                            <xsl:value-of select="'Only the first 1024 have been returned.'"/>
                        </div>
                    </xsl:if>
                                                
                    <xsl:if test="m:texts/m:text">
                        <table class="table table-responsive">
                            
                            <thead>
                                <tr>
                                    <th>Toh</th>
                                    <th>Title</th>
                                    <th>Pages</th>
                                    <th class="hidden-print">Start</th>
                                    <th class="hidden-print">End</th>
                                    <th>Sponsorship</th>
                                </tr>
                            </thead>
                            
                            <tbody>
                                <xsl:for-each select="m:texts/m:text">
                                    
                                    <xsl:variable name="text" select="."/>
                                    <xsl:variable name="text-status" select="(/m:response/m:text-statuses/m:status[@status-id eq $text/@status], /m:response/m:text-statuses/m:status[@status-id eq '0'])[1]"/>
                                    
                                    <xsl:variable name="preceding-text" select="$text/preceding-sibling::m:text[1]"/>
                                    <xsl:variable name="preceding-text-status" select="(/m:response/m:text-statuses/m:status[@status-id eq $preceding-text/@status], /m:response/m:text-statuses/m:status[@status-id eq '0'])[1]"/>
                                    
                                    <xsl:variable name="text-translation-status" select="$translation-status/m:text[@text-id eq $text/@id][1]"/>
                                    
                                    <!-- Status grouping -->
                                    <xsl:if test="$texts[@sort eq 'status'] and not($text-status/@status-id eq $preceding-text-status/@status-id)">
                                        
                                        <tr class="header">
                                            <td colspan="5">
                                                
                                                <xsl:variable name="status-count-texts" select="count($texts/m:text[@status eq $text-status/@status-id])"/>
                                                <xsl:variable name="status-text-pages" select="$texts/m:text[@status eq $text-status/@status-id]/m:source/m:location/@count-pages ! xs:integer(.)" as="xs:integer*"/>
                                                <xsl:variable name="status-status-pages" as="xs:integer*">
                                                    <xsl:for-each select="$texts/m:text[@status eq $text-status/@status-id]">
                                                        <xsl:call-template name="status-pages">
                                                            <xsl:with-param name="text" select="."/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </xsl:variable>
                                                
                                                <xsl:value-of select="concat($text-status/@status-id, ' / ', $text-status/text())"/>
                                                <xsl:value-of select="concat(' (', format-number($status-count-texts, '#,###'), ' texts, ')"/>
                                                <xsl:choose>
                                                    <xsl:when test="sum($status-status-pages) gt 0">
                                                        <xsl:value-of select="concat(format-number(sum($status-status-pages), '#,###'), ' pages', if(sum($status-text-pages) gt sum($status-status-pages)) then concat(' of ', format-number(sum($status-text-pages), '#,###')) else '')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="concat(format-number(sum($status-text-pages), '#,###'), ' pages')"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:value-of select="')'"/>
                                                
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    
                                    <!-- Main row - About the text -->
                                    <tr>
                                        
                                        <!-- Toh / status -->
                                        <td rowspan="4">
                                            
                                            <xsl:if test="$text/m:sponsors/tei:div[@type eq 'acknowledgment'][tei:p]">
                                                <xsl:attribute name="rowspan" select="'4'"/>
                                            </xsl:if>
                                            
                                            <xsl:choose>
                                                <xsl:when test="$texts[@deduplicate eq 'text'] and $text/m:toh[m:duplicates]">
                                                    <xsl:value-of select="$text/m:toh/m:full/text()"/>
                                                    <xsl:for-each select="$text/m:toh/m:duplicates/m:duplicate">
                                                        <br/>
                                                        <span class="nowrap">
                                                            <xsl:value-of select="normalize-space(concat(' / ', m:full/text()))"/>
                                                        </span>
                                                    </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:call-template name="expandable-toh">
                                                        <xsl:with-param name="toh" select="$text/m:toh"/>
                                                    </xsl:call-template>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                            <!-- Status -->
                                            <br/>
                                            <span>
                                                <xsl:choose>
                                                    <xsl:when test="$text[@status-group eq 'published']">
                                                        <xsl:attribute name="class" select="'label label-success'"/>
                                                    </xsl:when>
                                                    <xsl:when test="$text[@status-group eq 'translated']">
                                                        <xsl:attribute name="class" select="'label label-primary'"/>
                                                    </xsl:when>
                                                    <xsl:when test="$text[@status-group eq 'in-translation']">
                                                        <xsl:attribute name="class" select="'label label-warning'"/>
                                                    </xsl:when>
                                                    <xsl:when test="$text[@status-group eq 'in-application']">
                                                        <xsl:attribute name="class" select="'label label-danger'"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="class" select="'label label-default'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:attribute name="title" select="$text-status/text()"/>
                                                <xsl:value-of select="$text-status/@status-id"/>
                                            </span>
                                            
                                        </td>
                                        
                                        <!-- Title / links to forms / stats -->
                                        <td>
                                            
                                            <!-- Title -->
                                            <a target="_blank" class="printable">
                                                <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text/m:toh/@key, '.html')"/>
                                                <xsl:value-of select="($text/m:titles/m:title[@xml:lang eq 'en'], $text/m:titles/m:title[@xml:lang eq 'Sa-Ltn'], $text/m:titles/m:title[@xml:lang eq 'Bo-Ltn'])[normalize-space()][1]"/>
                                            </a>
                                            
                                            <!-- Stats -->
                                            <xsl:if test="$text-translation-status/@word-count ! xs:integer(.) gt 0 or $text-translation-status/@glossary-count ! xs:integer(.) gt 0">
                                                <div class="sml-margin top">
                                                    <ul class="list-inline inline-dots small text-muted hidden-print">
                                                        <xsl:if test="$text-translation-status/@word-count ! xs:integer(.) gt 0">
                                                            <li>
                                                                <xsl:value-of select="concat(format-number($text-translation-status/@word-count, '#,###'), ' words translated')"/>
                                                            </li>
                                                        </xsl:if>
                                                        <xsl:if test="$text-translation-status/@glossary-count ! xs:integer(.) gt 0">
                                                            <li>
                                                                <xsl:value-of select="concat(format-number($text-translation-status/@glossary-count, '#,###'), ' glossaries')"/>
                                                            </li>
                                                        </xsl:if>
                                                    </ul>
                                                </div>
                                            </xsl:if>
                                            
                                        </td>
                                        
                                        <!-- Pages / location -->
                                        <td class="nowrap small">
                                            <xsl:variable name="text-pages" select="$text/m:source/m:location/@count-pages ! xs:integer(.)" as="xs:integer?"/>
                                            <xsl:variable name="status-pages" as="xs:integer?">
                                                <xsl:call-template name="status-pages">
                                                    <xsl:with-param name="text" select="."/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <xsl:when test="$status-pages">
                                                    <xsl:value-of select="concat(format-number($status-pages, '#,###'), if($text-pages gt $status-pages) then concat(' of ', format-number($text-pages, '#,###')) else '')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="format-number($text-pages, '#,###')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                        <td class="nowrap small hidden-print">
                                            <xsl:variable name="start-volume-number" select="min($text/m:source/m:location/m:volume/@number)"/>
                                            <xsl:variable name="start-volume" select="$text/m:source/m:location/m:volume[@number ! xs:integer(.) eq $start-volume-number][1]"/>
                                            <xsl:value-of select="concat('vol. ' , $start-volume/@number, ', p. ', $start-volume/@start-page)"/>
                                        </td>
                                        <td class="nowrap small hidden-print">
                                            <xsl:variable name="end-volume-number" select="max($text/m:source/m:location/m:volume/@number)"/>
                                            <xsl:variable name="end-volume" select="$text/m:source/m:location/m:volume[@number ! xs:integer(.) eq $end-volume-number][1]"/>
                                            <xsl:value-of select="concat('vol. ' , $end-volume/@number, ', p. ', $end-volume/@end-page)"/>
                                        </td>
                                        
                                        <!-- Sponsorship -->
                                        <td>
                                            <xsl:copy-of select="ops:sponsorship-status($text/m:sponsorship-status/m:status)"/>
                                        </td>
                                        
                                    </tr>
                                    
                                    <!-- Links -->
                                    <tr class="sub">
                                        <td colspan="5">
                                            
                                            <xsl:call-template name="text-links-list">
                                                <xsl:with-param name="text" select="$text"/>
                                                <xsl:with-param name="exclude-links" select="('source-folios')"/>
                                                <xsl:with-param name="text-status" select="$text-status"/>
                                                <xsl:with-param name="glossary-filter" select="$texts/@filter"/>
                                            </xsl:call-template>
                                            
                                        </td>
                                    </tr>
                                    
                                    <!-- Acknowlegment -->
                                    <xsl:if test="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                        <tr class="sub">
                                            
                                            <td colspan="5">
                                                <div class="pull-quote green-quote no-bottom-margin small">
                                                    
                                                    <xsl:if test="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/@generated">
                                                        <xsl:attribute name="class" select="'pull-quote orange-quote no-bottom-margin small'"/>
                                                    </xsl:if>
                                                    
                                                    <div class="title">
                                                        <xsl:value-of select="'Acknowledgment'"/>
                                                        <xsl:if test="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/@generated">
                                                            <xsl:value-of select="' (auto-generated)'"/>
                                                        </xsl:if>
                                                    </div>
                                                    
                                                    <xsl:apply-templates select="$text/m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                                    
                                                </div>
                                            </td>
                                            
                                        </tr>
                                    </xsl:if>
                                    
                                    <!-- Translation team -->
                                    <tr class="sub">
                                        
                                        <td colspan="5">
                                            <hr/>
                                            <div class="collapse-one-line one-line small italic text-success">
                                                <xsl:variable name="team-contribution-id" select="$text/m:publication/m:contributors/m:summary/@xml:id"/>
                                                <xsl:variable name="translator-team" select="$text/m:contributors/m:team[m:instance/@id = $team-contribution-id]"/>
                                                <xsl:choose>
                                                    <xsl:when test="$translator-team">
                                                        <xsl:value-of select="$translator-team/m:label"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="class" select="'collapse-one-line one-line small italic text-warning'"/>
                                                        <xsl:value-of select="'No translator team set'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                        </td>
                                        
                                    </tr>
                                    
                                    <!-- Notes and statuses -->
                                    <tr class="sub">
                                        
                                        <td colspan="5">
                                            
                                            <!-- Action note -->
                                            <xsl:if test="$text-translation-status/m:action-note[normalize-space(string-join(text(),''))]">
                                                <hr/>
                                                <div class="collapse-one-line one-line small italic text-danger">
                                                    <xsl:value-of select="concat('Awaiting action from: ', $text-translation-status/m:action-note, '. ')"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <!-- Status note -->
                                            <xsl:if test="$text-translation-status/m:progress-note[normalize-space(string-join(text(),''))]">
                                                <hr/>
                                                <div class="collapse-one-line one-line small italic text-danger">
                                                    <xsl:value-of select="$text-translation-status/m:progress-note"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <!-- Text note -->
                                            <xsl:if test="$text-translation-status/m:text-note[normalize-space(string-join(text(),''))]">
                                                <hr/>
                                                <div class="collapse-one-line one-line small italic text-danger">
                                                    <xsl:value-of select="$text-translation-status/m:text-note"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <!-- Project targets -->
                                            <hr/>
                                            <div>
                                                <ul class="list-inline inline-dots">
                                                    
                                                    <xsl:variable name="next-target-date" select="$text-translation-status/m:target-date[@next eq 'true'][1]"/>
                                                    <xsl:choose>
                                                        <xsl:when test="$next-target-date">
                                                            <li>
                                                                
                                                                <xsl:choose>
                                                                    <xsl:when test="xs:integer($next-target-date/@due-days) ge 0">
                                                                        <span class="label label-success">
                                                                            <xsl:value-of select="concat($next-target-date/@due-days, ' days')"/>
                                                                        </span>
                                                                    </xsl:when>
                                                                    <xsl:when test="xs:integer($next-target-date/@due-days) lt 0">
                                                                        <span class="label label-danger">
                                                                            <xsl:value-of select="concat(abs($next-target-date/@due-days), ' overdue')"/>
                                                                        </span>
                                                                    </xsl:when>
                                                                </xsl:choose>
                                                                
                                                                <span class="small italic">
                                                                    <xsl:value-of select="' '"/>
                                                                    <span class="text-danger">
                                                                        <xsl:value-of select="concat('Target date for status ', $next-target-date/@status-id, ' is ', format-dateTime($next-target-date/@date-time, '[D01] [MNn,*-3] [Y]'))"/>
                                                                    </span>
                                                                </span>
                                                                
                                                            </li>
                                                        </xsl:when>
                                                        
                                                        <xsl:when test="not($text/@status-group eq 'published')">
                                                            <li>
                                                                <span class="small italic">
                                                                    <xsl:value-of select="'No target set'"/>
                                                                </span>
                                                            </li>
                                                        </xsl:when>
                                                        
                                                    </xsl:choose>
                                                    
                                                    <xsl:variable name="status-date-start" select="$request/@target-date-start"/>
                                                    <xsl:variable name="status-date-end" select="$request/@target-date-end"/>
                                                    <xsl:variable name="status-updates-in-range" as="element(m:status-update)*">
                                                        <xsl:choose>
                                                            <xsl:when test="$request/@target-date-type eq 'status-date' and ($status-date-start gt '' or $status-date-end gt '')">
                                                                <xsl:sequence select="$text/m:status-updates/m:status-update[@type = ('translation-status', 'publication-status')][if($status-date-start gt '') then @when ! xs:dateTime(.) ge xs:dateTime(xs:date($status-date-start)) else true()][if($status-date-end gt '') then @when ! xs:dateTime(.) le xs:dateTime(xs:date($status-date-end)) else true()]"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:sequence select="$text/m:status-updates/m:status-update[@type = ('translation-status', 'publication-status')][@current-status eq 'true']"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    
                                                    <xsl:for-each select="$status-updates-in-range/m:status-update">
                                                        <li>
                                                            <span class="small italic">
                                                                <xsl:value-of select="concat('Status ', @status, ' set by ', @who, ' on ', format-dateTime(@when, '[D01] [MNn,*-3] [Y]'))"/>
                                                            </span>
                                                        </li>
                                                    </xsl:for-each>
                                                    
                                                    <xsl:if test="$text/@status-group eq 'published'">
                                                        <li>
                                                            <span class="small italic">
                                                                <xsl:value-of select="concat('Publication date: ', format-date($text/m:publication/m:publication-date, '[D01] [MNn,*-3] [Y]'))"/>
                                                            </span>
                                                        </li>
                                                    </xsl:if>
                                                    
                                                </ul>
                                            </div>
                                            
                                            <!-- Sponsorship alerts -->
                                            <xsl:variable name="sponsorship-alerts">
                                                <div>
                                                    <ul class="small list-inline list-dots">
                                                        <xsl:if test="count($text/m:sponsorship-status/m:text) gt 1">
                                                            <li>
                                                                <xsl:value-of select="concat(count($text/m:sponsorship-status/m:text), ' texts combined')"/>
                                                            </li>
                                                        </xsl:if>
                                                        <xsl:if test="$text/m:sponsorship-status/m:cost and not($text/m:sponsorship-status/m:cost/@pages/number() eq $text/m:source/m:location/@count-pages/number())">
                                                            <li class="text-warning">
                                                                <xsl:value-of select="concat('Sponsorship is for ', $text/m:sponsorship-status/m:cost/@pages/number(),' pages')"/>
                                                            </li>
                                                        </xsl:if>
                                                        <xsl:variable name="calculated-rounded-cost" select="ceiling($text/m:sponsorship-status/m:cost/@basic-cost/number() div 1000) * 1000"/>
                                                        <xsl:variable name="cost-of-parts" select="sum($text/m:sponsorship-status/m:cost/m:part/@amount/number())"/>
                                                        <xsl:if test="$text/m:sponsorship-status/m:cost and abs($cost-of-parts - $calculated-rounded-cost) gt 1000">
                                                            <li class="text-warning">
                                                                <xsl:value-of select="concat(format-number($cost-of-parts, '#,###'), ' cost varies from expected ', format-number($calculated-rounded-cost, '#,###'))"/>
                                                            </li>
                                                        </xsl:if>
                                                    </ul>
                                                </div>
                                            </xsl:variable>
                                            <xsl:if test="$sponsorship-alerts//xhtml:li">
                                                <hr/>
                                                <xsl:copy-of select="$sponsorship-alerts"/>
                                            </xsl:if>
                                            
                                        </td>
                                    </tr>
                                    
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:if>
                    
                    <xsl:if test="not(m:texts/m:text)">
                        <hr/>
                        <h4>
                            <xsl:value-of select="'No Results'"/>
                        </h4>
                        <p class="text-muted">
                            <xsl:value-of select="'Please select your search critera from the options above.'"/>
                        </p>
                    </xsl:if>
                    
                    <hr/>
                    <div class="small text-center">
                        <xsl:value-of select="concat('~ ', common:date-user-string('Report generated', current-dateTime(), /m:response/@user-name), ' ~')"/>
                    </div>
                
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Texts | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Project progress report for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="status-pages" as="xs:integer?">
        
        <xsl:param name="text" as="element(m:text)"/>
        
        <xsl:variable name="status-date-start" select="$request/@target-date-start[not(. eq '')] ! xs:date(.) ! xs:dateTime(.)" as="xs:dateTime?"/>
        <xsl:variable name="status-date-end" select="$request/@target-date-end[not(. eq '')] ! xs:date(.) ! xs:dateTime(.)" as="xs:dateTime?"/>
        <xsl:variable name="target-date-type" select="$request/@target-date-type" as="xs:string?"/>
        
        <xsl:variable name="text-status-index" select="$text-statuses[@status-id eq $text/@status]/@index ! xs:integer(.)" as="xs:integer?"/>
        <xsl:variable name="text-status-updates" select="$text/m:status-updates/m:status-update[@type eq 'translation-status'][empty($status-date-start) or @when ! xs:dateTime(.) ge $status-date-start][empty($status-date-end) or @when ! xs:dateTime(.) le $status-date-end][empty($selected-statuses) or @status = $selected-statuses[@index ! xs:integer(.) ge $text-status-index]/@status-id]" as="element(m:status-update)*"/>
        <xsl:variable name="text-status-block-ids" select="$text-status-updates/@target ! replace(., '^#', '')" as="xs:string*"/>
        
        <xsl:choose>
            <!-- Status achieved target date range, so which blocks are relevant? -->
            <xsl:when test="$selected-statuses and $target-date-type eq 'status-date' and (not(empty($status-date-start)) or not(empty($status-date-end)))">
                <xsl:value-of select="sum($text/m:publication-status[@block-id = ($text-status-block-ids, $text/@id)]/@count-pages ! xs:integer(.))"/>
            </xsl:when>
            <!-- Filtered by status, so may not be all parts -->
            <xsl:when test="$selected-statuses">
                <xsl:value-of select="sum($text/m:publication-status[@status = $selected-statuses/@status-id]/@count-pages ! xs:integer(.))"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>