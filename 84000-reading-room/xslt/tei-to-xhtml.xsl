<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <!-- Transforms tei to xhtml -->
    
    <!-- Output as website page -->
    <xsl:import href="../views/html/website-page.xsl"/>
    
    <!-- Global variables -->
    <xsl:variable name="translation" select="/m:response/m:translation" as="element(m:translation)?"/>
    <xsl:variable name="section" select="/m:response/m:section" as="element(m:section)?"/>
    <xsl:variable name="knowledgebase" select="/m:response/m:knowledgebase" as="element(m:knowledgebase)?"/>
    <xsl:variable name="entities" select="/m:response/m:entities/m:entity" as="element(m:entity)*"/>
    <xsl:variable name="requested-part" select="/m:response/m:request/@part" as="xs:string?"/>
    <xsl:variable name="requested-passage" select="/m:response/m:request/m:passage/@id" as="xs:string?"/>
    <xsl:variable name="toh-key" select="$translation/m:toh/@key" as="xs:string?"/>
    <xsl:variable name="kb-id" select="$knowledgebase/m:page/@xml:id" as="xs:string?"/>
    <xsl:variable name="part-status" select="if(not($translation//m:part[@render = ('preview', 'empty')])) then 'complete' else if($translation//m:part[@render eq 'show']) then 'part' else 'empty'" as="xs:string"/>
    
    <!-- Useful keys -->
    <xsl:key name="text-parts" match="m:part[@id]" use="@id"/>
    <xsl:key name="glossary-cache-gloss" match="m:glossary-cache/m:gloss" use="@id"/>
    <xsl:key name="glossary-cache-index" match="m:glossary-cache/m:gloss" use="@index"/>
    <xsl:key name="glossary-cache-location" match="m:glossary-cache/m:gloss/m:location" use="@id"/>
    <xsl:key name="folios-cache-ref" match="m:folios-cache/m:folio-ref" use="@id"/>
    <xsl:key name="notes-cache-end-note" match="m:notes-cache/m:end-note" use="@id"/>
    <xsl:key name="milestones-cache-milestone" match="m:milestones-cache/m:milestone" use="@id"/>
    <xsl:key name="entity-instance" match="m:entities/m:entity/m:instance" use="@id"/>
    <xsl:key name="related-entries" match="m:entities/m:related/m:text/m:entry" use="@id"/>
    <xsl:key name="related-pages" match="m:entities/m:related/m:page" use="@xml:id"/>
    <xsl:key name="related-entities" match="m:entities/m:related/m:entity" use="@xml:id"/>
    
    <!-- Pre-sort the glossaries by priority -->
    <xsl:variable name="glossary-prioritised" as="element(tei:gloss)*">
        <xsl:perform-sort select="($translation | $knowledgebase)/m:part[@type eq 'glossary']//tei:gloss[@xml:id][tei:term[not(@xml:lang)][not(@type = ('definition','alternative'))][normalize-space(text())]]">
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
    <xsl:variable name="ref-1-validated" select="if(key('folios-cache-ref', $ref-1/@xml:id, $root)/@index-in-resource/string() = '1') then $ref-1 else ()"/>
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
                
                <!-- Check if deferred -->
                <xsl:when test="$view-mode[@glossary = ('defer', 'editor-defer')] and (ancestor::tei:*[@tid] or ancestor::tei:note[@place eq 'end'][@xml:id] or ancestor::tei:note[@place eq 'end'][@xml:id] or ancestor::tei:gloss[@xml:id])">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- TEI elements we don't want to process -->
                <xsl:when test="parent::tei:ptr | parent::tei:ref[@target] | parent::tei:lb | parent::tei:milestone | parent::tei:term[not(@type eq 'definition')] | ancestor::tei:head">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- EFT elements we don't want to process -->
                <xsl:when test="parent::m:honoration | parent::m:main-title  | parent::m:sub-title | parent::m:title-supp | parent::m:title-text | parent::m:match">
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
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'mantra'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
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
                <xsl:variable name="index" select="if($ref[@xml:id]) then key('folios-cache-ref', $ref/@xml:id, $root)[1]/@index-in-resource else ()"/>

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
                                    <xsl:attribute name="href" select="concat('/source/', $toh-key, '.html?ref-index=', $index, '#ajax-source')"/>
                                    <xsl:attribute name="data-ref" select="$ref/@cRef"/>
                                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-source .ajax-target'"/>
                                    <xsl:value-of select="concat('[', $ref/@cRef, ']')"/>
                                </a>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                
                                <span class="ref">
                                    <xsl:attribute name="data-href" select="concat('/source/', $toh-key, '.html?ref-index=', $index, '#ajax-source')"/>
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
                    <xsl:attribute name="href">
                        <xsl:value-of select="$ref/@target"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$ref[data()]">
                            <xsl:attribute name="title">
                                <xsl:value-of select="$ref/data() ! normalize-space(.)"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="$ref/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="title">
                                <xsl:value-of select="$ref/@target"/>
                            </xsl:attribute>
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
            <xsl:variable name="pointer-target" select="if($target-type eq 'id') then substring-after($pointer/@target, '#') else $pointer/@target"/>
            
            <!-- Look through the various keys to find this id -->
            <xsl:variable name="target" as="element()?">
                <xsl:if test="$target-type eq 'id'">
                    <xsl:call-template name="target-element">
                        <xsl:with-param name="target-id" select="$pointer-target"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:variable>
            
            <!-- Set a data value to flag these -->
            <xsl:attribute name="data-pointer-type" select="$target-type"/>
            
            <!-- Set the href and class -->
            <xsl:choose>
                
                <xsl:when test="$target">
                    
                    <xsl:call-template name="target-element-href">
                        <xsl:with-param name="target-element" select="$target"/>
                    </xsl:call-template>
                    
                    <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <xsl:attribute name="class" select="'pointer scroll-to-anchor'"/>
                    </xsl:if>
                    
                    <xsl:attribute name="target" select="'_self'"/>
                    
                </xsl:when>
                
                <xsl:when test="$target-type eq 'url'">
                    
                    <xsl:attribute name="href" select="$pointer-target"/>
                    <xsl:attribute name="target" select="'_blank'"/>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <!-- Don't add an href -->
                </xsl:otherwise>
                
            </xsl:choose>
            
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
    
    <xsl:template match="tei:p | tei:ab | tei:trailer | tei:bibl | tei:lg | tei:q">
        
        <!-- Output the ref prologue -->
        <xsl:if test="$ref-prologue-container and count(. | $ref-prologue-container) eq count(.)">
            <div class="rw rw-first rw-paragraph">
                <p class="ref-prologue">
                    <xsl:apply-templates select="$ref-prologue"/>
                </p>
            </div>
            <br/>
        </xsl:if>
        
        <xsl:call-template name="milestone">
            
            <xsl:with-param name="content">
                <xsl:element name="{ if(self::tei:lg) then 'div' else if(self::tei:q) then 'blockquote' else 'p' }" namespace="http://www.w3.org/1999/xhtml">
                    
                    <!-- id -->
                    <xsl:call-template name="tid">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <!-- class -->
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            
                            <xsl:if test="(@rend, @type) = 'mantra'">
                                <xsl:value-of select="'mantra'"/>
                            </xsl:if>
                            
                            <xsl:if test="@type = ('sdom', 'bar_sdom', 'spyi_sdom')">
                                <xsl:value-of select="'italic'"/>
                            </xsl:if>
                            
                            <xsl:choose>
                                <xsl:when test="self::tei:trailer">
                                    <xsl:value-of select="'trailer'"/>
                                </xsl:when>
                                <xsl:when test="self::tei:bibl">
                                    <xsl:value-of select="'bibl'"/>
                                </xsl:when>
                                <xsl:when test="self::tei:lg">
                                    <xsl:value-of select="'line-group'"/>
                                </xsl:when>
                            </xsl:choose>
                            
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <!-- Output the content, filtering out the ref prologue -->
                    <xsl:call-template name="filter-ref-prologue">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <!-- Add link to tei editor -->
                    <xsl:call-template name="tei-editor">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                </xsl:element>
            </xsl:with-param>
            
            <xsl:with-param name="row-type">
                <xsl:choose>
                    <xsl:when test="(@rend,@type) = 'mantra'">
                        <xsl:value-of select="'mantra'"/>
                    </xsl:when>
                    <xsl:when test="self::tei:trailer">
                        <xsl:value-of select="'trailer'"/>
                    </xsl:when>
                    <xsl:when test="self::tei:lg">
                        <xsl:value-of select="'line-group'"/>
                    </xsl:when>
                    <xsl:when test="self::tei:q">
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
        
        <xsl:variable name="matches-ref-prologue-parent" select="count(. | $ref-prologue-parent) eq count(.)" as="xs:boolean"/>
        
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" select="'line'"/>
                    </xsl:call-template>
                    
                    <!-- Output the content, filtering out the ref prologue -->
                    <xsl:call-template name="filter-ref-prologue">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'line'"/>
        </xsl:call-template>
        
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
                    <xsl:call-template name="tid">
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
            
            <xsl:call-template name="tid">
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
                    
                    <xsl:call-template name="tid">
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
                    
                    <xsl:call-template name="tid">
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
        <xsl:variable name="notes-cache-end-note" select="key('notes-cache-end-note', $note/@xml:id, $root)[1]"/>
        
        <a class="footnote-link">
            
            <xsl:choose>
                
                <xsl:when test="$note[@xml:id] and $notes-cache-end-note[@index]">
                    
                    <xsl:attribute name="id" select="$note/@xml:id"/>
                    
                    <xsl:call-template name="href-attribute">
                        <xsl:with-param name="target-id" select="concat('end-note-', $note/@xml:id)"/>
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
                    
                    <xsl:value-of select="$notes-cache-end-note/@index"/>
                    
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
        
        <xsl:for-each select="$end-notes">
            
            <xsl:sort select="key('notes-cache-end-note', @xml:id, $root)[1]/@index ! common:enforce-integer(.)"/>
            
            <xsl:variable name="end-note" select="."/>
            <xsl:variable name="notes-cache-end-note" select="key('notes-cache-end-note', @xml:id, $root)[1]"/>
            <xsl:variable name="part" select="key('text-parts', $notes-cache-end-note/@part-id, $root)[1]"/>
            
            <div class="rw footnote">
                
                <xsl:attribute name="id" select="concat('end-note-', $end-note/@xml:id)"/>
                
                <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                    <xsl:attribute name="data-passage-id" select="$end-note/@xml:id"/>
                </xsl:if>
                
                <xsl:if test="$view-mode[@glossary = ('defer', 'editor-defer')]">
                    <xsl:call-template name="in-view-replace-attribute">
                        <xsl:with-param name="part-id" select="$end-note/@xml:id"/>
                        <xsl:with-param name="target-id" select="concat('end-note-', $end-note/@xml:id)"/>
                    </xsl:call-template>
                </xsl:if>
                
                <div class="gtr">
                    
                    <xsl:choose>
                        
                        <!-- Internal links to hash locations -->
                        <xsl:when test="$view-mode[@client = ('browser', 'ajax', 'pdf', 'ebook', 'app')]">
                            
                            <a>
                                
                                <xsl:call-template name="href-attribute">
                                    <xsl:with-param name="target-id" select="$end-note/@xml:id"/>
                                    <xsl:with-param name="part-id" select="$part/@id"/>
                                    <xsl:with-param name="mark-id" select="$end-note/@xml:id"/>
                                </xsl:call-template>
                                
                                <xsl:if test="$view-mode[@client = ('browser', 'ajax', 'pdf')]">
                                    <!-- marks a target -->
                                    <xsl:attribute name="class" select="'footnote-number scroll-to-anchor'"/>
                                    <xsl:attribute name="title" select="concat('Go to note ', $notes-cache-end-note/@index, ' in the text')"/>
                                </xsl:if>
                                
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="$end-notes-part/@prefix"/>
                                    <xsl:with-param name="index" select="$notes-cache-end-note/@index"/>
                                </xsl:call-template>
                                
                            </a>
                            
                        </xsl:when>
                        
                        <!-- Just text -->
                        <xsl:otherwise>
                            <xsl:call-template name="bookmark-label">
                                <xsl:with-param name="prefix" select="$end-notes-part/@prefix"/>
                                <xsl:with-param name="index" select="$notes-cache-end-note/@index"/>
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
                    
                    <!-- Check if deferred -->
                    <xsl:when test="$view-mode[@glossary = ('defer', 'editor-defer')] and ancestor::tei:*[@tid]">
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
        
        <xsl:variable name="glossary-render" select="$glossary-part//tei:gloss[@xml:id][$view-mode[not(@parts eq 'passage')] or @xml:id eq $requested-passage]"/>
        
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
                    
                    <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <xsl:attribute name="data-passage-id" select="$glossary-item/@xml:id"/>
                    </xsl:if>
                    
                    <xsl:if test="$view-mode[@glossary = ('defer', 'editor-defer')]">
                        <xsl:call-template name="in-view-replace-attribute">
                            <xsl:with-param name="part-id" select="$glossary-item/@xml:id"/>
                            <xsl:with-param name="target-id" select="$glossary-item/@xml:id"/>
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
                    
                    <div>
                        
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
                                                        
                                                        <xsl:if test="$view-mode[@id = ('editor', 'annotation', 'editor-passage')] and @status eq 'verified'">
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
                        <xsl:if test="$view-mode[@id = ('editor', 'annotation', 'tests', 'editor-passage')] and $alternative-terms">
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
                        <xsl:variable name="entity-definition" select="$entity/m:content[@type eq 'glossary-definition']"/>
                        
                        <!-- Definition -->
                        <xsl:for-each select="$entry-definition">
                            <p>
                                <xsl:call-template name="class-attribute">
                                    <xsl:with-param name="base-classes" select="'definition'"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="node()"/>
                            </p>
                        </xsl:for-each>
                        
                        <!-- Entity definition -->
                        <xsl:if test="$view-mode[@id = ('editor', 'editor-passage')] and not($entity)">
                            <div class="footer">
                                <span class="label label-warning">
                                    <xsl:value-of select="'No shared entity assigned'"/>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="$entity-definition and (not($entry-definition) or $entity-instance[@use-definition  eq 'both'])">
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
                        <xsl:variable name="knowledgebase-instances" select="$entity/m:instance[@type eq 'knowledgebase-article'][not(@id eq $kb-id)]"/>
                        <xsl:variable name="requires-attention" select="$entity-instance/m:flag[@type eq 'requires-attention']"/>
                        <xsl:if test="$view-mode[@client = ('browser', 'ajax')] and ($glossary-instances, $knowledgebase-instances) and ($view-mode[@id = ('editor', 'editor-passage')] or not($requires-attention))">
                            <div class="footer entity-content" role="navigation">
                                <xsl:if test="$view-mode[@id = ('editor', 'editor-passage')] and $requires-attention">
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
                                <ul class="list-inline inline-dots small">
                                    <xsl:if test="$glossary-instances">
                                        <li>
                                            <a target="84000-glossary">
                                                <xsl:attribute name=" href" select="concat('/glossary.html?entity-id=', $entity/@xml:id, if($view-mode[@id = ('editor', 'editor-passage')]) then '&amp;view-mode=editor' else '')"/>
                                                <xsl:value-of select="concat(format-number(count($glossary-instances), '#,###'), ' related glossary ', if(count($glossary-instances) eq 1) then 'entry' else 'entries')"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                    <xsl:if test="$knowledgebase-instances">
                                        <li>
                                            <a target="84000-knowledgebase">
                                                <xsl:attribute name=" href" select="concat('/knowledgebase/', $knowledgebase-instances[1]/@id, '.html', if($view-mode[@id = ('editor', 'editor-passage')]) then '?view-mode=editor' else '')"/>
                                                <xsl:value-of select="'View the 84000 Knowledge Base article'"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                </ul>
                            </div>
                        </xsl:if>
                        
                        <!-- Link to glossary tool -->
                        <xsl:if test="$view-mode[@id = ('editor', 'editor-passage')] and $environment/m:url[@id eq 'operations']">
                            
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
        <xsl:if test="$view-mode[@id = ('editor', 'editor-passage')] and $environment/m:url[@id eq 'operations'] and m:knowledgebase/m:page[@xml:id gt '']">
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
                                    <xsl:attribute name="href" select="concat('#', $cached-location/@id)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                                <xsl:attribute name="data-glossary-location" select="$cached-location/@id"/>
                                <!-- marks a target -->
                                <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $glossary-id, '&#34;]')"/>
                                <xsl:attribute name="class" select="'scroll-to-anchor'"/>
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
    
    <!-- Headers -->
    <!-- About headers -->
    <xsl:template match="tei:head[@type eq 'about']">
        <h2>
            
            <xsl:call-template name="tid">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
            
            <!-- Don't duplicate if this is already the title -->
            <xsl:if test="string-join(data(), '') eq $section/m:titles/m:title[@xml:lang eq 'en']/text()">
                <xsl:attribute name="class" select="'sr-only'"/>
            </xsl:if>
            
            <xsl:apply-templates select="node()"/>
            
        </h2>
    </xsl:template>
    <!-- Primary headers -->
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
            
            <!-- data-passage-id -->
            <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                <xsl:attribute name="data-passage-id" select="$part/@id"/>
            </xsl:if>
            
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
                            
                            <xsl:call-template name="tid">
                                <xsl:with-param name="node" select="$title-supp"/>
                            </xsl:call-template>
                            
                            <xsl:apply-templates select="$title-supp/text()"/>
                            
                        </div>
                    </xsl:if>
                    
                    <xsl:element name="{ $header-tag }">
                        
                        <xsl:call-template name="tid">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                        <xsl:attribute name="class" select="'section-title break'"/>
                        
                        <xsl:apply-templates select="node()"/>
                        
                        <xsl:call-template name="tei-editor">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                    </xsl:element>
                    
                    <xsl:if test="$title-text[text()]">
                        
                        <div class="h3">
                            
                            <xsl:call-template name="tid">
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
                        
                        <xsl:call-template name="tid">
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

    <xsl:template match="m:part | tei:div">
        
        <div>
            
            <!-- Set the id -->
            <xsl:variable name="id" select="(@id, @xml:id)[1]"/>
            <xsl:attribute name="id" select="$id"/>
            
            <!-- Set the class -->
            <xsl:attribute name="class" select="'nested-section relative'"/>
            
            <!-- If the child is another div it will recurse -->
            <xsl:if test="$view-mode[not(@parts eq 'passage')] or node()[not(self::tei:head)]">
                <xsl:apply-templates select="node()"/>
            </xsl:if>
            
            <!-- Add link to tei editor -->
            <xsl:call-template name="tei-editor">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
            
        </div>
        
    </xsl:template>
    
    <xsl:template match="tei:media">
        <xsl:choose>
            
            <xsl:when test="@mimeType eq 'audio/mpeg' and $view-mode[@client = ('browser', 'ajax')]">
                <xsl:call-template name="milestone">
                    <xsl:with-param name="content">
                        <audio controls="controls">
                            <xsl:attribute name="title" select="tei:desc"/>
                            <source src="horse.mp3" type="audio/mpeg">
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
    
    <!-- Milestone -->
    <xsl:template name="milestone">
        
        <xsl:param name="content" required="yes"/>
        <xsl:param name="row-type" required="yes"/>
        
        <div>
            
            <xsl:if test="($translation | $knowledgebase)">
               
                <!-- Set id -->
                <xsl:variable name="milestone" select="(preceding-sibling::tei:*[1][self::tei:milestone] | preceding-sibling::tei:*[2][self::tei:milestone[following-sibling::tei:*[1][self::tei:lb]]] | parent::tei:seg/preceding-sibling::tei:*[1][self::tei:milestone] | parent::tei:seg/preceding-sibling::tei:*[2][self::tei:milestone[following-sibling::tei:*[1][self::tei:lb]]])[1]"/>
                <xsl:if test="$milestone">
                    <xsl:attribute name="id" select="$milestone/@xml:id"/>
                </xsl:if>
                
                <!-- Set the class -->
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="base-classes" as="xs:string*">
                        <xsl:value-of select="'rw'"/>
                        <xsl:value-of select="concat('rw-', $row-type)"/>
                        <!-- .rw-first specifies no preceding siblings -->
                        <xsl:variable name="count-previous-siblings" select="count(preceding-sibling::tei:*)"/>
                        <xsl:choose>
                            <xsl:when test="$count-previous-siblings eq 0">
                                <xsl:value-of select="'rw-first'"/>
                                <!-- .rw-no-head specifies no preceding siblings -->
                                <xsl:if test="parent::tei:div">
                                    <xsl:value-of select="'rw-first-in-section'"/>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                
                <!-- Set nearest id -->
                <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                    <xsl:variable name="nearest-milestone" select="preceding-sibling::tei:milestone[@xml:id][1]"/>
                    <xsl:if test="$nearest-milestone">
                        <xsl:attribute name="data-passage-id" select="$nearest-milestone/@xml:id"/>
                    </xsl:if>
                </xsl:if>
                
                <!-- If there's a milestone add a gutter and milestone link -->
                <xsl:if test="$milestone">
                    
                    <xsl:variable name="milestones-cache-milestone" select="key('milestones-cache-milestone', $milestone/@xml:id, $root)[1]"/>
                    <xsl:if test="$milestones-cache-milestone">
                        
                        <xsl:variable name="part" select="ancestor::m:part[@prefix][1]"/>
                        
                        <xsl:variable name="milestone-label">
                            <xsl:call-template name="bookmark-label">
                                <xsl:with-param name="prefix" select="($part/@prefix, '?')[1]"/>
                                <xsl:with-param name="index" select="$milestones-cache-milestone/@index"/>
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
                
            </xsl:if>
            
            <!-- Output the content -->
            <xsl:sequence select="$content"/>
            
        </div>
        
    </xsl:template>
    
    <!-- Temporary id - used to locate search results -->
    <xsl:template name="tid">
        
        <xsl:param name="node" required="yes"/>
        
        <!-- If a temporary id is present then set the id -->
        <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
            
            <xsl:variable name="id">
                <xsl:choose>
                    <xsl:when test="$node[@tid]">
                        <xsl:value-of select="concat('node-', $node/@tid)"/>
                    </xsl:when>
                    <xsl:when test="$node[@xml:id]">
                        <xsl:value-of select="$node/@xml:id"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                
                <!-- A translation -->
                <xsl:when test="$translation">
                    
                    <xsl:if test="$id gt ''">
                        <xsl:attribute name="id" select="$id"/>
                    </xsl:if>
                    
                    <xsl:if test="$view-mode[@glossary = ('defer', 'editor-defer')] and m:glossarize-context($node) and not(self::tei:head) and $node[@tid] and not($node[descendant::*/@tid])">
                        <xsl:call-template name="in-view-replace-attribute">
                            <xsl:with-param name="part-id" select="$id"/>
                            <xsl:with-param name="target-id" select="$id"/>
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
                        <xsl:when test="ancestor::m:text">
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
                    
                    <xsl:attribute name="href" select="concat('/tei-editor.html?type=', $resource-type, '&amp;resource-id=', $resource-id,'&amp;passage-id=', $id,'&amp;timestamp=', current-dateTime(), '#ajax-source')"/>
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
                                <a class="scroll-to-anchor" target="_self">
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
                                <a class="scroll-to-anchor" target="_self">
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
                                <a class="scroll-to-anchor" target="_self">
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
                                <a class="scroll-to-anchor log-click" target="_self">
                                    
                                    <xsl:choose>
                                        <xsl:when test="$part[@render eq 'preview']">
                                            <xsl:attribute name="href" select="concat('?part=', $part/@id, m:view-mode-parameter(()), m:archive-path-parameter(), '#', $part/@id)"/>
                                        </xsl:when>
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
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:param name="html-classes" as="xs:string*"/>
        
        <xsl:variable name="lang-class" select="common:lang-class(normalize-space($lang))"/>
        
        <xsl:variable name="css-classes" as="xs:string*">
            <xsl:if test="count($base-classes[normalize-space()]) gt 0">
                <xsl:value-of select="string-join($base-classes[normalize-space()], ' ')"/>
            </xsl:if>
            <xsl:if test="count($html-classes[normalize-space()]) gt 0 and $view-mode[not(@client = ('ebook', 'app'))]">
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
        
        <xsl:param name="target-id" as="xs:string"/>
        <xsl:param name="part-id" as="xs:string?"/>
        <xsl:param name="mark-id" as="xs:string?"/>
        
        <xsl:choose>
            
            <xsl:when test="$view-mode[@client = ('browser', 'ajax', 'pdf')]">
                
                <!-- Hash only, so it will be appended to page location on right-click and won't be followed by crawlers -->
                <xsl:attribute name="href" select="concat('#', $target-id)"/>
                
                <!-- Add relative url for later -->
                <xsl:choose>
                    <xsl:when test="$toh-key">
                        <xsl:attribute name="data-href-relative" select="concat('/translation/', $toh-key, '.html#', $target-id)"/>
                    </xsl:when>
                    <xsl:when test="$kb-id">
                        <xsl:attribute name="data-href-relative" select="concat('/knowledgebase/', $kb-id, '.html#', $target-id)"/>
                    </xsl:when>
                </xsl:choose>
                
                <!-- Marks a target -->
                <xsl:if test="$mark-id">
                    <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $mark-id, '&#34;]')"/>
                </xsl:if>
                
            </xsl:when>
            
            <xsl:when test="$view-mode[@client = ('ebook', 'app')]">
                
                <!-- Link to section in ebook -->
                <xsl:if test="$part-id">
                    <xsl:attribute name="href" select="concat($part-id, '.xhtml#', $target-id)"/>
                </xsl:if>
                
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="in-view-replace-attribute">
        
        <xsl:param name="part-id" as="xs:string"/>
        <xsl:param name="target-id" as="xs:string"/>
        
        <xsl:variable name="request-view-mode" select="if($view-mode[@glossary = ('defer')]) then 'passage' else 'editor-passage'"/>
        
        <xsl:choose>
            <xsl:when test="$toh-key">
                <xsl:attribute name="data-in-view-replace" select="concat('/translation/', $toh-key, '.html', '?part=', $part-id, m:view-mode-parameter($request-view-mode), m:archive-path-parameter(), '#', $target-id)"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="target-element" as="element()?">
        
        <xsl:param name="target-id" as="xs:string"/>
        <xsl:param name="translation-root" select="$root"/>
        
        <xsl:variable name="target" select="key('text-parts', $target-id, $translation-root)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('notes-cache-end-note', $target-id, $translation-root)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('milestones-cache-milestone', $target-id, $translation-root)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('glossary-cache-gloss', $target-id, $translation-root)[1]"/>
        
        <xsl:sequence select="$target"/>
        
    </xsl:template>
    
    <xsl:template name="target-element-href">
        
        <xsl:param name="target-element" as="element()"/>
        <xsl:param name="mark-id" as="xs:string?"/>
        
        <xsl:choose>
            
            <xsl:when test="$target-element[self::m:gloss]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="target-id" select="$target-element/@id"/>
                    <xsl:with-param name="part-id" select="'glossary'"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:end-note]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="target-id" select="concat('end-note-', $target-element/@id)"/>
                    <xsl:with-param name="part-id" select="'end-notes'"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:milestone]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="target-id" select=" $target-element/@id"/>
                    <xsl:with-param name="part-id" select="$target-element/@part-id"/>
                    <xsl:with-param name="mark-id" select="$mark-id"/>
                </xsl:call-template>
                
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:part][@id]">
                
                <xsl:call-template name="href-attribute">
                    <xsl:with-param name="target-id" select=" $target-element/@id"/>
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
                <xsl:with-param name="target-id" select=" $bookmark-target-hash"/>
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
                <xsl:apply-templates select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="filter-ref-prologue" as="node()*">
        <xsl:param name="node" as="node()?"/>
        <xsl:choose>
            <xsl:when test="count($node | $ref-prologue-parent) eq count($node)">
                <xsl:call-template name="filter-child-nodes">
                    <xsl:with-param name="child-nodes" select="$node/node()"/>
                    <xsl:with-param name="skip-nodes" select="$ref-prologue"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$node/node()"/>
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
                                <xsl:with-param name="target-id" select="$matching-glossary/@xml:id"/>
                            </xsl:call-template>
                            
                            <xsl:attribute name="data-glossary-id" select="$matching-glossary/@xml:id"/>
                            <xsl:attribute name="data-match-mode" select="'marked'"/>
                            
                            <xsl:variable name="glossary-location">
                                <xsl:call-template name="glossary-location">
                                    <xsl:with-param name="node" select="$element"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:attribute name="data-glossary-location" select="$glossary-location"/>
                            
                            <!-- target to be marked -->
                            <xsl:attribute name="data-mark-id" select="$matching-glossary/@xml:id"/>
                            
                            <xsl:call-template name="class-attribute">
                                
                                <xsl:with-param name="base-classes" as="xs:string*">
                                    
                                    <xsl:value-of select="'glossary-link'"/>
                                    
                                    <!-- Check if the location is cached and flag it if not -->
                                    <xsl:if test="$view-mode[@glossary = ('no-cache', 'editor-defer')]">
                                        <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $matching-glossary/@xml:id, $root)[1]" as="element(m:gloss)*"/>
                                        <xsl:if test="not($glossary-cache-gloss/m:location[@id/string() eq $glossary-location])">
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
        <xsl:variable name="glossary-location">
            <xsl:call-template name="glossary-location">
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
                    <xsl:variable name="cached-location-gloss-ids" select="key('glossary-cache-location', $glossary-location, $root)/parent::m:gloss/@id" as="xs:string*"/>
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
                        <xsl:call-template name="mark-text">
                            <xsl:with-param name="glossary-id" select="$matching-glossary/@xml:id"/>
                            <xsl:with-param name="glossary-location" select="$glossary-location"/>
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
                <xsl:call-template name="scan-text">
                    <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
                    <xsl:with-param name="match-glossary-index" select="1"/>
                    <xsl:with-param name="glossary-location" select="$glossary-location"/>
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
        <xsl:param name="glossary-location" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        
        <!-- We are recursing through the terms  -->
        <xsl:choose>
            
            <xsl:when test="$text[normalize-space()] and $match-glossary-index le count($match-glossary-items)">
                
                <xsl:variable name="match-glossary-item" select="$match-glossary-items[$match-glossary-index]"/>
                <xsl:variable name="match-glossary-item-terms-regex" select="common:matches-regex(m:glossary-terms-to-match($match-glossary-item))"/>
                
                <xsl:analyze-string regex="{ $match-glossary-item-terms-regex }" select="$text" flags="i">
                    
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:call-template name="mark-text">
                            <xsl:with-param name="glossary-id" select="$match-glossary-item/@xml:id"/>
                            <xsl:with-param name="glossary-location" select="$glossary-location"/>
                            <xsl:with-param name="text" as="text()">
                                <xsl:value-of select="concat(regex-group(2), regex-group(3), '')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:value-of select="regex-group(4)"/>
                    </xsl:matching-substring>
                    
                    <xsl:non-matching-substring>
                        <xsl:call-template name="scan-text">
                            <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
                            <xsl:with-param name="match-glossary-index" select="$match-glossary-index + 1"/>
                            <xsl:with-param name="glossary-location" select="$glossary-location"/>
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
    <xsl:template name="mark-text">
        
        <xsl:param name="glossary-id" as="xs:string"/>
        <xsl:param name="glossary-location" as="xs:string"/>
        <xsl:param name="text" as="text()*"/>
        
        <xsl:choose>
            
            <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))]">
                <a>
                    
                    <xsl:call-template name="href-attribute">
                        <xsl:with-param name="target-id" select="$glossary-id"/>
                    </xsl:call-template>
                    
                    <xsl:attribute name="data-glossary-id" select="$glossary-id"/>
                    <xsl:attribute name="data-match-mode" select="'matched'"/>
                    <xsl:attribute name="data-glossary-location" select="$glossary-location"/>
                    
                    <!-- target to be marked -->
                    <xsl:attribute name="data-mark-id" select="$glossary-id"/>
                    
                    <xsl:call-template name="class-attribute">
                        
                        <xsl:with-param name="base-classes" as="xs:string*">
                            
                            <xsl:value-of select="'glossary-link'"/>
                            
                            <!-- Check if the location is cached and flag it if not -->
                            <xsl:if test="$view-mode[@glossary = ('no-cache', 'editor-defer')]">
                                <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $glossary-id, $root)[1]" as="element(m:gloss)*"/>
                                <xsl:if test="not($glossary-cache-gloss/m:location[@id/string() eq $glossary-location])">
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
    
    <!-- Get the location for glossary caching -->
    <xsl:template name="glossary-location" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            
            <!-- Get the xml:id from the container -->
            <xsl:when test="$node[ancestor::tei:*[@xml:id]]">
                <xsl:value-of select="$node/ancestor::tei:*[@xml:id][1]/@xml:id"/>
            </xsl:when>
            
            <!-- Get the xml:id from the container -->
            <xsl:when test="$node[ancestor::m:entry[parent::m:glossary][@id]]">
                <xsl:value-of select="$node/ancestor::m:entry[@id][1]/@id"/>
            </xsl:when>
            
            <!-- Look for a nearest milestone -->
            <xsl:when test="$node[ancestor::tei:*/preceding-sibling::tei:milestone[@xml:id]]">
                <xsl:value-of select="$node/ancestor::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]/@xml:id"/>
            </xsl:when>
            
            <!-- Default to the id of the nearest part -->
            <xsl:otherwise>
                <xsl:value-of select="$node/ancestor::m:part[@id][1]/@id"/>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <!-- Check the context of the node is a somewhere to glossarize -->
    <xsl:function name="m:glossarize-context" as="xs:boolean">
        
        <xsl:param name="node" as="node()"/>
        
        <xsl:choose>
            
            <xsl:when test="$view-mode[@glossary eq 'suppress']">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <xsl:when test="$node[ancestor-or-self::*[@glossarize eq 'suppress']]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
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
    
    <!-- Tantra warning -->
    <xsl:template name="tantra-warning">
        <xsl:param name="id"/>
        <xsl:param name="node"/>
        
        <div class="hidden-print">
            
            <a data-toggle="modal" class="warning">
                <xsl:attribute name="href" select="concat('#tantra-warning-', $id)"/>
                <xsl:attribute name="data-target" select="concat('#tantra-warning-', $id)"/>
                <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                <xsl:value-of select="' Tantra Text Warning'"/>
            </a>
            
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
                    </div>
                </div>
            </div>
            
        </div>
        
        <div class="visible-print-block small">
            <xsl:apply-templates select="$node"/>
        </div>
        
    </xsl:template>
    
    <!-- Expandable summary of text (summary, variant titles, supplementary roles) -->
    <xsl:template name="expandable-summary">
        
        <xsl:param name="text"/>
        <xsl:param name="expand-id" as="xs:string"/>
        
        <xsl:variable name="toh-key" select="$text/m:toh/@key"/>
        
        <xsl:variable name="supplementaryRoles" select="('translator', 'reviser')"/>
        <xsl:variable name="summary" select="$text/m:part[@type eq 'summary']/tei:p"/>
        <xsl:variable name="titleVariants" select="$text/m:title-variants/m:title[normalize-space(string-join(text(), ' '))] | $text/m:title-variants/m:note[@type eq 'title'][normalize-space(string-join(text(), ''))]"/>
        <xsl:variable name="supplementaryAttributions" select="$text/m:source/m:attribution[@ref][@role = $supplementaryRoles]"/>
        
        <xsl:if test="$summary or $titleVariants or $supplementaryAttributions">
            
            <hr class="hidden-print"/>
                
            <a class="summary-link collapsed hidden-print" role="button" data-toggle="collapse" aria-expanded="false">
                <xsl:attribute name="href" select="concat('#', $expand-id)"/>
                <xsl:attribute name="aria-controls" select="concat('#', $expand-id)"/>
                <i class="fa fa-chevron-down"/>
                <xsl:value-of select="' '"/>
                <xsl:value-of select="'Summary and further information'"/>
            </a>
            
            <xsl:variable name="summary-content">
                
                <div class="well well-sm small">
                    
                    <h4>
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
            
            <!--<section>
                
                <xsl:attribute name="class" select="'preview summary-detail print-collapse-override'"/>
                
                <xsl:call-template name="preview-controls">
                    <xsl:with-param name="section-id" select="$expand-id"/>
                </xsl:call-template>
                
                <xsl:sequence select="$summary-content"/>
                
            </section>-->
            
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
    
    <xsl:template name="entity-data">
        
        <xsl:param name="entity" as="element(m:entity)"/>
        <xsl:param name="search-text" as="xs:string"/>
        <xsl:param name="selected-term-lang" as="xs:string"/>
        
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
                
                <xsl:variable name="primary-terms" as="element(m:term)*">
                    <xsl:choose>
                        <xsl:when test="$related-entries/m:term[@xml:lang eq 'bo'][text()][not(text() = ('', $term-empty-bo))]">
                            <xsl:sequence select="$related-entries/m:term[@xml:lang eq 'bo']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$related-entries/m:term[@xml:lang eq 'Sa-Ltn'][text()][not(text() = ('', $term-empty-sa-ltn))]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:variable name="sorted-terms" as="element(m:term)*">
                    <xsl:perform-sort select="$primary-terms">
                        <xsl:sort select="string-length(lower-case(data()))" order="descending"/>
                    </xsl:perform-sort>
                </xsl:variable>
                
                <xsl:variable name="longest-term" select="if($sorted-terms) then $sorted-terms[1] else ($entity/m:label[@xml:lang eq 'en'], $entity/m:label[@xml:lang eq 'Sa-Ltn'], $entity/m:label[@xml:lang eq 'Bo-Ltn'])[1]"/>
                
                <xsl:element name="label" namespace="http://read.84000.co/ns/1.0">
                    <xsl:attribute name="type" select="'primary'"/>
                    <xsl:attribute name="xml:lang" select="$longest-term/@xml:lang"/>
                    <xsl:value-of select="$longest-term"/>
                </xsl:element>
                
                <xsl:if test="$longest-term[@xml:lang eq 'bo']">
                    
                    <xsl:variable name="sorted-secondary-terms" as="element(m:term)*">
                        <xsl:perform-sort select="$related-entries/m:term[@xml:lang eq 'Bo-Ltn']">
                            <xsl:sort select="string-length(lower-case(data()))" order="descending"/>
                        </xsl:perform-sort>
                    </xsl:variable>
                    
                    <xsl:if test="$sorted-secondary-terms">
                        <xsl:element name="label" namespace="http://read.84000.co/ns/1.0">
                            <xsl:attribute name="type" select="'secondary'"/>
                            <xsl:attribute name="xml:lang" select="$sorted-secondary-terms[1]/@xml:lang"/>
                            <xsl:value-of select="$sorted-secondary-terms[1]"/>
                        </xsl:element>
                    </xsl:if>
                    
                </xsl:if>
                
                <xsl:for-each-group select="$related-entries/m:term[@xml:lang eq $selected-term-lang]" group-by="string-join(tokenize(data(), '\s+') ! lower-case(data()) ! common:standardized-sa(.) ! common:alphanumeric(.), ' ')">
                    
                    <xsl:sort select="string-join(tokenize(data(), '\s+') ! lower-case(data()) ! common:standardized-sa(.) ! common:alphanumeric(.), ' ')"/>
                    
                    <xsl:variable name="match-text" select="string-join(tokenize(data(), '\s+') ! lower-case(.) ! common:standardized-sa(.) ! common:alphanumeric(.), ' ')" as="xs:string"/>
                    <xsl:variable name="match-regex" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="@xml:lang eq 'en'">
                                <xsl:value-of select="concat(if(string-length($search-text) ne 1) then '(?:^|\s+)' else '^(The\s+|A\s+|An\s+)?', string-join(tokenize($search-text, '\s+') ! common:standardized-sa(.) ! common:alphanumeric(.), '.*\s+'))"/>
                            </xsl:when>
                            <xsl:when test="@xml:lang eq 'Bo-Ltn'">
                                <xsl:value-of select="concat(if(string-length($search-text) ne 1) then '' else '^', string-join(tokenize($search-text, '\s+') ! common:standardized-sa(.) ! common:alphanumeric(.), '.*\s+'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(if(string-length($search-text) ne 1) then '(?:^|\s+)' else '^', string-join(tokenize($search-text, '\s+') ! common:standardized-sa(.) ! common:alphanumeric(.), '.*\s+'))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:element name="term" namespace="http://read.84000.co/ns/1.0">
                        <xsl:variable name="term-entry-id" select="parent::m:entry/@id"/>
                        <xsl:attribute name="xml:lang" select="@xml:lang"/>
                        <xsl:attribute name="word-count" select="count(tokenize($match-text, '\s+'))"/>
                        <xsl:attribute name="letter-count" select="string-length($match-text)"/>
                        <xsl:if test="matches($match-text, $match-regex, 'i')">
                            <xsl:attribute name="matches" select="true()"/>
                        </xsl:if>
                        <xsl:if test="$entity/m:instance[@id eq $term-entry-id][m:flag]">
                            <xsl:attribute name="flagged" select="true()"/>
                        </xsl:if>
                        <xsl:value-of select="data()"/>
                    </xsl:element>
                    
                </xsl:for-each-group>
                
            </xsl:element>
            
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>