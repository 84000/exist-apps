<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Operations Reports
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            <form action="progress.html" method="post">
                                <div class="row">
                                    
                                    <div class="col-sm-8">
                                        <div class="text-bold">Translation statuses</div>
                                        <div class="form-group">
                                            <xsl:for-each select="m:text-statuses/m:status">
                                                <div class="checkbox">
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
                                    
                                    <div class="col-sm-4">
                                    
                                        <div class="form-group">
                                            <select class="form-control" name="section" disabled="disabled">
                                                <option value="O1JC11494">
                                                    <xsl:if test="m:texts/@section eq 'O1JC11494'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Kangyur
                                                </option>
                                                <option value="O1JC7630">
                                                    <xsl:if test="m:texts/@section eq 'O1JC7630'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Tengyur
                                                </option>
                                                <option value="LOBBY">
                                                    <xsl:if test="m:texts/@section eq 'LOBBY'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    All
                                                </option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group">
                                            <select name="sponsored" class="form-control">
                                                <option value="none">
                                                    <xsl:if test="m:texts/@sponsored eq 'none'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    No sponsor filter
                                                </option>
                                                <option value="sponsored">
                                                    <xsl:if test="m:texts/@sponsored eq 'sponsored'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    All sponsored texts
                                                </option>
                                                <option value="fully-sponsored">
                                                    <xsl:if test="m:texts/@sponsored eq 'fully-sponsored'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Fully sponsored texts
                                                </option>
                                                <option value="part-sponsored">
                                                    <xsl:if test="m:texts/@sponsored eq 'part-sponsored'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Part sponsored texts
                                                </option>
                                                <option value="not-sponsored">
                                                    <xsl:if test="m:texts/@sponsored eq 'not-sponsored'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Not sponsored texts
                                                </option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group">
                                            <select name="range" class="form-control">
                                                <option value="0">
                                                    No size filter
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
                                        
                                        <div class="form-group">
                                            <select name="sort" class="form-control">
                                                <option value="toh">
                                                    <xsl:if test="m:texts/@sort eq 'toh'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Sort by Tohoku
                                                </option>
                                                <option value="status">
                                                    <xsl:if test="m:texts/@sort eq 'status'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Sort by Status
                                                </option>
                                                <option value="longest">
                                                    <xsl:if test="m:texts/@sort eq 'longest'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Longest first
                                                </option>
                                                <option value="shortest">
                                                    <xsl:if test="m:texts/@sort eq 'shortest'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    Shortest first
                                                </option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group">
                                            <div class="row">
                                                <div class="col-sm-5">
                                                    <input type="text" name="search-toh" value="" class="form-control" placeholder="Filter Tohs">
                                                        <xsl:attribute name="value" select="m:texts/@search-toh"/>
                                                    </input>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="checkbox">
                                                        <label>
                                                            <input type="checkbox" name="deduplicate" value="true">
                                                                <xsl:if test="m:texts/@deduplicate eq 'true'">
                                                                    <xsl:attribute name="checked" select="'checked'"/>
                                                                </xsl:if>
                                                            </input>
                                                            Deduplicate
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <input type="submit" value="Apply" class="btn btn-primary pull-right"/>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="well well-sm no-bottom-margin">
                                            <strong>
                                                <xsl:value-of select="format-number(count(m:texts/m:text), '#,###')"/>
                                            </strong> texts, 
                                            <strong>
                                                <xsl:value-of select="format-number(sum(m:texts/m:text/tei:bibl/tei:location[@count-pages gt '']/@count-pages), '#,###')"/>
                                            </strong> pages.
                                        </div>
                                        
                                    </div>
                                </div>
                            </form>
                            
                            <table class="table table-responsive">
                                <thead>
                                    <tr>
                                        <th>Toh</th>
                                        <th>Status</th>
                                        <th>Title</th>
                                        <th>Pages</th>
                                        <th>Start</th>
                                        <th>End</th>
                                        <th>Sponsorship</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="m:texts/m:text">
                                        <xsl:variable name="status-id" select="xs:string(@status)"/>
                                        <tr>
                                            <td class="nowrap">
                                                <xsl:choose>
                                                    <xsl:when test="/m:response/m:texts/@deduplicate eq 'true'">
                                                        <xsl:value-of select="m:toh/m:duplicates"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="m:toh/m:base"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:value-of select="m:response/m:texts/@deduplicate"/>
                                            </td>
                                            <td>
                                                <xsl:variable name="status" select="/m:response/m:text-statuses/m:status[@status-id eq $status-id]"/>
                                                <div class="label label-success">
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
                                                </div>
                                            </td>
                                            <td>
                                                <xsl:if test="m:titles/m:parent/m:title">
                                                    <xsl:value-of select="m:titles/m:parent/m:title"/>, 
                                                </xsl:if>
                                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                                <br/>
                                                <small class="text-muted">
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/edit-text.html?id=', @id)"/>
                                                        edit
                                                    </a>
                                                    <xsl:if test="$status-id eq '1'">
                                                        | 
                                                        <a target="_blank">
                                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html')"/>
                                                            view
                                                        </a>
                                                    </xsl:if>
                                                </small>
                                            </td>
                                            <td class="nowrap">
                                                <xsl:value-of select="format-number(tei:bibl/tei:location/@count-pages, '#,###')"/>
                                            </td>
                                            <td class="nowrap">
                                                vol. <xsl:value-of select="tei:bibl/tei:location/tei:start/@volume"/>,
                                                p. <xsl:value-of select="tei:bibl/tei:location/tei:start/@page"/>
                                            </td>
                                            <td class="nowrap">
                                                vol. <xsl:value-of select="tei:bibl/tei:location/tei:end/@volume"/>,
                                                p. <xsl:value-of select="tei:bibl/tei:location/tei:end/@page"/>
                                            </td>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="m:acknowledgment/@sponsored eq 'full'">
                                                        <div class="label label-danger">
                                                            Fully sponsored
                                                        </div>
                                                    </xsl:when>
                                                    <xsl:when test="m:acknowledgment/@sponsored eq 'part'">
                                                        <div class="label label-warning">
                                                            Part sponsored
                                                        </div>
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
            </div>
            
            <xsl:call-template name="link-to-top"/>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Progress :: 84000 Operations'"/>
            <xsl:with-param name="page-description" select="'Project progress report for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>