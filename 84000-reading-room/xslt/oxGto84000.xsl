<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">
    <!-- 
        Converts OxGarage TEI output to 84000 TEI
        .........................................
        
    -->
    
    <xsl:output method="xml" encoding="UTF-8"/>
    <xsl:preserve-space elements="*"/>
    <xsl:output indent="yes"/>
    
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title type="mainTitle" xml:lang="bo">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[1]))"/>
                        </title>
                        <title type="mainTitle" xml:lang="eng">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[2]))"/>
                        </title>
                        <title type="mainTitle" xml:lang="Sa-Ltn">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[3]))"/> 
                        </title>
                        <title type="longTitle" xml:lang="bo">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[4]))"/>
                        </title>
                        <title type="longTitle" xml:lang="Bo-Ltn">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[5]))"/>
                        </title>
                        <title type="longTitle" xml:lang="eng">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[6]))"/>
                        </title>
                        <title type="longTitle" xml:lang="Sa-Ltn">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[7]))"/>
                        </title>
                        <author role="translatorMain">
                            <xsl:apply-templates select="//tei:text/tei:body/tei:p[9]/node()"/>
                        </author>
                    </titleStmt>
                    <editionStmt>
                        <edition>
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[10]))"/>
                        </edition>
                    </editionStmt>
                    <publicationStmt>
                        <publisher>
                            <name>84000: Translating the Words of the Buddha</name> is a global non-profit initiative that aims to translate all of the Buddha’s words into modern languages, and to make them available to everyone.
                        </publisher>
                        <availability>
                            <licence>
                                <graphic url="http://i.creativecommons.org/l/by-nc-nd/2.0/88x31.png"/>
                                <p>This work is provided under the protection of a Creative Commons CC BY-NC-ND (Attribution - Non-commercial - No-derivatives) 3.0 copyright. It may be copied or printed for fair use, but only with full attribution, and not for commercial advantage or personal compensation. For full details, see the Creative Commons license.</p>
                            </licence>
                        </availability>
                        <idno xml:id="DUMMY"/>
                        <date>2017</date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <ref/>
                            <biblScope>
                                <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:p[8]))"/>
                            </biblScope>
                            <author role="translatorTib"/>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <front>
                    <div type="summary">
                        <head type="summary">Summary</head>
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[parent::*/tei:head[contains(text(),'Summary')]]">
                            <xsl:if test="normalize-space(.)">
                                <milestone unit="chunk"/>
                                <p>
                                    <xsl:apply-templates select="."/>
                                </p>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <div type="acknowledgment">
                        <head type="acknowledgment">Acknowledgements</head>
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[parent::*/tei:head[contains(text(),'Acknowledgements')]]">
                            <xsl:if test="normalize-space(.)">
                                <milestone unit="chunk"/>
                                <p>
                                    <xsl:apply-templates select="."/>
                                </p>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <xsl:for-each select="//tei:text/tei:body/tei:div/tei:div[preceding-sibling::tei:head[1][contains(., 'Introduction')]]">
                        <div type="introduction">
                            <head type="introduction">Introduction</head>
                            <div type="section">
                                <xsl:for-each select="tei:p">
                                    <xsl:if test="normalize-space(.)">
                                        <milestone unit="chunk"/>
                                        <p>
                                            <xsl:apply-templates select="."/>
                                        </p>
                                    </xsl:if>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>
                </front>
                <body>
                    <xsl:for-each select="//tei:text/tei:body/tei:div/tei:div[preceding-sibling::tei:head[1][contains(., 'The Translation')]]">
                        <div>
                            <xsl:for-each select="tei:p | tei:head">
                                <xsl:if test="self::tei:head and contains(., 'Main Section')">
                                    <xsl:attribute name="type" select="'translation'"/>
                                    <head type="translation">The Translation</head>
                                    <head type="titleHon"/>
                                    <head type="titleMain"/>
                                </xsl:if>
                                <xsl:if test="self::tei:head and contains(., 'Colophon')">
                                    <xsl:attribute name="type" select="'colophon'"/>
                                </xsl:if>
                                <xsl:if test="self::tei:p and normalize-space(.)">
                                    <milestone unit="chunk"/>
                                    <p>
                                        <xsl:apply-templates select="."/>
                                    </p>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </xsl:for-each>
                    <div type="abbreviations">
                        <head type="abbreviations">Abbreviations</head>
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[parent::*/tei:head[contains(text(),'Abbreviations')]]">
                            <xsl:if test="normalize-space(.)">
                                <p>
                                    <xsl:apply-templates select="."/>
                                </p>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <div type="listBibl">
                        <head type="listBibl">Bibliography</head>
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:div[preceding-sibling::tei:head[1][contains(., 'Bibliography')]]/tei:p">
                            <xsl:if test="normalize-space(.)">
                                <bibl>
                                    <xsl:apply-templates select="."/>
                                </bibl>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="tei:hi">
        <title xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:choose>
                <xsl:when test="@rend = 'Title-English'">
                    <xsl:attribute name="xml:lang" select="'en'"/>
                </xsl:when>
                <xsl:when test="@rend = ('Foreign_Quote-Tibetan_Wyile','Title-Tibetan_Wylie')">
                    <xsl:attribute name="xml:lang" select="'Bo-Ltn'"/>
                </xsl:when>
                <xsl:when test="@rend = 'Title-Sanskrit'">
                    <xsl:attribute name="xml:lang" select="'Sa-Ltn'"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </title>
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <lb xmlns="http://www.tei-c.org/ns/1.0"/>
    </xsl:template>
    
    <xsl:template match="tei:note">
        <note xmlns="http://www.tei-c.org/ns/1.0" place="end">
            <xsl:apply-templates select="node()"/>
        </note>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
</xsl:stylesheet>