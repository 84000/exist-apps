<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
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
                        <td class="text-muted">
                            <xsl:value-of select="position()"/>.
                        </td>
                        <td class="nowrap">
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
                            
                            <span class="text-muted small">
                                <xsl:value-of select="' / '"/>
                                <xsl:value-of select="@id"/>
                            </span>
                            
                            <br/>
                            
                            <div class="small text-muted">
                                <xsl:value-of select="'File: '"/>
                                <a class="break text-muted">
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', @resource-id, '.tei')"/>
                                    <xsl:attribute name="target" select="concat(@resource-id, '.tei')"/>
                                    <xsl:value-of select="@document-url"/>
                                </a>
                            </div>
                            
                        </td>
                        <td>
                            
                            <table class="table no-border full-width table-transparent">
                                <tbody>
                                    <xsl:for-each select="m:publication-status">
                                        <tr>
                                            <td class="small nowrap">
                                                <xsl:value-of select="concat(fn:format-number(xs:integer(@count-pages),'#,##0'), ' pages ')"/>
                                            </td>
                                            <td class="nowrap text-right">
                                                <xsl:sequence select="common:translation-status(@status-group)"/>
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