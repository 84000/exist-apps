<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xmldb="http://exist-db.org/xquery/xmldb" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Specify specific glossary ids, or empty for all -->
    <xsl:param name="glossary-id" as="xs:string" select="'none'"/>
    
    <!-- Use cached locations or search the whole -->
    <xsl:param name="use-cache" as="xs:boolean" select="true()"/>
    
    <!-- 
        Select the glossary up front
        - Sort by the phrase with the most words and always find those matches first
    -->
    <xsl:variable name="glossary" as="element(m:item)*">
        <xsl:perform-sort select="/m:translation/m:glossary/m:item">
            <xsl:sort select="xs:integer(m:sort-term/@sort-length)" order="descending"/>
        </xsl:perform-sort>
    </xsl:variable>
    <xsl:variable name="glossary-items-count" select="count($glossary)" as="xs:integer"/>
    <xsl:variable name="glossary-requested" select="$glossary[@uid = $glossary-id]" as="element(m:item)*"/>
    <xsl:variable name="glossary-requested-strings" select="$glossary-requested/m:term[@xml:lang eq 'en']/text() | $glossary-requested/m:alternative/text()" as="xs:string*"/>
    
    <!-- 
        Temporarily encode matches 
        1. To allow the string result to be recursed
        2. To stop subsequent recursions from parsing this result (don't allow matches within matches).
        Matches will be encoded like this
        [[UT22084-040-003-001][Realm of Phenomena]]
        Then encoded like this, to inhibit them being re-matched to another glossary
        %5B%5BUT22084-040-003-001%5D%5BRealm%20of%20Phenomena%5D%5D
    -->
    <xsl:variable name="glossary-delimit-start" select="m:encode-string('[[')"/>
    <xsl:variable name="glossary-delimit-mid" select="m:encode-string('][')"/>
    <xsl:variable name="glossary-delimit-end" select="m:encode-string(']]')"/>
    
    <!-- Copy all nodes -->
    <xsl:template match="node()|@*" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- We don't want to parse some nodes, those we should just copy -->
    <xsl:template match="m:titles | m:long-titles | m:source | m:acknowledgment | m:bibliography | m:parent | m:downloads | m:abbreviations | m:term | m:sort-term | m:alternative | m:entity | m:honoration | m:main-title  | m:sub-title | tei:head | tei:note | tei:term[@type eq 'ignore'] | tei:match | text()[not(normalize-space())] | *[not(normalize-space(data()))]" priority="10">
        <xsl:copy>
            <xsl:copy-of select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Parse marked terms first -->
    <xsl:template match="tei:term[not(@type eq 'ignore')][not($glossary-requested) or matches(m:normalize-data(.), m:matches-regex($glossary-requested-strings), 'i')]" name="glossary-marked" priority="9">
        
        <xsl:variable name="term-content" select="node()"/>
        <xsl:variable name="term-ref" select="@ref" as="xs:string?"/>
        <xsl:variable name="term-text" select="m:normalize-data(data())" as="xs:string?"/>
        
        <xsl:variable name="matching-glossary" as="element(m:item)?">
            <xsl:choose>
                
                <!-- Find the first glossary that matches the ref -->
                <xsl:when test="$term-ref gt ''">
                    <xsl:copy-of select="$glossary[@mode eq 'marked'][@uid = $term-ref][1]"/>
                </xsl:when>
                
                <!-- Find the first glossary that matches the string -->
                <xsl:otherwise>
                    <xsl:copy-of select="$glossary[@mode eq 'marked'][matches($term-text, m:matches-regex(m:term[@xml:lang eq 'en']/text() | m:alternative/text()), 'i')][1]"/>
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="m:search-here(., $matching-glossary)">
                <xsl:copy-of select="m:output-match($matching-glossary/@uid, $term-content, 'marked')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="node()|@*"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Parse nodes that have to be exact matches next -->
    <xsl:template match="tei:title[not($glossary-requested) or matches(m:normalize-data(.), m:matches-regex($glossary-requested-strings), 'i')] | tei:name[not($glossary-requested) or matches(m:normalize-data(.), m:matches-regex($glossary-requested-strings), 'i')]" priority="8">
        
        <xsl:variable name="term-content" select="node()"/>
        <xsl:variable name="term-ref" select="@ref" as="xs:string?"/>
        <xsl:variable name="term-text" select="m:normalize-data(data())" as="xs:string?"/>
        
        <xsl:variable name="matching-glossary" as="element(m:item)?">
            <xsl:copy-of select="$glossary[matches($term-text, m:matches-regex-exact(m:term[@xml:lang eq 'en']/text() | m:alternative/text()), 'i')][1]"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="m:search-here(., $matching-glossary)">
                <xsl:element name="{ local-name(.) }" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="m:output-match($matching-glossary/@uid, $term-content, 'matched')"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="node()|@*"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Parse all other text nodes for matches -->
    <xsl:template match="text()[not($glossary-requested) or matches(m:normalize-data(.), m:matches-regex($glossary-requested-strings), 'i')]" name="glossary-match" priority="7">
        
        <!-- If no index passed, start with 1 -->
        <xsl:param name="glossary-index" as="xs:integer" select="1"/>
        <xsl:param name="text" as="xs:string" select="m:normalize-data(.)"/>
        
        <xsl:choose>
            
            <!-- We are recurring through the terms  -->
            <xsl:when test="$glossary-index le $glossary-items-count">
                
                <xsl:variable name="glossary-item" select="$glossary[$glossary-index]"/>
                
                <xsl:variable name="parsed-text">
                    
                    <xsl:choose>
                        <xsl:when test="$glossary-item[not(@mode) or @mode = ('match', '')]">
                            <xsl:choose>
                                <xsl:when test="m:search-here(., $glossary-item)">
                                    
                                    <!-- Parse the string for these glossary terms -->
                                    <xsl:analyze-string select="$text" regex="{ m:matches-regex($glossary-item/m:term[@xml:lang eq 'en'] | $glossary-item/m:alternative) }" flags="i">
                                        <xsl:matching-substring>
                                            
                                            <!-- First of all pass on as an encoded string  -->
                                            <xsl:value-of select="concat(regex-group(1), $glossary-delimit-start, $glossary-item/@uid, $glossary-delimit-mid, m:encode-string(regex-group(2)), regex-group(3), $glossary-delimit-end,regex-group(4))"/>
                                            
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:value-of select="."/>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                    
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$text"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$text"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:call-template name="glossary-match">
                    
                    <xsl:with-param name="glossary-index" select="$glossary-index + 1"/>
                    <xsl:with-param name="text" select="$parsed-text"/>
                    
                </xsl:call-template>
                
            </xsl:when>
            
            <!-- We are finished with glossaries, now output result nodes -->
            <xsl:otherwise>
                
                <xsl:call-template name="mark-matches">
                    <xsl:with-param name="mark-string" select="$text"/>
                </xsl:call-template>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="mark-matches" as="node()*">
        
        <xsl:param name="mark-string" as="xs:string"/>
        
        <xsl:choose>
            
            <!-- There's something encoded so parse it -->
            <xsl:when test="normalize-space($mark-string) gt '' and contains($mark-string, $glossary-delimit-start) and contains($mark-string, $glossary-delimit-end)">
                
                <xsl:variable name="glossary-and-leading-string" select="substring-before($mark-string, $glossary-delimit-end)"/>
                <xsl:variable name="glossary-string" select="substring-after($glossary-and-leading-string, $glossary-delimit-start)"/>
                <xsl:variable name="leading-string" select="substring-before($glossary-and-leading-string, $glossary-delimit-start)"/>
                <xsl:variable name="trailing-string" select="substring($mark-string, string-length($glossary-and-leading-string) + string-length($glossary-delimit-end) + 1)"/>
                <xsl:variable name="glossary-sequence" select="tokenize($glossary-string, m:escape-for-regex($glossary-delimit-mid))"/>
                
                <xsl:choose>
                    <xsl:when test="count($glossary-sequence) eq 2">
                        
                        <!-- Output leading and glossary strings -->
                        <xsl:value-of select="$leading-string"/>
                        <xsl:variable name="text-content" select="m:decode-string($glossary-sequence[2])"/>
                        <xsl:copy-of select="m:output-match($glossary-sequence[1], $text-content, 'matched')"/>
                        
                        <!-- Parse the remainder string -->
                        <xsl:call-template name="mark-matches">
                            <xsl:with-param name="mark-string" select="$trailing-string"/>
                        </xsl:call-template>
                        
                    </xsl:when>
                    
                    <!-- There was a problem so just output and stop -->
                    <xsl:otherwise>
                        <xsl:value-of select="$mark-string"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            
            <!-- No more encoded strings so output the last chunk -->
            <xsl:otherwise>
                <xsl:value-of select="$mark-string"/>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="m:search-here" as="xs:boolean">
        
        <xsl:param name="node" as="node()"/>
        <xsl:param name="glossary" as="node()?"/>
        
        <xsl:choose>
            <xsl:when test="$glossary">
                <xsl:choose>
                    <xsl:when test="$use-cache">
                        <xsl:variable name="nearest-milestone">
                            <xsl:value-of select="($node/ancestor::*[@uid][1]/@uid | $node/ancestor::*[@nearest-milestone][1]/@nearest-milestone)[1]/string()"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$nearest-milestone and $glossary/m:cache/m:expression[@include eq 'true'][@location eq $nearest-milestone]">
                                <xsl:value-of select="true()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="false()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="true()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="m:output-match">
        
        <xsl:param name="match-glossary-id" as="xs:string"/>
        <xsl:param name="content"/>
        <xsl:param name="mode" as="xs:string"/>
        
        <match xmlns="http://www.tei-c.org/ns/1.0">
            <!-- Set the id -->
            <xsl:attribute name="glossary-id" select="$match-glossary-id"/>
            <xsl:attribute name="match-mode" select="$mode"/>
            <!-- Flag if it's the requested one -->
            <!--<xsl:if test="$match-glossary-id = $glossary-id">
                <xsl:attribute name="requested-glossary" select="'true'"/>
            </xsl:if>-->
            <!-- retain the text -->
            <xsl:copy-of select="$content"/>
        </match>
    </xsl:function>
    
    <xsl:function name="m:matches-regex" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:value-of select="concat('(^|[^-\w])(', string-join($strings[normalize-space(.)] ! normalize-space(.) ! m:escape-for-regex(.), '|'), ')(s|es|&#34;s|s&#34;)?([^-\w]|$)')"/>
        
    </xsl:function>
    
    <xsl:function name="m:matches-regex-exact" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:value-of select="concat('^(', string-join($strings[normalize-space(.)] ! normalize-space(.) ! m:escape-for-regex(.), '|'), ')$')"/>
        
    </xsl:function>
    
    <xsl:function name="m:escape-for-regex" as="xs:string?">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
        
    </xsl:function>
    
    <xsl:function name="m:normalize-data" as="xs:string?">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="replace($arg, '\s+', ' ')"/>
        
    </xsl:function>
    
    <xsl:function name="m:encode-string" as="xs:string">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:value-of select="functx:replace-multi($arg, ('\[', '\]', '\s', '\-'), ('E%5B', 'E%5D', 'E%20', 'E%2D'))"/>
        
    </xsl:function>
    
    <xsl:function name="m:decode-string" as="xs:string">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:value-of select="functx:replace-multi($arg, ('E%5B', 'E%5D', 'E%20', 'E%2D'), ('[', ']', ' ', '-'))"/>
        
    </xsl:function>
    
</xsl:stylesheet>