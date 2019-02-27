<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
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
                                <div class="form-group print-no-margin">
                                    <h4 class="text-bold no-bottom-margin hidden-print">Text statuses:</h4>
                                    <xsl:for-each select="m:text-statuses/m:status">
                                        <div class="checkbox">
                                            <xsl:choose>
                                                <xsl:when test="@selected eq 'selected'">
                                                    <xsl:attribute name="class" select="'checkbox'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="class" select="'checkbox hidden-print'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <label>
                                                <input type="checkbox" name="status[]">
                                                    <xsl:attribute name="value" select="@value"/>
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="checked" select="'checked'"/>
                                                    </xsl:if>
                                                </input>
                                                <xsl:value-of select="text()"/>
                                            </label>
                                        </div>
                                    </xsl:for-each>
                                </div>
                            </div>
                            
                            <div class="col-sm-4 print-width-override">
                            
                                <div class="form-group hidden-print">
                                    <select class="form-control" name="section" disabled="disabled">
                                        <option value="O1JC11494">
                                            <xsl:if test="m:texts/@section eq 'O1JC11494'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Kangyur'"/>
                                        </option>
                                        <option value="O1JC7630">
                                            <xsl:if test="m:texts/@section eq 'O1JC7630'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Tengyur'"/>
                                        </option>
                                        <option value="LOBBY">
                                            <xsl:if test="m:texts/@section eq 'LOBBY'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'All'"/>
                                        </option>
                                    </select>
                                </div>
                                
                                <div class="form-group print-no-margin">
                                    <select name="sponsored" class="form-control">
                                        <option value="none">
                                            <xsl:if test="m:texts/@sponsored eq 'none'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'No sponsor filter'"/>
                                        </option>
                                        <option value="sponsored">
                                            <xsl:if test="m:texts/@sponsored eq 'sponsored'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'All sponsored texts'"/>
                                        </option>
                                        <option value="fully-sponsored">
                                            <xsl:if test="m:texts/@sponsored eq 'fully-sponsored'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Fully sponsored texts'"/>
                                        </option>
                                        <option value="part-sponsored">
                                            <xsl:if test="m:texts/@sponsored eq 'part-sponsored'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Part sponsored texts'"/>
                                        </option>
                                        <option value="not-sponsored">
                                            <xsl:if test="m:texts/@sponsored eq 'not-sponsored'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Not sponsored texts'"/>
                                        </option>
                                    </select>
                                </div>
                                
                                <div class="form-group print-no-margin">
                                    <select name="range" class="form-control">
                                        <option value="0">
                                            <xsl:value-of select="'No size filter'"/>
                                        </option>
                                        <xsl:for-each select="m:texts/m:page-size-ranges/m:range">
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
                                
                                <div class="form-group print-no-margin">
                                    <div class="row">
                                        <div class="col-sm-5 hidden-print">
                                            <input type="text" name="search-toh" value="" class="form-control" placeholder="Filter Tohs">
                                                <xsl:attribute name="value" select="m:texts/@search-toh"/>
                                            </input>
                                        </div>
                                        <div class="col-sm-4 print-width-override">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" name="deduplicate" value="true">
                                                        <xsl:if test="m:texts/@deduplicate eq 'true'">
                                                            <xsl:attribute name="checked" select="'checked'"/>
                                                        </xsl:if>
                                                    </input>
                                                    <xsl:value-of select="'Deduplicate'"/>
                                                </label>
                                            </div>
                                        </div>
                                        <div class="col-sm-3 hidden-print">
                                            <input type="submit" value="Search" class="btn btn-primary pull-right"/>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="well well-sm no-bottom-margin small">
                                    <strong>
                                        <xsl:value-of select="format-number(m:texts/@count, '#,###')"/>
                                    </strong>
                                    <xsl:value-of select="' texts, '"/>
                                    <strong>
                                        <xsl:value-of select="format-number(m:texts/@count-pages, '#,###')"/>
                                    </strong>
                                    <xsl:value-of select="' pages.'"/>
                                </div>
                                
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
                                    <xsl:variable name="status-id" select="xs:string(@status)"/>
                                    <xsl:variable name="status" select="/m:response/m:text-statuses/m:status[@status-id eq $status-id]"/>
                                    <xsl:if test="/m:response/m:texts[@sort eq 'status'] and not(preceding-sibling::m:text[@status eq $status-id])">
                                        <tr class="header">
                                            <td colspan="6">
                                                <xsl:value-of select="$status/text()"/>
                                                <xsl:value-of select="concat(' (', format-number(count(/m:response/m:texts/m:text[@status eq $status-id]), '#,###'), ' texts, ', format-number(sum(/m:response/m:texts/m:text[@status eq $status-id]/tei:bibl[1]/tei:location/@count-pages), '#,###'),' pages)')"/>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <tr>
                                        <td rowspan="2">
                                            <xsl:choose>
                                                <xsl:when test="/m:response/m:texts/@deduplicate eq 'true' and m:toh/m:duplicates">
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
                                            <td rowspan="2">
                                                
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
                                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                            </a>
                                        </td>
                                        <td class="nowrap">
                                            <xsl:value-of select="format-number(tei:bibl/tei:location/@count-pages, '#,###')"/>
                                        </td>
                                        <td class="nowrap hidden-print">
                                            <xsl:value-of select="concat('vol. ' , tei:bibl/tei:location/tei:start/@volume, ', p. ', tei:bibl/tei:location/tei:start/@page)"/>
                                        </td>
                                        <td class="nowrap hidden-print">
                                            <xsl:value-of select="concat('vol. ' , tei:bibl/tei:location/tei:end/@volume, ', p. ', tei:bibl/tei:location/tei:end/@page)"/>
                                        </td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="m:translation/@sponsored eq 'full'">
                                                    <div class="label label-danger">
                                                        <xsl:value-of select="'Fully sponsored'"/>
                                                    </div>
                                                </xsl:when>
                                                <xsl:when test="m:translation/@sponsored eq 'part'">
                                                    <div class="label label-warning">
                                                        <xsl:value-of select="'Part sponsored'"/>
                                                    </div>
                                                </xsl:when>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                    <tr class="sub">
                                        <td colspan="5">
                                            <ul class="list-inline inline-dots no-bottom-margin hidden-print">
                                                <xsl:if test="/m:response/m:permission[@group eq 'utilities']">
                                                    <li>
                                                        <a class="small">
                                                            <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', $text-id)"/>
                                                            <xsl:value-of select="'Edit headers'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', $text-id)"/>
                                                        <xsl:value-of select="'Edit sponsors'"/>
                                                    </a>
                                                </li>
                                            </ul>
                                        </td>
                                    </tr>
                                    <xsl:if test="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                        <tr class="sub">
                                            <td colspan="5">
                                                <div class="pull-quote">
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