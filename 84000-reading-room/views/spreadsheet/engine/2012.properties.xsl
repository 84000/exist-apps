<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!--
        Excel 2012 properties file

        @author Pavel Ptacek
        @copyright Pavel Ptacek (c) 2012-2013
    -->

    <xsl:template name="generate_properties">
        <xsl:param name="sheetNames">
            <name>Sheet1</name>
        </xsl:param>
        <xsl:param name="author">YOURCOMPANY</xsl:param>

        <!-- app.xml properties file -->
        <m:entry href="docProps/app.xml">
            <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
              <Application>Microsoft Excel</Application>
              <DocSecurity>0</DocSecurity>
              <ScaleCrop>false</ScaleCrop>
              <HeadingPairs>
                <vt:vector size="2" baseType="variant">
                  <vt:variant>
                    <vt:lpstr>Worksheets</vt:lpstr>
                  </vt:variant>
                  <vt:variant>
                    <vt:i4>
                                <xsl:value-of select="count($sheetNames/name)"/>
                            </vt:i4>
                  </vt:variant>
                </vt:vector>
              </HeadingPairs>
              <TitlesOfParts>
                <vt:vector size="{count($sheetNames/name)}" baseType="lpstr">
                    <xsl:for-each select="$sheetNames/name">
                      <vt:lpstr>
                                <xsl:value-of select="."/>
                            </vt:lpstr>
                    </xsl:for-each>
                </vt:vector>
              </TitlesOfParts>
              <LinksUpToDate>false</LinksUpToDate>
              <SharedDoc>false</SharedDoc>
              <HyperlinksChanged>false</HyperlinksChanged>
              <AppVersion>15.0300</AppVersion>
            </Properties>
        </m:entry>

        <!-- core.xml document -->
        <m:entry href="docProps/core.xml">
            <coreProperties xmlns="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/">
              <dc:creator>
                    <xsl:value-of select="$author"/>
                </dc:creator>
              <lastModifiedBy>
                    <xsl:value-of select="$author"/>
                </lastModifiedBy>
              <dcterms:created xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="current-dateTime()"/>
                </dcterms:created>
              <dcterms:modified xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="current-dateTime()"/>
                </dcterms:modified>
            </coreProperties>
        </m:entry>
    </xsl:template>

</xsl:stylesheet>