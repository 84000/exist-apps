<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="tabs.xsl"/>
    <xsl:template match="/m:response">
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold hidden-print center-vertical">
                        <span class="title">
                            <xsl:value-of select="'84000 Utilities'"/>
                        </span>
                        <span class="text-right">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                <xsl:value-of select="'Reading Room'"/>
                            </a>
                        </span>
                    </div>
                    <div class="panel-body">
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        <div class="tab-content">
                            <div class="row">
                                <div class="col-sm-6 col-sm-offset-3">
                                    <div class="alert alert-info small text-center">
                                        <p> Each layout example in the list should be checked on <strong>desktop</strong>, <strong>mobile</strong> and <strong>print</strong> each time the styles are
                                            changed. </p>
                                    </div>
                                    <ul>
                                        <li>
                                            <em>
                                                <xsl:value-of select="'Bulleted'"/>
                                            </em>
                                            <xsl:value-of select="' lists: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-057-009.html#UT22084-057-009-12')"/>
                                                <xsl:value-of select="'1'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html#UT22084-046-001-1454')"/>
                                                <xsl:value-of select="'2'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-25')"/>
                                                <xsl:value-of select="'3'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-047-002.html#UT22084-047-002-15')"/>
                                                <xsl:value-of select="'4'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <em>
                                                <xsl:value-of select="'Section'"/>
                                            </em>
                                            <xsl:value-of select="' lists: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-36')"/>
                                                <xsl:value-of select="'1'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-46')"/>
                                                <xsl:value-of select="'2'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-055-001.html#UT22084-055-001-44')"/>
                                                <xsl:value-of select="'3'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <em>
                                                <xsl:value-of select="'Mixed'"/>
                                            </em>
                                            <xsl:value-of select="' lists: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-051-004.html#UT22084-051-004-45')"/>
                                                <xsl:value-of select="'1'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#UT22084-080-015-866')"/>
                                                <xsl:value-of select="'2'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html#UT22084-081-006-272')"/>
                                                <xsl:value-of select="'3'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-011.html#UT22084-079-011-14')"/>
                                                <xsl:value-of select="'4'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-054-003.html#UT22084-054-003-19')"/>
                                                <xsl:value-of select="'Verses'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#UT22084-080-015-153')"/>
                                                <xsl:value-of select="'Mantra'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh1-1.html#UT22084-001-001-781')"/>
                                                <xsl:value-of select="'Nested sections'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-45')"/>
                                                <xsl:value-of select="'Nested paragraphs'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Blockquote: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html#UT22084-046-001-4')"/>
                                                <xsl:value-of select="'with paragraphs'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-047-002.html#UT22084-047-002-3')"/>
                                                <xsl:value-of select="'with verse'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-055-001.html#UT22084-055-001-44')"/>
                                                <xsl:value-of select="'Structured introduction'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-011.html#prologue')"/>
                                                <xsl:value-of select="'Prologue'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Chapters: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh11.html#chapter-1')"/>
                                                <xsl:value-of select="'with numbers and titles'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-056-002.html#chapter-1')"/>
                                                <xsl:value-of select="'without titles'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html#colophon')"/>
                                                <xsl:value-of select="'Colophon chapters'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#appendix')"/>
                                                <xsl:value-of select="'Appendix chapters'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-051-004.html#UT22084-051-004-136')"/>
                                                <xsl:value-of select="'Trailer'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Abbreviations: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html#abbreviations')"/>
                                                <xsl:value-of select="'with header &amp; footer'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-008.html#abbreviations')"/>
                                                <xsl:value-of select="'multiple lists'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#bibliography')"/>
                                                <xsl:value-of select="'Structured bibliography'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-001-001.html#UT22084-001-001-108')"/>
                                                <xsl:value-of select="'Line group'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-061-013.html#UT22084-061-013-50')"/>
                                                <xsl:value-of select="'Hanging indent'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html')"/>
                                                <xsl:value-of select="'Tantra warning'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Pointers: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-4437')"/>
                                                <xsl:value-of select="'From glossary (to milestone and footnote)'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh1-1.html#UT22084-001-001-2806')"/>
                                                <xsl:value-of select="'from footnote'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh260.html#UT22084-066-018-18')"/>
                                                <xsl:value-of select="'to section'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#UT22084-080-015-1670')"/>
                                                <xsl:value-of select="'Long milestone'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-044-005.html#UT22084-044-005-3')"/>
                                                <xsl:value-of select="'Small caps'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Tables: '"/>
                                            <a target="test-tables-layout-1">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh361.html#UT22084-077-002-623')"/>
                                                <xsl:value-of select="'web'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-tables-layout-2">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh361.html?view-mode=epub#UT22084-077-002-623')"/>
                                                <xsl:value-of select="'ebook'"/>
                                            </a>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Whitespace: '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh431.html#UT22084-080-015-156')"/>
                                                <xsl:value-of select="'No space after double quote'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh381.html#UT22084-079-008-1960')"/>
                                                <xsl:value-of select="'Space between foot note and foreign'"/>
                                            </a>
                                            <xsl:value-of select="', '"/>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh157.html#UT22084-058-006-854')"/>
                                                <xsl:value-of select="'Space between footnote and ref'"/>
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:variable>
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Layout Checks | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Links to layout elements taht should be checked'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>