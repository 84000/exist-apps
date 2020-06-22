<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <h1 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'84000 Project Management: Translations Report '"/>
                    </h1>
                    
                    <form action="search.html" method="post" class="form-horizontal">
                        <div class="row">
                            
                            <!-- Text statuses -->
                            <div class="col-sm-7  print-width-override">
                                
                                <table class="table table-condensed no-border no-padding hidden-print">
                                    <xsl:for-each select="m:text-statuses/m:status">
                                        <xsl:sort select="xs:integer(@index)"/>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="@status-id"/>
                                            </td>
                                            <td>
                                                <input type="checkbox" name="status[]">
                                                    <xsl:attribute name="value" select="@value"/>
                                                    <xsl:attribute name="id" select="concat('status-', position())"/>
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="checked" select="'checked'"/>
                                                    </xsl:if>
                                                </input>
                                            </td>
                                            <td>
                                                <label>
                                                    <xsl:attribute name="for" select="concat('status-', position())"/>
                                                    <xsl:value-of select="text()"/>
                                                    <span class="small text-muted">
                                                        <xsl:value-of select="' / '"/>
                                                        <xsl:choose>
                                                            <xsl:when test="@group eq 'not-started'">
                                                                <xsl:value-of select="'Not started'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:choose>
                                                            <xsl:when test="@group eq 'published'">
                                                                <xsl:value-of select="'Published'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:choose>
                                                            <xsl:when test="@group eq 'translated'">
                                                                <xsl:value-of select="'Translated'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:choose>
                                                            <xsl:when test="@group eq 'in-translation'">
                                                                <xsl:value-of select="'In translation'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </span>
                                                </label>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                                
                                <xsl:if test="m:text-statuses/m:status[@selected eq 'selected']">
                                    <div class="visible-print-block">
                                        <p class="no-bottom-margin">
                                            <xsl:value-of select="'Selected statuses:'"/>
                                        </p>
                                        <ul class="no-top-margin sml-margin bottom">
                                            <xsl:for-each select="m:text-statuses/m:status[@selected eq 'selected']">
                                                <li>
                                                    <xsl:value-of select="concat(@status-id, ' / ', text())"/>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </xsl:if>
                                
                            </div>
                            
                            <div class="col-sm-5 print-width-override">
                                
                                <!-- Kangyur / Tengyur / All -->
                                <div class="form-group hidden-print">
                                    <div class="col-sm-12">
                                        
                                        <select class="form-control" name="work">
                                            <option value="all">
                                                <xsl:if test="m:texts/@work eq 'all'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'[All]'"/>
                                            </option>
                                            <option value="UT4CZ5369">
                                                <xsl:if test="m:texts/@work eq 'UT4CZ5369'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Kangyur'"/>
                                            </option>
                                            <option value="UT23703">
                                                <xsl:if test="m:texts/@work eq 'UT23703'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Tengyur'"/>
                                            </option>
                                        </select>
                                        
                                    </div>
                                </div>
                                
                                <xsl:if test="m:texts/@work = ('UT4CZ5369', 'UT23703')">
                                   <div class="visible-print-block">
                                       <xsl:choose>
                                           <xsl:when test="m:texts/@work eq 'UT4CZ5369'">
                                               <xsl:value-of select="'Work: Kangyur'"/>
                                           </xsl:when>
                                           <xsl:when test="m:texts/@work eq 'UT23703'">
                                               <xsl:value-of select="'Work: Tengyur'"/>
                                           </xsl:when>
                                       </xsl:choose>
                                   </div>
                                </xsl:if>
                                
                                <!-- Sponsorship filter -->
                                <div class="form-group hidden-print">
                                    <div class="col-sm-12">
                                        <select name="sponsorship-group" class="form-control">
                                            <option value="none">
                                                <xsl:if test="m:texts/@sponsorship-group eq 'none'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'[No sponsorship filter]'"/>
                                            </option>
                                            <xsl:for-each select="m:sponsorship-groups/m:group">
                                                <xsl:variable name="group-id" select="@id"/>
                                                <option>
                                                    <xsl:attribute name="value" select="$group-id"/>
                                                    <xsl:if test="/m:response/m:texts/@sponsorship-group eq $group-id">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="m:label"/>
                                                </option>
                                            </xsl:for-each>
                                        </select>
                                    </div>
                                </div>
                                
                                <xsl:if test="not(m:texts/@sponsorship-group eq 'none')">
                                    <div class="visible-print-block">
                                        <xsl:value-of select="concat('Sponsorship group: ', m:sponsorship-groups/m:group[@id eq /m:response/m:texts/@sponsorship-group])"/>
                                    </div>
                                </xsl:if>
                                
                                <!-- Page range -->
                                <div class="form-group hidden-print">
                                    <label for="pages-min" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Number of pages:'"/>
                                    </label>
                                    <div class="col-sm-4">
                                        <input type="number" name="pages-min" id="pages-min" class="form-control" placeholder="min.">
                                            <xsl:attribute name="value" select="m:request/@pages-min"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="number" name="pages-max" id="pages-max" class="form-control" placeholder="max.">
                                            <xsl:attribute name="value" select="m:request/@pages-max"/>
                                        </input>
                                    </div>
                                </div>
                                <xsl:if test="m:request/@pages-min gt '' or m:request/@pages-max gt ''">
                                    <div class="visible-print-block">
                                        <xsl:value-of select="concat('Number of pages:', m:request/@pages-min, ' - ', m:request/@pages-max)"/>
                                    </div>
                                </xsl:if>
                                
                                <!-- Tohoku range -->
                                <div class="form-group hidden-print">
                                    <label for="toh-min" class="col-sm-4 control-label text-left">
                                        <xsl:value-of select="'Tohoku numbers:'"/>
                                    </label>
                                    <div class="col-sm-4">
                                        <input type="number" name="toh-min" id="toh-min" class="form-control" placeholder="min.">
                                            <xsl:attribute name="value" select="m:request/@toh-min"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="number" name="toh-max" id="toh-max" class="form-control" placeholder="max.">
                                            <xsl:attribute name="value" select="m:request/@toh-max"/>
                                        </input>
                                    </div>
                                </div>
                                <xsl:if test="m:request/@toh-min gt '' or m:request/@toh-max gt ''">
                                    <div class="visible-print-block">
                                        <xsl:value-of select="concat('Tohoku numbers:', m:request/@toh-min, ' - ', m:request/@toh-max)"/>
                                    </div>
                                </xsl:if>
                                
                                <!-- Target date -->
                                <div class="form-group hidden-print">
                                    <div class="col-sm-4">
                                        <select name="target-date-type" class="form-control">
                                            <option value="target-date">
                                                <xsl:if test="m:request/@target-date-type eq 'target-date'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Target dates'"/>
                                            </option>
                                            <option value="status-date">
                                                <xsl:if test="m:request/@target-date-type eq 'status-date'">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Status achieved'"/>
                                            </option>
                                        </select>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="date" name="target-date-start" id="target-date-start" class="form-control" placeholder="">
                                            <xsl:attribute name="value" select="m:request/@target-date-start"/>
                                        </input>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="date" name="target-date-end" id="target-date-end" class="form-control" placeholder="">
                                            <xsl:attribute name="value" select="m:request/@target-date-end"/>
                                        </input>
                                    </div>
                                </div>
                                <xsl:variable name="target-date-type-str">
                                    <xsl:choose>
                                        <xsl:when test="m:request/@target-date-type eq 'target-date'">
                                            <xsl:value-of select="'Target dates'"/>
                                        </xsl:when>
                                        <xsl:when test="m:request/@target-date-type eq 'status-date'">
                                            <xsl:value-of select="'Status achieved'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="m:request/@target-date-start gt '' and m:request/@target-date-end gt ''">
                                        <div class="visible-print-block">
                                            <xsl:value-of select="concat($target-date-type-str, ' between: ', format-date(m:request/@target-date-start, '[D01] [MNn,*-3] [Y]'), ' and ', format-date(m:request/@target-date-end, '[D01] [MNn,*-3] [Y]'))"/>
                                        </div>
                                    </xsl:when>
                                    <xsl:when test="m:request/@target-date-start gt ''">
                                        <div class="visible-print-block">
                                            <xsl:value-of select="concat($target-date-type-str, ' from: ', format-date(m:request/@target-date-start, '[D01] [MNn,*-3] [Y]'))"/>
                                        </div>
                                    </xsl:when>
                                    <xsl:when test="m:request/@target-date-end gt ''">
                                        <div class="visible-print-block">
                                            <xsl:value-of select="concat($target-date-type-str, ' until: ', format-date(m:request/@target-date-end, '[D01] [MNn,*-3] [Y]'))"/>
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
                            </div>
                        </div>
                    </form>
                    
                    <!-- Results summary -->
                    <xsl:if test="m:texts">
                        <div class="well well-sm small">
                            Summary: 
                            <strong>
                                <xsl:value-of select="format-number(count(m:texts/m:text), '#,###')"/>
                            </strong>
                            <xsl:value-of select="' texts / '"/>
                            <strong>
                                <xsl:value-of select="format-number(sum(m:texts/m:text/tei:bibl/tei:location/@count-pages ! xs:integer(.)), '#,###')"/>
                            </strong>
                            <xsl:value-of select="' pages / '"/>
                            <strong>
                                <xsl:value-of select="format-number(sum(/m:response/m:translation-status/m:text[@text-id = /m:response/m:texts/m:text/@id]/@word-count ! xs:integer(.)), '#,###')"/>
                            </strong>
                            <xsl:value-of select="' words / '"/>
                            <strong>
                                <xsl:value-of select="format-number(sum(/m:response/m:translation-status/m:text[@text-id = /m:response/m:texts/m:text/@id]/@glossary-count ! xs:integer(.)), '#,###')"/>
                            </strong>
                            <xsl:value-of select="' glossaries'"/>
                        </div>
                    </xsl:if>
                    
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
                                    <xsl:if test="not(/m:response/m:texts[@sort eq 'status'])">
                                        <th>Status</th>
                                    </xsl:if>
                                    <th>Title</th>
                                    <th>Pages</th>
                                    <th class="hidden-print">Start</th>
                                    <th class="hidden-print">End</th>
                                    <th>Sponsorship</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="m:texts/m:text">
                                    
                                    <xsl:variable name="text-id" select="@id"/>
                                    <xsl:variable name="status-id" as="xs:string">
                                        <xsl:choose>
                                            <xsl:when test="/m:response/m:text-statuses/m:status[@status-id eq xs:string(current()/@status)]">
                                                <xsl:value-of select="/m:response/m:text-statuses/m:status[@status-id eq xs:string(current()/@status)][1]/@status-id"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="preceding-text" select="preceding-sibling::m:text[1]"/>
                                    <xsl:variable name="preceding-status-id" as="xs:string">
                                        <xsl:choose>
                                            <xsl:when test="/m:response/m:text-statuses/m:status[@status-id eq xs:string($preceding-text/@status)]">
                                                <xsl:value-of select="/m:response/m:text-statuses/m:status[@status-id eq xs:string($preceding-text/@status)][1]/@status-id"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="status" select="/m:response/m:text-statuses/m:status[@status-id eq $status-id][1]"/>
                                    <xsl:variable name="translation-status" select="/m:response/m:translation-status/m:text[@text-id eq $text-id][1]"/>
                                    
                                    <xsl:if test="/m:response/m:texts[@sort eq 'status'] and not($status-id eq $preceding-status-id)">
                                        <tr class="header">
                                            <td colspan="6">
                                                <xsl:value-of select="concat($status/@status-id, ' / ', $status/text())"/>
                                                <xsl:value-of select="concat(' (', format-number(count(/m:response/m:texts/m:text[@status eq $status-id]), '#,###'), ' texts, ', format-number(sum(/m:response/m:texts/m:text[@status eq $status-id]/tei:bibl[1]/tei:location/@count-pages), '#,###'),' pages)')"/>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    
                                    <tr>
                                        <td rowspan="2">
                                            <xsl:choose>
                                                <xsl:when test="/m:response/m:texts/@deduplicate eq 'text' and m:toh/m:duplicates">
                                                    <xsl:value-of select="m:toh/m:full/text()"/>
                                                    <xsl:for-each select="m:toh/m:duplicates/m:duplicate">
                                                        <br/>
                                                        <span class="nowrap">
                                                            <xsl:value-of select="normalize-space(concat(' / ', m:full/text()))"/>
                                                        </span>
                                                    </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:call-template name="expandable-toh">
                                                        <xsl:with-param name="toh" select="m:toh"/>
                                                    </xsl:call-template>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                        <xsl:if test="not(/m:response/m:texts[@sort eq 'status'])">
                                            <td>
                                                <span>
                                                    <xsl:choose>
                                                        <xsl:when test="@status-group eq 'published'">
                                                            <xsl:attribute name="class" select="'label label-success'"/>
                                                        </xsl:when>
                                                        <xsl:when test="@status-group eq 'translated'">
                                                            <xsl:attribute name="class" select="'label label-primary'"/>
                                                        </xsl:when>
                                                        <xsl:when test="@status-group eq 'in-translation'">
                                                            <xsl:attribute name="class" select="'label label-warning'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="class" select="'label label-default'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:attribute name="title" select="$status/text()"/>
                                                    <xsl:value-of select="if($status-id) then $status-id else '0'"/>
                                                </span>
                                            </td>
                                        </xsl:if>
                                        <td>
                                            <a target="_blank" class="printable">
                                                <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html')"/>
                                                <xsl:choose>
                                                    <xsl:when test="m:titles/m:title[@xml:lang eq 'en']/text()">
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                                    </xsl:when>
                                                    <xsl:when test="m:titles/m:title[@xml:lang eq 'sa-ltn']/text()">
                                                        <xsl:attribute name="class" select="'printable text-sa break'"/>
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'sa-ltn']"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="class" select="'printable text-wy'"/>
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'bo-ltn']"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </a>
                                            <ul class="list-inline inline-dots sml-margin top no-bottom-margin small hidden-print">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', $text-id)"/>
                                                        <xsl:value-of select="'Edit headers'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', $text-id)"/>
                                                        <xsl:value-of select="'Edit sponsorship'"/>
                                                    </a>
                                                </li>
                                                <xsl:if test="$status/@marked-up eq 'true'">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat('/glossary.html?resource-id=', $text-id)"/>
                                                            <xsl:value-of select="'Edit glossary'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                <xsl:if test="@status-group eq 'published' and m:downloads[@tei-version != m:download/@version]">
                                                    <li>
                                                        <span class="text-danger">
                                                            <i class="fa fa-exclamation-circle"/>
                                                            <xsl:value-of select="' out-of-date files'"/>
                                                        </span>
                                                    </li>
                                                </xsl:if>
                                            </ul>
                                            <xsl:if test="$translation-status/@word-count ! xs:integer(.) gt 0 or $translation-status/@glossary-count ! xs:integer(.) gt 0">
                                                <ul class="list-inline inline-dots sml-margin top no-bottom-margin small text-muted hidden-print">
                                                    <xsl:if test="$translation-status/@word-count ! xs:integer(.) gt 0">
                                                        <li>
                                                            <xsl:value-of select="concat(format-number($translation-status/@word-count, '#,###'), ' words translated')"/>
                                                        </li>
                                                    </xsl:if>
                                                    <xsl:if test="$translation-status/@glossary-count ! xs:integer(.) gt 0">
                                                        <li>
                                                            <xsl:value-of select="concat(format-number($translation-status/@glossary-count, '#,###'), ' glossaries')"/>
                                                        </li>
                                                    </xsl:if>
                                                </ul>
                                            </xsl:if>
                                        </td>
                                        <td class="nowrap small">
                                            <xsl:value-of select="format-number(tei:bibl/tei:location/@count-pages, '#,###')"/>
                                        </td>
                                        <td class="nowrap small hidden-print">
                                            <xsl:variable name="start-volume-number" select="min(tei:bibl/tei:location/tei:volume/@number)"/>
                                            <xsl:variable name="start-volume" select="tei:bibl/tei:location/tei:volume[xs:integer(@number) eq $start-volume-number][1]"/>
                                            <xsl:value-of select="concat('vol. ' , $start-volume/@number, ', p. ', $start-volume/@start-page)"/>
                                        </td>
                                        <td class="nowrap small hidden-print">
                                            <xsl:variable name="end-volume-number" select="max(tei:bibl/tei:location/tei:volume/@number)"/>
                                            <xsl:variable name="end-volume" select="tei:bibl/tei:location/tei:volume[xs:integer(@number) eq $end-volume-number][1]"/>
                                            <xsl:value-of select="concat('vol. ' , $end-volume/@number, ', p. ', $end-volume/@end-page)"/>
                                        </td>
                                        <td>
                                            <xsl:copy-of select="common:sponsorship-status(m:sponsorship-status/m:status)"/>
                                        </td>
                                    </tr>
                                    
                                    <tr class="sub">
                                        
                                        <xsl:if test="not(/m:response/m:texts[@sort eq 'status'])">
                                            <td/>
                                        </xsl:if>
                                        <td colspan="5">
                                            
                                            <xsl:if test="$translation-status/m:action-note[normalize-space(text())]">
                                                <hr/>
                                                <div class="collapse-one-line small italic text-danger">
                                                    <xsl:value-of select="concat('Awaiting action from: ', $translation-status/m:action-note, '. ')"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <xsl:if test="$translation-status/m:progress-note[normalize-space(text())]">
                                                <hr/>
                                                <div class="collapse-one-line small italic text-danger">
                                                    <xsl:value-of select="$translation-status/m:progress-note"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <xsl:if test="$translation-status/m:text-note[normalize-space(text())]">
                                                <hr/>
                                                <div class="collapse-one-line small italic text-danger">
                                                    <xsl:value-of select="$translation-status/m:text-note"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <hr/>
                                            <ul class="list-inline inline-dots no-bottom-margin">
                                                <li>
                                                    <xsl:variable name="next-target-date" select="$translation-status/m:target-date[@next eq 'true'][1]"/>
                                                    <xsl:choose>
                                                        <xsl:when test="$next-target-date">
                                                            
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
                                                            
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            
                                                            <span class="small italic">
                                                                <xsl:value-of select="'No target set'"/>
                                                            </span>
                                                            
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </li>
                                                
                                                <xsl:variable name="status-date-start" select="/m:response/m:request/@target-date-start"/>
                                                <xsl:variable name="status-date-end" select="/m:response/m:request/@target-date-end"/>
                                                <xsl:variable name="status-updates-in-range">
                                                    <xsl:choose>
                                                        <xsl:when test="/m:response/m:request/@target-date-type eq 'status-date' and ($status-date-start gt '' or $status-date-end gt '')">
                                                            <xsl:copy-of select="m:status-updates/m:status-update                                                                 [@update eq 'translation-status']                                                                 [if($status-date-start gt '') then @date-time ! xs:dateTime(.) ge xs:dateTime(xs:date($status-date-start)) else true()]                                                                 [if($status-date-end gt '') then @date-time ! xs:dateTime(.) le xs:dateTime(xs:date($status-date-end)) else true()]                                                                 "/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:copy-of select="m:status-updates/m:status-update[@current-status eq 'true']"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                
                                                <xsl:for-each select="$status-updates-in-range/m:status-update">
                                                    <li>
                                                        <span class="small italic">
                                                            <xsl:value-of select="concat('Status ', ./@value, ' set by ', @user, ' on ', format-dateTime(./@date-time, '[D01] [MNn,*-3] [Y]'))"/>
                                                        </span>
                                                    </li>
                                                </xsl:for-each>
                                                
                                            </ul>
                                            
                                            <xsl:variable name="sponsorship-alerts">
                                                <ul class="small list-inline list-dots no-bottom-margin">
                                                    <xsl:if test="count(m:sponsorship-status/m:text) gt 1">
                                                        <li>
                                                            <xsl:value-of select="concat(count(m:sponsorship-status/m:text), ' texts combined')"/>
                                                        </li>
                                                    </xsl:if>
                                                    <xsl:if test="m:sponsorship-status/m:cost and not(m:sponsorship-status/m:cost/@pages/number() eq tei:bibl/tei:location/@count-pages/number())">
                                                        <li class="text-warning">
                                                            <xsl:value-of select="concat('Sponsorship is for ', m:sponsorship-status/m:cost/@pages/number(),' pages')"/>
                                                        </li>
                                                    </xsl:if>
                                                    <xsl:variable name="calculated-rounded-cost" select="ceiling(m:sponsorship-status/m:cost/@basic-cost/number() div 1000) * 1000"/>
                                                    <xsl:variable name="cost-of-parts" select="sum(m:sponsorship-status/m:cost/m:part/@amount/number())"/>
                                                    <xsl:if test="m:sponsorship-status/m:cost and abs($cost-of-parts - $calculated-rounded-cost) gt 1000">
                                                        <li class="text-warning">
                                                            <xsl:value-of select="concat(format-number($cost-of-parts, '#,###'), ' cost varies from expected ', format-number($calculated-rounded-cost, '#,###'))"/>
                                                        </li>
                                                    </xsl:if>
                                                </ul>
                                            </xsl:variable>
                                            <xsl:if test="$sponsorship-alerts/xhtml:ul/xhtml:li">
                                                <hr/>
                                                <xsl:copy-of select="$sponsorship-alerts"/>
                                            </xsl:if>
                                            
                                        </td>
                                    </tr>
                                    
                                    <xsl:if test="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                        <tr class="sub">
                                            <td colspan="2">
                                                <xsl:if test="/m:response/m:texts[@sort eq 'status']">
                                                    <xsl:attribute name="colspan" select="'1'"/>
                                                </xsl:if>
                                            </td>
                                            <td colspan="5">
                                                <div>
                                                    <xsl:choose>
                                                        <xsl:when test="m:sponsors/tei:div[@type eq 'acknowledgment']/@generated">
                                                            <xsl:attribute name="class" select="'pull-quote orange-quote no-bottom-margin'"/>
                                                            <div class="small text-warning">
                                                                <xsl:value-of select="'Auto-generated acknowledgment:'"/>
                                                            </div>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="class" select="'pull-quote green-quote no-bottom-margin'"/>
                                                            <div class="small">
                                                                <xsl:value-of select="'Acknowledgment:'"/>
                                                            </div>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:apply-templates select="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p"/>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    
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
            <xsl:with-param name="page-title" select="'Search | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Project progress report for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>