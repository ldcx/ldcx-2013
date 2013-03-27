# Soft Deletes in Fedora with Rubydora and XACMLs

Two adjustments were required:

* Adjust Fedora's default XACML policies
* Adjust Rubydora's purge behavior
* Adjust ActiveFedora's behavior

## XACML files to enforce soft deletes

Replace default XACML policies with the repository-policies.
`test.sh` is for verifying the Fedora configuration.

## Rubydora and ActiveFedora behavior

https://github.com/ndlib/curate_nd/blob/master/config/initializers/active_fedora_monkey_patch.rb

https://github.com/ndlib/curate_nd/blob/master/spec/initializers/active_fedora_monkey_patch_spec.rb

## Discussion Concerning Alternate Implementation

Discussion concerning an adjustment to Rubydora to say "don't fetch deleted objects."
