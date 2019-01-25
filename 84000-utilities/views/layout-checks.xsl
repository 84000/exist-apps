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
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        <span class="title"> 84000 Utilities </span>
                        <span class="text-right">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="$reading-room-path"/> Reading Room </a>
                        </span>
                    </div>
                    <div class="panel-body">
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        <div class="tab-content">
                            <div class="row">
                                <div class="col-sm-6 col-sm-offset-3">
                                    <div class="alert alert-warning small text-center">
                                        <p> Each layout example in the list should be checked on <strong>desktop</strong>, <strong>mobile</strong> and <strong>print</strong> each time the styles are
                                            changed. </p>
                                    </div>
                                    <ul>
                                        <li>
                                            <em>Bulleted</em> lists: <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-057-009.html#UT22084-057-009-12')"/> 1 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html#UT22084-046-001-1454')"/> 2 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-25')"/> 3 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-047-002.html#UT22084-047-002-15')"/> 4 </a>
                                        </li>
                                        <li>
                                            <em>Section</em> lists: <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-36')"/> 1 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-46')"/> 2 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-055-001.html#UT22084-055-001-44')"/> 3 </a>
                                        </li>
                                        <li>
                                            <em>Mixed</em> lists: <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-051-004.html#UT22084-051-004-45')"/> 1 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#UT22084-080-015-866')"/> 2 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html#UT22084-081-006-272')"/> 3 </a>, <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-011.html#UT22084-079-011-14')"/> 4 </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-054-003.html#UT22084-054-003-19')"/> Verses </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#UT22084-080-015-153')"/> Mantra </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-45')"/> Nested paragraphs </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html#UT22084-046-001-4')"/> Blockquote with paragraphs </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-047-002.html#UT22084-047-002-3')"/> Blockquote with verse </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-055-001.html#UT22084-055-001-44')"/> Structured introduction </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-011.html#prologue')"/> Prologue </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh11.html#chapter-1')"/> Chapters with numbers and titles </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-056-002.html#chapter-1')"/> Chapters without titles </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-051-004.html#UT22084-051-004-136')"/> Trailer </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html#colophon')"/> Colophon chapters </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#appendix')"/> Appendix chapters </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html#abbreviations')"/> Abbreviations with header &amp;
                                                footer </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-008.html#abbreviations')"/> Multiple abbreviations lists</a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#bibliography')"/> Structured bibliography </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-061-013.html#UT22084-061-013-50')"/> Hanging indent </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html')"/> Tantra warning </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html#UT22084-031-002-4437')"/> Internal pointer </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html#UT22084-080-015-1670')"/> Long milestone </a>
                                        </li>
                                        <li>
                                            <a target="test-layout">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-044-005.html#UT22084-044-005-3')"/> Small caps </a>
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
            <xsl:with-param name="page-title" select="'Layout Ckecks :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Links to layout elements taht should be checked'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>