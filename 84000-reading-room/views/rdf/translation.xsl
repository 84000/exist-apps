<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="xsl xs tei m" version="3.0">

    <!-- Use this output header to return xml for debugging -->
    <xsl:output method="xml" indent="no" encoding="UTF-8" media-type="application/xml"/>
    <!-- <xsl:output method="xml" indent="no" encoding="UTF-8" media-type="application/rdf+xml"/> -->

    <xsl:variable name="contributors" select="doc(concat(/m:response/@data-path, '/operations/contributors.xml'))"/>
    <xsl:variable name="collections" select="doc(concat(/m:response/@data-path, '/config/linked-data/collection-refs.xml'))"/>
    <xsl:variable name="texts" select="doc(concat(/m:response/@data-path, '/config/linked-data/text-refs.xml'))"/>

    <xsl:template match="/m:response">
        
        <!-- Get additional collection data -->
        <xsl:variable name="source-work" select="m:translation/m:source/m:location/@work" as="xs:string"/>
        <xsl:variable name="collection-refs" select="$collections//m:collection[@work eq $source-work]"/>
        
        <xsl:variable name="collection-id" select="$collection-refs/@key" as="xs:string"/>
        
        <!-- Get additional text data -->
        <xsl:variable name="text-key" select="m:translation/m:source/m:location/@key" as="xs:string"/>
        <xsl:variable name="text-refs" select="$texts//m:text[@key eq $text-key]"/>
        <xsl:variable name="bdrc-work-id" select="$text-refs/m:ref[@type eq 'bdrc-work-id']/@value" as="xs:string?"/>
        <xsl:variable name="bdrc-tibetan-id" select="$text-refs/m:ref[@type eq 'bdrc-tibetan-id']/@value" as="xs:string?"/>
        <xsl:variable name="bdrc-derge-id" select="$text-refs/m:ref[@type eq 'bdrc-derge-id']/@value" as="xs:string?"/>
        
        <!-- Set ids -->
        <xsl:variable name="eft-id" select="upper-case($text-key)"/>
        <xsl:variable name="eft-indic-id" select="'WAI' || $eft-id" as="xs:string"/>
        <xsl:variable name="eft-english-id" select="'WAE' || $eft-id" as="xs:string"/>
        <xsl:variable name="eft-tibetan-id" select="'WAT' || $eft-id" as="xs:string"/>
        <xsl:variable name="eft-derge-id" select="'WEKD' || $eft-id" as="xs:string"/>
        
        <rdf:RDF xmlns:eftr="http://purl.84000.co/resource/core/" xmlns:bdr="http://purl.bdrc.io/resource/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:adm="http://purl.bdrc.io/ontology/admin/" xmlns:bdo="http://purl.bdrc.io/ontology/core/" xmlns:bda="http://purl.bdrc.io/admindata/"> 
            
            <xsl:comment>Some admin data</xsl:comment>
            <rdf:Description rdf:about="http://purl.84000.co/resource/core/DatasetAdminData">
                <adm:metadataLegal rdf:resource="http://purl.84000.co/resource/core/LegalData"/>
                <xsl:if test="$collection-id">
                    <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $collection-id }"/>
                </xsl:if>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-derge-id }"/>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }"/>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-english-id }"/>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }"/>
                <adm:graphId rdf:resource="http://purl.84000.co/resource/core/Dataset"/>
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/admin/AdminData"/>
                <adm:canonicalHtml rdf:resource="http://84000.co/about/copyright"/>
            </rdf:Description>
            
            <xsl:comment>Content provider</xsl:comment>
            <rdf:Description rdf:about="http://purl.84000.co/resource/core/EFT">
               <rdf:type rdf:resource="http://purl.bdrc.io/ontology/admin/ContentProvider"/>
               <rdfs:label>84000</rdfs:label>
               <adm:canonicalHtml rdf:resource="http://84000.co"/>
            </rdf:Description>
            
            <xsl:comment>Legal data</xsl:comment>
            <rdf:Description rdf:about="http://purl.84000.co/resource/core/LegalData">
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/admin/LegalData"/>
                <adm:provider rdf:resource="http://purl.84000.co/resource/core/EFT"/>
                <adm:license rdf:resource="http://purl.bdrc.io/admindata/LicenseCC0"/>
                <adm:copyrightOwner rdf:resource="http://purl.84000.co/resource/core/EFT"/>
                <skos:prefLabel xml:lang="en">Metadata related to the translations by 84000, provided under the CC0 License</skos:prefLabel>
                <adm:canonicalHtml rdf:resource="http://84000.co/about/copyright"/>
            </rdf:Description>
            
            <xsl:comment>The collection</xsl:comment>
            <xsl:choose>
                <xsl:when test="$collection-id eq 'WKangyurD'">
                    <xsl:comment>- The Derge Kangyur</xsl:comment>
                    <rdf:Description rdf:about="http://purl.84000.co/resource/core/WKangyurD">
                        <owl:sameAs rdf:resource="http://purl.bdrc.io/resource/MW22084"/>
                        <bdo:script rdf:resource="http://purl.bdrc.io/resource/ScriptDbuCan"/>
                        <skos:prefLabel xml:lang="en">
                            <xsl:value-of select="$collection-refs/m:label"/>
                        </skos:prefLabel>
                        <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Instance"/>
                        <adm:canonicalHtml rdf:resource="http://read.84000.co/section/O1JC11494.html"/>
                    </rdf:Description>
                </xsl:when>
            </xsl:choose>
            
            <!-- Check the refs are found in the config -->
            <xsl:if test="$text-refs">
                
                <xsl:comment>The abstract work of the Indic text</xsl:comment>
                <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }">
                    <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                    <xsl:if test="$bdrc-work-id">
                        <owl:sameAs rdf:resource="{ $bdrc-work-id }"/>
                    </xsl:if>
                    <bdo:language rdf:resource="http://purl.bdrc.io/resource/LangInc"/>
                    <bdo:workHasTranslation rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-english-id }"/>
                    <bdo:workHasTranslation rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }"/>
                    <xsl:call-template name="translation-titles">
                        <xsl:with-param name="lang" select="'Sa-Ltn'"/>
                    </xsl:call-template>
                    <xsl:call-template name="translation-titles">
                        <xsl:with-param name="lang" select="'en'"/>
                    </xsl:call-template>
                    <adm:canonicalHtml rdf:resource="{ m:translation/@canonical-html }"/>
                </rdf:Description>
                
                <xsl:comment>The Derge edition of the Tibetan translation</xsl:comment>
                <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-derge-id }">
                    <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Instance"/>
                    <xsl:if test="$bdrc-derge-id">
                        <owl:sameAs rdf:resource="{ $bdrc-derge-id }"/>
                    </xsl:if>
                    <bdo:script rdf:resource="http://purl.bdrc.io/resource/ScriptDbuCan"/>
                    <xsl:if test="$collection-id">
                        <bdo:partOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $collection-id }"/>
                    </xsl:if>
                    <bdo:instanceOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }"/>
                    <xsl:call-template name="translation-titles">
                        <xsl:with-param name="lang" select="'bo'"/>
                    </xsl:call-template>
                    <adm:canonicalHtml rdf:resource="{ m:translation/@canonical-html }"/>
                </rdf:Description>
                
                <xsl:comment>The original Tibetan translation</xsl:comment>
                <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }">
                    <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                    <xsl:if test="$bdrc-tibetan-id">
                        <owl:sameAs rdf:resource="{ $bdrc-tibetan-id }"/>
                    </xsl:if>
                    <bdo:language rdf:resource="http://purl.bdrc.io/resource/LangBo"/>
                    <bdo:workHasInstance rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-derge-id }"/>
                    <bdo:workTranslationOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }"/>
                    <xsl:call-template name="translation-titles">
                        <xsl:with-param name="lang" select="'bo'"/>
                    </xsl:call-template>
                    <xsl:if test="$text-refs/m:ref[@type eq 'rkts-work-id']">
                        <bf:identifiedBy>
                            <bdr:RefrKTsK>
                                <rdf:value>
                                    <xsl:value-of select="$text-refs/m:ref[@type eq 'rkts-work-id']/@value"/>
                                </rdf:value>
                            </bdr:RefrKTsK>
                        </bf:identifiedBy>
                    </xsl:if>
                    <adm:canonicalHtml rdf:resource="{ m:translation/@canonical-html }"/>
                </rdf:Description>
                
                <xsl:if test="m:translation/@status-group eq 'published'">
                    <xsl:comment>The English translation</xsl:comment>
                    <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-english-id }">
                        <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                        <bdo:workTranslationOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }"/>
                        <bdo:language rdf:resource="http://purl.bdrc.io/resource/LangEn"/>
                        <xsl:call-template name="translation-titles">
                            <xsl:with-param name="lang" select="'en'"/>
                        </xsl:call-template>
                        <adm:canonicalHtml rdf:resource="{ m:translation/@canonical-html }"/>
                        <xsl:if test="m:translation/m:publication/m:contributors/m:author[@role = 'translatorEng']">
                            <xsl:comment>Creators</xsl:comment>
                            <xsl:for-each select="m:translation/m:publication/m:contributors/m:author[@role = 'translatorEng']">
                                <xsl:variable name="contributor-id" select="replace(@ref, '^(EFT:|contributors\.xml#)', '', 'i')"/>
                                <xsl:variable name="contributor" select="$contributors//m:person[@xml:id eq lower-case($contributor-id)]"/>
                                <xsl:if test="$contributor">
                                    <bdo:creator>
                                        <bdo:AgentAsCreator>
                                            <bdo:agent>
                                                <bdo:Person>
                                                    <xsl:attribute name="rdf:about" select="concat('http://purl.84000.co/resource/core/', $contributor/@xml:id)"/>
                                                    <skos:prefLabel xml:lang="en">
                                                        <xsl:value-of select="$contributor/m:label"/>
                                                    </skos:prefLabel>
                                                    <xsl:if test="$contributor/m:ref[@type eq 'viaf']">
                                                        <bdo:sameAsVIAF>
                                                            <xsl:attribute name="rdf:resource" select="$contributor/m:ref[@type eq 'viaf']/@uri"/>
                                                        </bdo:sameAsVIAF>
                                                    </xsl:if>
                                                </bdo:Person>
                                            </bdo:agent>
                                            <bdo:role rdf:resource="http://purl.bdrc.io/resource/R0ER0017"/>
                                        </bdo:AgentAsCreator>
                                    </bdo:creator>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </rdf:Description>
                </xsl:if>
                
            </xsl:if>
            
        </rdf:RDF>

    </xsl:template>
    
    <xsl:template name="translation-titles">
        <xsl:param name="lang" as="xs:string"/>
        <xsl:if test="m:translation/m:titles/m:title[@xml:lang eq $lang]/text()">
            <skos:prefLabel>
                <xsl:call-template name="set-xml-lang">
                    <xsl:with-param name="lang" select="$lang"/>
                </xsl:call-template>
                <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq $lang]"/>
            </skos:prefLabel>
        </xsl:if>
        <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq $lang]/text()">
            <skos:altLabel>
                <xsl:call-template name="set-xml-lang">
                    <xsl:with-param name="lang" select="$lang"/>
                </xsl:call-template>
                <xsl:value-of select="m:translation/m:long-titles/m:title[@xml:lang eq $lang]"/>
            </skos:altLabel>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="set-xml-lang">
        <xsl:param name="lang" as="xs:string"/>
        <xsl:attribute name="xml:lang">
            <xsl:choose>
                <xsl:when test="$lang eq 'Sa-Ltn'">
                    <xsl:value-of select="'sa-x-iast'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$lang"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

</xsl:stylesheet>