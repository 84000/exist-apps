<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Section Texts | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Texts belong to a section of the canon'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content">
                        <table id="ajax-content" class="table table-responsive ajax-content">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Toh.</th>
                                    <th>Title</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="m:section/m:texts/m:text">
                                    <xsl:sort select="number(m:toh/@number)"/>
                                    <xsl:sort select="m:toh/@letter"/>
                                    <xsl:sort select="number(m:toh/@chapter-number)"/>
                                    <xsl:sort select="m:toh/@chapter-letter"/>
                                    <tr>
                                        <td rowspan="2" class="text-muted">
                                            <xsl:value-of select="position()"/>.
                                        </td>
                                        <td class="nowrap" rowspan="2">
                                            <xsl:value-of select="m:toh/m:base"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                        </td>
                                        <td class="nowrap">
                                            <div class="center-vertical full-width">
                                                <span class="small">
                                                    <xsl:value-of select="@id"/>
                                                </span>
                                                <span>
                                                    <xsl:copy-of select="common:translation-status(@status-group)"/>
                                                </span>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr class="sub">
                                        <td class="small">
                                            <xsl:value-of select="'File: '"/>
                                            <a class="break">
                                                <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', @resource-id, '.tei')"/>
                                                <xsl:attribute name="target" select="concat(@resource-id, '.tei')"/>
                                                <xsl:value-of select="@uri"/>
                                            </a>
                                        </td>
                                        <td class="small">
                                            <xsl:value-of select="concat(fn:format-number(xs:integer(m:source/m:location/@count-pages),'#,##0'), ' pages')"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
        
    </xsl:template>
    
</xsl:stylesheet>