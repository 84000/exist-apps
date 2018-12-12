<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <!-- 
        Converts other tei to xhtml
    -->
    
    <xsl:import href="functions.xsl"/>
    
    <xsl:template match="text()">
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
    <xsl:template match="tei:title">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat(normalize-space(common:lang-class(@xml:lang)), ' glossarize-complete', ' title')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('name ', normalize-space(common:lang-class(@xml:lang)), ' glossarize-complete')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:term">
        <span>
            <xsl:choose>
                <xsl:when test="@type eq 'ignore'">
                    <xsl:attribute name="class" select="'ignore'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class" select="'term'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat(normalize-space(common:lang-class(@xml:lang)), ' glossarize', ' foreign')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:emph">
        <em>
            <xsl:attribute name="class">
                <xsl:value-of select="concat(normalize-space(common:lang-class(@xml:lang)), ' glossarize', if(@rend eq 'bold') then ' text-bold' else '')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:distinct">
        <em>
            <xsl:attribute name="class">
                <xsl:value-of select="concat(normalize-space(common:lang-class(@xml:lang)), ' glossarize')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:note">
        <a class="footnote-link">
            <xsl:attribute name="id" select="concat('link-to-', @xml:id)"/>
            <xsl:choose>
                <xsl:when test="/m:response/m:request/@doc-type eq 'epub'">
                    <xsl:attribute name="href" select="concat('notes.xhtml#', @xml:id)"/>
                    <xsl:attribute name="epub:type" select="'noteref'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href" select="concat('#', @xml:id)"/>
                    <xsl:attribute name="class" select="'footnote-link pop-up'"/>
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
        <xsl:if test="(not(@rend) or not(@rend eq 'hidden')) and (not(@key) or @key eq /m:response/m:translation/m:source/@key)">
            <xsl:choose>
                <xsl:when test="@cRef">
                    <xsl:variable name="volume" select="/m:response/m:translation/m:source/m:location/m:start/@volume"/>
                    <xsl:variable name="folio" select="substring-after(lower-case(@cRef), 'f.')"/>
                    <xsl:variable name="anchor" select="common:folio-id(@cRef)"/>
                    <xsl:choose>
                        <!-- Conditions for creating a link... -->
                        <xsl:when test="not(@type) and /m:response/m:request/@doc-type ne 'epub' and $volume and $folio">
                            <a class="ref log-click">
                                <xsl:attribute name="id" select="$anchor"/>
                                <xsl:attribute name="href" select="concat('/source/', /m:response/m:translation/m:source/@key, '.html?folio=', $folio, '&amp;anchor=', $anchor)"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-source .data-container'"/>
                                [<xsl:apply-templates select="@cRef"/>]</a>
                        </xsl:when>
                        <!-- ...or just output the text. -->
                        <xsl:otherwise>
                            <span class="ref">[<xsl:apply-templates select="@cRef"/>]</span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
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
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@location, '.xhtml', @target)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="href" select="@target"/>
                    <xsl:attribute name="class" select="'internal-ref scroll-to-anchor'"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="@location eq 'missing'">
                <xsl:attribute name="href" select="'#'"/>
                <xsl:attribute name="class" select="'internal-ref disabled'"/>
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
                    <xsl:attribute name="class" select="string-join(('glossarize', if(self::tei:ab[@type = 'mantra']) then 'mantra' else '', if(self::tei:trailer) then 'trailer' else ''), ' ')"/>
                    <xsl:apply-templates select="node()"/>
                </p>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="if(self::tei:ab[@type = 'mantra']) then 'mantra' else if(self::tei:trailer) then 'trailer' else 'paragraph'"/>
        </xsl:call-template>
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
                    <xsl:attribute name="class" select="concat('list', if(parent::tei:item) then ' list-sublist' else '', if(@type eq 'section') then ' list-section' else ' list-bullet', concat(' nesting-', count(ancestor::tei:list[not(@type eq 'section')])) )"/>
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
                    <xsl:attribute name="class" select="concat( 'list-item', if(common:index-of-node(parent::tei:list/tei:item, .) eq 1) then ' list-item-first' else '', if(common:index-of-node(parent::tei:list/tei:item, .) = count(parent::tei:list/tei:item)) then ' list-item-last' else '' )"/>
                    <xsl:apply-templates select="node()"/>
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'list-item'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:lg">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div class="line-group">
                    <!-- id -->
                    <xsl:call-template name="tid">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                    <xsl:if test="@type = ('sdom', 'bar_sdom', 'spyi_sdom')">
                        <xsl:attribute name="class" select="'line-group italic'"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()"/>
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'line-group'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:l[parent::tei:lg]">
        <xsl:call-template name="milestone">
            <xsl:with-param name="content">
                <div class="line">
                    <xsl:if test="/m:response/m:request/@doc-type ne 'epub'">
                        <xsl:attribute name="class" select="'line glossarize'"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()"/>
                </div>
            </xsl:with-param>
            <xsl:with-param name="row-type" select="'line'"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <xsl:choose>
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
            <xsl:when test="@type = ('about')">
                <h1 class="text-center">
                    <xsl:value-of select="text()"/>
                </h1>
            </xsl:when>
            <xsl:when test="@type = ('chapterTitle')">
                <xsl:call-template name="milestone">
                    <xsl:with-param name="content">
                        <div class="rw-heading">
                            <xsl:call-template name="tid">
                                <xsl:with-param name="node" select="."/>
                            </xsl:call-template>
                            <h2>
                                <xsl:value-of select="text()"/>
                            </h2>
                        </div>
                    </xsl:with-param>
                    <xsl:with-param name="row-type" select="'chapter-title'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@type = ('chapter', 'section')">
                <xsl:call-template name="milestone">
                    <xsl:with-param name="content">
                        <div>
                            <xsl:call-template name="tid">
                                <xsl:with-param name="node" select="."/>
                            </xsl:call-template>
                            <xsl:attribute name="class" select="concat('rw-heading heading-', @type, ' nesting-', ancestor::tei:div[1]/@nesting)"/>
                            <h4>
                                <xsl:if test="@type eq 'chapter'">
                                    <xsl:attribute name="class" select="'chapter-number'"/>
                                </xsl:if>
                                <xsl:value-of select="text()"/>
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
    
    <xsl:template match="tei:hi[@rend eq 'small-caps']">
        <xsl:copy-of select="translate(text(), 'abcdefghijklmnopqrstuvwxyz', 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ')"/>
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <!-- Temporary id -->
    <xsl:template name="tid">
        <xsl:param name="node" required="yes"/>
        <xsl:if test="$node/@tid">
            <xsl:choose>
                <xsl:when test="/m:response/m:translation">
                    <xsl:attribute name="id" select="concat('node-', $node/@tid)"/>
                </xsl:when>
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
            <xsl:when test="/m:response/m:translation">
                <div class="rw">
                    
                    <xsl:attribute name="class" select="string-join(('rw', concat('rw-', $row-type), if(common:index-of-node(../., .) eq 1) then 'first-child' else '', if(common:index-of-node(../., .) eq count(../.)) then 'last-child' else ''), ' ')"/>
                    
                    <xsl:variable name="milestone" select="preceding-sibling::*[1][self::tei:milestone] | preceding-sibling::*[2][self::tei:milestone[following-sibling::*[1][self::tei:lb]]]"/>
                    
                    <!-- Add a gutter is there's a milestone -->
                    <xsl:if test="$milestone/@xml:id">
                        <div class="gtr">
                            <xsl:choose>
                                <xsl:when test="/m:response/m:request/@doc-type ne 'epub'">
                                    <a class="milestone from-tei" title="Bookmark this section">
                                        <xsl:attribute name="href" select="concat('#', $milestone/@xml:id)"/>
                                        <xsl:attribute name="id" select="$milestone/@xml:id"/>
                                        <xsl:value-of select="$milestone/@label"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="id" select="$milestone/@xml:id"/>
                                    <xsl:value-of select="$milestone/@label"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:if>
                    
                    <xsl:copy-of select="$content"/>
                    
                </div>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:copy-of select="$content"/>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Nested Sections -->
    <xsl:template match="tei:div[@type = ('section', 'chapter')]">
        <div>
            <xsl:if test="@section-id">
                <xsl:attribute name="id" select="concat('section-', @section-id)"/>
            </xsl:if>
            <xsl:attribute name="class" select="concat('nested-', @type)"/>
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
    
    <!-- Abbreviations -->
    <xsl:template name="abbreviations">
        <!-- Called in epubs and RR -->
        <xsl:param name="translation" required="yes"/>
        <xsl:for-each select="$translation/m:abbreviations/*">
            <xsl:call-template name="abbreviations-section">
                <xsl:with-param name="section" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="abbreviations-section">
        <xsl:param name="section" required="yes"/>
        <xsl:choose>
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
    
    <!-- Glossary item -->
    <xsl:template name="glossary-item">
        <!-- Called in epubs and RR -->
        <xsl:param name="glossary-item" required="yes"/>
        <h4 class="term">
            <xsl:apply-templates select="m:term[lower-case(@xml:lang) = 'en']"/>
        </h4>
        <xsl:if test="$glossary-item/m:term[lower-case(@xml:lang) eq 'bo-ltn']">
            <p class="text-wy">
                <xsl:value-of select="string-join($glossary-item/m:term[lower-case(@xml:lang) eq 'bo-ltn'], ' · ')"/>
            </p>
        </xsl:if>
        <xsl:if test="$glossary-item/m:term[lower-case(@xml:lang) eq 'bo']">
            <p class="text-bo">
                <xsl:value-of select="string-join($glossary-item/m:term[lower-case(@xml:lang) eq 'bo'], ' · ')"/>
            </p>
        </xsl:if>
        <xsl:if test="$glossary-item/m:term[lower-case(@xml:lang) eq 'sa-ltn']">
            <p class="text-sa">
                <xsl:value-of select="string-join($glossary-item/m:term[lower-case(@xml:lang) eq 'sa-ltn'], ' · ')"/>
            </p>
        </xsl:if>
        <xsl:for-each select="$glossary-item/m:alternative">
            <p class="term alternative">
                <xsl:apply-templates select="text()"/>
            </p>
        </xsl:for-each>
        <xsl:for-each select="$glossary-item/m:definition">
            <p class="definition glossarize">
                <xsl:apply-templates select="node()"/>
            </p>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>