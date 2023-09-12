package torque.environment

import future.keywords.if


# This policy enforces rules for how many vCPUs a user is allowed to request when deploying vmware VMs
# It takes two numbers as arguments (in the data object):
#   1. env_max_vcpus : the highest number of vcpus the user is allowed to request. Entries above this value will be denied
#   2. env_needs_approval_vcpus : the number of vcpus above which a request requires approval
#
# An example of a data object for this policy looks like this:
# {
#   "env_max_vcpus": 16,
#   "env_needs_approval_vcpus": 5
# }
#

#### Making inputs more friendly, not really necessary
bp_inputs := input.inputs

#### Extract the value of the "vcpus" input, if it exists 
vcpus = value {
    some i
    obj = bp_inputs[i]
    #### Hardcoding the input name, this could be a data value instead
    obj.name == "vcpus"
    value = obj.value
}

#### If this input name does not exist in the BP, approve it
result = { "decision": "Approved" } if {
	not vcpus
} 

result := {"decision": "Denied", "reason": "max_vcpus and needs_approval_vcpus have to be numbers."} if {
	data.env_max_vcpus
	not is_number(data.env_max_vcpus)
	data.env_needs_approval_vcpus
	not is_number(data.env_needs_approval_vcpus)
}

result = {"decision": "Denied", "reason": sprintf("requested number of vcpus (%d) exceeds maximum of %d", [vcpus,data.env_max_vcpus])} if {
    is_number(data.env_max_vcpus)
	vcpus > data.env_max_vcpus
}

result = {"decision": "Manual", "reason": "this number of vcpus requires approval"} if {
	is_number(data.env_max_vcpus)
	is_number(data.env_needs_approval_vcpus)
	data.env_max_vcpus >= vcpus
	data.env_needs_approval_vcpus <= vcpus
}

result = {"decision": "Approved"} if {
    is_number(data.env_max_vcpus)
	is_number(data.env_needs_approval_vcpus)
	data.env_max_vcpus >= vcpus
	data.env_needs_approval_vcpus > vcpus
}