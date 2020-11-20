<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-no-cache-path" select="$environment/m:url[@id eq 'reading-room-no-cache']/text()"/>
        <xsl:variable name="reading-room-path" select="if($reading-room-no-cache-path) then $reading-room-no-cache-path else $environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            <div class="container">
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
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-057-009.html?part=UT22084-057-009-12#UT22084-057-009-12')"/>
                                    <xsl:value-of select="'1'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html?part=UT22084-046-001-1454#UT22084-046-001-1454')"/>
                                    <xsl:value-of select="'2'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html?part=UT22084-031-002-25#UT22084-031-002-25')"/>
                                    <xsl:value-of select="'3'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-047-002.html?part=UT22084-047-002-15#UT22084-047-002-15')"/>
                                    <xsl:value-of select="'4'"/>
                                </a>
                            </li>
                            <li>
                                <em>
                                    <xsl:value-of select="'Section'"/>
                                </em>
                                <xsl:value-of select="' lists: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html?part=UT22084-031-002-36#UT22084-031-002-36')"/>
                                    <xsl:value-of select="'1'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html?part=UT22084-031-002-46#UT22084-031-002-46')"/>
                                    <xsl:value-of select="'2'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-055-001.html?part=UT22084-055-001-44#UT22084-055-001-44')"/>
                                    <xsl:value-of select="'3'"/>
                                </a>
                            </li>
                            <li>
                                <em>
                                    <xsl:value-of select="'Mixed'"/>
                                </em>
                                <xsl:value-of select="' lists: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-051-004.html?part=UT22084-051-004-45#UT22084-051-004-45')"/>
                                    <xsl:value-of select="'1'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html?part=UT22084-080-015-866#UT22084-080-015-866')"/>
                                    <xsl:value-of select="'2'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html?part=UT22084-081-006-272#UT22084-081-006-272')"/>
                                    <xsl:value-of select="'3'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-011.html?part=UT22084-079-011-14#UT22084-079-011-14')"/>
                                    <xsl:value-of select="'4'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-054-003.html?part=UT22084-054-003-19#UT22084-054-003-19')"/>
                                    <xsl:value-of select="'Verses'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html?part=UT22084-080-015-153#UT22084-080-015-153')"/>
                                    <xsl:value-of select="'Mantra'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-001-001.html?part=UT22084-001-001-781#UT22084-001-001-781')"/>
                                    <xsl:value-of select="'Nested sections'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html?part=UT22084-031-002-45#UT22084-031-002-45')"/>
                                    <xsl:value-of select="'Nested paragraphs'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Blockquote: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html?part=UT22084-046-001-4#UT22084-046-001-4')"/>
                                    <xsl:value-of select="'with paragraphs'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-047-002.html?part=UT22084-047-002-3#UT22084-047-002-3')"/>
                                    <xsl:value-of select="'with verse'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-055-001.html?part=UT22084-055-001-44#UT22084-055-001-44')"/>
                                    <xsl:value-of select="'Structured introduction'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-079-011.html?part=UT22084-079-011-prologue#UT22084-079-011-prologue')"/>
                                    <xsl:value-of select="'Prologue'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Chapters: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html?part=UT22084-031-002-chapter-1#UT22084-031-002-chapter-1')"/>
                                    <xsl:value-of select="'with numbers and titles'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-056-002.html?part=UT22084-056-002-chapter-1#UT22084-056-002-chapter-1')"/>
                                    <xsl:value-of select="'without titles'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-046-001.html?part=UT22084-046-001-colophon#UT22084-046-001-colophon')"/>
                                    <xsl:value-of select="'Colophon chapters'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html?part=UT22084-080-015-appendix#UT22084-080-015-appendix')"/>
                                    <xsl:value-of select="'Appendix chapters'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-051-004.html?part=UT22084-051-004-136#UT22084-051-004-136')"/>
                                    <xsl:value-of select="'Trailer'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Abbreviations: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-040-003.html?part=UT22084-040-003-colophon#UT22084-040-003-colophon')"/>
                                    <xsl:value-of select="'none'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-001-001.html#abbreviations')"/>
                                    <xsl:value-of select="'basic'"/>
                                </a>
                                <xsl:value-of select="', '"/>
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
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-001-001.html?part=UT22084-001-001-108#UT22084-001-001-108')"/>
                                    <xsl:value-of select="'Line group'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-061-013.html?part=UT22084-061-013-50#UT22084-061-013-50')"/>
                                    <xsl:value-of select="'Hanging indent'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-081-006.html#imprint')"/>
                                    <xsl:value-of select="'Tantra warning'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Pointers: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-031-002.html?part=UT22084-031-002-4437#UT22084-031-002-4437')"/>
                                    <xsl:value-of select="'From glossary (to milestone and footnote)'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh1-1.html?part=UT22084-001-001-2806#UT22084-001-001-2806')"/>
                                    <xsl:value-of select="'from footnote'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh260.html?part=UT22084-066-018-18#UT22084-066-018-18')"/>
                                    <xsl:value-of select="'to section'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Refs: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh114.html?part=UT22084-051-002-14#UT22084-051-002-14')"/>
                                    <xsl:value-of select="'Rendered as Toh 114'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh527.html?part=UT22084-051-002-14#UT22084-051-002-14')"/>
                                    <xsl:value-of select="'Rendered as Toh 527 - including inactive ref'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh1-1.html?part=UT22084-001-001-136#UT22084-001-001-136')"/>
                                    <xsl:value-of select="'Refs 4a and 4.b have a footnote (60) between them containing a ref (14.b)'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-080-015.html?part=UT22084-080-015-1670#UT22084-080-015-1670')"/>
                                    <xsl:value-of select="'Long milestone'"/>
                                </a>
                            </li>
                            <li>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/UT22084-044-005.html?part=UT22084-044-005-3#UT22084-044-005-3')"/>
                                    <xsl:value-of select="'Small caps'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Tables: '"/>
                                <a target="test-tables-layout-1">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh361.html?part=UT22084-077-002-623#UT22084-077-002-623')"/>
                                    <xsl:value-of select="'web'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-tables-layout-2">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh361.html?part=UT22084-077-002-623&amp;view-mode=ebook#UT22084-077-002-623')"/>
                                    <xsl:value-of select="'ebook'"/>
                                </a>
                            </li>
                            <li>
                                <xsl:value-of select="'Whitespace: '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh431.html?part=UT22084-080-015-156#UT22084-080-015-156')"/>
                                    <xsl:value-of select="'No space after double quote'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh381.html?part=UT22084-079-008-1960#UT22084-079-008-1960')"/>
                                    <xsl:value-of select="'Space between foot note and foreign'"/>
                                </a>
                                <xsl:value-of select="', '"/>
                                <a target="test-layout">
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/toh157.html?part=UT22084-058-006-854#UT22084-058-006-854')"/>
                                    <xsl:value-of select="'Space between footnote and ref'"/>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </xsl:variable>
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Layout Checks | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Links to layout elements taht should be checked'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>