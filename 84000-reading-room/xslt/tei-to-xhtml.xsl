<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <!-- Transforms tei to xhtml -->
    
    <!-- Output as webpage -->
    <xsl:import href="webpage.xsl"/>
    
    <!-- Global variables -->
    <xsl:variable name="translation" select="/m:response/m:translation" as="element(m:translation)?"/>
    <xsl:variable name="section" select="/m:response/m:section" as="element(m:section)?"/>
    <xsl:variable name="knowledgebase" select="/m:response/m:knowledgebase" as="element(m:knowledgebase)?"/>
    <xsl:variable name="entities" select="/m:response/m:entities/m:entity" as="element(m:entity)*"/>
    <!--<xsl:variable name="quotes" select="/m:response/m:quotes/m:quote" as="element(m:quote)*"/>-->
    <xsl:variable name="requested-resource" select="/m:response/m:request/@resource-id" as="xs:string?"/>
    <xsl:variable name="requested-part" select="/m:response/m:request/@part" as="xs:string?"/>
    <xsl:variable name="requested-passage" select="/m:response/m:request/@passage-id" as="xs:string?"/>
    <xsl:variable name="requested-commentary" select="/m:response/m:request/@commentary" as="xs:string?"/>
    <xsl:variable name="toh-key" select="$translation/m:source/@key" as="xs:string?"/>
    <xsl:variable name="kb-id" select="$knowledgebase/m:page/@xml:id" as="xs:string?"/>
    <xsl:variable name="part-status" select="if(not($translation//m:part[@content-status = ('preview', 'passage', 'empty')])) then 'complete' else if($translation//m:part[@content-status eq 'complete']) then 'part' else 'empty'" as="xs:string"/>
    
    <!-- Useful keys -->
    <xsl:key name="text-parts" match="m:part[@id]" use="@id"/>
    <xsl:key name="glossary-cache-gloss" match="m:glossary-cache/m:gloss" use="@id"/>
    <xsl:key name="glossary-cache-index" match="m:glossary-cache/m:gloss" use="@index"/>
    <xsl:key name="glossary-cache-location" match="m:glossary-cache/m:gloss/m:location" use="@id"/>
    <xsl:key name="folio-refs-pre-processed" match="m:pre-processed[@type eq 'folio-refs']/m:folio-ref" use="@id"/>
    <xsl:key name="end-notes-pre-processed" match="m:pre-processed[@type eq 'end-notes']/m:end-note" use="@id"/>
    <xsl:key name="milestones-pre-processed" match="m:pre-processed[@type eq 'milestones']/m:milestone" use="@id"/>
    <xsl:key name="entity-instance" match="m:entities/m:entity/m:instance" use="@id"/>
    <xsl:key name="related-entries" match="m:entities/m:related/m:text/m:entry" use="@id"/>
    <xsl:key name="related-pages" match="m:entities/m:related/m:page" use="@xml:id"/>
    <xsl:key name="related-entities" match="m:entities/m:related/m:entity" use="@xml:id"/>
    <xsl:key name="quotes-outbound" match="m:quotes/m:quote[@resource-id eq $toh-key]" use="@id"/>
    <xsl:key name="quotes-inbound" match="m:quotes/m:quote[m:source/@resource-id eq $toh-key]" use="m:source/@location-id"/>
    
    <!-- Pre-sort the glossaries by priority -->
    <xsl:variable name="glossary-prioritised" as="element(tei:gloss)*">
        <xsl:perform-sort select="($translation | $knowledgebase)/m:part[@type eq 'glossary']//tei:gloss[@xml:id][tei:term[not(@xml:lang)][not(@type = ('definition','alternative'))][string-join(text(), '') ! normalize-space(.)]]">
            <xsl:sort select="key('glossary-cache-gloss', @xml:id, $root)[1]/@word-count ! common:enforce-integer(.)" order="descending"/>
            <xsl:sort select="key('glossary-cache-gloss', @xml:id, $root)[1]/@letter-count[not(. eq '')] ! common:enforce-integer(.)" order="descending"/>
        </xsl:perform-sort>
    </xsl:variable>
    
    <!-- Specify glossary ids to be tested, or empty for all - a single invalid test-glossary (e.g. 'all') will trigger a test of all without a cache  -->
    <xsl:variable name="test-glossary" select="/m:response/m:request/m:test-glossary[@id]"/>
    <xsl:variable name="test-glossary-items" select="if($test-glossary) then $glossary-prioritised[@xml:id = $test-glossary/@id] else ()" as="element(tei:gloss)*"/>
    <xsl:variable name="test-glossary-items-terms" as="xs:string*" select="m:glossary-terms-to-match($test-glossary-items)"/>
    
    <!-- Create a prologue with the first refs -->
    <xsl:variable name="ref-1" select="($translation//tei:ref[@xml:id][@type eq 'folio'][not(@key) or @key eq $toh-key])[1]" as="element(tei:ref)?"/>
    <xsl:variable name="ref-1-validated" select="if(key('folio-refs-pre-processed', $ref-1/@xml:id, $root)/@index-in-resource/string() = '1') then $ref-1 else ()" as="element(tei:ref)?"/>
    <xsl:variable name="ref-prologue" select="($ref-1-validated/../node()[self::tei:ref or self::tei:note or self::text()[not(matches(., '\w+'))]][not(preceding-sibling::node()[not(self::tei:ref or self::tei:note or self::text()[not(matches(., '\w+'))])])])"/>
    <xsl:variable name="ref-prologue-container" select="$ref-1-validated/ancestor::tei:*[self::tei:p | self::tei:lg | self::tei:q][1]"/>
    <xsl:variable name="ref-prologue-parent" select="$ref-1-validated/parent::tei:*"/>
    
    <!-- Normalize text and check if it needs glossarizing -->
    <xsl:template match="text()">
        
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
        
        <!-- Prioitise highlights -->
        <xsl:variable name="text-highlighted" as="node()*">
            <xsl:choose>
                <xsl:when test="m:quotable-node(., $text-normalized)">
                    <xsl:call-template name="mark-quotes">
                        <xsl:with-param name="text-node" select="."/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Evaluate if it's one we want to parse -->
        <xsl:variable name="glossarize" as="xs:boolean">
            <xsl:choose>
                
                <!-- Highlight instead -->
                <xsl:when test="$text-highlighted">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- Check the context -->
                <xsl:when test="not(m:glossarize-node(., $text-normalized))">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- Marked terms are done elsewhere -->
                <xsl:when test="ancestor::tei:term[not(parent::tei:gloss)]">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:choose>
                        
                        <!-- We are matching a particular glossary item, so pre-parse to see if this node is relevant -->
                        <xsl:when test="$test-glossary-items">
                            
                            <xsl:choose>
                                
                                <!-- Test if the text matches one of the terms exactly -->
                                <xsl:when test="parent::tei:title | parent::tei:name">
                                    <!-- Returns true / false -->
                                    <xsl:sequence select="matches($text-normalized, common:matches-regex-exact($test-glossary-items-terms), 'i')"/>
                                </xsl:when>
                                
                                <!-- Test if the text matches one of the terms -->
                                <xsl:otherwise>
                                    <!-- Returns true / false -->
                                    <xsl:sequence select="matches($text-normalized, common:matches-regex($test-glossary-items-terms), 'i')"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </xsl:when>
                        
                        <!-- Parse the node -->
                        <xsl:otherwise>
                            <xsl:value-of select="true()"/>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:variable>
        
        <!-- Parse the text -->
        <xsl:choose>
            
            <!-- Already highlighted -->
            <xsl:when test="$text-highlighted">
                <xsl:sequence select="$text-highlighted"/>
            </xsl:when>
            
            <xsl:when test="$glossarize">
                
                <xsl:call-template name="glossarize-text">
                    <xsl:with-param name="text-node" select="."/>
                    <xsl:with-param name="text-normalized" select="$text-normalized"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <!-- Output un-parsed by default -->
            <xsl:otherwise>
                <xsl:value-of select="$text-normalized"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Ignore any nodes with a different key - except those that are indexed -->
    <xsl:template match="tei:*[@key][@key = $translation/m:toh//m:duplicate/@key][not(self::tei:note | self::tei:milestone | tei:gloss)]">
        <!-- Ignore these -->
    </xsl:template>
    
    <xsl:template match="tei:title">
        <cite>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </cite>
    </xsl:template>
    <xsl:template match="m:title">
        <xsl:if test="text()">
            <div>
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="lang" select="@xml:lang"/>
                    <xsl:with-param name="base-classes" as="xs:string*">
                        <xsl:value-of select="'title'"/>
                        <xsl:if test="@xml:lang eq 'Sa-Ltn'">
                            <xsl:value-of select="'break'"/>
                        </xsl:if>
                        <xsl:if test="@rend = ('reconstruction', 'semanticReconstruction','transliterationReconstruction')">
                            <xsl:value-of select="'reconstructed'"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates select="node()"/>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'name'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:mantra">
        <xsl:choose>
            
            <!-- parent::tei:mantra handled sparately in tei:l -->
            <xsl:when test="tei:l">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <span>
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" select="'mantra'"/>
                        <xsl:with-param name="lang" select="@xml:lang"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="node()"/>
                </span>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'foreign'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:emph">
        <em>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes">
                    <xsl:if test="@rend eq 'bold'">
                        <xsl:value-of select="'text-bold'"/>
                    </xsl:if>
                </xsl:with-param>
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:distinct">
        <em>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <span class="date">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        
        <xsl:variable name="ref" select="."/>
        
        <xsl:choose>
            
            <xsl:when test="$ref[@rend eq 'hidden']">
                <!-- Ignore these -->
            </xsl:when>
            
            <!-- Target is a placeholder -->
            <xsl:when test="$ref[@rend eq 'pending']">
                <span class="ref-pending">
                    <xsl:apply-templates select="$ref/text()"/>
                </span>
            </xsl:when>
            
            <!-- If there's a cRef then output it... -->
            <xsl:when test="$ref[@cRef]">
                
                <!-- Set the index -->
                <xsl:variable name="index" select="if($ref[@xml:id]) then key('folio-refs-pre-processed', $ref/@xml:id, $root)[1]/@index-in-resource else ()"/>

                <xsl:choose>
                    
                    <!-- Target is an empty page -->
                    <xsl:when test="$ref[@rend eq 'blank']">
                        <span class="ref text-muted">
                            <xsl:value-of select="concat('[', $ref/@cRef, ']')"/>
                        </span>
                    </xsl:when>
                    
                    <!-- Check for index -->
                    <xsl:when test="$index and $toh-key">
                        <xsl:choose>
                            
                            <!-- If it's html then add a link -->
                            <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))]">
                                
                                <a class="ref log-click">
                                    <!-- define an anchor so we can link back to this point -->
                                    <xsl:attribute name="id" select="$ref/@xml:id"/>
                                    <xsl:attribute name="href" select="concat('/source/', $toh-key, '.html?ref-index=', $index)"/>
                                    <xsl:attribute name="data-ref" select="$ref/@cRef"/>
                                    <xsl:attribute name="target" select="concat('source-', $toh-key)"/>
                                    <xsl:attribute name="data-dualview-href" select="concat('/source/', $toh-key, '.html?ref-index=', $index)"/>
                                    <xsl:attribute name="data-dualview-title" select="concat($translation/m:source/m:toh, ' (source text)')"/>
                                    <xsl:attribute name="data-loading" select="concat('Loading ', $translation/m:source/m:toh, '...')"/>
                                    <xsl:value-of select="concat('[', $ref/@cRef, ']')"/>
                                </a>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                
                                <span class="ref">
                                    <xsl:attribute name="data-href" select="concat('/source/', $toh-key, '.html?ref-index=', $index)"/>
                                    <xsl:value-of select="concat('[', $ref/@cRef, ']')"/>
                                </span>
                                
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:when>
                    
                    <!-- ...or just output the cRef. -->
                    <xsl:otherwise>
                        
                        <span class="ref">
                            <xsl:value-of select="concat('[', $ref/@cRef, ']')"/>
                        </span>
                        
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <!-- @target designates an external (http) link -->
            <xsl:when test="$ref[@target]">
                <a target="_blank">
                    
                    <xsl:attribute name="href" select="$ref/@target"/>
                    
                    <xsl:choose>
                        
                        <xsl:when test="$ref[data()]">
                            <xsl:attribute name="title" select="$ref/data() ! normalize-space(.)"/>
                            <xsl:apply-templates select="$ref/node()"/>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <xsl:attribute name="title" select="$ref/@target"/>
                            <xsl:attribute name="class" select="'break printable'"/>
                            <xsl:value-of select="$ref/@target"/>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </a>
            </xsl:when>
            
            <!-- Otherwise just output the text -->
            <xsl:when test="$ref[text()]">
                <span class="ref">
                    <xsl:apply-templates select="$ref/text()"/>
                </span>
            </xsl:when>
        
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:ptr">
        <a>
            
            <xsl:variable name="pointer" select="."/>
            <xsl:variable name="target-type" select="if(starts-with($pointer/@target, '#')) then 'id' else if(starts-with($pointer/@target, 'http')) then 'url' else ''"/>
            <xsl:variable name="pointer-target" select="if($target-type eq 'id') then replace($pointer/@target, '^#(end\-note\-)?', '') else $pointer/@target"/>
            
            <!-- Look through the various keys to find this id -->
            <xsl:variable name="target" as="element()?">
                <xsl:if test="$target-type eq 'id'">
                    <xsl:call-template name="target-element">
                        <xsl:with-param name="target-id" select="$pointer-target"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:variable>
            
            <!-- Set the href and class -->
            <xsl:choose>
                
                <xsl:when test="$target">
                    
                    <xsl:call-template name="target-element-href">
                        <xsl:with-param name="target-element" select="$target"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="html-classes">
                            
                            <xsl:value-of select="'pointer'"/>
                            
                            <!-- If id don't expand for printing -->
                            <xsl:if test="$target-type eq 'id'">
                                <xsl:value-of select="'printable'"/>
                            </xsl:if>
                            
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:choose>
                        
                        <!-- External text -->
                        <xsl:when test="$target/ancestor::m:pre-processed[not(@text-id eq $translation/@id)]">
                            <xsl:attribute name="target" select="concat($target/ancestor::m:pre-processed/@text-id, '.html')"/>
                        </xsl:when>
                        
                        <!-- Internal fragment -->
                        <xsl:otherwise>
                            <xsl:attribute name="target" select="'_self'"/>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </xsl:when>
                
                <xsl:when test="$target-type eq 'url'">
                    
                    <xsl:attribute name="href" select="$pointer-target"/>
                    <xsl:attribute name="target" select="'_blank'"/>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <!-- Don't add an href -->
                </xsl:otherwise>
                
            </xsl:choose>
            
            <!-- Set a data value to flag these -->
            <xsl:attribute name="data-pointer-type" select="$target-type"/>
            
            <!-- Set the text -->
            <xsl:choose>
                
                <!-- The label is defined -->
                <xsl:when test="$pointer[normalize-space(text())]">
                    <xsl:apply-templates select="$pointer/text()"/>
                </xsl:when>
                
                <xsl:when test="$target">
                    <xsl:call-template name="target-element-label">
                        <xsl:with-param name="target-element" select="$target"/>
                    </xsl:call-template>
                </xsl:when>
                
                <!-- Just output the target -->
                <xsl:otherwise>
                    <xsl:apply-templates select="$pointer-target"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </a>
    </xsl:template>
    
    <!-- Inline quote-->
    <xsl:template match="tei:q[parent::tei:p | parent::tei:l]">
        
        <xsl:variable name="element" select="."/>
        
        <!-- Outbound quotes -->
        <xsl:variable name="quotes-outbound" as="element(m:quote)?">
            <xsl:if test="$element[@xml:id][ancestor-or-self::*/@ref]">
                <xsl:sequence select="key('quotes-outbound', $element/@xml:id, $root)[m:source/@location-id eq $element/ancestor-or-self::*[@ref][1]/@ref]"/>
            </xsl:if>
        </xsl:variable>
        
        <span>
            
            <xsl:call-template name="id-attribute">
                <xsl:with-param name="node" select="$element"/>
            </xsl:call-template>
            
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes">
                    <xsl:value-of select="'quote'"/>
                </xsl:with-param>
            </xsl:call-template>
            
            <!-- Output the content, filtering out the ref prologue -->
            <xsl:call-template name="parse-content">
                <xsl:with-param name="node" select="$element"/>
            </xsl:call-template>
            
        </span>
        
        <xsl:for-each select="$quotes-outbound">
            
            <xsl:call-template name="quote-link">
                <xsl:with-param name="quote" select="."/>
            </xsl:call-template>
            
            <xsl:value-of select="' '"/>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Elements that may have a milestone -->
    <xsl:template match="tei:p | tei:ab | tei:trailer | tei:bibl | tei:lg | tei:q">
        
        <xsl:variable name="element" select="."/>
        
        <!-- Output the ref prologue -->
        <xsl:if test="$ref-prologue-container and count($element | $ref-prologue-container) eq count($element)">
            <div class="rw rw-first rw-paragraph">
                <p class="ref-prologue">
                    <xsl:apply-templates select="$ref-prologue"/>
                </p>
            </div>
            <br/>
        </xsl:if>
        
        <!-- Output the milestone -->
        <xsl:call-template name="milestone">
            
            <xsl:with-param name="content">
                <xsl:element name="{ if($element/self::tei:lg) then 'div' else if($element/self::tei:q) then 'blockquote' else 'p' }" namespace="http://www.w3.org/1999/xhtml">
                    
                    <!-- id -->
                    <xsl:call-template name="id-attribute">
                        <xsl:with-param name="node" select="$element"/>
                    </xsl:call-template>
                    
                    <!-- Outbound quote link -->
                    <xsl:variable name="quotes-outbound" as="element(m:quote)*">
                        <xsl:choose>
                            <!-- quote elements -->
                            <xsl:when test="$element[self::tei:q][@xml:id][ancestor-or-self::*/@ref gt '']">
                                <xsl:sequence select="key('quotes-outbound', $element/@xml:id, $root)[m:source/@location-id eq $element/ancestor-or-self::*[@ref][1]/@ref]"/>
                            </xsl:when>
                            <!-- elements containing quotes -->
                            <xsl:when test="$element/tei:q[@xml:id][parent::tei:p | parent::tei:l][ancestor-or-self::*/@ref gt '']">
                                <xsl:sequence select="key('quotes-outbound', $element/tei:q/@xml:id, $root)[m:source/@location-id eq $element/tei:q/ancestor-or-self::*[@ref][1]/@ref]"/>
                            </xsl:when>
                            <!-- elements in quotes (must be the last one - accounting for hidden elements) -->
                            <xsl:when test="$element[not(tei:l)]/parent::tei:q[@xml:id][ancestor-or-self::*/@ref gt ''] and not($element/following-sibling::tei:*[not(self::tei:orig)])">
                                <xsl:sequence select="key('quotes-outbound', $element/ancestor::tei:q[@xml:id][1]/@xml:id, $root)[m:source/@location-id eq $element/ancestor-or-self::*[@ref][1]/@ref]"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <!-- class -->
                    <xsl:call-template name="class-attribute">
                        
                        <xsl:with-param name="base-classes" as="xs:string*">
                            
                            <xsl:if test="($element/@rend, $element/@type) = 'mantra'">
                                <xsl:value-of select="'mantra'"/>
                            </xsl:if>
                            
                            <xsl:if test="$element/@type = ('sdom', 'bar_sdom', 'spyi_sdom')">
                                <xsl:value-of select="'italic'"/>
                            </xsl:if>
                            
                            <xsl:choose>
                                <xsl:when test="$element/self::tei:trailer">
                                    <xsl:value-of select="'trailer'"/>
                                </xsl:when>
                                <xsl:when test="$element/self::tei:bibl">
                                    <xsl:value-of select="'bibl'"/>
                                </xsl:when>
                                <xsl:when test="$element/self::tei:lg">
                                    <xsl:value-of select="'line-group'"/>
                                </xsl:when>
                                <xsl:when test="$element/self::tei:q[@xml:id][@ref gt '']">
                                    <xsl:value-of select="'quote'"/>
                                </xsl:when>
                            </xsl:choose>
                            
                        </xsl:with-param>
                        
                        <xsl:with-param name="html-classes">
                            <xsl:if test="$quotes-outbound and $element/descendant-or-self::tei:q">
                                <xsl:value-of select="'quote-container'"/>
                            </xsl:if>
                        </xsl:with-param>
                        
                    </xsl:call-template>
                    
                    <!-- Output the content, filtering out the ref prologue -->
                    <xsl:call-template name="parse-content">
                        <xsl:with-param name="node" select="$element"/>
                    </xsl:call-template>
                    
                    <!-- Output quote links -->
                    <xsl:if test="$quotes-outbound and $element[not(descendant-or-self::tei:q)]">
                        <xsl:for-each select="$quotes-outbound">
                            
                            <xsl:value-of select="' '"/>
                            
                            <xsl:call-template name="quote-link">
                                <xsl:with-param name="quote" select="."/>
                            </xsl:call-template>
                            
                        </xsl:for-each>
                    </xsl:if>
                    
                    <!-- Add link to tei editor -->
                    <xsl:call-template name="tei-editor">
                        <xsl:with-param name="node" select="$element"/>
                    </xsl:call-template>
                    
                </xsl:element>
            </xsl:with-param>
            
            <xsl:with-param name="row-type">
                <xsl:choose>
                    <xsl:when test="($element/@rend, $element/@type) = 'mantra'">
                        <xsl:value-of select="'mantra'"/>
                    </xsl:when>
                    <xsl:when test="$element/self::tei:trailer">
                        <xsl:value-of select="'trailer'"/>
                    </xsl:when>
                    <xsl:when test="$element/self::tei:lg">
                        <xsl:value-of select="'line-group'"/>
                    </xsl:when>
                    <xsl:when test="$element/self::tei:q">
                        <xsl:value-of select="'blockquote'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'paragraph'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
                        
        </xsl:call-template>
    
    </xsl:template>
    
    <xsl:template match="tei:l">
        
        <xsl:variable name="element" select="."/>
        
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    
                    <!-- Outbound quote link -->
                    <xsl:variable name="quotes-outbound" as="element(m:quote)*">
                        <xsl:if test="$element/ancestor::tei:q[@xml:id][ancestor-or-self::*/@ref gt ''] and not($element/following-sibling::tei:l)">
                            <xsl:sequence select="key('quotes-outbound', $element/ancestor::tei:q[@xml:id][1]/@xml:id, $root)[m:source/@location-id eq $element/ancestor-or-self::*[@ref][1]/@ref]"/>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:call-template name="class-attribute">
                        
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'line'"/>
                            <xsl:if test="$element/parent::tei:mantra">
                                <xsl:value-of select="'mantra'"/>
                            </xsl:if>
                        </xsl:with-param>
                        
                        <xsl:with-param name="lang" select="$element/parent::tei:mantra/@xml:lang"/>
                        
                    </xsl:call-template>
                    
                    <!-- Output the content, filtering out the ref prologue -->
                    <xsl:call-template name="parse-content">
                        <xsl:with-param name="node" select="$element"/>
                    </xsl:call-template>
                    
                    <!-- Output quote links -->
                    <xsl:for-each select="$quotes-outbound">
                        
                        <xsl:value-of select="' '"/>
                        
                        <xsl:call-template name="quote-link">
                            <xsl:with-param name="quote" select="."/>
                        </xsl:call-template>
                        
                    </xsl:for-each>
                    
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'line'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="tei:orig">
        <!-- Don't output orig -->
    </xsl:template>
    
    <!-- Highlights -->
    <xsl:template match="tei:hi[@rend eq 'subscript']">
        <sub>
            <xsl:apply-templates select="node()"/>
        </sub>
    </xsl:template>
    <xsl:template match="tei:hi[@rend eq 'superscript']">
        <sup>
            <xsl:apply-templates select="node()"/>
        </sup>
    </xsl:template>
    <xsl:template match="tei:hi[@rend eq 'small-caps']">
        <xsl:value-of select="translate(lower-case(text()), 'abcdefghijklmnopqrstuvwxyz', 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ')"/>
    </xsl:template>
    
    <!-- Table -->
    <xsl:template match="tei:table">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                
                <div>
                    
                    <!-- id -->
                    <xsl:call-template name="id-attribute">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <xsl:apply-templates select="tei:head"/>
                    
                    <!-- Render the list version of the table in case it's for printing -->
                    <div class="visible-print visible-ebook">
                        <xsl:variable name="label-row" select="(tei:row[@role eq 'label'][1], tei:row[1])[1]"/>
                        <xsl:variable name="data-rows" select="tei:row[not(. = $label-row)]"/>
                        <div class="table-as-list">
                            <xsl:for-each select="$data-rows">
                                
                                <xsl:variable name="row" select="."/>
                                <xsl:variable name="row-num" select="position()"/>
                                <xsl:variable name="row-labels" select="if($row/tei:cell[@role eq 'label']) then $row/tei:cell[@role eq 'label'] else $row/tei:cell[1]"/>
                                <xsl:variable name="row-data" select="$row/tei:cell[not(. = $row-labels)]"/>
                                
                                <!-- Output the labels -->
                                <h5 class="section-label">
                                    
                                    <xsl:variable name="labels">
                                        <xsl:for-each select="tei:cell">
                                            <xsl:if test=". = $row-labels">
                                                <xsl:variable name="col-num" select="position()"/>
                                                <xsl:variable name="label-cell" select="$label-row/tei:cell[$col-num]"/>
                                                <xsl:call-template name="list-cell-data">
                                                    <xsl:with-param name="label" select="normalize-space($label-row/tei:cell[$col-num]/text())"/>
                                                    <xsl:with-param name="data" select="normalize-space(data(.))"/>
                                                </xsl:call-template>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    
                                    <xsl:for-each select="$labels/xhtml:span">
                                        <xsl:sequence select="."/>
                                        <xsl:value-of select="if(position() eq count($labels/xhtml:span)) then '' else '; '"/>
                                    </xsl:for-each>
                                    
                                </h5>
                                
                                <p class="table-as-list-row">
                                    <!-- .table-as-list-row used in automated tests -->
                                    
                                    <xsl:variable name="datas">
                                        
                                        <!-- Output the values -->
                                        <xsl:for-each select="tei:cell">
                                            <xsl:if test=". = $row-data">
                                                <xsl:variable name="col-num" select="position()"/>
                                                <xsl:variable name="label-cell" select="$label-row/tei:cell[$col-num]"/>
                                                <xsl:call-template name="list-cell-data">
                                                    <xsl:with-param name="label" select="normalize-space(data($label-cell))"/>
                                                    <xsl:with-param name="data" select="normalize-space(data(.))"/>
                                                </xsl:call-template>
                                            </xsl:if>
                                        </xsl:for-each>
                                        
                                        <!-- Output values in other rows that span this row -->
                                        <xsl:for-each select="$data-rows">
                                            <xsl:variable name="sibling-row-num" select="position()"/>
                                            <xsl:for-each select="tei:cell">
                                                <xsl:if test="common:is-a-number(@rows) and $row-num gt $sibling-row-num and $row-num le ($sibling-row-num + xs:integer(@rows))">
                                                    <xsl:variable name="col-num" select="position()"/>
                                                    <xsl:variable name="label-cell" select="$label-row/tei:cell[$col-num]"/>
                                                    <xsl:call-template name="list-cell-data">
                                                        <xsl:with-param name="label" select="normalize-space(data($label-cell))"/>
                                                        <xsl:with-param name="data" select="normalize-space(data(.))"/>
                                                    </xsl:call-template>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                        
                                    </xsl:variable>
                                    
                                    <xsl:for-each select="$datas/xhtml:span">
                                        <xsl:sequence select="."/>
                                        <xsl:if test="position() lt count($datas/xhtml:span)">
                                            <br/>
                                        </xsl:if>
                                    </xsl:for-each>
                                    
                                </p>
                            </xsl:for-each>
                        </div>
                    </div>
                    
                    <!-- Render the table version for html -->
                    <xsl:if test="$view-mode[not(@id = ('ebook', 'pdf'))]">
                        <div class="table-responsive hidden-print hidden-ebook">
                            <table>
                                <xsl:call-template name="class-attribute">
                                    <xsl:with-param name="base-classes" select="'table table-unpad'"/>
                                    <xsl:with-param name="html-classes" select="@rend"/>
                                </xsl:call-template>
                                <tbody>
                                    <xsl:for-each select="tei:row">
                                        <tr>
                                            <xsl:for-each select="tei:cell">
                                                <xsl:choose>
                                                    <xsl:when test="@role='label' or parent::tei:row[@role = 'label']">
                                                        <th>
                                                            <xsl:apply-templates select="."/>
                                                        </th>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <td>
                                                            <xsl:apply-templates select="."/>
                                                        </td>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="tei:note">
                        <div class="table-notes">
                            <xsl:apply-templates select="tei:note"/>
                        </div>
                    </xsl:if>
                    
                </div>
                
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'table'"/>
        </xsl:call-template>
    </xsl:template> 
    <xsl:template name="list-cell-data">
        <xsl:param name="label" as="xs:string" required="yes"/>
        <xsl:param name="data" as="xs:string" required="yes"/>
        <span>
            <xsl:if test="$label">
                <span class="row-label">
                    <xsl:value-of select="concat($label, ': ')"/>
                </span>
            </xsl:if>
            <xsl:value-of select="$data"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:cell">
        <xsl:if test="$view-mode[not(@client eq 'ebook')]">
            <xsl:if test="@rows">
                <xsl:attribute name="rowspan" select="@rows"/>
            </xsl:if>
            <xsl:if test="@cols">
                <xsl:attribute name="colspan" select="@cols"/>
            </xsl:if>
        </xsl:if>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:head[parent::tei:table]">
        <h5 class="table-label">
            
            <xsl:call-template name="id-attribute">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
            
            <xsl:apply-templates select="node()"/>
            
        </h5>
    </xsl:template>
    <xsl:template match="tei:note[parent::tei:table]">
        <p class="table-note">
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>
    
    <!-- Labels -->
    <xsl:template match="tei:label[parent::tei:p]">
        <strong>
            <xsl:apply-templates select="node()"/>
        </strong>
    </xsl:template>
    <xsl:template match="tei:label">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <h5 class="section-label">
                    
                    <xsl:call-template name="id-attribute">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <xsl:apply-templates select="node()"/>
                    
                    <xsl:call-template name="tei-editor">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                </h5>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'label'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Lists -->
    <xsl:template match="tei:list[@type eq 'abbreviations']">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <xsl:for-each select="tei:head[@type eq 'abbreviations' and not(lower-case(data()) = ('abbreviations', 'abbreviations:'))]">
                    <h5>
                        <xsl:apply-templates select="node()"/>
                    </h5>
                </xsl:for-each>
                <xsl:for-each select="tei:head[@type eq 'description']">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
                <table class="table">
                    <tbody>
                        <xsl:for-each select="tei:item[tei:abbr]">
                            <xsl:sort select="tei:abbr"/>
                            <tr>
                                <th>
                                    <xsl:apply-templates select="tei:abbr/node()"/>
                                </th>
                                <td>
                                    <xsl:apply-templates select="tei:expan/node()"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                <xsl:for-each select="tei:item[not(tei:abbr)]">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'list-section'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="tei:list">
        
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'list'"/>
                            <xsl:if test="parent::tei:item">
                                <xsl:value-of select="'list-sublist'"/>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="@type eq 'section'">
                                    <xsl:value-of select="'list-section'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'list-bullet'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="@rend"/>
                            <xsl:if test="ancestor::tei:list[not(@type eq 'section')]">
                                <xsl:value-of select="concat('nesting-', count(ancestor::tei:list[not(@type eq 'section')]))"/>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:apply-templates select="node()"/>
                    
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="concat('list-', @type)"/>
        </xsl:call-template>
        
    </xsl:template>
    <xsl:template match="tei:head[parent::tei:list]">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <h5 class="section-label">
                    
                    <xsl:call-template name="id-attribute">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <xsl:apply-templates select="node()"/>
                    
                    <xsl:call-template name="tei-editor">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                </h5>
            </xsl:with-param>
            
            <xsl:with-param name="row-type" select="'list-head'"/>
            
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="tei:item[parent::tei:list]">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:attribute name="class">
                        <xsl:value-of select="'list-item'"/>
                        <xsl:if test="not(preceding-sibling::tei:item)">
                            <xsl:value-of select="' list-item-first'"/>
                        </xsl:if>
                        <xsl:if test="not(following-sibling::tei:item)">
                            <xsl:value-of select="' list-item-last'"/>
                        </xsl:if>
                    </xsl:attribute>
                    
                    <xsl:apply-templates select="node()"/>
                    
                </div>
            </xsl:with-param>
            
            <xsl:with-param name="row-type" select="'list-item'"/>
            
        </xsl:call-template>
    </xsl:template>
    
    <!-- Note link in the text -->
    <xsl:template match="tei:note[@place eq 'end'][@xml:id]">
        
        <xsl:variable name="note" select="."/>
        <xsl:variable name="end-notes-pre-processed" select="key('end-notes-pre-processed', $note/@xml:id, $root)[1]" as="element(m:end-note)?"/>
        
        <a class="footnote-link">
            
            <xsl:choose>
                
                <xsl:when test="$note[@xml:id] and $end-notes-pre-processed[@index]">
                    
                    <xsl:call-template name="id-attribute">
                        <xsl:with-param name="node" select="$note"/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="href-attribute">
                        <xsl:with-param name="fragment-id" select="concat('end-note-', $note/@xml:id)"/>
                        <xsl:with-param name="part-id" select="'end-notes'"/>
                    </xsl:call-template>
                    
                    <!-- target to be marked -->
                    <xsl:attribute name="data-mark-id" select="$note/@xml:id"/>
                    
                    <xsl:choose>
                        
                        <xsl:when test="$view-mode[@client = ('ebook', 'app')]">
                            <xsl:attribute name="epub:type" select="'noteref'"/>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <xsl:call-template name="class-attribute">
                                <xsl:with-param name="base-classes" select="'footnote-link'"/>
                                <xsl:with-param name="html-classes" select="'pop-up'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <xsl:value-of select="$end-notes-pre-processed/@index"/>
                    
                </xsl:when>
                
                <!-- Problem with the note -->
                <xsl:otherwise>
                    <xsl:value-of select="'?'"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </a>
        
    </xsl:template>
    <!-- List at the end -->
    <xsl:template name="end-notes">
        
        <xsl:param name="end-notes" select="$translation/m:part[@type eq 'end-notes']//tei:note[@place eq 'end'][@xml:id] | $knowledgebase/m:part[@type eq 'end-notes']//tei:note[@place eq 'end'][@xml:id]" as="element(tei:note)*"/>
        
        <xsl:variable name="end-notes-part" select="($translation/m:part[@type eq 'end-notes'] | $knowledgebase/m:part[@type eq 'end-notes'])[1]"/>
        
        <xsl:apply-templates select="$end-notes-part/tei:head"/>
        
        <xsl:for-each select="$end-notes[@xml:id]">
            
            <xsl:sort select="key('end-notes-pre-processed', @xml:id, $root)[1]/@index ! common:enforce-integer(.)"/>
            
            <xsl:variable name="end-note" select="."/>
            <xsl:variable name="end-notes-pre-processed" select="key('end-notes-pre-processed', @xml:id, $root)[1]" as="element(m:end-note)?"/>
            <xsl:variable name="part" select="key('text-parts', $end-notes-pre-processed/@part-id, $root)[1]" as="element(m:part)?"/>
            
            <div class="rw footnote">
                
                <xsl:attribute name="id" select="concat('end-note-', $end-note/@xml:id)"/>
                
                <xsl:call-template name="data-location-id-attribute">
                    <xsl:with-param name="node" select="$end-note"/>
                </xsl:call-template>
                
                <!-- Defer the glossary parsing -->
                <xsl:if test="$view-mode[@glossary eq 'defer']">
                    <xsl:call-template name="in-view-replace-attribute">
                        <xsl:with-param name="element-id" select="$end-note/@xml:id"/>
                        <xsl:with-param name="fragment-id" select="concat('end-note-', $end-note/@xml:id)"/>
                    </xsl:call-template>
                </xsl:if>
                
                <div class="gtr">
                    
                    <xsl:choose>
                        
                        <!-- Internal links to hash locations -->
                        <xsl:when test="$view-mode[@client = ('browser', 'ajax', 'pdf', 'ebook', 'app')]">
                            
                            <a>
                                
                                <xsl:call-template name="href-attribute">
                                    <xsl:with-param name="fragment-id" select="$end-note/@xml:id"/>
                                    <xsl:with-param name="part-id" select="$part/@id"/>
                                    <xsl:with-param name="mark-id" select="$end-note/@xml:id"/>
                                </xsl:call-template>
                                
                                <xsl:if test="$view-mode[@client = ('browser', 'ajax', 'pdf')]">
                                    <!-- marks a target -->
                                    <xsl:attribute name="class" select="'milestone footnote-number'"/>
                                    <xsl:attribute name="title" select="concat('Go to note ', $end-notes-pre-processed/@index, ' in the text')"/>
                                </xsl:if>
                                
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="$end-notes-part/@prefix"/>
                                    <xsl:with-param name="index" select="$end-notes-pre-processed/@index"/>
                                </xsl:call-template>
                                
                            </a>
                            
                        </xsl:when>
                        
                        <!-- Just text -->
                        <xsl:otherwise>
                            <xsl:call-template name="bookmark-label">
                                <xsl:with-param name="prefix" select="$end-notes-part/@prefix"/>
                                <xsl:with-param name="index" select="$end-notes-pre-processed/@index"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </div>
                
                <div>
                    <xsl:apply-templates select="node()"/>
                </div>
                
            </div>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Non-glossary glosses -->
    <xsl:template match="tei:term[not(parent::tei:gloss)]">
        <span>
            
            <xsl:if test="@ref">
                <xsl:attribute name="data-ref" select="@ref"/>
            </xsl:if>
            
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes">
                    <xsl:choose>
                        <xsl:when test="@type eq 'ignore'">
                            <xsl:value-of select="'ignore'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--<xsl:value-of select="'match'"/>-->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:variable name="text-normalized" as="text()">
                <xsl:value-of select="common:normalize-data(data(.))"/>
            </xsl:variable>
            
            <!-- Evaluate if it's one we want to parse -->
            <xsl:variable name="glossarize" as="xs:boolean">
                <xsl:choose>
                    
                    <!-- Check the type -->
                    <xsl:when test="@type eq 'ignore'">
                        <xsl:value-of select="false()"/>
                    </xsl:when>
                    
                    <!-- Check the context -->
                    <xsl:when test="not(m:glossarize-node(., $text-normalized))">
                        <xsl:value-of select="false()"/>
                    </xsl:when>
                    
                    <xsl:when test="$test-glossary-items">
                        <xsl:choose>
                            
                            <!-- Glossarize element -->
                            <xsl:when test="matches($text-normalized, common:matches-regex-exact($test-glossary-items-terms), 'i')">
                                <xsl:value-of select="true()"/>
                            </xsl:when>
                            
                            <!-- Output child nodes -->
                            <xsl:otherwise>
                                <xsl:value-of select="false()"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="true()"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                
                <!-- Glossarize -->
                <xsl:when test="$glossarize">
                    <xsl:call-template name="glossarize-element">
                        <xsl:with-param name="element" select="."/>
                    </xsl:call-template>
                </xsl:when>
                
                <!-- Output child nodes -->
                <xsl:otherwise>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </span>
    </xsl:template>
    
    <!-- Glossary -->
    <xsl:template name="glossary">
        
        <xsl:variable name="glossary-part" select="($translation/m:part[@type eq 'glossary'] | $knowledgebase/m:part[@type eq 'glossary'])[1]"/>
        
        <xsl:variable name="glossary-render" as="element(tei:gloss)*">
            <xsl:choose>
                <xsl:when test="$view-mode[@parts eq 'passage']">
                    <xsl:sequence select="$glossary-part//tei:gloss[@xml:id eq $requested-passage]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$glossary-part//tei:gloss[@xml:id]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$glossary-render">
            
            <xsl:apply-templates select="$glossary-part/tei:head"/>
            
            <xsl:for-each select="$glossary-render">
                
                <xsl:sort select="key('glossary-cache-gloss', @xml:id, $root)[1]/@index ! common:enforce-integer(.)"/>
                
                <xsl:variable name="glossary-item" select="."/>
                <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $glossary-item/@xml:id, $root)[1]"/>
                <xsl:variable name="cached-locations" select="$glossary-cache-gloss/m:location"/>
                <xsl:variable name="glossary-item-label">
                    <xsl:call-template name="bookmark-label">
                        <xsl:with-param name="prefix" select="$glossary-part/@prefix"/>
                        <xsl:with-param name="index" select="$glossary-cache-gloss/@index"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <div class="rw glossary-item">
                    
                    <xsl:attribute name="id" select="$glossary-item/@xml:id"/>
                    
                    <xsl:call-template name="data-location-id-attribute">
                        <xsl:with-param name="node" select="$glossary-item"/>
                    </xsl:call-template>
                    
                    <!-- Defer the glossary parsing -->
                    <xsl:if test="$view-mode[@glossary eq 'defer']">
                        <xsl:call-template name="in-view-replace-attribute">
                            <xsl:with-param name="element-id" select="$glossary-item/@xml:id"/>
                            <xsl:with-param name="fragment-id" select="$glossary-item/@xml:id"/>
                        </xsl:call-template>
                    </xsl:if>
                    
                    <div class="gtr">
                        <xsl:choose>
                            
                            <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))]">
                                
                                <xsl:call-template name="bookmark-link">
                                    <xsl:with-param name="bookmark-target-hash" select="$glossary-item/@xml:id"/>
                                    <xsl:with-param name="bookmark-target-part" select="'glossary'"/>
                                    <xsl:with-param name="bookmark-label" select="$glossary-item-label"/>
                                </xsl:call-template>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <xsl:value-of select="$glossary-item-label"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </div>
                    
                    <div class="glossary-content">
                        
                        <!-- Main term -->
                        <h3 class="term">
                            <xsl:value-of select="($glossary-item/tei:term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq 'en'])[1]/normalize-space(.) ! functx:capitalize-first(.)"/>
                        </h3>
                        
                        <!-- Output terms grouped and ordered by language -->
                        <xsl:for-each select="('Bo-Ltn','bo','Sa-Ltn', 'zh')">
                            
                            <xsl:variable name="term-lang" select="."/>
                            <xsl:variable name="term-lang-terms" select="$glossary-item/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq $term-lang][normalize-space(text())]"/>
                            <xsl:variable name="term-empty-text">
                                <xsl:call-template name="text">
                                    <xsl:with-param name="global-key" select="concat('glossary.term-empty-', lower-case($term-lang))"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <xsl:if test="$term-lang-terms or $term-empty-text gt ''">
                                <div>
                                    <ul class="list-inline inline-dots">
                                        <xsl:choose>
                                            
                                            <xsl:when test="$term-lang-terms">
                                                <xsl:for-each select="$term-lang-terms">
                                                    <li>
                                                        
                                                        <span>
                                                            
                                                            <xsl:call-template name="class-attribute">
                                                                <xsl:with-param name="base-classes" as="xs:string*">
                                                                    <xsl:value-of select="'term'"/>
                                                                    <xsl:if test="@type = ('reconstruction', 'semanticReconstruction','transliterationReconstruction')">
                                                                        <xsl:value-of select="'reconstructed'"/>
                                                                    </xsl:if>
                                                                </xsl:with-param>
                                                                <xsl:with-param name="lang" select="$term-lang"/>
                                                            </xsl:call-template>
                                                            
                                                            <xsl:value-of select="normalize-space(text())"/>
                                                            
                                                        </span>
                                                        
                                                        <xsl:if test="($tei-editor or $view-mode[@id  eq 'annotation']) and @status eq 'verified'">
                                                            <xsl:value-of select="' '"/>
                                                            <span class="text-warning small">
                                                                <xsl:value-of select="'[Verified]'"/>
                                                            </span>
                                                        </xsl:if>
                                                        
                                                    </li>
                                                </xsl:for-each>
                                            </xsl:when>
                                            
                                            <xsl:otherwise>
                                                <li>
                                                    <xsl:value-of select="$term-empty-text"/>
                                                </li>
                                            </xsl:otherwise>
                                            
                                        </xsl:choose>
                                    </ul>
                                </div>
                            </xsl:if>
                            
                        </xsl:for-each>
                        
                        <!-- Alternatives -->
                        <xsl:variable name="alternative-terms" select="$glossary-item/tei:term[@type eq 'alternative'][normalize-space(data())]"/>
                        <xsl:if test="($tei-editor or $view-mode[@id = ('annotation','tests')]) and $alternative-terms">
                            <ul class="list-inline inline-dots">
                                <xsl:for-each select="$alternative-terms">
                                    <li>
                                        <span>
                                            <xsl:call-template name="class-attribute">
                                                <xsl:with-param name="base-classes" as="xs:string*">
                                                    <xsl:value-of select="'term'"/>
                                                    <xsl:value-of select="'alternative'"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="lang" select="@xml:lang"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="normalize-space(data())"/>
                                        </span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        
                        <!-- Definition -->
                        <xsl:variable name="entry-definition" select="$glossary-item/tei:term[@type eq 'definition'][node()]"/>
                        
                        <!-- Entity -->
                        <xsl:variable name="entity" select="key('entity-instance', $glossary-item/@xml:id, $root)[1]/parent::m:entity"/>
                        <xsl:variable name="entity-instance" select="$entity/m:instance[@id eq $glossary-item/@xml:id]"/>
                        <xsl:variable name="entity-definition" select="$entity/m:content[@type eq 'glossary-definition'][node()]"/>
                        
                        <!-- Definition -->
                        <xsl:if test="($entry-definition and not($entity-definition)) or ($entry-definition and not($entity-instance[@use-definition eq 'override']))">
                            <xsl:for-each select="$entry-definition">
                                <p>
                                    <xsl:call-template name="class-attribute">
                                        <xsl:with-param name="base-classes" select="'definition'"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="node()"/>
                                </p>
                            </xsl:for-each>
                        </xsl:if>
                        
                        <!-- Entity definition -->
                        <xsl:if test="$tei-editor and not($entity)">
                            <div class="footer">
                                <span class="label label-warning">
                                    <xsl:value-of select="'No shared entity assigned'"/>
                                </span>
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="($entity-definition and not($entry-definition)) or ($entity-definition and $entity-instance[@use-definition = ('both','override')])">
                            <div class="footer">
                                <h4 class="heading">
                                    <xsl:value-of select="'Definition from the 84000 Glossary of Terms:'"/>
                                </h4>
                                <xsl:for-each select="$entity-definition">
                                    <p>
                                        <xsl:call-template name="class-attribute">
                                            <xsl:with-param name="base-classes" select="'definition'"/>
                                        </xsl:call-template>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </xsl:if>
                        
                        <!-- Expressions -->
                        <xsl:if test="$view-mode[not(@id eq 'pdf')]">
                            <div class="footer hidden-print" role="navigation" aria-label="Locations of this term in the text">
                                
                                <xsl:variable name="count-locations" select="count($cached-locations)"/>
                                <h4 class="heading">
                                    <xsl:choose>
                                        <xsl:when test="$count-locations gt 1">
                                            <xsl:value-of select="concat(format-number($count-locations, '#,###'), ' passages contain this term:')"/>
                                        </xsl:when>
                                        <xsl:when test="$count-locations eq 1">
                                            <xsl:value-of select="'1 passage contains this term:'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'No known locations for this term'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h4>
                                
                                <xsl:call-template name="cached-locations">
                                    <xsl:with-param name="cached-locations" select="$cached-locations"/>
                                    <xsl:with-param name="glossary-id" select="$glossary-item/@xml:id"/>
                                </xsl:call-template>
                                
                            </div>
                        </xsl:if>
                        
                        <!-- Link to the Glossary / Knowledge Base -->
                        <xsl:variable name="glossary-instances" select="$entity/m:instance[@type eq 'glossary-item'][not(@id eq $glossary-item/@xml:id)]"/>
                        <xsl:variable name="knowledgebase-instances" select="$entity/m:instance[@type eq 'knowledgebase-article'][not(@id eq $kb-id)][$environment/m:enable[@type eq 'knowledgebase']]"/>
                        <xsl:variable name="requires-attention" select="$entity-instance/m:flag[@type eq 'requires-attention']"/>
                        <xsl:if test="$view-mode[@client = ('browser', 'ajax', 'ebook', 'pdf')] and ($glossary-instances, $knowledgebase-instances) and ($tei-editor or not($requires-attention))">
                            <div class="footer entity-content" role="navigation">
                                
                                <xsl:if test="$tei-editor and $requires-attention">
                                    <xsl:attribute name="class" select="'footer entity-content well well-sm'"/>
                                    <div>
                                        <span class="label label-danger">
                                            <xsl:value-of select="/m:response/m:entity-flags/m:flag[@id eq 'requires-attention']/m:label"/>
                                        </span>
                                    </div>
                                </xsl:if>
                                
                                <h4 class="heading">
                                    <xsl:value-of select="'Links to further resources:'"/>
                                </h4>
                                <ul class="list-inline inline-dots">
                                    <xsl:if test="$glossary-instances">
                                        <li>
                                            <a target="84000-glossary">
                                                <!--<xsl:attribute name=" href" select="concat($reading-room-path, '/glossary/', $entity/@xml:id, '.html', if($tei-editor) then '?view-mode=editor' else '')"/>-->
                                                <xsl:call-template name="href-attribute">
                                                    <xsl:with-param name="resource-type" select="'glossary'"/>
                                                    <xsl:with-param name="resource-id" select="$entity/@xml:id"/>
                                                </xsl:call-template>
                                                <xsl:value-of select="concat(format-number(count($glossary-instances), '#,###'), ' related glossary ', if(count($glossary-instances) eq 1) then 'entry' else 'entries')"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                    <xsl:if test="$knowledgebase-instances">
                                        <li>
                                            <a target="84000-knowledgebase">
                                                <!--<xsl:attribute name=" href" select="concat($reading-room-path, '/knowledgebase/', $knowledgebase-instances[1]/@id, '.html', if($tei-editor) then '?view-mode=editor' else '')"/>-->
                                                <xsl:call-template name="href-attribute">
                                                    <xsl:with-param name="resource-type" select="'knowledgebase'"/>
                                                    <xsl:with-param name="resource-id" select="$knowledgebase-instances[1]/@id"/>
                                                </xsl:call-template>
                                                <xsl:value-of select="'View the 84000 Knowledge Base article'"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                </ul>
                                
                            </div>
                        </xsl:if>
                        
                        <!-- Link to glossary tool -->
                        <xsl:if test="$tei-editor and $environment/m:url[@id eq 'operations']">
                            
                            <div>
                                
                                <xsl:variable name="resource-id" select="if($knowledgebase) then $knowledgebase/m:page/@xml:id else $glossary-part/parent::m:translation/@id"/>
                                <xsl:variable name="resource-type" select="if($knowledgebase) then 'knowledgebase' else 'translation'"/>
                                
                                <a target="84000-glossary-tool" class="editor">
                                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/data(), '/edit-glossary.html', '?resource-id=', $resource-id, '&amp;resource-type=', $resource-type,'&amp;glossary-id=', $glossary-item/@xml:id, '&amp;max-records=1')"/>
                                    <xsl:value-of select="'Open in the glossary editor'"/>
                                </a>
                                
                            </div>
                            
                        </xsl:if>
                        
                    </div>
                    
                </div>
                
            </xsl:for-each>
            
        </xsl:if>
        
        <!-- Link to glossary form -->
        <!-- Knowledge base only, editor mode, operations app, no child divs and an id -->
        <xsl:if test="$tei-editor and $environment/m:url[@id eq 'operations'] and m:knowledgebase/m:page[@xml:id gt '']">
            <div>
                <a class="editor" target="84000-operations">
                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/text(), '/edit-glossary.html', '?resource-id=', m:knowledgebase/m:page/@xml:id, '&amp;resource-type=knowledgebase&amp;filter=blank-form')"/>
                    <xsl:value-of select="'Add a glossary entry'"/>
                </a>
            </div>
        </xsl:if>
        
    </xsl:template>
    <xsl:template name="cached-locations">
        
        <xsl:param name="cached-locations" as="element(m:location)*"/>
        <xsl:param name="glossary-id" as="xs:string"/>
        <xsl:param name="translation-root" select="$root"/>
        
        <xsl:if test="$cached-locations">
            <ul class="list-inline">
                <xsl:for-each select="$cached-locations">
                    <li>
                        <a>
                            
                            <xsl:variable name="cached-location" select="."/>
                            
                            <xsl:variable name="target-element" as="element()?">
                                <xsl:call-template name="target-element">
                                    <xsl:with-param name="target-id" select="$cached-location/@id"/>
                                    <xsl:with-param name="translation-root" select="$translation-root"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <xsl:choose>
                                <xsl:when test="$target-element">
                                    <xsl:call-template name="target-element-href">
                                        <xsl:with-param name="target-element" select="$target-element"/>
                                        <xsl:with-param name="mark-id" select="$glossary-id"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="concat(m:view-mode-parameter((),'?'), m:archive-path-parameter(), '#', $cached-location/@id)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                                <xsl:attribute name="data-location-id" select="$cached-location/@id"/>
                            </xsl:if>
                            
                            <xsl:choose>
                                <xsl:when test="$target-element">
                                    <xsl:call-template name="target-element-label">
                                        <xsl:with-param name="target-element" select="$target-element"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="position()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>
    
    <!-- Sections -->
    <xsl:template match="m:part | tei:div">
        
        <xsl:variable name="element" select="."/>
        <xsl:variable name="element-id" select="($element/@id, $element/@xml:id)[1]" as="xs:string?"/>
        
        <div>
            
            <!-- Set the id -->
            <xsl:if test="ancestor-or-self::m:part[@content-status][1][not(@content-status eq 'preview')]">
                <xsl:attribute name="id" select="$element-id"/>
            </xsl:if>
            
            <!-- Set the class -->
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" as="xs:string*">
                    
                    <xsl:value-of select="'nested-section'"/>
                    <xsl:value-of select="'relative'"/>
                    
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:call-template name="data-location-id-attribute">
                <xsl:with-param name="node" select="$element"/>
            </xsl:call-template>
            
            <!-- If the child is another div it will recurse -->
            <!--<xsl:if test="$view-mode[not(@parts eq 'passage')] or node()[not(self::tei:head)]">
                <xsl:apply-templates select="node()"/>
            </xsl:if>-->
            
            <xsl:apply-templates select="$element/node()"/>
            
            <!-- Add link to tei editor -->
            <xsl:call-template name="tei-editor">
                <xsl:with-param name="node" select="$element"/>
            </xsl:call-template>
            
        </div>
        
    </xsl:template>
    
    <!-- Headers -->
    <!-- About headers -->
    <xsl:template match="tei:head[@type eq 'about']">
        <h2>
            
            <xsl:call-template name="id-attribute">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
            
            <!-- Don't duplicate if this is already the title -->
            <xsl:if test="string-join(data(), '') eq $section/m:titles/m:title[@xml:lang eq 'en']/text()">
                <xsl:attribute name="class" select="'sr-only'"/>
            </xsl:if>
            
            <xsl:apply-templates select="node()"/>
            
        </h2>
    </xsl:template>
    <!-- Primary headers / linked to a section -->
    <xsl:template match="tei:head[@type eq parent::*/@type]">
        
        <xsl:variable name="part" select="(parent::m:part, parent::tei:div)[1]"/>
        <xsl:variable name="part-nesting" select="($part/@nesting/number(), count(ancestor::tei:div))[1]"/>
        <xsl:variable name="header-tag" as="xs:string">
            <xsl:choose>
                <xsl:when test="$part-nesting eq 0">
                    <xsl:value-of select="'h2'"/>
                </xsl:when>
                <xsl:when test="$part-nesting eq 1">
                    <xsl:value-of select="'h3'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'h4'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title-text" select="$part/m:title-text[1]"/>
        <xsl:variable name="title-supp" select="$part/m:title-supp[1]"/>
        
        <!-- .rw container -->
        <div>
            
            <!-- .rw container classes -->
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" as="xs:string*">
                    <xsl:value-of select="'rw'"/>
                    <xsl:value-of select="'rw-section-head'"/>
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:call-template name="data-location-id-attribute">
                <xsl:with-param name="node" select="$part"/>
            </xsl:call-template>
            
            <!-- Add a milestone .gtr -->
            <xsl:if test="$part[@prefix]">
                <div class="gtr">
                    <xsl:choose>
                        
                        <!-- show a link -->
                        <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))] and $part[@id]">
                            <xsl:call-template name="bookmark-link">
                                <xsl:with-param name="bookmark-target-hash" select="$part/@id"/>
                                <xsl:with-param name="bookmark-target-part" select="$part/@id"/>
                                <xsl:with-param name="bookmark-label">
                                    <xsl:call-template name="bookmark-label">
                                        <xsl:with-param name="prefix" select="$part/@prefix"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="bookmark-title" select="data()"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                        <!-- or just the text -->
                        <xsl:otherwise>
                            <xsl:call-template name="bookmark-label">
                                <xsl:with-param name="prefix" select="$part/@prefix"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </div>
            </xsl:if>
            
            <xsl:call-template name="quotes-inbound">
                <xsl:with-param name="quotes" select="key('quotes-inbound', $part/@id, $root)"/>
            </xsl:call-template>
            
            <!-- .rw-heading container -->
            <div>
                
                <!-- .rw-heading container classes -->
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="base-classes" as="xs:string*">
                        <xsl:value-of select="'rw-heading'"/>
                        <xsl:value-of select="'heading-section'"/>
                        <xsl:if test="not(@type = ('section', 'colophon', 'homage', 'prologue'))">
                            <xsl:value-of select="'chapter'"/>
                        </xsl:if>
                        <xsl:if test="$part-nesting">
                            <xsl:value-of select="concat('nested nested-', $part-nesting)"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                
                <!-- Add another container element for dots :before and :after -->
                <header>
                    
                    <!-- Supplementary title -->
                    <xsl:if test="$title-supp[text()]">
                        <div class="h4">
                            
                            <xsl:call-template name="id-attribute">
                                <xsl:with-param name="node" select="$title-supp"/>
                            </xsl:call-template>
                            
                            <xsl:apply-templates select="$title-supp/text()"/>
                            
                        </div>
                    </xsl:if>
                    
                    <xsl:element name="{ $header-tag }">
                        
                        <xsl:call-template name="id-attribute">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="class-attribute">
                            <xsl:with-param name="base-classes" as="xs:string*">
                                <xsl:value-of select="'section-title'"/>
                                <xsl:if test="@xml:lang eq 'Sa-Ltn'">
                                    <xsl:value-of select="'break'"/>
                                </xsl:if>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:apply-templates select="node()"/>
                        
                        <xsl:call-template name="tei-editor">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                    </xsl:element>
                    
                    <xsl:if test="$title-text[text()]">
                        
                        <div class="h3">
                            
                            <xsl:call-template name="id-attribute">
                                <xsl:with-param name="node" select="$title-text"/>
                            </xsl:call-template>
                            
                            <xsl:apply-templates select="$title-text/node()"/>
                            
                        </div>
                        
                    </xsl:if>
                    
                </header>
                
            </div>
            
        </div>
        
    </xsl:template>
    <!-- Other headers, could be anywhere in text -->
    <xsl:template match="tei:head">
        
        <!-- .rw container from milestone template -->
        <xsl:call-template name="milestone">
            
            <xsl:with-param name="content">
                
                <!-- .rw-heading container -->
                <div>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'rw-heading'"/>
                            <xsl:value-of select="'heading-section'"/>
                            <xsl:if test="@type eq 'nonStructuralBreak'">
                                <xsl:value-of select="'supplementary'"/>
                            </xsl:if>
                        </xsl:with-param>
                        <xsl:with-param name="lang" select="@xml:lang"/>
                    </xsl:call-template>
                    
                    <header class="h3">
                        
                        <xsl:call-template name="id-attribute">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                        <xsl:choose>
                            <xsl:when test="@type eq 'sub'">
                                <xsl:attribute name="class" select="'h4'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class" select="'h3'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <xsl:apply-templates select="node()"/>
                        
                        <xsl:call-template name="tei-editor">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                    </header>
                    
                </div>
            </xsl:with-param>
            
            <xsl:with-param name="row-type" select="'section-head'"/>
            
        </xsl:call-template>
        
    </xsl:template>
    <xsl:template match="m:title-text">
        <!-- Already parsed in combination with tei:head, so ignore -->
    </xsl:template>
    <xsl:template match="m:title-supp">
        <!-- Already parsed in combination with tei:head, so ignore -->
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:media">
        <xsl:choose>
            
            <xsl:when test="@mimeType eq 'audio/mpeg' and $view-mode[@client = ('browser', 'ajax')]">
                <xsl:call-template name="milestone">
                    <xsl:with-param name="content">
                        <audio controls="controls">
                            <xsl:attribute name="title" select="tei:desc"/>
                            <source type="audio/mpeg">
                                <xsl:attribute name="src" select="concat($reading-room-path, @url)"/>
                            </source>
                            Your browser does not support the <code>audio</code> element.
                        </audio>
                    </xsl:with-param>
                    <xsl:with-param name="row-type" select="'audio'"/>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:when test="@mimeType eq 'image/png' and $view-mode[@client = ('browser', 'ajax', 'pdf', 'ebook')]">
                <xsl:variable name="caption" select="tei:desc/text() ! normalize-space()"/>
                <xsl:choose>
                    <xsl:when test="$caption">
                        <xsl:choose>
                            <xsl:when test="$view-mode[@client eq 'ebook']">
                                <div class="row sml-margin top bottom">
                                    <xsl:apply-templates select="$caption"/>
                                    <img>
                                        <xsl:attribute name="src" select="concat('image', @url)"/>
                                        <xsl:attribute name="title" select="$caption"/>
                                    </img>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="row sml-margin top bottom">
                                    <div class="col-sm-8 col-xs-6">
                                        <xsl:apply-templates select="$caption"/>
                                    </div>
                                    <div class="col-sm-4 col-xs-6">
                                        <img class="img-responsive pull-right">
                                            <xsl:attribute name="src" select="concat($reading-room-path, @url)"/>
                                            <xsl:attribute name="title" select="$caption"/>
                                        </img>
                                    </div>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <img class="img-responsive">
                            <xsl:attribute name="src" select="@url"/>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="tei:code">
        <code>
            <xsl:apply-templates select="node()"/>
        </code>
    </xsl:template>
    
    <!-- Milestone -->
    <xsl:template name="milestone">
        
        <xsl:param name="content" required="yes"/>
        <xsl:param name="row-type" required="yes"/>
        
        <xsl:variable name="element" select="."/>
        
        <div>
            
            <xsl:choose>
                <xsl:when test="($translation | $knowledgebase)">
                    
                    <!-- Set id -->
                    <xsl:variable name="milestone" select="($element/preceding-sibling::tei:*[1][self::tei:milestone] | $element/preceding-sibling::tei:*[2][self::tei:milestone[following-sibling::tei:*[1][self::tei:lb]]] | $element/parent::tei:seg/preceding-sibling::tei:*[1][self::tei:milestone] | $element/parent::tei:seg/preceding-sibling::tei:*[2][self::tei:milestone[following-sibling::tei:*[1][self::tei:lb]]])[1]"/>
                    
                    <xsl:if test="$milestone[@xml:id] and ancestor-or-self::m:part[@content-status][1][not(@content-status eq 'preview')]">
                        <xsl:attribute name="id" select="$milestone/@xml:id"/>
                    </xsl:if>
                    
                    <!-- Set nearest id -->
                    <xsl:variable name="location-id">
                        <xsl:call-template name="persistent-location">
                            <xsl:with-param name="node" select="$element"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:attribute name="data-location-id" select="$location-id"/>
                    
                    <!-- Set the css class -->
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'rw'"/>
                            <xsl:value-of select="concat('rw-', $row-type)"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <!-- If there's a milestone add a gutter and milestone link -->
                    <xsl:if test="$milestone">
                        
                        <!-- Add a milestone anchor -->
                        <xsl:variable name="part" select="$element/ancestor::m:part[@prefix][1]"/>
                        <xsl:variable name="milestones-pre-processed" select="key('milestones-pre-processed', $milestone/@xml:id, $root)[1]" as="element(m:milestone)?"/>
                        
                        <xsl:if test="$milestones-pre-processed">
                            
                            <xsl:variable name="milestone-label">
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="($part/@prefix, '?')[1]"/>
                                    <xsl:with-param name="index" select="$milestones-pre-processed/@index"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <div class="gtr">
                                <xsl:choose>
                                    
                                    <!-- show a relative link -->
                                    <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))]">
                                        
                                        <xsl:call-template name="bookmark-link">
                                            <xsl:with-param name="bookmark-target-hash" select="$milestone/@xml:id"/>
                                            <xsl:with-param name="bookmark-target-part" select="$part/@id"/>
                                            <xsl:with-param name="bookmark-label" select="$milestone-label"/>
                                            <xsl:with-param name="link-class" select="'milestone from-tei'"/>
                                        </xsl:call-template>
                                        
                                    </xsl:when>
                                    
                                    <!-- or just the text -->
                                    <xsl:otherwise>
                                        
                                        <xsl:value-of select="$milestone-label"/>
                                        
                                    </xsl:otherwise>
                                    
                                </xsl:choose>
                            </div>
                            
                        </xsl:if>
                        
                    </xsl:if>
                    
                    <!-- Output the content -->
                    <xsl:sequence select="$content"/>
                    
                    <!-- Check for inbound quote link -->
                    <!-- Also check if this is the first node of a section with no header. 
                     The assumption is that the first node in the section will be a milestone. 
                     If this is the anchor of the first milestone in the section then it's the first element in the section -->
                    <xsl:variable name="quotes-location-id" select="($milestone/@xml:id, $milestone/ancestor::m:part[1][not(tei:head/@type = @type)][count(descendant::tei:milestone[1] | $milestone) eq 1]/@id)[1]" as="xs:string?"/>
                    <xsl:call-template name="quotes-inbound">
                        <xsl:with-param name="quotes" select="key('quotes-inbound', $quotes-location-id, $root)"/>
                    </xsl:call-template>
                    
                </xsl:when>
                <xsl:otherwise>
                    
                    <!-- Output the content -->
                    <xsl:sequence select="$content"/>
                    
                </xsl:otherwise>
            </xsl:choose>
            
        </div>
        
    </xsl:template>
    
    <!-- Temporary id - used to locate search results -->
    <xsl:template name="id-attribute">
        
        <xsl:param name="node" required="yes"/>
        
        <!-- If an id is present then set the id attribute -->
        <xsl:if test="not($view-mode[@client = ('ebook', 'app')]) and not($node/ancestor-or-self::m:part[@content-status][1][@content-status eq 'preview'])">
            
            <xsl:variable name="id">
                <xsl:choose>
                    <xsl:when test="$node[@xml:id]">
                        <xsl:value-of select="$node/@xml:id"/>
                    </xsl:when>
                    <xsl:when test="$node[@tid]">
                        <xsl:value-of select="concat('node-', $node/@tid)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                
                <!-- A translation -->
                <xsl:when test="$translation">
                    
                    <xsl:if test="$id gt ''">
                        <xsl:attribute name="id" select="$id"/>
                    </xsl:if>
                    
                    <xsl:variable name="text-normalized" as="text()">
                        <xsl:value-of select="common:normalize-data(data($node))"/>
                    </xsl:variable>
                    
                    <!-- Defer the glossary parsing -->
                    <xsl:if test="$view-mode[@glossary eq 'defer'] and m:glossarize-node($node, $text-normalized) and $node[@tid] and not($node[ancestor::*/@tid])">
                        <xsl:call-template name="in-view-replace-attribute">
                            <xsl:with-param name="element-id" select="$id"/>
                            <xsl:with-param name="fragment-id" select="$id"/>
                        </xsl:call-template>
                    </xsl:if>
                    
                </xsl:when>
                
                <!-- A knowledge base page -->
                <xsl:when test="$knowledgebase">
                    <xsl:attribute name="id" select="$id"/>
                </xsl:when>
                
                <!-- If we are rendering a section then the id may refer to a text in that section rather than the section itself -->
                <xsl:when test="$section">
                    
                    <xsl:choose>
                        <xsl:when test="$node/ancestor::m:text">
                            <xsl:attribute name="id" select="concat($node/ancestor::m:text[1]/@resource-id, '-', $id)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id" select="$id"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:when>
                
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!-- Add links to inbound and outbound quotes -->
    <xsl:template name="quote-link">
        
        <xsl:param name="quote" as="element(m:quote)"/>
        
        <!-- If incomplete, only show if we're in editor mode -->
        <xsl:if test="$view-mode[@client = ('browser', 'ajax')] and ($quote/@resource-id gt '' and $quote/m:source/@resource-id gt '' or $tei-editor)">
            <a>
                
                <xsl:attribute name="data-quote-id" select="$quote/@id"/>
                
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="base-classes" as="xs:string*">
                        
                        <xsl:value-of select="'quote-link'"/>
                        
                        <xsl:if test="not($quote/@resource-id gt '') or not($quote/m:source/@resource-id gt '')">
                            <xsl:value-of select="'quote-error'"/>
                        </xsl:if>
                        
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:choose>
                    
                    <!-- This text quotes another text -->
                    <xsl:when test="$quote/@resource-id eq $toh-key">
                        
                        <xsl:attribute name="href" select="concat('/translation/', $quote/m:source/@resource-id, '.html', '?commentary=', $toh-key, '&amp;part=', $quote/m:source/@location-part, '#', $quote/m:source/@location-id)"/>
                        <xsl:attribute name="target" select="concat('translation-', $quote/m:source/@resource-id)"/>
                        <xsl:attribute name="data-dualview-href" select="concat('/translation/', $quote/m:source/@resource-id, '.html', '?commentary=', $toh-key, '#', $quote/m:source/@location-id, '/', $quote/@id)"/>
                        <xsl:attribute name="data-dualview-title" select="concat($quote/m:source/m:text-title, ' (root text)')"/>
                        <xsl:attribute name="data-loading" select="concat('Loading ', 'root text', '...')"/>
                        <xsl:attribute name="title" select="$quote/m:label"/>
                        
                        <xsl:value-of select="$quote/m:source/m:text-title"/>
                        
                    </xsl:when>
                    
                    <!-- Another text quotes this text, and it's already set as the commentary -->
                    <xsl:when test="$quote/m:source/@resource-id eq $toh-key and $quote/@resource-id eq $requested-commentary">
                        
                        <xsl:attribute name="href" select="concat('/translation/', $quote/@resource-id, '.html', '?part=', $quote/@part, '#', $quote/@id)"/>
                        <xsl:attribute name="target" select="concat('translation-', $quote/@resource-id)"/>
                        <xsl:attribute name="data-dualview-href" select="concat('/translation/', $quote/@resource-id, '.html', '#', $quote/@id)"/>
                        <xsl:attribute name="data-dualview-title" select="concat($quote/m:text-title, ' (commentary)')"/>
                        <xsl:attribute name="data-loading" select="concat('Loading ', 'commentary', '...')"/>
                        <xsl:attribute name="title" select="$quote/m:label"/>
                        
                        <xsl:value-of select="$quote/m:text-title"/>
                        
                    </xsl:when>
                    
                    <!-- Another text quotes this text -->
                    <!-- Reload this text for that commentary -->
                    <xsl:when test="$quote/m:source/@resource-id eq $toh-key">
                        
                        <xsl:attribute name="href" select="concat('?commentary=', $quote/@id, '#', $quote/m:source/@location-id)"/>
                        <xsl:attribute name="target" select="'_self'"/>
                        <xsl:attribute name="data-loading" select="concat('Re-loading as root text for commentary', '...')"/>
                        <xsl:attribute name="data-confirm" select="string-join(($quote/m:label, 'Reload this text to be read with this commentary?', 'This may take a few moments.'), '\n\n')"/>
                        <xsl:attribute name="title" select="$quote/m:label"/>
                        
                        <xsl:value-of select="$quote/m:text-title"/>
                        
                    </xsl:when>
                    
                </xsl:choose>
                
            </a>
        </xsl:if>
    
    </xsl:template>
    
    <xsl:template name="quotes-inbound">
        
        <xsl:param name="quotes" as="element(m:quote)*"/>
        
        <xsl:if test="$quotes">
            <div class="quotes-inbound">
                <xsl:for-each-group select="$quotes" group-by="m:source/@resource-id">
                    <!-- Group texts -->
                    <div>
                        <xsl:for-each select="current-group()">
                            
                            <xsl:variable name="quote-link" as="element(xhtml:a)?">
                                <xsl:call-template name="quote-link">
                                    <xsl:with-param name="quote" select="."/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <xsl:if test="$quote-link">
                                <div class="quote-link-container">
                                    <xsl:if test="position() gt 1">
                                        <xsl:attribute name="class" select="'quote-link-container hidden'"/>
                                    </xsl:if>
                                    <xsl:sequence select="$quote-link"/>
                                </div>
                            </xsl:if>
                            
                        </xsl:for-each>
                    </div>
                </xsl:for-each-group>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Add link to TEI Editor -->
    <xsl:template name="tei-editor">
        
        <xsl:param name="node" as="node()"/>
        
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="$node[@tid]">
                    <xsl:value-of select="concat('node-', $node/@tid)"/>
                </xsl:when>
                <xsl:when test="$node[@xml:id]">
                    <xsl:value-of select="$node/@xml:id"/>
                </xsl:when>
                <xsl:when test="$node[self::m:part][@id][@nesting ! xs:integer(.) gt 0]">
                    <xsl:value-of select="$node/@id"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$tei-editor and $view-mode[not(@client = ('ebook', 'app'))] and $id gt ''">
            
            <!-- Knowledge base only -->
            <xsl:variable name="resource-id" select="if($knowledgebase[m:page/@kb-id]) then $knowledgebase/m:page/@xml:id else ()(:$translation/@id:)"/>
            <xsl:variable name="resource-type" select="if($knowledgebase) then 'knowledgebase' else 'translation'"/>
            
            <xsl:if test="$resource-id">
                
                <xsl:if test="$node[text()]">
                    <xsl:value-of select="' '"/>
                </xsl:if>
                
                <a target="tei-editor" class="editor" title="Open TEI editor">
                    
                    <xsl:if test="$node[comment()]">
                        <xsl:attribute name="class" select="'editor sticky-note'"/>
                        <xsl:attribute name="title" select="concat('Comment: ', $node/comment() ! normalize-space(.))"/>
                    </xsl:if>
                    
                    <xsl:attribute name="href" select="concat('/tei-editor.html?resource-type=', $resource-type, '&amp;resource-id=', $resource-id,'&amp;passage-id=', $id, '#ajax-source')"/>
                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                    
                    <xsl:choose>
                        <xsl:when test="$node[self::m:part | self::tei:div]">
                            <xsl:value-of select="'Add Section'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Edit'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </a>
                
            </xsl:if>
            
        </xsl:if>
    </xsl:template>
    
    <!-- Table of Contents - html rendering - derived from parts, not a part itself -->
    <xsl:template name="table-of-contents">
        
        <section id="toc" class="page page-force tei-parser">
            
            <hr class="hidden-print"/>
            
            <div class="rw rw-section-head">
                <div class="gtr">
                    <xsl:call-template name="bookmark-link">
                        <xsl:with-param name="bookmark-target-hash" select="'toc'"/>
                        <xsl:with-param name="bookmark-target-part" select="'contents'"/>
                        <xsl:with-param name="bookmark-label">
                            <xsl:call-template name="bookmark-label">
                                <xsl:with-param name="prefix" select="'co'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
                <div class="rw-heading heading-section chapter">
                    <header>
                        <h2 class="section-title">
                            <xsl:value-of select="'Table of Contents'"/>
                        </h2>
                    </header>
                </div>
            </div>
            
            <nav class="rw" aria-label="Table of Contents">
                <table class="contents-table">
                    <tbody>
                        
                        <tr>
                            <td>
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="'ti'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <a target="_self">
                                    <xsl:attribute name="href" select="concat('#', 'titles')"/>
                                    <xsl:value-of select="'Title'"/>
                                </a>
                            </td>
                        </tr>
                        
                        <tr>
                            <td>
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="'im'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <a target="_self">
                                    <xsl:attribute name="href" select="concat('#', 'imprint')"/>
                                    <xsl:value-of select="'Imprint'"/>
                                </a>
                            </td>
                        </tr>
                        
                        <tr>
                            <td>
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="'co'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <a target="_self">
                                    <xsl:attribute name="href" select="concat('#', 'toc')"/>
                                    <xsl:value-of select="'Contents'"/>
                                </a>
                            </td>
                        </tr>
                        
                        <xsl:call-template name="toc-parts">
                            <xsl:with-param name="parts" select="$translation/m:part"/>
                            <xsl:with-param name="doc-type" select="'html'"/>
                        </xsl:call-template>
                        
                    </tbody>
                </table>
            </nav>
            
        </section>
        
    </xsl:template>
    <!-- Recurse through toc - html and epub (controlled by doc-type) -->
    <xsl:template name="toc-parts">
        
        <xsl:param name="parts" as="element(m:part)*"/>
        <xsl:param name="doc-type" as="xs:string"/>
        
        <xsl:for-each select="$parts">
            
            <xsl:variable name="part" select="."/>
            <xsl:variable name="sub-parts" select="$part/m:part"/>
            
            <xsl:choose>
                
                <xsl:when test="$doc-type eq 'epub'">
                    
                    <xsl:choose>
                        
                        <!-- Create a link/label -->
                        <xsl:when test="$part/tei:head[@type eq $part/@type][data()]">
                            <li>
                                <a>
                                    
                                    <xsl:variable name="page" select="$part/ancestor-or-self::m:part[@id][@nesting eq '0'][1]/@id"/>
                                    <xsl:variable name="anchor" select="if($part[not(@nesting eq '0') and not(@id = ('translation', 'appendix'))]) then concat('#', $part/@id) else ''"/>
                                    <xsl:attribute name="href" select="concat($page, '.xhtml', $anchor)"/>
                                    
                                    <xsl:if test="$part[@type eq 'chapter'][@prefix]">
                                        <xsl:value-of select="concat($part/@prefix, '. ')"/>
                                    </xsl:if>
                                    
                                    <xsl:apply-templates select="$part/tei:head[@type eq $part/@type][1]/node()[not(self::tei:note)]"/>
                                    
                                </a>
                                
                                <!-- Move down the tree -->
                                <xsl:if test="$sub-parts">
                                    <ol>
                                        <xsl:call-template name="toc-parts">
                                            <xsl:with-param name="parts" select="$sub-parts"/>
                                            <xsl:with-param name="doc-type" select="$doc-type"/>
                                        </xsl:call-template>
                                    </ol>
                                </xsl:if>
                                
                            </li>
                        </xsl:when>
                        
                        <!-- Move straight down the tree -->
                        <xsl:when test="$sub-parts">
                            <xsl:call-template name="toc-parts">
                                <xsl:with-param name="parts" select="$sub-parts"/>
                                <xsl:with-param name="doc-type" select="$doc-type"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                    </xsl:choose>
                </xsl:when>
                
                <xsl:when test="$doc-type eq 'ncx'">
                    <xsl:choose>
                        
                        <!-- Create a new nav point -->
                        <xsl:when test="$part/tei:head[@type eq $part/@type][data()]">
                            <navPoint xmlns="http://www.daisy.org/z3986/2005/ncx/">
                                
                                <xsl:attribute name="id" select="$part/@id"/>
                                <xsl:variable name="page" select="$part/ancestor-or-self::m:part[@id][@nesting eq '0'][1]/@id"/>
                                <xsl:variable name="anchor" select="if($part[not(@nesting eq '0') and not(@id = ('translation', 'appendix'))]) then concat('#', $part/@id) else ''"/>
                                
                                <navLabel>
                                    <text>
                                        <xsl:apply-templates select="$part/tei:head[@type eq $part/@type][1]/text()"/>
                                    </text>
                                </navLabel>
                                
                                <content>
                                    <xsl:attribute name="src" select="concat($page, '.xhtml', $anchor)"/>
                                </content>
                                
                                <!-- Move down the tree -->
                                <xsl:if test="$sub-parts">
                                    <xsl:call-template name="toc-parts">
                                        <xsl:with-param name="parts" select="$sub-parts"/>
                                        <xsl:with-param name="doc-type" select="$doc-type"/>
                                    </xsl:call-template>
                                </xsl:if>
                                
                            </navPoint>
                        </xsl:when>
                        
                        <!-- Move straight down the tree -->
                        <xsl:when test="$sub-parts">
                            <xsl:call-template name="toc-parts">
                                <xsl:with-param name="parts" select="$sub-parts"/>
                                <xsl:with-param name="doc-type" select="$doc-type"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                    </xsl:choose>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    
                    <!-- Link to the section -->
                    <xsl:if test="$part/tei:head[@type eq $part/@type][data()]">
                        <tr>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="$part[@prefix]">
                                        <xsl:call-template name="bookmark-label">
                                            <xsl:with-param name="prefix" select="$part/@prefix"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'·'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <a class="log-click" target="_self">
                                    
                                    <xsl:choose>
                                        
                                        <!-- Set href for crawlers, but override in Reading Room -->
                                        <xsl:when test="$view-mode[@client = ('browser', 'ajax')]">
                                            <xsl:attribute name="href" select="concat('?part=', $part/@id, m:view-mode-parameter(()), m:archive-path-parameter(), '#', $part/@id)"/>
                                            <xsl:attribute name="data-href-override" select="concat('#', $part/@id)"/>
                                        </xsl:when>
                                        
                                        <!-- PDFs use hash -->
                                        <xsl:otherwise>
                                            <xsl:attribute name="href" select="concat('#', $part/@id)"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                    
                                    <xsl:apply-templates select="$part/tei:head[@type eq $part/@type][1]/node()[not(self::tei:note)]"/>
                                    
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                    
                    <xsl:choose>
                        
                        <!-- Create an expandable block for sub-sections -->
                        <xsl:when test="$sub-parts/tei:head[data()]">
                            
                            <xsl:variable name="count-chapters" select="count($sub-parts[@type eq 'chapter'])"/>
                            <xsl:variable name="count-sections" select="count($sub-parts[tei:head[data()]])"/>
                            <xsl:variable name="sub-parts-label">
                                <xsl:choose>
                                    <xsl:when test="$count-chapters eq 1">
                                        <xsl:value-of select="'1 chapter'"/>
                                    </xsl:when>
                                    <xsl:when test="$count-chapters gt 1">
                                        <xsl:value-of select="concat($count-chapters, ' chapters')"/>
                                    </xsl:when>
                                    <xsl:when test="$count-sections eq 1">
                                        <xsl:value-of select="'1 section'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat($count-sections, ' sections')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <xsl:variable name="expand-id" select="concat('toc-', $part/@id)"/>
                            <xsl:variable name="expanded" select="false()"/>
                            
                            <tr class="sub">
                                <td/>
                                <td>
                                    
                                    <!-- Link to open/close -->
                                    <a role="button" data-toggle="collapse">
                                        
                                        <xsl:attribute name="href" select="concat('#', $expand-id)"/>
                                        <xsl:attribute name="aria-controls" select="$expand-id"/>
                                        
                                        <xsl:choose>
                                            <xsl:when test="$expanded">
                                                <xsl:attribute name="class" select="'small text-muted hidden-print'"/>
                                                <xsl:attribute name="aria-expanded" select="'true'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="class" select="'collapsed small text-muted hidden-print'"/>
                                                <xsl:attribute name="aria-expanded" select="'false'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        <span class="collapsed-show">
                                            <span class="monospace">
                                                <xsl:value-of select="'+ '"/>
                                            </span>
                                            <xsl:value-of select="$sub-parts-label"/>
                                        </span>
                                        <span class="collapsed-hide">
                                            <span class="monospace">
                                                <xsl:value-of select="'- '"/>
                                            </span>
                                            <xsl:value-of select="$sub-parts-label"/>
                                        </span>
                                        
                                    </a>
                                    
                                    <!-- Expandable box -->
                                    <div>
                                        
                                        <xsl:attribute name="id" select="$expand-id"/>
                                        
                                        <xsl:choose>
                                            <xsl:when test="$expanded">
                                                <xsl:attribute name="class" select="'collapse in persist print-expand collapse-chapter'"/>
                                                <xsl:attribute name="aria-expanded" select="'true'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="class" select="'collapse persist print-expand collapse-chapter'"/>
                                                <xsl:attribute name="aria-expanded" select="'false'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        <table>
                                            <tbody>
                                                <!-- Process sub-sections -->
                                                <xsl:call-template name="toc-parts">
                                                    <xsl:with-param name="parts" select="$sub-parts"/>
                                                    <xsl:with-param name="doc-type" select="$doc-type"/>
                                                </xsl:call-template>
                                            </tbody>
                                        </table>
                                    </div>
                                    
                                </td>
                            </tr>
                            
                        </xsl:when>
                        
                        <!-- Pass the subsections down the tree -->
                        <xsl:when test="$sub-parts">
                            
                            <xsl:call-template name="toc-parts">
                                <xsl:with-param name="parts" select="$sub-parts"/>
                                <xsl:with-param name="doc-type" select="$doc-type"/>
                            </xsl:call-template>
                            
                        </xsl:when>
                        
                    </xsl:choose>
                    
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:for-each>
    
    </xsl:template>

    <xsl:template name="class-attribute">
        
        <xsl:param name="base-classes" as="xs:string*"/>
        <xsl:param name="html-classes" as="xs:string*"/>
        <xsl:param name="lang" as="xs:string?"/>
        
        <xsl:variable name="lang-class" select="common:lang-class(normalize-space($lang))"/>
        
        <xsl:variable name="css-classes" as="xs:string*">
            <xsl:if test="count($base-classes[normalize-space()]) gt 0">
                <xsl:value-of select="string-join($base-classes[normalize-space()], ' ')"/>
            </xsl:if>
            <xsl:if test="count($html-classes[normalize-space()]) gt 0 and $view-mode[@client = ('browser', 'pdf', 'ajax')]">
                <xsl:value-of select="string-join($html-classes[normalize-space()], ' ')"/>
            </xsl:if>
            <xsl:value-of select="$lang-class"/>
        </xsl:variable>
        
        <xsl:if test="count($css-classes[normalize-space()]) gt 0">
            <xsl:attribute name="class" select="string-join($css-classes[normalize-space()], ' ')"/>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="$lang-class eq 'text-bo'">
                <xsl:attribute name="lang" select="'bo'"/>
            </xsl:when>
            <xsl:when test="$lang-class eq 'text-sa'">
                <xsl:attribute name="lang" select="'sa-LTN'"/>
            </xsl:when>
            <xsl:when test="$lang-class eq 'text-wy'">
                <xsl:attribute name="lang" select="'bo-LTN'"/>
            </xsl:when>
            <xsl:when test="$lang-class eq 'text-zh'">
                <xsl:attribute name="lang" select="'zh'"/>
            </xsl:when>
            <xsl:when test="$lang-class eq 'text-en'">
                <xsl:attribute name="lang" select="'en'"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="href-attribute">
        
        <xsl:param name="fragment-id" as="xs:string?"/>
        <xsl:param name="part-id" as="xs:string?"/>
        <xsl:param name="mark-id" as="xs:string?"/>
        <xsl:param name="resource-id" select="$requested-resource" as="xs:string"/>
        <xsl:param name="resource-type" select="if($knowledgebase) then 'knowledgebase' else 'translation'" as="xs:string"/>
        
        <xsl:choose>
            
            <!-- Link to section in ebook -->
            <xsl:when test="$view-mode[@client = ('ebook', 'app')]">
                
                <xsl:choose>
                    
                    <!-- Link to an external text -->
                    <xsl:when test="not($resource-id eq $requested-resource)">
                        <xsl:attribute name="href" select="concat('https://read.84000.co/', $resource-type, '/', $resource-id, '.html', if($fragment-id) then concat('#', $fragment-id) else ())"/>
                    </xsl:when>
                    
                    <!-- Check there's a part -->
                    <xsl:when test="$part-id">
                        <xsl:attribute name="href" select="concat($part-id, '.xhtml',  if($fragment-id) then concat('#', $fragment-id) else ())"/>
                    </xsl:when>
                    
                    <!-- Default to fragment -->
                    <xsl:when test="$fragment-id">
                        <xsl:attribute name="href" select="concat('#', $fragment-id)"/>
                    </xsl:when>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <!-- Link to section in pdf -->
            <xsl:when test="$view-mode[@client = ('pdf')]">
                
                <xsl:choose>
                    
                    <!-- Link to an external text -->
                    <xsl:when test="not($resource-id eq $requested-resource)">
                        <xsl:attribute name="href" select="concat('https://read.84000.co/', $resource-type, '/', $resource-id, '.html',  if($fragment-id) then concat('#', $fragment-id) else ())"/>
                    </xsl:when>
                    
                    <!-- Default to fragment -->
                    <xsl:when test="$fragment-id">
                        <xsl:attribute name="href" select="concat('#', $fragment-id)"/>
                    </xsl:when>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <xsl:otherwise>
                
                <xsl:choose>
                    
                    <!-- Link to an external text -->
                    <xsl:when test="not($resource-id eq $requested-resource)">
                        <xsl:attribute name="href" select="concat('/', $resource-type, '/', $resource-id, '.html',  if($fragment-id) then concat('#', $fragment-id) else ())"/>
                    </xsl:when>
                    
                    <!-- Default to fragment -->
                    <xsl:when test="$fragment-id">
                        <xsl:attribute name="href" select="concat(m:view-mode-parameter((),'?'), m:archive-path-parameter(),  if($fragment-id) then concat('#', $fragment-id) else ())"/>
                    </xsl:when>
                    
                </xsl:choose>
                
                <!-- Marks a target -->
                <xsl:if test="$view-mode[@client = ('browser', 'ajax')] and $mark-id">
                    <xsl:attribute name="data-postscroll-mark" select="concat('[data-mark-id=&#34;', $mark-id, '&#34;]')"/>
                </xsl:if>
                
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="in-view-replace-attribute">
        
        <xsl:param name="element-id" as="xs:string"/>
        <xsl:param name="fragment-id" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$toh-key">
                <xsl:attribute name="data-in-view-replace" select="concat('/passage/', $toh-key, '.html', '?passage-id=', $element-id, m:view-mode-parameter(()), m:archive-path-parameter(), '#', $fragment-id)"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="data-location-id-attribute">
        <xsl:param name="node" as="node()"/>
        <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
            <xsl:attribute name="data-location-id">
                <xsl:call-template name="persistent-location">
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="target-element" as="element()?">
        
        <xsl:param name="target-id" as="xs:string"/>
        <xsl:param name="translation-root" select="$root"/>
        
        <xsl:variable name="target" select="key('text-parts', $target-id, $translation-root)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('end-notes-pre-processed', $target-id, $translation-root)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('milestones-pre-processed', $target-id, $translation-root)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('glossary-cache-gloss', $target-id, $translation-root)[1]"/>
        
        <xsl:sequence select="$target"/>
        
    </xsl:template>
    
    <xsl:template name="target-element-href">
        
        <xsl:param name="target-element" as="element()"/>
        <xsl:param name="mark-id" as="xs:string?"/>
        
        <xsl:choose>
            
            <xsl:when test="$target-element/ancestor::m:pre-processed[not(@text-id eq $translation/@id)]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="fragment-id" select="$target-element/@id"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                    <xsl:with-param name="resource-id" select="$target-element/ancestor::m:pre-processed/@text-id"/>
                    <xsl:with-param name="resource-type" select="($target-element/ancestor::m:pre-processed/@resource-type, 'translation')[1]"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:gloss]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="fragment-id" select="$target-element/@id"/>
                    <xsl:with-param name="part-id" select="'glossary'"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:end-note]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="fragment-id" select="concat('end-note-', $target-element/@id)"/>
                    <xsl:with-param name="part-id" select="'end-notes'"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:milestone]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="fragment-id" select=" $target-element/@id"/>
                    <xsl:with-param name="part-id" select="$target-element/@part-id"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:part][@id]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="fragment-id" select=" $target-element/@id"/>
                    <xsl:with-param name="part-id" select="$target-element/ancestor-or-self::m:part[@id][not(@type = ('translation', 'appendix'))][last()]/@id"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="target-element-label" as="xs:string?">
        
        <xsl:param name="target-element" as="element()"/>
        
        <xsl:variable name="target-part" as="element()?">
            <xsl:choose>
                <xsl:when test="$target-element[self::m:end-note][@index]">
                    <xsl:sequence select="key('text-parts', 'end-notes', $root)[1]"/>
                </xsl:when>
                <xsl:when test="$target-element[self::m:gloss][@index]">
                    <xsl:sequence select="key('text-parts', 'glossary', $root)[1]"/>
                </xsl:when>
                <xsl:when test="$target-element[self::m:milestone][@index]">
                    <xsl:sequence select="key('text-parts', $target-element/@part-id, $root)[1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- The target is one of above types -->
            <xsl:when test="$target-part[@prefix]">
                <xsl:call-template name="bookmark-label">
                    <xsl:with-param name="prefix" select="$target-part/@prefix"/>
                    <xsl:with-param name="index" select="$target-element/@index"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- The target is a section -->
            <xsl:when test="$target-element[self::m:part][tei:head[@type = $target-element/@type]]">
                <xsl:value-of select="$target-element[tei:head[@type = $target-element/@type]][1]/tei:head[@type = $target-element/@type]/text()/normalize-space()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="$target-element/@id"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="download-label">
        <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$type eq 'html'">
                <xsl:value-of select="'Read online'"/>
            </xsl:when>
            <xsl:when test="$type eq 'epub'">
                <xsl:value-of select="'Download EPUB'"/>
            </xsl:when>
            <xsl:when test="$type eq 'azw3'">
                <xsl:value-of select="'Download AZW3 (Kindle)'"/>
            </xsl:when>
            <xsl:when test="$type eq 'pdf'">
                <xsl:value-of select="'Download PDF'"/>
            </xsl:when>
            <xsl:when test="$type eq 'app'">
                <xsl:value-of select="'Open in the 84000 App'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="download-icon">
        <xsl:param name="type" as="xs:string"/>
        <i>
            <xsl:choose>
                <xsl:when test="$type eq 'html'">
                    <xsl:attribute name="class" select="'fa fa-laptop'"/>
                </xsl:when>
                <xsl:when test="$type eq 'epub'">
                    <xsl:attribute name="class" select="'fa fa-book'"/>
                </xsl:when>
                <xsl:when test="$type eq 'azw3'">
                    <xsl:attribute name="class" select="'fa fa-amazon'"/>
                </xsl:when>
                <xsl:when test="$type eq 'pdf'">
                    <xsl:attribute name="class" select="'fa fa-file-pdf-o'"/>
                </xsl:when>
                <xsl:when test="$type eq 'app'">
                    <xsl:attribute name="class" select="'fa fa-tablet'"/>
                </xsl:when>
            </xsl:choose>
        </i>
    </xsl:template>
    
    <xsl:template name="bookmark-link">
        
        <xsl:param name="bookmark-target-hash" as="xs:string"/>
        <xsl:param name="bookmark-target-part" as="xs:string?"/>
        <xsl:param name="bookmark-label" as="xs:string"/>
        <xsl:param name="bookmark-title" as="xs:string?"/>
        <xsl:param name="link-class" as="xs:string?" select="'milestone'"/>
        
        <a title="Bookmark this section">
            
            <xsl:call-template name="href-attribute">
                <xsl:with-param name="fragment-id" select=" $bookmark-target-hash"/>
                <xsl:with-param name="part-id" select="$bookmark-target-part"/>
            </xsl:call-template>
            
            <xsl:choose>
                <xsl:when test="$translation">
                    <xsl:attribute name="data-bookmark" select="string-join((($translation/m:titles/m:title[@xml:lang eq 'en'])[1], if($bookmark-title gt '') then $bookmark-title else $bookmark-label), ' / ')"/>
                </xsl:when>
                <xsl:when test="$knowledgebase">
                    <xsl:attribute name="data-bookmark" select="string-join((($knowledgebase/m:page/m:titles/m:title[@xml:lang eq 'en'])[1], if($bookmark-title gt '') then $bookmark-title else $bookmark-label), ' / ')"/>
                </xsl:when>
            </xsl:choose>
            
            <xsl:attribute name="class" select="$link-class"/>
            <xsl:value-of select="$bookmark-label"/>
            
        </a>
        
    </xsl:template>
    
    <xsl:template name="bookmark-label" as="xs:string">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="index" as="xs:string?"/>
        <xsl:value-of select="concat($prefix, '.', if($index gt '') then concat('­', $index) else '')"/>
    </xsl:template>
    
    <!-- Filter out some nodes / direct children only -->
    <xsl:template name="filter-child-nodes" as="node()*">
        <xsl:param name="child-nodes" as="node()*"/>
        <xsl:param name="skip-nodes" as="node()*"/>
        <xsl:for-each select="$child-nodes">
            <xsl:if test="count(.|$skip-nodes) gt count($skip-nodes)">
                <xsl:sequence select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Return xhtml content, with some elements filtered -->
    <xsl:template name="parse-content" as="node()*">
        
        <!-- Input is TEI -->
        <xsl:param name="node" as="node()?"/>
        
        <!-- Filter out the ref-prologue -->
        <xsl:variable name="nodes-ref-prologue-filtered" as="node()*">
            <xsl:choose>
                <xsl:when test="count($node | $ref-prologue-parent) eq count($node)">
                    <xsl:call-template name="filter-child-nodes">
                        <xsl:with-param name="child-nodes" select="$node/node()"/>
                        <xsl:with-param name="skip-nodes" select="$ref-prologue"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$node/node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Convert to XHTML -->
        <xsl:variable name="xhtml-content" as="node()*">
            <xsl:apply-templates select="$nodes-ref-prologue-filtered"/>
        </xsl:variable>
        
        <!-- Mark quotes elided by ellipses -->
        <xsl:variable name="xhtml-content-quotes-merged" as="node()*">
            
            <!-- Has quoted content, including duplicates -->
            <xsl:if test="$requested-commentary gt '' and count($xhtml-content/descendant-or-self::xhtml:span/@data-quote-id) gt count(distinct-values($xhtml-content/descendant-or-self::xhtml:span/@data-quote-id)) ">
                
                <!-- Look for content between quotes with the same id -->
                <xsl:for-each select="$xhtml-content">
                    <xsl:variable name="xhtml-content-index" select="position()"/>
                    <xsl:variable name="preceding-quotes" select="$xhtml-content[position() lt $xhtml-content-index]/descendant-or-self::xhtml:span[@data-quote-id]" as="element(xhtml:span)*"/>
                    <xsl:variable name="trailing-quotes" select="$xhtml-content[position() gt $xhtml-content-index]/descendant-or-self::xhtml:span[@data-quote-id]" as="element(xhtml:span)*"/>
                    <xsl:choose>
                        <xsl:when test="$preceding-quotes/@data-quote-id = $trailing-quotes/@data-quote-id">
                            <xsl:call-template name="quote-bridge">
                                <xsl:with-param name="content" select="."/>
                                <xsl:with-param name="data-quote-ids" select="distinct-values($preceding-quotes[@data-quote-id = $trailing-quotes/@data-quote-id]/@data-quote-id)"/>
                                <xsl:with-param name="data-quote-index" select="1"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                
            </xsl:if>
            
        </xsl:variable>
        
        <!-- Output is XHTML -->
        <xsl:choose>
            <xsl:when test="$xhtml-content-quotes-merged">
                <xsl:sequence select="$xhtml-content-quotes-merged"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$xhtml-content"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="quote-bridge">
        
        <xsl:param name="content" as="node()*"/>
        <xsl:param name="data-quote-ids" as="xs:string*"/>
        <xsl:param name="data-quote-index" as="xs:integer"/>
        
        <xsl:choose>
            <!-- If there is some content that isn't marked, then mark it -->
            <xsl:when test="$content/descendant-or-self::text()[not(ancestor::xhtml:span[@data-quote-id eq $data-quote-ids[$data-quote-index]])]">
                <span data-quote-id="{ $data-quote-ids[$data-quote-index] }" class="quoted bridged">
                    <xsl:choose>
                        <xsl:when test="$data-quote-index lt count($data-quote-ids)">
                            <xsl:call-template name="quote-bridge">
                                <xsl:with-param name="content" select="$content"/>
                                <xsl:with-param name="data-quote-ids" select="$data-quote-ids"/>
                                <xsl:with-param name="data-quote-index" select="$data-quote-index + 1"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$content"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$data-quote-index lt count($data-quote-ids)">
                        <xsl:call-template name="quote-bridge">
                            <xsl:with-param name="content" select="$content"/>
                            <xsl:with-param name="data-quote-ids" select="$data-quote-ids"/>
                            <xsl:with-param name="data-quote-index" select="$data-quote-index + 1"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$content"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Determine the nearest xml:id -->
    <xsl:template name="persistent-location" as="xs:string">
        
        <xsl:param name="node" as="node()"/>
        
        <xsl:choose>
            
            <!-- Get the xml:id from the container -->
            <xsl:when test="$node[ancestor-or-self::tei:*[@xml:id]]">
                <xsl:value-of select="$node/ancestor-or-self::tei:*[@xml:id][1]/@xml:id"/>
            </xsl:when>
            
            <!-- Get the eft:id from the container -->
            <xsl:when test="$node[ancestor-or-self::m:entry[parent::m:glossary][@id]]">
                <xsl:value-of select="$node/ancestor-or-self::m:entry[@id][1]/@id"/>
            </xsl:when>
            
            <!-- Look for a nearest milestone -->
            <xsl:when test="$node[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]">
                <xsl:value-of select="$node/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]/@xml:id"/>
            </xsl:when>
            
            <!-- Default to the id of the nearest part -->
            <xsl:otherwise>
                <xsl:value-of select="$node/ancestor-or-self::m:part[@id][1]/@id"/>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <!-- Glossarize an element -->
    <xsl:template name="glossarize-element">
        
        <xsl:param name="element" as="element()"/>
        
        <!-- Find the first matching item -->
        <xsl:variable name="matching-glossary" as="element(tei:gloss)?">
            <xsl:choose>
                
                <!-- Find the first glossary that matches the ref -->
                <xsl:when test="$element/@ref[string() gt '']">
                    <xsl:sequence select="$glossary-prioritised[@mode eq 'marked'][@xml:id/string() eq $element/@ref/string()][1]"/>
                </xsl:when>
                
                <!-- Find the first glossary that matches the string -->
                <xsl:otherwise>
                    <xsl:variable name="element-data" select="normalize-space($element/data())"/>
                    <xsl:sequence select="$glossary-prioritised[@mode eq 'marked'][matches($element-data, common:matches-regex-exact(m:glossary-terms-to-match(.)), 'i')][1]"/>
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- If there's a match output -->
            <xsl:when test="$matching-glossary">
                <xsl:choose>
                    <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <a>
                            
                            <xsl:call-template name="href-attribute">
                                <xsl:with-param name="fragment-id" select="$matching-glossary/@xml:id"/>
                            </xsl:call-template>
                            
                            <xsl:attribute name="data-glossary-id" select="$matching-glossary/@xml:id"/>
                            <xsl:attribute name="data-match-mode" select="'marked'"/>
                            
                            <xsl:variable name="location-id">
                                <xsl:call-template name="persistent-location">
                                    <xsl:with-param name="node" select="$element"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <!-- target to be marked -->
                            <xsl:attribute name="data-mark-id" select="$matching-glossary/@xml:id"/>
                            
                            <xsl:call-template name="class-attribute">
                                
                                <xsl:with-param name="base-classes" as="xs:string*">
                                    
                                    <xsl:value-of select="'glossary-link'"/>
                                    
                                    <!-- Check if the location is cached and flag it if not -->
                                    <xsl:if test="$view-mode[@glossary = ('no-cache')]">
                                        <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $matching-glossary/@xml:id, $root)[1]" as="element(m:gloss)*"/>
                                        <xsl:if test="not($glossary-cache-gloss/m:location[@id/string() eq $location-id])">
                                            <xsl:value-of select="'not-cached'"/>
                                        </xsl:if>
                                    </xsl:if>
                                    
                                </xsl:with-param>
                                
                                <xsl:with-param name="html-classes" select="'pop-up'"/>
                                
                            </xsl:call-template>
                            
                            <xsl:apply-templates select="$element/node()"/>
                            
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:attribute name="data-glossary-id" select="$matching-glossary/@xml:id"/>
                            <xsl:apply-templates select="$element/node()"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <!-- Otherwise output the text -->
            <xsl:otherwise>
                <xsl:apply-templates select="$element/node()"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Glossarize a text node -->
    <xsl:template name="glossarize-text">
        
        <xsl:param name="text-node" as="text()"/>
        <xsl:param name="text-normalized" as="text()"/>
        
        <!--<xsl:variable name="text-word-count" select="count(tokenize($text-normalized, '\s+'))"/>-->
        
        <!-- Get a location reference -->
        <xsl:variable name="location-id">
            <xsl:call-template name="persistent-location">
                <xsl:with-param name="node" select="$text-node"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- Match whole string or just find -->
        <xsl:variable name="match-complete-data" select="if($text-node[parent::tei:title | parent::tei:name]) then true() else false()" as="xs:boolean"/>
        
        <!-- Exclude itself if this is a glossary definition -->
        <xsl:variable name="exclude-gloss-ids" select="if($text-node[ancestor::tei:gloss]) then $text-node/ancestor::tei:gloss[1]/@xml:id else if($text-node[ancestor::m:entry[parent::m:glossary]]) then $text-node/ancestor::m:entry[1]/@id else ()" as="xs:string*"/>
        
        <!-- Narrow down the glossary items - we don't want to scan them all -->
        <xsl:variable name="match-glossary-items" as="element(tei:gloss)*">
            <xsl:choose>
                
                <!-- Preferably use the cache -->
                <xsl:when test="$view-mode[@glossary eq 'use-cache']">
                    <xsl:variable name="cached-location-gloss-ids" select="key('glossary-cache-location', $location-id, $root)/parent::m:gloss/@id" as="xs:string*"/>
                    <xsl:sequence select="$glossary-prioritised[@xml:id = $cached-location-gloss-ids][not(@xml:id = $exclude-gloss-ids)][not(@mode eq 'marked')]"/>
                </xsl:when>
                
                <!-- Which items should we scan for? -->
                <xsl:otherwise>
                    <xsl:for-each select="$glossary-prioritised[not(@xml:id = $exclude-gloss-ids)][not(@mode eq 'marked')]">
                        
                        <xsl:variable name="terms" select="m:glossary-terms-to-match(.)"/>
                        
                        <!-- Do an initial check to avoid too much recursion -->
                        <xsl:variable name="match-glossary-item-terms-regex" as="xs:string">
                            <xsl:choose>
                                
                                <!-- Look for exact matches -->
                                <xsl:when test="$match-complete-data">
                                    <xsl:value-of select="common:matches-regex-exact($terms)"/>
                                </xsl:when>
                                
                                <!-- Look for any matches -->
                                <xsl:otherwise>
                                    <xsl:value-of select="common:matches-regex($terms)"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                        </xsl:variable>
                        
                        <!-- If it matches then include it in the scan -->
                        <xsl:if test="matches($text-normalized, $match-glossary-item-terms-regex, 'i')">
                            <xsl:sequence select="."/>
                        </xsl:if>
                        
                    </xsl:for-each>
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- Match the whole string -->
            <xsl:when test="$match-complete-data">
                
                <!-- Find the first glossary that matches the string -->
                <xsl:variable name="matching-glossary" as="element(tei:gloss)?">
                    <xsl:copy-of select="$match-glossary-items[matches($text-normalized, common:matches-regex-exact(m:glossary-terms-to-match(.)), 'i')][1]"/>
                </xsl:variable>
                
                <xsl:choose>
                    
                    <!-- If there's a match output the match -->
                    <xsl:when test="$matching-glossary">
                        <xsl:call-template name="glossary-mark-text">
                            <xsl:with-param name="glossary-id" select="$matching-glossary/@xml:id"/>
                            <xsl:with-param name="location-id" select="$location-id"/>
                            <!--<xsl:with-param name="match-mode" select="'matched'"/>-->
                            <xsl:with-param name="text" select="$text-normalized"/>
                        </xsl:call-template>
                    </xsl:when>
                    
                    <!-- Otherwise output the text -->
                    <xsl:otherwise>
                        <xsl:value-of select="$text-normalized"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <!-- Recursively scan for matches -->
            <xsl:when test="$match-glossary-items">
                <xsl:call-template name="glossary-scan-text">
                    <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
                    <xsl:with-param name="match-glossary-index" select="1"/>
                    <xsl:with-param name="location-id" select="$location-id"/>
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
    <xsl:template name="glossary-scan-text">
        
        <xsl:param name="match-glossary-items" as="element(tei:gloss)*"/>
        <xsl:param name="match-glossary-index" as="xs:integer"/>
        <xsl:param name="location-id" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        
        <!-- We are recursing through the terms  -->
        <xsl:choose>
            
            <xsl:when test="$text[normalize-space()] and $match-glossary-index le count($match-glossary-items)">
                
                <xsl:variable name="match-glossary-item" select="$match-glossary-items[$match-glossary-index]"/>
                <xsl:variable name="match-glossary-item-terms-regex" select="common:matches-regex(m:glossary-terms-to-match($match-glossary-item))"/>
                
                <xsl:analyze-string regex="{ $match-glossary-item-terms-regex }" select="$text" flags="i">
                    
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:call-template name="glossary-mark-text">
                            <xsl:with-param name="glossary-id" select="$match-glossary-item/@xml:id"/>
                            <xsl:with-param name="location-id" select="$location-id"/>
                            <xsl:with-param name="text" as="text()">
                                <xsl:value-of select="concat(regex-group(2), regex-group(3), '')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:value-of select="regex-group(4)"/>
                    </xsl:matching-substring>
                    
                    <xsl:non-matching-substring>
                        <xsl:call-template name="glossary-scan-text">
                            <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
                            <xsl:with-param name="match-glossary-index" select="$match-glossary-index + 1"/>
                            <xsl:with-param name="location-id" select="$location-id"/>
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

    <!-- Mark the matched text -->
    <xsl:template name="glossary-mark-text">
        
        <xsl:param name="glossary-id" as="xs:string"/>
        <xsl:param name="location-id" as="xs:string"/>
        <xsl:param name="text" as="text()*"/>
        
        <xsl:choose>
            
            <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))]">
                <a>
                    
                    <xsl:call-template name="href-attribute">
                        <xsl:with-param name="fragment-id" select="$glossary-id"/>
                    </xsl:call-template>
                    
                    <xsl:attribute name="data-glossary-id" select="$glossary-id"/>
                    <xsl:attribute name="data-match-mode" select="'matched'"/>
                    <!--<xsl:attribute name="data-glossary-location-id" select="$location-id"/>-->
                    
                    <!-- target to be marked -->
                    <xsl:attribute name="data-mark-id" select="$glossary-id"/>
                    
                    <xsl:call-template name="class-attribute">
                        
                        <xsl:with-param name="base-classes" as="xs:string*">
                            
                            <xsl:value-of select="'glossary-link'"/>
                            
                            <!-- Check if the location is cached and flag it if not -->
                            <xsl:if test="$view-mode[@glossary = ('no-cache')]">
                                <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $glossary-id, $root)[1]" as="element(m:gloss)*"/>
                                <xsl:if test="not($glossary-cache-gloss/m:location[@id/string() eq $location-id])">
                                    <xsl:value-of select="'not-cached'"/>
                                </xsl:if>
                            </xsl:if>
                            
                        </xsl:with-param>
                        
                        <xsl:with-param name="html-classes" select="'pop-up'"/>
                        
                    </xsl:call-template>
                    
                    <xsl:value-of select="$text"/>
                </a>
            </xsl:when>
            
            <xsl:otherwise>
                <span>
                    <xsl:attribute name="data-glossary-id" select="$glossary-id"/>
                    <xsl:value-of select="$text"/>
                </span>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Check the context of the node is somewhere to glossarize -->
    <xsl:function name="m:glossarize-node" as="xs:boolean">
        
        <xsl:param name="node" as="node()"/>
        <xsl:param name="text-normalized" as="text()"/>
        
        <xsl:choose>
            
            <!-- Check view-mode -->
            <xsl:when test="$view-mode[@glossary eq 'suppress']">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- Check for content flags -->
            <xsl:when test="$node[ancestor-or-self::tei:term[@type eq 'ignore']]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- Check for content flags -->
            <xsl:when test="$node[ancestor-or-self::*[@rend eq 'ignoreGlossary']]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- Check for content flags -->
            <xsl:when test="$node[ancestor-or-self::*[@glossarize eq 'suppress']]">
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
            <xsl:when test="$node/ancestor-or-self::tei:ptr | $node/ancestor-or-self::tei:ref[@target] | $node/ancestor-or-self::tei:lb | $node/ancestor-or-self::tei:milestone | $node/ancestor-or-self::tei:head | $node/ancestor-or-self::tei:term[parent::tei:gloss][not(@type eq 'definition')]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- EFT elements we don't want to process -->
            <xsl:when test="$node/ancestor-or-self::m:honoration | $node/ancestor-or-self::m:main-title  | $node/ancestor-or-self::m:sub-title | $node/ancestor-or-self::m:title-supp | $node/ancestor-or-self::m:title-text | $node/ancestor-or-self::m:match">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- Check if deferred -->
            <xsl:when test="$view-mode[@glossary eq 'defer'] and ($node/ancestor::tei:*[@tid] or $node/ancestor::tei:note[@place eq 'end'][@xml:id] or $node/ancestor::tei:gloss[@xml:id] or $node/ancestor::tei:orig)">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- Check for positive flag -->
            <xsl:when test="$node[ancestor-or-self::*[@glossarize eq 'mark']]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:function>
    
    <!-- Get relevant terms from gloss -->
    <xsl:function name="m:glossary-terms-to-match" as="xs:string*">
        <xsl:param name="glossary-items" as="element(tei:gloss)*"/>
        <xsl:sequence select="$glossary-items/tei:term[not(@type eq 'definition')][not(@xml:lang) or @xml:lang eq 'en'][normalize-space(data())]/data()"/>
    </xsl:function>
    
    <!-- Check the context of the node is somewhere that can be quoted -->
    <xsl:function name="m:quotable-node" as="xs:boolean">
        
        <xsl:param name="node" as="node()"/>
        <xsl:param name="text-normalized" as="text()"/>
        
        <xsl:choose>
            
            <!-- Check the content -->
            <xsl:when test="not(normalize-space($text-normalized))">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- Check the content -->
            <xsl:when test="not(matches($text-normalized,'[a-zA-Z0-9]'))">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- TEI elements we don't want to process -->
            <xsl:when test="$node/ancestor-or-self::tei:ptr | $node/ancestor-or-self::tei:ref[@target] | $node/ancestor-or-self::tei:lb | $node/ancestor-or-self::tei:milestone">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <!-- EFT elements we don't want to process -->
            <xsl:when test="$node/ancestor-or-self::m:honoration | $node/ancestor-or-self::m:main-title  | $node/ancestor-or-self::m:sub-title | $node/ancestor-or-self::m:title-supp | $node/ancestor-or-self::m:title-text">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <xsl:when test="$node/ancestor::m:part[@content-status eq 'complete'][parent::m:part[@type eq 'translation']]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:function>
    
    <!-- Highlight a text node -->
    <xsl:template name="mark-quotes">
        
        <!-- Return quotes marked, or an empty sequence if no match found -->
        
        <xsl:param name="text-node" as="text()"/>
        
        <xsl:if test="$requested-commentary gt ''">
            
            <!-- Get the location of the text -->
            <xsl:variable name="location-id">
                <xsl:call-template name="persistent-location">
                    <xsl:with-param name="node" select="$text-node"/>
                </xsl:call-template>
            </xsl:variable>
            
            <!-- Quoted at this location -->
            <xsl:variable name="quotes-location" select="key('quotes-inbound', $location-id, $root)[@resource-id eq $requested-commentary]" as="element(m:quote)*"/>
            
            <xsl:if test="$quotes-location">
                
                <xsl:variable name="quotes-location-highlights-sorted" as="element(m:highlight)*">
                    <xsl:perform-sort select="$quotes-location/m:highlight[@string-length]">
                        <xsl:sort select="xs:integer(@string-length)" order="descending"/>
                    </xsl:perform-sort>
                </xsl:variable>
                
                <xsl:variable name="text-context" select="$text-node/ancestor-or-self::*[preceding-sibling::tei:milestone][1]//text()[not(ancestor::tei:note)][not(ancestor::tei:orig)]" as="text()*"/>
                <xsl:variable name="text-index" select="common:index-of-node($text-context, $text-node)" as="xs:integer?"/>
                
                <xsl:call-template name="mark-quote">
                    <xsl:with-param name="highlights" select="$quotes-location-highlights-sorted"/>
                    <xsl:with-param name="highlight-index" select="1"/>
                    <xsl:with-param name="text-context" select="$text-context"/>
                    <xsl:with-param name="text-index" select="$text-index"/>
                    <xsl:with-param name="text" select="$text-node ! replace(., '\s+', ' ')"/>
                </xsl:call-template>
                
            </xsl:if>
            
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="mark-quote">
        
        <xsl:param name="highlights" as="element(m:highlight)*" required="true"/>
        <xsl:param name="highlight-index" as="xs:integer"/>
        <xsl:param name="text-context" as="text()*"/>
        <xsl:param name="text-index" as="xs:integer?"/>
        <xsl:param name="text" as="xs:string?"/>
        
        <xsl:variable name="highlight" select="$highlights[$highlight-index]" as="element(m:highlight)?"/>
        
        <xsl:choose>
            
            <xsl:when test="$highlight and $highlight/@string-length ! xs:integer(.) le string-length($text)">
                
                <!-- The regex to mark this string -->
                <xsl:variable name="mark-regex" select="$highlight/@target ! concat('(^|[^\p{L}]+)(', ., ')([^\p{L}]+|$)')" as="xs:string?"/>
                
                <!-- Get matches in text -->
                <xsl:variable name="text-analyzed" select="$mark-regex ! analyze-string(replace($text, '\s+', ' '), ., 'i')" as="element(fn:analyze-string-result)?"/>
                <xsl:variable name="text-matches-count" select="count($text-analyzed/fn:match)" as="xs:integer"/>
                
                <xsl:choose>
                    
                    <!-- There are matches in this text -->
                    <!-- Skip if there are too many -->
                    <xsl:when test="$text-matches-count gt 0 and $text-matches-count le 5">
                        
                        <!-- More detail about the quote -->
                        <xsl:variable name="quote" select="$highlight/parent::m:quote" as="element(m:quote)"/>
                        
                        <!-- Validate all matches in the context -->
                        <!-- Get matches in context -->
                        <xsl:variable name="context" select="string-join($text-context ! replace(., '\s+', ' '), '')" as="xs:string?"/>
                        <xsl:variable name="context-analyzed" select="analyze-string($context, $mark-regex, 'i')" as="element(fn:analyze-string-result)?"/>
                        
                        <!--<span class="hidden" data-test-quote-id="{ $quote/@id }" data-test-quote-highlight="{ $highlight/@index }" data-mark-regex="{ $mark-regex }" data-context-matches="{count($context-analyzed/fn:match)}">
                            <xsl:sequence select="$context-analyzed"/>
                        </span>-->
                        
                        <!-- The specified occurrence of this string, or first -->
                        <xsl:variable name="context-occurrence-target" select="($highlight/@occurrence, 1)[1]" as="xs:integer?"/>
                        
                        <!-- Which is the correct one? -->
                        <xsl:variable name="context-occurrences-validated" as="xs:integer*">
                            
                            <xsl:choose>
                                
                                <!-- There are other matches in the context to be ruled out -->
                                <xsl:when test="$highlight[@regex-preceding] or $highlight[@regex-following] or (count($context-analyzed/fn:match) gt 1 and $context-occurrence-target gt 1)">
                                    
                                    <xsl:variable name="quote-highlights-index" select="$highlight/@index" as="xs:integer?"/>
                                    
                                    <xsl:for-each select="$context-analyzed/*">
                                        
                                        <xsl:variable name="context-analyzed-index" select="position()" as="xs:integer"/>
                                        
                                        <xsl:if test="self::fn:match">
                                            
                                            <!-- Test that this text is preceded by the preceding highlight(s) -->
                                            <xsl:variable name="matches-preceding" as="xs:boolean">
                                                
                                                <xsl:choose>
                                                    
                                                    <!-- Nothing preceding to match -->
                                                    <xsl:when test="not($highlight/@regex-preceding)">
                                                        <xsl:value-of select="true()"/>
                                                    </xsl:when>
                                                    
                                                    <!-- Check for matches -->
                                                    <xsl:when test="$highlight/@regex-preceding and $context-analyzed-index gt 1">
                                                        
                                                        <!-- Concatenate preceding nodes in context -->
                                                        <xsl:variable name="preceding-context" select="string-join(($context-analyzed/*[position() lt $context-analyzed-index]) ! replace(., '\s+', ' '), '')" as="xs:string?"/>
                                                        
                                                        <xsl:value-of select="matches($preceding-context, $highlight/@regex-preceding, 'i')"/>
                                                        
                                                    </xsl:when>
                                                    
                                                    <!-- Highlights to match but no preceding text to check -->
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="false()"/>
                                                    </xsl:otherwise>
                                                    
                                                </xsl:choose>
                                                
                                            </xsl:variable>
                                            
                                            <!-- Test following text that the following highlight matches -->
                                            <xsl:variable name="matches-following" as="xs:boolean">
                                                
                                                <xsl:choose>
                                                    
                                                    <!-- Already failed so don't bother -->
                                                    <xsl:when test="$matches-preceding eq false()">
                                                        <xsl:value-of select="false()"/>
                                                    </xsl:when>
                                                    
                                                    <!-- Nothing more to match -->
                                                    <xsl:when test="not($highlight/@regex-following)">
                                                        <xsl:value-of select="true()"/>
                                                    </xsl:when>
                                                    
                                                    <!-- Check for matches -->
                                                    <xsl:when test="$highlight/@regex-following and $context-analyzed-index lt count($context-analyzed/*)">
                                                        
                                                        <!-- Concatenate following nodes in context -->
                                                        <xsl:variable name="following-context" select="string-join($context-analyzed/*[position() gt $context-analyzed-index] ! replace(., '\s+', ' '), '')" as="xs:string?"/>
                                                        
                                                        <xsl:value-of select="matches($following-context, $highlight/@regex-following, 'i')"/>
                                                        
                                                    </xsl:when>
                                                    
                                                    <!-- Highlights to match but no following text to check -->
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="false()"/>
                                                    </xsl:otherwise>
                                                    
                                                </xsl:choose>
                                                
                                            </xsl:variable>
                                            
                                            <!-- Remember the indexes of valid matches -->
                                            <xsl:if test="$matches-preceding and $matches-following">
                                                <xsl:value-of select="common:index-of-node($context-analyzed/fn:match, .)"/>
                                            </xsl:if>
                                            
                                        </xsl:if>
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                                
                                <!-- This is the only option in this context -->
                                <xsl:otherwise>
                                    <xsl:value-of select="1"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </xsl:variable>
                        
                        <!--<span class="hidden" data-test-quote-id="{ $quote/@id }" data-test-quote-highlight="{ $highlight/@index }" data-regex-preceding="{ $highlight/@regex-preceding }" data-context-occurrences-validated="{string-join($context-occurrences-validated, ',')}">
                            
                            <!-\- Concatenate preceding nodes in context -\->
                            <xsl:if test="$highlight/@regex-preceding">
                                <xsl:sequence select="analyze-string(string-join(($context-analyzed/*[position() lt 2]) ! replace(., '\s+', ' '), ''), $highlight/@regex-preceding, 'i')"/>
                            </xsl:if>
                            
                        </span>-->
                        
                        <xsl:choose>
                            
                            <xsl:when test="count($context-occurrences-validated) gt 0">
                                
                                <!-- Get the number of matches in the preceding context -->
                                <xsl:variable name="preceding-context" select="string-join(($text-context[position() lt $text-index]) ! replace(., '\s+', ' '), '')" as="xs:string?"/>
                                <xsl:variable name="preceding-analyzed" select="analyze-string($preceding-context, $mark-regex, 'i')" as="element(fn:analyze-string-result)?"/>
                                <xsl:variable name="preceding-context-occurrences-count" select="count($preceding-analyzed/fn:match)" as="xs:integer"/>
                                
                                <xsl:for-each select="$text-analyzed/*">
                                    
                                    <xsl:variable name="text-analyzed-node" select="."/>
                                    <xsl:variable name="text-analyzed-index" select="position()" as="xs:integer"/>
                                    
                                    <!--<span class="hidden" data-test-quote-id="{ $quote/@id }" data-quote-highlight="{ $highlight/@index }">
                                        <xsl:sequence select="$context-analyzed"/>
                                    </span>-->
                                    
                                    <xsl:choose>
                                        
                                        <xsl:when test="self::fn:match">
                                            
                                            <xsl:variable name="text-analyzed-match-index" select="common:index-of-node($text-analyzed/fn:match, $text-analyzed-node)" as="xs:integer"/>
                                            <xsl:variable name="context-occurrence-index" select="($text-analyzed-match-index + $preceding-context-occurrences-count)" as="xs:integer"/>
                                            
                                            <xsl:variable name="text-match-text" select="$text-analyzed-node/fn:group[@nr eq '2']/text()" as="text()"/>
                                            <xsl:variable name="text-match-index" select="common:index-of-node($text-analyzed//text(), $text-match-text)" as="xs:integer"/>
                                            
                                            <xsl:variable name="text-match-recurse">
                                                <xsl:call-template name="mark-quote">
                                                    <xsl:with-param name="highlights" select="$highlights"/>
                                                    <xsl:with-param name="highlight-index" select="$highlight-index + 1"/>
                                                    <xsl:with-param name="text-context" select="($text-context[position() lt $text-index], $text-analyzed//text(), $text-context[position() gt $text-index])"/>
                                                    <xsl:with-param name="text-index" select="($text-index - 1) + $text-match-index"/>
                                                    <xsl:with-param name="text" select="$text-match-text"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            
                                            <xsl:value-of select="$text-analyzed-node/fn:group[@nr eq '1']"/>
                                            <xsl:choose>
                                                <xsl:when test="$context-occurrence-index gt 0 and $context-occurrence-index = $context-occurrences-validated and (count($context-occurrences-validated) eq 1 or $context-occurrence-index eq $context-occurrence-target)">
                                                    <span data-quote-id="{ $quote/@id }" data-quote-highlight="{ $highlight/@index }" class="quoted matched">
                                                        <xsl:sequence select="$text-match-recurse"/>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:sequence select="$text-match-recurse"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:value-of select="$text-analyzed-node/fn:group[@nr eq '3']"/>
                                            
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            
                                            <xsl:variable name="text-matched" select="$text-analyzed-node/text()"/>
                                            <xsl:variable name="text-matched-index" select="common:index-of-node($text-analyzed//text(), $text-matched)"/>
                                            
                                            <xsl:call-template name="mark-quote">
                                                <xsl:with-param name="highlights" select="$highlights"/>
                                                <xsl:with-param name="highlight-index" select="$highlight-index + 1"/>
                                                <xsl:with-param name="text-context" select="($text-context[position() lt $text-index], $text-analyzed//text(), $text-context[position() gt $text-index])"/>
                                                <xsl:with-param name="text-index" select="($text-index - 1) + $text-matched-index"/>
                                                <xsl:with-param name="text" select="$text-matched"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                    
                                </xsl:for-each>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <xsl:call-template name="mark-quote">
                                    <xsl:with-param name="highlights" select="$highlights"/>
                                    <xsl:with-param name="highlight-index" select="$highlight-index + 1"/>
                                    <xsl:with-param name="text-context" select="$text-context"/>
                                    <xsl:with-param name="text-index" select="$text-index"/>
                                    <xsl:with-param name="text" select="$text"/>
                                </xsl:call-template>   
                            </xsl:otherwise>
                            
                        </xsl:choose>
                        
                    </xsl:when>
                    
                    <!-- Otherwise move on to the next highlight -->
                    <xsl:otherwise>
                        <xsl:call-template name="mark-quote">
                            <xsl:with-param name="highlights" select="$highlights"/>
                            <xsl:with-param name="highlight-index" select="$highlight-index + 1"/>
                            <xsl:with-param name="text-context" select="$text-context"/>
                            <xsl:with-param name="text-index" select="$text-index"/>
                            <xsl:with-param name="text" select="$text"/>
                        </xsl:call-template>    
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <xsl:when test="$highlight-index le count($highlights)">
                <xsl:call-template name="mark-quote">
                    <xsl:with-param name="highlights" select="$highlights"/>
                    <xsl:with-param name="highlight-index" select="$highlight-index + 1"/>
                    <xsl:with-param name="text-context" select="$text-context"/>
                    <xsl:with-param name="text-index" select="$text-index"/>
                    <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>  
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="replace($text, '\s+', ' ')"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Tantra warning -->
    <xsl:template name="tantra-warning">
        
        <xsl:param name="id"/>
        <xsl:param name="node"/>
        <xsl:param name="modal-only" as="xs:boolean" select="false()"/>
        <xsl:param name="restricted-text-id" as="xs:string?"/>
        
        <div class="hidden-print">
            
            <xsl:if test="not($modal-only)">
                <a data-toggle="modal" class="block-link warning">
                    <xsl:attribute name="href" select="concat('#tantra-warning-', $id)"/>
                    <xsl:attribute name="data-target" select="concat('#tantra-warning-', $id)"/>
                    <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                    <xsl:value-of select="' Tantra Text Warning'"/>
                </a>
            </xsl:if>
            
            <div class="modal fade warning" tabindex="-1" role="dialog">
                
                <xsl:attribute name="id" select="concat('tantra-warning-', $id)"/>
                <xsl:attribute name="aria-labelledby" select="concat('tantra-warning-label-', $id)"/>
                
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">
                                    <i class="fa fa-times"/>
                                </span>
                            </button>
                            <h4 class="modal-title">
                                <xsl:attribute name="id" select="concat('tantra-warning-label-', $id)"/>
                                <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                <xsl:value-of select="' Tantra Text Warning'"/>
                            </h4>
                        </div>
                        
                        <div class="modal-body">
                            <xsl:apply-templates select="$node"/>
                        </div>
                        
                        <xsl:if test="$restricted-text-id">
                            <div class="modal-footer">
                                <div class="text-center">
                                    <button type="button" class="btn btn-danger btn-sm" data-inhibit-restriction="{ $restricted-text-id }">
                                        <xsl:value-of select="'Don''t show this warning again for this text'"/>
                                    </button>
                                </div>
                            </div>
                        </xsl:if>
                        
                    </div>
                </div>
                
            </div>
            
        </div>
        
        <xsl:if test="not($modal-only)">
            <div class="visible-print-block small">
                <xsl:apply-templates select="$node"/>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Expandable summary of text (summary, variant titles, supplementary roles) -->
    <xsl:template name="expandable-summary">
        
        <xsl:param name="text"/>
        <xsl:param name="expand-id" as="xs:string"/>
        <xsl:param name="prepend-hr" as="xs:boolean" select="true()"/>
        
        <xsl:variable name="toh-key" select="$toh-key"/>
        
        <xsl:variable name="supplementaryRoles" select="('translator', 'reviser')"/>
        <xsl:variable name="summary" select="$text/m:part[@type eq 'summary']/tei:p"/>
        <xsl:variable name="titleVariants" select="$text/m:title-variants/m:title[normalize-space(string-join(text(), ' '))] | $text/m:title-variants/m:note[@type eq 'title'][normalize-space(string-join(text(), ''))]"/>
        <xsl:variable name="supplementaryAttributions" select="$text/m:source/m:attribution[@ref][@role = $supplementaryRoles]"/>
        
        <xsl:if test="$summary or $titleVariants or $supplementaryAttributions">
            
            <xsl:if test="$prepend-hr">
                <hr class="hidden-print"/>
            </xsl:if>
            
            <a class="summary-link collapsed hidden-print small" role="button" data-toggle="collapse" aria-expanded="false">
                <xsl:attribute name="href" select="concat('#', $expand-id)"/>
                <xsl:attribute name="aria-controls" select="concat('#', $expand-id)"/>
                <i class="fa fa-chevron-down"/>
                <xsl:value-of select="' '"/>
                <xsl:value-of select="'Summary and further information'"/>
            </a>
            
            <xsl:variable name="summary-content">
                
                <div class="well well-sm small">
                    
                    <h4 class="no-top-margin">
                        <xsl:value-of select="'Summary'"/>
                    </h4>
                    <div class="summary">
                        <xsl:choose>
                            <xsl:when test="$summary">
                                <xsl:apply-templates select="$summary"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <p class="italic text-muted">
                                    <xsl:value-of select="'No summary is currently available.'"/>
                                </p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    
                    <xsl:if test="$titleVariants">
                        <div>
                            <xsl:attribute name="id" select="concat($toh-key, '-title-variants')"/>
                            <h4>
                                <xsl:value-of select="'Title variants'"/>
                            </h4>
                            <ul>
                                <xsl:for-each select="$titleVariants">
                                    <li>
                                        <span>
                                            <xsl:attribute name="class" select="common:lang-class(@xml:lang)"/>
                                            <xsl:value-of select="normalize-space(text())"/> 
                                        </span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="$supplementaryAttributions">
                        <div>
                            <xsl:attribute name="id" select="concat($toh-key, '-supplementary-roles')"/>
                            <xsl:for-each select="$supplementaryRoles">
                                <xsl:variable name="supplementaryRole" select="."/>
                                <xsl:variable name="roleAttributions" select="$supplementaryAttributions[@role eq $supplementaryRole]"/>
                                <xsl:if test="$roleAttributions">
                                    <h4>
                                        <xsl:choose>
                                            <xsl:when test="$supplementaryRole eq 'reviser'">
                                                <xsl:value-of select="'Revision:'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'Tibetan translation:'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </h4>
                                    <ul>
                                        <xsl:for-each select="$roleAttributions">
                                            <xsl:variable name="entity-id" select="replace(@ref, '^eft:', '')"/>
                                            <xsl:variable name="entity" select="$entities/id($entity-id)"/>
                                            <li>
                                                <xsl:call-template name="attribution-label">
                                                    <xsl:with-param name="attribution" select="."/>
                                                    <xsl:with-param name="entity" select="$entity"/>
                                                    <xsl:with-param name="page" select="key('related-pages', $entity/m:instance/@id, $root)[1]"/>
                                                </xsl:call-template>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    
                </div>
                
            </xsl:variable>
            
            <div>
                
                <xsl:attribute name="id" select="$expand-id"/>
                
                <xsl:attribute name="class" select="'collapse summary-detail print-collapse-override'"/>
                
                <xsl:sequence select="$summary-content"/>
                
            </div>
            
        </xsl:if>
        
    </xsl:template>
    
    <!-- Authors -->
    <xsl:template name="source-authors">
        
        <xsl:param name="text" as="element(m:text)?"/>
        
        <xsl:if test="$text/m:source/m:attribution[@ref][@role eq 'author'][normalize-space(text())]">
            <hr/>
            <div role="navigation" aria-label="The attributed authors of the source text" class="small">
                <span class="text-muted">
                    <xsl:value-of select="'by '"/>
                </span>
                <ul class="list-inline inline-dots">
                    <xsl:for-each select="$text/m:source/m:attribution[@ref][@role eq 'author'][normalize-space(text())]">
                        <xsl:variable name="entity-id" select="replace(@ref, '^eft:', '')"/>
                        <xsl:variable name="entity" select="$entities/id($entity-id)"/>
                        <li>
                            <xsl:call-template name="attribution-label">
                                <xsl:with-param name="attribution" select="."/>
                                <xsl:with-param name="entity" select="$entity"/>
                                <xsl:with-param name="page" select="key('related-pages', $entity/m:instance/@id, $root)[1]"/>
                            </xsl:call-template>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="attribution-label">
        
        <xsl:param name="attribution" as="element(m:attribution)?"/>
        <xsl:param name="entity" as="element(m:entity)?"/>
        <xsl:param name="page" as="element(m:page)?"/>
        
        <xsl:choose>
            <xsl:when test="$page">
                <a>
                    <xsl:attribute name="href" select="common:internal-link(concat('/knowledgebase/', $page/@kb-id, '.html'), (), '', /m:response/@lang)"/>
                    <span>
                        <xsl:attribute name="class" select="common:lang-class($attribution/@xml:lang)"/>
                        <xsl:value-of select="normalize-space($attribution/text())"/> 
                    </span>
                </a>
            </xsl:when>
            <xsl:when test="$entity">
                <span>
                    <xsl:attribute name="class" select="common:lang-class($attribution/@xml:lang)"/>
                    <xsl:value-of select="normalize-space($attribution/text())"/> 
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:attribute name="class" select="common:lang-class($attribution/@xml:lang)"/>
                    <xsl:value-of select="normalize-space($attribution/text())"/> 
                </span>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Entities derived metadata -->
    <xsl:template name="entity-data">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:if test="$entity">
            
            <xsl:variable name="related-entries" select="key('related-entries', $entity/m:instance/@id, $root)" as="element(m:entry)*"/>
            
            <xsl:if test="$related-entries">
                
                <xsl:element name="entity-data" namespace="http://read.84000.co/ns/1.0">
                    
                    <xsl:attribute name="ref" select="$entity/@xml:id"/>
                    
                    <xsl:attribute name="related-entries" select="count($related-entries)"/>
                    
                    <xsl:variable name="term-empty-bo">
                        <xsl:call-template name="text">
                            <xsl:with-param name="global-key" select="'glossary.term-empty-bo'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:variable name="term-empty-sa-ltn">
                        <xsl:call-template name="text">
                            <xsl:with-param name="global-key" select="'glossary.term-empty-sa-ltn'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:variable name="terms-bo" select="$related-entries/m:term[@xml:lang eq 'bo'][text()][not(text() ! normalize-space(.) = ('', $term-empty-bo))]"/>
                    <xsl:variable name="terms-sa" select="$related-entries/m:term[@xml:lang eq 'Sa-Ltn'][text()][not(text() ! normalize-space(.) = ('', $term-empty-sa-ltn))]"/>
                    <xsl:variable name="terms-wy" select="$related-entries/m:term[@xml:lang eq 'Bo-Ltn'][text()]"/>
                    <xsl:variable name="terms-en" select="$related-entries/m:term[@xml:lang eq 'en'][text()]"/>
                    
                    <xsl:variable name="primary-terms" as="element(m:term)*">
                        <xsl:choose>
                            <xsl:when test="$terms-bo">
                                <xsl:sequence select="$terms-bo"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$terms-sa"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="sorted-terms" as="element(m:term)*">
                        <xsl:perform-sort select="$primary-terms">
                            <!--<xsl:sort select="string-length(lower-case(data()))" order="descending"/>-->
                            <xsl:sort select="count($related-entries/m:term/data() ! lower-case(.) = data() ! lower-case(.))" order="descending"/>
                        </xsl:perform-sort>
                    </xsl:variable>
                    
                    <xsl:variable name="primary-term" select="if($sorted-terms) then $sorted-terms[1] else ($entity/m:label[@xml:lang eq 'en'], $entity/m:label[@xml:lang eq 'Sa-Ltn'], $entity/m:label[@xml:lang eq 'Bo-Ltn'])[1]"/>
                    <xsl:variable name="primary-term-entry" select="$primary-term/parent::m:entry"/>
                    
                    <xsl:element name="label" namespace="http://read.84000.co/ns/1.0">
                        <xsl:attribute name="type" select="'primary'"/>
                        <xsl:attribute name="xml:lang" select="$primary-term/@xml:lang"/>
                        <xsl:value-of select="$primary-term"/>
                    </xsl:element>
                    
                    <xsl:if test="$primary-term[@xml:lang eq 'bo']">
                        
                        <xsl:variable name="sorted-wylie-terms" as="element(m:term)*">
                            <xsl:perform-sort select="$primary-term-entry/m:term[@xml:lang eq 'Bo-Ltn']">
                                <xsl:sort select="string-length(lower-case(data()))" order="descending"/>
                            </xsl:perform-sort>
                        </xsl:variable>
                        
                        <xsl:variable name="wylie-term" select="$sorted-wylie-terms[1]"/>
                        
                        <xsl:if test="$wylie-term">
                            <xsl:element name="label" namespace="http://read.84000.co/ns/1.0">
                                <xsl:attribute name="type" select="'secondary'"/>
                                <xsl:attribute name="xml:lang" select="$wylie-term/@xml:lang"/>
                                <xsl:value-of select="$wylie-term"/>
                            </xsl:element>
                        </xsl:if>
                        
                        <xsl:variable name="sorted-sanskrit-terms" as="element(m:term)*">
                            <xsl:perform-sort select="$primary-term-entry/m:term[@xml:lang eq 'Sa-Ltn']">
                                <xsl:sort select="string-length(lower-case(data()))" order="descending"/>
                            </xsl:perform-sort>
                        </xsl:variable>
                        
                        <xsl:variable name="sanskrit-term" select="$sorted-sanskrit-terms[1]"/>
                        
                        <xsl:if test="$sanskrit-term">
                            <xsl:element name="label" namespace="http://read.84000.co/ns/1.0">
                                <xsl:attribute name="type" select="'secondary'"/>
                                <xsl:attribute name="xml:lang" select="$sanskrit-term/@xml:lang"/>
                                <xsl:value-of select="$sanskrit-term"/>
                            </xsl:element>
                        </xsl:if>
                        
                    </xsl:if>
                    
                    <xsl:for-each-group select="$terms-bo | $terms-sa | $terms-wy | $terms-en" group-by="string-join((@xml:lang, tokenize(data(), '\s+') ! lower-case(.) ! replace(., '­','')(: strip soft-hyphens :)), ' ')">
                        
                        <xsl:variable name="term-group" select="."/>
                        <xsl:variable name="normalized-string" select="string-join((tokenize($term-group[1]/text(), '\s+') ! lower-case(.) ! replace(., '­','')(: strip soft-hyphens :)), ' ')"/>
                        
                        <xsl:element name="term" namespace="http://read.84000.co/ns/1.0">
                            <xsl:variable name="term-entry-id" select="parent::m:entry/@id[1]"/>
                            <xsl:attribute name="xml:lang" select="@xml:lang"/>
                            <xsl:attribute name="normalized-string" select="$normalized-string"/>
                            <xsl:attribute name="word-count" select="count(tokenize($normalized-string, '\s+'))"/>
                            <xsl:attribute name="letter-count" select="string-length($normalized-string)"/>
                            <xsl:if test="$entity/m:instance[@id eq $term-entry-id][m:flag]">
                                <xsl:attribute name="flagged" select="true()"/>
                            </xsl:if>
                            <xsl:value-of select="$term-group[1]/text()"/>
                        </xsl:element>
                        
                    </xsl:for-each-group>
                    
                </xsl:element>
                
            </xsl:if>
            
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>