<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Ensure eveything is copied -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Parse milestones adding @label -->
    <xsl:template match="tei:milestone">
        <xsl:variable name="this-milestone" select="."/>
        <milestone xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <!-- Get the prefix of the ancestor -->
            <xsl:variable name="group" select="ancestor::*[exists(@prefix)][1]"/>
            <!-- Add a label based on the prefix -->
            <!-- include a soft-hyphen for line breaks -->
            <xsl:attribute name="label" select="concat($group/@prefix, '.', '­', common:index-of-node($group//tei:milestone, .))"/>
        </milestone>
    </xsl:template>
    
    <xsl:template match="tei:*[not(self::tei:milestone)][preceding-sibling::tei:milestone[@xml:id]]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="nearest-milestone" select="preceding-sibling::tei:milestone[@xml:id][1]/@xml:id"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Supress warning -->
    <xsl:template match="m:dummy">
        <!-- ignore -->
    </xsl:template>
    
</xsl:stylesheet>