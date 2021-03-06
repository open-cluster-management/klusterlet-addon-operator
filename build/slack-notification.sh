# Copyright (c) 2020 Red Hat, Inc.
# Copyright Contributors to the Open Cluster Management project

#!/bin/bash
###############################################################################
# (c) Copyright IBM Corporation 2019, 2020. All Rights Reserved.
# Note to U.S. Government Users Restricted Rights:
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
# Licensed Materials - Property of IBM
###############################################################################
_project="$(cut -d'/' -f2 <<<"$TRAVIS_REPO_SLUG")"
_branch=${TRAVIS_TAG:-$TRAVIS_BRANCH}
_result="Failed"
_color="danger"
_text=""
if [ "$TRAVIS_TEST_RESULT" == "0" ]; then
    _result="Success"
    _color="good"
    _coverage=$(go tool cover -func=test/coverage/cover.out 2>/dev/null | grep "total:" | awk '{ print $3 }' | sed 's/[][()><%]/ /g')
    if [ -n "$_coverage" ]; then
        _text="Test Coverage: $_coverage%"
    fi
fi

if [ "$OS" == "rhel7" ]; then
    TRAVIS_OS_NAME="rhel7"
fi

cat >./slack_content.json <<EOF
{
    "attachments": [{
        "title": "$_project - $_branch - $TRAVIS_OS_NAME - $_result",
        "title_link": "https://travis.ibm.com/$TRAVIS_REPO_SLUG/jobs/$TRAVIS_JOB_ID",
        "text": "$_text",
        "color": "$_color"
    }]
}
EOF

cat ./slack_content.json

curl -s -H "Content-Type: application/json" -X POST -d @slack_content.json "https://hooks.slack.com/services/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"
rm slack_content.json
