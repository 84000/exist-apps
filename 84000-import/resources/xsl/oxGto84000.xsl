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
                            <name>84000: Translating the Words of the Buddha</name> is a global
                            non-profit initiative that aims to translate all of the Buddha’s words
                            into modern languages, and to make them available to everyone. </publisher>
                        <availability>
                            <licence>
                                <graphic url="http://i.creativecommons.org/l/by-nc-nd/2.0/88x31.png"/>
                                <p>This work is provided under the protection of a Creative Commons
                                    CC BY-NC-ND (Attribution - Non-commercial - No-derivatives) 3.0
                                    copyright. It may be copied or printed for fair use, but only
                                    with full attribution, and not for commercial advantage or
                                    personal compensation. For full details, see the Creative
                                    Commons license.</p>
                            </licence>
                        </availability>
                        <idno xml:id="DUMMY"/>
                        <date>2018</date>
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
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[parent::*/tei:head[contains(text(), 'Summary')]]">
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
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[parent::*/tei:head[contains(text(), 'Acknowledgements')]]">
                            <xsl:if test="normalize-space(.)">
                                <milestone unit="chunk"/>
                                <p>
                                    <xsl:apply-templates select="."/>
                                </p>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <div type="introduction">
                        <head type="introduction">Introduction</head>
                        
                        <!--Need this script incase the translator has paragraphs of introduction before the first subsection.-->
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[preceding-sibling::tei:head[1][contains(., 'Introduction')]]">
                            <xsl:if test="normalize-space(.)">
                                <milestone unit="chunk"/>
                                <p>
                                    <xsl:apply-templates select="."/>
                                </p>
                            </xsl:if>
                        </xsl:for-each>
                        
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:div[preceding-sibling::tei:head[1][contains(., 'Introduction')]]">
                            <div type="section">
                                <xsl:for-each select="tei:p | tei:head">
                                    <xsl:if test="self::tei:p and normalize-space(.)">
                                        <milestone unit="chunk"/>
                                        <p>
                                            <xsl:apply-templates select="."/>
                                        </p>
                                    </xsl:if>
                                    <xsl:if test="self::tei:head and normalize-space(.)">
                                        <head>
                                            <xsl:apply-templates select="."/>
                                        </head>
                                    </xsl:if>
                                </xsl:for-each>
                            </div>
                        </xsl:for-each>
                    </div>
                </front>
                <body>           
                    <div type="translation">
                        <head type="translation">
                            The Translation
                        </head>
                        <head type="titleHon">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:div/tei:p[1][preceding-sibling::tei:head[1][contains(., 'The Translation')]]))"/>
                        </head>
                        <head type="titleMain">
                            <xsl:value-of select="normalize-space(data(//tei:text/tei:body/tei:div/tei:p[2][preceding-sibling::tei:head[1][contains(., 'The Translation')]]))"/>
                        </head>
                        
                    <!--Need this incase there is initial text before the first chapter begins, usually homage sometimes with endnote. 
                    This will duplicate the titles, but that is easy to fix and preferable to losing important data. Is there a way to
                    have the "for each" command skip the first two "body/div/p[1]" and "body/div/p[2]" and begin on ...p[3]?-->    
                    <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[preceding-sibling::tei:head[1][contains(., 'The Translation')]]">
                        <xsl:if test="normalize-space(.)">
                            <milestone unit="chunk"/>
                            <p>
                                <xsl:apply-templates select="."/>
                            </p>
                        </xsl:if>
                    </xsl:for-each>
                    
                    <xsl:for-each select="//tei:text/tei:body/tei:div/tei:div[preceding-sibling::tei:head[1][contains(., 'The Translation')]]">
                        <div>
                            <xsl:for-each select="tei:p | tei:head">
                                <!--<xsl:if test="self::tei:head and contains(., 'Main Section')">
                                    <xsl:attribute name="type" select="'translation'"/>
                                    <head type="translation">The Translation</head>
                                    <head type="titleHon"/>
                                    <head type="titleMain"/>
                                </xsl:if>-->
                                <xsl:if test="self::tei:head and contains(., 'Colophon')">
                                    <xsl:attribute name="type" select="'colophon'"/>
                                </xsl:if>
                                <xsl:if test="self::tei:p and normalize-space(.)">
                                    <milestone unit="chunk"/>
                                    <p>
                                        <xsl:apply-templates select="."/>
                                    </p>
                                </xsl:if>
                                <xsl:if test="self::tei:head and normalize-space(.)">
                                    <head>
                                        <xsl:apply-templates select="."/>
                                    </head>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </xsl:for-each>
                    <div type="abbreviations">
                        <head type="abbreviations">Abbreviations</head>
                        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:p[parent::*/tei:head[contains(text(), 'Abbreviations')]]">
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
                    </div>
                </body>
            </text>
        </TEI>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Title-English']">
        <title xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'en'"/>
            <xsl:apply-templates select="node()"/>
        </title>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Title-Sanskrit']">
        <title xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Sa-Ltn'"/>
            <xsl:apply-templates select="node()"/>
        </title>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Title-Tibetan']">
        <title xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Bo-Ltn'"/>
            <xsl:apply-templates select="node()"/>
        </title>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Title-Other']">
        <title xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Input Language'"/>
            <xsl:apply-templates select="node()"/>
        </title>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Foreign_Term-Sanskrit']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Sa-Ltn'"/>
            <xsl:attribute name="type" select="'term'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Foreign_Term-Tibetan']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Bo-Ltn'"/>
            <xsl:attribute name="type" select="'term'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Foreign_Term-Other']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Input Language'"/>
            <xsl:attribute name="type" select="'term'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Foreign_Quote-Sanskrit']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Sa-Ltn'"/>
            <xsl:attribute name="type" select="'quote'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Foreign_Quote-Tibetan']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Bo-Ltn'"/>
            <xsl:attribute name="type" select="'quote'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Foreign_Quote-Other']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Input Language'"/>
            <xsl:attribute name="type" select="'quote'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Mantra-Sanskrit']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Sa-Ltn'"/>
            <xsl:attribute name="type" select="'mantra'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Mantra-Tibetan']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Bo-Ltn'"/>
            <xsl:attribute name="type" select="'mantra'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Mantra-Other']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Input Language'"/>
            <xsl:attribute name="type" select="'mantra'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Other_Foreign_Usage-Sanskrit']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Sa-Ltn'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Other_Foreign_Usage-Tibetan']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Bo-Ltn'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Other_Foreign_Usage-Other']">
        <foreign xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:lang" select="'Input Language'"/>
            <xsl:apply-templates select="node()"/>
        </foreign>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Distinct']">
        <distinct xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="node()"/>
        </distinct>
    </xsl:template>

    <xsl:template match="tei:hi[@rend = 'Emphasis_Tag']">
        <emph xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="node()"/>
        </emph>
    </xsl:template>

    <xsl:template match="tei:hi">
        <hi>
            <xsl:apply-templates select="node()"/>
        </hi>
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