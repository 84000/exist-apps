<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'matching-funds-title'"/>
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'matching-funds-description'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="matching-funds" class="list-group accordion" role="tablist" aria-multiselectable="false">
                
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'matching-funds-sponsors'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'matching-funds-list-title'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <ul>
                            <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'matching-funds']]">
                                <li>
                                    <xsl:value-of select="m:label"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'sutras-title'"/>
                    
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'sutras-description'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="sutra" class="list-group accordion" role="tablist" aria-multiselectable="false">
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'sutra-sponsors'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'sutras-list-title'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <xsl:call-template name="text-list">
                            <xsl:with-param name="texts" select="m:sponsored-texts/m:text"/>
                            <xsl:with-param name="grouping" select="'sponsorship'"/>
                            <xsl:with-param name="show-sponsors" select="true()"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'founding-title'"/>
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'founding-description'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="founding" class="list-group accordion" role="tablist" aria-multiselectable="false">
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'founding-sponsors'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'founding-list-title'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <table class="table no-border">
                            <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'founding']]">
                                <xsl:sort select="xs:integer(fn:substring-after(@xml:id, 'sponsor-'))"/>
                                <tr>
                                    <td class="nowrap">
                                        <xsl:value-of select="concat(position(), '.')"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="m:label"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:with-param>
                </xsl:call-template>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>