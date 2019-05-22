<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:ptr">
        <ptr xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="target-id" select="substring-after(@target, '#')"/>
            <xsl:variable name="target" select="//*[@xml:id eq $target-id]"/>
            <xsl:choose>
                <xsl:when test="$target[self::tei:note]">
                    <xsl:attribute name="location" select="'notes'"/>
                    <xsl:value-of select="concat('note ', $target/@index)"/>
                </xsl:when>
                <xsl:when test="$target[self::gloss]">
                    <xsl:attribute name="location" select="'glossary'"/>
                    <xsl:value-of select="normalize-space($target/tei:term[not(@xml:lang)][not(@type)][1]/text())"/>
                </xsl:when>
                <xsl:when test="$target[self::tei:milestone]">
                    <xsl:variable name="group" select="$target/ancestor::*[exists(@prefix)][1]"/>
                    <xsl:attribute name="location" select="$group/name()"/>
                    <xsl:attribute name="chapter-index" select="$group/@chapter-index"/>
                    <xsl:choose>
                        <xsl:when test="text()[normalize-space(.)]">
                            <xsl:value-of select="text()[normalize-space(.)]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$target/@label"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$target-id = ('summary', 'acknowledgements', 'introduction', 'prologue', 'colophon', 'appendix', 'abbreviations', 'bibliography')">
                    <xsl:attribute name="location" select="$target-id"/>
                    <xsl:value-of select="text()[normalize-space(.)]"/>
                </xsl:when>
                <xsl:when test="ancestor::m:item[parent::m:glossary]">
                    <xsl:attribute name="target">
                        <xsl:value-of select="concat(substring-before(ancestor::m:item[parent::m:glossary]/@uri, '#'), @target)"/>
                    </xsl:attribute>
                    <xsl:value-of select="@target"/>
                </xsl:when>
                <xsl:when test="text()[normalize-space(.)]">
                    <xsl:value-of select="text()[normalize-space(.)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Show nothing? -->
                    <xsl:attribute name="location" select="'missing'"/>
                    <xsl:value-of select="'[pointer target not found]'"/>
                </xsl:otherwise>
            </xsl:choose>
        </ptr>
    </xsl:template>
    
    <!-- 
    <xsl:template match="m:notes/m:note">
        <note>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="target-id" select="@uid"/>
            <xsl:variable name="target" select="//*[@xml:id eq $target-id]"/>
            <xsl:variable name="group" select="$target/ancestor::*[exists(@prefix)][1]"/>
            <xsl:attribute name="location" select="$group/name()"/>
            <xsl:attribute name="chapter-index" select="$group/@chapter-index"/>
            <xsl:copy-of select="node()"/>
        </note>
    </xsl:template> -->
    
</xsl:stylesheet>