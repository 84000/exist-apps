xquery version "3.0";

module namespace local="http://utilities.84000.co/local";

declare namespace pkg="http://expath.org/ns/pkg";

declare function local:app-version() as xs:string {
    doc('../expath-pkg.xml')/pkg:package/@version
};

