<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    <!-- 
        Converts other xml to valid xhtml
    -->
    
    <xsl:output method="html" indent="no"/>
    
    <xsl:function name="common:lang-class" as="xs:string*">
        <!-- Standardise wayward lang ids -->
        <xsl:param name="lang"/>
        <xsl:choose>
            <xsl:when test="lower-case($lang) eq 'bo'">
                <xsl:value-of select="'text-bo'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'sa-ltn'">
                <xsl:value-of select="'text-sa'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                <xsl:value-of select="'text-wy'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = ('eng', 'en')">
                <xsl:value-of select="'text-en'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'zh'">
                <xsl:value-of select="'text-zh'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="common:echo-for-doc-type" as="xs:string*">
        <xsl:param name="current-doc-type"/>
        <xsl:param name="echo-for-doc-type"/>
        <xsl:param name="string-to-echo" as="xs:string*"/>
        <xsl:if test="$string-to-echo and (lower-case($current-doc-type) eq lower-case($echo-for-doc-type))">
            <xsl:value-of select="$string-to-echo"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="common:index-of-node" as="xs:integer*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="nodeToFind" as="node()"/>
        <xsl:sequence select="for $seq in (1 to count($nodes)) return $seq[$nodes[$seq] is $nodeToFind]"/>
    </xsl:function>
    
    <xsl:function name="common:standardized-sa" as="xs:string*">
        <xsl:param name="sa-string" as="xs:string"/>
        <xsl:variable name="in" select="'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'"/>
        <xsl:variable name="out" select="'adhillmnnnrrsstum'"/>
        <xsl:value-of select="translate(lower-case($sa-string), $in, $out)"/>
    </xsl:function>
    
    <xsl:function name="common:glossarize-class" as="xs:string*">
        <xsl:param name="glossarize" as="xs:boolean"/>
        <xsl:param name="css-class" as="xs:string*"/>
        <xsl:if test="$css-class and $glossarize eq true()">
            <xsl:value-of select="concat(' ', $css-class)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="common:alphanumeric" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace($string, '[^a-zA-Z0-9]', '')"/>
    </xsl:function>
    
    <xsl:function name="common:limit-str" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="max-length" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string-length( $string ) &gt; $max-length ">
                <xsl:value-of select="concat(substring( $string ,0, $max-length ), '...')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select=" $string "/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="common:pagination">
        <xsl:param name="first-record" as="xs:integer"/>
        <xsl:param name="max-records" as="xs:integer"/>
        <xsl:param name="count-records" as="xs:integer"/>
        <xsl:param name="append-to-url" as="xs:string"/>
        
        <xsl:variable name="count-pages" select="xs:integer(($count-records div $max-records) + 1)"/>
        <xsl:variable name="max-pages" select="if ($count-pages le 15) then $count-pages else 15"/>
        
        <nav aria-label="Page navigation" class="text-right">
            <ul class="pagination">
                <li class="disabled">
                    <span>Page: </span>
                </li>
                <xsl:for-each select="1 to $max-pages">
                    <xsl:variable name="page-first-record" select="(((. - 1) * $max-records) + 1)"/>
                    <li>
                        <xsl:if test="$first-record eq $page-first-record">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="href" select="concat('?first-record=', $page-first-record, $append-to-url)"/>
                            <xsl:value-of select="position()"/>
                        </a>
                    </li>
                </xsl:for-each>
                <li class="disabled">
                    <span>
                        <xsl:value-of select="concat('of ', format-number($count-records, '#,###'), ' results')"/>
                    </span>
                </li>
            </ul>
        </nav>
    </xsl:function>
    
    <xsl:function name="common:marker">
        
        <xsl:param name="start-letter" as="xs:string"/>
        <xsl:param name="previous-start-letter" as="xs:string"/>
        
        <xsl:if test="not($previous-start-letter eq $start-letter)">
            <a class="marker">
                <xsl:attribute name="name" select="$start-letter"/>
                <xsl:attribute name="id" select="concat('marker-', $start-letter)"/>
                <xsl:value-of select="$start-letter"/>
            </a>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="common:marker-nav">
        
        <xsl:param name="items-with-start-letters" as="item()*"/>
        
        <div data-spy="affix">
            <div class="btn-group-vertical btn-group-xs" role="group" aria-label="navigation">
                <xsl:for-each select="$items-with-start-letters">
                    <xsl:sort select="@start-letter"/>
                    <xsl:variable name="start-letter" select="@start-letter"/>
                    <xsl:if test="not(preceding-sibling::*[@start-letter = $start-letter])">
                        
                        <a class="btn btn-default scroll-to-anchor">
                            <xsl:attribute name="href" select="concat('#marker-', $start-letter)"/>
                            <xsl:value-of select="$start-letter"/>
                        </a>
                        
                    </xsl:if>
                </xsl:for-each>
            </div>
        </div>
    </xsl:function>
    
    <xsl:function name="common:position-to-color" as="xs:string">
        
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="format" as="xs:string"/>
        
        <xsl:variable name="colour-map" select="document('colour-map.xml')"/>
        <xsl:variable name="max-position" select="count($colour-map/m:colours/m:colour)"/>
        <xsl:variable name="position-bounded" select="if($position gt $max-position) then $max-position else $position"/>
        
        <xsl:choose>
            <xsl:when test="$format eq 'hex'">
                <xsl:value-of select="$colour-map/m:colours/m:colour[$position-bounded]/@hex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$colour-map/m:colours/m:colour[$position-bounded]/@id"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
</xsl:stylesheet>