<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <!--<xsl:variable name="environment" select="/m:response/m:environment"/>-->
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="alert alert-info small text-center">
                <p>This page tracks and validates links between texts defined in the tei header, specifically tei:fileDesc/tei:sourceDesc/tei:link nodes with a target attribute <br/>e.g. &lt;link target="toh123"/&gt;</p>
            </div>
            
            <div class="div-list">
                <xsl:for-each select="m:text">
                    
                    <xsl:sort select="number(m:toh/@number)"/>
                    <xsl:sort select="m:toh/@letter"/>
                    <xsl:sort select="number(m:toh/@chapter-number)"/>
                    <xsl:sort select="m:toh/@chapter-letter"/>
                    
                    <div class="item">
                        
                        <div>
                            
                            <strong>
                                <xsl:value-of select="m:toh/m:full"/>
                            </strong>
                            <xsl:value-of select=" ' / '"/>
                            <xsl:value-of select="@id"/>
                            <xsl:value-of select=" ' '"/>
                            
                            <!-- Published flag -->
                            <span class="label label-warning">
                                <xsl:choose>
                                    <xsl:when test="@status-group eq 'published'">
                                        <xsl:attribute name="class" select="'label label-success'"/>
                                        <xsl:value-of select="'Text published'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Text not published'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                            
                        </div>
                        
                        <div>
                            <xsl:value-of select="(m:titles/m:title[@xml:lang eq 'en'][text()], m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1]"/>
                        </div>
                        
                        <div class="collapse-one-line">
                            <a class="small text-muted">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', @id, '.tei')"/>
                                <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                <xsl:value-of select="@document-url"/>
                            </a>
                        </div>
                        
                        <div>
                            <table class="table no-border width-auto">
                                <xsl:for-each select="m:link">
                                    <tr class="vertical-middle">
                                        <td>
                                            <xsl:value-of select="' ↳ '"/>
                                        </td>
                                        <td>
                                            
                                            <code class="small">
                                                <xsl:value-of select="@type"/>
                                            </code>
                                            <xsl:value-of select=" ' '"/>
                                            
                                            <xsl:choose>
                                                <xsl:when test="m:text">
                                                    
                                                    <span class="label label-info">
                                                        <xsl:value-of select="m:text/m:toh/m:full"/>
                                                    </span>
                                                    <xsl:value-of select=" ' '"/>
                                                    
                                                    <!-- Published flag -->
                                                    <span class="label label-warning">
                                                        <xsl:choose>
                                                            <xsl:when test="m:text/@status-group eq 'published'">
                                                                <xsl:attribute name="class" select="'label label-success'"/>
                                                                <xsl:value-of select="'Text published'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'Text not published'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="@target"/>
                                                        <xsl:value-of select=" ' '"/>
                                                        <xsl:value-of select="' is an invalid target!'"/>
                                                    </span>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </td>
                                    </tr>
                                    <xsl:if test="m:text">
                                        <tr class="sub">
                                            <td/>
                                            <td>
                                                <xsl:value-of select="(m:text/m:titles/m:title[@xml:lang eq 'en'][text()], m:text/m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], m:text/m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1]"/>
                                            </td>
                                        </tr>
                                        <tr class="sub">
                                            <td/>
                                            <td>
                                                <div class="collapse-one-line">
                                                    <a class="small text-muted">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:text/@id, '.tei')"/>
                                                        <xsl:attribute name="target" select="concat(m:text/@id, '.tei')"/>
                                                        <xsl:value-of select="m:text/@document-url"/>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    
                                </xsl:for-each>
                            </table>
                        </div>
                    
                    </div>
                </xsl:for-each>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Linked Texts | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Links between the texts'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>