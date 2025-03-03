<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:json="http://www.json.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    
    <xsl:param name="api-version" select="'0.4.0'"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/eft:response">
        <sponsorship>
            
            <xsl:for-each-group select="eft:sponsorship-texts/eft:text/eft:sponsorship-status" group-by="@project-id">
                
                <!-- Sponsorship project -->
                <xsl:element name="sponsorshipProject">
                    
                    <xsl:attribute name="json:array" select="true()"/>
                    <xsl:attribute name="projectId" select="@project-id"/>
                    
                    <xsl:apply-templates select="eft:cost"/>
                    <xsl:apply-templates select="eft:status"/>
                    
                    <!-- Associated texts -->
                    <xsl:for-each select="current-group()">
                        <xsl:call-template name="work">
                            <xsl:with-param name="text" select="parent::eft:text"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    
                </xsl:element>
            </xsl:for-each-group>
            
            <xsl:apply-templates select="eft:cost-groups"/>
            
        </sponsorship>
    </xsl:template>
    
    <xsl:template name="work">
        <xsl:param name="text" as="element(eft:text)"/>
        <xsl:element name="work">
            
            <xsl:attribute name="json:array" select="true()"/>
            
            <!-- Work attributes -->
            <xsl:attribute name="workId" select="$text/@id"/>
            <xsl:attribute name="workType" select="$text/@resource-type ! concat('eft:', .)"/>
            <xsl:attribute name="url" select="$text/@id ! concat('/translation/', .,'.json?api-version=', $api-version)"/>
            <xsl:attribute name="htmlUrl" select="$text/@id ! m:translation-href(., (), (), ())"/>
            <xsl:attribute name="publicationStatus" select="$text/@status"/>
            
            <!-- Titles -->
            <xsl:call-template name="title">
                <xsl:with-param name="titles" select="$text/eft:titles/eft:title"/>
                <xsl:with-param name="titleType" select="'mainTitle'"/>
            </xsl:call-template>
            <xsl:call-template name="title">
                <xsl:with-param name="titles" select="$text/eft:title-variants/eft:title[@xml:lang eq 'zh']"/>
                <xsl:with-param name="titleType" select="'otherTitle'"/>
            </xsl:call-template>
            
            <!-- Summary -->
            <xsl:if test="$text/eft:part[@type eq 'summary'][tei:p]">
                <xsl:element name="content">
                    <xsl:attribute name="json:array" select="true()"/>
                    <xsl:attribute name="contentType" select="'summary'"/>
                    <xsl:attribute name="language" select="(@xml:lang, 'en')[1]"/>
                    <xsl:for-each select="$text/eft:part[@type eq 'summary']/tei:p">
                        <xsl:variable name="summary-html" as="node()*">
                            <xsl:apply-templates select="node()"/>
                        </xsl:variable>
                        <xsl:element name="p">
                            <xsl:attribute name="json:array" select="true()"/>
                            <xsl:element name="tei">
                                <xsl:value-of select="replace(replace(serialize(node()), '\s+', ' '), '\s*xmlns=&#34;[^\s|&gt;]*&#34;', '')"/>
                            </xsl:element>
                            <xsl:element name="html">
                                <xsl:value-of select="replace(replace(serialize($summary-html), '\s+', ' '), '\s*xmlns=&#34;[^\s|&gt;]*&#34;', '')"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
            
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="title">
        <xsl:param name="titles" as="element(eft:title)*"/>
        <xsl:param name="titleType" as="xs:string"/>
        <xsl:element name="title">
            <xsl:attribute name="json:array" select="true()"/>
            <xsl:attribute name="titleType" select="$titleType"/>
            <xsl:for-each select="$titles">
                <xsl:element name="label">
                    <xsl:attribute name="json:array" select="true()"/>
                    <xsl:attribute name="language" select="@xml:lang"/>
                    <xsl:attribute name="content" select="string-join(text()) ! normalize-space(.)"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:cost">
        <xsl:element name="sponsorshipCost">
            <xsl:element name="perPagePrice">
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="@per-page-price/string()"/>
            </xsl:element>
            <xsl:element name="costBasic">
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="@basic-cost/string()"/>
            </xsl:element>
            <xsl:element name="costRounded">
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="@rounded-cost/string()"/>
            </xsl:element>
            <xsl:apply-templates select="@*[not(local-name() = ('per-page-price','basic-cost','rounded-cost'))]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:status">
        <xsl:element name="sponsorshipStatus">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:part">
        <xsl:element name="sponsorshipPart">
            <xsl:attribute name="sponsorshipStatus" select="@status"/>
            <xsl:apply-templates select="@*[not(local-name() = ('status'))]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:cost-groups">
        <xsl:element name="costGroups">
            <xsl:element name="perPagePrice">
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="@cost-per-page/string()"/>
            </xsl:element>
            <xsl:apply-templates select="@*[not(local-name() = ('cost-per-page'))]"/>
            <xsl:for-each select="eft:cost-group[@parts ! xs:integer(.) eq 1]">
                <xsl:element name="costGroup">
                    <xsl:element name="pageUpperBound">
                        <xsl:attribute name="json:literal" select="true()"/>
                        <xsl:value-of select="@page-upper/string()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
            <xsl:if test="eft:cost-group[not(@parts ! xs:integer(.) eq 1)]">
                <xsl:element name="costGroup">
                    <xsl:element name="pageUpperBound">
                        <xsl:attribute name="json:literal" select="true()"/>
                        <xsl:value-of select="max(eft:cost-group[not(@parts ! xs:integer(.) eq 1)]/@page-upper ! xs:integer(.))"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:*">
        <xsl:element name="{ node-name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:choose>
            <xsl:when test="parent::eft:cost and local-name(.) = ('pages')">
                <xsl:element name="{ local-name(.) }">
                    <xsl:attribute name="json:literal" select="true()"/>
                    <xsl:value-of select="string()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="parent::eft:part and local-name(.) = ('amount')">
                <xsl:element name="{ local-name(.) }">
                    <xsl:attribute name="json:literal" select="true()"/>
                    <xsl:value-of select="string()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="parent::eft:cost-group and local-name(.) = ('page-upper','parts')">
                <xsl:element name="{ local-name(.) }">
                    <xsl:attribute name="json:literal" select="true()"/>
                    <xsl:value-of select="string()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{ local-name(.) }">
                    <xsl:value-of select="string()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.) ! replace(., '\s+', ' ')"/>
    </xsl:template>
    
</xsl:stylesheet>