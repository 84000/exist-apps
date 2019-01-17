<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="1.0" exclude-result-prefixes="xs m">
    
    <xsl:param name="lang" select="'en'"/>
    <xsl:param name="active-url" select="'/'"/>
    <xsl:param name="local-comms-url" select="''"/>
    <xsl:param name="local-reading-room-url" select="'http://read.84000.co'"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat" omit-xml-declaration="yes"/>
    
    <xsl:template match="m:navigation">
        <ul class="nav navbar-nav">
            <xsl:for-each select="m:language[@xml:lang = $lang]/m:item">
                <li>
                    <xsl:choose>
                        
                        <!-- Has child items -->
                        <xsl:when test="m:item">
                            <xsl:attribute name="class">
                                <xsl:choose>
                                    <xsl:when test="@url = $active-url">
                                        <xsl:value-of select="concat(@class,' dropdown-toggle-container', ' active')"/>
                                    </xsl:when>
                                    <xsl:when test="m:item[@url = $active-url]">
                                        <xsl:value-of select="concat(@class,' dropdown-toggle-container', ' active')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat(@class,' dropdown-toggle-container')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <!-- Main nav -->
                            <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                                <xsl:value-of select="m:label"/>
                                <span>
                                    <i class="fa fa-plus"/>
                                    <i class="fa fa-minus"/>
                                </span>
                            </a>
                            
                            <!-- Dropdown sub-nav -->
                            <ul class="dropdown-menu">
                                <xsl:for-each select="m:item">
                                    <li>
                                        <xsl:if test="@url = $active-url">
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="'active'"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="local-url">
                                                    <xsl:with-param name="url" select="@url"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:value-of select="m:label"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                            
                        </xsl:when>
                        
                        <!-- Has no child items -->
                        <xsl:otherwise>
                            <xsl:attribute name="class">
                                <xsl:choose>
                                    <xsl:when test="@url = $active-url">
                                        <xsl:value-of select="concat(@class, ' active')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@class"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="local-url">
                                        <xsl:with-param name="url" select="@url"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:value-of select="m:label"/>
                            </a>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    <xsl:template name="local-url">
        <xsl:param name="url"/>
        <xsl:variable name="standard-comms-url" select="'http://84000.co'"/>
        <xsl:variable name="standard-reading-room-url" select="'http://read.84000.co'"/>
        <xsl:choose>
            <xsl:when test="starts-with($url, $standard-reading-room-url)">
                <xsl:value-of select="concat($local-reading-room-url, substring-after($url, $standard-reading-room-url))"/>
            </xsl:when>
            <xsl:when test="starts-with($url, $standard-comms-url)">
                <xsl:value-of select="concat($local-comms-url, substring-after($url, $standard-comms-url))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>