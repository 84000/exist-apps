<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="functions.xsl"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:milestone">
        <milestone xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="group" select="ancestor::*[exists(@prefix)][1]"/>
            <!-- <xsl:attribute name="location" select="$group/name()"/> -->
            <!-- <xsl:attribute name="chapter-index" select="$group/@chapter-index"/> -->
            <xsl:attribute name="label" select="concat($group/@prefix, '.', '­', common:index-of-node($group//tei:milestone, .))"/>
        </milestone>
    </xsl:template>
    
    <xsl:template match="tei:note">
        <note xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="group" select="ancestor::*[exists(@prefix)][1]"/>
            <!-- <xsl:attribute name="location" select="$group/name()"/> -->
            <!-- <xsl:attribute name="chapter-index" select="$group/@chapter-index"/> -->
            <xsl:copy-of select="node()"/>
        </note>
    </xsl:template>
    
</xsl:stylesheet>