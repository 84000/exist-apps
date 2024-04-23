<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/eft:response">
        <sponsorship>
            <xsl:for-each-group select="eft:sponsorship-texts/eft:text/eft:sponsorship-status" group-by="@project-id">
                
                <!-- Sponsorship project -->
                <xsl:element name="sponsorshipProject">
                    
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
            
        </sponsorship>
    </xsl:template>
    
    <xsl:template name="work">
        <xsl:param name="text" as="element(eft:text)"/>
        <xsl:element name="work">
            
            <!-- Work attributes -->
            <xsl:attribute name="workId" select="$text/@id"/>
            <xsl:attribute name="workType" select="$text/@resource-type ! concat('eft:', .)"/>
            <xsl:attribute name="url" select="$text/@id ! concat('/translation/', .,'.json?api-version=', '0.3.0')"/>
            <xsl:attribute name="htmlUrl" select="$text/@id ! concat('https://read.84000.co', '/translation/', ., '.html')"/>
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
            
            <!-- Cost -->
            <xsl:if test="$text/eft:part[@type eq 'summary'][tei:p]">
                <xsl:element name="summary">
                    <xsl:for-each select="$text/eft:part[@type eq 'summary']/tei:p">
                        <xsl:variable name="summary-html" as="node()*">
                            <xsl:apply-templates select="node()"/>
                        </xsl:variable>
                        <xsl:element name="p">
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
            <xsl:attribute name="titleType" select="$titleType"/>
            <xsl:for-each select="$titles">
                <xsl:element name="label">
                    <xsl:attribute name="language" select="@xml:lang"/>
                    <xsl:attribute name="content" select="string-join(text()) ! normalize-space(.)"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:cost">
        <xsl:element name="sponsorshipCost">
            <xsl:attribute name="perPagePrice" select="@per-page-price"/>
            <xsl:attribute name="costBasic" select="@basic-cost"/>
            <xsl:attribute name="costRounded" select="@basic-rounded"/>
            <xsl:sequence select="@*[not(local-name() = ('per-page-price','basic-cost','basic-rounded'))]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:status">
        <xsl:element name="sponsorshipStatus">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:part">
        <xsl:element name="sponsorshipPart">
            <xsl:attribute name="sponsorshipStatus" select="@status"/>
            <xsl:sequence select="@*[not(local-name() = ('status'))]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="eft:*">
        <xsl:element name="{ node-name(.)}">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.) ! replace(., '\s+', ' ')"/>
    </xsl:template>
    
</xsl:stylesheet>