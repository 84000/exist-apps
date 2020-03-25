<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Specify specific glossary ids, or empty for all -->
    <xsl:param name="glossary-id" as="xs:string"/>
    
    <!-- Specify a section to parse, or empty for all -->
    <xsl:param name="scope" as="xs:string"/>
    
    <!-- Specify an additional term to scan for, or empty for none -->
    <xsl:param name="additional-term" as="xs:string" select="''"/>
    
    <!-- Test data for pointers -->
    <!--<xsl:variable name="pointers" select="doc('/db/apps/84000-data/local/pointers.xml')//m:gloss" as="element(m:gloss)*"/>-->
    
    <!-- 
        Select the glossary up front
        - Sort by the phrase with the most words and always find those matches first
    -->
    <xsl:variable name="glossary" as="element(m:item)*">
        <xsl:perform-sort select="/m:translation/m:glossary/m:item">
            <xsl:sort select="count(tokenize(m:sort-term, '\s+'))" order="descending"/>
        </xsl:perform-sort>
    </xsl:variable>
    <xsl:variable name="glossary-items-count" select="count($glossary)" as="xs:integer"/>
    <xsl:variable name="glossary-requested" select="if(count($glossary-id) eq 1) then $glossary[@uid = $glossary-id] else () " as="element(m:item)?"/>
    <!-- Add the additional term to the requested strings -->
    <xsl:variable name="glossary-requested-strings" select="(($glossary-requested/m:term[@xml:lang eq 'en'] | $glossary-requested/m:alternative ), if($additional-term gt '') then $additional-term else ())" as="xs:string*"/>
    
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
    <xsl:template match="         (: Just copy sections :)         m:titles | m:long-titles | m:source | m:summary | m:acknowledgment | m:bibliography | m:parent | m:downloads | m:abbreviations         (: Just copy m nodes :)         | m:term | m:sort-term | m:alternative         (: Just copy tei nodes :)         | tei:head | tei:note | tei:term[@type eq 'ignore'] | tei:match" priority="10">
        <xsl:copy>
            <xsl:copy-of select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Parse marked terms first -->
    <xsl:template match="tei:term[not(@type eq 'ignore')][matches(replace(data(), '\s+', ' '), m:matches-regex($glossary-requested-strings), 'i')]" name="glossary-marked" priority="9">
        
        <xsl:variable name="term-content" select="node()" as="xs:string?"/>
        <xsl:variable name="term-ref" select="@ref" as="xs:string?"/>
        <xsl:variable name="term-text" select="replace(data(), '\s+', ' ')" as="xs:string?"/>
        
        <xsl:variable name="matching-glossary" as="element(m:item)?">
            <xsl:choose>
                
                <!-- Find the first glossary that matches the ref -->
                <xsl:when test="$term-ref gt ''">
                    <xsl:copy-of select="$glossary[@mode eq 'marked'][@uid = $term-ref][1]"/>
                </xsl:when>
                
                <!-- Find the first glossary that matches the string -->
                <xsl:otherwise>
                    <xsl:copy-of select="$glossary[@mode eq 'marked'][matches($term-text, m:matches-regex((m:term[@xml:lang eq 'en']/text() | m:alternative/text())), 'i')][1]"/>
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:variable>
        
        <match xmlns="http://www.tei-c.org/ns/1.0">
            <!-- Set the id -->
            <xsl:attribute name="glossary-id" select="$matching-glossary/@uid"/>
            <xsl:attribute name="match-mode" select="'marked'"/>
            <!-- Flag if it's the requested one -->
            <xsl:if test="$matching-glossary[@uid eq $glossary-id]">
                <xsl:attribute name="requested-glossary" select="'true'"/>
            </xsl:if>
            <!-- retain the text -->
            <xsl:copy-of select="$term-content"/>
        </match>
        
    </xsl:template>
    
    <!-- Parse all other text nodes for matches -->
    <xsl:template match="text()[matches(replace(., '\s+', ' '), m:matches-regex($glossary-requested-strings), 'i')]" name="glossary-match" priority="8">
    <!--<xsl:template match="tei:*[@nearest-milestone = $pointers[@id eq $glossary-id]/m:ptr/@cRef]//text()" name="glossary-match" priority="8">-->
        
        <!-- If no index passed, start with 1 -->
        <xsl:param name="glossary-index" as="xs:integer" select="1"/>
        <xsl:param name="text" as="xs:string" select="replace(., '\s+', ' ')"/>
        
        <xsl:variable name="nearest-milestone" select="ancestor::tei:*[@nearest-milestone][1]/@nearest-milestone"/>
        
        <xsl:choose>
            
            <!-- We are recurring through the terms  -->
            <xsl:when test="$glossary-index le $glossary-items-count and normalize-space($text)">
                
                <!-- 
                    Select the glossary term(s)
                    - Find the translated term and alternatives
                    - Sort by the phrase with the most words and match those first
                -->
                <xsl:variable name="glossary-item" select="$glossary[$glossary-index]"/>
                <xsl:variable name="glossary-terms" as="xs:string*">
                    <xsl:choose>
                        <!-- If this is the selected glossary use the terms already defined with the additional term added -->
                        <xsl:when test="$glossary-item/@uid eq $glossary-requested/@uid">
                            <xsl:copy-of select="$glossary-requested-strings"/>
                        </xsl:when>
                        <!-- Otherwise derive from the current item -->
                        <xsl:otherwise>
                            <xsl:perform-sort select="$glossary-item/m:term[@xml:lang eq 'en'] | $glossary-item/m:alternative">
                                <xsl:sort select="count(tokenize(., '\s+'))" order="descending"/>
                            </xsl:perform-sort>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:variable>
                
                <!-- Check @mode="match|marked" here -->
                <xsl:call-template name="glossary-match">
                    
                    <xsl:with-param name="glossary-index" select="$glossary-index + 1"/>
                    
                    <xsl:with-param name="text">
                        
                        <xsl:choose>
                            
                            <xsl:when test="$glossary-item[not(@mode) or @mode = ('match', '')][matches($text, m:matches-regex($glossary-terms), 'i')]">
                            <!--<xsl:when test="$glossary-item[not(@mode) or @mode = ('match', '')][$pointers[@id eq $glossary-item/@uid][m:ptr[@cRef eq $nearest-milestone]]]">-->
                                
                                <!-- Parse the string for this glossary -->
                                <xsl:analyze-string select="$text" regex="{ m:matches-regex($glossary-terms) }" flags="i">
                                    <xsl:matching-substring>
                                        
                                        <!-- First of all output as an encoded string  -->
                                        <xsl:value-of select="                                             concat(                                                 regex-group(1),                                                 $glossary-delimit-start,                                                 $glossary-item/@uid,                                                 $glossary-delimit-mid,                                                 (: Encode spaces in the string to inhibit sub matches :)                                                  m:encode-string(regex-group(2)),                                                 regex-group(3),                                                 $glossary-delimit-end,regex-group(4)                                             )                                         "/>
                                        
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                                
                            </xsl:when>
                            
                            <!-- Just copy it -->
                            <xsl:otherwise>
                                <xsl:value-of select="$text"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                        
                    </xsl:with-param>
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
                        <match xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="glossary-id" select="$glossary-sequence[1]"/>
                            <xsl:attribute name="match-mode" select="'matched'"/>
                            <xsl:if test="$glossary-sequence[1] eq $glossary-id">
                                <xsl:attribute name="requested-glossary" select="'true'"/>
                            </xsl:if>
                            <!-- Un-encode the spaces -->
                            <xsl:value-of select="m:decode-string($glossary-sequence[2])"/>
                            <!--<xsl:value-of select=" concat(' (ptrs:',count($pointers),')')"/>-->
                        </match>
                        
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
    
    <xsl:function name="m:matches-regex" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:value-of select="concat('(^|\W)(', string-join($strings[normalize-space(.)] ! normalize-space(.) ! m:escape-for-regex(.), '|'), ')(s|es|&#34;s|s&#34;)?(\W|$)')"/>
        
    </xsl:function>
    
    <xsl:function name="m:escape-for-regex" as="xs:string">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
        
    </xsl:function>
    
    <xsl:function name="m:encode-string">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:value-of select="functx:replace-multi($arg, ('\[', '\]', '\s', '\-'), ('%5B', '%5D', '%20', '%2D'))"/>
        
    </xsl:function>
    
    <xsl:function name="m:decode-string">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:value-of select="functx:replace-multi($arg, ('%5B', '%5D', '%20', '%2D'), ('[', ']', ' ', '-'))"/>
        
    </xsl:function>
    
</xsl:stylesheet>