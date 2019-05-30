<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/2005/Atom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="http://exist-db.org/xquery/util" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:output method="xml" indent="no" encoding="UTF-8" media-type="text/xml"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="feed-type" select="if(m:request/@resource-suffix eq 'acquisition.atom') then 'acquisition' else 'navigation'"/>
        
        <feed xmlns:fh="http://purl.org/syndication/history/1.0" xmlns:opds="http://opds-spec.org/2010/catalog" xmlns:dc="http://purl.org/dc/terms/">
            
            <id>
                <xsl:value-of select="concat('http://read.84000.co/section/', upper-case(m:section/@id), '/', $feed-type)"/>
            </id>
            
            <title>
                <xsl:value-of select="m:section/m:titles/m:title[@xml:lang eq 'en']"/>
            </title>
            
            <icon>http://fe.84000.co/favicon/favicon.ico</icon>
            
            <updated>
                <xsl:value-of select="m:section/@last-updated"/>
            </updated>
            
            <author>
                <name>84000: Translating the Words of the Buddha</name>
                <uri>http://84000.co</uri>
            </author>
            
            <!-- Add a navigation link to start (Lobby) -->
            <link type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/section/lobby.navigation.atom" rel="start" title="The 84000 Reading Room"/>
            
            <!-- Add a navigation link to All Translated -->
            <xsl:if test="not(lower-case(m:section/@id) eq 'all-translated')">
                <link type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/section/all-translated.acquisition.atom" rel="related" title="84000: All Translated Texts"/>
            </xsl:if>
            
            <!-- Add a navigation link to self -->
            <link>
                <xsl:choose>
                    <xsl:when test="$feed-type eq 'acquisition'">
                        <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=acquisition'"/>
                        <xsl:attribute name="href" select="concat('/section/', upper-case(m:section/@id), '.acquisition.atom')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=navigation'"/>
                        <xsl:attribute name="href" select="concat('/section/', upper-case(m:section/@id), '.navigation.atom')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="rel" select="'self'"/>
                <xsl:attribute name="title" select="m:section/m:titles/m:title[@xml:lang eq 'en']"/>
            </link>
            
            <!-- Perhaps add an acquisition link to self -->
            <xsl:if test="$feed-type eq 'navigation' and m:section/m:text-stats/m:stat[@type eq 'count-published-children']/@value gt '0'">
                <link>
                    <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=acquisition'"/>
                    <xsl:attribute name="href" select="concat('/section/', upper-case(m:section/@id), '.acquisition.atom')"/>
                    <xsl:attribute name="rel" select="'self'"/>
                    <xsl:attribute name="title" select="m:section/m:titles/m:title[@xml:lang eq 'en']"/>
                </link>
            </xsl:if>
            
            <!-- All Translated is the complete catalogue -->
            <xsl:if test="lower-case(m:section/@id) eq 'all-translated'">
                <fh:complete/>
            </xsl:if>
            
            <!-- Add a navigation link to parent -->
            <xsl:if test="m:section/m:parent/@id">
                <link>
                    <xsl:attribute name="type" select="'application/atom+xml;profile=opds-catalog;kind=navigation'"/>
                    <xsl:attribute name="href" select="concat('/section/', upper-case(m:section/m:parent/@id), '.navigation.atom')"/>
                    <xsl:attribute name="rel" select="'up'"/>
                    <xsl:attribute name="title" select="m:section/m:parent/m:title[@xml:lang eq 'en']"/>
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
                    <xsl:for-each select="m:section/m:texts/m:text">
                        <xsl:sort select="@last-updated" order="descending"/>
                        <entry>
                            <title>
                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                            </title>
                            <id>
                                <xsl:value-of select="concat('http://read.84000.co/translation/', lower-case(@resource-id))"/>
                            </id>
                            <updated>
                                <xsl:value-of select="@last-updated"/>
                            </updated>
                            <author>
                                <name>84000: Translating the Words of the Buddha</name>
                                <uri>http://84000.co</uri>
                            </author>
                            <dc:publisher>84000: Translating the Words of the Buddha</dc:publisher>
                            <dc:language>en</dc:language>
                            <dc:issued>
                                <xsl:value-of select="m:translation/m:publication-date"/>
                            </dc:issued>
                            <category scheme="https://bisg.org/page/BISACEdition" term="REL007050" label="RELIGION / Buddhism / Tibetan"/>
                            <category scheme="https://bisg.org/page/BISACEdition" term="REL007030" label="RELIGION / Buddhism / Sacred Writings"/>
                            <summary>
                                <xsl:value-of select="m:summary"/>
                            </summary>
                            <xsl:for-each select="m:downloads/m:download[@type = ('epub', 'azw3', 'pdf')]">
                                <link>
                                    <xsl:choose>
                                        <xsl:when test="@type eq 'epub'">
                                            <xsl:attribute name="type" select="'application/epub+zip'"/>
                                        </xsl:when>
                                        <xsl:when test="@type eq 'azw3'">
                                            <xsl:attribute name="type" select="'application/vnd.amazon.mobi8-ebook'"/>
                                        </xsl:when>
                                        <xsl:when test="@type eq 'pdf'">
                                            <xsl:attribute name="type" select="'application/pdf'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:attribute name="href" select="@url"/>
                                    <xsl:attribute name="rel" select="'http://opds-spec.org/acquisition'"/>
                                </link>
                            </xsl:for-each>
                        </entry>
                    </xsl:for-each>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    
                    <!-- Navigation feed: add entries for sub sections -->
                    <xsl:for-each select="m:section/m:descendants">
                        <xsl:variable name="descendant-id" select="@id"/>
                        <xsl:variable name="sub-section" select="/m:response/m:section/m:sub-section[@id eq $descendant-id]"/>
                        
                        <!-- If there are texts add an acquisition entry -->
                        <xsl:if test="m:text-stats/m:stat[@type eq 'count-published-children']/@value gt '0'">
                            <xsl:call-template name="sub-section-entry">
                                <xsl:with-param name="sub-section" select="$sub-section"/>
                                <xsl:with-param name="feed-type" select="'acquisition'"/>
                                <xsl:with-param name="last-updated" select="@last-updated"/>
                            </xsl:call-template>
                        </xsl:if>
                        
                        <!-- If there are more descedant texts then add a navigation entry too -->
                        <xsl:if test="m:text-stats/m:stat[@type eq 'count-published-descendants']/@value gt m:text-stats/m:stat[@type eq 'count-published-children']/@value">
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
        <xsl:param name="sub-section" required="yes" as="element()"/>
        <xsl:param name="feed-type" required="yes" as="xs:string"/>
        <xsl:param name="last-updated" required="yes" as="xs:dateTime"/>
        <entry>
            <title>
                <xsl:value-of select="$sub-section/m:titles/m:title[@xml:lang eq 'en']"/>
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
            <content type="text">
                <xsl:value-of select="$sub-section/m:abstract"/>
            </content>
        </entry>
    </xsl:template>
    
    
</xsl:stylesheet>