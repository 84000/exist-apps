<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <!-- Transforms tei to xhtml -->
    
    <!-- Output as website page -->
    <xsl:import href="../views/html/website-page.xsl"/>
    
    <!-- Useful keys -->
    <xsl:key name="translation-parts" match="/m:response/m:translation//m:part[@id]" use="@id"/>
    <xsl:key name="glossary-cache-gloss" match="/m:response/m:translation/m:glossary-cache/m:gloss" use="@id"/>
    <xsl:key name="glossary-cache-location" match="/m:response/m:translation/m:glossary-cache/m:gloss/m:location" use="@id"/>
    <xsl:key name="folios-cache-ref" match="/m:response/m:translation/m:folios-cache/m:folio-ref" use="@id"/>
    <xsl:key name="notes-cache-end-note" match="/m:response/m:translation/m:notes-cache/m:end-note" use="@id"/>
    <xsl:key name="milestones-cache-milestone" match="/m:response/m:translation/m:milestones-cache/m:milestone" use="@id"/>
    
    <!-- Global variables -->
    <xsl:variable name="translation-id" select="/m:response/m:translation/@id"/>
    <xsl:variable name="toh-key" select="/m:response/m:translation/m:source/@key"/>
    <xsl:variable name="part-status" select="if(not(/m:response/m:translation//m:part[@render = ('preview', 'empty')])) then 'complete' else if(/m:response/m:translation//m:part[@render eq 'show']) then 'part' else 'empty'" as="xs:string"/>
    
    <!-- Pre-sort the glossaries by priority -->
    <xsl:variable name="glossary-prioritised" as="element(tei:gloss)*">
        <xsl:perform-sort select="/m:response/m:translation/m:part[@type eq 'glossary']/tei:div/tei:gloss[@xml:id]">
            <xsl:sort select="key('glossary-cache-gloss', @xml:id)[1]/@word-count ! xs:integer(.)" order="descending"/>
            <xsl:sort select="key('glossary-cache-gloss', @xml:id)[1]/@letter-count ! xs:integer(.)" order="descending"/>
        </xsl:perform-sort>
    </xsl:variable>
    
    <!-- Specify glossary ids to be tested, or empty for all - a single invalid test-glossary (e.g. 'all') will trigger a test of all without a cache  -->
    <xsl:variable name="test-glossary" select="/m:response/m:request/m:test-glossary[@id]"/>
    <xsl:variable name="test-glossary-items" select="if($test-glossary) then $glossary-prioritised[@xml:id = $test-glossary/@id] else ()" as="element(tei:gloss)*"/>
    <xsl:variable name="test-glossary-items-terms" as="xs:string*" select="m:glossary-terms-to-match($test-glossary-items)"/>
   
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
                <xsl:when test="$view-mode[@glossary = ('defer', 'defer-no-cache')] and not(ancestor::tei:note[@place eq 'end'][@xml:id]) and ancestor::tei:*[@tid]">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- TEI elements we don't want to process -->
                <xsl:when test="parent::tei:ptr | parent::tei:lb | parent::tei:milestone | parent::tei:term[not(@type eq 'definition')] | ancestor::tei:head">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                
                <!-- EFT elements we don't want to process -->
                <xsl:when test="parent::m:honoration | parent::m:main-title  | parent::m:sub-title | parent::m:title-supp | parent::m:match">
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
    
    <xsl:template match="tei:title">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'title'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
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
            
            <xsl:when test="$ref[@key] and $ref[not(@key eq $toh-key)]">
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
                <xsl:variable name="index" select="if($ref[@xml:id]) then key('folios-cache-ref', $ref/@xml:id)[1]/@index-in-resource else ()"/>
                
                <xsl:choose>
                    
                    <xsl:when test="$index">
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
    
    <xsl:template match="tei:q">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <blockquote>
                    <xsl:apply-templates select="node()"/>
                </blockquote>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'blockquote'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:p | tei:ab | tei:trailer | tei:bibl">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <p>
                    
                    <!-- id -->
                    <xsl:call-template name="tid">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <!-- class -->
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:choose>
                                <xsl:when test="(@rend, @type) = 'mantra'">
                                    <xsl:value-of select="'mantra'"/>
                                </xsl:when>
                                <xsl:when test="self::tei:trailer">
                                    <xsl:value-of select="'trailer'"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:apply-templates select="node()"/>
                    
                </p>
            </xsl:with-param>
            <xsl:with-param name="row-type">
                <xsl:choose>
                    <xsl:when test="(@rend,@type) = 'mantra'">
                        <xsl:value-of select="'mantra'"/>
                    </xsl:when>
                    <xsl:when test="self::tei:trailer">
                        <xsl:value-of select="'trailer'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'paragraph'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
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
                                
                                <xsl:for-each select="$labels/*:span">
                                    <xsl:sequence select="."/>
                                    <xsl:value-of select="if(position() eq count($labels/*:span)) then '' else '; '"/>
                                </xsl:for-each>
                                
                            </h5>
                            
                            <p>
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
                                
                                <xsl:for-each select="$datas/*:span">
                                    <xsl:sequence select="."/>
                                    <xsl:value-of select="if(position() eq count($datas/*:span)) then '.' else '; '"/>
                                </xsl:for-each>
                                
                            </p>
                        </xsl:for-each>
                    </div>
                </div>
                
                <!-- Render the table version for html -->
                <xsl:if test="$view-mode[not(@id = ('ebook', 'pdf'))]">
                    <div class="table-responsive hidden-print hidden-ebook">
                        <table class="table">
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
                
                <div class="table-notes">
                    <xsl:apply-templates select="tei:note"/>
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
                </h5>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'label'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Lists -->
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
                    
                </h5>
            </xsl:with-param>
            
            <xsl:with-param name="row-type" select="'list-head'"/>
            
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="tei:item[parent::tei:list]">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div class="list-item">
                    
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
    
    <!-- Line groups -->
    <xsl:template match="tei:lg">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:call-template name="tid">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'line-group'"/>
                            <xsl:if test="@type = ('sdom', 'bar_sdom', 'spyi_sdom')">
                                <xsl:value-of select="'italic'"/>
                            </xsl:if>
                            <xsl:if test="@rend = 'mantra'">
                                <xsl:value-of select="'mantra'"/>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:for-each select="tei:l">
                        <xsl:call-template name="milestone">
                            <xsl:with-param name="content">
                                <div>
                                    <xsl:call-template name="class-attribute">
                                        <xsl:with-param name="base-classes" select="'line'"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="node()"/>
                                </div>
                            </xsl:with-param>
                            <xsl:with-param name="row-type" select="'line'"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    
                </div>
            </xsl:with-param>
            
            <xsl:with-param name="row-type" select="'line-group'"/>
            
        </xsl:call-template>
    </xsl:template>

    <!-- Note link in the text -->
    <xsl:template match="tei:note[@place eq 'end'][@xml:id]">
        
        <xsl:variable name="note" select="."/>
        <xsl:variable name="notes-cache-end-note" select="key('notes-cache-end-note', $note/@xml:id)[1]"/>
    
        <a class="footnote-link">
            
            <xsl:attribute name="id" select="$note/@xml:id"/>
            <!-- target to be marked -->
            <xsl:attribute name="data-mark-id" select="$note/@xml:id"/>
            
            <xsl:choose>
                
                <xsl:when test="$view-mode[@client = ('ebook')]">
                    <xsl:attribute name="href" select="concat('end-notes.xhtml#end-note-', $note/@xml:id)"/>
                    <xsl:attribute name="epub:type" select="'noteref'"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:attribute name="href" select="concat('#end-note-', $note/@xml:id)"/>
                    <xsl:attribute name="data-href-part" select="'end-notes'"/>
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" select="'footnote-link'"/>
                        <xsl:with-param name="html-classes" select="'pop-up'"/>
                    </xsl:call-template>
                </xsl:otherwise>
                
            </xsl:choose>
            <xsl:value-of select="$notes-cache-end-note/@index"/>
        </a>
        
    </xsl:template>
    <!-- List at the end -->
    <xsl:template name="end-notes">
        
        <xsl:variable name="end-notes-part" select="/m:response/m:translation/m:part[@type eq 'end-notes'][1]"/>
        
        <xsl:apply-templates select="$end-notes-part/tei:head"/>
        
        <xsl:for-each-group select="/m:response/m:translation//tei:note[@place eq 'end'][@xml:id]" group-by="@xml:id">
            
            <xsl:sort select="key('notes-cache-end-note', @xml:id)[1]/@index ! xs:integer(.)"/>
            
            <xsl:variable name="end-note" select="."/>
            <xsl:variable name="notes-cache-end-note" select="key('notes-cache-end-note', @xml:id)[1]"/>
            <xsl:variable name="part" select="key('translation-parts', $notes-cache-end-note/@part-id)[1]"/>
            
            <div class="rw footnote">
                
                <xsl:attribute name="id" select="concat('end-note-', $end-note/@xml:id)"/>
                
                <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                    <xsl:attribute name="data-passage-id" select="$end-note/@xml:id"/>
                </xsl:if>
                
                <div class="gtr">
                    
                    <xsl:choose>
                        
                        <xsl:when test="$view-mode[@client = ('browser', 'ajax')]">
                            
                            <a>
                                
                                <xsl:attribute name="href" select="concat('#', $end-note/@xml:id)"/>
                                <xsl:attribute name="data-href-part" select="$part/@id"/>
                                <!-- marks a target -->
                                <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $end-note/@xml:id, '&#34;]')"/>
                                <xsl:attribute name="class" select="'footnote-number scroll-to-anchor'"/>
                                
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="$end-notes-part/@prefix"/>
                                    <xsl:with-param name="index" select="$notes-cache-end-note/@index"/>
                                </xsl:call-template>
                                
                            </a>
                            
                        </xsl:when>
                        
                        <xsl:when test="$view-mode[@client = ('ebook', 'app')]">
                            
                            <a>
                                
                                <xsl:attribute name="href" select="concat($part/@id, '.xhtml',  '#', $end-note/@xml:id)"/>
                                
                                <xsl:call-template name="bookmark-label">
                                    <xsl:with-param name="prefix" select="$end-notes-part/@prefix"/>
                                    <xsl:with-param name="index" select="$notes-cache-end-note/@index"/>
                                </xsl:call-template>
                                
                            </a>
                            
                        </xsl:when>
                        
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
            
        </xsl:for-each-group>
        
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
                    
                    <!-- Check ifs deferred -->
                    <xsl:when test="$view-mode[@glossary = ('defer', 'defer-no-cache')] and ancestor::tei:*[@tid]">
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
        
        <xsl:variable name="glossary-part" select="/m:response/m:translation/m:part[@type eq 'glossary'][1]"/>
        
        <xsl:apply-templates select="$glossary-part/tei:head"/>
        
        <xsl:for-each select="$glossary-part/tei:div/tei:gloss[@xml:id]">
            
            <xsl:sort select="key('glossary-cache-gloss', @xml:id)[1]/@index ! xs:integer(.)"/>
            
            <xsl:variable name="glossary-item" select="."/>
            <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', $glossary-item/@xml:id)[1]"/>
            <xsl:variable name="cached-locations" select="$glossary-cache-gloss/m:location"/>
            <xsl:variable name="glossary-item-label">
                <xsl:call-template name="bookmark-label">
                    <xsl:with-param name="prefix" select="$glossary-part/@prefix"/>
                    <xsl:with-param name="index" select="$glossary-cache-gloss/@index"/>
                </xsl:call-template>
            </xsl:variable>
            
            <!-- Potential optimisation: only show glossaries with expressions in the text (Could be slower to filter them than to just parse them) -->
            <div class="rw glossary-item">
                
                <xsl:if test="$glossary-item[@xml:id]">
                    
                    <xsl:attribute name="id" select="$glossary-item/@xml:id"/>
                    
                    <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <xsl:attribute name="data-passage-id" select="$glossary-item/@xml:id"/>
                    </xsl:if>
                    
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
                    
                    <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <xsl:attribute name="class" select="'row'"/>
                    </xsl:if>
                    
                    <div>
                        
                        <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                            <xsl:attribute name="class" select="'col-md-7 match-this-height print-width-override'"/>
                        </xsl:if>
                        
                        <h4 class="term">
                            <xsl:value-of select="$glossary-item/tei:term[not(@type)][not(@xml:lang) or @xml:lang eq 'en'][1]/normalize-space(.) ! functx:capitalize-first(.)"/>
                        </h4>
                        
                        <xsl:for-each select="('Bo-Ltn','bo','Sa-Ltn')">
                            <xsl:variable name="term-lang" select="."/>
                            <xsl:variable name="term-lang-terms" select="$glossary-item/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq $term-lang]"/>
                            <ul class="list-inline inline-dots">
                                <xsl:choose>
                                    <xsl:when test="$term-lang-terms">
                                        <xsl:for-each select="$term-lang-terms">
                                            <li>
                                                
                                                <xsl:call-template name="class-attribute">
                                                    <xsl:with-param name="base-classes" as="xs:string*">
                                                        <xsl:value-of select="'term'"/>
                                                        <xsl:choose>
                                                            <xsl:when test="$term-lang eq 'Bo-Ltn'">
                                                                <xsl:value-of select="'text-wy'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$term-lang eq 'bo'">
                                                                <xsl:value-of select="'text-bo'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$term-lang eq 'Sa-Ltn'">
                                                                <xsl:value-of select="'text-sa'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:if test="@type = ('semanticReconstruction','transliterationReconstruction')">
                                                            <xsl:value-of select="'reconstructed'"/>
                                                        </xsl:if>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                                
                                                <xsl:choose>
                                                    <xsl:when test="normalize-space(text())">
                                                        <xsl:value-of select="normalize-space(text())"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="text">
                                                            <xsl:with-param name="global-key" select="concat('glossary.term-empty-', lower-case($term-lang))"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                            </li>
                                        </xsl:for-each>
                                    </xsl:when>
                                </xsl:choose>
                            </ul>
                            
                        </xsl:for-each>
                        
                        <xsl:if test="$view-mode[@id = ('editor', 'annotation', 'tests')]">
                            <xsl:for-each select="$glossary-item/tei:term[@type eq 'alternative'][normalize-space(data())]">
                                <p class="term alternative">
                                    <xsl:value-of select="normalize-space(data())"/>
                                </p>
                            </xsl:for-each>
                        </xsl:if>
                        
                        <xsl:for-each select="$glossary-item/tei:term[@type eq 'definition'][node()]">
                            <p>
                                <xsl:call-template name="class-attribute">
                                    <xsl:with-param name="base-classes" select="'definition'"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="node()"/>
                            </p>
                        </xsl:for-each>
                        
                        <xsl:if test="$view-mode[@id = ('editor')] and $environment/m:url[@id eq 'operations']">
                            <a target="84000-glossary-tool" class="underline small">
                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/text(), '/glossary.html', '?resource-id=', $translation-id, '&amp;glossary-id=', $glossary-item/@xml:id, '&amp;max-records=1')"/>
                                <xsl:value-of select="'Open in the glossary editor'"/>
                            </a>
                        </xsl:if>
                        
                    </div>
                    
                    <xsl:if test="$view-mode[not(@id eq 'pdf')]">
                        <div class="locations">
                            
                            <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                                
                                <xsl:attribute name="class" select="'locations col-md-5 hidden-print'"/>
                                
                                <hr class="visible-xs-block visible-sm-block"/>
                                
                            </xsl:if>
                            
                            <xsl:variable name="count-expressions" select="count($cached-locations)"/>
                            <h5>
                                <xsl:choose>
                                    <xsl:when test="$count-expressions gt 1">
                                        <xsl:value-of select="concat(format-number($count-expressions, '#,###'), ' passages contain this term')"/>
                                    </xsl:when>
                                    <xsl:when test="$count-expressions eq 1">
                                        <xsl:value-of select="'1 passage contains this term'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'No instances of this term'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </h5>
                            
                            <xsl:if test="$cached-locations">
                                <ul class="list-inline">
                                    <xsl:for-each select="$cached-locations">
                                        <li>
                                            <a>
                                                
                                                <xsl:variable name="cached-location" select="."/>
                                                
                                                <xsl:variable name="target-element" as="element()?">
                                                    <xsl:call-template name="target-element">
                                                        <xsl:with-param name="target-id" select="$cached-location/@id"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$target-element">
                                                        <xsl:call-template name="target-element-href">
                                                            <xsl:with-param name="target-element" select="$target-element"/>
                                                            <xsl:with-param name="mark-id" select="$glossary-item/@xml:id"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="href" select="$cached-location/@id"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                                <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                                                    <xsl:attribute name="data-glossary-location" select="$cached-location/@id"/>
                                                    <!-- marks a target -->
                                                    <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $glossary-item/@xml:id, '&#34;]')"/>
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
                            
                        </div>
                    </xsl:if>
                    
                </div>
                
            </div>
            
        </xsl:for-each>
    
    </xsl:template>
    
    <!-- Headers -->
    <xsl:template match="tei:head[@type eq 'about']">
        <h1 class="text-center">
            <xsl:call-template name="tid">
                <xsl:with-param name="node" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </h1>
    </xsl:template>
    <xsl:template match="tei:head">
        
        <xsl:variable name="part" select="parent::m:part"/>
        <xsl:variable name="title-text" select="$part/m:title-text[1]"/>
        <xsl:variable name="title-supp" select="$part/m:title-supp[1]"/>
        
        <xsl:choose>
            
            <!-- Only show base headers in preview -->
            <xsl:when test="$part/@type eq @type">
                <div>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'rw'"/>
                            <xsl:value-of select="'rw-section-head'"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <xsl:attribute name="data-passage-id" select="$part/@id"/>
                    </xsl:if>
                    
                    <xsl:if test="$part[@prefix]">
                        <div class="gtr">
                            <xsl:choose>
                                
                                <!-- show a link -->
                                <xsl:when test="$view-mode[not(@client = ('ebook', 'app'))] and $part[@id]">
                                    <xsl:call-template name="bookmark-link">
                                        <xsl:with-param name="bookmark-target-hash" select="$part/@id"/>
                                        <xsl:with-param name="bookmark-label">
                                            <xsl:call-template name="bookmark-label">
                                                <xsl:with-param name="prefix" select="$part/@prefix"/>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                        <xsl:with-param name="bookmark-title" select="text()"/>
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
                    
                    <div>
                        
                        <xsl:call-template name="class-attribute">
                            <xsl:with-param name="base-classes" as="xs:string*">
                                <xsl:value-of select="'rw-heading'"/>
                                <xsl:value-of select="'heading-section'"/>
                                <xsl:choose>
                                    <xsl:when test="not(@type = ('section', 'colophon', 'homage', 'prologue'))">
                                        <xsl:value-of select="'chapter'"/>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:if test="$part[@nesting]">
                                    <xsl:value-of select="concat('nested nested-', $part/@nesting)"/>
                                </xsl:if>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <!-- Add container for dots :before and :after -->
                        <div>
                            
                            <!-- Supplementary title -->
                            <xsl:if test="$title-supp[text()]">
                                <h4>
                                    <xsl:call-template name="tid">
                                        <xsl:with-param name="node" select="$title-supp"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="$title-supp/text()"/>
                                </h4>
                            </xsl:if>
                            
                            <!-- Section head -->
                            <xsl:choose>
                                
                                <!-- Make this <h1/> if it's the selected part -->
                                <xsl:when test="$part[@prefix]">
                                    
                                    <xsl:choose>
                                        <xsl:when test="$title-text[text()]">
                                            
                                            <h2>
                                                <xsl:call-template name="tid">
                                                    <xsl:with-param name="node" select="."/>
                                                </xsl:call-template>
                                                <xsl:apply-templates select="node()"/>
                                            </h2>
                                            
                                            <h3>
                                                <xsl:call-template name="tid">
                                                    <xsl:with-param name="node" select="$title-text"/>
                                                </xsl:call-template>
                                                <xsl:apply-templates select="$title-text/text()"/>
                                            </h3>
                                            
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <h2>
                                                <xsl:call-template name="tid">
                                                    <xsl:with-param name="node" select="."/>
                                                </xsl:call-template>
                                                <xsl:apply-templates select="node()"/>
                                            </h2>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:when>
                                
                                <!-- Chapter head -->
                                <xsl:when test="not(@type = ('section', 'colophon', 'homage', 'prologue')) and not($title-text[text()])">
                                    <h2>
                                        <xsl:call-template name="tid">
                                            <xsl:with-param name="node" select="."/>
                                        </xsl:call-template>
                                        <xsl:apply-templates select="node()"/>
                                    </h2>
                                </xsl:when>
                                
                                <!-- Section head -->
                                <xsl:otherwise>
                                    <h3>
                                        <xsl:call-template name="tid">
                                            <xsl:with-param name="node" select="."/>
                                        </xsl:call-template>
                                        <xsl:apply-templates select="node()"/>
                                    </h3>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                        
                        </div>
                        
                    </div>
                </div>
            </xsl:when>
            
            <xsl:otherwise>
                
                <xsl:call-template name="milestone">
                    
                    <xsl:with-param name="content">
                        <div>
                            
                            <xsl:call-template name="class-attribute">
                                <xsl:with-param name="base-classes" as="xs:string*">
                                    <xsl:value-of select="'rw-heading heading-section'"/>
                                    <xsl:if test="@type eq 'nonStructuralBreak'">
                                        <xsl:value-of select="'supplementary'"/>
                                    </xsl:if>
                                </xsl:with-param>
                            </xsl:call-template>
                            
                            <h4>
                                <xsl:call-template name="tid">
                                    <xsl:with-param name="node" select="."/>
                                </xsl:call-template>
                                <xsl:apply-templates select="node()"/>
                            </h4>
                            
                        </div>
                    </xsl:with-param>
                    
                    <xsl:with-param name="row-type" select="'section-head'"/>
                    
                </xsl:call-template>
                
            </xsl:otherwise>
            
        </xsl:choose>
        
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

    <xsl:template match="m:part">
        <!-- Wrap in a div -->
        <div>
            
            <!-- Set the id -->
            <xsl:attribute name="id" select="@id"/>
            
            <!-- Set the class -->
            <xsl:attribute name="class" select="'nested-section'"/>
            
            <!-- If the child is another div it will recurse -->
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>
    
    <xsl:template match="m:abbreviations">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <xsl:for-each select="m:head[not(lower-case(text()) = ('abbreviations', 'abbreviations:'))]">
                    <h5>
                        <xsl:apply-templates select="node()"/>
                    </h5>
                </xsl:for-each>
                <xsl:for-each select="m:description">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
                <table class="table">
                    <tbody>
                        <xsl:for-each select="m:item">
                            <xsl:sort select="m:abbreviation"/>
                            <tr>
                                <th>
                                    <xsl:apply-templates select="m:abbreviation/node()"/>
                                </th>
                                <td>
                                    <xsl:apply-templates select="m:explanation/node()"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                <xsl:for-each select="m:foot">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'list-section'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:bibliography">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                
                <!-- Title -->
                <xsl:if test="m:title/text()">
                    <h5 class="section-label">
                        <xsl:apply-templates select="m:title/text()"/>
                    </h5>
                </xsl:if>
                
                <!-- Items -->
                <xsl:for-each select="m:item">
                    <p>
                        <xsl:attribute name="id" select="@id"/>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
                
                <!-- Possible nested bibliographies -->
                <xsl:apply-templates select="m:bibliography"/>
                
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'list-section'"/>
        </xsl:call-template>
    </xsl:template>
 
    <!-- Milestone -->
    <xsl:template name="milestone">
        
        <xsl:param name="content" required="yes"/>
        <xsl:param name="row-type" required="yes"/>
        
        <xsl:choose>
            
            <xsl:when test="/m:response/m:translation">
                <div>
                    
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
                            <xsl:if test="count(preceding-sibling::tei:*) eq 0">
                                <xsl:value-of select="'first-child'"/>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <!-- Set nearest id -->
                    <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))]">
                        <xsl:variable name="nearest-milestone" select="preceding-sibling::tei:milestone[@xml:id][1]"/>
                        <xsl:if test="$nearest-milestone">
                            <xsl:attribute name="data-passage-id" select="$nearest-milestone/@xml:id"/>
                        </xsl:if>
                    </xsl:if>
                    
                    <!-- If there's a milestone add a gutter and put the milestone in it -->
                    <xsl:if test="$milestone">
                        
                        <xsl:variable name="milestones-cache-milestone" select="key('milestones-cache-milestone', $milestone/@xml:id)[1]"/>
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
                                            <xsl:with-param name="bookmark-target-part" select="$milestone/@xml:id"/>
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
                    
                </div>
                
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:sequence select="$content"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Temporary id - used to locate serach results -->
    <xsl:template name="tid">
        <xsl:param name="node" required="yes"/>
        
        <xsl:variable name="id" select="concat('node-', $node/@tid)"/>
        
        <!-- If a temporary id is present then set the id -->
        <xsl:if test="$view-mode[not(@client = ('ebook', 'app'))] and $node[@tid]">
            <xsl:choose>
                
                <!-- A translation -->
                <xsl:when test="/m:response/m:translation">
                    
                    <xsl:attribute name="id" select="$id"/>
                    
                    <xsl:if test="$view-mode[@glossary = ('defer', 'defer-no-cache')] and m:glossarize-context($node) and not(self::tei:head)">
                        <xsl:variable name="request-view-mode" select="if($view-mode[@glossary = ('defer')]) then 'passage' else 'passage-no-cache'"/>
                        <xsl:attribute name="data-in-view-replace" select="concat('/translation/', $toh-key, '.html', '?part=', $id, m:view-mode-parameter($request-view-mode), m:archive-path-parameter(), '#', $id)"/>
                    </xsl:if>
                    
                </xsl:when>
                
                <!-- If we are rendering a section then the id may refer to a text in that section rather than the section itself -->
                <xsl:when test="/m:response/m:section">
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
    
    <!-- Table of Contents - html rendering -->
    <xsl:template name="table-of-contents">
        
        <aside id="toc" class="page page-force">
            
            <hr class="hidden-print"/>
            
            <div class="rw rw-section-head">
                <div class="gtr">
                    <xsl:call-template name="bookmark-link">
                        <xsl:with-param name="bookmark-target-hash" select="'toc'"/>
                        <xsl:with-param name="bookmark-label">
                            <xsl:call-template name="bookmark-label">
                                <xsl:with-param name="prefix" select="'co'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
                <div class="rw-heading heading-section chapter">
                    <div>
                        <h2>
                            <xsl:value-of select="'Table of Contents'"/>
                        </h2>
                    </div>
                </div>
            </div>
            
            <div class="rw">
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
                            <xsl:with-param name="parts" select="/m:response/m:translation/m:part"/>
                            <xsl:with-param name="doc-type" select="'html'"/>
                        </xsl:call-template>
                        
                    </tbody>
                </table>
            </div>
            
        </aside>
        
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
                        <xsl:when test="$part/tei:head[@type eq $part/@type][text()]">
                            <li>
                                <a>
                                    
                                    <xsl:variable name="page" select="$part/ancestor-or-self::m:part[@id][@nesting eq '0'][1]/@id"/>
                                    <xsl:variable name="anchor" select="if($part[not(@nesting eq '0') and not(@id = ('translation', 'appendix'))]) then concat('#', $part/@id) else ''"/>
                                    <xsl:attribute name="href" select="concat($page, '.xhtml', $anchor)"/>
                                    
                                    <xsl:if test="$part[@type eq 'chapter'][@prefix]">
                                        <xsl:value-of select="concat($part/@prefix, '. ')"/>
                                    </xsl:if>
                                    
                                    <xsl:apply-templates select="$part/tei:head[@type eq $part/@type]/text()"/>
                                    
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
                        <xsl:when test="$part/tei:head[@type eq $part/@type][text()]">
                            <navPoint xmlns="http://www.daisy.org/z3986/2005/ncx/">
                                
                                <xsl:attribute name="id" select="$part/@id"/>
                                <xsl:variable name="page" select="$part/ancestor-or-self::m:part[@id][@nesting eq '0'][1]/@id"/>
                                <xsl:variable name="anchor" select="if($part[not(@nesting eq '0') and not(@id = ('translation', 'appendix'))]) then concat('#', $part/@id) else ''"/>
                                
                                <navLabel>
                                    <text>
                                        <xsl:apply-templates select="$part/tei:head[@type eq $part/@type]/text()"/>
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
                    <xsl:if test="$part/tei:head[@type eq $part/@type][text()]">
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
                                    
                                    <xsl:apply-templates select="$part/tei:head[@type eq $part/@type][1]/text()"/>
                                    
                                </a>
                            </td>
                        </tr>
                    </xsl:if>
                    
                    <xsl:choose>
                        
                        <!-- Create an expandable block for sub-sections -->
                        <xsl:when test="$sub-parts/tei:head[text()]">
                            
                            <xsl:variable name="count-chapters" select="count($sub-parts[@type eq 'chapter'])"/>
                            <xsl:variable name="count-sections" select="count($sub-parts[tei:head[text()]])"/>
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
        <xsl:variable name="css-classes" as="xs:string*">
            <xsl:if test="count($base-classes[normalize-space()]) gt 0">
                <xsl:value-of select="string-join($base-classes[normalize-space()], ' ')"/>
            </xsl:if>
            <xsl:if test="count($html-classes[normalize-space()]) gt 0 and $view-mode[not(@client = ('ebook', 'app'))]">
                <xsl:value-of select="string-join($html-classes[normalize-space()], ' ')"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(common:lang-class($lang))"/>
        </xsl:variable>
        <xsl:if test="count($css-classes[normalize-space()]) gt 0">
            <xsl:attribute name="class" select="string-join($css-classes[normalize-space()], ' ')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="target-element" as="element()?">
        
        <xsl:param name="target-id" as="xs:string"/>
        
        <xsl:variable name="target" select="key('translation-parts', $target-id)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('notes-cache-end-note', $target-id)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('milestones-cache-milestone', $target-id)[1]"/>
        <xsl:variable name="target" select="if($target) then $target else key('glossary-cache-gloss', $target-id)[1]"/>
        
        <xsl:sequence select="$target"/>
        
    </xsl:template>
    
    <xsl:template name="target-element-href">
        
        <xsl:param name="target-element" as="element()"/>
        <xsl:param name="mark-id" as="xs:string?"/>
        
        <xsl:choose>
            
            <xsl:when test="$target-element[self::m:gloss]">
                <xsl:choose>
                    <xsl:when test="$view-mode[@client = ('ebook')]">
                        <xsl:attribute name="href" select="concat('glossary.xhtml#', $target-element/@id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Hash only, so it will be appended to page location on right-click and won't be followed by crawlers -->
                        <xsl:attribute name="href" select="concat('#', $target-element/@id)"/>
                        <xsl:attribute name="data-href-part" select="'glossary'"/>
                        <xsl:if test="$mark-id">
                            <!-- marks a target -->
                            <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $mark-id, '&#34;]')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:end-note]">
                <xsl:choose>
                    <xsl:when test="$view-mode[@client = ('ebook')]">
                        <xsl:attribute name="href" select="concat('end-notes.xhtml#end-note-', $target-element/@id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Hash only, so it will be appended to page location on right-click and won't be followed by crawlers -->
                        <xsl:attribute name="href" select="concat('#end-note-', $target-element/@id)"/>
                        <xsl:attribute name="data-href-part" select="'end-notes'"/>
                        <xsl:if test="$mark-id">
                            <!-- marks a target -->
                            <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $mark-id, '&#34;]')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:milestone]">
                <xsl:choose>
                    <xsl:when test="$view-mode[@client = ('ebook')]">
                        <xsl:attribute name="href" select="concat($target-element/@part-id, '.xhtml#', $target-element/@id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Hash only, so it will be appended to page location on right-click and won't be followed by crawlers -->
                        <xsl:attribute name="href" select="concat('#', $target-element/@id)"/>
                        <xsl:attribute name="data-href-part" select="$target-element/@id"/>
                        <xsl:if test="$mark-id">
                            <!-- marks a target -->
                            <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $mark-id, '&#34;]')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$target-element[self::m:part][@id]">
                <xsl:choose>
                    <xsl:when test="$view-mode[@client = ('ebook')]">
                        <xsl:attribute name="href" select="concat($target-element/@id, '.xhtml#', $target-element/@id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Hash only, so it will be appended to page location on right-click and won't be followed by crawlers -->
                        <xsl:attribute name="href" select="concat('#', $target-element/@id)"/>
                        <xsl:attribute name="data-href-part" select="$target-element/@id"/>
                        <xsl:if test="$mark-id">
                            <!-- marks a target -->
                            <xsl:attribute name="data-mark" select="concat('[data-mark-id=&#34;', $mark-id, '&#34;]')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="target-element-label" as="xs:string?">
        
        <xsl:param name="target-element" as="element()"/>
        
        <xsl:choose>
            
            <!-- The target is a note -->
            <xsl:when test="$target-element[self::m:end-note][@index]">
                <xsl:variable name="part" select="key('translation-parts', 'end-notes')[1]"/>
                <xsl:if test="$part[@prefix]">
                    <xsl:call-template name="bookmark-label">
                        <xsl:with-param name="prefix" select="$part/@prefix"/>
                        <xsl:with-param name="index" select="$target-element/@index"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            
            <!-- The target is a glossary item -->
            <xsl:when test="$target-element[self::m:gloss][@index]">
                <xsl:variable name="part" select="key('translation-parts', 'glossary')[1]"/>
                <xsl:if test="$part[@prefix]">
                    <xsl:call-template name="bookmark-label">
                        <xsl:with-param name="prefix" select="$part/@prefix"/>
                        <xsl:with-param name="index" select="$target-element/@index"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            
            <!-- The target is a milestone -->
            <xsl:when test="$target-element[self::m:milestone][@index]">
                <xsl:variable name="part" select="key('translation-parts', $target-element/@part-id)[1]"/>
                <xsl:if test="$part[@prefix]">
                    <xsl:call-template name="bookmark-label">
                        <xsl:with-param name="prefix" select="$part/@prefix"/>
                        <xsl:with-param name="index" select="$target-element/@index"/>
                    </xsl:call-template>
                </xsl:if>
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
            <!-- Hash only, so it will be appended to page location on right-click and won't be followed by crawlers -->
            <xsl:attribute name="href" select="concat('#', $bookmark-target-hash)"/>
            <xsl:attribute name="data-bookmark" select="string-join((/m:response/m:translation/m:titles/m:title[@xml:lang eq 'en'], if($bookmark-title gt '') then $bookmark-title else $bookmark-label), ' / ')"/>
            <xsl:attribute name="class" select="$link-class"/>
            <xsl:value-of select="$bookmark-label"/>
        </a>
        
    </xsl:template>
    
    <xsl:template name="bookmark-label" as="xs:string">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="index" as="xs:string?"/>
        <xsl:value-of select="concat($prefix, '.', if($index gt '') then concat('­', $index) else '')"/>
    </xsl:template>
    
    <!-- Glossarize an element -->
    <xsl:template name="glossarize-element">
        
        <xsl:param name="element" as="element()"/>
        
        <!-- Find the first matching item -->
        <xsl:variable name="matching-glossary" as="element(tei:gloss)?">
            <xsl:choose>
                
                <!-- Find the first glossary that matches the ref -->
                <xsl:when test="$element/@ref/string() gt ''">
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
                            <xsl:attribute name="href" select="concat('#', $matching-glossary/@xml:id)"/>
                            <xsl:attribute name="data-glossary-id" select="$matching-glossary/@xml:id"/>
                            <xsl:attribute name="data-match-mode" select="'marked'"/>
                            <xsl:attribute name="data-glossary-location">
                                <xsl:call-template name="glossary-location">
                                    <xsl:with-param name="node" select="$element"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <!-- target to be marked -->
                            <xsl:attribute name="data-mark-id" select="$matching-glossary/@xml:id"/>
                            <xsl:attribute name="class" select="'glossary-link pop-up'"/>
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
        
        <xsl:variable name="text-word-count" select="count(tokenize($text-normalized, '\s+'))"/>
        
        <!-- Get a location reference -->
        <xsl:variable name="glossary-location">
            <xsl:call-template name="glossary-location">
                <xsl:with-param name="node" select="$text-node"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="match-complete-data" select="if($text-node/parent::tei:title | $text-node/parent::tei:name) then true() else false()" as="xs:boolean"/>
        
        <!-- Narrow down the glossary items - we don't want to scan them all -->
        <xsl:variable name="match-glossary-items" as="element(tei:gloss)*">
            <xsl:choose>
                
                <!-- Preferably use the cache -->
                <xsl:when test="$view-mode[@glossary eq 'use-cache']">
                    <xsl:variable name="cached-location-gloss-ids" select="key('glossary-cache-location', $glossary-location)/parent::m:gloss/@id" as="xs:string*"/>
                    <xsl:sequence select="$glossary-prioritised[not(@mode eq 'marked')][@xml:id = $cached-location-gloss-ids]"/>
                </xsl:when>
                
                <!-- Which items should we scan for? -->
                <xsl:otherwise>
                    <xsl:for-each select="$glossary-prioritised[not(@mode eq 'marked')]">
                        
                        <xsl:variable name="terms" select="m:glossary-terms-to-match(.)"/>
                        <xsl:variable name="glossary-cache-gloss" select="key('glossary-cache-gloss', @xml:id)[1]"/>
                        
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
                    
                    <xsl:attribute name="href" select="concat('#', $glossary-id)"/>
                    <xsl:attribute name="data-glossary-id" select="$glossary-id"/>
                    <xsl:attribute name="data-match-mode" select="'matched'"/>
                    <xsl:attribute name="data-glossary-location" select="$glossary-location"/>
                    <!-- target to be marked -->
                    <xsl:attribute name="data-mark-id" select="$glossary-id"/>
                    
                    <xsl:call-template name="class-attribute">
                        
                        <xsl:with-param name="base-classes" as="xs:string*">
                            
                            <xsl:value-of select="'glossary-link'"/>
                            
                            <!-- Check if the location is cached and flag it if not -->
                            <xsl:if test="$view-mode[@glossary = ('no-cache', 'defer-no-cache')]">
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
            <xsl:when test="$node/ancestor::tei:*[@xml:id]">
                <xsl:value-of select="$node/ancestor::tei:*[@xml:id][1]/@xml:id"/>
            </xsl:when>
            
            <!-- Look for a nearest milestone -->
            <xsl:when test="$node/ancestor::tei:*/preceding-sibling::tei:milestone[@xml:id]">
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
            
            <xsl:when test="$node[not(ancestor::m:part[@glossarize])]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:function>
    
    <!-- Get relevant terms from gloss -->
    <xsl:function name="m:glossary-terms-to-match" as="xs:string*">
        <xsl:param name="glossary-items" as="element(tei:gloss)*"/>
        <xsl:sequence select="$glossary-items/tei:term[not(@type) or @type eq 'alternative'][not(@xml:lang) or @xml:lang eq 'en'][normalize-space(data())]/data()"/>
    </xsl:function>
    
</xsl:stylesheet>