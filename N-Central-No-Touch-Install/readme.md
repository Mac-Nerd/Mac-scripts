Create a folder "Scripts" and copy "postinstall" and "include.sh" into it.

Be sure they are set executable:
`chmod -R a+x Scripts`

Edit "include.sh" with correct values for the server, version, customer name, and token information.

Build a no-payload installer PKG
`pkgbuild --nopayload --scripts Scripts --identifier com.option8.ncentral --version 2024.01.08 sample-installer.pkg`

Upload to Intune or MDM of choice, and deploy as a normal installer PKG.

