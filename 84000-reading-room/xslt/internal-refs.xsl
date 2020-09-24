<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Ensure eveything is copied -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Parse pointers resolving internal links -->
    <xsl:template match="tei:ptr">
        <ptr xmlns="http://www.tei-c.org/ns/1.0">
            
            <!-- Copy all the current attributes -->
            <xsl:copy-of select="@*"/>
            <!--<xsl:attribute name="debug" select="''"/>-->
            
            <!-- Set / update the following attributes -->
            <!-- @target is the id of the node referenced e.g. UT22084-051-001-389 -->
            <!-- @location is the section of the text e.g. glossary -->
            
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
                    <xsl:variable name="target" select="/m:translation/m:section//tei:*[@xml:id eq $target-id][1]"/>
                    
                    <xsl:choose>
                        
                        <!-- The target is a note -->
                        <xsl:when test="$target[self::tei:note]">
                            <xsl:attribute name="location" select="'end-notes'"/>
                            <xsl:value-of select="concat('n.', $target/@index)"/>
                        </xsl:when>
                        
                        <!-- The target is a gloss -->
                        <!-- This is wrong! gloss is already processed to m:item -->
                        <xsl:when test="$target[self::tei:gloss]">
                            <xsl:attribute name="location" select="'glossary'"/>
                            <xsl:value-of select="normalize-space($target/tei:term[not(@xml:lang)][not(@type = ('definition','alternative'))][1])"/>
                        </xsl:when>
                        
                        <!-- The target is a milestone -->
                        <xsl:when test="$target[self::tei:milestone]">
                            <xsl:variable name="group" select="$target/ancestor::m:section[@nesting eq '0'][1]"/>
                            <xsl:attribute name="location" select="$group/@section-id"/>
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
                        <xsl:when test="$target-id = ('summary', 'acknowledgements', 'introduction', 'prologue', 'homage', 'colophon', 'appendix', 'abbreviations', 'bibliography')">
                            <xsl:attribute name="location" select="$target-id"/>
                            <xsl:value-of select="text()[normalize-space(.)]"/>
                        </xsl:when>
                        
                        <!-- @target not found in this file! Leave @target as it is and show whatever text there is -->
                        <!-- This allows use as a standard link -->
                        <xsl:when test="@target and text()[normalize-space(.)]">
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
    
    <!-- Parse refs adding indexes -->
    <xsl:variable name="toh-key" select="m:translation/m:source/@key"/>
    
    <!-- Get valid refs for this rendering in the translation -->
    <xsl:variable name="folio-refs" select="m:translation/m:section[@type eq 'translation']//tei:ref[@type eq 'folio'][not(@rend) or not(@rend eq 'hidden')][not(@key) or @key eq $toh-key][not(ancestor::tei:note)]"/>
    
    <xsl:template match="tei:ref">
        
        <xsl:variable name="current-ref" select="current()"/>
        
        <!-- Just set the index -->
        <xsl:variable name="ref-index" select="common:index-of-node($folio-refs, $current-ref)"/>
        
        <xsl:choose>
            
            <!-- Add the index of the folio -->
            <xsl:when test="$ref-index">
                <ref xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="ref-index" select="$ref-index"/>
                    <xsl:copy-of select="node()"/>
                </ref>
            </xsl:when>
            
            <!-- strip these -->
            <xsl:when test="@key and not(@key eq $toh-key)">
                <!-- ignore -->
            </xsl:when>
            
            <!--make a copy of all other refs -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:copy>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <!-- Add indexes to glossaries -->
    <xsl:template match="m:translation/m:section[@type eq 'glossary']">
        <xsl:element name="{ node-name(.) }">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*[not(self::m:item)]"/>
            <xsl:for-each select="m:item">
                <xsl:sort select="m:sort-term"/>
                <xsl:element name="{ node-name(.) }">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="index" select="position()"/>
                    <xsl:apply-templates select="*"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- TO DO: Add indexes to notes -->
    
    <!-- Supress warning -->
    <!--<xsl:template match="m:dummy">
        <!-\- ignore -\->
    </xsl:template>-->
    
</xsl:stylesheet>