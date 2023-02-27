<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <!-- Output as website page -->
    <xsl:import href="common.xsl"/>
    
    <!-- Pre-sort the glossaries by priority -->
    <xsl:variable name="glossary" select="/tei:TEI/tei:text/tei:back/tei:div[@type eq 'glossary']/tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]"/>
    
    <xsl:template match="node()|@*" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" priority="2">
        
        <!-- Prepare the text -->
        <xsl:variable name="text-normalized" as="text()">
            <xsl:choose>
                <!-- 
                    Strip leading or trailing empty text nodes
                    - If it's whitespace only
                    - And it's the first or last node
                    - Return normalized (empty)
                -->
                <xsl:when test="not(normalize-space(.)) and common:index-of-node(../node(), .) = (1, count(../node()))">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <!-- If it's following by a note then leave the whitespace -->
                <xsl:when test="preceding-sibling::tei:*[1][self::tei:note[@place = 'end']]">
                    <xsl:value-of select="common:normalize-data(data(.))"/>
                </xsl:when>
                <!-- If it's trailed by a note then remove the whitespace -->
                <xsl:when test="following-sibling::tei:*[1][self::tei:note[@place = 'end']]">
                    <xsl:value-of select="common:normalize-data(replace(data(.), '\s+$', ''))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="common:normalize-data(data(.))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Evaluate if it's one we want to parse -->
        <xsl:variable name="glossarize" as="xs:boolean">
            <xsl:choose>
                
                <!-- Check the context -->
                <xsl:when test="not(m:glossarize-context(.))">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- Check the content -->
                <xsl:when test="$text-normalized[not(normalize-space(.))]">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- Check the content -->
                <xsl:when test="$text-normalized[not(matches(.,'[a-zA-Z]'))]">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- TEI elements we don't want to process -->
                <xsl:when test="parent::tei:ptr | parent::tei:ref[@target] | parent::tei:lb | parent::tei:milestone | parent::tei:term[not(@type eq 'definition')] | ancestor::tei:head">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:value-of select="true()"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:variable>
        
        <!-- Parse the text -->
        <xsl:choose>
            
            <xsl:when test="$glossarize">
                <xsl:call-template name="glossarize-text">
                    <xsl:with-param name="text-node" select="."/>
                    <xsl:with-param name="text-normalized" select="$text-normalized"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- Output un-parsed by default -->
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Check the context of the node is a somewhere to glossarize -->
    <xsl:function name="m:glossarize-context" as="xs:boolean">
        
        <xsl:param name="node" as="node()"/>
        
        <xsl:choose>
            
            <xsl:when test="$node[ancestor-or-self::*[@rend eq 'ignoreGlossary']]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <xsl:when test="not($node[ancestor::tei:div[@type = ('summary', 'introduction', 'translation')]])">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:function>
    
    <!-- Glossarize a text node -->
    <xsl:template name="glossarize-text">
        
        <xsl:param name="text-node" as="text()"/>
        <xsl:param name="text-normalized" as="text()"/>
        
        <!-- Exclude itself if this is a glossary definition -->
        <xsl:variable name="exclude-gloss-ids" select="$text-node/ancestor::tei:gloss[1]/@xml:id"/>
        
        <!-- Narrow down the glossary items - we don't want to scan them all -->
        <xsl:variable name="match-glossary-items" as="element(tei:gloss)*">
            <xsl:for-each select="$glossary[not(@mode eq 'marked')][not(@xml:id = $exclude-gloss-ids)]">
                
                <xsl:variable name="terms" select="m:glossary-terms-to-match(.)"/>
                
                <!-- Do an initial check to avoid too much recursion -->
                <xsl:variable name="match-glossary-item-terms-regex" as="xs:string">
                    <xsl:value-of select="common:matches-regex($terms)"/>
                </xsl:variable>
                
                <!-- If it matches then include it in the scan -->
                <xsl:if test="matches($text-normalized, $match-glossary-item-terms-regex, 'i')">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- Recursively scan for matches -->
            <xsl:when test="$match-glossary-items">
                <xsl:call-template name="scan-text">
                    <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
                    <xsl:with-param name="match-glossary-index" select="1"/>
                    <xsl:with-param name="text" select="$text-normalized"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- Otherwise output -->
            <xsl:otherwise>
                <xsl:value-of select="$text-normalized"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Recursively hunt for matches -->
    <xsl:template name="scan-text">
        
        <xsl:param name="match-glossary-items" as="element(tei:gloss)*"/>
        <xsl:param name="match-glossary-index" as="xs:integer"/>
        <xsl:param name="text" as="xs:string"/>
        
        <!-- We are recursing through the terms  -->
        <xsl:choose>
            
            <xsl:when test="$text[normalize-space()] and $match-glossary-index le count($match-glossary-items)">
                
                <xsl:variable name="match-glossary-item" select="$match-glossary-items[$match-glossary-index]"/>
                <xsl:variable name="match-glossary-item-terms-regex" select="common:matches-regex(m:glossary-terms-to-match($match-glossary-item))"/>
                
                <xsl:analyze-string regex="{ $match-glossary-item-terms-regex }" select="$text" flags="i">
                    
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ref" select="$match-glossary-item/@xml:id"/>
                            <xsl:value-of select="concat(regex-group(2), regex-group(3), '')"/>
                        </xsl:element>
                        <xsl:value-of select="regex-group(4)"/>
                    </xsl:matching-substring>
                    
                    <xsl:non-matching-substring>
                        <xsl:call-template name="scan-text">
                            <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
                            <xsl:with-param name="match-glossary-index" select="$match-glossary-index + 1"/>
                            <xsl:with-param name="text" select="."/>
                        </xsl:call-template>
                    </xsl:non-matching-substring>
                    
                </xsl:analyze-string>
                
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Get relevant terms from gloss -->
    <xsl:function name="m:glossary-terms-to-match" as="xs:string*">
        <xsl:param name="glossary-items" as="element(tei:gloss)*"/>
        <xsl:sequence select="$glossary-items/tei:term[not(@type eq 'definition')][not(@xml:lang) or @xml:lang eq 'en'][normalize-space(data())]/data()"/>
    </xsl:function>
    
</xsl:stylesheet>