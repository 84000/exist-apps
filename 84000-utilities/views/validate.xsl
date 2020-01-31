<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <h4>
                <xsl:value-of select="concat('Schema: ', m:results/@schema)"/>
                <xsl:if test="m:results/@type eq 'placeholders'">
                    <xsl:value-of select="concat('| Work: ', m:results/@work)"/>
                </xsl:if>
            </h4>
            
            <table class="table table-responsive table-icons">
                <tbody>
                    <xsl:for-each select="//m:results/m:tei-validation">
                        <xsl:sort select="m:result/@status eq 'valid'"/>
                        <xsl:sort select="@id"/>
                        <tr class="heading">
                            <td rowspan="2">
                                <xsl:choose>
                                    <xsl:when test="m:result/@status eq 'valid'">
                                        <i class="fa fa-check-circle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i class="fa fa-times-circle"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:value-of select="concat(position(), '. ', m:title/text())"/>
                            </td>
                            <td>
                                <xsl:if test="m:result/m:error">
                                    <a role="button" data-toggle="collapse" aria-expanded="false" class="center-vertical text-muted">
                                        <xsl:attribute name="href" select="concat('#errors-', @id)"/>
                                        <xsl:attribute name="aria-controls" select="concat('errors-', @id)"/>
                                        <span>
                                            <xsl:value-of select="'Show errors'"/>
                                        </span>
                                        <span>
                                            <span class="badge badge-notification">
                                                <xsl:value-of select="count(m:result/m:error)"/>
                                            </span>
                                        </span>
                                    </a>
                                </xsl:if>
                            </td>
                        </tr>
                        <tr class="sub">
                            <td colspan="2">
                                <div>
                                    <a class="small">
                                        <xsl:attribute name="href" select="@url"/>
                                        <xsl:attribute name="target" select="@id"/>
                                        <xsl:value-of select="@file-name"/> 
                                    </a>
                                </div>
                                <xsl:if test="m:result/m:error">
                                    <div class="collapse">
                                        <xsl:attribute name="id" select="concat('errors-', @id)"/>
                                        <hr class="sml-margin"/>
                                        <xsl:for-each select="m:result/m:error">
                                            <div class="row small">
                                                <div class="col-sm-1 text-bold">
                                                    <xsl:value-of select="concat('Line ', @line)"/>
                                                </div>
                                                <div>
                                                    <xsl:value-of select="text()"/>
                                                </div>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </xsl:if>
                                
                            </td>
                        </tr>
                        
                    </xsl:for-each>
                </tbody>
            </table>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities tests'"/>
            <xsl:with-param name="page-title" select="'Validation | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Validation for TEI Files'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    
    
</xsl:stylesheet>