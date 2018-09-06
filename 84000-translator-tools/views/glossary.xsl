<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/xslt/functions.xsl"/>
    
    <xsl:template name="glossary">
        
        <div id="cumulative-glossary">
            <div class="row">
                <div class="col-sm-4">
                    <ul class="nav nav-pills">
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'term'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=term&amp;lang=', m:glossary/@lang)"/>
                                Terms
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'person'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=person&amp;lang=', m:glossary/@lang)"/>
                                Persons
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'place'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=place&amp;lang=', m:glossary/@lang)"/>
                                Places
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'text'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=text&amp;lang=', m:glossary/@lang)"/>
                                Texts
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="col-sm-4">
                    <ul class="nav nav-pills">
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'en'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', m:glossary/@type,'&amp;lang=en')"/>
                                English
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'sa-ltn'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', m:glossary/@type,'&amp;lang=Sa-Ltn')"/>
                                Sanskrit
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="lower-case(m:glossary/@lang) eq 'bo-ltn'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href" select="concat('?tab=glossary&amp;type=', m:glossary/@type,'&amp;lang=Bo-Ltn')"/>
                                Wylie
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="col-sm-4">
                    <a href="cumulative-glossary.zip" class="download-link center-vertical">
                        <span>
                            <i class="fa fa-cloud-download"/>
                        </span>
                        <span>Download All (.xml)</span>
                    </a>
                </div>
            </div>
            <div class="row">
                
                <div class="col-items div-list">
                    
                    <xsl:for-each select="m:glossary/m:term">
                        <div class="item">
                            
                            <xsl:copy-of select="common:marker(@start-letter, if(preceding-sibling::m:term[1]/@start-letter) then preceding-sibling::m:term[1]/@start-letter else '')"/>
                            
                            <div class="row">
                                <div class="col-sm-6 name">
                                    <xsl:value-of select="normalize-space(m:main-term/text())"/>
                                </div>
                                <div class="col-sm-6 text-right">
                                    <a target="_self">
                                        <xsl:attribute name="href" select="concat('glossary-items.html?term=', fn:encode-for-uri(m:main-term/text()))"/>
                                        <xsl:attribute name="data-ajax-target" select="concat('#occurrences-', position())"/>
                                        <xsl:choose>
                                            <xsl:when test="@count-items &gt; 1">
                                                <xsl:value-of select="@count-items"/> matches
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@count-items"/> match
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </a>
                                </div>
                            </div>
                            
                            <div class="collpase">
                                <xsl:attribute name="id" select="concat('occurrences-', position())"/>
                            </div>
                            
                        </div>                                    
                    </xsl:for-each>
                </div>
                
                <div id="letters-nav" class="col-nav">
                    <xsl:copy-of select="common:marker-nav(m:glossary/m:term)"/>
                </div>
                
            </div>
            
        </div>
    </xsl:template>
    
</xsl:stylesheet>