<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'84000 Operations text search'"/>
                    </h3>
                    
                    <form action="search.html" method="post" class="bottom-margin">
                        <div class="row">
                            
                            <div class="col-sm-8 print-width-override">
                                <table class="table table-condensed no-border no-padding">
                                    <xsl:for-each select="m:text-statuses/m:status">
                                        <xsl:sort select="@status-id eq '0'"/>
                                        <xsl:sort select="@status-id"/>
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
                                
                            </div>
                            
                            <div class="col-sm-4 print-width-override">
                            
                                <div class="form-group hidden-print">
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
                                
                                <div class="form-group print-no-margin">
                                    <select name="sponsorship-group" class="form-control">
                                        <option value="none">
                                            <xsl:if test="m:texts/@sponsorship-group eq 'none'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'[No sponsor filter]'"/>
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
                                
                                <div class="form-group print-no-margin">
                                    <select name="range" class="form-control">
                                        <option value="0">
                                            <xsl:value-of select="'[No size filter]'"/>
                                        </option>
                                        <xsl:for-each select="m:page-size-ranges/m:range">
                                            <option>
                                                <xsl:attribute name="value" select="@id"/>
                                                <xsl:if test="/m:response/m:texts/@range eq xs:string(@id)">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="concat(@min, ' to ', format-number(@max, '#,###'), ' pages')"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                                
                                <div class="form-group print-no-margin">
                                    <div class="row">
                                        <div class="col-sm-6 print-width-override">
                                            <select name="sort" class="form-control">
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
                                                    <xsl:value-of select="'Sort by Status'"/>
                                                </option>
                                                <option value="longest">
                                                    <xsl:if test="m:texts/@sort eq 'longest'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Longest first'"/>
                                                </option>
                                                <option value="shortest">
                                                    <xsl:if test="m:texts/@sort eq 'shortest'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Shortest first'"/>
                                                </option>
                                            </select>
                                        </div>
                                        <div class="col-sm-6 print-width-override">
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
                                    </div>
                                    
                                </div>
                                
                                <div class="form-group print-no-margin">
                                    <div class="row">
                                        <div class="col-sm-9 hidden-print">
                                            <input type="text" name="search-toh" value="" class="form-control" placeholder="Search for Tohoku">
                                                <xsl:attribute name="value" select="m:texts/@search-toh"/>
                                            </input>
                                        </div>
                                        <div class="col-sm-3 hidden-print">
                                            <input type="submit" value="Search" class="btn btn-primary pull-right"/>
                                        </div>
                                    </div>
                                </div>
                                
                                <xsl:if test="m:texts">
                                    <div class="well well-sm no-bottom-margin small">
                                        <strong>
                                            <xsl:value-of select="format-number(m:texts/@count, '#,###')"/>
                                        </strong>
                                        <xsl:value-of select="' texts / '"/>
                                        <strong>
                                            <xsl:value-of select="format-number(m:texts/@count-pages, '#,###')"/>
                                        </strong>
                                        <xsl:value-of select="' pages / '"/>
                                        <strong>
                                            <xsl:value-of select="format-number(m:texts/@count-words, '#,###')"/>
                                        </strong>
                                        <xsl:value-of select="' words'"/>
                                    </div>
                                </xsl:if>
                            </div>
                        </div>
                    </form>
                    
                    <xsl:if test="xs:integer(m:texts/@count) gt count(m:texts/m:text)">
                        <div class="alert alert-danger small text-center">
                            <xsl:value-of select="concat('This search has ', xs:integer(m:texts/@count), ' results but only the first ', count(m:texts/m:text), ' have been returned.')"/>
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
                                                <xsl:value-of select="/m:response/m:text-statuses/m:status[@status-id eq xs:string(current()/@status)]/@status-id"/>
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
                                                <xsl:value-of select="/m:response/m:text-statuses/m:status[@status-id eq xs:string($preceding-text/@status)]/@status-id"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="status" select="/m:response/m:text-statuses/m:status[@status-id eq $status-id]"/>
                                    <xsl:if test="/m:response/m:texts[@sort eq 'status'] and not($status-id eq $preceding-status-id)">
                                        <tr class="header">
                                            <td colspan="6">
                                                <xsl:value-of select="concat($status/@status-id, ' / ', $status/text())"/>
                                                <xsl:value-of select="concat(' (', format-number(count(/m:response/m:texts/m:text[@status eq $status-id]), '#,###'), ' texts, ', format-number(sum(/m:response/m:texts/m:text[@status eq $status-id]/tei:bibl[1]/tei:location/@count-pages), '#,###'),' pages)')"/>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <tr>
                                        <td>
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
                                            <ul class="list-inline inline-dots no-bottom-margin hidden-print">
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', $text-id)"/>
                                                        <xsl:value-of select="'Edit headers'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', $text-id)"/>
                                                        <xsl:value-of select="'Edit sponsorship'"/>
                                                    </a>
                                                </li>
                                                <xsl:if test="@status-group eq 'published' and m:downloads[@tei-version != m:download/@version]">
                                                    <li>
                                                        <span class="small text-danger">
                                                            <i class="fa fa-exclamation-circle"/>
                                                            <xsl:value-of select="' out-of-date files'"/>
                                                        </span>
                                                    </li>
                                                </xsl:if>
                                            </ul>
                                            <xsl:if test="xs:integer(@word-count) gt 0">
                                                <div class="small text-muted sml-margin top hidden-print">
                                                    <xsl:value-of select="concat(format-number(@word-count, '#,###'), ' words translated')"/>
                                                </div>
                                            </xsl:if>
                                        </td>
                                        <td class="nowrap small">
                                            <xsl:value-of select="format-number(tei:bibl/tei:location/@count-pages, '#,###')"/>
                                        </td>
                                        <td class="nowrap small hidden-print">
                                            <xsl:variable name="start-volume-number" select="min(tei:bibl/tei:location/tei:volume/@number)"/>
                                            <xsl:variable name="start-volume" select="tei:bibl/tei:location/tei:volume[xs:integer(@number) eq $start-volume-number]"/>
                                            <xsl:value-of select="concat('vol. ' , $start-volume/@number, ', p. ', $start-volume/@start-page)"/>
                                        </td>
                                        <td class="nowrap small hidden-print">
                                            <xsl:variable name="end-volume-number" select="max(tei:bibl/tei:location/tei:volume/@number)"/>
                                            <xsl:variable name="end-volume" select="tei:bibl/tei:location/tei:volume[xs:integer(@number) eq $end-volume-number]"/>
                                            <xsl:value-of select="concat('vol. ' , $end-volume/@number, ', p. ', $end-volume/@end-page)"/>
                                        </td>
                                        <td>
                                            
                                            <xsl:copy-of select="common:sponsorship-status(m:sponsorship-status/m:status)"/>
                                            
                                            <ul class="small list-unstyled sml-margin top">
                                                <xsl:if test="count(m:sponsorship-status/m:text) gt 1">
                                                    <li>
                                                        <xsl:value-of select="concat('- ', count(m:sponsorship-status/m:text), ' texts combined')"/>
                                                    </li>
                                                </xsl:if>
                                                <xsl:if test="m:sponsorship-status/m:cost and not(m:sponsorship-status/m:cost/@pages/number() eq tei:bibl/tei:location/@count-pages/number())">
                                                    <li class="text-warning">
                                                        <xsl:value-of select="concat('- ', 'Sponsorship is for ', m:sponsorship-status/m:cost/@pages/number(),' pages')"/>
                                                    </li>
                                                </xsl:if>
                                                <xsl:variable name="calculated-rounded-cost" select="ceiling(m:sponsorship-status/m:cost/@basic-cost/number() div 1000) * 1000"/>
                                                <xsl:variable name="cost-of-parts" select="sum(m:sponsorship-status/m:cost/m:part/@amount/number())"/>
                                                <xsl:if test="m:sponsorship-status/m:cost and abs($cost-of-parts - $calculated-rounded-cost) gt 1000">
                                                    <li class="text-warning">
                                                        <xsl:value-of select="concat('- ', format-number($cost-of-parts, '#,###'), ' cost varies from expected ', format-number($calculated-rounded-cost, '#,###'))"/>
                                                    </li>
                                                </xsl:if>
                                            </ul>
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
                                    <xsl:variable name="translation-status" select="/m:response/m:translation-status/m:text[@text-id eq $text-id]"/>
                                    <xsl:if test="$translation-status/m:*[self::m:action-note | self::m:progress-note | self::m:text-note]/text() | $translation-status/m:task[not(@checked-off)]">
                                        <tr class="sub">
                                            <td colspan="2">
                                                <xsl:if test="/m:response/m:texts[@sort eq 'status']">
                                                    <xsl:attribute name="colspan" select="'1'"/>
                                                </xsl:if>
                                            </td>
                                            <td colspan="5">
                                                
                                                <xsl:if test="$translation-status/m:action-note/text() | $translation-status/m:task[not(@checked-off)]">
                                                    <hr class="xs-margin"/>
                                                    <div class="collapse-one-line small italic text-danger">
                                                        <xsl:value-of select="if($translation-status/m:action-note/text()) then concat('Awaiting action from: ', $translation-status/m:action-note, '. ') else ''"/>
                                                        <xsl:value-of select="if($translation-status/m:task[not(@checked-off)]) then concat(string-join($translation-status/m:task[not(@checked-off)]/text(), ', '), '.') else ''"/>
                                                    </div>
                                                </xsl:if>
                                                
                                                <xsl:if test="$translation-status/m:progress-note/text()">
                                                    <hr class="xs-margin"/>
                                                    <div class="collapse-one-line small italic text-danger">
                                                        <xsl:value-of select="$translation-status/m:progress-note"/>
                                                    </div>
                                                </xsl:if>
                                                
                                                <xsl:if test="$translation-status/m:text-note/text()">
                                                    <hr class="xs-margin"/>
                                                    <div class="collapse-one-line small italic text-danger">
                                                        <xsl:value-of select="$translation-status/m:text-note"/>
                                                    </div>
                                                </xsl:if>
                                                
                                            </td>
                                        </tr>
                                    </xsl:if>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:if>
                    
                    <xsl:if test="not(m:texts/m:text)">
                        <hr/>
                        <h4>No Results</h4>
                        <p class="text-muted">
                            <xsl:value-of select="'Please select your search critera from the options above.'"/>
                        </p>
                    </xsl:if>
                    
                    <hr/>
                    
                    <div class="text-muted small">
                        <xsl:value-of select="common:date-user-string('Report generated', current-dateTime(), /m:response/@user-name)"/>
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