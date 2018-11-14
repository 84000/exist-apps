<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:exslt="http://exslt.org/common" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    
    <xsl:template name="tabs">
        <xsl:param name="active-tab"/>
        <ul class="nav nav-tabs" role="tablist">
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/index'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="index.html">
                    Summary
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/search'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="search.html?status=none">
                    Search
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sponsors'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sponsors.html">
                    Sponsors
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translators'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translators.html">
                    Translators
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-teams'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-teams.html">
                    Translator Teams
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-institutions'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-institutions.html">
                    Translator Institutions
                </a>
            </li>
            <xsl:if test="$active-tab eq 'operations/edit-text'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text.html?id=', /m:response/m:request/@id)"/>
                        Edit Text
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-sponsors'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', /m:response/m:request/@id)"/>
                        Edit Text Sponsors
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-sponsor'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-sponsor.html?id=', /m:response/m:request/@id)"/>
                        Edit Sponsor
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', /m:response/m:request/@id)"/>
                        Edit Translator
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-team'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', /m:response/m:request/@id)"/>
                        Edit Translator Team
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-institution'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', /m:response/m:request/@id)"/>
                        Edit Translator Institution
                    </a>
                </li>
            </xsl:if>
        </ul>
    </xsl:template>
    
    <xsl:template name="acknowledgements">
        
        <xsl:param name="acknowledgements" required="yes"/>
        <xsl:param name="group" as="xs:string" required="yes"/>
        <xsl:param name="css-class" as="xs:string" required="yes"/>
        <xsl:param name="link-href" as="xs:string" required="yes"/>
        
        <xsl:for-each select="$acknowledgements">
            <xsl:sort select="xs:integer(m:toh/@number)"/>
            <div>
                <xsl:attribute name="class" select="$css-class"/>
                <xsl:if test="$group gt ''">
                    <xsl:attribute name="data-match-height" select="concat('group-', $group)"/>
                </xsl:if>
                <div class="pull-quote">
                    <div class="title top-vertical">
                        <a>
                            <xsl:attribute name="href" select="replace($link-href, '@translation-id', @translation-id)"/>
                            <xsl:value-of select="m:toh/m:full"/> / <xsl:value-of select="m:title"/>
                        </a>
                        <span>
                            <xsl:call-template name="translation-status">
                                <xsl:with-param name="status" select="@translation-status"/>
                            </xsl:call-template>
                        </span>
                    </div>
                    <xsl:apply-templates select="tei:div[@type eq 'acknowledgment']/*"/>
                </div>
            </div>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template name="link-to-top">
        <!-- Link to top of page -->
        <div class="hidden-print">
            <div id="link-to-top-container" class="fixed-btn-container">
                <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                    <i class="fa fa-arrow-up" aria-hidden="true"/>
                </a>
            </div>
        </div>
    </xsl:template>
    
    
    <xsl:function name="m:text-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div>
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:attribute name="value" select="$value"/>
                    <xsl:attribute name="class" select="concat('form-control', ' ', $css-class)"/>
                    <xsl:if test="contains($css-class, 'disabled')">
                        <xsl:attribute name="disabled" select="'disabled'"/>
                    </xsl:if>
                    <xsl:if test="contains($css-class, 'required')">
                        <xsl:attribute name="required" select="'required'"/>
                    </xsl:if>
                </input>
            </div>
        </div>
    </xsl:function>
    
    <xsl:function name="m:text-multiple-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="values"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <xsl:for-each select="$values">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:copy-of select="m:text-input($label, concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="m:text-input('+', concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:copy-of select="m:text-input('+', concat($name, '-', (count($values) + 1)), '', $size, $css-class)"/>
    </xsl:function>
    
    <xsl:function name="m:select-input">
        <!-- $options sequence requires @value and @selected elements -->
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="rows"/>
        <xsl:param name="options"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div class="col-sm-10">
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <select class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:if test="$rows gt 1">
                        <xsl:attribute name="multiple" select="'multiple'"/>
                        <xsl:attribute name="size" select="$rows"/>
                    </xsl:if>
                    <xsl:for-each select="$options">
                        <option>
                            <xsl:attribute name="value" select="@value"/>
                            <xsl:if test="@selected eq 'selected'">
                                <xsl:attribute name="selected" select="@selected"/>
                            </xsl:if>
                            <xsl:value-of select="text()"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:function>
    
    <xsl:function name="m:select-input-name">
        <!-- $options sequence requires m:name or text() and @xml:id or @id elements -->
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="options"/>
        <xsl:param name="selected-id"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div>
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <select class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <option value=""/>
                    <xsl:for-each select="$options">
                        <xsl:variable name="option-id" select="(@xml:id, @id)[1]"/>
                        <option>
                            <xsl:attribute name="value" select="$option-id"/>
                            <xsl:if test="$option-id eq $selected-id">
                                <xsl:attribute name="selected" select="@selected"/>
                            </xsl:if>
                            <xsl:value-of select="m:name"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:function>
    
</xsl:stylesheet>