<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">

    <!-- Use this output header to return xml for debugging -->
    <xsl:output method="xml" indent="no" encoding="UTF-8" media-type="application/xml"/>
    <!-- <xsl:output method="xml" indent="no" encoding="UTF-8" media-type="application/rdf+xml"/> -->

    <xsl:variable name="contributors" select="doc(concat(/m:response/@data-path, '/operations/contributors.xml'))"/>
    <xsl:variable name="collections" select="doc(concat(/m:response/@data-path, '/operations/collection-refs.xml'))"/>
    <xsl:variable name="texts" select="doc(concat(/m:response/@data-path, '/operations/text-refs.xml'))"/>

    <xsl:template match="/m:response">
        
        <!-- Get additional collection data -->
        <xsl:variable name="source-work" select="m:translation/m:source/m:location/@work" as="xs:string"/>
        <xsl:variable name="collection-refs" select="$collections//m:collection[@work eq $source-work]"/>
        <xsl:variable name="collection-id" select="$collection-refs/@key" as="xs:string"/>
        
        <!-- Get additional text data -->
        <xsl:variable name="text-key" select="m:translation/m:source/m:location/@key" as="xs:string"/>
        <xsl:variable name="text-refs" select="$texts//m:text[@key eq $text-key]"/>
        <xsl:variable name="bdrc-work-id" select="$text-refs/m:ref[@type eq 'bdrc-work-id']/@value" as="xs:string?"/>
        <xsl:variable name="bdrc-derge-id" select="$text-refs/m:ref[@type eq 'bdrc-derge-id']/@value" as="xs:string?"/>
        
        <!-- Set ids -->
        <xsl:variable name="eft-id" select="upper-case($text-key)"/>
        <xsl:variable name="eft-indic-id" select="'WAI' || $eft-id" as="xs:string"/>
        <xsl:variable name="eft-english-id" select="'WAE' || $eft-id" as="xs:string"/>
        <xsl:variable name="eft-tibetan-id" select="'WAT' || $eft-id" as="xs:string"/>
        <xsl:variable name="eft-derge-id" select="'WEKD' || $eft-id" as="xs:string"/>
        
        <rdf:RDF xmlns:eftr="http://purl.84000.co/resource/core/" xmlns:bdr="http://purl.bdrc.io/resource/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:adm="http://purl.bdrc.io/ontology/admin/" xmlns:bdo="http://purl.bdrc.io/ontology/core/" xmlns:bda="http://purl.bdrc.io/admindata/"> 
            
            <xsl:comment>Some admin data</xsl:comment>
            <rdf:Description rdf:about="http://purl.84000.co/resource/core/DatasetAdminData">
                <bda:metadataLegal rdf:resource="http://purl.84000.co/resource/core/LegalData"/>
                <xsl:if test="$collection-id">
                    <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $collection-id }"/>
                </xsl:if>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-derge-id }"/>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }"/>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-english-id }"/>
                <adm:adminAbout rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }"/>
                <adm:graphId rdf:resource="http://purl.84000.co/resource/core/Dataset"/>
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/admin/AdminData"/>
            </rdf:Description>
            
            <xsl:comment>Content provider</xsl:comment>
            <rdf:Description rdf:about="http://purl.84000.co/resource/core/EFT">
               <rdf:type rdf:resource="http://purl.bdrc.io/ontology/admin/ContentProvider"/>
               <rdfs:label>84000</rdfs:label>
            </rdf:Description>
            
            <xsl:comment>Legal data</xsl:comment>
            <rdf:Description rdf:about="http://purl.84000.co/resource/core/LegalData">
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/admin/LegalData"/>
                <adm:provider rdf:resource="http://purl.84000.co/resource/core/EFT"/>
                <adm:license rdf:resource="http://purl.bdrc.io/admindata/LicenseCC0"/>
                <adm:copyrightOwner rdf:resource="http://purl.84000.co/resource/core/EFT"/>
                <skos:prefLabel xml:lang="en">Metadata related to the translations by 84000, provided under the CC0 License</skos:prefLabel>
            </rdf:Description>
            
            <xsl:comment>The collection</xsl:comment>
            <xsl:choose>
                <xsl:when test="$collection-id eq 'WKangyurD'">
                    <xsl:comment>- The Derge Kangyur</xsl:comment>
                    <rdf:Description rdf:about="http://purl.84000.co/resource/core/WKangyurD">
                        <owl:sameAs rdf:resource="http://purl.bdrc.io/resource/W4CZ5369"/>
                        <adm:sameAsBDRC rdf:resource="http://purl.bdrc.io/resource/W4CZ5369"/>
                        <bdo:workLangScript rdf:resource="http://purl.bdrc.io/resource/BoDbuCan"/>
                        <skos:prefLabel xml:lang="en">
                            <xsl:value-of select="$collection-refs/m:label"/>
                        </skos:prefLabel>
                        <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                    </rdf:Description>
                </xsl:when>
            </xsl:choose>
            
            <xsl:comment>The abstract work of the Indic text</xsl:comment>
            <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }">
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/AbstractWork"/>
                <xsl:if test="$bdrc-work-id">
                    <owl:sameAs rdf:resource="{ 'http://purl.bdrc.io/resource/' || $bdrc-work-id }"/>
                    <adm:sameAsBDRC rdf:resource="{ 'http://purl.bdrc.io/resource/' || $bdrc-work-id }"/>
                </xsl:if>
                <bdo:workLangScript rdf:resource="http://purl.bdrc.io/resource/Inc"/>
                <bdo:workHasTranslation rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-english-id }"/>
                <bdo:workHasTranslation rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }"/>
                <xsl:if test="m:translation/m:titles/m:title[@xml:lang eq 'sa-ltn']/text()">
                    <skos:prefLabel xml:lang="sa-x-iast">
                        <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'sa-ltn']"/>
                    </skos:prefLabel>
                </xsl:if>
                <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'sa-ltn']/text()">
                    <skos:altLabel xml:lang="sa-x-iast">
                        <xsl:value-of select="m:translation/m:long-titles/m:title[@xml:lang eq 'sa-ltn']"/>
                    </skos:altLabel>
                </xsl:if>
                <xsl:if test="m:translation/m:titles/m:title[@xml:lang eq 'en']/text()">
                    <skos:prefLabel xml:lang="en">
                        <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                    </skos:prefLabel>
                </xsl:if>
                <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'en']/text()">
                    <skos:altLabel xml:lang="en">
                        <xsl:value-of select="m:translation/m:long-titles/m:title[@xml:lang eq 'en']"/>
                    </skos:altLabel>
                </xsl:if>
            </rdf:Description>
            
            <xsl:comment>The Derge edition of the Tibetan translation</xsl:comment>
            <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-derge-id }">
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                <bdo:workLangScript rdf:resource="http://purl.bdrc.io/resource/BoDbuCan"/>
                <xsl:if test="$bdrc-derge-id">
                    <owl:sameAs rdf:resource="{ 'http://purl.bdrc.io/resource/' || $bdrc-derge-id }"/>
                    <adm:sameAsBDRC rdf:resource="{ 'http://purl.bdrc.io/resource/' || $bdrc-derge-id }"/>
                </xsl:if>
                <xsl:if test="$collection-id">
                    <bdo:workPartOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $collection-id }"/>
                </xsl:if>
                <bdo:workExpressionOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }"/>
                <xsl:if test="m:translation/m:titles/m:title[@xml:lang eq 'bo']/text()">
                    <skos:prefLabel xml:lang="bo">
                        <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                    </skos:prefLabel>
                </xsl:if>
            </rdf:Description>
            
            <xsl:comment>The original Tibetan translation</xsl:comment>
            <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-tibetan-id }">
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/AbstractWork"/>
                <xsl:if test="$bdrc-work-id">
                    <owl:sameAs rdf:resource="{ 'http://purl.bdrc.io/resource/' || $bdrc-work-id }"/>
                    <adm:sameAsBDRC rdf:resource="{ 'http://purl.bdrc.io/resource/' || $bdrc-work-id }"/>
                </xsl:if>
                <bdo:workLangScript rdf:resource="http://purl.bdrc.io/resource/Bo"/>
                <bdo:workHasExpression rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-derge-id }"/>
                <bdo:workTranslationOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }"/>
                <xsl:if test="m:translation/m:titles/m:title[@xml:lang eq 'bo']/text()">
                    <skos:prefLabel xml:lang="bo">
                        <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                    </skos:prefLabel>
                </xsl:if>
                <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'bo']/text()">
                    <skos:altLabel xml:lang="bo">
                        <xsl:value-of select="m:translation/m:long-titles/m:title[@xml:lang eq 'bo']"/>
                    </skos:altLabel>
                </xsl:if>
                <xsl:if test="$text-refs/m:ref[@type eq 'rkts-work-id']">
                    <bdo:workRefrKTsK rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
                        <xsl:value-of select="$text-refs/m:ref[@type eq 'rkts-work-id']/@value"/>
                    </bdo:workRefrKTsK>
                </xsl:if>
            </rdf:Description>
            
            <xsl:if test="m:translation/@status-group eq 'published'">
                <xsl:comment>The English translation</xsl:comment>
                <rdf:Description rdf:about="{ 'http://purl.84000.co/resource/core/' || $eft-english-id }">
                    <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/Work"/>
                    <rdf:type rdf:resource="http://purl.bdrc.io/ontology/core/AbstractWork"/>
                    <bdo:workTranslationOf rdf:resource="{ 'http://purl.84000.co/resource/core/' || $eft-indic-id }"/>
                    <bdo:workLangScript rdf:resource="http://purl.bdrc.io/resource/En"/>
                    <xsl:if test="m:translation/m:titles/m:title[@xml:lang eq 'en']/text()">
                        <skos:prefLabel xml:lang="en">
                            <xsl:value-of select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                        </skos:prefLabel>
                    </xsl:if>
                    <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'en']/text()">
                        <skos:altLabel xml:lang="en">
                            <xsl:value-of select="m:translation/m:long-titles/m:title[@xml:lang eq 'en']"/>
                        </skos:altLabel>
                    </xsl:if>
                    <adm:canonicalHtml rdf:resource="{ m:translation/@page-url }"/>
                    <xsl:if test="m:translation/m:translation/m:contributors/m:author[@role = 'translatorEng']">
                        <xsl:comment>Creators</xsl:comment>
                        <xsl:for-each select="m:translation/m:translation/m:contributors/m:author[@role = 'translatorEng']">
                            <xsl:variable name="contributor-id" select="substring-after(@ref, 'contributors.xml#')"/>
                            <xsl:variable name="contributor" select="$contributors//m:person[@xml:id eq $contributor-id]"/>
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
            
        </rdf:RDF>

    </xsl:template>


</xsl:stylesheet>