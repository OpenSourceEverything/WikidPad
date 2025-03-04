<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>

  <!-- Identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- For horizontal box sizers, remove wxALIGN_CENTRE_VERTICAL if combined with wxEXPAND -->
  <xsl:template match="object[@class='wxBoxSizer' and orient='wxHORIZONTAL']//flag">
    <flag>
      <xsl:value-of select="replace(., 'wxEXPAND\s*\|\s*wxALIGN_CENTRE_VERTICAL', 'wxEXPAND')"/>
    </flag>
  </xsl:template>

  <!-- For vertical box sizers, remove wxALIGN_CENTRE_VERTICAL entirely -->
  <xsl:template match="object[@class='wxBoxSizer' and orient='wxVERTICAL']//flag">
    <flag>
      <xsl:value-of select="replace(., 'wxALIGN_CENTRE_VERTICAL', '')"/>
    </flag>
  </xsl:template>
</xsl:stylesheet>