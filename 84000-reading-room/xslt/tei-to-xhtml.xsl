<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <!-- 
        Converts other tei to xhtml
    -->
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Strip return characters from text -->
    <xsl:template match="text()">
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
    <!-- Strip leading or trailing empty text nodes -->
    <xsl:template match="text()[not(normalize-space())][common:index-of-node(../node(), .) = (1, count(../node()))]">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
    <xsl:template name="class-attribute">
        <xsl:param name="base-classes" as="xs:string*"/>
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:param name="html-classes" as="xs:string*"/>
        <xsl:variable name="css-classes" as="xs:string*">
            <xsl:if test="count($base-classes[normalize-space()]) gt 0">
                <xsl:value-of select="string-join($base-classes[normalize-space()], ' ')"/>
            </xsl:if>
            <xsl:if test="$html-classes gt '' and /m:response/m:request[@doc-type eq 'html']">
                <xsl:value-of select="$html-classes"/>
            </xsl:if>
            <xsl:value-of select="normalize-space(common:lang-class($lang))"/>
        </xsl:variable>
        <xsl:if test="count($css-classes[normalize-space()]) gt 0">
            <xsl:attribute name="class" select="string-join($css-classes[normalize-space()], ' ')"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:title">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'title'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
                <xsl:with-param name="html-classes" select="'glossarize-complete'"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'name'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
                <xsl:with-param name="html-classes" select="'glossarize-complete'"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:mantra">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'mantra'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
                <xsl:with-param name="html-classes" select="'glossarize'"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:term">
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
                            <xsl:value-of select="'match'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="base-classes" select="'foreign'"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
                <xsl:with-param name="html-classes" select="'glossarize'"/>
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
                <xsl:with-param name="html-classes" select="'glossarize'"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:distinct">
        <em>
            <xsl:call-template name="class-attribute">
                <xsl:with-param name="lang" select="@xml:lang"/>
                <xsl:with-param name="html-classes" select="'glossarize'"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:note[@place eq 'end']">
        <a class="footnote-link">
            <xsl:attribute name="id" select="concat('link-to-', @xml:id)"/>
            <xsl:choose>
                <xsl:when test="/m:response/m:request/@doc-type eq 'epub'">
                    <xsl:attribute name="href" select="concat('notes.xhtml#', @xml:id)"/>
                    <xsl:attribute name="epub:type" select="'noteref'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href" select="concat('#', @xml:id)"/>
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" select="'footnote-link'"/>
                        <xsl:with-param name="html-classes" select="'pop-up'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="@index"/>
        </a>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <span class="date">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:gloss">
        <a class="glossary">
            <xsl:attribute name="href" select="concat('#glossary-', @uid)"/>
            <xsl:apply-templates select="text()"/>
        </a>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <!-- Only display visible <ref/>s-->
        <!-- Some <ref/>s have been filtered out in translation-global based on @key -->
        <xsl:if test="(not(@rend) or not(@rend eq 'hidden'))">
            <xsl:choose>
                
                <!-- @cRef designates an encoded (folio) link and will also have been assigned a @ref-index -->
                <xsl:when test="@cRef">
                    <xsl:choose>
                        
                        <!-- If it's html then add a link -->
                        <xsl:when test="/m:response/m:request[@doc-type eq 'html'] and @ref-index">
                            
                            <a class="ref log-click">
                                <!-- define an anchor so we can link back to this point -->
                                <xsl:attribute name="id" select="concat('source-link-', @ref-index)"/>
                                <xsl:attribute name="href" select="concat('/source/', /m:response/m:translation/m:source/@key, '.html?ref-index=', @ref-index, '#ajax-content')"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-source .data-container'"/>
                                <xsl:value-of select="concat('[', @cRef, ']')"/>
                            </a>
                            
                        </xsl:when>
                        
                        <!-- show an absolute link -->
                        <xsl:when test="ancestor::m:expressions[@reading-room-url][@toh-key] and @ref-index">
                            
                            <xsl:variable name="expressions" select="ancestor::m:expressions[@reading-room-url][@toh-key][1]"/>
                            <xsl:variable name="glossary-item" select="$expressions/parent::m:item[1]"/>
                            
                            <a class="ref log-click">
                                <!-- define an anchor so we can link back to this point -->
                                <xsl:attribute name="id" select="concat('source-link-', @ref-index)"/>
                                <xsl:attribute name="href" select="concat($expressions/@reading-room-url, '/source/', $expressions/@toh-key, '.html?ref-index=', @ref-index, '&amp;highlight=', string-join($glossary-item/m:term[@xml:lang eq 'bo'], ','), '#ajax-content')"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-source .data-container'"/>
                                <xsl:value-of select="concat('[', @cRef, ']')"/>
                            </a>
                            
                        </xsl:when>
                        
                        <!-- ...or just output the text. -->
                        <xsl:otherwise>
                            <span class="ref">
                                <xsl:value-of select="concat('[', @cRef, ']')"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <!-- @target designates an external (http) link -->
                <xsl:when test="@target">
                    <a target="_blank">
                        <xsl:attribute name="href">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="text()"/>
                    </a>
                </xsl:when>
                
                <!-- Otherwise just output the text -->
                <xsl:otherwise>
                    <span class="ref">
                        <xsl:apply-templates select="text()"/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:ptr">
        <a class="internal-ref">
            <xsl:choose>
                
                <xsl:when test="/m:response/m:request/@doc-type eq 'epub'">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="@location eq 'chapter'">
                                <xsl:value-of select="concat('chapter-', @chapter-index, '.xhtml', @target)"/>
                            </xsl:when>
                            <xsl:when test="@location gt '' and @target gt '' and not(@location = ('missing'))">
                                <xsl:value-of select="concat(@location, '.xhtml', @target)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@target"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                
                <xsl:when test="/m:response[@model-type eq 'operations/glossary']">
                    <!-- TO DO: point to the Reading Room -->
                    <xsl:attribute name="href" select="@target"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:attribute name="href" select="@target"/>
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" select="'internal-ref'"/>
                        <xsl:with-param name="html-classes" select="'scroll-to-anchor'"/>
                    </xsl:call-template>
                </xsl:otherwise>
                
            </xsl:choose>
            
            <xsl:if test="@location eq 'missing'">
                <xsl:attribute name="href" select="'#'"/>
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="base-classes" select="'internal-ref'"/>
                    <xsl:with-param name="html-classes" select="'disabled'"/>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:apply-templates select="text()"/>
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
                                <xsl:when test="(@rend,@type) = 'mantra'">
                                    <xsl:value-of select="'mantra'"/>
                                </xsl:when>
                                <xsl:when test="self::tei:trailer">
                                    <xsl:value-of select="'trailer'"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="html-classes">
                            <!--<xsl:if test="not(ancestor-or-self::*[@rend = 'ignoreGlossary'])">-->
                                <xsl:value-of select="'glossarize'"/>
                            <!--</xsl:if>-->
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
    
    <xsl:template match="tei:table">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <xsl:apply-templates select="tei:head"/>
                
                <!-- output a table -->
                <div class="table-responsive hidden-print hidden-ebook">
                    <xsl:if test="/m:response/m:request/@view-mode eq 'epub'">
                        <xsl:attribute name="class" select="'table-responsive hidden'"/>
                    </xsl:if>
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
                
                <!-- output a list -->
                <div class="visible-print visible-ebook">
                    <xsl:if test="/m:response/m:request/@view-mode eq 'epub'">
                        <xsl:attribute name="class" select="''"/>
                    </xsl:if>
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
                                    <xsl:copy-of select="."/>
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
                                    <xsl:copy-of select="."/>
                                    <xsl:value-of select="if(position() eq count($datas/*:span)) then '.' else '; '"/>
                                </xsl:for-each>
                            </p>
                        </xsl:for-each>
                    </div>
                </div>
                
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
        <xsl:if test="/m:response/m:request[@doc-type eq 'html']">
            <xsl:if test="@rows">
                <xsl:attribute name="rowspan" select="@rows"/>
            </xsl:if>
            <xsl:if test="@cols">
                <xsl:attribute name="colspan" select="@cols"/>
            </xsl:if>
        </xsl:if>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tei:note[parent::tei:table]">
        <p>
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>
    
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
    
    <xsl:template match="tei:list[tei:item]">
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
    
    <xsl:template match="tei:item[parent::tei:list]">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div class="list-item">
                    <xsl:attribute name="class">
                        <xsl:variable name="node-index" select="common:index-of-node(parent::tei:list/tei:item, .)"/>
                        <xsl:value-of select="'list-item'"/>
                        <xsl:if test="$node-index eq 1">
                            <xsl:value-of select="' list-item-first'"/>
                        </xsl:if>
                        <xsl:if test="$node-index eq count(parent::tei:list/tei:item)">
                            <xsl:value-of select="' list-item-last'"/>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'list-item'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:lg">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    <!-- id -->
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
                    <xsl:apply-templates select="node()"/>
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'line-group'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:l(:[parent::tei:lg]:)">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div>
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" select="'line'"/>
                        <xsl:with-param name="html-classes" select="'glossarize'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="node()"/>
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'line'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <xsl:choose>
            
            <!-- A list header -->
            <xsl:when test="parent::tei:list">
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
            </xsl:when>
            
            <!-- A table header -->
            <xsl:when test="parent::tei:table">
                <h5 class="table-label">
                    <xsl:call-template name="tid">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    <xsl:apply-templates select="node()"/>
                </h5>
            </xsl:when>
            
            <!-- An about section header -->
            <xsl:when test="@type = ('about')">
                <h1 class="text-center">
                    <xsl:apply-templates select="node()"/>
                </h1>
            </xsl:when>
            
            <!-- A chapter header -->
            <xsl:when test="@type = ('chapterTitle')">
                <xsl:call-template name="milestone">
                    <xsl:with-param name="content">
                        <div class="rw-heading">
                            <xsl:call-template name="tid">
                                <xsl:with-param name="node" select="."/>
                            </xsl:call-template>
                            <h2>
                                <xsl:apply-templates select="node()"/>
                            </h2>
                        </div>
                    </xsl:with-param>
                    <xsl:with-param name="row-type" select="'chapter-title'"/>
                </xsl:call-template>
            </xsl:when>
            
            <!-- A section header -->
            <xsl:when test="@type = ('chapter', 'section')">
                <xsl:call-template name="milestone">
                    <xsl:with-param name="content">
                        <div>
                            <xsl:call-template name="tid">
                                <xsl:with-param name="node" select="."/>
                            </xsl:call-template>
                            <xsl:call-template name="class-attribute">
                                <xsl:with-param name="base-classes" as="xs:string*">
                                    <xsl:value-of select="'rw-heading'"/>
                                    <xsl:if test="@type">
                                        <xsl:value-of select="concat('heading-', @type)"/>
                                    </xsl:if>
                                    <xsl:if test="ancestor::tei:div[1]/@nesting">
                                        <xsl:value-of select="concat('nesting-', ancestor::tei:div[1]/@nesting)"/>
                                    </xsl:if>
                                </xsl:with-param>
                            </xsl:call-template>
                            <h4>
                                <xsl:if test="@type eq 'chapter'">
                                    <xsl:attribute name="class" select="'chapter-number'"/>
                                </xsl:if>
                                <xsl:apply-templates select="node()"/>
                            </h4>
                        </div>
                    </xsl:with-param>
                    <xsl:with-param name="row-type" select="concat(@type, '-head')"/>
                </xsl:call-template>
            </xsl:when>
            
        </xsl:choose>
    </xsl:template>
    
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
        <xsl:copy-of select="translate(lower-case(text()), 'abcdefghijklmnopqrstuvwxyz', 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ')"/>
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:match">
        <span class="underline">
            <xsl:attribute name="data-glossary-id" select="@glossary-id"/>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <!-- Nested Sections -->
    <xsl:template match="tei:div[@type = ('section', 'chapter')]">
        <!-- Wrap in a div -->
        <div>
            <!-- Set the id -->
            <xsl:if test="@section-id">
                <xsl:attribute name="id" select="concat('section-', @section-id)"/>
            </xsl:if>
            <!-- Set the class -->
            <xsl:attribute name="class" select="concat('nested-', @type)"/>
            <!-- If the child is another div it will recurse -->
            <xsl:apply-templates select="tei:*"/>
        </div>
    </xsl:template>
    
    <!-- Bibliography -->
    <xsl:template match="m:section[ancestor::m:bibliography]">
        <div>
            <xsl:if test="m:title/text()">
                <h5 class="section-label">
                    <xsl:apply-templates select="m:title/text()"/>
                </h5>
            </xsl:if>
            <xsl:for-each select="m:item">
                <p>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:apply-templates select="node()"/>
                </p>
            </xsl:for-each>
            <xsl:apply-templates select="m:section"/>
        </div>
    </xsl:template>
    
    <!-- Glossary item -->
    <xsl:template match="m:glossary/m:item">
        <div class="glossary-item rw">
            
            <xsl:attribute name="id" select="@uid/string()"/>
            <xsl:attribute name="data-match" select="if(@mode/string() eq 'marked') then 'marked' else 'match'"/>
            
            <div class="gtr">
                <xsl:choose>
                    
                    <xsl:when test="/m:response/m:request[@doc-type eq 'html']">
                        
                        <a class="milestone" title="Bookmark this section">
                            <xsl:attribute name="href" select="concat('#', @uid/string())"/>
                            <xsl:value-of select="concat(parent::m:glossary/@prefix, '.', @index)"/>
                        </a>
                        
                    </xsl:when>
                    
                    <xsl:when test="ancestor::m:expressions[@reading-room-url][@toh-key]">
                        
                        <xsl:variable name="expressions" select="ancestor::m:expressions[@reading-room-url][@toh-key][1]"/>
                        
                        <a target="reading-room">
                            <xsl:attribute name="href" select="concat($expressions/@reading-room-url, '/translation/', $expressions/@toh-key, '.html#', @uid/string())"/>
                            <xsl:value-of select="concat(parent::m:glossary/@prefix, '.', @index)"/>
                        </a>
                        
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="concat(parent::m:glossary/@prefix, '.', @index)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            
            <div class="row">
                
                <div class="col-md-12 print-width-override print-height-override">
                    
                    <xsl:if test="/m:response/m:request[@doc-type eq 'html']">
                        <xsl:attribute name="class" select="'col-md-8 match-this-height print-width-override print-height-override'"/>
                    </xsl:if>
                    
                    <xsl:attribute name="data-match-height" select="concat('gloss-', @index)"/>
                    <xsl:attribute name="data-match-height-media" select="'.md,.lg'"/>
                    
                    <h4 class="term">
                        <xsl:apply-templates select="m:term[lower-case(@xml:lang) = 'en']"/>
                    </h4>
                    <xsl:if test="m:term[@xml:lang eq 'bo-ltn']">
                        <p class="text-wy">
                            <xsl:value-of select="string-join(m:term[@xml:lang eq 'bo-ltn'], ' · ')"/>
                        </p>
                    </xsl:if>
                    <xsl:if test="m:term[@xml:lang eq 'bo']">
                        <p class="text-bo">
                            <xsl:value-of select="string-join(m:term[@xml:lang eq 'bo'], ' · ')"/>
                        </p>
                    </xsl:if>
                    <xsl:if test="m:term[@xml:lang eq 'sa-ltn']">
                        <p class="text-sa">
                            <xsl:value-of select="string-join(m:term[@xml:lang eq 'sa-ltn'], ' · ')"/>
                        </p>
                    </xsl:if>
                    <xsl:for-each select="m:alternative">
                        <p class="term alternative">
                            <xsl:apply-templates select="text()"/>
                        </p>
                    </xsl:for-each>
                    <xsl:for-each select="m:definition">
                        <p>
                            <xsl:call-template name="class-attribute">
                                <xsl:with-param name="base-classes" select="'definition'"/>
                                <xsl:with-param name="html-classes" select="'glossarize'"/>
                            </xsl:call-template>
                            <xsl:apply-templates select="node()"/>
                        </p>
                    </xsl:for-each>
                    
                </div>
                
                <xsl:if test="/m:response/m:request[@doc-type eq 'html']">
                    <div class="col-md-4 occurences hidden-print match-height-overflow print-height-override">
                        <xsl:attribute name="data-match-height" select="concat('gloss-', @index)"/>
                        <xsl:attribute name="data-match-height-media" select="'.md,.lg'"/>
                        <hr class="visible-xs-block visible-sm-block"/>
                        <h6>
                            <xsl:value-of select="'Finding passages containing this term...'"/>
                        </h6>
                    </div>
                </xsl:if>
                
            </div>
            
        </div>
        
    </xsl:template>
    
    <!-- End notes -->
    <xsl:template match="m:notes/m:note">
        <div class="footnote rw">
            <xsl:attribute name="id" select="@uid"/>
            <div class="gtr">
                
                <xsl:choose>
                    
                    <xsl:when test="/m:response/m:request[@doc-type eq 'html']">
                        <a class="scroll-to-anchor footnote-number">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('#link-to-', @uid)"/>
                            </xsl:attribute>
                            <xsl:attribute name="data-mark">
                                <xsl:value-of select="concat('#link-to-', @uid)"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat(parent::m:notes/@prefix, '.', @index)"/>
                        </a>
                    </xsl:when>
                    
                    <xsl:when test="ancestor::m:expressions[@reading-room-url][@toh-key]">
                        
                        <xsl:variable name="expressions" select="ancestor::m:expressions[@reading-room-url][@toh-key][1]"/>
                        
                        <a target="reading-room">
                            <xsl:attribute name="href" select="concat($expressions/@reading-room-url, '/translation/', $expressions/@toh-key, '.html#', @uid/string())"/>
                            <xsl:value-of select="concat(parent::m:notes/@prefix, '.', @index)"/>
                        </a>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="concat(parent::m:notes/@prefix, '.', @index)"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </div>
            <div class="glossarize">
                <xsl:apply-templates select="node()"/>
            </div>
        </div>
    </xsl:template>
    
    <!-- Temporary id -->
    <xsl:template name="tid">
        <xsl:param name="node" required="yes"/>
        <!-- If a temporary id is present then set the id -->
        <xsl:if test="/m:response/m:request[@doc-type eq 'html'] and $node/@tid">
            <xsl:choose>
                
                <!-- A translation -->
                <xsl:when test="/m:response/m:translation">
                    <xsl:attribute name="id" select="concat('node-', $node/@tid)"/>
                </xsl:when>
                
                <!-- If we are rendering a section then the id may refer to a text in that section rather than the section itself -->
                <xsl:when test="/m:response/m:section">
                    <xsl:choose>
                        <xsl:when test="ancestor::m:text">
                            <xsl:attribute name="id" select="concat($node/ancestor::m:text/@resource-id, '-node-', $node/@tid)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id" select="concat('node-', $node/@tid)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!-- Milestone -->
    <xsl:template name="milestone">
        
        <xsl:param name="content" required="yes"/>
        <xsl:param name="row-type" required="yes"/>
        
        <xsl:choose>
            <xsl:when test="/m:response/m:translation | ancestor::m:expressions">
                <div class="rw">
                    
                    <!-- Set the class -->
                    <xsl:attribute name="class">
                        <xsl:variable name="node-index" select="common:index-of-node(../., .)"/>
                        <xsl:value-of select="'rw'"/>
                        <xsl:value-of select="concat(' rw-', $row-type)"/>
                        <xsl:if test="$node-index eq 1">
                            <xsl:value-of select="' first-child'"/>
                        </xsl:if>
                        <xsl:if test="$node-index eq count(../.)">
                            <xsl:value-of select="' last-child'"/>
                        </xsl:if>
                    </xsl:attribute>
                    
                    <!-- 
                        Select the milestone node
                        1. The element is preceded by a milestone
                        2. The element is preceded by an lb and a milestones precedes that
                        3. The parent node is a seg preceded by a milestone
                        4. The parent node is a seg preceded by an lb preceded by a milestone
                    -->
                    <xsl:variable name="milestone" select="preceding-sibling::*[1][self::tei:milestone] | preceding-sibling::*[2][self::tei:milestone[following-sibling::*[1][self::tei:lb]]] | parent::tei:seg/preceding-sibling::*[1][self::tei:milestone] | parent::tei:seg/preceding-sibling::*[2][self::tei:milestone[following-sibling::*[1][self::tei:lb]]]"/>
                    
                    <!-- If there's a milestone add a gutter and put the milestone in it -->
                    <xsl:if test="$milestone/@xml:id">
                        <div class="gtr">
                            <xsl:choose>
                                
                                <!-- show a relative link -->
                                <xsl:when test="/m:response/m:request[@doc-type eq 'html']">
                                    <a class="milestone from-tei" title="Bookmark this section">
                                        <xsl:attribute name="href" select="concat('#', $milestone/@xml:id)"/>
                                        <xsl:attribute name="id" select="$milestone/@xml:id"/>
                                        <xsl:value-of select="$milestone/@label"/>
                                    </a>
                                </xsl:when>
                                
                                <!-- show an absolute link -->
                                <xsl:when test="ancestor::m:expressions[@reading-room-url][@toh-key]">
                                    
                                    <xsl:variable name="expressions" select="ancestor::m:expressions[@reading-room-url][@toh-key][1]"/>
                                    
                                    <a target="reading-room" title="Go to this section">
                                        <xsl:attribute name="href" select="concat($expressions/@reading-room-url, '/translation/', $expressions/@toh-key,'.html#', $milestone/@xml:id)"/>
                                        <xsl:attribute name="id" select="$milestone/@xml:id"/>
                                        <xsl:value-of select="$milestone/@label"/>
                                    </a>
                                </xsl:when>
                                
                                <!-- or just the text -->
                                <xsl:otherwise>
                                    <xsl:attribute name="id" select="$milestone/@xml:id"/>
                                    <xsl:value-of select="$milestone/@label"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                        </div>
                    </xsl:if>
                    
                    <!-- Output the content -->
                    <xsl:copy-of select="$content"/>
                    
                </div>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:copy-of select="$content"/>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <!-- Chapter title -->
    <xsl:template name="chapter-title">
        <xsl:param name="chapter-index" required="yes"/>
        <xsl:param name="prefix" required="yes"/>
        <xsl:param name="title" required="yes"/>
        <xsl:param name="title-number" required="yes"/>
        <div class="rw rw-chapter-title">
            <div class="gtr">
                <xsl:choose>
                    
                    <!-- show a link -->
                    <xsl:when test="/m:response/m:request[@doc-type eq 'html']">
                        <a class="milestone milestone-h4" title="Bookmark this section">
                            <xsl:attribute name="href" select="concat('#chapter-', $prefix)"/>
                            <xsl:value-of select="concat($prefix, '.')"/>
                        </a>
                    </xsl:when>
                    
                    <!-- or just the text -->
                    <xsl:otherwise>
                        <xsl:value-of select="concat($prefix, '.')"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
            </div>
            <div class="rw-heading">
                <xsl:choose>
                    
                    <xsl:when test="$title-number/text() and not($title/text())">
                        <xsl:if test="$title-number/text()">
                            <h2 class="chapter-number">
                                <xsl:call-template name="tid">
                                    <xsl:with-param name="node" select="$title-number"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="$title-number/text()"/>
                            </h2>
                        </xsl:if>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        
                        <xsl:if test="$title-number/text()">
                            <h4 class="chapter-number">
                                <xsl:call-template name="tid">
                                    <xsl:with-param name="node" select="$title-number"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="$title-number/text()"/>
                            </h4>
                        </xsl:if>
                        
                        <xsl:if test="$title/text()">
                            <h2>
                                <xsl:call-template name="tid">
                                    <xsl:with-param name="node" select="$title"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="$title/text()"/>
                            </h2>
                        </xsl:if>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>
    
    <!-- Section title -->
    <xsl:template name="section-title">
        <xsl:param name="bookmark-id" required="yes"/>
        <xsl:param name="prefix" required="yes"/>
        <xsl:param name="title" required="yes"/>
        <xsl:param name="title-tag" select="'h3'" required="no"/>
        <xsl:param name="title-id"/>
        
        <div class="rw rw-section-title">
            <div class="gtr">
                
                <xsl:choose>
                    
                    <!-- show a link -->
                    <xsl:when test="/m:response/m:request[@doc-type eq 'html']">
                        <a title="Bookmark this section">
                            <xsl:attribute name="href" select="concat('#', $bookmark-id)"/>
                            <xsl:attribute name="class" select="concat('milestone', ' milestone-', $title-tag)"/>
                            <xsl:value-of select="concat($prefix, '.')"/>
                        </a>
                    </xsl:when>
                    
                    <!-- or just the text -->
                    <xsl:otherwise>
                        <xsl:value-of select="concat($prefix, '.')"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </div>
            <div class="rw-heading">
                
                <xsl:if test="$title-id">
                    <xsl:attribute name="id" select="concat('node-', $title-id)"/>
                </xsl:if>
                
                <xsl:choose>
                    <xsl:when test="$title-tag eq 'h2'">
                        <h2>
                            <xsl:value-of select="$title"/>
                        </h2>
                    </xsl:when>
                    <xsl:when test="$title-tag eq 'h4'">
                        <h4>
                            <xsl:value-of select="$title"/>
                        </h4>
                    </xsl:when>
                    <xsl:otherwise>
                        <h3>
                            <xsl:value-of select="$title"/>
                        </h3>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
        </div>
    </xsl:template>
    
    <!-- Abbreviations -->
    <xsl:template name="abbreviations">
        <xsl:param name="translation" required="yes"/>
        <!-- Abbreviations may have multiple sections -->
        <xsl:for-each select="$translation/m:abbreviations/*">
            <xsl:call-template name="abbreviations-section">
                <xsl:with-param name="section" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="abbreviations-section">
        <xsl:param name="section" required="yes"/>
        <xsl:choose>
            
            <!-- If it's a section then output a title and recurse -->
            <xsl:when test="local-name($section) eq 'section'">
                <div class="nested-section">
                    <xsl:for-each select="$section/m:title">
                        <h4 class="section-label">
                            <xsl:apply-templates select="node()"/>
                        </h4>
                    </xsl:for-each>
                    <xsl:for-each select="$section/m:section | $section/m:list">
                        <xsl:call-template name="abbreviations-section">
                            <xsl:with-param name="section" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            
            <!-- If it's a list output a table with headers and footers -->
            <xsl:when test="local-name($section) eq 'list'">
                <xsl:for-each select="$section/m:head[not(lower-case(text()) = ('abbreviations', 'abbreviations:'))]">
                    <h5>
                        <xsl:apply-templates select="node()"/>
                    </h5>
                </xsl:for-each>
                <xsl:for-each select="$section/m:description">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
                <table class="table">
                    <tbody>
                        <xsl:for-each select="$section/m:item">
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
                <xsl:for-each select="$section/m:foot">
                    <p>
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:for-each>
            </xsl:when>
            
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template name="expandable-toh">
        <xsl:param name="toh" required="yes" as="element(m:toh)"/>
        <xsl:choose>
            <xsl:when test="$toh/m:duplicates">
                <xsl:variable name="expand-id" select="concat('expand-toh-', $toh/@key)"/>
                <a role="button" data-toggle="collapse" aria-expanded="true" class="collapsed nowrap">
                    <xsl:attribute name="href" select="concat('#', $expand-id)"/>
                    <xsl:attribute name="aria-controls" select="$expand-id"/>
                    <xsl:value-of select="$toh/m:full"/>
                    <span class="collapsed-show">
                        <span class="monospace">+</span>
                    </span>
                </a>
                <div class="collapse print-expand">
                    <xsl:attribute name="id" select="$expand-id"/>
                    <xsl:for-each select="$toh/m:duplicates/m:duplicate">
                        <span class="nowrap">
                            <xsl:value-of select="normalize-space(concat(' / ', m:full/text()))"/>
                        </span>
                        <br/>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <span class="nowrap">
                    <xsl:value-of select="$toh/m:full"/>
                </span>
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
    
</xsl:stylesheet>