<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:ptr">
        <ptr xmlns="http://www.tei-c.org/ns/1.0">
            
            <!-- Copy all the current attributes -->
            <xsl:copy-of select="@*"/>
            
            <!-- Set / update the following attributes -->
            <!-- @target is the id of the node referenced e.g. UT22084-051-001-389 -->
            <!-- @location is the section of the text e.g. glossary -->
            <!-- @chapter-index is the chapter number if @location is a chapter -->
            
            <xsl:choose>
                
                <!-- The pointer is in the cumulative glossary -->
                <!-- Point to the target in the particular text defined in the item/@uri -->
                <!-- TO DO: This is a bit dodgy as all the below options could apply -->
                <xsl:when test="/m:response/m:glossary and ancestor::m:item/@uri">
                    <xsl:attribute name="target">
                        <xsl:value-of select="concat(substring-before(ancestor::m:item/@uri, '#'), @target)"/>
                    </xsl:attribute>
                    <xsl:value-of select="@target"/>
                </xsl:when>
                
                <xsl:otherwise>
                    
                    <!-- Get the target of this pointer -->
                    <xsl:variable name="target-id" select="substring-after(@target, '#')"/>
                    <!-- Query it in this page -->
                    <xsl:variable name="target" select="//*[@xml:id eq $target-id]"/>
                    
                    <xsl:choose>
                        
                        <!-- The target is a note -->
                        <xsl:when test="$target[self::tei:note]">
                            <xsl:attribute name="location" select="'notes'"/>
                            <xsl:value-of select="concat('note ', $target/@index)"/>
                        </xsl:when>
                        
                        <!-- The target is a gloss -->
                        <xsl:when test="$target[self::gloss]">
                            <xsl:attribute name="location" select="'glossary'"/>
                            <xsl:value-of select="normalize-space($target/tei:term[not(@xml:lang)][not(@type)][1]/text())"/>
                        </xsl:when>
                        
                        <!-- The target is a milestone -->
                        <xsl:when test="$target[self::tei:milestone]">
                            <xsl:variable name="group" select="$target/ancestor::*[exists(@prefix)][1]"/>
                            <xsl:attribute name="location" select="local-name($group)"/>
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
                        
                        <!-- The target is a section -->
                        <xsl:when test="$target-id = ('summary', 'acknowledgements', 'introduction', 'prologue', 'colophon', 'appendix', 'abbreviations', 'bibliography')">
                            <xsl:attribute name="location" select="$target-id"/>
                            <xsl:value-of select="text()[normalize-space(.)]"/>
                        </xsl:when>
                        
                        <!-- @target not found in this file! Leave @target as it is and show whatever text there is -->
                        <xsl:when test="text()[normalize-space(.)]">
                            <xsl:value-of select="text()[normalize-space(.)]"/>
                        </xsl:when>
                        
                        <!-- @target not found in this file and no text! set @location as missing -->
                        <xsl:otherwise>
                            <xsl:attribute name="location" select="'missing'"/>
                            <xsl:value-of select="'[pointer target not found]'"/>
                        </xsl:otherwise>
                    </xsl:choose>
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