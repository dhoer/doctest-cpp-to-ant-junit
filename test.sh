#!/usr/bin/env bash

for test_path in $(find test_input/*.cpp_xml.txt)
do
  if [ "$test_path" != "test_input/asserts_used_outside_of_tests.cpp_xml.txt" ]
  then
    echo "$test_path"
    cat $test_path|sed '/Program code\./d' > $test_path.doctest
    saxonb-xslt -s:$test_path.doctest -xsl:doctest-cpp-to-ant-junit.xsl -o:$test_path.xml
    xmllint --noout --schema ant-junit.xsd $test_path.xml
  fi
done
