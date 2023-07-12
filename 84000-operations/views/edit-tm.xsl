<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bcrdb="http://www.bcrdb.org/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="translation" select="/m:response/m:translation" as="element(m:translation)*"/>
    <xsl:variable name="tmx" select="/m:response/tmx:tmx" as="element(tmx:tmx)?"/>
    <xsl:variable name="tmx-text-version" select="$tmx/tmx:header/@eft:text-version" as="xs:string?"/>
    <xsl:variable name="tm-units" select="$tmx/tmx:body/tmx:tu" as="element(tmx:tu)*"/>
    
    <xsl:variable name="first-record" select="/m:response/m:request/@first-record ! xs:integer(.)" as="xs:integer"/>
    <xsl:variable name="max-records" select="/m:response/m:request/@max-records ! xs:integer(.)" as="xs:integer"/>
    <xsl:variable name="filter" select="/m:response/m:request/@filter[string() = ('revisions', 'unmatched', 'nolocation', 'remainder', 'flagged')]" as="xs:string?"/>
    <xsl:variable name="active-record" select="/m:response/m:request/@active-record" as="xs:string?"/>
    <xsl:variable name="job-running" select="/m:response/scheduler:job"/>
    <xsl:variable name="flag-types" select="('requires-attention', 'alternative-source')" as="xs:string*"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Translation Memory Editor'"/>
                        <!--<xsl:value-of select="concat(' / ', $filter)"/>-->
                    </h3>
                    
                    <!-- Text title -->
                    <div class="h4">
                        
                        <a>
                            <xsl:if test="$translation[m:toh]">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html')"/>
                                <xsl:attribute name="target" select="$translation/@id"/>
                                <xsl:value-of select="$translation/m:toh[1]/m:full/data()"/>
                                <xsl:value-of select="' / '"/>
                            </xsl:if>
                            <xsl:value-of select="common:limit-str($translation/m:titles/m:title[@xml:lang eq 'en'][1], 80)"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a class="small underline">
                            <xsl:attribute name="target" select="'check-folios'"/>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', $translation/m:toh[1]/@key, '.html?page=1')"/>
                            <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, '/source/', $translation/m:toh[1]/@key, '.html?page=1')"/>
                            <xsl:attribute name="data-dualview-title" select="'Tibetan source'"/>
                            <xsl:value-of select="'Tibetan source'"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a target="_self" class="small underline" data-loading="Loading...">
                            <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $translation/@id)"/>
                            <xsl:value-of select="'Edit headers'"/>
                        </a>
                        
                        <div class="pull-right">
                            <xsl:sequence select="ops:translation-status($translation/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <xsl:choose>
                        
                        <xsl:when test="$tm-units">
                            
                            <xsl:variable name="tm-noid" select="$tm-units[not(@id)]" as="element(tmx:tu)*"/>
                            <xsl:variable name="tm-remainder" select="$tm-units[not(tmx:tuv[@xml:lang eq 'bo']) or not(tmx:tuv[@xml:lang eq 'en'])]" as="element(tmx:tu)*"/>
                            <xsl:variable name="tm-revisions" select="$tm-units[tmx:prop[@name eq 'revision'][text() eq $tmx-text-version]] except $tm-remainder" as="element(tmx:tu)*"/>
                            <xsl:variable name="tm-unmatched" select="$tm-units[tmx:prop[@name eq 'unmatched'][text() eq $tmx-text-version]] except $tm-remainder" as="element(tmx:tu)*"/>
                            <xsl:variable name="tm-nolocation" select="$tm-units[not(tmx:prop[@name eq 'location-id']/text() gt '')] except ($tm-unmatched | $tm-remainder)" as="element(tmx:tu)*"/>
                            <xsl:variable name="tm-flagged" select="$tm-units[tmx:prop[@name = $flag-types]]" as="element(tmx:tu)*"/>
                            <xsl:variable name="tm-units-filtered" as="element(tmx:tu)*">
                                <xsl:choose>
                                    <xsl:when test="$filter eq 'remainder'">
                                        <xsl:sequence select="$tm-remainder"/>
                                    </xsl:when>
                                    <xsl:when test="$filter eq 'revisions'">
                                        <xsl:sequence select="$tm-revisions"/>
                                    </xsl:when>
                                    <xsl:when test="$filter eq 'unmatched'">
                                        <xsl:sequence select="$tm-unmatched"/>
                                    </xsl:when>
                                    <xsl:when test="$filter eq 'nolocation'">
                                        <xsl:sequence select="$tm-nolocation"/>
                                    </xsl:when>
                                    <xsl:when test="$filter eq 'flagged'">
                                        <xsl:sequence select="$tm-flagged"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$tm-units"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="count-records" select="count($tm-units-filtered)" as="xs:integer"/>
                            <xsl:variable name="tei-revised" select="not($translation/@tei-version eq $tmx-text-version)" as="xs:boolean"/>
                            
                            <!-- Version comparison -->
                            <hr class="sml-margin"/>
                            <div class="center-vertical full-width">
                                <div>
                                    <ul class="list-inline">
                                        <li>
                                            <span class="small">
                                                <xsl:value-of select="'Current TEI version: '"/>
                                            </span>
                                            <span class="label label-default">
                                                <xsl:value-of select="$translation/@tei-version"/>
                                            </span>
                                        </li>
                                        <li>
                                            <span class="small">
                                                <xsl:value-of select="'TM version: '"/>
                                            </span>
                                            <span class="label label-success">
                                                <xsl:if test="$tei-revised">
                                                    <xsl:attribute name="class" select="'label label-danger'"/>
                                                </xsl:if>
                                                <xsl:value-of select="$tmx-text-version"/>
                                            </span>
                                        </li>
                                        <li>
                                            <span class="small italic text-success">
                                                <xsl:if test="$tei-revised">
                                                    <xsl:attribute name="class" select="'small italic text-danger'"/>
                                                </xsl:if>
                                                <xsl:value-of select="concat('Version note: ', $translation/m:status-updates/m:status-update[@type eq 'text-version'][@current-version eq 'true'][1])"/>
                                            </span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            
                            <!-- Filters and pagination -->
                            <hr class="sml-margin"/>
                            <div class="center-vertical full-width sml-margin bottom">
                                
                                <!-- Filters -->
                                <div>
                                    <ul class="nav nav-pills no-bottom-margin" role="tablist">
                                        
                                        <!-- No filter -->
                                        <li role="presentation">
                                            <xsl:if test="not($filter)">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id)"/>
                                                <xsl:value-of select="'All units'"/>
                                            </a>
                                        </li>
                                        
                                        <!-- Revisions -->
                                        <li role="presentation">
                                            <xsl:if test="$filter eq 'revisions'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;filter=revisions')"/>
                                                <xsl:value-of select="'Revised'"/>
                                                <xsl:value-of select="' '"/>
                                                <span class="badge">
                                                    <xsl:value-of select="format-number(count($tm-revisions), '#,###')"/>
                                                </span>
                                            </a>
                                        </li>
                                        
                                        <!-- Un matched -->
                                        <li role="presentation">
                                            <xsl:if test="$filter eq 'unmatched'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;filter=unmatched')"/>
                                                <xsl:value-of select="'Not matched'"/>
                                                <xsl:value-of select="' '"/>
                                                <xsl:variable name="tm-unmatched-count" select="count($tm-unmatched)"/>
                                                <span class="badge">
                                                    <xsl:if test="$tm-unmatched-count gt 0">
                                                        <xsl:attribute name="class" select="'badge badge-alert'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="format-number($tm-unmatched-count, '#,###')"/>
                                                </span>
                                            </a>
                                        </li>
                                        
                                        <!-- No location -->
                                        <li role="presentation">
                                            <xsl:if test="$filter eq 'nolocation'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;filter=nolocation')"/>
                                                <xsl:value-of select="'No location'"/>
                                                <xsl:value-of select="' '"/>
                                                <xsl:variable name="tm-nolocation-count" select="count($tm-nolocation)"/>
                                                <span class="badge">
                                                    <xsl:if test="$tm-nolocation-count gt 0">
                                                        <xsl:attribute name="class" select="'badge badge-alert'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="format-number($tm-nolocation-count, '#,###')"/>
                                                </span>
                                            </a>
                                        </li>
                                        
                                        <!-- No Tibetan -->
                                        <li role="presentation">
                                            <xsl:if test="$filter eq 'remainder'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;filter=remainder')"/>
                                                <xsl:value-of select="'Remainders'"/>
                                                <xsl:value-of select="' '"/>
                                                <xsl:variable name="tm-remainder-count" select="count($tm-remainder)"/>
                                                <span class="badge">
                                                    <xsl:if test="$tm-remainder-count gt 0">
                                                        <xsl:attribute name="class" select="'badge badge-alert'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="format-number($tm-remainder-count, '#,###')"/>
                                                </span>
                                            </a>
                                        </li>
                                        
                                        <!-- Flagged -->
                                        <li role="presentation">
                                            <xsl:if test="$filter eq 'flagged'">
                                                <xsl:attribute name="class" select="'active'"/>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;filter=flagged')"/>
                                                <xsl:value-of select="'Flagged'"/>
                                                <xsl:value-of select="' '"/>
                                                <xsl:variable name="tm-flagged-count" select="count($tm-flagged)"/>
                                                <span class="badge">
                                                    <xsl:if test="$tm-flagged-count gt 0">
                                                        <xsl:attribute name="class" select="'badge badge-alert'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="format-number($tm-flagged-count, '#,###')"/>
                                                </span>
                                            </a>
                                        </li>
                                        
                                    </ul>
                                </div>
                                
                                <!-- Pagination -->
                                <div>
                                    <xsl:sequence select="common:pagination($first-record, $max-records, $count-records, concat('?text-id=', $translation/@id))"/>
                                </div>
                                
                            </div>
                            
                            <!-- Fix ids -->
                            <xsl:if test="$tm-noid and not($job-running)">
                                <div class="alert alert-danger small" id="alert-ids-missing">
                                    <p>
                                        <xsl:value-of select="'Some IDs are missing from this TMX | '"/>
                                        <a href="{concat('/edit-tm.html?text-id=', $translation/@id, '&amp;form-action=fix-ids')}" class="alert-link">
                                            <xsl:value-of select="'Fix missing IDs'"/>
                                        </a>
                                    </p>
                                </div>
                            </xsl:if>
                            
                            <!-- Alert / actions -->
                            <xsl:choose>
                                
                                <xsl:when test="$job-running">
                                    <div class="alert alert-danger" id="alert-tei-revised">
                                        <p>
                                            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                            <xsl:value-of select="' Job running, please wait! '"/>
                                            <xsl:if test="$tmx/tmx:header/@eft:seconds-to-revise">
                                                <xsl:value-of select="concat('This previously took ', format-number(($tmx/tmx:header/@eft:seconds-to-revise ! xs:decimal(.) div 60), '#,##0.##'), ' minutes')"/>
                                            </xsl:if>
                                        </p>
                                    </div>
                                </xsl:when>
                                
                                <xsl:when test="$tei-revised">
                                    <div class="alert alert-warning" id="alert-tei-revised">
                                        <p>
                                            <xsl:value-of select="'The TEI has been revised since this TM was created | '"/>
                                            <a href="{concat('/edit-tm.html?text-id=', $translation/@id, '&amp;form-action=apply-revisions')}" class="alert-link">
                                                <xsl:value-of select="'Apply revisions'"/>
                                            </a>
                                            <xsl:if test="$tmx/tmx:header/@eft:seconds-to-revise">
                                                <small>
                                                    <br/>
                                                    <xsl:value-of select="concat('(This previously took ', format-number(($tmx/tmx:header/@eft:seconds-to-revise ! xs:decimal(.) div 60), '#,##0.##'), ' minutes)')"/>
                                                </small>
                                            </xsl:if>
                                        </p>
                                    </div>
                                </xsl:when>
                                
                                <xsl:when test="$tm-nolocation">
                                    <div class="alert alert-warning" id="alert-tei-revised">
                                        <p>
                                            <xsl:value-of select="concat(format-number(count($tm-nolocation), '#,###'),' units are missing locations | ')"/>
                                             <a href="{concat('/edit-tm.html?text-id=', $translation/@id, '&amp;form-action=apply-revisions')}" class="alert-link">
                                                <xsl:value-of select="'Apply revisions'"/>
                                             </a>
                                            <xsl:if test="$tmx/tmx:header/@eft:seconds-to-revise">
                                                <small>
                                                    <br/>
                                                    <xsl:value-of select="concat('(This previously took ', format-number(($tmx/tmx:header/@eft:seconds-to-revise ! xs:decimal(.) div 60), '#,##0.##'), ' minutes)')"/>
                                                </small>
                                            </xsl:if>
                                        </p>
                                    </div>
                                </xsl:when>
                                
                                <xsl:when test="$tm-remainder">
                                    <div class="alert alert-warning" id="alert-tei-revised">
                                        <p>
                                            <xsl:value-of select="'There is some '"/>
                                            <a href="{concat('/edit-tm.html?text-id=', $translation/@id, '&amp;filter=remainder')}" class="alert-link">
                                                <xsl:value-of select="'remainder'"/>
                                            </a>
                                            <xsl:value-of select="' text left over from the alignment process.'"/>
                                        </p>
                                    </div>
                                </xsl:when>
                                
                            </xsl:choose>
                            
                            <!-- List TM units -->
                            <xsl:choose>
                                
                                <!-- Has units -->
                                <xsl:when test="$tm-units-filtered">
                                    
                                    <div class="div-list">
                                        <xsl:for-each select="subsequence($tm-units-filtered, $first-record, $max-records)">
                                            
                                            <xsl:variable name="tm-unit" select="." as="element(tmx:tu)?"/>
                                            <xsl:variable name="tm-bo" select="string-join($tm-unit/tmx:tuv[@xml:lang eq 'bo']/tmx:seg)" as="xs:string?"/>
                                            <xsl:variable name="tm-en" select="string-join($tm-unit/tmx:tuv[@xml:lang eq 'en']/tmx:seg)" as="xs:string?"/>
                                            <xsl:variable name="row-id" select="concat('row-', ($tm-unit/@id, 'new')[1])" as="xs:string"/>
                                            <xsl:variable name="row-number" select="common:index-of-node($tm-units, $tm-unit)" as="xs:integer"/>
                                            <xsl:variable name="tm-location-id" select="$tm-unit/tmx:prop[@name eq 'location-id'][1]/string()"/>
                                            
                                            <div class="item">
                                                <div class="row">
                                                    
                                                    <xsl:attribute name="id" select="$row-id"/>
                                                    
                                                    <!-- Number / flag column -->
                                                    <div class="col-sm-2">
                                                        
                                                        <span class="number">
                                                            <xsl:value-of select="format-number($row-number, '#,###')"/>
                                                        </span>
                                                        
                                                        <xsl:choose>
                                                            
                                                            <xsl:when test="$tm-unit/tmx:prop[@name eq 'unmatched']">
                                                                <br/>
                                                                <span class="label label-danger">
                                                                    <xsl:value-of select="'Not matched'"/>
                                                                </span>
                                                            </xsl:when>
                                                            
                                                            <xsl:when test="$tm-unit[not(tmx:prop[@name eq 'location-id']/text() gt '')]">
                                                                <br/>
                                                                <span class="label label-warning">
                                                                    <xsl:value-of select="'No location'"/>
                                                                </span>
                                                            </xsl:when>
                                                            
                                                            <xsl:when test="$tm-unit/tmx:prop[@name eq 'revision'][text() eq $tmx-text-version]">
                                                                <br/>
                                                                <span class="label label-success">
                                                                    <xsl:value-of select="'Revised'"/>
                                                                </span>
                                                            </xsl:when>
                                                            
                                                        </xsl:choose>
                                                        
                                                        <xsl:for-each select="$tm-unit/tmx:prop[@name = $flag-types]">
                                                            <br/>
                                                            <xsl:choose>
                                                                <xsl:when test="@name eq 'requires-attention'">
                                                                    <span class="label label-danger">
                                                                        <xsl:value-of select="'Requires attention'"/>
                                                                    </span>
                                                                </xsl:when>
                                                                <xsl:when test="@name eq 'alternative-source'">
                                                                    <span class="label label-warning">
                                                                        <xsl:value-of select="'Alternative source'"/>
                                                                    </span>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <span class="label label-warning">
                                                                        <xsl:value-of select="@name"/>
                                                                    </span>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:for-each>
                                                        
                                                    </div>
                                                    
                                                    <!-- Form column -->
                                                    <div class="col-sm-10">
                                                        
                                                        <xsl:variable name="update-form-id" select="concat('form-update-segment-', $row-id)"/>
                                                        
                                                        <form id="{ $update-form-id }" method="post" class="form form-update stealth">
                                                            
                                                            <xsl:if test="$active-record eq $tm-unit/@id">
                                                                <xsl:attribute name="class" select="'form form-update stealth reveal onload-scroll-target'"/>
                                                            </xsl:if>
                                                            
                                                            <xsl:attribute name="action" select="concat('/edit-tm.html?text-id=', $translation/@id, '#', $row-id)"/>
                                                            <xsl:attribute name="data-loading" select="'Updating translation memory...'"/>
                                                            
                                                            <!-- Action -->
                                                            <input type="hidden" name="form-action" value="update-segment"/>
                                                            <input type="hidden" name="filter" value="{ $filter }"/>
                                                            <input type="hidden" name="first-record" value="{ $first-record }"/>
                                                            <input type="hidden" name="tu-id" value="{ $tm-unit/@id }"/>
                                                            
                                                            <!-- Tibetan -->
                                                            <div class="form-group">
                                                                
                                                                <label for="tm-en-{ $tm-unit/@id }" class="text-muted small sml-margin bottom">
                                                                    <xsl:choose>
                                                                        <xsl:when test="$tm-unit[not(tmx:tuv[@xml:lang eq 'bo'])]">
                                                                            <xsl:value-of select="'Add Tibetan from the source text that matches some or all of the translation'"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="'Only delete Tibetan if it is not from this text. Otherwise add a line break to split a segment in 2.'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </label>
                                                                
                                                                <textarea name="tm-bo" id="tm-en-{ $tm-unit/@id }" class="form-control text-bo onkeypress-ctrlreturn-submit" placeholder="Tibetan segment">
                                                                    <xsl:attribute name="rows" select="ops:textarea-rows($tm-bo, 1, 170)"/>
                                                                    <xsl:value-of select="normalize-space($tm-bo)"/>
                                                                </textarea>
                                                                
                                                            </div>
                                                            
                                                            <!-- Translation -->
                                                            <div class="form-group">
                                                                
                                                                <label for="tm-en-{ $tm-unit/@id }" class="text-muted small sml-margin bottom">
                                                                    <xsl:choose>
                                                                        <xsl:when test="$tm-unit[not(tmx:tuv[@xml:lang eq 'bo'])]">
                                                                            <xsl:value-of select="'TEI content not matched with a Tibetan segment'"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="'Translation'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </label>
                                                                
                                                                <textarea name="tm-en" id="tm-en-{ $tm-unit/@id }" class="form-control monospace onkeypress-ctrlreturn-submit">
                                                                    <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                    <xsl:value-of select="normalize-space($tm-en)"/>
                                                                </textarea>
                                                                
                                                            </div>
                                                            
                                                            <!-- Fixes -->
                                                            <xsl:choose>
                                                                
                                                                <!-- Unmatched -->
                                                                <xsl:when test="$tm-unit[tmx:prop[@name eq 'unmatched']]">
                                                                    
                                                                    <!-- Include the unmatched TEI -->
                                                                    <div class="form-group stealth-hidden">
                                                                        
                                                                        <label for="unmatched-{ $tm-unit/@id }" class="small sml-margin bottom top text-warning">
                                                                            <xsl:value-of select="'Select the matching revised text from the TEI and paste into the field above'"/>
                                                                        </label>
                                                                        
                                                                        <div id="unmatched-{ $tm-unit/@id }">
                                                                            <xsl:for-each select="$tm-remainder[not(tmx:tuv[@xml:lang eq 'bo'])][tmx:tuv[@xml:lang eq 'en']/tmx:seg[text()]]">
                                                                                <p class="form-control monospace">
                                                                                    <xsl:value-of select="tmx:tuv[@xml:lang eq 'en']/tmx:seg"/>
                                                                                </p>
                                                                            </xsl:for-each>
                                                                        </div>
                                                                        
                                                                    </div>
                                                                    
                                                                </xsl:when>
                                                                
                                                            </xsl:choose>
                                                            
                                                            <!-- Footer (Location / buttons) -->
                                                            
                                                            <div class="row  stealth-hidden">
                                                                
                                                                <!-- Location -->
                                                                <div class="col-sm-3">
                                                                    <div class="form-group">
                                                                        
                                                                        <div>
                                                                            
                                                                            <label for="tei-location-id-{ $row-id }" class="text-muted small sml-margin bottom">
                                                                                <xsl:value-of select="'TEI location'"/>
                                                                            </label>
                                                                            
                                                                            <!-- Link to location -->
                                                                            <xsl:if test="$tm-location-id gt ''">
                                                                                
                                                                                <span class="text-muted">
                                                                                    <xsl:value-of select="' / '"/>
                                                                                </span>
                                                                                
                                                                                <a target="{ $translation/@id }-html">
                                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html#', $tm-location-id)"/>
                                                                                    <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html#', $tm-location-id)"/>
                                                                                    <xsl:attribute name="data-dualview-title" select="$translation/m:toh[1]/m:full/data()"/>
                                                                                    <span class="small">
                                                                                        <xsl:value-of select="'Test'"/>
                                                                                    </span>
                                                                                </a>
                                                                                
                                                                            </xsl:if>
                                                                            
                                                                        </div>
                                                                        
                                                                        <input type="text" name="tei-location-id" value="{ $tm-location-id }" id="tei-location-id-{ $row-id }" class="form-control"/>
                                                                        
                                                                    </div>
                                                                    
                                                                </div>
                                                                    
                                                                <!-- Flags -->
                                                                <div class="col-sm-5">
                                                                    <div class="form-group">
                                                                        
                                                                        <label class="text-muted small sml-margin bottom">
                                                                            <xsl:value-of select="'Flags'"/>
                                                                        </label>
                                                                        
                                                                        <div class="row">
                                                                            <xsl:for-each select="$flag-types">
                                                                                
                                                                                <xsl:variable name="flag-name" select="." as="xs:string"/>
                                                                                <xsl:variable name="unit-flag" select="$tm-unit/tmx:prop[@name = $flag-name]"/>
                                                                                
                                                                                <div class="col-sm-{ floor(12 div count($flag-types)) }">
                                                                                    <div class="checkbox">
                                                                                        <label>
                                                                                            
                                                                                            <input type="checkbox" name="tm-flags[]" value="{ $flag-name }">
                                                                                                <xsl:if test="$unit-flag">
                                                                                                    <xsl:attribute name="checked" select="'checked'"/>
                                                                                                </xsl:if>
                                                                                            </input>
                                                                                            
                                                                                            <xsl:choose>
                                                                                                <xsl:when test="$flag-name eq 'requires-attention'">
                                                                                                    <xsl:value-of select="'Requires attention'"/>
                                                                                                </xsl:when>
                                                                                                <xsl:when test="$flag-name eq 'alternative-source'">
                                                                                                    <xsl:value-of select="'Alternative source'"/>
                                                                                                </xsl:when>
                                                                                                <xsl:otherwise>
                                                                                                    <xsl:value-of select="$flag-name"/>
                                                                                                </xsl:otherwise>
                                                                                            </xsl:choose>
                                                                                            
                                                                                            <xsl:if test="$unit-flag">
                                                                                                <br/>
                                                                                                <span class="text-muted small">
                                                                                                    <xsl:value-of select="$unit-flag/@user ! concat(' by ', .) || $unit-flag/@timestamp ! concat(' on ', format-dateTime(., '[D1o] [MNn,*-3] [Y01]'))"/>
                                                                                                </span>
                                                                                            </xsl:if>
                                                                                            
                                                                                        </label>
                                                                                    </div>
                                                                                </div>
                                                                                
                                                                            </xsl:for-each>
                                                                        </div>
                                                                        
                                                                    </div>
                                                                </div>
                                                                
                                                                <!-- Buttons -->
                                                                <div class="col-sm-4">
                                                                    <div class="form-group">
                                                                        
                                                                        <label class="small sml-margin bottom">
                                                                            <xsl:choose>
                                                                                
                                                                                <xsl:when test="$job-running">
                                                                                    <span class="small text-danger">
                                                                                        <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                                                        <xsl:value-of select="' Job running, please wait...'"/>
                                                                                    </span>
                                                                                </xsl:when>
                                                                                
                                                                                <xsl:when test="not($tm-unit/@id gt '')">
                                                                                    <a href="#alert-ids-missing" class="small text-danger">
                                                                                        <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                                                        <xsl:value-of select="' This unit has no unique id value and therefore cannot be updated'"/>
                                                                                    </a>
                                                                                </xsl:when>
                                                                                
                                                                            </xsl:choose>
                                                                        </label>
                                                                        
                                                                        <div class="row">
                                                                            <div class="col-sm-6 text-right">
                                                                                
                                                                                <xsl:if test="$tm-unit/@id gt ''">
                                                                                    <a role="button" class="btn btn-danger btn-sm">
                                                                                        <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;remove-unit=', $tm-unit/@id, '&amp;filter=', $filter)"/>
                                                                                        <xsl:attribute name="data-confirm" select="'Are you sure you want to delete this unit?'"/>
                                                                                        <xsl:value-of select="'Delete'"/>
                                                                                    </a>
                                                                                </xsl:if>
                                                                                
                                                                            </div>
                                                                            
                                                                            <div class="col-sm-6 text-right">
                                                                                
                                                                                <button type="submit" class="btn btn-primary btn-sm">
                                                                                    <xsl:value-of select="'Update'"/>
                                                                                </button>
                                                                                
                                                                            </div>
                                                                        </div>
                                                                        
                                                                    </div>
                                                                </div>
                                                                
                                                            </div>
                                                            
                                                        </form>
                                                        
                                                    </div>
                                                    
                                                </div>
                                            </div>
                                            
                                        </xsl:for-each>
                                    </div>
                                    
                                </xsl:when>
                                
                                <!-- No units -->
                                <xsl:otherwise>
                                    
                                    <hr class="sml-margin"/>
                                    <p class="text-muted italic">
                                        <xsl:value-of select="'No translation memory units'"/>
                                    </p>
                                    
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </xsl:when>
                        
                        <!-- No TM -->
                        <xsl:otherwise>
                            
                            <hr/>
                            <p class="text-muted italic">
                                <xsl:value-of select="'No translation memory found for this text'"/>
                            </p>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </xsl:with-param>
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translation Memory Editor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Create Translation Memory pairs from 84000 TEI files'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>