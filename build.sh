#!/bin/bash


  for f in *.svg
  do
    cp $f $f.orig
     rm $f.post


#     xmlstarlet ed -d "//svg:g/@inkscape:label" | xmlstarlet ed -d "//svg:g/@inkscape:groupmode" | \
#     xmlstarlet ed -d "//svg:rect/@style" | \
#     xmlstarlet ed -d "//svg:path/@style" | \
#     xmlstarlet ed -d "//svg:text/@style" | \
#     xmlstarlet ed -d "//svg:text/svg:tspan"  | \

    cat $f | \
    xmlstarlet ed -d "//sodipodi:namedview" | xmlstarlet ed -d "//svg:metadata" | \
    xmlstarlet ed -d "//@inkscape:version" | xmlstarlet ed -d "//@sodipodi:docname" | \
    xmlstarlet ed -d "//svg:text/@stroke" > $f.prepost
    svgcheck -a -r -g $f.prepost > $f.post

    # rm $f.1
    done

echo -- reduction
D=hierarchical-snps

xml2rfc $D.xml
xml2rfc --pdf $D.xml

nl -ba $D.txt > $D.nl.txt

