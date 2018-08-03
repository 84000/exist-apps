This is a simple eXist-db appllication that enables users to convert conformant Microsoft Word documents[^1] into XML documents that validate against an 84000-project schema. Both the original Word document and the TEI derivative are stored in the eXist-db.

# Configuration #
There are several variables that can be used to configure the application; see modules/config.xqm.

# Installation #
  * Run `ant` in the top-level directory to generate a .xar file in the build/ directory.
  * Use eXist's Package Manager to install the .xar file.

# Command-line usage #
Users can use eXist's standard rest interface to post documents to the application:

> curl -v -F file-upload=@sample1.docx \ 
> http://localhost:8080/exist/apps/84000-import/modules/upload-process.xq

[^1]: The Word documents must in .docx format and conform with specifications provided by 84000.
