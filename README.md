# DocTest C++ to Ant JUnit

Converts DocTest C++ XML to 
[Ant JUnit](https://github.com/windyroad/JUnit-Schema/blob/master/JUnit.xsd)
flavor of JUnit XML.

This was created so DocTest C++ XML can be ingested by 
[Jenkins xUnit plugin](https://plugins.jenkins.io/xunit/).

## Caveats 

- testsuite element
    - `id` attribute defaults to index of doctest testsuite element
    - `package` - attribute defaults to doctest binary attribute with path 
    removed (note that this is not used by Jenkins JUnit)
    - `name` attribute **must be unique**, if doctest testsuite name is missing,
    it will default to index of testsuite element plus first testcase filename 
    with path and file extension removed, e.g., index of `1` and filename of 
    `/path/to/bar.cpp` will become `1_bar`
    - `hostname` attribute defaults to `N/A`
    - `timestamp` attribute defaults to date/time doctest transform occurred
    - `errors` attribute defaults to zero
    - `failures` attribute is the count of testcases that have failures
    - `time` attribute is the execution duration for a testcase truncated
    to 3 decimal places (this fixes Jenkins xUnit issue: https://issues.jenkins-ci.org/browse/JENKINS-52152)
- testcase element
    - `classname` attribute defaults to doctest binary attribute with path 
    remove, followed by a period, and then filename with path and file 
    extension removed, e.g., binary `path/to/foo` and filename 
    `path/to/bar.cpp` becomes `foo.bar` (this fixes Jenkins JUnit issue:
    https://stackoverflow.com/questions/49852378/junit-plugin-not-showing-results-from-all-tests-in-jenkins)
    - `time` attribute is the sum of execution duration for testcases truncated
    to 3 decimal places (this fixes Jenkins xUnit issue: https://issues.jenkins-ci.org/browse/JENKINS-52152)
    - `failures` element is added if one or more failures occur, the`type` 
    attribute is left blank, `message` attribute contains OverallResultsAsserts 
    info, and `text` body will contain contents of failures and errors formatted

## Usage

### Jenkins xUnit

Copy `doctest-cpp-to-ant-junt.xsl` over to:

    $JENKINS_HOME/userContent/doctestcpp.xsl

It should then be visible under:
 
    http(s)://$JENKINS_URL/userContent/doctestcpp.xsl
    
Jenkins pipeline call example:

    pipeline {
        agent any
        stages {
            stage('Test'){
                steps {
                    sh "run_tests.bash"
                }
            }
        }
        post {
            always{
                xunit (
                    thresholds: [ skipped(failureThreshold: '0'), failed(failureThreshold: '0') ],
                    tools: [ Custom(customXSL: 'http(s)://$JENKINS_URL/userContent/doctestcpp.xsl', pattern: 'test/*.xml') ]
                )
            }
        }
    }
    
Known issues:

- When Jenkins anonymous user has no access rights, userContent is inaccessible 
resulting in a "403 Forbidden Error". Use a url outside of Jenkins instead.
- If you see random code coverage reporting by Jenkins, it is probably related 
to doctest testsuite name being repeated. Make sure your doctest testsuite 
names are unique.
- Doctest doesn't filter out non-printable chars. If you see "ERROR: 
Error occurs on the use of the user stylesheet: Error to convert the input XML 
document," check if doctest xml is valid by running a linter, e.g.,
`xmllint --noout doctest.xml`.  Tip: use sed to filter out 
non-printable chars like control symbols, e.g., 
`${test_binary} -s -d --reporters=xml | s/[[:cntrl:]]//g > doctest.xml`.

## Testing

The `test.sh` script will; execute
doctest-cpp-to-ant-junit.xsl against doctest *.cpp_xml.txt examples,
and validate its output against ant-junit.xsd.

> The `test_input` directory was created by cloning 
`git@github.com:onqtam/doctest.git` and copying the contents of 
`examples/all_features/test_output` directory over to it.

A Dockerfile is provided to setup the xslt test environment:

    docker build . -t doctest
    docker run -it --rm -v $(pwd):/doctest doctest /bin/bash

Be sure to run `./clean.sh` after running `./test.sh`, since docker 
will create files as root.

## References

- http://nelsonwells.net/2012/09/how-jenkins-ci-parses-and-displays-junit-output/
- https://stackoverflow.com/questions/49852378/junit-plugin-not-showing-results-from-all-tests-in-jenkins
- https://github.com/onqtam/doctest/blob/master/doc/markdown/reporters.md
- https://github.com/catchorg/Catch2/blob/master/docs/reporters.md
- https://github.com/windyroad/JUnit-Schema/blob/master/JUnit.xsd
- https://plugins.jenkins.io/xunit/
- https://jenkins.io/doc/pipeline/steps/xunit/
