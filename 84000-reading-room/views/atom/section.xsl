<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/2005/Atom" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dc="http://purl.org/dc/terms/" version="3.0" exclude-result-prefixes="#default">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <xsl:output method="xml" indent="no" encoding="UTF-8" media-type="text/xml"/>
    
    <xsl:template match="/eft:response">
        
        <xsl:variable name="feed-type" select="if(eft:request/@resource-suffix eq 'acquisition.atom') then 'acquisition' else 'navigation'"/>
        <xsl:variable name="published-only" select="eft:request/@published-only" as="xs:boolean"/>
        <xsl:variable name="stat-toh-children-texts" select="eft:section/eft:translation-summary[@section-id eq parent::eft:section/@id]/eft:publications-summary[@grouping eq 'toh'][@scope eq 'children']/eft:texts"/>
        
        <feed xmlns:fh="http://purl.org/syndication/history/1.0" xmlns:opds="http://opds-spec.org/2010/catalog" xmlns:thr="http://purl.org/syndication/thread/1.0" xml:lang="en">
            
            <id>
                <xsl:value-of select="concat('https://read.84000.co/section/', upper-case(eft:section/@id), '/', $feed-type)"/>
            </id>
            
            <title>
                <xsl:value-of select="eft:section/eft:titles/eft:title[@xml:lang eq 'en']"/>
            </title>
            
            <icon>https://fe.84000.co/favicon/favicon.ico</icon>
            
            <updated>
                <xsl:value-of select="eft:section/@last-updated"/>
            </updated>
            
            <author>
                <name>84000: Translating the Words of the Buddha</name>
                <uri>https://read.84000.co</uri>
            </author>
            
            <xsl:if test="eft:section/eft:abstract/*">
                <summary type="text">
                    <xsl:value-of select="normalize-space(data(eft:section/eft:abstract))"/>
                </summary>
                <eft:abstract>
                    <xsl:apply-templates select="eft:section/eft:abstract" exclude-result-prefixes="xhtml"/>
                </eft:abstract>
            </xsl:if>
            
            <!-- Add a navigation link to start (Lobby) -->
            <link type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/section/lobby.navigation.atom" rel="start" title="The 84000 Reading Room"/>
            
            <!-- Add a navigation link to All Translated -->
            <xsl:if test="not(lower-case(eft:section/@id) eq 'all-translated') and eft:section//eft:translation-summary[@section-id ! lower-case(.) eq 'lobby']">
                <link type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/section/all-translated.acquisition.atom" rel="related" title="84000: All Translated Texts">
                    <xsl:attribute name="thr:count" select="eft:section//eft:translation-summary[@section-id ! lower-case(.) eq 'lobby']/eft:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/eft:texts/@published"/>
                </link>
            </xsl:if>
            
            <!-- Add a navigation link to self -->
            <link>
                <xsl:choose>
                    <xsl:when test="$feed-type eq 'acquisition'">
                        <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=acquisition'"/>
                        <xsl:attribute name="href" select="concat('/section/', upper-case(eft:section/@id), '.acquisition.atom')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=navigation'"/>
                        <xsl:attribute name="href" select="concat('/section/', upper-case(eft:section/@id), '.navigation.atom')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="rel" select="'self'"/>
                <xsl:attribute name="title" select="eft:section/eft:titles/eft:title[@xml:lang eq 'en']"/>
            </link>
            
            <!-- Perhaps add an acquisition link to self -->
            <xsl:if test="$feed-type eq 'navigation' and $stat-toh-children-texts[@published ! xs:integer(.) gt 0]">
                <link>
                    <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=acquisition'"/>
                    <xsl:attribute name="href" select="concat('/section/', upper-case(eft:section/@id), '.acquisition.atom')"/>
                    <xsl:attribute name="rel" select="'self'"/>
                    <xsl:attribute name="title" select="eft:section/eft:titles/eft:title[@xml:lang eq 'en']"/>
                </link>
            </xsl:if>
            
            <!-- All Translated is the complete catalogue -->
            <xsl:if test="lower-case(eft:section/@id) eq 'all-translated'">
                <fh:complete/>
            </xsl:if>
            
            <!-- Add a navigation link to parent -->
            <xsl:if test="eft:section/eft:parent/@id">
                <link>
                    <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=navigation'"/>
                    <xsl:attribute name="href" select="concat('/section/', upper-case(eft:section/eft:parent/@id), '.navigation.atom')"/>
                    <xsl:attribute name="rel" select="'up'"/>
                    <xsl:attribute name="title" select="eft:section/eft:parent/eft:titles/eft:title[@xml:lang eq 'en']"/>
                </link>
            </xsl:if>
            
            <!-- 
            TO DO: 
            Add a link to search
            <link rel="search" href="/search.xml" type="application/opensearchdescription+xml" title="Search the Reading Room"/>
             -->
            
            <xsl:choose>
                
                <xsl:when test="$feed-type eq 'acquisition'">
                    
                    <!-- Acquisition feed: add entries for texts -->
                    <xsl:for-each select="eft:section/eft:texts/eft:text">
                        
                        <xsl:sort select="@last-updated" order="descending"/>
                        
                        <xsl:call-template name="text-entry">
                            <xsl:with-param name="text" select="."/>
                        </xsl:call-template>
                    
                    </xsl:for-each>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    
                    <!-- Navigation feed: add entries for sub sections -->
                    <xsl:for-each select="eft:section/eft:section">
                        
                        <xsl:variable name="descendant-id" select="@id"/>
                        <xsl:variable name="sub-section" select="/eft:response/eft:section/eft:section[@id eq $descendant-id]"/>
                        <xsl:variable name="sub-section-stats" select="/eft:response/eft:section/eft:translation-summary[@section-id eq $descendant-id]"/>
                        <xsl:variable name="sub-section-stat-children" select="$sub-section-stats/eft:publications-summary[@grouping eq 'toh'][@scope eq 'children']/eft:texts"/>
                        <xsl:variable name="sub-section-stat-descendants" select="$sub-section-stats/eft:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/eft:texts"/>
                        
                        
                        <!-- If there are texts add an acquisition entry -->
                        <xsl:if test="$sub-section-stat-children/@published ! xs:integer(.) gt 0">
                            <xsl:call-template name="sub-section-entry">
                                <xsl:with-param name="sub-section" select="$sub-section"/>
                                <xsl:with-param name="feed-type" select="'acquisition'"/>
                                <xsl:with-param name="last-updated" select="@last-updated"/>
                            </xsl:call-template>
                        </xsl:if>
                        
                        <!-- If there are more descedant texts then add a navigation entry too -->
                        <xsl:if test="not($published-only) or $sub-section-stat-descendants/@published ! xs:integer(.) gt $sub-section-stat-children/@published ! xs:integer(.)">
                            <xsl:call-template name="sub-section-entry">
                                <xsl:with-param name="sub-section" select="$sub-section"/>
                                <xsl:with-param name="feed-type" select="'navigation'"/>
                                <xsl:with-param name="last-updated" select="@last-updated"/>
                            </xsl:call-template>
                        </xsl:if>
                        
                    </xsl:for-each>
                    
                </xsl:otherwise>
            
            </xsl:choose>
            
        </feed>
    </xsl:template>
    
    <xsl:template name="sub-section-entry">
        
        <xsl:param name="sub-section" required="yes" as="element(eft:section)"/>
        <xsl:param name="feed-type" required="yes" as="xs:string"/>
        <xsl:param name="last-updated" required="yes" as="xs:dateTime"/>
        
        <entry>
            
            <title>
                <xsl:value-of select="$sub-section/eft:titles/eft:title[@xml:lang eq 'en']"/>
            </title>
            
            <id>
                <xsl:value-of select="concat('http://read.84000.co/section/', upper-case($sub-section/@id), '/', $feed-type)"/>
            </id>
            
            <updated>
                <xsl:value-of select="$last-updated"/>
            </updated>
            
            <link>
                <xsl:attribute name="type" select="concat('application/atom+xml;profile=opds-catalog;kind=', $feed-type)"/>
                <xsl:attribute name="rel" select="'subsection'"/>
                <xsl:attribute name="href" select="concat('/section/', upper-case($sub-section/@id), '.', $feed-type, '.atom')"/>
            </link>
            
            <xsl:if test="$sub-section/eft:abstract/*">
                <summary type="text">
                    <xsl:value-of select="normalize-space(data($sub-section/eft:abstract))"/>
                </summary>
                <eft:abstract>
                    <xsl:apply-templates select="$sub-section/eft:abstract" exclude-result-prefixes="xhtml"/>
                </eft:abstract>
            </xsl:if>
            
        </entry>
        
    </xsl:template>
    
    <xsl:template name="text-entry">
        
        <xsl:param name="text" required="yes" as="element(eft:text)"/>
        
        <entry>
            
            <title>
                <xsl:value-of select="$text/eft:titles/eft:title[@xml:lang eq 'en']"/>
            </title>
            
            <id>
                <xsl:value-of select="concat('http://read.84000.co/translation/', lower-case($text/@resource-id))"/>
            </id>
            
            <updated>
                <xsl:value-of select="$text/@last-updated"/>
            </updated>
            
            <author>
                <name>84000: Translating the Words of the Buddha</name>
                <uri>http://84000.co</uri>
            </author>
            
            <dc:publisher>84000: Translating the Words of the Buddha</dc:publisher>
            
            <dc:language>en</dc:language>
            
            <dc:issued>
                <xsl:value-of select="$text/eft:translation/eft:publication-date"/>
            </dc:issued>
            
            <category scheme="https://bisg.org/page/BISACEdition" term="REL007050" label="RELIGION / Buddhism / Tibetan"/>
            <category scheme="https://bisg.org/page/BISACEdition" term="REL007030" label="RELIGION / Buddhism / Sacred Writings"/>
            
            <eft:toh>
                <xsl:copy-of select="$text/eft:toh/@*"/>
                <xsl:copy-of select="$text/eft:toh/eft:*"/>
            </eft:toh>
            
            <eft:titles>
                <xsl:for-each select="$text/eft:titles/eft:title">
                    <eft:title>
                        <xsl:attribute name="xml:lang" select="@xml:lang"/>
                        <xsl:value-of select="."/>
                    </eft:title>
                </xsl:for-each>
            </eft:titles>
            
            <eft:title-variants>
                <xsl:for-each select="$text/eft:title-variants/eft:title">
                    <eft:title>
                        <xsl:attribute name="xml:lang" select="@xml:lang"/>
                        <xsl:value-of select="."/>
                    </eft:title>
                </xsl:for-each>
            </eft:title-variants>
            
            <xsl:if test="$text/eft:part[@type eq 'summary']/*">
                <summary type="text">
                    <xsl:value-of select="data($text/eft:part[@type eq 'summary']/tei:p) ! normalize-space()"/>
                </summary>
                <eft:summary>
                    <xsl:apply-templates select="$text/eft:part[@type eq 'summary']" exclude-result-prefixes="xhtml"/>
                </eft:summary>
            </xsl:if>
            
            <xsl:for-each select="$text/eft:files/eft:file[@type = ('pdf','epub')][@group eq 'translation-files'][@timestamp gt '']">
                <xsl:variable name="download" select="."/>
                <link>
                    <xsl:choose>
                        <xsl:when test="$download[@type eq 'epub']">
                            <xsl:attribute name="type" select="'application/epub+zip'"/>
                        </xsl:when>
                        <xsl:when test="$download[@type eq 'pdf']">
                            <xsl:attribute name="type" select="'application/pdf'"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:attribute name="href" select="$download/@source"/>
                    <xsl:attribute name="rel" select="'http://opds-spec.org/acquisition/open-access'"/>
                </link>
            </xsl:for-each>
            
            <link>
                <xsl:attribute name="type" select="'text/html'"/>
                <xsl:attribute name="href" select="concat('/translation/', lower-case($text/@resource-id), '.html')"/>
                <xsl:attribute name="rel" select="'http://opds-spec.org/acquisition/open-access'"/>
            </link>
            
        </entry>
        
    </xsl:template>
    
</xsl:stylesheet>