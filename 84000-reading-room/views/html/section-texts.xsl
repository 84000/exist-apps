<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:webflow="http://read.84000.co/webflow-api" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <xsl:variable name="webflow-api" select="/m:response/webflow:webflow-api"/>
    
    <xsl:template match="m:section">
        
        <xsl:variable name="section" select="."/>
        <xsl:variable name="section-webflow-api-item" select="$webflow-api//webflow:item[@id eq $section/@id]"/>
        
        <div>
            <ul class="list-inline inline-dashes">
                <li>
                    <h2>
                        <xsl:value-of select="(m:page/m:titles/m:title[@type eq 'articleTitle'], m:titles/m:title[@xml:lang eq 'en'])[1]"/>
                    </h2>
                </li>
                <li class="text-muted">
                    <xsl:value-of select="@id"/>
                </li>
                <li>
                    <xsl:choose>
                        <xsl:when test="$section-webflow-api-item and $section-webflow-api-item[not(@updated gt '')]">
                            <span class="label label-warning">
                                <xsl:value-of select="'No Webflow CMS updates'"/>
                            </span>
                        </xsl:when>
                        <xsl:when test="$section-webflow-api-item">
                            <span class="label label-default">
                                <xsl:value-of select="concat('Lastest update to Webflow CMS ', (format-dateTime($section-webflow-api-item/@updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="label label-danger">
                                <xsl:value-of select="'Not linked to Webflow CMS'"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
                <xsl:if test="$section-webflow-api-item[@updated ! xs:dateTime(.) lt $section/@last-updated ! xs:dateTime(.)]">
                    <li>
                        <span class="label label-warning">
                            <xsl:value-of select="concat('Latest update in this section ', (format-dateTime($section/@last-updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                        </span>
                    </li>
                </xsl:if>
            </ul>
        </div>
        
        <table id="ajax-source" class="table table-responsive table-transparent ajax-target">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Toh.</th>
                    <th>Title</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="m:texts/m:text">
                    
                    <xsl:sort select="number(m:toh/@number)"/>
                    <xsl:sort select="m:toh/@letter"/>
                    <xsl:sort select="number(m:toh/@chapter-number)"/>
                    <xsl:sort select="m:toh/@chapter-letter"/>
                    
                    <xsl:variable name="text" select="."/>
                    <xsl:variable name="text-webflow-api-item" select="$webflow-api//webflow:item[@id eq ($text/m:toh)[1]/@key]"/>
                    
                    <tr>
                        <td class="text-muted">
                            <xsl:value-of select="position()"/>.
                        </td>
                        <td class="nowrap">
                            <xsl:value-of select="$text/m:toh/m:base"/>
                        </td>
                        <td>
                            <div>
                                <xsl:choose>
                                    
                                    <!-- Only make it a link if this is displayed in the operations site -->
                                    <xsl:when test="/m:response[@app-id eq 'operations']">
                                        <a>
                                            <xsl:attribute name="href" select="concat('/translation-project.html?id=', $text/@id)"/>
                                            <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
                                        </a>
                                    </xsl:when>
                                    
                                    <xsl:otherwise>
                                        <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
                                    </xsl:otherwise>
                                    
                                </xsl:choose>
                                
                                <span class="text-muted small">
                                    <xsl:value-of select="' / '"/>
                                    <xsl:value-of select="$text/@id"/>
                                </span>
                            </div>
                            
                            <div class="small text-muted">
                                <xsl:value-of select="'File: '"/>
                                <a class="break text-muted">
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text/@resource-id, '.tei')"/>
                                    <xsl:attribute name="target" select="concat($text/@resource-id, '.tei')"/>
                                    <xsl:value-of select="$text/@document-url"/>
                                </a>
                            </div>
                            
                            <div class="center-vertical align-left">
                                
                                <span>
                                    <xsl:choose>
                                        <xsl:when test="$text-webflow-api-item and $text-webflow-api-item[not(@updated gt '')]">
                                            <span class="label label-warning">
                                                <xsl:value-of select="'No Webflow CMS updates yet'"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="$text-webflow-api-item">
                                            <span class="label label-default">
                                                <xsl:value-of select="concat('Lastest update to Webflow CMS ', (format-dateTime($text-webflow-api-item/@updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="label label-danger">
                                                <xsl:value-of select="'Not linked to Webflow CMS'"/>
                                            </span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                                
                                <xsl:if test="$text-webflow-api-item[@updated ! xs:dateTime(.) lt $text/@last-updated ! xs:dateTime(.)]">
                                    <span>
                                        <span class="label label-warning">
                                            <xsl:value-of select="concat('Lastest update to TEI ', (format-dateTime($text/@last-updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                                        </span>
                                    </span>
                                </xsl:if>
                                
                            </div>
                            
                        </td>
                        <td>
                            
                            <table class="table no-border full-width table-transparent">
                                <tbody>
                                    <xsl:for-each select="$text/m:publication-status">
                                        <tr class="vertical-middle">
                                            <td class="small nowrap">
                                                <xsl:value-of select="concat(fn:format-number(xs:integer(@count-pages),'#,##0'), ' pages ')"/>
                                            </td>
                                            <td class="nowrap text-right">
                                                <span>
                                                    <xsl:choose>
                                                        <xsl:when test="@status-group eq 'published'">
                                                            <xsl:attribute name="class" select="'label label-success'"/>
                                                            <xsl:value-of select="concat(@status, ' / ', 'Published')"/>
                                                        </xsl:when>
                                                        <xsl:when test="@status-group eq 'translated'">
                                                            <xsl:attribute name="class" select="'label label-warning'"/>
                                                            <xsl:value-of select="concat(@status, ' / ', 'Translated')"/>
                                                        </xsl:when>
                                                        <xsl:when test="@status-group eq 'in-translation'">
                                                            <xsl:attribute name="class" select="'label label-warning'"/>
                                                            <xsl:value-of select="concat(@status, ' / ', 'In-translation')"/>
                                                        </xsl:when>
                                                        <xsl:when test="@status-group eq 'in-application'">
                                                            <xsl:attribute name="class" select="'label label-danger'"/>
                                                            <xsl:value-of select="concat(@status, ' / ', 'Application pending')"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="class" select="'label label-default'"/>
                                                            <xsl:value-of select="concat(@status, ' / ', 'Not published')"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                            
                        </td>
                    </tr>
                
                </xsl:for-each>
            </tbody>
        </table>
    
    </xsl:template>
    
</xsl:stylesheet>