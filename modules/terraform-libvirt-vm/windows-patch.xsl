<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- Identity transform to copy everything as is -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Add Tablet to fix mouse issues in Windows VM -->
  <xsl:template match="/domain/devices">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <input type="tablet" bus="usb"/>
    </xsl:copy>
  </xsl:template>

  <!-- Use SATA disk for Windows setup to avoid embedding virtio drivers-->
  <xsl:template match="disk[target/@bus='virtio']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <driver name="qemu" type="qcow2" discard="unmap"/>
      <target dev="sda" bus="sata"/>
      <xsl:apply-templates select="node()[not(self::driver or self::target)]"/>
    </xsl:copy>
  </xsl:template>

  <!-- Use SATA CD-ROM for Windows setup for UEFI compability -->
  <xsl:template match="disk[target/@bus='ide']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <target dev="sdb" bus="sata"/>
      <xsl:apply-templates select="node()[not(self::target)]"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
