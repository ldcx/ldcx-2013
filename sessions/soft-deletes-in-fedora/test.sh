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
delete_prefixes="ARCH-SEASIDE CATHOLLIC-PAMPHLET CYL LAPOP NDU RBSC- VIDEO-CONTENT"

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
    # TODO: check if the object exists before trying to create it
    printf "Creating $1 test object\\n"
    tell_fedora "objects/$1?label=test" admin not_verbose post 2>&1 1>/dev/null
    # the above may error if the object already exists
}

if [ $modify_fedora = true ]; then
    create_object "changeme:1"
    for prefix in $special_prefixes; do
        create_object "$prefix:test"
    done
else
    printf "Please ensure the objects changeme:1 exists in fedora\\n"
fi

# Must also enable listDatastreams to get the API-A version of
# getDatastreamDissemination to work (seems related to fedora commons jira issue FCREPO-703)
# The API-A-LITE version of getDatastreamDissemination doesn't have this problem


printf "========== Testing API-A-LITE (deprecated) ==========\\n"
should_only_work_admin "describeRepository works" "describe"
should_only_work_admin "findObjects" "search?query=pid%7E*&pid=true"
# resumeFindObjects # test not implemented
should_only_work_admin "getDatastreamDissemination changeme" "get/changeme:1/DC"
# getDissemination # test not implemented
should_only_work_admin "getObjectHistory History" "getObjectHistory/changeme:1"
should_only_work_admin "getObjectProfile changeme" "get/changeme:1"
should_only_work_admin "listDatastreams changeme" "listDatastreams/changeme:1?xml=true"
should_only_work_admin "listMethods changeme" "listMethods/changeme:1?xml=true"
for prefix in $special_prefixes; do
    should_work "getDatastreamDissemination $prefix" "get/$prefix:test/DC"
    should_only_work_admin "getObjectHistory $prefix" "getObjectHistory/$prefix:test"
    should_only_work_admin "getObjectProfile $prefix" "get/$prefix:test"
    should_work "listDatastreams $prefix" "listDatastreams/$prefix:test?xml=true"
    should_only_work_admin "listMethods $prefix" "listMethods/$prefix:test?xml=true"
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
should_only_work_admin "getDatastreamDissemination changeme" "objects/changeme:1/datastreams/DC/content"
# should_work "getDissemination" "" # test not implemented
should_only_work_admin "getObjectHistory changeme" "objects/changeme:1/versions?format=xml"
should_only_work_admin "getObjectProfile changeme" "objects/changeme:1?format=xml"
should_only_work_admin "listDatastreams changeme" "objects/changeme:1/datastreams?format=xml"
should_only_work_admin "listMethods changeme" "objects/changeme:1/methods?format=xml"

for prefix in $special_prefixes; do
    should_work "getDatastreamDissemination $prefix" "objects/$prefix:test/datastreams/DC/content"
    # should_work "getDissemination" "" # test not implemented
    should_only_work_admin "getObjectHistory $prefix" "objects/$prefix:test/versions?format=xml"
    should_only_work_admin "getObjectProfile $prefix" "objects/$prefix:test?format=xml"
    should_work "listDatastreams $prefix" "objects/$prefix:test/datastreams?format=xml"
    should_only_work_admin "listMethods $prefix" "objects/$prefix:test/methods?format=xml"
done

printf "========== Testing API-M ==========\\n"
should_only_work_admin "export changeme" "objects/changeme:1/export"
should_only_work_admin "getDatastream changeme" "objects/changeme:1/datastreams/DC?format=xml"
should_only_work_admin "getDatastreamHistory changeme" "objects/changeme:1/datastreams/DC/history?format=xml"
should_only_work_admin "getDatastreams changeme" "objects/changeme:1/datastreams?profiles=true"
should_only_work_admin "getObjectXML changeme" "objects/changeme:1/objectXML"
should_only_work_admin "getRelationships changeme" "objects/changeme:1/relationships"
# should_only_work_admin "compareDatastreamChecksum changeme" "" # test not implemented
should_only_work_admin "validate changeme" "objects/changeme:1/validate"

for prefix in $special_prefixes; do
    should_only_work_admin "export $prefix" "objects/$prefix:test/export"
    should_only_work_admin "getDatastream $prefix" "objects/$prefix:test/datastreams/DC?format=xml"
    should_only_work_admin "getDatastreamHistory $prefix" "objects/$prefix:test/datastreams/DC/history?format=xml"
    should_only_work_admin "getDatastreams $prefix" "objects/$prefix:test/datastreams?profiles=true"
    should_only_work_admin "getObjectXML $prefix" "objects/$prefix:test/objectXML"
    should_only_work_admin "getRelationships $prefix" "objects/$prefix:test/relationships"
    # should_only_work_admin "compareDatastreamChecksum $prefix" "" # test not implemented
    should_only_work_admin "validate $prefix" "objects/$prefix:test/validate"
done

if [ $modify_fedora = true ]; then
    should_only_work_admin "getNextPID" "objects/nextPID" post
    should_only_work_admin "addDatastream changeme" "objects/changeme:1/datastreams/test?controlGroup=M&dsLabel=test&checksumType=SHA-256&mimeType=text/plain" post_data "some-content"
    should_only_work_admin "addRelationship changeme" "objects/changeme:1/relationships/new?predicate=http%3a%2f%2fwww.example.org%2frels%2fname&object=dublin%20core&isLiteral=true" post
    # didn't have time to implement tests for these calls
    #should_not_work "ingest changeme" "objects/changeme:1/relationships"
    should_only_work_admin "modifyDatastream changeme" "objects/changeme:1/datastreams/test?dsLabel=test-changed" put
    should_only_work_admin "modifyObject changeme" "objects/changeme:1?label=test--new%20label" put
    should_only_work_admin "setDatastreamVersionable changeme" "objects/changeme:1/datastreams/test?versionable=true" put
    should_only_work_admin "setDatastreamState changeme" "objects/changeme:1/datastreams/test?dsState=D" put
    should_not_work "purgeDatastream changeme" "objects/changeme:1/datastreams/test" delete
    should_not_work "purgeObject changeme" "objects/changeme:1" delete
    #purgeRelationship
    #upload

    for prefix in $special_prefixes; do
        should_only_work_admin "addDatastream $prefix" "objects/$prefix:test/datastreams/test?controlGroup=M&dsLabel=test&checksumType=SHA-256&mimeType=text/plain" post_data "some-content"
        should_only_work_admin "addRelationship $prefix" "objects/$prefix:test/relationships/new?predicate=http%3a%2f%2fwww.example.org%2frels%2fname&object=dublin%20core&isLiteral=true" post
        should_only_work_admin "modifyDatastream $prefix" "objects/$prefix:test/datastreams/test?dsLabel=test-changed" put
        should_only_work_admin "modifyObject $prefix" "objects/$prefix:test?label=test--new%20label" put
        should_only_work_admin "setDatastreamVersionable $prefix" "objects/$prefix:test/datastreams/test?versionable=true" put
        should_only_work_admin "setDatastreamState $prefix" "objects/$prefix:test/datastreams/test?dsState=D" put
        should_not_work "purgeDatastream $prefix" "objects/$prefix:test/datastreams/test" delete
        should_not_work "purgeObject $prefix" "objects/$prefix:test" delete
    done
else
    printf "Skipping tests which modify Fedora\\n"
fi

printf "========== OAI Access ==========\\n"
should_not_work "Identify" "oai?verb=Identify"

printf "====================\\n"
printf "$total_count tests:\\n $success_count Successes\\n $fail_count Failures\\n"
