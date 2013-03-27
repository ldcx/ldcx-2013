#!/bin/sh
#
# Test fedora access permissions
#

#set -x

reverse_on="\x1b[7m"
reverse_off="\x1b[0m"

reverse_on="***"
reverse_off="***"

# configuration of fedora instance

fedora_host=localhost
fedora_port=8983
admin_user=fedoraAdmin
admin_pass=fedoraAdmin
modify_fedora=true

special_prefixes="ARCH-SEASIDE CATHOLLIC-PAMPHLET CYL LAPOP NDU RBSC- VIDEO-CONTENT"
deletable_prefixes="ARCH-SEASIDE CATHOLLIC-PAMPHLET CYL LAPOP RBSC- VIDEO-CONTENT"

output_dir=$(dirname $0)/output
mkdir -p $output_dir

# wraps a call to fedora
# $1 = command to send to fedora
# rest = optional parameters:
#       "admin" = send the request as the admin user
#       "post"  = make post request
#       "post_data" = make post request using next argument as data
function tell_fedora() {
    local options="--silent --fail"
    local url=$1
    local input_data
    local not_verbose
    shift
    while [ $1 ]; do
        case $1 in
            admin)
                options+=" --user $admin_user:$admin_pass"
                shift
                ;;
            post)
                options+=" -X POST"
                shift
                ;;
            post_data)
                options+=" -d @-"
                input_data="$2"
                shift 2
                ;;
            put)
                options+=" -X PUT"
                shift
                ;;
            delete)
                options+=" -X DELETE"
                shift
                ;;
            not_verbose)
                not_verbose=true
                shift
                ;;
            status_only)
                options+=' -w "%{http_code}" -o /dev/null'
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    if [ -z $not_verbose ]; then
        options+=" --verbose"
    fi
    options+=" http://$fedora_host:$fedora_port/fedora/$url"

    echo "$input_data" | curl $options
    return $?
}

# run tests!

total_count=0
success_count=0
fail_count=0

# $1 = test name
# $2 = fedora command
# $3 = optional "admin"
function should_work() {
    local test_name=$1
    shift
    perform_test -eq "$test_name as anonymous" "$@"
    perform_test -eq "$test_name as Admin" "$@" admin
}

function should_not_work() {
    local test_name=$1
    shift
    perform_test -ne "$test_name as anonymous" "$@"
    perform_test -ne "$test_name as Admin" "$@" admin
}

function should_only_work_admin() {
    local test_name=$1
    shift
    perform_test -ne "$test_name as anonymous" "$@"
    perform_test -eq "$test_name as Admin" "$@" admin
}

function perform_test() {
    let total_count++
    local comparison=$1
    local description=$2
    local outfile=$output_dir/test-$total_count-$(echo $2 | sed 'y/ /-/')
    shift 2
    if [ -f $outfile ]; then
        local count=1
        while [ -f $outfile-$count ]; do
            let count++
        done
        outfile=$outfile-$count
    fi
    printf "$total_count) $description... "
    tell_fedora "$@" > $outfile 2>&1
    local retval=$?
    if [ $retval -eq 0 ]; then
        printf "(worked) "
    else
        printf "(rejected) "
    fi
    if [ $retval $comparison 0 ]; then
        printf "pass\\n"
        let success_count++
    else
        printf "${reverse_on}fail${reverse_off}\\n"
        let fail_count++
    fi
}

function create_object() {
    local pid="$1"
    # does object exist?
    local code=$(tell_fedora "objects/$pid" admin not_verbose status_only)
    case $code in
        *200*)
            # object exists...don't do anything
            printf "Object $pid already exists\\n"
            ;;
        *401*)
            # object exists, but we don't have permission to touch it
            printf "Don't have permission to access $pid\\n"
            return 1
            ;;
        *404*)
            # object does not exist
            printf "Creating object $pid\\n"
            tell_fedora "objects/$pid?label=test" admin not_verbose post 2>&1 1>/dev/null
            ;;
        *)
            # wat?!
            printf "Got code $code making $pid\\n"
            return 1
            ;;
    esac
}

noid=test
if [ $modify_fedora = true ]; then
    printf "Creating test objects\\n"
    error_count=0
    count=0
    while true ; do
        let count++
        let error_count++
        if [ $error_count -ge 100 ]; then
            printf "Serious problem making objects\\n"
            printf "Continuing anyway\\n"
            break
        fi
        create_object "changeme:$noid$count"
        if [ $? -ne 0 ]; then
            continue
        fi
        for prefix in $special_prefixes; do
            create_object "$prefix:$noid$count"
            if [ $? -ne 0 ]; then
                continue 2
            fi
        done
        break
    done
    noid="$noid$count"
else
    printf "Not loading objects since modify_fedora is off\\n"
fi

# Must also enable listDatastreams to get the API-A version of
# getDatastreamDissemination to work (seems related to fedora commons jira issue FCREPO-703)
# The API-A-LITE version of getDatastreamDissemination doesn't have this problem


printf "========== Testing API-A-LITE (deprecated) ==========\\n"
should_work "describeRepository" "describe"
should_only_work_admin "findObjects" "search?query=pid%7E*&pid=true"
# resumeFindObjects # test not implemented

function api_a_lite_common() {
    local prefix=$1

    # getDissemination # test not implemented
    should_only_work_admin "getObjectHistory $prefix" "getObjectHistory/$prefix:$noid"
    should_only_work_admin "getObjectProfile $prefix" "get/$prefix:$noid"
    should_only_work_admin "listMethods $prefix" "listMethods/$prefix:$noid?xml=true"
}

should_only_work_admin "getDatastreamDissemination changeme" "get/changeme:$noid/DC"
should_only_work_admin "listDatastreams changeme" "listDatastreams/changeme:$noid?xml=true"
api_a_lite_common changeme

for prefix in $special_prefixes; do
    should_work "getDatastreamDissemination $prefix" "get/$prefix:$noid/DC"
    should_work "listDatastreams $prefix" "listDatastreams/$prefix:$noid?xml=true"
    api_a_lite_common $prefix
done



printf "========== API-M-LITE (deprecated) ==========\\n"
if [ $modify_fedora = true ]; then
    should_only_work_admin "Get next pid" "management/getNextPID?xml=true"
    # need to POST a file for this to work
    # should_not_work "Upload File" "management/upload"
else
    printf "Skipping tests which modify Fedora\\n"
fi




printf "========== Testing API-A ==========\\n"
# should_work "describeRepository" ""  # This entry has not been implemented by Fedora
should_only_work_admin "findObjects" "objects?query=pid%7E*&pid=true"
# should_work "resumeFindObjects" "" # test not implemented

function api_a_common() {
    local prefix=$1

    should_only_work_admin "getObjectHistory $prefix" "objects/$prefix:$noid/versions?format=xml"
    should_only_work_admin "getObjectProfile $prefix" "objects/$prefix:$noid?format=xml"
    should_only_work_admin "listMethods $prefix" "objects/$prefix:$noid/methods?format=xml"
}

should_only_work_admin "getDatastreamDissemination changeme" "objects/changeme:$noid/datastreams/DC/content"
should_only_work_admin "listDatastreams changeme" "objects/changeme:$noid/datastreams?format=xml"
# should_work "getDissemination" "" # test not implemented
api_a_common changeme

for prefix in $special_prefixes; do
    should_work "getDatastreamDissemination $prefix" "objects/$prefix:$noid/datastreams/DC/content"
    should_work "listDatastreams $prefix" "objects/$prefix:$noid/datastreams?format=xml"
    api_a_common $prefix
done



printf "========== Testing API-M ==========\\n"
for prefix in changeme $special_prefixes; do
    should_only_work_admin "export $prefix" "objects/$prefix:$noid/export"
    should_only_work_admin "getDatastream $prefix" "objects/$prefix:$noid/datastreams/DC?format=xml"
    should_only_work_admin "getDatastreamHistory $prefix" "objects/$prefix:$noid/datastreams/DC/history?format=xml"
    should_only_work_admin "getDatastreams $prefix" "objects/$prefix:$noid/datastreams?profiles=true"
    should_only_work_admin "getObjectXML $prefix" "objects/$prefix:$noid/objectXML"
    should_only_work_admin "getRelationships $prefix" "objects/$prefix:$noid/relationships"
    # should_only_work_admin "compareDatastreamChecksum $prefix" "" # test not implemented
    should_only_work_admin "validate $prefix" "objects/$prefix:$noid/validate"
done

function api_m_common() {
    local prefix="$1"

    should_only_work_admin "addDatastream $prefix" "objects/$prefix:$noid/datastreams/test?controlGroup=M&dsLabel=test&checksumType=SHA-256&mimeType=text/plain" post_data "some-content"
    should_only_work_admin "addRelationship $prefix" "objects/$prefix:$noid/relationships/new?predicate=http%3a%2f%2fwww.example.org%2frels%2fname&object=dublin%20core&isLiteral=true" post
    #should_not_work "ingest $prefix" "objects/$prefix:$noid/relationships"
    should_only_work_admin "modifyDatastream $prefix" "objects/$prefix:$noid/datastreams/test?dsLabel=test-changed" put
    should_only_work_admin "modifyObject $prefix" "objects/$prefix:$noid?label=test--new%20label" put
    should_only_work_admin "setDatastreamVersionable $prefix" "objects/$prefix:$noid/datastreams/test?versionable=true" put
    should_only_work_admin "setDatastreamState $prefix" "objects/$prefix:$noid/datastreams/test?dsState=I" put
    # unimplemented:
    #purgeRelationship
    #upload
}

function should_only_soft_delete() {
    local prefix="$1"

    # the ordering of the following tests is important since the "D" states render
    # the object/datastream unreachable
    should_not_work "purgeDatastream $prefix" "objects/$prefix:$noid/datastreams/test" delete
    should_not_work "purgeObject $prefix" "objects/$prefix:$noid" delete
    # this relies on the previous test passing (so the object still exists)
    # and the datastream having a "D" state

    # Fedora bug? cannot set the datastream state to D...think the xacml policy is confusing
    # the current ds state with the new ds state
    #should_only_work_admin "setDatastreamState D $prefix" "objects/$prefix:$noid/datastreams/test?dsState=D" put
    #should_not_work "get D datastream $prefix" "objects/$prefix:$noid/datastreams/test/content"
    # put the object in a D state and try to access
    should_only_work_admin "set object D state $prefix" "objects/$prefix:$noid?state=D" put
    should_not_work "get D object $prefix" "objects/$prefix:$noid?format=xml"
    should_not_work "get datastream from D object $prefix" "objects/$prefix:$noid/datastreams/test/content"
}

function should_purge() {
    local prefix="$1"

    # for these tests, we do not care about soft deletes...because these objects
    # can be purged outright
    should_only_work_admin "purgeDatastream $prefix" "objects/$prefix:$noid/datastreams/test" delete
    should_only_work_admin "purgeObject $prefix" "objects/$prefix:$noid" delete
}

if [ $modify_fedora = true ]; then
    should_only_work_admin "getNextPID" "objects/nextPID" post

    for prefix in changeme NDU; do
        api_m_common $prefix
        should_only_soft_delete $prefix
    done

    for prefix in $deletable_prefixes; do
        api_m_common $prefix
        should_purge $prefix
    done
else
    printf "Skipping tests which modify Fedora\\n"
fi

printf "========== OAI Access ==========\\n"
should_not_work "Identify" "oai?verb=Identify"

printf "====================\\n"
printf "$total_count tests:\\n $success_count Successes\\n $fail_count Failures\\n"
