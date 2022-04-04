<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" version="2.0">

    <!--
         The excel 2012 workbook file

        @author Pavel Ptacek
        @copyright Pavel Ptacek (c) 2012-2013
    -->

    <xsl:template name="generate_sheets">
        <xsl:param name="sheetNames"/>
        <xsl:param name="sheets"/>
        <xsl:param name="vbas"/>

        <!-- Put the sheetX contents into correct places -->
        <xsl:for-each select="$sheets/*">
            <m:entry href="xl/worksheets/sheet{position()}.xml">
                <xsl:copy-of select="."/>
            </m:entry>
        </xsl:for-each>

        <!-- Generate the workbook.xml -->
        <m:entry href="xl/workbook.xml">
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:x15="http://schemas.microsoft.com/office/spreadsheetml/2010/11/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" mc:Ignorable="x15">
              <fileVersion appName="xl" lastEdited="6" lowestEdited="4" rupBuild="14128"/>
              <workbookPr defaultThemeVersion="124226"/>
              <bookViews>
                <workbookView xWindow="0" yWindow="0" windowWidth="28800" windowHeight="12435"/>
              </bookViews>
              <sheets>
                <xsl:for-each select="$sheetNames/name">
                    <sheet name="{.}" sheetId="{position()}" r:id="rId{position()}"/>
                </xsl:for-each>
              </sheets>
              <calcPr calcId="125725"/>
            </workbook>
        </m:entry>

        <!-- Generate the vba project files -->
        <xsl:if test="$vbas">
            <xsl:for-each select="$vbas/vba">
                <m:entry href="xl/{.}" media-type="text/plain" omit-xml-declaration="yes">
                    <xsl:fallback/>
                </m:entry>
            </xsl:for-each>
        </xsl:if>

        <!-- Generate the empty sharedStrings file -->
        <m:entry href="xl/sharedStrings.xml">
            <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="0" uniqueCount="0"/>
        </m:entry>

    </xsl:template>

</xsl:stylesheet>