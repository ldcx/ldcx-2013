# Soft Deletes in Fedora with Rubydora and XACMLs

Two adjustments were required:

* Adjust Fedora's default XACML policies
* Adjust Rubydora's purge behavior
* Adjust ActiveFedora's behavior

## XACML files to enforce soft deletes

Replace default XACML policies with the repository-policies.

https://github.com/ldcx/ldcx-2013/tree/master/sessions/soft-deletes-in-fedora

[`test.sh`](https://github.com/ldcx/ldcx-2013/blob/master/sessions/soft-deletes-in-fedora/test.sh) is for verifying the Fedora configuration.

## Rubydora and ActiveFedora behavior

Here are the few lines of code to implement soft deletes:

https://github.com/ndlib/curate_nd/blob/master/config/initializers/active_fedora_monkey_patch.rb

And a test to verify behavior:

https://github.com/ndlib/curate_nd/blob/master/spec/initializers/active_fedora_monkey_patch_spec.rb

## Discussion Concerning Alternate Implementation

Discussion concerning an adjustment to Rubydora to say "don't fetch deleted objects."
