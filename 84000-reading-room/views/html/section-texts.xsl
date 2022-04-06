<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <xsl:template match="m:section">
        <h2 class="no-top-margin">
            <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
            <small class="text-muted">
                <xsl:value-of select="' / '"/>
                <xsl:value-of select="@id"/>
            </small>
        </h2>
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
                    <tr>
                        <td rowspan="2" class="text-muted">
                            <xsl:value-of select="position()"/>.
                        </td>
                        <td class="nowrap" rowspan="2">
                            <xsl:value-of select="m:toh/m:base"/>
                        </td>
                        <td>
                            <xsl:choose>
                                
                                <!-- Only make it a link if this is displayed in the operations site -->
                                <xsl:when test="/m:response[@app-id eq 'operations']">
                                    <a>
                                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', @id)"/>
                                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                    </a>
                                </xsl:when>
                                
                                <xsl:otherwise>
                                    <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
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
                                <xsl:value-of select="@document-url"/>
                            </a>
                        </td>
                        <td class="small">
                            <xsl:value-of select="concat(fn:format-number(xs:integer(m:source/m:location/@count-pages),'#,##0'), ' pages')"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    
</xsl:stylesheet>